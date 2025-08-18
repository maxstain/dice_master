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
        child: Text(
            'Welcome, Dungeon Master $dmName! This is your control panel.'),
        // You'll add DM-specific UI elements here
      ),
    );
  }
}
