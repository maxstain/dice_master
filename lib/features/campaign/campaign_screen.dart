import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../home/widgets/home_dungeon_master_screen.dart';
import '../home/widgets/home_player_screen.dart';
import 'bloc/campaign_bloc.dart';
import 'bloc/campaign_event.dart';
import 'bloc/campaign_state.dart';

class CampaignScreen extends StatelessWidget {
  final String campaignId;

  const CampaignScreen({super.key, required this.campaignId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CampaignBloc()..add(CampaignStarted(campaignId)),
      child: BlocBuilder<CampaignBloc, CampaignState>(
        builder: (context, state) {
          if (state is CampaignLoading || state is CampaignInitial) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (state is CampaignFailure) {
            return Scaffold(
              body: Center(child: Text(state.message)),
            );
          } else if (state is CampaignLoaded) {
            final campaign = state.campaign;
            final players = state.players;
            if (state.isDungeonMaster) {
              return HomeDungeonMasterScreen(
                  campaign: campaign, players: players);
            } else {
              return HomePlayerScreen(campaign: campaign, players: players);
            }
          }

          return const Scaffold(
            body: Center(child: Text('Unexpected state')),
          );
        },
      ),
    );
  }
}
