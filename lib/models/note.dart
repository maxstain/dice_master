class Note {
  final String title;
  final String content;
  final String date;

  Note({required this.title,
    required this.content,
    required this.date,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      title: json['title'] as String? ?? 'Untitled Note',
      content: json['content'] as String? ?? '',
      date: json['date'] as String? ?? '',
    );
  }
}