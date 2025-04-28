import 'package:flutter/material.dart';
import 'Task.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TextEditingController _titleController = TextEditingController();
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );

                if (pickedDate != null && pickedDate != _dueDateTime) {
                  setState(() {
                    _dueDateTime = pickedDate;
                  });
                }
              },
              child: Text(_dueDateTime == null
                  ? 'Chọn ngày hạn'
                  : 'Ngày hạn: ${_dueDateTime?.toLocal()}'.split(' ')[0]),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_titleController.text.isNotEmpty && _dueDateTime != null) {
                  final newTask = Task(
                    title: _titleController.text,
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
}
