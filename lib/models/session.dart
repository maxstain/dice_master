import 'package:cloud_firestore/cloud_firestore.dart';

class Session {
  final String title;
  final String description;
  final DateTime dateTime;

  Session({
    required this.title,
    required this.description,
    required this.dateTime,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
        title: json['title'] as String? ?? 'Untitled Session',
        description: json['description'] as String? ?? '',
        dateTime: (json['dateTime'] as Timestamp?)?.toDate() ?? DateTime.now());
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
    };
  }
}
