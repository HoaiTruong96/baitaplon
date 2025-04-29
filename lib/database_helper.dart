import 'package:supabase_flutter/supabase_flutter.dart';
import 'Task.dart';

class TaskDatabase {
  final supabase = Supabase.instance.client;

  // Thêm task
  Future<int?> insertTask(Task task) async {
    final response = await supabase.from('tasks').insert({
      'title': task.title,
      'description': task.description,
      'dueDateTime': task.dueDateTime?.toIso8601String(),
    }).select('id').single();

    if (response == null) return null;
    return response['id'] as int?;
  }

  // Lấy danh sách task
  Future<List<Task>> getTasks() async {
    final response = await supabase.from('tasks').select().order('id');

    return (response as List).map((data) {
      return Task(
        id: data['id'],
        title: data['title'],
        description: data['description'],
        dueDateTime: data['dueDateTime'] != null
            ? DateTime.parse(data['dueDateTime'])
            : null,
      );
    }).toList();
  }

  // Xóa task
  Future<void> deleteTask(int id) async {
    await supabase.from('tasks').delete().eq('id', id);
  }
}
