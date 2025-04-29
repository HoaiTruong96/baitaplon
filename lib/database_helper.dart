import 'package:supabase_flutter/supabase_flutter.dart';
import 'Task.dart';

class TaskDatabase {
  final supabase = Supabase.instance.client;

  // Thêm task vào bảng Supabase
  Future<int?> insertTask(Task task) async {
    try {
      final response = await supabase.from('tasks').insert({
        'title': task.title,
        'description': task.description,
        'due_date_time': task.dueDateTime?.toIso8601String(),
        'is_completed': task.isCompleted,  // Thêm trạng thái is_completed
      }).select('id').single();

      print("Response: $response");  // Debug log

      if (response == null) {
        print("Không thể thêm task mới.");
        return null;
      }
      return response['id'] as int?;
    } catch (e) {
      print("Error while inserting task: $e");
      return null;
    }
  }

  // Lấy danh sách task từ Supabase
  Future<List<Task>> getTasks() async {
    try {
      final response = await supabase.from('tasks').select().order('id');

      print("Tasks loaded: $response");  // Debug log

      return (response as List).map((data) {
        return Task(
          id: data['id'],
          title: data['title'],
          description: data['description'],
          dueDateTime: data['due_date_time'] != null
              ? DateTime.parse(data['due_date_time'])
              : null,
          isCompleted: data['is_completed'] ?? false,  // Lấy trạng thái hoàn thành từ cơ sở dữ liệu
        );
      }).toList();
    } catch (e) {
      print("Error while fetching tasks: $e");
      return [];
    }
  }

  // Xóa task theo ID
  Future<void> deleteTask(int id) async {
    try {
      await supabase.from('tasks').delete().eq('id', id);
      print("Task with id $id deleted.");
    } catch (e) {
      print("Error while deleting task: $e");
    }
  }

  // Cập nhật task
  Future<void> updateTask(Task task) async {
    try {
      final response = await supabase.from('tasks').update({
        'title': task.title,
        'description': task.description,
        'due_date_time': task.dueDateTime?.toIso8601String(),
        'is_completed': task.isCompleted,  // Cập nhật trạng thái hoàn thành
      }).eq('id', task.id as Object);
      print("Task updated: $response");
    } catch (e) {
      print("Error while updating task: $e");
    }
  }
}
