import 'package:flutter/material.dart';
import 'Task.dart';

class AddTaskPage extends StatefulWidget {
  final Task? existingTask;

  const AddTaskPage({super.key, this.existingTask});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDateTime;

  @override
  void initState() {
    super.initState();
    if (widget.existingTask != null) {
      _titleController.text = widget.existingTask!.title;
      _descriptionController.text = widget.existingTask!.description ?? '';
      _selectedDateTime = widget.existingTask!.dueDateTime;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime ?? DateTime.now()),
    );
    if (time == null) return;

    setState(() {
      _selectedDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final newTask = Task(
        id: widget.existingTask?.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dueDateTime: _selectedDateTime,
      );
      Navigator.pop(context, newTask);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingTask != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Sửa công việc' : 'Thêm công việc'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Tên công việc'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Vui lòng nhập tên' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Mô tả'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    _selectedDateTime == null
                        ? 'Chưa chọn thời gian'
                        : 'Hạn: ${_selectedDateTime!.toLocal()}'.split('.')[0],
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _pickDateTime,
                    child: const Text('Chọn thời gian'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: Text(isEditing ? 'Cập nhật' : 'Thêm'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
