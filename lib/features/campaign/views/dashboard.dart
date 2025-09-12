import 'package:flutter/material.dart';

import '../../../models/campaign.dart';
import '../../../models/character.dart';

class DashboardView extends StatelessWidget {
  final Campaign campaign;
  final List<Character> players;
  final bool isDm;

  const DashboardView({
    super.key,
    required this.campaign,
    required this.players,
    required this.isDm,
  });

  @override
  Widget build(BuildContext context) {
    final upcomingSessions = campaign.sessions;

    return Scaffold(
      appBar: AppBar(
        title: Text(campaign.title),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Dungeon Master: ${campaign.hostId}",
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 24),

            // Upcoming Sessions
            const Text("Upcoming Sessions",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            if (upcomingSessions.isEmpty)
              const Text("No upcoming sessions yet")
            else
              Column(
                children: upcomingSessions.map((s) {
                  final title = s['title'] ?? 'Unnamed Session';
                  final desc = s['description'] ?? '';
                  final date = s['date'] ?? '';
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(title),
                      subtitle: Text(desc),
                      trailing: Text(date,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple)),
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 24),

            // Party Members
            const Text("Party Members",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                    onPressed: () {
                      // Navigate to Notes tab
                      DefaultTabController.of(context)?.animateTo(2);
                    },
                    icon: const Icon(Icons.book),
                    label: const Text("Campaign Notes"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to Combat tab
                      DefaultTabController.of(context)?.animateTo(2);
                    },
                    icon: const Icon(Icons.sports_martial_arts),
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
