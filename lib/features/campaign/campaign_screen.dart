import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../campaign/bloc/campaign_bloc.dart';
import '../campaign/bloc/campaign_event.dart';
import '../campaign/bloc/campaign_state.dart';
import 'views/campaign.dart';
import 'views/characters.dart';
import 'views/dashboard.dart';
import 'views/sessions.dart';

class CampaignScreen extends StatefulWidget {
  final String campaignId;

  const CampaignScreen({super.key, required this.campaignId});

  @override
  State<CampaignScreen> createState() => _CampaignScreenState();
}

class _CampaignScreenState extends State<CampaignScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<CampaignBloc>().add(CampaignStarted(widget.campaignId));
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String _getAppBarTitle(CampaignState state) {
    if (state is CampaignLoaded) {
      switch (_selectedIndex) {
        case 0:
          return state.campaign.title;
        case 1:
          return "Characters";
        case 2:
          return "Campaign";
        case 3:
          return "Sessions";
      }
    }
    return "Campaign";
  }

  List<Widget> _getAppBarActions(CampaignState state) {
    if (state is CampaignLoaded) {
      switch (_selectedIndex) {
        case 1: // Characters tab
          return [
            IconButton(
              icon: const Icon(Icons.person_add),
              tooltip: "Add Character",
              onPressed: () =>
                  _showAddCharacterDialog(context, state.campaign.id),
            ),
          ];
        case 3: // Sessions tab
          return [
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: "Add Session",
              onPressed: () =>
                  _showAddSessionDialog(context, state.campaign.id),
            ),
          ];
      }
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CampaignBloc, CampaignState>(
      listener: (context, state) {
        if (state is CampaignLoaded) {
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.successMessage!)),
            );
            // Clear message after showing
            context.read<CampaignBloc>().add(const ClearMessagesRequested());
          }
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
            // Clear message after showing
            context.read<CampaignBloc>().add(const ClearMessagesRequested());
          }
        }
      },
      builder: (context, state) {
        if (state is CampaignLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is CampaignLoaded) {
          final campaign = state.campaign;
          final players = state.players;
          final isDm = state.isDungeonMaster;

          final views = [
            DashboardView(
              campaign: campaign,
              players: players,
              isDm: isDm,
              onNavigate: _onItemTapped,
            ),
            CharactersView(players: players, isDm: isDm),
            CampaignView(
              campaign: campaign,
              players: players,
              isDm: isDm,
              notes: const [],
            ),
            SessionsView(campaign: campaign, players: players, isDm: isDm),
          ];

          return Stack(
            children: [
              Scaffold(
                appBar: AppBar(
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: Text(_getAppBarTitle(state)),
                  actions: _getAppBarActions(state),
                ),
                body: views[_selectedIndex],
                bottomNavigationBar: BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  currentIndex: _selectedIndex,
                  onTap: _onItemTapped,
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.dashboard),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.group),
                      label: 'Characters',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.menu_book), // new icon for notes
                      label: 'Campaign',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.event),
                      label: 'Sessions',
                    ),
                  ],
                ),
              ),
              if (state.isProcessing)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          );
        }

        return const Scaffold(
          body: Center(child: Text("Campaign not found")),
        );
      },
    );
  }

  // ---------------------------
  // Dialogs
  // ---------------------------

  Future<void> _showAddCharacterDialog(
      BuildContext context, String campaignId) async {
    final nameController = TextEditingController();
    final roleController = TextEditingController();
    final raceController = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return BlocListener<CampaignBloc, CampaignState>(
          listenWhen: (prev, curr) =>
              curr is CampaignLoaded && curr.successMessage != null,
          listener: (ctx, state) {
            if (state is CampaignLoaded && state.successMessage != null) {
              Navigator.pop(ctx); // ✅ close dialog on success
            }
          },
          child: BlocBuilder<CampaignBloc, CampaignState>(
            builder: (ctx, state) {
              final isProcessing =
                  state is CampaignLoaded ? state.isProcessing : false;

              return AlertDialog(
                title: const Text("Add Character"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: "Name"),
                    ),
                    TextField(
                      controller: roleController,
                      decoration: const InputDecoration(labelText: "Role"),
                    ),
                    TextField(
                      controller: raceController,
                      decoration: const InputDecoration(labelText: "Race"),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: isProcessing ? null : () => Navigator.pop(ctx),
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: isProcessing
                        ? null
                        : () {
                            final name = nameController.text.trim();
                            if (name.isEmpty) return;

                            final newChar = {
                              'id': DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString(),
                              'name': name,
                              'role': roleController.text.trim().isEmpty
                                  ? "Adventurer"
                                  : roleController.text.trim(),
                              'race': raceController.text.trim().isEmpty
                                  ? "Human"
                                  : raceController.text.trim(),
                              'level': 1,
                              'hp': 10,
                              'maxHp': 10,
                              'xp': 0.0,
                              'items': [],
                              'imageUrl': '',
                            };

                            context.read<CampaignBloc>().add(
                                AddCharacterRequested(campaignId, newChar));
                          },
                    child: isProcessing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text("Add"),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _showAddSessionDialog(
      BuildContext context, String campaignId) async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime? selectedDate;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return BlocListener<CampaignBloc, CampaignState>(
          listenWhen: (prev, curr) =>
              curr is CampaignLoaded && curr.successMessage != null,
          listener: (ctx, state) {
            if (state is CampaignLoaded && state.successMessage != null) {
              Navigator.pop(ctx); // ✅ auto-close on success
            }
          },
          child: StatefulBuilder(
            builder: (ctx, setState) {
              return BlocBuilder<CampaignBloc, CampaignState>(
                builder: (ctx, state) {
                  final isProcessing =
                      state is CampaignLoaded ? state.isProcessing : false;

                  return AlertDialog(
                    title: const Text("Add Session"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: titleController,
                          decoration: const InputDecoration(labelText: "Title"),
                        ),
                        TextField(
                          controller: descriptionController,
                          decoration:
                              const InputDecoration(labelText: "Description"),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                selectedDate == null
                                    ? "No date selected"
                                    : "Date: ${selectedDate?.toLocal()}",
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: isProcessing
                                  ? null
                                  : () async {
                                      final picked = await showDatePicker(
                                        context: ctx,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime(2100),
                                      );
                                      if (picked != null) {
                                        final time = await showTimePicker(
                                          context: ctx,
                                          initialTime: TimeOfDay.now(),
                                        );
                                        if (time != null) {
                                          setState(() {
                                            selectedDate = DateTime(
                                              picked.year,
                                              picked.month,
                                              picked.day,
                                              time.hour,
                                              time.minute,
                                            );
                                          });
                                        }
                                      }
                                    },
                            ),
                          ],
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed:
                            isProcessing ? null : () => Navigator.pop(ctx),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: isProcessing
                            ? null
                            : () {
                                final title = titleController.text.trim();
                                if (title.isEmpty || selectedDate == null)
                                  return;

                                final newSession = {
                                  "title": title,
                                  "description":
                                      descriptionController.text.trim(),
                                  "date": selectedDate!.toIso8601String(),
                                };

                                context.read<CampaignBloc>().add(
                                    AddSessionRequested(
                                        campaignId, newSession));
                              },
                        child: isProcessing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text("Add"),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
