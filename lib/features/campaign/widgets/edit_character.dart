import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dice_master/features/campaign/bloc/campaign_bloc.dart';
import 'package:dice_master/features/campaign/bloc/campaign_event.dart';
import 'package:dice_master/features/campaign/bloc/campaign_state.dart';
import 'package:dice_master/models/character.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditCharacterScreen extends StatefulWidget {
  final String campaignId;
  final String characterId;

  const EditCharacterScreen({
    super.key,
    required this.characterId,
    required this.campaignId,
  });

  @override
  State<EditCharacterScreen> createState() => _EditCharacterScreenState();
}

Future<Character> fetchCharacterById(String playerId, String campaignId) async {
  try {
    final character = await FirebaseFirestore.instance
        .collection('campaigns')
        .doc(campaignId) // Replace with actual campaign ID
        .collection('players')
        .doc(playerId)
        .get()
        .then((doc) => Character.fromJson({...doc.data()!, 'id': doc.id}));
    return character;
  } catch (e) {
    throw Exception('Failed to load character: $e');
  }
}

class _EditCharacterScreenState extends State<EditCharacterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _levelController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  void _setControllers(Character character) {
    if (_nameController.text.isEmpty) {
      _nameController.text = character.name;
    }
    if (_roleController.text.isEmpty) {
      _roleController.text = character.role;
    }
    if (_levelController.text.isEmpty) {
      _levelController.text = character.level.toString();
    }
    if (_imageUrlController.text.isEmpty) {
      _imageUrlController.text = character.imageUrl;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Character"),
      ),
      body: BlocBuilder<CampaignBloc, CampaignState>(
        builder: (context, state) {
          return FutureBuilder(
            future: fetchCharacterById(widget.characterId, widget.campaignId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData) {
                return const Center(child: Text('Character not found'));
              } else {
                final character = snapshot.data!;
                _setControllers(character);
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(labelText: 'Name'),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _roleController,
                          decoration: const InputDecoration(labelText: 'Role'),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _levelController,
                          decoration: const InputDecoration(labelText: 'Level'),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              final updatedData = {
                                'name': _nameController.text.isEmpty
                                    ? character.name
                                    : _nameController.text,
                                'role': _roleController.text.isEmpty
                                    ? character.role
                                    : _roleController.text,
                                'level': _levelController.text.isEmpty
                                    ? character.level
                                    : int.tryParse(_levelController.text) ??
                                        character.level,
                                'imageUrl': _imageUrlController.text.isEmpty
                                    ? character.imageUrl
                                    : _imageUrlController.text,
                              };

                              context.read<CampaignBloc>().add(
                                    UpdateCharacterRequested(
                                      widget.campaignId,
                                      widget.characterId,
                                      updatedData,
                                    ),
                                  );

                              Navigator.of(context).pop();
                            }
                          },
                          child: const Text('Save Changes'),
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
