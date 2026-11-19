import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/task_model.dart';
import '../providers/task_provider.dart';
import 'task_form_screen.dart';

class TaskDetailScreen extends StatefulWidget {
  final TaskModel task;

  const TaskDetailScreen({
    super.key,
    required this.task,
  });

  @override
  State<TaskDetailScreen> createState() =>
      _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  static const navy = Color(0xFF26364D);
  static const cream = Color(0xFFF9F5E9);
  static const orange = Color(0xFFFFB31A);
  static const mutedText = Color(0xFF999999);

  // Reminder settings for the current screen.
  // These settings are temporary because TaskModel
  // does not currently store reminder preferences.
  bool _reminderThreeDays = true;
  bool _reminderOneDay = true;
  bool _reminderDueDay = true;

  Color _priorityColor(TaskModel task) {
    if (task.isCompleted) {
      return Colors.green.shade700;
    }

    switch (task.deadlineLevel) {
      case DeadlineLevel.urgent:
        return Colors.red.shade600;
      case DeadlineLevel.near:
        return Colors.orange.shade700;
      case DeadlineLevel.safe:
        return Colors.green.shade700;
    }
  }

  String _priorityText(TaskModel task) {
    if (task.isCompleted) {
      return 'Completed';
    }

    switch (task.deadlineLevel) {
      case DeadlineLevel.urgent:
        return 'Urgent';
      case DeadlineLevel.near:
        return 'Pending • Tomorrow';
      case DeadlineLevel.safe:
        return 'Pending';
    }
  }

  Future<void> _editTask(TaskModel task) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TaskFormScreen(task: task),
      ),
    );
  }

  Future<void> _deleteTask(TaskModel task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Delete Task?',
            style: TextStyle(
              color: navy,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${task.judul}"?',
            style: const TextStyle(
              color: mutedText,
              fontSize: 13,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: mutedText),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    context.read<TaskProvider>().deleteTask(task.id);

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Task deleted successfully.'),
      ),
    );
  }

  void _toggleTaskStatus(TaskModel task) {
    context.read<TaskProvider>().toggleTaskStatus(task.id);
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();

    final currentTask = taskProvider.getTaskById(widget.task.id);

    if (currentTask == null) {
      return Scaffold(
        backgroundColor: cream,
        appBar: AppBar(
          backgroundColor: cream,
          foregroundColor: navy,
          elevation: 0,
        ),
        body: const Center(
          child: Text(
            'Task not found.',
            style: TextStyle(color: navy),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        backgroundColor: cream,
        foregroundColor: navy,
        elevation: 0,
        titleSpacing: 0,
        title: const Text(
          'Task Details',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: navy,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Edit Task',
            onPressed: () => _editTask(currentTask),
            icon: const Icon(
              Icons.edit_outlined,
              size: 20,
            ),
          ),
          IconButton(
            tooltip: 'Delete Task',
            onPressed: () => _deleteTask(currentTask),
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task information card.
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: currentTask.isCompleted
                        ? Colors.green.shade500
                        : Colors.red.shade400,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F0FF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              currentTask.labelName?.isNotEmpty == true
                                  ? currentTask.labelName!
                                  : 'No Label',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: navy,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: _priorityColor(currentTask)
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _priorityText(currentTask),
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: _priorityColor(currentTask),
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Text(
                      currentTask.judul,
                      style: const TextStyle(
                        color: navy,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Text(
                      currentTask.deskripsi.isEmpty
                          ? 'No description provided.'
                          : currentTask.deskripsi,
                      style: const TextStyle(
                        color: navy,
                        fontSize: 11,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'CREATED',
                      style: TextStyle(
                        color: mutedText,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      DateFormat('d MMMM yyyy • HH:mm')
                          .format(currentTask.createdAt),
                      style: const TextStyle(
                        color: navy,
                        fontSize: 10,
                      ),
                    ),

                    const SizedBox(height: 9),

                    const Text(
                      'DEADLINE',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      DateFormat('d MMMM yyyy • HH:mm')
                          .format(currentTask.deadline),
                      style: const TextStyle(
                        color: navy,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Reminder card.
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reminders',
                      style: TextStyle(
                        color: navy,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    _buildReminder(
                      title: 'D-3',
                      description: 'Remind me one day before',
                      value: _reminderThreeDays,
                      onChanged: (value) {
                        setState(() {
                          _reminderThreeDays = value;
                        });
                      },
                    ),

                    const SizedBox(height: 7),

                    _buildReminder(
                      title: 'D-1',
                      description: 'Remind me one day before',
                      value: _reminderOneDay,
                      onChanged: (value) {
                        setState(() {
                          _reminderOneDay = value;
                        });
                      },
                    ),

                    const SizedBox(height: 7),

                    _buildReminder(
                      title: 'Due day',
                      description: 'Remind me on the due date',
                      value: _reminderDueDay,
                      onChanged: (value) {
                        setState(() {
                          _reminderDueDay = value;
                        });
                      },
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Local reminders work even when the app is closed.',
                      style: TextStyle(
                        color: mutedText,
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Mark complete button.
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    _toggleTaskStatus(currentTask);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orange,
                    foregroundColor: navy,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  child: Text(
                    currentTask.isCompleted
                        ? 'Mark as Pending'
                        : 'Mark Complete',
                    style: const TextStyle(
                      fontSize: 11,
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

  Widget _buildReminder({
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: navy,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: const TextStyle(
                  color: mutedText,
                  fontSize: 8,
                ),
              ),
            ],
          ),
        ),
        Transform.scale(
          scale: 0.78,
          child: Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: navy,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFD5D5D5),
            trackOutlineColor:
                WidgetStateProperty.all(Colors.transparent),
          ),
        ),
      ],
    );
  }
}