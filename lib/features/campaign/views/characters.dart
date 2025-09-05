import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CharactersView extends StatefulWidget {
  final campaignId;

  const CharactersView({super.key, required this.campaignId});

  @override
  State<CharactersView> createState() => _CharactersViewState();
}

// 🔥 Players subcollection stream
Stream<QuerySnapshot<Map<String, dynamic>>> _playersStream(String campaignId) {
  return FirebaseFirestore.instance
      .collection('campaigns')
      .doc(campaignId)
      .collection('players')
      .snapshots();
}

class _CharactersViewState extends State<CharactersView> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _playersStream(widget.campaignId),
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

          return Expanded(
            child: ListView.builder(
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
            ),
          );
        });
  }
}
