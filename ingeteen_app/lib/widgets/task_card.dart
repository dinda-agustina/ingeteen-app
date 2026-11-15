import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/task_model.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final String labelName;
  final VoidCallback onChanged;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.labelName,
    required this.onChanged,
    required this.onEdit,
    required this.onDelete,
  });

  Color _getBorderColor() {
    if (task.isCompleted) return Colors.grey.shade400;

    switch (task.deadlineLevel) {
      case DeadlineLevel.urgent:
        return Colors.red.shade400;
      case DeadlineLevel.near:
        return Colors.orange.shade400;
      case DeadlineLevel.safe:
        return Colors.green.shade400;
    }
  }

  Color _getPriorityColor() {
    if (task.isCompleted) return Colors.grey.shade600;

    switch (task.deadlineLevel) {
      case DeadlineLevel.urgent:
        return Colors.red.shade700;
      case DeadlineLevel.near:
        return Colors.orange.shade700;
      case DeadlineLevel.safe:
        return Colors.green.shade700;
    }
  }

  String _getPriorityText() {
    if (task.isCompleted) return 'Completed';

    switch (task.deadlineLevel) {
      case DeadlineLevel.urgent:
        return 'Urgent';
      case DeadlineLevel.near:
        return 'Due Soon';
      case DeadlineLevel.safe:
        return 'On Track';
    }
  }

  @override
  Widget build(BuildContext context) {
    final completed = task.isCompleted;

    final deadlineText =
        DateFormat('dd MMM yyyy, HH:mm').format(task.deadline);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: completed ? const Color(0xFFF0F0F0) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getBorderColor(),
          width: 1.5,
        ),
      ),
      child: SizedBox(
        height: 145,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 76, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.judul,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: completed
                          ? Colors.grey.shade600
                          : const Color(0xFF26364D),
                      decoration: completed
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    task.deskripsi,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      color: completed
                          ? Colors.grey.shade600
                          : const Color(0xFF6F6F6F),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _getPriorityText(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getPriorityColor(),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      if (labelName.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: completed
                                ? const Color(0xFFE0E0E0)
                                : const Color(0xFFEAF1FA),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            labelName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 9,
                              color: completed
                                  ? Colors.grey.shade700
                                  : const Color(0xFF526B8A),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '□ $deadlineText',
                          style: TextStyle(
                            fontSize: 9,
                            color: completed
                                ? Colors.grey.shade600
                                : const Color(0xFF777777),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 2,
              right: 4,
              child: Column(
                children: [
                  Checkbox(
                    value: completed,
                    onChanged: (_) => onChanged(),
                    activeColor: completed
                        ? Colors.grey.shade600
                        : const Color(0xFF26364D),
                    side: BorderSide(
                      color: completed
                          ? Colors.grey.shade500
                          : const Color(0xFF8793A3),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'Task options',
                    icon: Icon(
                      Icons.more_vert,
                      color: completed
                          ? Colors.grey.shade600
                          : const Color(0xFF526B8A),
                      size: 20,
                    ),
                    onSelected: (value) {
                      if (value == 'edit') onEdit();
                      if (value == 'delete') onDelete();
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 18),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: Colors.red,
                            ),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}