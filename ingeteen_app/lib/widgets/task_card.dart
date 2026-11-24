import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/task_model.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final String labelName;
  final Color labelColor;
  final VoidCallback onChanged;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.task,
    required this.labelName,
    this.labelColor = const Color(0xFFE3DDD0),
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

  Widget _buildCheckbox() {
    return SizedBox(
      width: 30,
      height: 30,
      child: Checkbox(
        value: task.isCompleted,
        onChanged: (_) => onChanged(),
        activeColor: const Color(0xFF858585),
        checkColor: Colors.white,
        side: const BorderSide(color: Color(0xFF8793A3), width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _buildLabelAndDeadline(String deadlineText, bool completed) {
    final trimmedLabel = labelName.trim();

    return Row(
      children: [
        if (trimmedLabel.isNotEmpty) ...[
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 115),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: labelColor.withValues(alpha: 0.28),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                trimmedLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 9,
                  color: navy,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
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
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  deadlineText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9,
                    color: completed
                        ? const Color(0xFF858585)
                        : const Color(0xFF777777),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final completed = task.isCompleted;

    final deadlineText = DateFormat('dd MMM yyyy, HH:mm').format(task.deadline);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: completed ? const Color(0xFFE5E5E5) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getBorderColor(), width: 1.3),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TASK TITLE AND CHECKBOX
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Text(
                            task.judul,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: completed ? const Color(0xFF777777) : navy,
                              decoration: completed
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              decorationColor: const Color(0xFF777777),
                              decorationThickness: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      _buildCheckbox(),
                    ],
                  ),

                  // TASK DESCRIPTION
                  if (task.deskripsi.trim().isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      task.deskripsi,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        height: 1.3,
                        color: completed
                            ? const Color(0xFF858585)
                            : const Color(0xFF6F6F6F),
                      ),
                    ),
                  ],

                  const SizedBox(height: 6),

                  // TASK STATUS
                  Text(
                    _getPriorityText(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getPriorityColor(),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // LABEL AND DEADLINE
                  _buildLabelAndDeadline(deadlineText, completed),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
