import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dice_master/models/character.dart';

class Campaign {
  final String id;
  final String title;
  final String hostId;
  final List<Map<String, dynamic>> sessions;
  final String sessionCode;
  final Map<String, dynamic> notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Campaign({
    required this.id,
    required this.title,
    required this.hostId,
    this.sessions = const [],
    required this.sessionCode,
    required this.notes,
    required List<Character> players,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Campaign.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Campaign(
      id: doc.id,
      title: data['title'] as String? ?? 'Untitled Campaign',
      hostId: data['hostId'] as String? ?? 'DEFAULT_HOST_ID',
      sessions: (data['sessions'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .toList() ??
          [],
      sessionCode: data['sessionCode'] as String? ?? 'NO_CODE',
      notes: (data['notes'] is Map<String, dynamic>)
          ? Map<String, dynamic>.from(data['notes'])
          : {},
      players: [],
      // Players should be populated separately
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'hostId': hostId,
      'sessions': sessions,
      'sessionCode': sessionCode,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  static fromJson(Map<String, dynamic> map) {
    return Campaign(
      id: map['id'] as String,
      title: map['title'] as String? ?? 'Untitled Campaign',
      hostId: map['hostId'] as String? ?? 'DEFAULT_HOST_ID',
      sessions: (map['sessions'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .toList() ??
          [],
      sessionCode: map['sessionCode'] as String? ?? 'NO_CODE',
      notes: (map['notes'] is Map<String, dynamic>)
          ? Map<String, dynamic>.from(map['notes'])
          : {},
      players: [],
      // Players should be populated separately
      createdAt: (map['createdAt'] is Timestamp)
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: (map['updatedAt'] is Timestamp)
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
