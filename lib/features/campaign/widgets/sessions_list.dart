import 'package:dice_master/features/character/create_character_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/campaign.dart';
import '../../../models/character.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../bloc/campaign_bloc.dart';
import '../bloc/campaign_event.dart';

class SessionsList extends StatelessWidget {
  final Campaign campaign;
  final List<Character> players;
  final bool isDungeonMaster;

  const SessionsList({
    super.key,
    required this.campaign,
    required this.players,
    required this.isDungeonMaster,
  });

  void _createSession(BuildContext context) {
    final newSession = {
      "id": DateTime.now().millisecondsSinceEpoch.toString(),
      "title": "Session ${campaign.sessions.length + 1}",
      "createdAt": DateTime.now().toIso8601String(),
      "participants": [],
    };

    context
        .read<CampaignBloc>()
        .add(AddSessionRequested(campaign.id, newSession));
  }

  void _joinSession(BuildContext context, String sessionId) async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final userId = authState.user.uid;

      context
          .read<CampaignBloc>()
          .add(JoinSessionRequested(campaign.id, sessionId, userId));

      // Navigate to character creation
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CreateCharacterScreen(
            campaignId: campaign.id,
            userId: userId,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("You must be signed in to join a session")),
      );
    }
  }

  Widget _buildParticipants(List<dynamic> ids) {
    if (ids.isEmpty) return const Text("No participants yet");

    final participantTiles = ids.map((id) {
      final character = players.firstWhere(
        (p) => p.id == id,
        orElse: () => Character(
          id: id,
          name: "Unknown",
          role: "unknown",
          race: "unknown",
          level: 0,
          hp: 0,
          maxHp: 0,
          imageUrl: "",
        ),
      );
      return ListTile(
        leading: character.imageUrl.isNotEmpty
            ? CircleAvatar(backgroundImage: NetworkImage(character.imageUrl))
            : const CircleAvatar(child: Icon(Icons.person)),
        title: Text(character.name),
        subtitle: Text(
            "${character.role} • ${character.race} (Lvl ${character.level})"),
        trailing: Text("${character.hp}/${character.maxHp} HP"),
      );
    }).toList();

    return Column(children: participantTiles);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Sessions",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (campaign.sessions.isEmpty) const Text("No sessions yet"),
        if (campaign.sessions.isNotEmpty)
          ...campaign.sessions.map((s) {
            final sessionId = s['id'] ?? 'unknown';
            final title = s['title'] ?? 'Unnamed Session';
            final participantIds = (s['participants'] as List<dynamic>? ?? []);

            return ExpansionTile(
              title: Text(title),
              subtitle: Text("${participantIds.length} participants"),
              trailing: isDungeonMaster
                  ? IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        // TODO: implement DeleteSessionRequested
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Delete session not implemented")),
                        );
                      },
                    )
                  : ElevatedButton(
                      onPressed: () => _joinSession(context, sessionId),
                      child: const Text("Join"),
                    ),
              children: [
                _buildParticipants(participantIds),
              ],
            );
          }),
        if (isDungeonMaster)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: ElevatedButton.icon(
              onPressed: () => _createSession(context),
              icon: const Icon(Icons.add),
              label: const Text("Create Session"),
            ),
          ),
      ],
    );
  }
}
