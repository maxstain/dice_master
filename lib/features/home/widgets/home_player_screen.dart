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
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<HomeBloc>().add(const HomeStarted());
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // logout the user or perform any necessary cleanup
              context.read<HomeBloc>().add(const LeaveCampaignRequested());
              // Navigate back to the splash screen
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
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
