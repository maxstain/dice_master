import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dice_master/features/campaign/components/character_card.dart';
import 'package:dice_master/models/character.dart';
import 'package:flutter/material.dart';

class CharactersView extends StatefulWidget {
  final Stream<QuerySnapshot<Map<String, dynamic>>> players;

  const CharactersView({super.key, required this.players});

  @override
  State<CharactersView> createState() => _CharactersViewState();
}

class _CharactersViewState extends State<CharactersView> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: widget.players,
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

                return CharacterCard(
                  character: character,
                );
              },
            ),
          );
        });
  }
}
