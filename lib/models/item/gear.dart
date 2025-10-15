import 'package:dice_master/models/item/itemRepo.dart';

class Gear extends ItemRepo {
  final double weight;
  final int quantity;
  final ItemCategory category; // e.g., "Weapon", "Armor", "Potion", etc.
  final Map<String, dynamic>
      properties; // e.g., {"damage": "1d6", "range": "30/120"}

  Gear({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required this.weight,
    required this.quantity,
    required this.category,
    required this.properties,
  });

  factory Gear.fromMap(Map<String, dynamic> data, String documentId) {
    return Gear(
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
      'category': category.toString(),
      'properties': properties,
    };
  }

  @override
  String toString() {
    return 'Gear{id: $id, name: $name, description: $description, weight: $weight, quantity: $quantity, price: $price, category: $category, properties: $properties}';
  }
}
