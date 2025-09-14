import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dice_master/models/character.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../campaign/bloc/campaign_bloc.dart';
import '../campaign/bloc/campaign_event.dart';
import '../campaign/bloc/campaign_state.dart';
import 'views/characters.dart';
import 'views/combat.dart';
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
          return "Combat";
        case 3:
          return "Sessions";
        default:
          return state.campaign.title;
      }
    }
    return "Campaign";
  }

  Character createDefaultCharacter(String uid, String name) {
    return Character(
      id: uid,
      name: name,
      role: 'Adventurer',
      race: 'Human',
      level: 1,
      hp: 10,
      maxHp: 10,
      xp: 0.0,
      items: [],
      imageUrl: '',
    );
  }

  Future<void> _showAddCharacterDialog(
      BuildContext context, String campaignId) async {
    final nameController = TextEditingController();
    final roleController = TextEditingController();
    final raceController = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
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
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;

              final newChar = Character(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: name,
                role: roleController.text.trim().isEmpty
                    ? "Adventurer"
                    : roleController.text.trim(),
                race: raceController.text.trim().isEmpty
                    ? "Human"
                    : raceController.text.trim(),
                level: 1,
                hp: 10,
                maxHp: 10,
                xp: 0.0,
                items: [],
                imageUrl: '',
              );

              final ref = FirebaseFirestore.instance
                  .collection('campaigns')
                  .doc(campaignId)
                  .collection('players')
                  .doc(newChar.id);

              await ref.set(newChar.toJson());

              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Character ${newChar.name} added")),
              );
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddSessionDialog(
      BuildContext context, String campaignId) async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime? selectedDate;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
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
                decoration: const InputDecoration(labelText: "Description"),
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
                    onPressed: () async {
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
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final title = titleController.text.trim();
                if (title.isEmpty || selectedDate == null) return;

                final newSession = {
                  "title": title,
                  "description": descriptionController.text.trim(),
                  "date": selectedDate!.toIso8601String(),
                };

                final ref = FirebaseFirestore.instance
                    .collection('campaigns')
                    .doc(campaignId);

                await ref.update({
                  "sessions": FieldValue.arrayUnion([newSession])
                });

                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Session \"$title\" added")),
                );
              },
              child: const Text("Add"),
            ),
          ],
        ),
      ),
    );
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
    return BlocBuilder<CampaignBloc, CampaignState>(
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
            CombatView(campaign: campaign, players: players, isDm: isDm),
            SessionsView(campaign: campaign, players: players, isDm: isDm),
          ];

          return Scaffold(
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
                  icon: Icon(Icons.sports_kabaddi),
                  label: 'Combat',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.event),
                  label: 'Sessions',
                ),
              ],
            ),
          );
        }

        return const Scaffold(
          body: Center(child: Text("Campaign not found")),
        );
      },
    );
  }
}
