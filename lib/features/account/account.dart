import 'package:dice_master/features/account/bloc/account_bloc.dart';
import 'package:dice_master/features/account/edit_profile_screen.dart';
import 'package:dice_master/features/account/widgets/custom_list_tile.dart';
import 'package:dice_master/features/auth/bloc/auth_bloc.dart';
import 'package:dice_master/features/auth/bloc/auth_event.dart';
import 'package:dice_master/features/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

enum Months {
  january,
  february,
  march,
  april,
  may,
  june,
  july,
  august,
  september,
  october,
  november,
  december
}

Future<void> _showDeleteAccountDialog(BuildContext context) async {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Account"),
          content: const Text("Are you sure you want to delete your account?"),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () =>
                  context.read<AuthBloc>().add(DeleteAccountRequested()),
              child: const Text("Delete"),
            ),
          ],
        );
      });
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Account",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocBuilder<AccountBloc, AccountState>(
        builder: (BuildContext context, AccountState state) {
          if (state is AccountLoaded) {
            return ListView(
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  margin: const EdgeInsets.all(16.0),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                    color: Colors.grey.shade900,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          FutureBuilder(
                            future: Future(() async {
                              if (state.user.photoURL != null) {
                                return state.user.photoURL;
                              }
                            }),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return CircleAvatar(
                                  radius: 30,
                                  backgroundImage: NetworkImage(snapshot.data!),
                                );
                              } else {
                                return const Icon(Icons.person);
                              }
                            },
                          ),
                          const SizedBox(width: 16.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.user.displayName!,
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                state.user.email!,
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              Text(
                                "Member since ${Months.values[state.user.metadata.creationTime!.month - 2].name} ${state.user.metadata.creationTime?.year}",
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.31,
                            vertical: 16,
                          ),
                        ),
                        onPressed: (() => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const EditProfileScreen()))),
                        child: const Text(
                          "Edit Profile",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                    color: Colors.grey.shade900,
                  ),
                  child: Column(
                    children: [
                      CustomListTile(
                        icon: Icons.settings_outlined,
                        iconColor: Theme.of(context).colorScheme.primary,
                        title: "Settings",
                        titleColor: Colors.white,
                        subtitle: "App settings and customization",
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SettingsScreen(),
                          ),
                        ),
                      ),
                      CustomListTile(
                        icon: Icons.notifications_none_outlined,
                        iconColor: Theme.of(context).colorScheme.primary,
                        title: "Notifications",
                        titleColor: Colors.white,
                        subtitle: "Manage alerts and reminders",
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                        ),
                        onTap: () {},
                      ),
                      CustomListTile(
                        icon: Icons.privacy_tip_outlined,
                        iconColor: Theme.of(context).colorScheme.primary,
                        title: "Privacy",
                        titleColor: Colors.white,
                        subtitle: "Data and privacy settings",
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                        ),
                        onTap: () {},
                      ),
                      CustomListTile(
                        icon: Icons.help_outline_outlined,
                        iconColor: Theme.of(context).colorScheme.primary,
                        title: "Help & Support",
                        titleColor: Colors.white,
                        subtitle: "Get assistance with the app",
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                        ),
                        onTap: () {},
                      ),
                      CustomListTile(
                        icon: Icons.delete_outline,
                        iconColor: Colors.red,
                        title: "Delete account",
                        titleColor: Colors.red,
                        subtitle: "Delete your account",
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                        ),
                        onTap: () {
                          _showDeleteAccountDialog(context);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else if (state is AccountFailure) {
            return Center(
              child: Text(state.message),
            );
          } else if (state is AccountLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return const Center(
              child: Text("Account not loaded"),
            );
          }
        },
      ),
    );
  }
}
