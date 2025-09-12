import 'package:flutter/material.dart';

import '../../../models/campaign.dart';
import '../../../models/character.dart';

class CombatView extends StatelessWidget {
  final Campaign campaign;
  final List<Character> players;
  final bool isDm;

  const CombatView({
    super.key,
    required this.campaign,
    required this.players,
    required this.isDm,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Initiative Tracker")),
      body: players.isEmpty
          ? const Center(child: Text("No participants yet"))
          : ListView.builder(
              itemCount: players.length,
              itemBuilder: (ctx, i) {
                final c = players[i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage:
                        c.imageUrl.isNotEmpty ? NetworkImage(c.imageUrl) : null,
                    child: c.imageUrl.isEmpty ? Text(c.name[0]) : null,
                  ),
                  title: Text(c.name),
                  subtitle: Text("${c.race} ${c.role} • Lvl ${c.level}"),
                  trailing: Text("${c.hp}/${c.maxHp} HP"),
                );
              },
            ),
    );
  }
}
