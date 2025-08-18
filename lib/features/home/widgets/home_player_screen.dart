import 'package:dice_master/features/home/bloc/home_bloc.dart';
import 'package:dice_master/features/home/bloc/home_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePlayerScreen extends StatelessWidget {
  final String playerName;
  const HomePlayerScreen({super.key, required this.playerName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Player Screen: $playerName'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Dispatch LeaveSessionRequested first
              context.read<HomeBloc>().add(LeaveSessionRequested());
              // Then pop the current screen
              // Check if the screen can be popped before popping
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
            tooltip: 'Leave Session',
          ),
        ],
      ),
      body: Center(
        child: Text('Welcome, Player $playerName! This is your game screen.'),
        // You'll add player-specific UI elements here
      ),
    );
  }
}
