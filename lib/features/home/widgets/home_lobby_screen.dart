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
  final Map<String, String> _usernameCache = {};

  Future<void> _refreshCampaigns(BuildContext context) async {
    context.read<HomeBloc>().add(const HomeStarted());
  }

  Future<String> _getHostName(String uid) async {
    if (_usernameCache.containsKey(uid)) {
      return _usernameCache[uid]!;
    }
    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final username = data['username'] ?? uid;
        _usernameCache[uid] = username;
        return username;
      }
    } catch (e) {
      debugPrint("Failed to fetch username for $uid: $e");
    }
    return uid;
  }

  void _showCreateCampaignDialog(BuildContext context) {
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Create Campaign"),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(hintText: "Enter campaign title"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text.trim();
              if (title.isNotEmpty) {
                context.read<HomeBloc>().add(CreateCampaignRequested(title));
                Navigator.pop(ctx);
              }
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }

  void _showJoinCampaignDialog(BuildContext context) {
    final codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Join Campaign"),
        content: TextField(
          controller: codeController,
          decoration: const InputDecoration(hintText: "Enter session code"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final code = codeController.text.trim();
              if (code.isNotEmpty) {
                context.read<HomeBloc>().add(JoinCampaignRequested(code));
                Navigator.pop(ctx);
              }
            },
            child: const Text("Join"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

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
                          subtitle: FutureBuilder<String>(
                            future: _getHostName(c.hostId),
                            builder: (ctx, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Text("Loading host...");
                              }
                              return Text("Host: ${snapshot.data ?? c.hostId}");
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
                  onPressed: () => _showCreateCampaignDialog(context),
                  label: const Text('Create'),
                  icon: const Icon(Icons.add),
                ),
                const SizedBox(height: 12),
                FloatingActionButton.extended(
                  heroTag: "joinCampaign",
                  onPressed: () => _showJoinCampaignDialog(context),
                  label: const Text('Join'),
                  icon: const Icon(Icons.group_add),
                ),
              ],
            ),
          );
        }

        return const Scaffold(
          body: Center(child: Text("No campaigns available")),
        );
      },
    );
  }
}
