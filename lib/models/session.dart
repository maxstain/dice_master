class Session {
  final String id;
  final String name;
  final String hostId;
  final List<String> players;
  final String sessionCode;
  final DateTime createdAt;
  final DateTime updatedAt;

  Session({
    required this.id,
    required this.name,
    required this.hostId,
    this.players = const [],
    required this.sessionCode,
    required this.createdAt,
    required this.updatedAt,
  });

  Session.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String,
        name = json['name'] as String,
        hostId = json['hostId'] as String,
        players = (json['players'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        sessionCode = json['sessionCode'] as String,
        createdAt = DateTime.parse(json['createdAt'] as String),
        updatedAt = DateTime.parse(json['updatedAt'] as String);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'hostId': hostId,
      'players': players,
      'sessionCode': sessionCode,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Session(id: $id, name: $name, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
