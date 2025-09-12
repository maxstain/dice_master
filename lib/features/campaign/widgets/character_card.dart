import 'package:dice_master/models/character.dart';
import 'package:flutter/material.dart';

class CharacterCard extends StatefulWidget {
  final Character character;

  const CharacterCard({super.key, required this.character});

  @override
  State<CharacterCard> createState() => _CharacterCardState();
}

class _CharacterCardState extends State<CharacterCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6.0,
            offset: const Offset(0, 4),
          ),
        ],
        color: Colors.blueGrey.shade800,
      ),
      margin: const EdgeInsets.symmetric(
          vertical: 8.0, horizontal: 10.0), // Adjusted margin
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Consistent padding
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(100.0),
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2.0),
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                    child: widget.character.imageUrl.isNotEmpty
                        ? Image.network(
                            widget.character.imageUrl,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                          )
                        : const Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.white70,
                          ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.character.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        "Level ${widget.character.level} ${widget.character.race} ${widget.character.role}",
                        style: const TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(
                  value: widget.character.hp / widget.character.maxHp,
                  backgroundColor: Colors.grey.shade700,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                  minHeight: 8.0,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "HP",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      "${widget.character.hp} / ${widget.character.maxHp}",
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
