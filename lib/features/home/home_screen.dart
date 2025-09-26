import 'package:dice_master/features/home/bloc/home_bloc.dart';
import 'package:dice_master/features/home/widgets/home_lobby_screen.dart';
import 'package:dice_master/features/home/widgets/home_skeleton_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state is HomeLoaded && state.warning != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.warning!),
              backgroundColor: Colors.orangeAccent,
              duration: const Duration(seconds: 3),
            ),
          );
        } else if (state is HomeFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.redAccent,
              duration: const Duration(seconds: 3),
            ),
          );
        } else if (state is HomeLoading) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        }
      },
      builder: (context, state) {
        if (state is HomeLoading) {
          return const HomeSkeletonScreen();
        } else if (state is HomeFailure) {
          return Scaffold(
            appBar: AppBar(title: const Text("Campaign Lobby")),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Error: ${state.message}",
                    textAlign: TextAlign.center,
                    style:
                        const TextStyle(color: Colors.redAccent, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      context
                          .read<HomeBloc>()
                          .add(const HomeTriggerInitialLoad());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text("Retry"),
                  ),
                ],
              ),
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
