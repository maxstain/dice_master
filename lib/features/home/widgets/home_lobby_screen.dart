import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import '../bloc/home_bloc.dart';

class HomeLobbyScreen extends StatelessWidget {
  final List<CampaignWithMeta> campaigns;

  const HomeLobbyScreen({super.key, required this.campaigns});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Campaign Lobby",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<HomeBloc>().add(const HomeRefreshRequested());
        },
        child: campaigns.isEmpty
            ? const Center(
                child: Text(
                  "No campaigns yet",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: campaigns.length,
                itemBuilder: (ctx, i) {
                  final c = campaigns[i];

                  final waitingForHost =
                      c.hostName == c.campaign.hostId; // still UID, not loaded
                  final waitingForPlayers =
                      c.playerCount == 0 && c.campaign.id.isNotEmpty;

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
                              ? _buildShimmerLine(width: 100)
                              : Text("Host: ${c.hostName}"),
                          waitingForPlayers
                              ? _buildShimmerLine(width: 60)
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

  Widget _buildShimmerLine({double width = 120, double height = 14}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade800,
        highlightColor: Colors.grey.shade600,
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
