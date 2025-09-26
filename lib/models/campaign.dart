import 'package:cloud_firestore/cloud_firestore.dart';

import 'character.dart';

class Campaign {
  final String id;
  final String title;
  final String hostId;
  final List<Character> players;
  final List<Map<String, dynamic>> sessions;
  final String sessionCode;
  final DateTime createdAt;
  final DateTime updatedAt;

  Campaign({
    required this.id,
    required this.title,
    required this.hostId,
    this.players = const [],
    this.sessions = const [],
    required this.sessionCode,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: json['id'] as String,
      title: json['title'] as String,
      hostId: json['hostId'] as String,
      sessionCode: json['sessionCode'] as String,
      createdAt: (json['createdAt'] as Timestamp?)!.toDate(),
      updatedAt: (json['updatedAt'] as Timestamp?)!.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'hostId': hostId,
      'sessions': sessions,
      'sessionCode': sessionCode,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  @override
  String toString() {
    return 'Campaign(id: $id, title: $title, hostId: $hostId, players: ${players.length}, sessions: $sessions, sessionCode: $sessionCode, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  static Campaign empty() {
    return Campaign(
      id: 'DEFAULT_ID',
      title: 'Untitled Campaign',
      hostId: 'DEFAULT_HOST_ID',
      players: [],
      sessions: [],
      sessionCode: 'NO_CODE',
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  bool isEmpty() {
    return id == 'DEFAULT_ID' && title == 'Untitled Campaign';
  }

  static Map<String, dynamic> newCampaign(String title, String hostId,
      List<Map<String, dynamic>> sessions, String sessionCode) {
    return {
      'title': title,
      'hostId': hostId,
      'sessions': sessions,
      'sessionCode': sessionCode,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
