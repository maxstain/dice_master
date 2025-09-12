import 'package:dice_master/features/campaign/views/combat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../campaign/bloc/campaign_bloc.dart';
import '../campaign/bloc/campaign_state.dart';
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
            DashboardView(campaign: campaign, players: players, isDm: isDm),
            CharactersView(players: players, isDm: isDm),
            CombatView(campaign: campaign, players: players, isDm: isDm),
            SessionsView(campaign: campaign, players: players, isDm: isDm),
          ];

          return Scaffold(
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
                  icon: Icon(Icons.bolt),
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
