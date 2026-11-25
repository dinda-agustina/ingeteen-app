import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/task_model.dart';
import '../../models/label_model.dart';
import '../../providers/task_provider.dart';
import '../../providers/label_provider.dart';
import 'task_form_screen.dart';

class TaskDetailScreen extends StatefulWidget {
  final TaskModel task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  static const Color navy = Color(0xFF26364D);
  static const Color cream = Color(0xFFF9F5E9);
  static const Color orange = Color(0xFFFFB31A);
  static const Color mutedText = Color(0xFF999999);

  // Reminder masih bersifat sementara.
  bool _reminderThreeDays = true;
  bool _reminderOneDay = true;
  bool _reminderDueDay = true;

  bool _isDeleting = false;
  bool _isArchiving = false;
  bool _isUpdatingStatus = false;

  // Warna status tugas.
  Color _priorityColor(TaskModel task) {
    if (task.isCompleted) {
      return const Color(0xFF858585);
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

  // Tulisan status tugas.
  String _priorityText(TaskModel task) {
    if (task.isCompleted) {
      return 'Completed';
    }

    switch (task.deadlineLevel) {
      case DeadlineLevel.urgent:
        return 'Urgent';

      case DeadlineLevel.near:
        return 'Due Soon';

      case DeadlineLevel.safe:
        return 'On Track';
    }
  }

  // Membuka halaman edit tugas.
  Future<void> _editTask(TaskModel task) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TaskFormScreen(task: task)),
    );
  }

  // Popup konfirmasi penghapusan.
  Future<bool> _showDeleteConfirmation(TaskModel task) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: const Color(0xFFFFFCF5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFE9E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                    size: 24,
                  ),
                ),

                const SizedBox(height: 14),

                const Text(
                  'Delete Task?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: navy,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 9),

                Text(
                  'Are you sure you want to delete '
                  '"${task.judul}"?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: mutedText,
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(dialogContext, false);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: navy,
                            side: const BorderSide(color: Color(0xFFE5E0D5)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(dialogContext, true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: orange,
                            foregroundColor: navy,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9),
                            ),
                          ),
                          child: const Text(
                            'Delete',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    return result ?? false;
  }

  // Menghapus tugas.
  Future<void> _deleteTask(TaskModel task) async {
    if (_isDeleting) return;

    final confirmed = await _showDeleteConfirmation(task);

    if (confirmed != true || !mounted) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      await context.read<TaskProvider>().deleteTask(task.id);

      if (!mounted) return;

      // Kembali ke Home dan kirim tanda bahwa task berhasil dihapus.
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete task. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  Future<void> _showArchiveSuccessDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: const Color(0xFFFFFCF5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_outline_rounded,
                  color: Color(0xFF55A875),
                  size: 48,
                ),

                const SizedBox(height: 14),

                const Text(
                  'Task archived successfully!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: navy,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 9),

                const Text(
                  'This task has been moved to your archive.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: mutedText,
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orange,
                      foregroundColor: navy,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Memindahkan tugas ke Archive.
  Future<void> _archiveTask(TaskModel task) async {
    if (_isArchiving || _isDeleting) return;

    setState(() {
      _isArchiving = true;
    });

    try {
      await context.read<TaskProvider>().archiveTask(
            task.id,
            userId: task.userId,
          );

      if (!mounted) return;

      // Tampilkan dialog sukses sebelum kembali ke Home.
      await _showArchiveSuccessDialog();

      if (!mounted) return;

      // Kembali ke Home setelah pengguna menekan Done.
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to archive task. Please try again.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isArchiving = false;
        });
      }
    }
  }

  // Mengubah status tugas.
  Future<void> _toggleTaskStatus(TaskModel task) async {
    if (_isUpdatingStatus) return;

    setState(() {
      _isUpdatingStatus = true;
    });

    try {
      await context.read<TaskProvider>().toggleTaskStatus(task.id);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update task status. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingStatus = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();

    final currentTask = taskProvider.getTaskById(
      widget.task.id,
      userId: widget.task.userId,
    );

    // Cari label yang sedang digunakan tugas.
    final userLabels = context.watch<LabelProvider>().getLabelsForUser(
      widget.task.userId,
    );

    LabelModel? currentLabel;

    for (final label in userLabels) {
      if (label.id == currentTask?.labelId) {
        currentLabel = label;
        break;
      }
    }

    if (currentTask == null) {
      return Scaffold(
        backgroundColor: cream,
        appBar: AppBar(
          backgroundColor: cream,
          foregroundColor: navy,
          elevation: 0,
        ),
        body: const Center(
          child: Text('Task not found.', style: TextStyle(color: navy)),
        ),
      );
    }

    final priorityColor = _priorityColor(currentTask);

    final labelColor = currentLabel?.color ?? LabelModel.defaultColor;

    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        backgroundColor: cream,
        foregroundColor: navy,
        elevation: 0,
        scrolledUnderElevation: 0,
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
          // EDIT BUTTON
          IconButton(
            tooltip: 'Edit Task',
            onPressed: _isArchiving
                ? null
                : () => _editTask(currentTask),
            icon: const Icon(
              Icons.edit_outlined,
              size: 20,
            ),
          ),

          // ARCHIVE BUTTON
          IconButton(
            tooltip: 'Archive Task',
            onPressed: (_isArchiving || _isDeleting)
                ? null
                : () => _archiveTask(currentTask),
            icon: _isArchiving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: navy,
                    ),
                  )
                : const Icon(
                    Icons.archive_outlined,
                    color: navy,
                    size: 20,
                  ),
          ),

          // DELETE BUTTON
          IconButton(
            tooltip: 'Delete Task',
            onPressed: (_isDeleting || _isArchiving)
                ? null
                : () => _deleteTask(currentTask),
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
              // TASK INFORMATION CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: priorityColor, width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // LABEL AND STATUS
                    Row(
                      children: [
                        // LABEL DI SISI KIRI
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: labelColor.withValues(alpha: 0.28),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              currentTask.labelName?.isNotEmpty == true
                                  ? currentTask.labelName!
                                  : 'No Label',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: navy,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        // MEMBERIKAN RUANG DI ANTARA KEDUANYA
                        const Spacer(),

                        // STATUS DI SISI KANAN
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: priorityColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _priorityText(currentTask),
                            maxLines: 1,
                            style: TextStyle(
                              color: priorityColor,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // TASK TITLE
                    Text(
                      currentTask.judul,
                      style: const TextStyle(
                        color: navy,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 7),

                    // DESCRIPTION
                    Text(
                      currentTask.deskripsi.trim().isEmpty
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
                      style: const TextStyle(color: navy, fontSize: 10),
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

              // REMINDER CARD
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
                      description: 'Remind me 3 days before',
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
                      'Reminder preferences are temporary and are not saved yet.',
                      style: TextStyle(color: mutedText, fontSize: 8),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // MARK COMPLETE BUTTON
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  onPressed: _isUpdatingStatus || _isDeleting || _isArchiving ? null
                    : () => _toggleTaskStatus(currentTask),
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

  // REMINDER WIDGET
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
                style: const TextStyle(color: mutedText, fontSize: 8),
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
            trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
          ),
        ),
      ],
    );
  }
}
