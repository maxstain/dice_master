import 'package:dice_master/models/item/itemRepo.dart';

class Item extends ItemRepo {
  final double weight;
  final int quantity;
  final ItemCategory category; // e.g., "Potion", "Misc", "Ammo", etc.
  final Map<String, dynamic>
      properties; // e.g., {"damage": "1d6", "range": "30/120"}

  Item({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required this.weight,
    required this.quantity,
    required this.category,
    required this.properties,
  });

  factory Item.fromMap(Map<String, dynamic> data, String documentId) {
    return Item(
      id: documentId,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      weight: (data['weight'] ?? 0).toDouble(),
      quantity: data['quantity'] ?? 1,
      price: (data['price'] ?? 0).toDouble(),
      category: data['category'] ?? 'Misc',
      properties: Map<String, dynamic>.from(data['properties'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'weight': weight,
      'quantity': quantity,
      'price': price,
      'category': category,
      'properties': properties,
    };
  }

  @override
  String toString() {
    return 'Item{id: $id, name: $name, description: $description, weight: $weight, quantity: $quantity, price: $price, category: $category, properties: $properties}';
  }
}
