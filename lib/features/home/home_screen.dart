import 'package:dice_master/features/home/bloc/home_bloc.dart';
import 'package:dice_master/features/home/bloc/home_event.dart';
import 'package:dice_master/features/home/bloc/home_state.dart';
import 'package:dice_master/features/home/widgets/home_dungeon_master_screen.dart';
import 'package:dice_master/features/home/widgets/home_lobby_screen.dart';
import 'package:dice_master/features/home/widgets/home_player_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBloc()..add(const HomeStarted()),
      child: BlocListener<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state is HomeDungeonMaster) {
            Navigator.of(context)
                .push(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: BlocProvider.of<HomeBloc>(context),
                  child:
                      HomeDungeonMasterScreen(dmName: state.dungeonMasterName),
                ),
              ),
            )
                .then((_) {
              // This is called when the HomeDungeonMasterScreen is popped
              // Ensure we are not already in Lobby or another state that doesn't require leaving
              if (BlocProvider.of<HomeBloc>(context).state
                  is HomeDungeonMaster) {
                BlocProvider.of<HomeBloc>(context)
                    .add(const LeaveCampaignRequested());
              }
            });
          } else if (state is HomePlayer) {
            Navigator.of(context)
                .push(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: BlocProvider.of<HomeBloc>(context),
                  child: HomePlayerScreen(playerName: state.playerName),
                ),
              ),
            )
                .then((_) {
              // This is called when the HomePlayerScreen is popped
              if (BlocProvider.of<HomeBloc>(context).state is HomePlayer) {
                BlocProvider.of<HomeBloc>(context)
                    .add(const LeaveCampaignRequested());
              }
            });
          }
        },
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            } else if (state is HomeNotAuthenticated) {
              // You might want to navigate to an AuthScreen here
              return const Scaffold(
                body: Center(child: Text('Not Authenticated. Please log in.')),
              );
            }
            // For HomeLobby, HomeDungeonMaster, HomePlayer, or any other state
            // that should show the lobby when no other screen is pushed.
            // The actual DM/Player screens are pushed by the listener.
            return const HomeLobbyScreen();
          },
        ),
      ),
    );
  }
}
