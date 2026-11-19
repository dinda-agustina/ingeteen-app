import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/task_model.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final String labelName;
  final VoidCallback onChanged;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.task,
    required this.labelName,
    required this.onChanged,
    this.onTap,
  });

  static const navy = Color(0xFF26364D);

  Color _getBorderColor() {
    if (task.isCompleted) {
      return const Color(0xFFC8C8C8);
    }

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
    if (task.isCompleted) {
      return const Color(0xFF858585);
    }

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
        color: completed
            ? const Color(0xFFE5E5E5)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getBorderColor(),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              height: completed ? 165 : 145,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      12,
                      12,
                      55,
                      10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Task title.
                        Text(
                          task.judul,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: completed
                                ? const Color(0xFF777777)
                                : navy,
                            decoration: completed
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            decorationColor: const Color(0xFF777777),
                            decorationThickness: 1.5,
                          ),
                        ),

                        const SizedBox(height: 5),

                        // Task description.
                        Text(
                          task.deskripsi,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            color: completed
                                ? const Color(0xFF858585)
                                : const Color(0xFF6F6F6F),
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Task status.
                        Text(
                          _getPriorityText(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _getPriorityColor(),
                          ),
                        ),

                        const SizedBox(height: 5),

                        // Label and deadline.
                        Row(
                          children: [
                            if (labelName.isNotEmpty)
                              Container(
                                constraints: const BoxConstraints(
                                  maxWidth: 100,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: completed
                                      ? const Color(0xFFDCDCDC)
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
                                        ? const Color(0xFF777777)
                                        : const Color(0xFF526B8A),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),

                            const SizedBox(width: 8),

                            Expanded(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    size: 11,
                                    color: completed
                                        ? const Color(0xFF858585)
                                        : const Color(0xFF777777),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      deadlineText,
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: completed
                                            ? const Color(0xFF858585)
                                            : const Color(0xFF777777),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Completion checkbox.
                  Positioned(
                    top: 7,
                    right: 8,
                    child: Checkbox(
                      value: completed,
                      onChanged: (_) => onChanged(),
                      activeColor: completed
                          ? const Color(0xFF858585)
                          : navy,
                      checkColor: Colors.white,
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
          ),
        ),
      ),
    );
  }
}