import 'package:flutter/material.dart';

import '../../../models/campaign.dart';
import '../../../models/character.dart';
import '../widgets/sessions_list.dart';

class SessionsView extends StatelessWidget {
  final Campaign campaign;
  final List<Character> players;
  final bool isDm;

  const SessionsView({
    super.key,
    required this.campaign,
    required this.players,
    required this.isDm,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sessions")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SessionsList(
          campaign: campaign,
          players: players,
          isDungeonMaster: isDm,
        ),
      ),
    );
  }
}
