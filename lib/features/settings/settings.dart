import 'package:dice_master/features/settings/bloc/settings_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(builder: (context, state) {
        if (state is SettingsLoaded) {
          return Center(
            child: Text(state.username),
          );
        }
        return const Center(child: CircularProgressIndicator());
      }),
    );
  }
}
