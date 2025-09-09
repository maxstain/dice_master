import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dice_master/features/campaign/components/session_card.dart';
import 'package:dice_master/models/campaign.dart';
import 'package:dice_master/models/character.dart';
import 'package:dice_master/models/session.dart';
import 'package:flutter/material.dart';

class DashboardView extends StatefulWidget {
  final Campaign campaign;
  final Stream<QuerySnapshot<Map<String, dynamic>>> players;

  const DashboardView({
    super.key,
    required this.campaign,
    required this.players,
  });

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

Future<String> getHostName(String hostId) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(hostId)
      .get()
      .then((doc) => doc['username'] as String)
      .catchError((_) => 'Unknown');
}

class _DashboardViewState extends State<DashboardView> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getHostName(widget.campaign.hostId),
        builder: (context, asyncSnapshot) {
          return Column(
            children: [
              Text(widget.campaign.title,
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              Text(
                "Dungeon Master: ${asyncSnapshot.data ?? 'Loading...'}",
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: Colors.deepPurple,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Upcoming Sessions:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              widget.campaign.sessions.isEmpty
                  ? const Text(
                      'No upcoming sessions scheduled.',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    )
                  : Column(
                      children: widget.campaign.sessions.map((session) {
                        final sessionObj = Session.fromJson(session);
                        return SessionCard(session: sessionObj);
                      }).toList(),
                    ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(
                    Icons.supervisor_account_outlined,
                    size: 18,
                    color: Colors.deepPurple,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Party Members:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              StreamBuilder(
                stream: widget.players,
                builder: (context, playersSnapshot) {
                  if (playersSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (playersSnapshot.hasError) {
                    return const Center(child: Text("Error loading players"));
                  }

                  final playersDocs = playersSnapshot.data?.docs ?? [];

                  if (playersDocs.isEmpty) {
                    return const Center(child: Text("No players yet"));
                  }

                  return Expanded(
                    child: ListView.builder(
                      itemCount: playersDocs.length,
                      itemBuilder: (context, index) {
                        final playerData = playersDocs[index].data();
                        final Character character =
                            Character.fromJson(playerData);

                        return Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: character.imageUrl.isEmpty == false
                                  ? Image.network(
                                      character.imageUrl,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: 100,
                                      height: 100,
                                      color: Colors.grey,
                                      child: const Icon(
                                        Icons.person,
                                        size: 50,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 8),
                            Text(character.name),
                            const SizedBox(height: 4),
                            Text("${character.race} ${character.role}"),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          );
        });
  }
}
