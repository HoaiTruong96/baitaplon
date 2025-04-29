class Task {
  int? id;
  String title;
  DateTime? dueDateTime;

  Task({this.id, required this.title, this.dueDateTime});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'dueDateTime': dueDateTime?.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      dueDateTime: map['dueDateTime'] != null ? DateTime.parse(map['dueDateTime']) : null,
    );
  }
}
