import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/home_bloc.dart';
import 'bloc/home_event.dart';
import 'bloc/home_state.dart';
import 'widgets/home_lobby_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBloc()..add(const TriggerInitialLoad()),
      child: BlocConsumer<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state is HomeFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (state is HomeNotAuthenticated) {
            return const Scaffold(
              body: Center(child: Text('Not Authenticated. Please sign in.')),
            );
          } else if (state is HomeLoaded) {
            // Campaigns loaded → show lobby
            return HomeLobbyScreen(campaigns: state.campaigns);
          }
          // Default fallback
          return const Scaffold(
            body: Center(child: Text('Welcome to Dice Master')),
          );
        },
      ),
    );
  }
}
