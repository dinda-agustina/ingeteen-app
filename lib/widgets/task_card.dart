import 'package:flutter/material.dart';

import '../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onChanged;

  const TaskCard({
    super.key,
    required this.task,
    required this.onChanged,
  });

  static const Color completedBackground = Color(0xFFF0F0F0);
  static const Color completedBorder = Color(0xFFD2D2D2);
  static const Color completedText = Color(0xFF888888);

  Color _getBorderColor() {
    if (task.completed) {
      return completedBorder;
    }

    if (task.priority.contains('Urgent')) {
      return Colors.red.shade400;
    }

    if (task.priority.contains('Moderate')) {
      return Colors.orange.shade400;
    }

    return Colors.green.shade400;
  }

  Color _getPriorityColor() {
    if (task.completed) {
      return completedText;
    }

    if (task.priority.contains('Urgent')) {
      return Colors.red.shade700;
    }

    if (task.priority.contains('Moderate')) {
      return Colors.orange.shade700;
    }

    return Colors.green.shade700;
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _getBorderColor();
    final priorityColor = _getPriorityColor();

    // Completed tasks always display the Completed status.
    final displayedStatus =
        task.completed ? 'Completed' : task.priority;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: task.completed
            ? completedBackground
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: 1.5,
        ),
      ),
      child: SizedBox(
        height: 130,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                12,
                12,
                44,
                10,
              ),
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
                      color: task.completed
                          ? completedText
                          : const Color(0xFF26364D),
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
                    style: TextStyle(
                      fontSize: 10,
                      color: task.completed
                          ? completedText
                          : const Color(0xFF6F6F6F),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    displayedStatus,
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
                          color: task.completed
                              ? const Color(0xFFE2E2E2)
                              : const Color(0xFFEAF1FA),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          task.label,
                          style: TextStyle(
                            fontSize: 9,
                            color: task.completed
                                ? completedText
                                : const Color(0xFF526B8A),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '▣ ${task.deadline}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 9,
                            color: task.completed
                                ? completedText
                                : const Color(0xFF777777),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 6,
              child: Checkbox(
                value: task.completed,
                onChanged: (_) {
                  onChanged();
                },
                activeColor: completedText,
                side: const BorderSide(
                  color: Color(0xFF8793A3),
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}