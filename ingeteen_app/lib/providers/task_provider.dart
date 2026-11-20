import 'package:flutter/foundation.dart';

import '../models/task_model.dart';
import '../services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService _taskService;

  final List<TaskModel> _tasks = [];

  bool _isLoading = false;
  String? _errorMessage;

  TaskProvider({TaskService? taskService})
      : _taskService = taskService ?? TaskService();

  // =========================
  // STATE
  // =========================

  List<TaskModel> get tasks => List.unmodifiable(_tasks);

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  List<TaskModel> get pendingTasks {
    return _tasks.where((task) => !task.isCompleted).toList();
  }

  List<TaskModel> get completedTasks {
    return _tasks.where((task) => task.isCompleted).toList();
  }

  // =========================
  // LOAD TASK
  // =========================

  Future<void> loadTasks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _taskService.getTasks();

      _tasks
        ..clear()
        ..addAll(result);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh task.
  Future<void> refreshTasks() async {
    await loadTasks();
  }

  // =========================
  // CREATE TASK
  // =========================

  Future<void> addTask({
    required int userId,
    String? labelName,
    int? labelId,
    required String judul,
    required String deskripsi,
    required DateTime deadline,
    bool isCompleted = false,
  }) async {
    try {
      final newTask = await _taskService.createTask(
        judul: judul,
        deskripsi: deskripsi,
        deadline: deadline,
        labelId: labelId,
        isCompleted: isCompleted,
      );

      _tasks.add(newTask);

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    }
  }

  // =========================
  // UPDATE TASK
  // =========================

  Future<void> updateTask({
    required int id,
    int? userId,
    String? labelName,
    int? labelId,
    bool clearLabel = false,
    required String judul,
    required String deskripsi,
    required DateTime deadline,
    bool? isCompleted,
  }) async {
    final existingTask = getTaskById(id, userId: userId);

    if (existingTask == null) return;

    try {
      final updatedTask = await _taskService.updateTask(
        id: id,
        judul: judul,
        deskripsi: deskripsi,
        deadline: deadline,
        labelId: clearLabel ? null : labelId,
        isCompleted: isCompleted ?? existingTask.isCompleted,
      );

      final index = _tasks.indexWhere((task) => task.id == id);

      if (index != -1) {
        _tasks[index] = updatedTask;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    }
  }

  // =========================
  // DELETE TASK
  // =========================

  Future<void> deleteTask(int id, {int? userId}) async {
    final existingTask = getTaskById(id, userId: userId);

    if (existingTask == null) return;

    try {
      await _taskService.deleteTask(id);

      _tasks.removeWhere(
        (task) => task.id == id,
      );

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    }
  }

  // =========================
  // TOGGLE STATUS
  // =========================

  Future<void> toggleTaskStatus(int id, {int? userId}) async {
    final existingTask = getTaskById(id, userId: userId);

    if (existingTask == null) return;

    try {
      final updatedTask = await _taskService.updateTaskStatus(
        id: id,
        isCompleted: !existingTask.isCompleted,
      );

      final index = _tasks.indexWhere(
        (task) => task.id == id,
      );

      if (index != -1) {
        _tasks[index] = updatedTask;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    }
  }

  // =========================
  // GET TASK
  // =========================

  TaskModel? getTaskById(int id, {int? userId}) {
    try {
      return _tasks.firstWhere(
        (task) =>
            task.id == id &&
            (userId == null || task.userId == userId),
      );
    } catch (_) {
      return null;
    }
  }

  // =========================
  // LABEL HELPER
  // =========================

  void renameLabel({
    required int userId,
    required int labelId,
    required String labelName,
  }) {
    bool changed = false;

    for (int i = 0; i < _tasks.length; i++) {
      final task = _tasks[i];

      if (task.userId == userId && task.labelId == labelId) {
        _tasks[i] = task.copyWith(
          labelName: labelName,
        );

        changed = true;
      }
    }

    if (changed) {
      notifyListeners();
    }
  }

  void removeLabelFromTasks({
    required int userId,
    required int labelId,
  }) {
    bool changed = false;

    for (int i = 0; i < _tasks.length; i++) {
      final task = _tasks[i];

      if (task.userId == userId && task.labelId == labelId) {
        _tasks[i] = task.copyWith(
          clearLabel: true,
        );

        changed = true;
      }
    }

    if (changed) {
      notifyListeners();
    }
  }

  // =========================
  // SEARCH
  // =========================

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

  // =========================
  // CLEAR DATA
  // =========================

  void clearTasks() {
    _tasks.clear();
    _errorMessage = null;
    notifyListeners();
  }
}