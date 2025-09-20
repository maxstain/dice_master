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
    return Scaffold(
      appBar: AppBar(
        title: Text(campaign.title),
      ),
      body: ListView(
        children: [
          // --- Host Info ---
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

          // --- Players Info ---
          ListTile(
            title: Text('Players (${players.length})'),
            subtitle: Text(
              players.isEmpty
                  ? "No players yet"
                  : players.map((p) => p.name).join(", "),
            ),
          ),

          // --- Notes from Firestore subcollection ---
          ListTile(
            title: const Text('Notes'),
            subtitle: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('campaigns')
                  .doc(campaign.id)
                  .collection('notes')
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text("Loading notes...");
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text("No notes yet");
                }
                final notes = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final title = data['title'] ?? 'Untitled';
                  final content = data['content'] ?? '';
                  final date = data['date'] ?? '';
                  return "- $title: $content (${date.toString()})";
                }).join("\n");

                return Text(notes);
              },
            ),
          ),

          // --- Sessions List ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SessionsList(
              campaign: campaign,
              isDungeonMaster: false,
              players: players,
            ),
          ),
        ],
      ),
    );
  }
}
