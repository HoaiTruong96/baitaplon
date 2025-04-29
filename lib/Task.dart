class Task {
  int? id;
  String title;
  String? description;
  DateTime? dueDateTime;
  bool isCompleted;  // Trường này giúp theo dõi trạng thái hoàn thành

  Task({
    this.id,
    required this.title,
    this.description,
    this.dueDateTime,
    this.isCompleted = false,  // Mặc định là chưa hoàn thành
  });

  // Cập nhật phương thức toMap() để lưu trạng thái vào cơ sở dữ liệu
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'due_date_time': dueDateTime?.toIso8601String(),
      'is_completed': isCompleted ? 1 : 0,  // Lưu trạng thái isCompleted vào cơ sở dữ liệu
    };
  }

  // Phương thức từ cơ sở dữ liệu để tạo Task
  static Task fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      dueDateTime: DateTime.tryParse(map['due_date_time']),
      isCompleted: map['is_completed'] == 1,  // Đọc trạng thái hoàn thành từ cơ sở dữ liệu
    );
  }
}
