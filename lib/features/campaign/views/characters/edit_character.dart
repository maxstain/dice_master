import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dice_master/models/character.dart';
import 'package:flutter/material.dart';

class EditCharacterScreen extends StatefulWidget {
  final String? characterId;

  const EditCharacterScreen({super.key, this.characterId});

  @override
  State<EditCharacterScreen> createState() => _EditCharacterScreenState();
}

Future<Character> fetchCharacterById(String id) async {
  try {
    final character = await FirebaseFirestore.instance
        .collection('characters')
        .doc(id)
        .get()
        .then((doc) => Character.fromJson({...doc.data()!, 'id': doc.id}));
    return character;
  } catch (e) {
    throw Exception('Failed to load character: $e');
  }
}

class _EditCharacterScreenState extends State<EditCharacterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Character"),
      ),
      body: FutureBuilder(
        future: fetchCharacterById(widget.characterId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Character not found'));
          } else {
            final character = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFormField(
                    initialValue: character.name,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  TextFormField(
                    initialValue: character.role,
                    decoration: const InputDecoration(labelText: 'Role'),
                  ),
                  TextFormField(
                    initialValue: character.level.toString(),
                    decoration: const InputDecoration(labelText: 'Level'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Save logic here
                    },
                    child: const Text('Save Changes'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
