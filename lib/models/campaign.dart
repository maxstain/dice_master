import 'package:cloud_firestore/cloud_firestore.dart';

import 'character.dart';

class Campaign {
  final String id;
  final String title;
  final String hostId;
  final List<Character> players; // always empty unless populated manually
  final List<Map<String, dynamic>>
      sessions; // always empty unless populated manually
  final String sessionCode;
  final Map<String, dynamic> notes;
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

  /// Safe deserialization that ignores legacy array fields
  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: json['id'] as String? ?? 'DEFAULT_ID',
      title: json['title'] as String? ?? 'Untitled Campaign',
      hostId: json['hostId'] as String? ?? 'DEFAULT_HOST_ID',
      // Ignore root-level players array → always empty here
      players: const [],
      // Ignore root-level sessions array → always empty here
      sessions: const [],
      sessionCode: json['sessionCode'] as String? ?? 'NO_CODE',
      notes: Map<String, dynamic>.from(json['notes'] ?? {}),
      createdAt: (json['createdAt'] is Timestamp)
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: (json['updatedAt'] is Timestamp)
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'hostId': hostId,
      'sessionCode': sessionCode,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      // ⚠️ players/sessions are excluded → use subcollections
    };
  }

  @override
  String toString() {
    return 'Campaign(id: $id, title: $title, hostId: $hostId, sessionCode: $sessionCode, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  static Campaign empty() {
    return Campaign(
      id: 'DEFAULT_ID',
      title: 'Untitled Campaign',
      hostId: 'DEFAULT_HOST_ID',
      sessionCode: 'NO_CODE',
      notes: {},
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  bool isEmpty() {
    return id == 'DEFAULT_ID' && title == 'Untitled Campaign';
  }

  static Map<String, dynamic> newCampaign(
    String title,
    String hostId,
    String sessionCode,
  ) {
    return {
      'title': title,
      'hostId': hostId,
      'sessionCode': sessionCode,
      'notes': {},
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
