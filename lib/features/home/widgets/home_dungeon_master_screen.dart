import 'package:dice_master/features/home/bloc/home_bloc.dart';
import 'package:dice_master/features/home/bloc/home_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeDungeonMasterScreen extends StatelessWidget {
  final String dmName;

  const HomeDungeonMasterScreen({super.key, required this.dmName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DM Screen: $dmName'),
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
              context.read<HomeBloc>().add(LeaveSessionRequested());
              // Navigate back to the splash screen
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
            'Welcome, Dungeon Master $dmName! This is your control panel.'),
        // You'll add DM-specific UI elements here
      ),
    );
  }
}
