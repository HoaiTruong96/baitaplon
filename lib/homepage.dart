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
      if (task.dueDateTime != null) {
        _scheduleNotification(task);
      }
    }
  }

  Future<void> _scheduleNotification(Task task) async {
    if (task.dueDateTime == null) return;
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

  void _addTask(Task task) async {
    final id = await TaskDatabase().insertTask(task);
    final newTask = Task(
      id: id,
      title: task.title,
      description: task.description,
      dueDateTime: task.dueDateTime,
    );
    setState(() {
      tasks.add(newTask);
    });
    _scheduleNotification(newTask);
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
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => _showTaskDetails(task),
                    child: const Text('Chi tiết'),
                  ),
                ],
              ),
              subtitle: task.dueDateTime != null
                  ? Text(
                'Due: ${task.dueDateTime!.toLocal()}'.split('.')[0],
                style: const TextStyle(color: Colors.blueGrey),
              )
                  : null,
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteTask(index),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final Task? newTask = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTaskPage()),
          );
          if (newTask != null) {
            _addTask(newTask);
          }
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}