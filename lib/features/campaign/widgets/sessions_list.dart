import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/campaign.dart';
import '../../../models/character.dart';
import '../bloc/campaign_bloc.dart';
import '../bloc/campaign_event.dart';

class SessionsList extends StatelessWidget {
  final Campaign campaign;
  final bool isDungeonMaster;
  final List<Character> players;

  const SessionsList({
    super.key,
    required this.campaign,
    required this.isDungeonMaster,
    required this.players,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('campaigns')
          .doc(campaign.id)
          .collection('sessions')
          .orderBy('date')
          .snapshots(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text("No sessions yet");
        }

        final sessions = snapshot.data!.docs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "All Sessions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...sessions.map((doc) {
              final session = doc.data() as Map<String, dynamic>;
              final sessionId = doc.id;
              final title = session["title"] ?? "Untitled Session";
              final description = session["description"] ?? "";
              final date = session["date"] ?? "";
              final isExpired = DateTime.parse(date).isBefore(DateTime.now());

              return !isExpired
                  ? Card(
                      color: const Color(0xFF1E1E2C),
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                if (isDungeonMaster) ...[
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.grey),
                                    onPressed: () {
                                      _showEditSessionDialog(
                                        context,
                                        campaign.id,
                                        sessionId,
                                        session,
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.redAccent),
                                    onPressed: () {
                                      context.read<CampaignBloc>().add(
                                            DeleteSessionRequested(
                                                campaign.id, sessionId),
                                          );
                                    },
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              description,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 14),
                            ),
                            if (date.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  date,
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ),
                          ],
                        ),
                      ),
                    )
                  : Card(
                      color: const Color(0xFF3A3A3E),
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.centerRight,
                                    child: const Text(
                                      "Expired",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ),
                                if (isDungeonMaster) ...[
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.grey),
                                    onPressed: () {
                                      _showEditSessionDialog(
                                        context,
                                        campaign.id,
                                        sessionId,
                                        session,
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.redAccent),
                                    onPressed: () {
                                      context.read<CampaignBloc>().add(
                                            DeleteSessionRequested(
                                                campaign.id, sessionId),
                                          );
                                    },
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              description,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 14),
                            ),
                            if (date.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  date,
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
            }),
          ],
        );
      },
    );
  }

  void _showEditSessionDialog(
    BuildContext context,
    String campaignId,
    String sessionId,
    Map<String, dynamic> session,
  ) {
    final titleController = TextEditingController(text: session["title"]);
    final descriptionController =
        TextEditingController(text: session["description"]);
    final dateController = TextEditingController(text: session["date"]);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Session"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Title")),
            TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: "Description")),
            TextField(
                controller: dateController,
                decoration: const InputDecoration(labelText: "Date")),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              context.read<CampaignBloc>().add(
                    UpdateSessionRequested(campaignId, sessionId, {
                      "title": titleController.text.trim(),
                      "description": descriptionController.text.trim(),
                      "date": dateController.text.trim(),
                    }),
                  );
              Navigator.pop(ctx);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
