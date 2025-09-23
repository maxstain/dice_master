import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/home_bloc.dart';

class HomeLobbyScreen extends StatelessWidget {
  final List<CampaignWithMeta> campaigns;

  const HomeLobbyScreen({super.key, required this.campaigns});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Campaign Lobby")),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<HomeBloc>().add(const HomeRefreshRequested());
        },
        child: campaigns.isEmpty
            ? const Center(child: Text("No campaigns yet"))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: campaigns.length,
                itemBuilder: (ctx, i) {
                  final c = campaigns[i];

                  final waitingForHost =
                      c.hostName == c.campaign.hostId; // still UID, not loaded
                  final waitingForPlayers =
                      c.playerCount == 0 && // could be really 0, so check notes
                          c.campaign.id.isNotEmpty;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      title: Text(
                        c.campaign.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          waitingForHost
                              ? _buildLoadingLine("Loading host...")
                              : Text("Host: ${c.hostName}"),
                          waitingForPlayers
                              ? _buildLoadingLine("Counting players...")
                              : Text("${c.playerCount} players"),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          "/campaign",
                          arguments: c.campaign.id,
                        );
                      },
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // You already had create/join campaign dialogs here
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildLoadingLine(String text) {
    return Row(
      children: [
        const SizedBox(
          height: 12,
          width: 12,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
