import 'package:flutter/foundation.dart';

import '../models/task_model.dart';

class TaskProvider extends ChangeNotifier {
  // The application starts with an empty task list.
  final List<TaskModel> _tasks = [];

  List<TaskModel> get tasks => List.unmodifiable(_tasks);

  List<TaskModel> get pendingTasks =>
      _tasks.where((task) => !task.isCompleted).toList();

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
  }) {
    final now = DateTime.now();

    final newId = _tasks.isEmpty
        ? 1
        : _tasks.map((task) => task.id).reduce(
              (a, b) => a > b ? a : b,
            ) +
            1;

    final newTask = TaskModel(
      id: newId,
      userId: userId,
      labelId: labelId,
      labelName: _normalizeLabel(labelName),
      judul: judul.trim(),
      deskripsi: deskripsi.trim(),
      deadline: deadline,
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
  }) {
    final index = _tasks.indexWhere((task) => task.id == id);

    if (index == -1) return;

    _tasks[index] = _tasks[index].copyWith(
      labelName: _normalizeLabel(labelName),
      labelId: labelId,
      clearLabel: clearLabel,
      judul: judul.trim(),
      deskripsi: deskripsi.trim(),
      deadline: deadline,
    );

    notifyListeners();
  }

  // Delete a task.
  void deleteTask(int id) {
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
  }

  // Change task completion status.
  void toggleTaskStatus(int id) {
    final index = _tasks.indexWhere((task) => task.id == id);

    if (index == -1) return;

    final task = _tasks[index];

    _tasks[index] = task.copyWith(
      isCompleted: !task.isCompleted,
    );

    notifyListeners();
  }

  String? _normalizeLabel(String? value) {
    final label = value?.trim();

    if (label == null || label.isEmpty) {
      return null;
    }

    return label;
  }
}