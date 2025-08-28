import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dice_master/models/campaign.dart';
import 'package:flutter/material.dart';

class CampaignScreen extends StatelessWidget {
  final String campaignId;

  const CampaignScreen({super.key, required this.campaignId});

  // 🔥 Campaign document stream
  Stream<Campaign> _campaignStream(String campaignId) {
    return FirebaseFirestore.instance
        .collection('campaigns')
        .doc(campaignId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return Campaign.fromJson(snapshot.data() as Map<String, dynamic>);
      } else {
        return Campaign.empty();
      }
    });
  }

  // 🔥 Players subcollection stream
  Stream<QuerySnapshot<Map<String, dynamic>>> _playersStream(
      String campaignId) {
    return FirebaseFirestore.instance
        .collection('campaigns')
        .doc(campaignId)
        .collection('players')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Campaign>(
      stream: _campaignStream(campaignId),
      builder: (context, campaignSnapshot) {
        if (campaignSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (campaignSnapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text("Error loading campaign")),
          );
        }

        final campaign = campaignSnapshot.data ?? Campaign.empty();

        if (campaign.isEmpty()) {
          return const Scaffold(
            body: Center(child: Text("Campaign not found")),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(campaign.title),
            centerTitle: true,
          ),
          body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _playersStream(campaignId),
            builder: (context, playersSnapshot) {
              if (playersSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (playersSnapshot.hasError) {
                return const Center(child: Text("Error loading players"));
              }

              final playersDocs = playersSnapshot.data?.docs ?? [];

              if (playersDocs.isEmpty) {
                return const Center(child: Text("No players yet"));
              }

              return ListView.builder(
                itemCount: playersDocs.length,
                itemBuilder: (context, index) {
                  final playerData = playersDocs[index].data();
                  final playerName = playerData['name'] ?? 'Unknown';
                  final playerRole = playerData['role'] ?? 'Adventurer';

                  return ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(
                      playerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      playerRole,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
