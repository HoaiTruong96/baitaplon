import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'Task.dart';
import 'addtask_page.dart';
import 'database_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Task> tasks = [];
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _initializeNotification();
    _loadTasks();
  }

  void _initializeNotification() async {
    tz.initializeTimeZones();
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  Future<void> _loadTasks() async {
    final loadedTasks = await TaskDatabase().getTasks();
    setState(() {
      tasks = loadedTasks;
    });
    for (var task in tasks) {
      if (task.dueDateTime != null && !task.isCompleted) {
        _scheduleNotification(task);
      }
    }
  }

  Future<void> _scheduleNotification(Task task) async {
    if (task.dueDateTime == null || task.isCompleted) return;
    final scheduledDateTime = task.dueDateTime!.subtract(const Duration(minutes: 5));
    if (scheduledDateTime.isBefore(DateTime.now())) return;
    final tzScheduledDateTime = tz.TZDateTime.from(scheduledDateTime, tz.local);
    const androidDetails = AndroidNotificationDetails(
      'task_channel_id',
      'Task Notifications',
      channelDescription: 'Thông báo nhắc nhở công việc',
      importance: Importance.max,
      priority: Priority.high,
    );
    const platformDetails = NotificationDetails(android: androidDetails);
    await flutterLocalNotificationsPlugin.zonedSchedule(
      task.id!,
      'Sắp tới hạn!',
      'Công việc: ${task.title}',
      tzScheduledDateTime,
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  void _editTask(Task task) async {
    final updatedTask = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTaskPage(existingTask: task),
      ),
    );
    if (updatedTask != null) {
      await TaskDatabase().updateTask(updatedTask);
      setState(() {
        tasks[tasks.indexWhere((t) => t.id == task.id)] = updatedTask;
      });
      if (updatedTask.dueDateTime != null && !updatedTask.isCompleted) {
        _scheduleNotification(updatedTask);
      }
    }
  }

  void _deleteTask(int index) async {
    final task = tasks[index];
    if (task.id != null) {
      await TaskDatabase().deleteTask(task.id!);
      await flutterLocalNotificationsPlugin.cancel(task.id!);
    }
    setState(() {
      tasks.removeAt(index);
    });
  }

  void _showTaskDetails(Task task) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(task.title),
          content: Text(task.description ?? 'Không có mô tả'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  void _updateTaskStatus(Task task, bool isCompleted) async {
    final updatedTask = Task(
      id: task.id,
      title: task.title,
      description: task.description,
      dueDateTime: task.dueDateTime,
      isCompleted: isCompleted,
    );
    await TaskDatabase().updateTask(updatedTask);
    setState(() {
      task.isCompleted = isCompleted;
    });
    if (isCompleted) {
      await flutterLocalNotificationsPlugin.cancel(task.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
        backgroundColor: Colors.blueAccent,
      ),
      body: tasks.isEmpty
          ? const Center(
        child: Text(
          'Chưa có việc cần làm',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            elevation: 4,
            color: task.isCompleted ? Colors.grey[300] : Colors.lightBlue[50],
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              title: Text(
                task.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
              subtitle: task.dueDateTime != null
                  ? Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Due: ${task.dueDateTime!.toLocal()}'.split('.')[0],
                  style: const TextStyle(color: Colors.blueGrey),
                ),
              )
                  : null,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.info, color: Colors.blue),
                    onPressed: () => _showTaskDetails(task),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Chi tiết',
                  ),
                  Checkbox(
                    value: task.isCompleted,
                    onChanged: (bool? value) {
                      _updateTaskStatus(task, value ?? false);
                    },
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: () => _editTask(task),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Chỉnh sửa',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteTask(index),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Xóa',
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTask = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTaskPage()),
          );
          if (newTask != null) {
            await TaskDatabase().insertTask(newTask);
            setState(() {
              tasks.add(newTask);
            });
            if (newTask.dueDateTime != null && !newTask.isCompleted) {
              _scheduleNotification(newTask);
            }
          }
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
        tooltip: 'Thêm công việc mới',
      ),
    );
  }
}
