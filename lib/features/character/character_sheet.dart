import 'package:dice_master/features/campaign/bloc/campaign_bloc.dart';
import 'package:dice_master/models/character.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CharacterSheet extends StatefulWidget {
  final Character character;

  const CharacterSheet({super.key, required this.character});

  @override
  State<CharacterSheet> createState() => _CharacterViewState();
}

class _CharacterViewState extends State<CharacterSheet> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Character Sheet"),
        centerTitle: true,
      ),
      body: BlocBuilder<CampaignBloc, CampaignState>(
        builder: (context, state) {
          if (state is CampaignLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CampaignFailure) {
            return Center(child: Text(state.message));
          }
          if (state is CampaignLoaded) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Name: ${widget.character.name}",
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Class: ${widget.character.role}",
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Level: ${widget.character.level}",
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Race: ${widget.character.race}",
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  ExpansionTile(
                    title: const Text("Items"),
                    children: widget.character.items.isNotEmpty
                        ? widget.character.items
                            .map((item) => ListTile(
                                  title: Text(item.name),
                                  subtitle: Text(item.description),
                                ))
                            .toList()
                        : [const ListTile(title: Text("No items"))],
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text("Unexpected state"));
        },
      ),
    );
  }
}
