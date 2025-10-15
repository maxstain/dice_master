import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/campaign_bloc.dart';

class NotesEditor extends StatelessWidget {
  final String campaignId;
  final bool isDm;

  const NotesEditor({
    super.key,
    required this.campaignId,
    required this.isDm,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CampaignBloc, CampaignState>(
      builder: (context, state) {
        if (state is CampaignLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is CampaignLoaded) {
          final notes = state.notes;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    "Campaign Notes",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (isDm)
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.purple),
                      onPressed: () => _showAddNoteDialog(context, campaignId),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (notes.isEmpty)
                const Text("No notes available")
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: notes.length,
                  itemBuilder: (ctx, i) {
                    final note = notes[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(note["title"] ?? "Untitled"),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(note["content"] ?? ""),
                            if (note["date"] != null)
                              Text(
                                note["date"],
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                          ],
                        ),
                        trailing: isDm
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _showEditNoteDialog(
                                      context,
                                      campaignId,
                                      note["id"],
                                      note["title"] ?? "",
                                      note["content"] ?? "",
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      context.read<CampaignBloc>().add(
                                          DeleteNoteRequested(
                                              campaignId, note["id"]));
                                    },
                                  ),
                                ],
                              )
                            : null,
                      ),
                    );
                  },
                ),
            ],
          );
        }
        return const Text("Error loading notes");
      },
    );
  }

  void _showAddNoteDialog(BuildContext context, String campaignId) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add Note"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(labelText: "Content"),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final newNote = {
                "title": titleController.text.trim(),
                "content": contentController.text.trim(),
                "date": DateTime.now().toString().split(" ").first,
              };
              context
                  .read<CampaignBloc>()
                  .add(AddNoteRequested(campaignId, newNote));
              Navigator.pop(ctx);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _showEditNoteDialog(BuildContext context, String campaignId,
      String noteId, String title, String content) {
    final titleController = TextEditingController(text: title);
    final contentController = TextEditingController(text: content);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Note"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(labelText: "Content"),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final updatedNote = {
                "title": titleController.text.trim(),
                "content": contentController.text.trim(),
                "date": DateTime.now().toString().split(" ").first,
              };
              context
                  .read<CampaignBloc>()
                  .add(UpdateNoteRequested(campaignId, noteId, updatedNote));
              Navigator.pop(ctx);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
