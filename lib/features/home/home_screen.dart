import 'package:dice_master/features/home/bloc/home_bloc.dart';
import 'package:dice_master/features/home/bloc/home_event.dart';
import 'package:dice_master/features/home/bloc/home_state.dart';
import 'package:dice_master/features/home/widgets/home_lobby_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBloc()..add(const HomeStarted()),
      child: BlocListener<HomeBloc, HomeState>(
        listener: (context, state) {},
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
