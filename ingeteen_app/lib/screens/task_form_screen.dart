import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/task_model.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../services/dummy_data.dart';

class TaskFormScreen extends StatefulWidget {
  final TaskModel? task;

  const TaskFormScreen({super.key, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  static const navy = Color(0xFF26364D);
  static const cream = Color(0xFFF9F5E9);
  static const orange = Color(0xFFFFB31A);

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _judulController;
  late final TextEditingController _deskripsiController;
  late final TextEditingController _labelController;

  DateTime? _deadline;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();

    _judulController = TextEditingController(
      text: widget.task?.judul ?? '',
    );

    _deskripsiController = TextEditingController(
      text: widget.task?.deskripsi ?? '',
    );

    _labelController = TextEditingController(
      text: widget.task?.labelName ?? '',
    );

    _deadline = widget.task?.deadline;
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _selectDeadline() async {
    final now = DateTime.now();

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _deadline ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      helpText: 'Select deadline date',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: orange,
              onPrimary: navy,
              surface: Colors.white,
              onSurface: navy,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate == null || !mounted) return;

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: _deadline != null
          ? TimeOfDay.fromDateTime(_deadline!)
          : const TimeOfDay(hour: 23, minute: 59),
      helpText: 'Select deadline time',
    );

    if (selectedTime == null || !mounted) return;

    setState(() {
      _deadline = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );
    });
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) return;

    if (_deadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a deadline.'),
        ),
      );
      return;
    }

    final user = context.read<AuthProvider>().user;
    final userId = user?.id ?? DummyData.user.id;

    final provider = context.read<TaskProvider>();

    final labelName = _labelController.text.trim();

    if (_isEditing) {
      provider.updateTask(
        id: widget.task!.id,
        labelName: labelName.isEmpty ? null : labelName,
        clearLabel: labelName.isEmpty,
        judul: _judulController.text,
        deskripsi: _deskripsiController.text,
        deadline: _deadline!,
      );
    } else {
      provider.addTask(
        userId: userId,
        labelName: labelName.isEmpty ? null : labelName,
        judul: _judulController.text,
        deskripsi: _deskripsiController.text,
        deadline: _deadline!,
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        backgroundColor: cream,
        foregroundColor: navy,
        elevation: 0,
        title: Text(
          _isEditing ? 'Edit Task' : 'Add Task',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFieldTitle('Task Title'),
              const SizedBox(height: 7),
              TextFormField(
                controller: _judulController,
                decoration: _inputDecoration('Enter task title'),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Task title is required.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 18),

              _buildFieldTitle('Description'),
              const SizedBox(height: 7),
              TextFormField(
                controller: _deskripsiController,
                maxLines: 4,
                decoration: _inputDecoration(
                  'Enter task description',
                ),
                textCapitalization: TextCapitalization.sentences,
              ),

              const SizedBox(height: 18),

              _buildFieldTitle('Label'),
              const SizedBox(height: 7),
              TextFormField(
                controller: _labelController,
                decoration: _inputDecoration(
                  'Type your own label',
                ).copyWith(
                  prefixIcon: const Icon(
                    Icons.label_outline,
                    color: navy,
                    size: 20,
                  ),
                ),
                textCapitalization: TextCapitalization.words,
              ),

              const SizedBox(height: 5),
              const Text(
                'Optional. Create any label you want.',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF888888),
                ),
              ),

              const SizedBox(height: 18),

              _buildFieldTitle('Deadline'),
              const SizedBox(height: 7),
              InkWell(
                onTap: _selectDeadline,
                borderRadius: BorderRadius.circular(10),
                child: InputDecorator(
                  decoration: _inputDecoration(
                    'Select date and time',
                  ).copyWith(
                    prefixIcon: const Icon(
                      Icons.calendar_month,
                      color: navy,
                      size: 20,
                    ),
                  ),
                  child: Text(
                    _deadline == null
                        ? 'No deadline selected'
                        : DateFormat(
                            'dd MMM yyyy, HH:mm',
                          ).format(_deadline!),
                    style: TextStyle(
                      color: _deadline == null
                          ? const Color(0xFF888888)
                          : navy,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _saveTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orange,
                    foregroundColor: navy,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    _isEditing ? 'Save Changes' : 'Add Task',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: navy,
        fontWeight: FontWeight.bold,
        fontSize: 13,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFF999999),
        fontSize: 12,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFFE5E0D5),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: orange,
          width: 1.3,
        ),
      ),
    );
  }
}