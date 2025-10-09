import 'package:dice_master/core/theme/theme_cubit.dart';
import 'package:dice_master/features/account/widgets/custom_list_tile.dart';
import 'package:dice_master/features/settings/bloc/settings_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

Future<User> _getUser() async {
  return FirebaseAuth.instance.currentUser!;
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
          return ListView(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomListTile(
                    icon: Icons.dark_mode_outlined,
                    iconColor: Theme.of(context).colorScheme.primary,
                    title: "Theme",
                    titleColor: Colors.white,
                    subtitle: "Toggle appearance theme",
                    trailing: Switch(
                      value: Theme.of(context).brightness == Brightness.dark,
                      onChanged: (value) {
                        context.read<ThemeCubit>().toggle();
                      },
                    ),
                  ),
                ],
              ),
            ],
          );
        }
        return const Center(child: CircularProgressIndicator());
      }),
    );
  }
}
