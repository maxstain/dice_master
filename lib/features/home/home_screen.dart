import 'package:dice_master/features/home/widgets/home_lobby_screen.dart';
import 'package:dice_master/features/home/widgets/home_skeleton_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/home_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading) {
          return const HomeSkeletonScreen();
        } else if (state is HomeFailure) {
          return Scaffold(
            body: Center(
              child: Text("Error: ${state.message}"),
            ),
          );
        } else if (state is HomeLoaded) {
          return HomeLobbyScreen(campaigns: state.campaigns);
        } else {
          return const Scaffold(
            body: Center(child: Text("Unknown state")),
          );
        }
      },
    );
  }
}
