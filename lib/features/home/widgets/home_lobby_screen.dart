import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../campaign/campaign_screen.dart';
import '../bloc/home_bloc.dart';

class HomeLobbyScreen extends StatelessWidget {
  const HomeLobbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Campaign Lobby"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<HomeBloc>().add(const HomeRefreshRequested());
            },
          ),
        ],
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is HomeFailure) {
            return Center(child: Text("Error: ${state.message}"));
          } else if (state is HomeLoaded) {
            if (state.campaigns.isEmpty) {
              return const Center(child: Text("No campaigns available"));
            }

            return ListView.builder(
              itemCount: state.campaigns.length,
              itemBuilder: (ctx, i) {
                final cwm = state.campaigns[i];

                return Card(
                  child: ListTile(
                    title: Text(cwm.campaign.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StreamBuilder<String>(
                          stream: cwm.hostNameStream,
                          builder: (ctx, snap) {
                            final host = snap.data ?? cwm.campaign.hostId;
                            return Text("Host: $host");
                          },
                        ),
                        StreamBuilder<int>(
                          stream: cwm.playerCountStream,
                          builder: (ctx, snap) {
                            final count = snap.data ?? 0;
                            return Text("Players: $count");
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CampaignScreen(
                            campaignId: cwm.campaign.id,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
