class Task {
  int? id;
  String title;
  String? description;  // Thêm mô tả công việc
  DateTime? dueDateTime;

  Task({this.id, required this.title, this.description, this.dueDateTime});

  // Cập nhật phương thức toMap để lưu trữ mô tả
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,  // Lưu mô tả vào DB
      'dueDateTime': dueDateTime?.toIso8601String(),
    };
  }

  // Cập nhật phương thức fromMap để lấy mô tả từ DB
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],  // Lấy mô tả từ DB
      dueDateTime: map['dueDateTime'] != null ? DateTime.parse(map['dueDateTime']) : null,
    );
  }
}
