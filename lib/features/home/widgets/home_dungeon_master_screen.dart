import 'package:flutter/material.dart';

import '../../../models/campaign.dart';
import '../../../models/character.dart';
import '../../campaign/widgets/notes_editor.dart';
import '../../campaign/widgets/sessions_list.dart';

class HomeDungeonMasterScreen extends StatelessWidget {
  final Campaign campaign;
  final List<Character> players;

  const HomeDungeonMasterScreen({
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
          ListTile(
            title: const Text('Session Code'),
            subtitle: Text(campaign.sessionCode),
          ),
          ListTile(
            title: Text('Players (${players.length})'),
            subtitle: Text(
              players.isEmpty
                  ? "No players yet"
                  : players.map((p) => p.name).join(", "),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: NotesEditor(
              campaignId: campaign.id,
              isDm: true,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SessionsList(
              campaign: campaign,
              isDungeonMaster: true,
              players: players,
            ),
          ),
        ],
      ),
    );
  }
}
