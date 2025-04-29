import 'package:flutter/material.dart';
import 'Task.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _dueDateTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm công việc mới'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Tiêu đề công việc'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Mô tả công việc'),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );

                if (pickedDate != null) {
                  final TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );

                  if (pickedTime != null) {
                    final combinedDateTime = DateTime(
                      pickedDate.year,
                      pickedDate.month,
                      pickedDate.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );

                    setState(() {
                      _dueDateTime = combinedDateTime;
                    });
                  }
                }
              },
              child: Text(
                _dueDateTime == null
                    ? 'Chọn ngày & giờ hạn'
                    : 'Hạn: ${_formatDateTime(_dueDateTime!)}',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_titleController.text.isNotEmpty && _dueDateTime != null) {
                  final newTask = Task(
                    title: _titleController.text,
                    description: _descriptionController.text,
                    dueDateTime: _dueDateTime,
                  );
                  Navigator.pop(context, newTask); // Trả task về HomePage
                }
              },
              child: const Text('Thêm công việc'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
