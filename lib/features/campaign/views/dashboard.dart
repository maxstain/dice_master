import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dice_master/features/campaign/widgets/session_card.dart';
import 'package:dice_master/models/session.dart';
import 'package:flutter/material.dart';

import '../../../models/campaign.dart';
import '../../../models/character.dart';

class DashboardView extends StatelessWidget {
  final Campaign campaign;
  final List<Character> players;
  final bool isDm;

  /// Callback to tell CampaignScreen to change bottom nav index
  final void Function(int) onNavigate;

  const DashboardView({
    super.key,
    required this.campaign,
    required this.players,
    required this.isDm,
    required this.onNavigate,
  });

  Future<String> _getHostName(String uid) async {
    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data['username'] ?? uid;
      }
    } catch (e) {
      debugPrint("Failed to fetch username for $uid: $e");
    }
    return uid;
  }

  @override
  Widget build(BuildContext context) {
    final upcomingSessions = campaign.sessions;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dungeon Master name (username lookup)
            FutureBuilder<String>(
              future: _getHostName(campaign.hostId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text("Dungeon Master: Loading...");
                }
                final hostName = snapshot.data ?? campaign.hostId;
                return Text(
                  "Dungeon Master: $hostName",
                  style: Theme.of(context).textTheme.titleSmall,
                );
              },
            ),
            const SizedBox(height: 24),

            // Upcoming Sessions
            const Row(
              children: [
                Icon(Icons.calendar_month_outlined, color: Colors.deepPurple),
                SizedBox(width: 8),
                Text(
                  "Upcoming Sessions",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (upcomingSessions.isEmpty)
              const Text("No upcoming sessions yet")
            else
              Column(
                children: upcomingSessions.map((s) {
                  final session = Session.fromJson(s);
                  return SessionCard(session: session);
                }).toList(),
              ),

            const SizedBox(height: 24),

            // Party Members
            const Row(
              children: [
                Icon(Icons.group, color: Colors.deepPurple),
                SizedBox(width: 8),
                Text(
                  "Party Members",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (players.isEmpty)
              const Text("No players yet")
            else
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: players.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (ctx, i) {
                    final p = players[i];
                    return Column(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundImage: p.imageUrl.isNotEmpty
                              ? NetworkImage(p.imageUrl)
                              : null,
                          child: p.imageUrl.isEmpty ? Text(p.name[0]) : null,
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: 80,
                          child: Text(
                            p.name,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text("${p.race} ${p.role}",
                            style: const TextStyle(fontSize: 10)),
                      ],
                    );
                  },
                ),
              ),

            const SizedBox(height: 24),

            // Quick Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => onNavigate(2), // 👈 go to Notes
                    icon: const Icon(Icons.book),
                    label: const Text("Campaign Notes"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => onNavigate(2), // 👈 go to Combat
                    icon: const Icon(Icons.sports_kabaddi),
                    label: const Text("Initiative Tracker"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
