class Character {
  final String id;
  final String name;
  final String role;
  final int level;
  final int hp;
  final double xp;
  final List<Object> items;
  final String imageUrl;

  Character({
    required this.id,
    required this.name,
    required this.role,
    required this.level,
    required this.hp,
    this.xp = 0.0,
    this.items = const [],
    required this.imageUrl,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'] as String? ?? 'DEFAULT_ID',
      name: json['name'] as String? ?? 'Unnamed Hero',
      role: json['role'] as String? ?? 'adventurer',
      level: json['level'] as int? ?? 1,
      hp: json['hp'] as int? ?? 10,
      xp: (json['xp'] as num?)?.toDouble() ?? 0.0,
      items: (json['items'] as List<dynamic>?)?.cast<Object>() ?? [],
      imageUrl: json['imageUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'level': level,
      'hp': hp,
      'xp': xp,
      'items': items,
      'imageUrl': imageUrl,
    };
  }

  @override
  String toString() {
    return 'Character(id: $id, name: $name, role: $role, level: $level, hp: $hp, xp: $xp, items: $items, imageUrl: $imageUrl)';
  }
}
