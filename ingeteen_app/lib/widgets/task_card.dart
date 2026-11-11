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

  Color _getBorderColor() {
    if (task.completed) {
      return Colors.green.shade400;
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
      return Colors.green.shade700;
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
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
                    task.priority,
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
              top: 10,
              right: 8,
              child: Checkbox(
                value: task.completed,
                onChanged: (_) {
                  onChanged();
                },
                activeColor: const Color(0xFF26364D),
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