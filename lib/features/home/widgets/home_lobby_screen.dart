import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../campaign/campaign_screen.dart';
import '../bloc/home_bloc.dart';

class HomeLobbyScreen extends StatelessWidget {
  const HomeLobbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Campaign Lobby"),
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoaded) {
            if (state.campaigns.isEmpty) {
              return const Center(child: Text("No campaigns available"));
            }

            return RefreshIndicator(
              color: theme.colorScheme.secondary,
              // spinner color
              backgroundColor: theme.scaffoldBackgroundColor,
              // background
              strokeWidth: 3.0,
              // thickness of the progress circle
              onRefresh: () async {
                context.read<HomeBloc>().add(const HomeRefreshRequested());
                await Future.delayed(const Duration(milliseconds: 600));
              },
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: state.campaigns.length,
                itemBuilder: (ctx, i) {
                  final cwm = state.campaigns[i];

                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: Text(
                        cwm.campaign.title,
                        style: theme.textTheme.titleMedium,
                      ),
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
              ),
            );
          }

          // Fallback state
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
