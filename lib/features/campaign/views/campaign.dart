import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dice_master/core/widgets/custom_dialogs.dart';
import 'package:dice_master/models/note.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/campaign.dart';
import '../../../models/character.dart';
import '../bloc/campaign_bloc.dart';
import '../bloc/campaign_event.dart';

class CampaignView extends StatelessWidget {
  final Campaign campaign;
  final List<Character> players;
  final List<Map<String, dynamic>> notes;
  final bool isDm;

  const CampaignView({
    super.key,
    required this.campaign,
    required this.players,
    required this.notes,
    required this.isDm,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(campaign.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text("Campaign Notes and Details",
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            Row(
              children: [
                Text("Campaign Notes",
                    style: Theme.of(context).textTheme.bodyMedium),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.purple),
                  onPressed: () => _showAddNoteDialog(context, campaign.id),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('campaigns')
                    .doc(campaign.id)
                    .collection('notes')
                    .orderBy('date', descending: true)
                    .snapshots(),
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text("No notes yet");
                  }
                  final notes = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: notes.length,
                    itemBuilder: (ctx, index) {
                      final note = Note.fromJson(
                          notes[index].data() as Map<String, dynamic>);
                      final noteId = notes[index].id;
                      return Card(
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
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      note.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  if (isDm) ...[
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.grey),
                                      onPressed: () {
                                        _showEditNoteDialog(
                                          context,
                                          campaign.id,
                                          noteId,
                                          note.title,
                                          note.content,
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.redAccent),
                                      onPressed: () {
                                        context.read<CampaignBloc>().add(
                                              DeleteNoteRequested(
                                                  campaign.id, noteId),
                                            );
                                      },
                                    ),
                                  ],
                                ],
                              ),
                              Text(
                                note.content,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                note.date
                                    .split('T')
                                    .first
                                    .split('-')
                                    .reversed
                                    .join('/'),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddNoteDialog(BuildContext context, String campaignId) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => CustomDialog(
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text.trim();
              final content = contentController.text.trim();
              if (title.isNotEmpty && content.isNotEmpty) {
                final newNote = {
                  "title": title,
                  "content": content,
                  "date": DateTime.now().toString().split(" ").first,
                };
                context
                    .read<CampaignBloc>()
                    .add(AddNoteRequested(campaignId, newNote));
                Navigator.pop(ctx);
              }
            },
            child: const Text("Add"),
          ),
        ],
        title: "Add Note",
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(labelText: "Content"),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  void _showEditNoteDialog(BuildContext context, String campaignId,
      String noteId, String title, String content) {
    final titleController = TextEditingController(text: title);
    final contentController = TextEditingController(text: content);

    showDialog(
      context: context,
      builder: (ctx) => CustomDialog(
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final updatedTitle = titleController.text.trim();
              final updatedContent = contentController.text.trim();
              if (updatedTitle.isNotEmpty && updatedContent.isNotEmpty) {
                final updatedNote = {
                  "title": updatedTitle,
                  "content": updatedContent,
                  "date": DateTime.now().toString().split(" ").first,
                };
                context
                    .read<CampaignBloc>()
                    .add(UpdateNoteRequested(campaignId, noteId, updatedNote));
                Navigator.pop(ctx);
              }
            },
            child: const Text("Update"),
          ),
        ],
        title: "Edit Note",
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(labelText: "Content"),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}
