import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/campaign.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../campaign/campaign_screen.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';

class HomeLobbyScreen extends StatefulWidget {
  final List<Campaign> campaigns;

  const HomeLobbyScreen({super.key, required this.campaigns});

  @override
  State<HomeLobbyScreen> createState() => _HomeLobbyScreenState();
}

class _HomeLobbyScreenState extends State<HomeLobbyScreen> {
  Future<void> _refreshCampaigns(BuildContext context) async {
    context.read<HomeBloc>().add(const HomeStarted());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        // While refreshing/loading
        if (state is HomeLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Loaded state
        if (state is HomeLoaded) {
          final campaigns = state.campaigns;

          return Scaffold(
            appBar: AppBar(
              title: const Text('My Campaigns'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    context.read<AuthBloc>().add(SignOutRequested());
                  },
                ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: () => _refreshCampaigns(context),
              child: campaigns.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 200),
                        Center(child: Text("No campaigns yet")),
                      ],
                    )
                  : ListView.builder(
                      itemCount: campaigns.length,
                      itemBuilder: (ctx, index) {
                        final c = campaigns[index];
                        return ListTile(
                          title: Text(c.title),
                          subtitle: FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('users')
                                .doc(c.hostId)
                                .get(),
                            builder: (ctx, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Text("Loading host...");
                              }
                              if (!snapshot.hasData || !snapshot.data!.exists) {
                                return Text("Host: ${c.hostId}");
                              }
                              final data =
                                  snapshot.data!.data() as Map<String, dynamic>;
                              final hostName = data['username'] ?? c.hostId;
                              return Text("Host: $hostName");
                            },
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.exit_to_app),
                            onPressed: () {
                              context
                                  .read<HomeBloc>()
                                  .add(LeaveCampaignRequested(c.id));
                            },
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    CampaignScreen(campaignId: c.id),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
            floatingActionButton: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.extended(
                  heroTag: "createCampaign",
                  onPressed: () {
                    // TODO: implement create campaign dialog
                  },
                  label: const Text('Create'),
                  icon: const Icon(Icons.add),
                ),
                const SizedBox(height: 12),
                FloatingActionButton.extended(
                  heroTag: "joinCampaign",
                  onPressed: () {
                    // TODO: implement join campaign dialog
                  },
                  label: const Text('Join'),
                  icon: const Icon(Icons.group_add),
                ),
              ],
            ),
          );
        }

        // Fallback for any other state
        return const Scaffold(
          body: Center(child: Text("No campaigns available")),
        );
      },
    );
  }
}
