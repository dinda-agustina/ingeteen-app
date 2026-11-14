import 'package:flutter/material.dart';

import '../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onChanged;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onChanged,
    required this.onEdit,
    required this.onDelete,
  });

  // Convert deadline into DateTime.
  DateTime? _parseDeadline(String value) {
    try {
      final String normalized = value
          .replaceAll('Ã¢â‚¬Â¢', '•')
          .replaceAll('â€¢', '•')
          .replaceAll('Â·', '•');

      final parts = normalized.split('•');

      if (parts.length != 2) return null;

      final dateParts = parts[0].trim().split(RegExp(r'\s+'));

      final timeParts = parts[1].trim().split(':');

      if (dateParts.length != 3 || timeParts.length != 2) {
        return null;
      }

      const Map<String, int> months = {
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

      final day = int.parse(dateParts[0]);
      final month = months[dateParts[1].toLowerCase()];
      final year = int.parse(dateParts[2]);

      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      if (month == null || hour < 0 || hour > 23 || minute < 0 || minute > 59) {
        return null;
      }

      final deadline = DateTime(year, month, day, hour, minute);

      if (deadline.year != year ||
          deadline.month != month ||
          deadline.day != day) {
        return null;
      }

      return deadline;
    } catch (_) {
      return null;
    }
  }

  // Calculate task status automatically.
  String _getPriorityText() {
    if (task.completed) {
      return 'Completed';
    }

    final deadline = _parseDeadline(task.deadline);

    if (deadline == null) {
      return 'Unknown Deadline';
    }

    final now = DateTime.now();

    final difference = deadline.difference(now);

    if (difference.isNegative || difference.inSeconds == 0) {
      return 'Urgent';
    }

    final daysRemaining = difference.inDays;

    if (daysRemaining <= 1) {
      return 'Urgent';
    }

    if (daysRemaining <= 3) {
      return 'Due Soon';
    }

    return 'On Track';
  }

  Color _getBorderColor() {
    switch (_getPriorityText()) {
      case 'Completed':
        return Colors.grey.shade400;
      case 'Urgent':
        return Colors.red.shade400;
      case 'Due Soon':
        return Colors.orange.shade400;
      default:
        return Colors.green.shade400;
    }
  }

  Color _getPriorityColor() {
    switch (_getPriorityText()) {
      case 'Completed':
        return Colors.grey.shade600;
      case 'Urgent':
        return Colors.red.shade700;
      case 'Due Soon':
        return Colors.orange.shade700;
      default:
        return Colors.green.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final priorityText = _getPriorityText();
    final borderColor = _getBorderColor();
    final priorityColor = _getPriorityColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: SizedBox(
        height: 145,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 44, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF26364D),
                      decoration: task.completed
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    task.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF6F6F6F),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    priorityText,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: priorityColor,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF1FA),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          task.label,
                          style: const TextStyle(
                            fontSize: 9,
                            color: Color(0xFF526B8A),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '▣ ${task.deadline}',
                          style: const TextStyle(
                            fontSize: 9,
                            color: Color(0xFF777777),
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
              top: 4,
              right: 4,
              child: Column(
                children: [
                  Checkbox(
                    value: task.completed,
                    onChanged: (_) => onChanged(),
                    activeColor: const Color(0xFF26364D),
                    side: const BorderSide(
                      color: Color(0xFF8793A3),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.more_vert,
                      size: 19,
                      color: Color(0xFF777777),
                    ),
                    onSelected: (value) {
                      if (value == 'edit') {
                        onEdit();
                      } else if (value == 'delete') {
                        onDelete();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 18),
                            SizedBox(width: 10),
                            Text('Edit Task'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: Colors.red,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Delete Task',
                              style: TextStyle(color: Colors.red),
                            ),
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
