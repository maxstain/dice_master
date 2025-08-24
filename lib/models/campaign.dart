import 'package:cloud_firestore/cloud_firestore.dart';

class Campaign {
  // Retitled from Session if it was Session before
  final String id;
  final String title;
  final String hostId;
  final List<String> players;
  final String sessionCode;
  final DateTime createdAt;
  final DateTime updatedAt;

  Campaign({
    required this.id,
    required this.title,
    required this.hostId,
    this.players = const [],
    required this.sessionCode,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: json['id'] as String? ?? 'DEFAULT_ID',
      // Provide default or handle error
      title: json['title'] as String? ?? 'Untitled Campaign',
      // Provide default
      hostId: json['hostId'] as String? ?? 'DEFAULT_HOST_ID',
      // Provide default
      players: (json['players'] as List<dynamic>?)
              ?.map((e) =>
                  e as String? ??
                  'INVALID_PLAYER_ID') // Also make player ID parsing safer
              .toList() ??
          [],
      sessionCode: json['sessionCode'] as String? ?? 'NO_CODE',
      // Provide default
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      // Handle null Timestamp
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ??
          DateTime.now(), // Handle null Timestamp
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'hostId': hostId,
      'players': players,
      'sessionCode': sessionCode,
      'createdAt': Timestamp.fromDate(createdAt),
      // Convert DateTime back to Timestamp for Firestore
      'updatedAt': Timestamp.fromDate(updatedAt),
      // Convert DateTime back to Timestamp
    };
  }

  @override
  String toString() {
    return 'Campaign(id: $id, title: $title, hostId: $hostId, players: $players, sessionCode: $sessionCode, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
