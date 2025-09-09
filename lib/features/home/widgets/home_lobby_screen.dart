import 'package:dice_master/features/auth/bloc/auth_bloc.dart';
import 'package:dice_master/features/auth/bloc/auth_event.dart';
import 'package:dice_master/features/campaign/campaign_screen.dart';
import 'package:dice_master/features/home/bloc/home_bloc.dart';
import 'package:dice_master/features/home/bloc/home_event.dart';
import 'package:dice_master/features/home/bloc/home_state.dart';
import 'package:dice_master/models/campaign.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeLobbyScreen extends StatefulWidget {
  const HomeLobbyScreen({super.key});

  @override
  State<HomeLobbyScreen> createState() => _HomeLobbyScreenState();
}

class _HomeLobbyScreenState extends State<HomeLobbyScreen> {
  final _campaignIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initial campaign load is triggered by HomeBloc's constructor or a TriggerInitialLoad event.
  }

  @override
  void dispose() {
    _campaignIdController.dispose();
    super.dispose();
  }

  Future<void> _showCreateCampaignDialog(BuildContext context) async {
    final TextEditingController nameController = TextEditingController();
    final homeBloc = context.read<HomeBloc>(); // Get BLoC instance once
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Create New Campaign'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: "Campaign Name"),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Create'),
              onPressed: () {
                final campaignName = nameController.text.trim();
                if (campaignName.isNotEmpty) {
                  homeBloc
                      .add(CreateCampaignRequested(campaignName: campaignName));
                  Navigator.of(dialogContext).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Campaign name cannot be empty.")),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showJoinCampaignDialog(BuildContext outerContext) async {
    // Renamed context to avoid conflict
    _campaignIdController.clear();
    final homeBloc = outerContext
        .read<HomeBloc>(); // Get BLoC instance once from the correct context
    return showDialog<void>(
      context: outerContext, // Use the correct context
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Join Campaign'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('Please enter the Campaign ID to join.'),
                TextField(
                  controller: _campaignIdController,
                  decoration: const InputDecoration(
                      hintText: "Campaign ID (e.g., ABCDE1)"),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Join'),
              onPressed: () {
                final campaignId =
                    _campaignIdController.text.trim().toUpperCase();
                if (campaignId.isNotEmpty) {
                  // Dispatch event to HomeBloc
                  homeBloc.add(JoinCampaignRequested(campaignId));
                  Navigator.of(dialogContext)
                      .pop(); // Close dialog after dispatching
                } else {
                  ScaffoldMessenger.of(outerContext).showSnackBar(
                    // Use outerContext for ScaffoldMessenger
                    const SnackBar(
                        content: Text("Campaign ID cannot be empty.")),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
        listener: (context, state) {
          print(
              "HomeLobbyScreen BlocListener: Received state: ${state.runtimeType}"); // ADDED

          if (state is HomeCampaignJoined) {
            print(
                "HomeLobbyScreen BlocListener: State is HomeCampaignJoined with ID: ${state.campaignId}. Attempting navigation."); // ADDED
            Navigator.of(context)
                .push(
              MaterialPageRoute(
                builder: (context) =>
                    CampaignScreen(campaignId: state.campaignId),
              ),
            )
                .then((_) {
              print(
                  "HomeLobbyScreen BlocListener: Returned from CampaignScreen (after HomeCampaignJoined). Dispatching HomeStarted."); // MODIFIED
              context.read<HomeBloc>().add(const HomeStarted());
            });
            print(
                "HomeLobbyScreen BlocListener: Navigator.push initiated for HomeCampaignJoined."); // ADDED
          } else if (state is HomeFailure) {
            print(
                "HomeLobbyScreen BlocListener: State is HomeFailure with message: ${state.message}. Showing SnackBar."); // ADDED
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          } else {
            print(
                "HomeLobbyScreen BlocListener: Received unhandled state: ${state.runtimeType}"); // ADDED
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'Lobby',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: "Refresh Campaigns",
                onPressed: () {
                  context.read<HomeBloc>().add(const HomeStarted());
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: "Logout",
                onPressed: () {
                  context.read<AuthBloc>().add(SignOutRequested());
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Create New Campaign'),
                      onPressed: () {
                        _showCreateCampaignDialog(context);
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Join Existing Campaign'),
                      onPressed: () {
                        _showJoinCampaignDialog(context);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text("Active Campaigns:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Expanded(
                child: BlocBuilder<HomeBloc, HomeState>(
                  builder: (context, state) {
                    if (state is HomeLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is HomeSuccess) {
                      if (state.campaigns == null || state.campaigns!.isEmpty) {
                        return const Center(
                            child: Text(
                                'No active campaigns. Create one or refresh!'));
                      }
                      return ListView.builder(
                        itemCount: state.campaigns!.length,
                        itemBuilder: (context, index) {
                          final Campaign campaign = state.campaigns![index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 6.0),
                            child: ListTile(
                              title: Text(campaign.title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                  'Code: ${campaign.sessionCode}\nPlayers: ${campaign.players.length}'),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () {
                                context
                                    .read<HomeBloc>()
                                    .add(JoinCampaignRequested(campaign.id));
                              },
                            ),
                          );
                        },
                      );
                    }
                    if (state is HomeFailure) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                              'Error: ${state.message}\nTap refresh to try again.',
                              textAlign: TextAlign.center),
                        ),
                      );
                    }
                    if (state is HomeInitial || state is HomeNotAuthenticated) {
                      return const Center(
                          child: Text("Initializing or not authenticated..."));
                    }
                    return const Center(
                        child: Text("Processing or no campaigns found..."));
                  },
                ),
              ),
            ],
          ),
        ));
  }
}
