enum ItemCategory {
  books,
  gemstones,
  ammunition,
  firearms,
  swords,
  daggers,
  armor,
  potions,
  food,
  clothing,
  tools,
  craftingMaterials,
}

class ItemRepo {
  final String id;
  final String name;
  final String description;
  final double price;

  ItemRepo({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
  });

  factory ItemRepo.fromJson(Map<String, dynamic> json) {
    return ItemRepo(
      id: json['id'] as String? ?? 'DEFAULT_ID',
      name: json['name'] as String? ?? 'Unnamed Item',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
    };
  }
}
