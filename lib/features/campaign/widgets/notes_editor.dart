import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/campaign.dart';
import '../bloc/campaign_bloc.dart';
import '../bloc/campaign_event.dart';

class NotesEditor extends StatefulWidget {
  final Campaign campaign;

  const NotesEditor({super.key, required this.campaign});

  @override
  State<NotesEditor> createState() => _NotesEditorState();
}

class _NotesEditorState extends State<NotesEditor> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    // Flatten the Map<String, dynamic> into a simple text representation
    final initialNotes = widget.campaign.notes.entries
        .map((e) => "${e.key}: ${e.value}")
        .join("\n");

    _controller = TextEditingController(text: initialNotes);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _saveNotes() {
    final text = _controller.text.trim();

    // Convert text back into a Map<String, dynamic>
    final Map<String, dynamic> notesMap = {};
    for (final line in text.split("\n")) {
      if (line.contains(":")) {
        final parts = line.split(":");
        final key = parts.first.trim();
        final value = parts.sublist(1).join(":").trim();
        notesMap[key] = value;
      }
    }

    context
        .read<CampaignBloc>()
        .add(UpdateNotesRequested(widget.campaign.id, notesMap));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Notes updated")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Campaign Notes",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          maxLines: 6,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: "Enter notes as key: value per line",
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: _saveNotes,
            icon: const Icon(Icons.save),
            label: const Text("Save Notes"),
          ),
        )
      ],
    );
  }
}
