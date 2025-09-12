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
      appBar: AppBar(title: const Text("Characters")),
      body: players.isEmpty
          ? const Center(child: Text("No characters yet"))
          : ListView.builder(
              itemCount: players.length,
              itemBuilder: (ctx, i) {
                final c = players[i];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: c.imageUrl.isNotEmpty
                          ? NetworkImage(c.imageUrl)
                          : null,
                      child: c.imageUrl.isEmpty ? Text(c.name[0]) : null,
                    ),
                    title: Text(c.name),
                    subtitle: Text("${c.race} ${c.role} • Lvl ${c.level}"),
                    trailing: Text("${c.hp}/${c.maxHp} HP"),
                    onTap: () {
                      // TODO: navigate to character details
                    },
                  ),
                );
              },
            ),
    );
  }
}
