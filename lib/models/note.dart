class Note {
  final String id;
  final String title;
  final String content;
  final String date;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
  });

  Note.empty()
      : id = 'DEFAULT_ID',
        title = 'Untitled Note',
        content = '',
        date = '';

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String? ?? 'DEFAULT_ID',
      title: json['title'] as String? ?? 'Untitled Note',
      content: json['content'] as String? ?? '',
      date: json['date'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'date': date,
    };
  }
}
