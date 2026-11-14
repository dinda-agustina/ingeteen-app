import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/label_model.dart';
import '../../models/task_model.dart';
import '../../services/dummy_data.dart';

class LabelDetailScreen extends StatefulWidget {
  final LabelModel label;
  final int userId;

  const LabelDetailScreen({
    super.key,
    required this.label,
    required this.userId,
  });

  @override
  State<LabelDetailScreen> createState() => _LabelDetailScreenState();
}

class _LabelDetailScreenState extends State<LabelDetailScreen> {
  static const Color _background = Color(0xFFFAF6E9);
  static const Color _navy = Color(0xFF101C3C);
  static const Color _orange = Color(0xFFFFA800);
  static const Color _grey = Color(0xFF89909C);

  bool _showCompleted = false;

  List<TaskModel> get _allTasks {
    return DummyData.tasks.where((task) {
      return task.userId == widget.userId &&
          task.labelId == widget.label.id;
    }).toList();
  }

  List<TaskModel> get _filteredTasks {
    return _allTasks.where((task) {
      return task.isCompleted == _showCompleted;
    }).toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));
  }

  void _toggleTask(TaskModel task, bool completed) {
    final index = DummyData.tasks.indexWhere(
      (item) => item.id == task.id && item.userId == widget.userId,
    );

    if (index == -1) return;

    setState(() {
      DummyData.tasks[index] = task.copyWith(
        isCompleted: completed,
      );
    });
  }

  Color _statusColor(TaskModel task) {
    switch (task.deadlineLevel) {
      case DeadlineLevel.urgent:
        return const Color(0xFFFFA800);
      case DeadlineLevel.near:
        return const Color(0xFFFFB019);
      case DeadlineLevel.safe:
        return const Color(0xFF24D83D);
    }
  }

  String _statusText(TaskModel task) {
    switch (task.deadlineLevel) {
      case DeadlineLevel.urgent:
        return 'Due soon';
      case DeadlineLevel.near:
        return 'Due soon';
      case DeadlineLevel.safe:
        return 'On track';
    }
  }

  String _formatDeadline(DateTime deadline) {
    return DateFormat('d MMM yyyy G�� HH:mm', 'en').format(deadline);
  }

  Widget _buildTab(String title, bool completed) {
    final isSelected = _showCompleted == completed;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _showCompleted = completed;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(color: _orange, width: 1)
                : null,
          ),
          child: Text(
            title,
            style: TextStyle(
              color: _navy,
              fontSize: 10,
              fontWeight:
                  isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCard(TaskModel task) {
    final completed = task.isCompleted;
    final statusColor = _statusColor(task);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: completed
              ? const Color(0xFFE6E1D8)
              : statusColor,
          width: completed ? 1 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  task.judul,
                  style: TextStyle(
                    color: _navy,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    decoration:
                        completed ? TextDecoration.lineThrough : null,
                    decorationColor: _grey,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _toggleTask(task, !completed),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 17,
                  height: 17,
                  decoration: BoxDecoration(
                    color: completed ? _navy : Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: completed ? _navy : const Color(0xFF40516B),
                      width: 1.2,
                    ),
                  ),
                  child: completed
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 13,
                        )
                      : null,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (task.deskripsi.trim().isNotEmpty)
            Text(
              task.deskripsi,
              style: TextStyle(
                color: _grey,
                fontSize: 9,
                height: 1.4,
                decoration:
                    completed ? TextDecoration.lineThrough : null,
                decorationColor: _grey,
              ),
            ),

          const SizedBox(height: 8),

          if (completed)
            const Text(
              'G�� Completed',
              style: TextStyle(
                color: Color(0xFF52647C),
                fontSize: 9,
              ),
            )
          else
            Text(
              _statusText(task),
              style: TextStyle(
                color: statusColor == const Color(0xFF24D83D)
                    ? const Color(0xFF16852B)
                    : const Color(0xFFB77A00),
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),

          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: widget.label.color.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.label.namaLabel,
              style: const TextStyle(
                color: _navy,
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 10,
                color: _grey,
              ),
              const SizedBox(width: 5),
              Text(
                _formatDeadline(task.deadline),
                style: const TextStyle(
                  color: _grey,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasks = _filteredTasks;
    final totalTasks = _allTasks.length;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: _navy,
            size: 20,
          ),
        ),
        title: Text(
          widget.label.namaLabel,
          style: const TextStyle(
            color: _navy,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.label.namaLabel,
              style: const TextStyle(
                color: _navy,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              '0 notes G�� $totalTasks tasks',
              style: const TextStyle(
                color: _grey,
                fontSize: 9,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFFF1EDE3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  _buildTab('PENDING', false),
                  _buildTab('COMPLETED', true),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: tasks.isEmpty
                  ? Center(
                      child: Text(
                        _showCompleted
                            ? 'Belum ada tugas yang selesai.'
                            : 'Tidak ada tugas yang pending.',
                        style: const TextStyle(
                          color: _grey,
                          fontSize: 12,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 12),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        return _buildTaskCard(tasks[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
