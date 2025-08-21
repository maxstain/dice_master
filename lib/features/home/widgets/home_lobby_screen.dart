import 'package:dice_master/features/auth/bloc/auth_bloc.dart';
import 'package:dice_master/features/auth/bloc/auth_event.dart';
import 'package:dice_master/features/home/bloc/home_bloc.dart';
import 'package:dice_master/features/home/bloc/home_event.dart';
import 'package:dice_master/features/home/bloc/home_state.dart';
import 'package:dice_master/features/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeLobbyScreen extends StatefulWidget {
  const HomeLobbyScreen({super.key});

  @override
  State<HomeLobbyScreen> createState() => _HomeLobbyScreenState();
}

class _HomeLobbyScreenState extends State<HomeLobbyScreen> {
  final _sessionIdController = TextEditingController();

  @override
  void dispose() {
    _sessionIdController.dispose();
    super.dispose();
  }

  Future<void> _showJoinSessionDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Join Session'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('Please enter the Session ID to join.'),
                TextField(
                  controller: _sessionIdController,
                  decoration: const InputDecoration(hintText: "Session ID"),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Join'),
              onPressed: () {
                final sessionId = _sessionIdController.text.trim();
                if (sessionId.isNotEmpty) {
                  context.read<HomeBloc>().add(JoinSessionRequested(sessionId));
                  Navigator.of(dialogContext).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lobby'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<HomeBloc>().add(const HomeStarted());
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // logout the user or perform any necessary cleanup
              context.read<AuthBloc>().add(SignOutRequested());
              // Navigate back to the splash screen
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const SplashScreen(),
                ),
                (route) => false, // Remove all previous routes
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize:
                          const Size(double.infinity, 50), // full width
                    ),
                    child: const Text('Create New Session'),
                    onPressed: () {
                      context.read<HomeBloc>().add(CreateSessionRequested());
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize:
                          const Size(double.infinity, 50), // full width
                    ),
                    child: const Text('Join Existing Session'),
                    onPressed: () {
                      _sessionIdController.clear(); // Clear previous input
                      _showJoinSessionDialog(context);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              if (state is HomeLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is HomeLoaded) {
                if (state.sessions.isEmpty) {
                  return const Center(child: Text('No active sessions.'));
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.sessions.length,
                  itemBuilder: (context, index) {
                    final session = state.sessions[index];
                    return ListTile(
                      title: Text(session.name),
                      subtitle: Text('ID: ${session.id}'),
                      onTap: () {
                        context
                            .read<HomeBloc>()
                            .add(JoinSessionRequested(session.id));
                      },
                    );
                  },
                );
              } else if (state is HomeFailure) {
                return Center(child: Text('Error: ${state.message}'));
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
