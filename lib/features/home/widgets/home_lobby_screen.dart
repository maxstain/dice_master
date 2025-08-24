import 'dart:io';

import 'package:dice_master/features/auth/bloc/auth_bloc.dart';
import 'package:dice_master/features/auth/bloc/auth_event.dart';
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
    // Initial campaign load is now triggered by HomeBloc's constructor via TriggerInitialLoad event.
    // The print statement below can be removed or kept for observing initState calls.
    print("HomeLobbyScreen: initState called.");
    // context.read<HomeBloc>().add(const HomeStarted()); // REMOVED - This was causing a loop
  }

  @override
  void dispose() {
    _campaignIdController.dispose();
    super.dispose();
  }

  Future<void> _showCreateCampaignDialog(BuildContext context) async {
    final TextEditingController nameController = TextEditingController();
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
                  context
                      .read<HomeBloc>()
                      .add(CreateCampaignRequested(campaignName: campaignName));
                  Navigator.of(dialogContext).pop();
                } else {
                  // Optional: Show a small validation message if name is empty
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

  Future<void> _showJoinCampaignDialog(BuildContext context) async {
    // _campaignIdController is already a state variable, so just clear it if needed
    _campaignIdController.clear();
    return showDialog<void>(
      context: context,
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
                final campaignId = _campaignIdController.text
                    .trim()
                    .toUpperCase(); // Ensure consistent casing if sessionCodes are uppercase
                if (campaignId.isNotEmpty) {
                  context
                      .read<HomeBloc>()
                      .add(JoinCampaignRequested(campaignId));
                  Navigator.of(dialogContext).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lobby',
          style: TextStyle(
            color:
                Colors.white, // Assuming your AppBar theme makes this visible
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh Campaigns",
            onPressed: () {
              print(
                  "HomeLobbyScreen: Refresh button pressed - Adding HomeStarted event.");
              context
                  .read<HomeBloc>()
                  .add(const HomeStarted()); // For manual refresh
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: () {
              context.read<AuthBloc>().add(SignOutRequested());
              // Navigation to SignInScreen is handled by the BlocListener in main.dart
              // The pushAndRemoveUntil to SplashScreen here might be redundant if main.dart's AuthBloc listener handles it.
              // If main.dart's listener is robust, this direct navigation might not be needed or could conflict.
              // For now, leaving it as per your existing code, but review its necessity.
              // Navigator.of(context).pushAndRemoveUntil(
              //   MaterialPageRoute(
              //     builder: (context) => const SplashScreen(),
              //   ),
              //   (route) => false,
              // );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            // Changed from Center(Padding(...)) to just Padding for less nesting
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Consider if this platform check is still what you want for create button visibility
                if (Platform.isAndroid ||
                    Platform.isIOS ||
                    Platform.isFuchsia ||
                    Platform.isLinux ||
                    Platform.isMacOS ||
                    Platform
                        .isWindows) // More inclusive if create is for all platforms
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Create New Campaign'),
                    onPressed: () {
                      _showCreateCampaignDialog(context);
                    },
                  )
                else
                  const SizedBox.shrink(),
                // If you want to hide it on web, for example

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
          const SizedBox(height: 10), // Reduced spacing
          const Text("Active Campaigns:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Expanded(
            child: BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                print(
                    "HomeLobbyScreen BlocBuilder: Received state: ${state.runtimeType}");
                if (state is HomeLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is HomeSuccess) {
                  if (state.campaigns!.isEmpty) {
                    // campaigns is not nullable in HomeSuccess
                    return const Center(
                        child: Text(
                            'No active campaigns. Create one or refresh!'));
                  }
                  return ListView.builder(
                    itemCount: state.campaigns?.length,
                    itemBuilder: (context, index) {
                      final Campaign campaign = state.campaigns![index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 6.0),
                        child: ListTile(
                          title: Text(campaign.title,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                              'Code: ${campaign.sessionCode}\nPlayers: ${campaign.players.length}'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            // Here you would typically navigate to the campaign screen
                            // For now, let's assume JoinCampaignRequested is for re-joining or entering
                            // Or this could be a different event like EnterCampaign(campaign.id)
                            print(
                                "HomeLobbyScreen: Tapped on campaign ${campaign.id}");
                            context.read<HomeBloc>().add(JoinCampaignRequested(
                                campaign
                                    .id)); // This might re-add the player if already in list
                            // Or it could be used to enter a campaign screen.
                          },
                        ),
                      );
                    },
                  );
                } else if (state is HomeFailure) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                          'Error loading campaigns: ${state.message}\nTap refresh to try again.',
                          textAlign: TextAlign.center),
                    ),
                  );
                } else if (state is HomeInitial ||
                    state is HomeNotAuthenticated) {
                  // HomeInitial might show loading, HomeNotAuthenticated should ideally not be handled here
                  // if main router handles auth. For now, showing a generic message.
                  // HomeNotAuthenticated should ideally be caught by HomeScreen or main router
                  return const Center(
                      child: Text("Initializing or not authenticated..."));
                }
                return const Center(
                    child: Text("No campaigns found or error.")); // Fallback
              },
            ),
          ),
        ],
      ),
    );
  }
}
