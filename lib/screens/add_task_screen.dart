import 'package:flutter/material.dart';

import '../models/task.dart';
import '../services/task_service.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? task;

  const AddTaskScreen({super.key, this.task});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _labelController;

  DateTime? _selectedDeadline;

  bool _isSaving = false;

  bool get _isEditing => widget.task != null;

  static const Map<String, int> _months = <String, int>{
    'january': 1,
    'february': 2,
    'march': 3,
    'april': 4,
    'may': 5,
    'june': 6,
    'july': 7,
    'august': 8,
    'september': 9,
    'october': 10,
    'november': 11,
    'december': 12,
    'januari': 1,
    'februari': 2,
    'maret': 3,
    'mei': 5,
    'juni': 6,
    'juli': 7,
    'agustus': 8,
    'oktober': 10,
    'desember': 12,
  };

  @override
  void initState() {
    super.initState();

    final Task? task = widget.task;

    _titleController = TextEditingController(text: task?.title ?? '');

    _descriptionController = TextEditingController(
      text: task?.description ?? '',
    );

    _labelController = TextEditingController(text: task?.label ?? '');

    _selectedDeadline = task == null
        ? DateTime.now().add(const Duration(days: 7))
        : _parseDeadline(task.deadline);

    _selectedDeadline ??= DateTime.now().add(const Duration(days: 7));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  // Parse existing deadline.
  DateTime? _parseDeadline(String value) {
    try {
      final String normalized = value
          .replaceAll('Ã¢â‚¬Â¢', '•')
          .replaceAll('â€¢', '•')
          .replaceAll('Â·', '•');

      final List<String> parts = normalized.split('•');

      if (parts.length != 2) {
        return null;
      }

      final List<String> dateParts = parts[0].trim().split(RegExp(r'\s+'));

      final List<String> timeParts = parts[1].trim().split(':');

      if (dateParts.length != 3 || timeParts.length != 2) {
        return null;
      }

      final int day = int.parse(dateParts[0]);

      final int? month = _months[dateParts[1].toLowerCase()];

      final int year = int.parse(dateParts[2]);

      final int hour = int.parse(timeParts[0]);

      final int minute = int.parse(timeParts[1]);

      if (month == null ||
          day < 1 ||
          day > 31 ||
          hour < 0 ||
          hour > 23 ||
          minute < 0 ||
          minute > 59) {
        return null;
      }

      final DateTime date = DateTime(year, month, day, hour, minute);

      if (date.year != year || date.month != month || date.day != day) {
        return null;
      }

      return date;
    } catch (_) {
      return null;
    }
  }

  // Format deadline.
  String _formatDeadline(DateTime date) {
    const List<String> months = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final String day = date.day.toString().padLeft(2, '0');

    final String month = months[date.month - 1];

    final String year = date.year.toString();

    final String hour = date.hour.toString().padLeft(2, '0');

    final String minute = date.minute.toString().padLeft(2, '0');

    return '$day $month $year • $hour:$minute';
  }

  // Select date.
  Future<void> _selectDate() async {
    final DateTime now = DateTime.now();

    final DateTime today = DateTime(now.year, now.month, now.day);

    final DateTime currentDeadline = _selectedDeadline ?? now;

    final DateTime initialDate = currentDeadline.isBefore(today)
        ? today
        : currentDeadline;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: today,
      lastDate: DateTime(2100),
      helpText: 'Select Deadline Date',
    );

    if (picked == null || !mounted) {
      return;
    }

    setState(() {
      final DateTime oldTime = _selectedDeadline ?? now;

      _selectedDeadline = DateTime(
        picked.year,
        picked.month,
        picked.day,
        oldTime.hour,
        oldTime.minute,
      );
    });
  }

  // Select time.
  Future<void> _selectTime() async {
    final DateTime initial = _selectedDeadline ?? DateTime.now();

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
      helpText: 'Select Deadline Time',
    );

    if (picked == null || !mounted) {
      return;
    }

    setState(() {
      _selectedDeadline = DateTime(
        initial.year,
        initial.month,
        initial.day,
        picked.hour,
        picked.minute,
      );
    });
  }

  // Save task.
  Future<void> _saveTask() async {
    if (_isSaving) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final DateTime? deadline = _selectedDeadline;

    if (deadline == null) {
      return;
    }

    if (deadline.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deadline cannot be in the past.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final Task task = Task(
        id: widget.task?.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        label: _labelController.text.trim(),
        priority: widget.task?.priority ?? 'Medium',
        deadline: _formatDeadline(deadline),
        completed: widget.task?.completed ?? false,
      );

      if (_isEditing) {
        await TaskService.updateTask(task);
      } else {
        await TaskService.addTask(task);
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Task updated successfully.'
                : 'Task added successfully.',
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save task: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF26364D);
    const Color accentColor = Color(0xFFFFB31A);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F5E9),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F5E9),
        foregroundColor: primaryColor,
        elevation: 0,
        title: Text(
          _isEditing ? 'Edit Task' : 'Add New Task',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),

      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Task title.
              _buildLabel('Task Title'),

              const SizedBox(height: 8),

              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: _inputDecoration('Enter task title', Icons.title),
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Task title is required.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Description.
              _buildLabel('Description'),

              const SizedBox(height: 8),

              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: _inputDecoration(
                  'Enter task description',
                  Icons.description_outlined,
                ),
              ),

              const SizedBox(height: 20),

              // Flexible label.
              _buildLabel('Label'),

              const SizedBox(height: 8),

              TextFormField(
                controller: _labelController,
                textCapitalization: TextCapitalization.words,
                decoration: _inputDecoration(
                  'Enter your own label',
                  Icons.label_outline,
                ),
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Label is required.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Deadline.
              _buildLabel('Deadline'),

              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selectDate,
                      icon: const Icon(Icons.calendar_month),
                      label: const Text('Select Date'),
                      style: _outlinedButtonStyle(),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selectTime,
                      icon: const Icon(Icons.access_time),
                      label: const Text('Select Time'),
                      style: _outlinedButtonStyle(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              if (_selectedDeadline != null)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.event_available,
                        color: primaryColor,
                        size: 20,
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          _formatDeadline(_selectedDeadline!),
                          style: const TextStyle(
                            fontSize: 12,
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 35),

              // Save button.
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveTask,

                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: primaryColor,
                          ),
                        )
                      : Icon(_isEditing ? Icons.save : Icons.add),

                  label: Text(
                    _isSaving
                        ? 'Saving...'
                        : _isEditing
                        ? 'Save Changes'
                        : 'Add Task',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: primaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
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

  // Form label.
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Color(0xFF26364D),
      ),
    );
  }

  // Input decoration.
  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF999999)),

      prefixIcon: Icon(icon, size: 19, color: const Color(0xFF7D8999)),

      filled: true,
      fillColor: Colors.white,

      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFFFB31A), width: 1.5),
      ),
    );
  }

  // Outlined button style.
  ButtonStyle _outlinedButtonStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFF26364D),
      side: const BorderSide(color: Color(0xFFFFB31A)),
      padding: const EdgeInsets.symmetric(vertical: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}
