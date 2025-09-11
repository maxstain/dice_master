import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dice_master/models/character.dart';

class Campaign {
  final String id;
  final String title;
  final String hostId;
  final List<Character> players;
  final List<Map<String, dynamic>> sessions;
  final String sessionCode;
  final Object notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Campaign({
    required this.id,
    required this.title,
    required this.hostId,
    this.players = const [],
    this.sessions = const [],
    required this.sessionCode,
    required this.notes,
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
              ?.map((playerJson) =>
                  Character.fromJson(playerJson as Map<String, dynamic>))
              .toList() ??
          [],
      // Handle null or empty list
      sessions: (json['sessions'] as List<dynamic>?)
              ?.map((session) => session as Map<String, dynamic>)
              .toList() ??
          [],
      // Handle null or empty list
      sessionCode: json['sessionCode'] as String? ?? 'NO_CODE',
      notes: json['notes'] ?? {},
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
      'sessions': sessions,
      'sessionCode': sessionCode,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      // Convert DateTime back to Timestamp for Firestore
      'updatedAt': Timestamp.fromDate(updatedAt),
      // Convert DateTime back to Timestamp
    };
  }

  @override
  String toString() {
    return 'Campaign(id: $id, title: $title, hostId: $hostId, players: $players, sessions: $sessions, sessionCode: $sessionCode, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  static Campaign empty() {
    // Use sentinel values to represent an empty/non-existent campaign
    return Campaign(
      id: 'DEFAULT_ID',
      title: 'Untitled Campaign',
      hostId: 'DEFAULT_HOST_ID',
      players: [],
      sessions: [],
      sessionCode: 'NO_CODE',
      notes: {},
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  bool isEmpty() {
    // Checking only the sentinel id is sufficient and reliable
    return id == 'DEFAULT_ID';
  }
}
