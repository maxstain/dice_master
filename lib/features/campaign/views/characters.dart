import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dice_master/models/character.dart';
import 'package:flutter/material.dart';

class CharactersView extends StatefulWidget {
  final String campaignId;

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
                final Character character = Character.fromJson(playerData);

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12.0), // Slightly more rounded
                  ),
                  color: Colors.blueGrey.shade800,
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 8.0), // Adjusted margin
                  child: Padding(
                    padding: const EdgeInsets.all(16.0), // Consistent padding
                    child: Row(
                      children: [
                        const Icon(Icons.person,
                            color: Colors.white, size: 40), // Leading Icon
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                character.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                "Role: ${character.role}, Level: ${character.level}",
                                style: const TextStyle(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16.0), // Spacer before trailing
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.favorite,
                              color: Colors.redAccent,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${character.hp}",
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        });
  }
}
