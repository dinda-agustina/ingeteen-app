import 'package:flutter/foundation.dart';

import '../models/task_model.dart';

class TaskProvider extends ChangeNotifier {
  // The application starts with an empty task list.
  final List<TaskModel> _tasks = [];

  // Get all tasks.
  List<TaskModel> get tasks => List.unmodifiable(_tasks);

  // Get pending tasks.
  List<TaskModel> get pendingTasks =>
      _tasks.where((task) => !task.isCompleted).toList();

  // Get completed tasks.
  List<TaskModel> get completedTasks =>
      _tasks.where((task) => task.isCompleted).toList();

  // Add a new task.
  void addTask({
    required int userId,
    String? labelName,
    int? labelId,
    required String judul,
    required String deskripsi,
    required DateTime deadline,
    bool isCompleted = false,
  }) {
    final now = DateTime.now();

    final newId = _tasks.isEmpty
        ? 1
        : _tasks
                .map((task) => task.id)
                .reduce((a, b) => a > b ? a : b) +
            1;

    final newTask = TaskModel(
      id: newId,
      userId: userId,
      labelId: labelId,
      labelName: _normalizeLabel(labelName),
      judul: judul.trim(),
      deskripsi: deskripsi.trim(),
      deadline: deadline,
      isCompleted: isCompleted,
      createdAt: now,
      updatedAt: now,
    );

    _tasks.add(newTask);

    notifyListeners();
  }

  // Update an existing task.
  void updateTask({
    required int id,
    String? labelName,
    int? labelId,
    bool clearLabel = false,
    required String judul,
    required String deskripsi,
    required DateTime deadline,
    bool? isCompleted,
  }) {
    final index = _tasks.indexWhere(
      (task) => task.id == id,
    );

    if (index == -1) return;

    _tasks[index] = _tasks[index].copyWith(
      labelName: _normalizeLabel(labelName),
      labelId: labelId,
      clearLabel: clearLabel,
      judul: judul.trim(),
      deskripsi: deskripsi.trim(),
      deadline: deadline,
      isCompleted: isCompleted,
    );

    notifyListeners();
  }

  // Delete a task.
  void deleteTask(int id) {
    final initialLength = _tasks.length;

    _tasks.removeWhere(
      (task) => task.id == id,
    );

    if (_tasks.length != initialLength) {
      notifyListeners();
    }
  }

  // Change task completion status.
  void toggleTaskStatus(int id) {
    final index = _tasks.indexWhere(
      (task) => task.id == id,
    );

    if (index == -1) return;

    final task = _tasks[index];

    _tasks[index] = task.copyWith(
      isCompleted: !task.isCompleted,
    );

    notifyListeners();
  }

  // Find a task by ID.
  TaskModel? getTaskById(int id) {
    try {
      return _tasks.firstWhere(
        (task) => task.id == id,
      );
    } catch (_) {
      return null;
    }
  }

  // Search tasks by title, description, or label.
  List<TaskModel> searchTasks(String query) {
    final keyword = query.trim().toLowerCase();

    if (keyword.isEmpty) {
      return tasks;
    }

    return _tasks.where((task) {
      return task.judul.toLowerCase().contains(keyword) ||
          task.deskripsi.toLowerCase().contains(keyword) ||
          (task.labelName ?? '').toLowerCase().contains(keyword);
    }).toList();
  }

  // Normalize label values.
  String? _normalizeLabel(String? value) {
    final label = value?.trim();

    if (label == null || label.isEmpty) {
      return null;
    }

    return label;
  }
}