// This is the character model for a D&D app.
import 'package:dice_master/models/item/itemRepo.dart';

class Character {
  final String id;
  final String name;
  final String role;
  final String race;
  final int level;
  final int hp;
  final int maxHp;
  final double xp;
  final List<ItemRepo> items = [];
  final String imageUrl;
  final String background = "";
  final String subRole = "";
  final List<String> personalityTraits = [];

  Character({
    required this.id,
    required this.name,
    required this.role,
    required this.race,
    required this.level,
    required this.hp,
    required this.maxHp,
    this.xp = 0.0,
    required this.imageUrl,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    final char = Character(
      id: json['id'] as String? ?? 'DEFAULT_ID',
      name: json['name'] as String? ?? 'Unnamed Hero',
      role: json['role'] as String? ?? 'adventurer',
      race: json['race'] as String? ?? 'human',
      level: json['level'] as int? ?? 1,
      hp: json['hp'] as int? ?? 10,
      maxHp: json['maxHp'] as int? ?? 30,
      xp: (json['xp'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] as String? ?? '',
    );
    if (json['items'] != null && json['items'] is List) {
      for (var itemJson in json['items']) {
        if (itemJson is Map<String, dynamic>) {
          char.items.add(ItemRepo.fromJson(itemJson));
        }
      }
    }
    return char;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'race': race,
      'level': level,
      'hp': hp,
      'maxHp': maxHp,
      'xp': xp,
      'items': items,
      'imageUrl': imageUrl,
    };
  }

  @override
  String toString() {
    return 'Character{id: $id, name: $name, role: $role race: $race, level: $level, hp: $hp/$maxHp, xp: $xp, items: $items, imageUrl: $imageUrl}';
  }
}
