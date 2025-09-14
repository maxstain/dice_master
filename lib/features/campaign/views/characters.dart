import 'package:dice_master/features/campaign/widgets/character_card.dart';
import 'package:flutter/material.dart';

import '../../../models/character.dart';

class CharactersView extends StatelessWidget {
  final List<Character> players;
  final bool isDm;

  const CharactersView({
    super.key,
    required this.players,
    required this.isDm,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: players.isEmpty
          ? const Center(child: Text("No characters yet"))
          : ListView.builder(
              itemCount: players.length,
              itemBuilder: (ctx, i) {
                final character = players[i];
                return CharacterCard(character: character);
              },
            ),
    );
  }
}
