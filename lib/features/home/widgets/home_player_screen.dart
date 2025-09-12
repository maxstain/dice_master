import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../models/campaign.dart';
import '../../../models/character.dart';
import '../../campaign/widgets/sessions_list.dart';

class HomePlayerScreen extends StatelessWidget {
  final Campaign campaign;
  final List<Character> players;

  const HomePlayerScreen({
    super.key,
    required this.campaign,
    required this.players,
  });

  @override
  Widget build(BuildContext context) {
    final notes = campaign.notes.isEmpty
        ? "No notes yet"
        : campaign.notes.entries.map((e) => "${e.key}: ${e.value}").join("\n");

    return Scaffold(
      appBar: AppBar(
        title: Text(campaign.title),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Host'),
            subtitle: FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(campaign.hostId)
                  .get(),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text("Loading host...");
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Text("Host: ${campaign.hostId}");
                }
                final data = snapshot.data!.data() as Map<String, dynamic>;
                final hostName = data['username'] ?? campaign.hostId;
                return Text("Host: $hostName");
              },
            ),
          ),
          ListTile(
            title: Text('Players (${players.length})'),
            subtitle: Text(
              players.isEmpty
                  ? "No players yet"
                  : players.map((p) => p.name).join(", "),
            ),
          ),
          ListTile(
            title: const Text('Notes'),
            subtitle: Text(notes),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SessionsList(
              campaign: campaign,
              isDungeonMaster: false,
              players: [],
            ),
          ),
        ],
      ),
    );
  }
}
