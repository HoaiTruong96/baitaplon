class Task {
  final int? id;
  final String title;
  final String? description;
  final DateTime? dueDateTime;

  Task({
    this.id,
    required this.title,
    this.description,
    this.dueDateTime,
  });

  // Tạo đối tượng Task từ JSON (map Supabase trả về)
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String?,
      dueDateTime: map['dueDateTime'] != null
          ? DateTime.parse(map['dueDateTime'])
          : null,
    );
  }

  // Chuyển đối tượng Task thành Map để gửi lên Supabase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDateTime': dueDateTime?.toIso8601String(),
    };
  }
}
