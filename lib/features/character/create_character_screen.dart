import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/character.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_state.dart';

class CreateCharacterScreen extends StatefulWidget {
  final String campaignId;
  final String userId;

  const CreateCharacterScreen({
    super.key,
    required this.campaignId,
    required this.userId,
  });

  @override
  State<CreateCharacterScreen> createState() => _CreateCharacterScreenState();
}

class _CreateCharacterScreenState extends State<CreateCharacterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _role = "adventurer";
  String _race = "human";
  int _level = 1;
  int _hp = 10;
  int _maxHp = 30;

  Future<void> _saveCharacter() async {
    if (_formKey.currentState?.validate() ?? false) {
      final newCharacter = Character(
        id: widget.userId,
        name: _nameController.text.trim(),
        role: _role,
        race: _race,
        level: _level,
        hp: _hp,
        maxHp: _maxHp,
        xp: 0.0,
        items: [],
        imageUrl: "",
      );

      await FirebaseFirestore.instance
          .collection('campaigns')
          .doc(widget.campaignId)
          .collection('players')
          .doc(widget.userId)
          .set(newCharacter.toJson());

      if (mounted) {
        Navigator.pop(context, newCharacter);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return const Scaffold(
        body: Center(child: Text("You must be signed in.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Create Your Character")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Character Name"),
                validator: (value) =>
                    (value == null || value.isEmpty) ? "Enter a name" : null,
              ),
              DropdownButtonFormField<String>(
                value: _role,
                decoration: const InputDecoration(labelText: "Role"),
                items: const [
                  DropdownMenuItem(
                      value: "adventurer", child: Text("Adventurer")),
                  DropdownMenuItem(value: "warrior", child: Text("Warrior")),
                  DropdownMenuItem(value: "mage", child: Text("Mage")),
                  DropdownMenuItem(value: "rogue", child: Text("Rogue")),
                ],
                onChanged: (val) => setState(() => _role = val ?? "adventurer"),
              ),
              DropdownButtonFormField<String>(
                value: _race,
                decoration: const InputDecoration(labelText: "Race"),
                items: const [
                  DropdownMenuItem(value: "human", child: Text("Human")),
                  DropdownMenuItem(value: "elf", child: Text("Elf")),
                  DropdownMenuItem(value: "dwarf", child: Text("Dwarf")),
                  DropdownMenuItem(value: "orc", child: Text("Orc")),
                ],
                onChanged: (val) => setState(() => _race = val ?? "human"),
              ),
              const SizedBox(height: 16),
              Text("Level: $_level"),
              Slider(
                min: 1,
                max: 20,
                value: _level.toDouble(),
                divisions: 19,
                label: "$_level",
                onChanged: (val) => setState(() => _level = val.toInt()),
              ),
              Text("HP: $_hp / $_maxHp"),
              Slider(
                min: 1,
                max: 100,
                value: _hp.toDouble(),
                divisions: 99,
                label: "$_hp",
                onChanged: (val) {
                  setState(() {
                    _hp = val.toInt();
                    if (_hp > _maxHp) _maxHp = _hp;
                  });
                },
              ),
              Slider(
                min: 10,
                max: 100,
                value: _maxHp.toDouble(),
                divisions: 90,
                label: "$_maxHp",
                onChanged: (val) => setState(() => _maxHp = val.toInt()),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _saveCharacter,
                icon: const Icon(Icons.save),
                label: const Text("Save Character"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
