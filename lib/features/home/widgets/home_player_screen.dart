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
        padding: const EdgeInsets.all(16),
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

          const SizedBox(height: 16),

          // --- Campaign Notes ---
          const Text(
            "Campaign Notes",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('campaigns')
                .doc(campaign.id)
                .collection('notes')
                .orderBy('date', descending: true)
                .snapshots(),
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Text("No notes yet");
              }

              final notes = snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return {
                  "id": doc.id,
                  "title": data['title'] ?? "Untitled",
                  "content": data['content'] ?? "",
                  "date": data['date'] ?? "",
                };
              }).toList();

              return Column(
                children: notes.map((note) {
                  return Card(
                    color: const Color(0xFF1E1E2C),
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            note["title"]!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            note["content"]!,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          if ((note["date"] as String).isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                note["date"],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 16),

          // --- Sessions List ---
          SessionsList(
            campaign: campaign,
            isDungeonMaster: false,
            players: players,
          ),
        ],
      ),
    );
  }
}
