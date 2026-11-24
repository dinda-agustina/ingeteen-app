import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/task_model.dart';
import '../services/task_service.dart';

// Data tugas yang disimpan di Trash.
class TrashedTask {
  final TaskModel task;
  final DateTime deletedAt;

  const TrashedTask({
    required this.task,
    required this.deletedAt,
  });
}

// Data tugas yang disimpan di Archive.
class ArchivedTask {
  final TaskModel task;
  final DateTime archivedAt;

  const ArchivedTask({
    required this.task,
    required this.archivedAt,
  });
}

class TaskProvider extends ChangeNotifier {
  final TaskService _taskService;
  final List<TaskModel> _tasks = [];

  // =========================
  // TRASH STATE
  // =========================

  final Map<int, List<TrashedTask>> _trashItems = {};
  final Map<int, Set<int>> _permanentlyDeletedIds = {};
  final Set<int> _loadedTrashUsers = {};

  // =========================
  // ARCHIVE STATE
  // =========================

  final Map<int, List<ArchivedTask>> _archiveItems = {};
  final Set<int> _loadedArchiveUsers = {};

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

  List<TaskModel> get pendingTasks =>
      _tasks.where((task) => !task.isCompleted).toList();

  List<TaskModel> get completedTasks =>
      _tasks.where((task) => task.isCompleted).toList();

  // Mengambil daftar Trash berdasarkan user ID.
  List<TrashedTask> trashItemsForUser(int userId) {
    return List.unmodifiable(_trashItems[userId] ?? []);
  }

  // Mengambil daftar Archive berdasarkan user ID.
  List<ArchivedTask> archiveItemsForUser(int userId) {
    return List.unmodifiable(_archiveItems[userId] ?? []);
  }

  // =========================
  // LOCAL TASK SERIALIZATION
  // =========================

  Map<String, dynamic> _taskToLocalJson(TaskModel task) {
    return {
      ...task.toJson(),
      'created_at': task.createdAt.toIso8601String(),
      'updated_at': task.updatedAt.toIso8601String(),
    };
  }

  // =========================
  // LOCAL TRASH STORAGE
  // =========================

  String _trashStorageKey(int userId) {
    return 'ingeteen_trash_$userId';
  }

  Future<void> _loadTrashForUser(int userId) async {
    if (_loadedTrashUsers.contains(userId)) return;

    final prefs = await SharedPreferences.getInstance();
    final storedData = prefs.getString(_trashStorageKey(userId));

    final items = <TrashedTask>[];
    final deletedIds = <int>{};

    if (storedData != null && storedData.isNotEmpty) {
      try {
        final decoded = jsonDecode(storedData) as Map<String, dynamic>;

        final storedItems = decoded['items'] as List? ?? [];

        for (final entry in storedItems) {
          final data = Map<String, dynamic>.from(entry as Map);

          final taskJson =
              Map<String, dynamic>.from(data['task'] as Map);

          items.add(
            TrashedTask(
              task: TaskModel.fromJson(taskJson),
              deletedAt: DateTime.parse(
                data['deleted_at'] as String,
              ),
            ),
          );
        }

        final storedDeletedIds =
            decoded['permanently_deleted_ids'] as List? ?? [];

        for (final id in storedDeletedIds) {
          deletedIds.add((id as num).toInt());
        }
      } catch (e) {
        debugPrint('Failed to load local Trash data: $e');
      }
    }

    _trashItems[userId] = items;
    _permanentlyDeletedIds[userId] = deletedIds;
    _loadedTrashUsers.add(userId);

    _tasks.removeWhere(
      (task) =>
          task.userId == userId &&
          (items.any((item) => item.task.id == task.id) ||
              deletedIds.contains(task.id)),
    );
  }

  Future<void> _saveTrashForUser(int userId) async {
    final prefs = await SharedPreferences.getInstance();

    final items = _trashItems[userId] ?? [];
    final deletedIds = _permanentlyDeletedIds[userId] ?? {};

    final data = {
      'items': items.map((item) {
        return {
          'task': _taskToLocalJson(item.task),
          'deleted_at': item.deletedAt.toIso8601String(),
        };
      }).toList(),
      'permanently_deleted_ids': deletedIds.toList(),
    };

    await prefs.setString(
      _trashStorageKey(userId),
      jsonEncode(data),
    );
  }

  Future<void> loadTrash(int userId) async {
    await _loadTrashForUser(userId);
    notifyListeners();
  }

  // =========================
  // LOCAL ARCHIVE STORAGE
  // =========================

  String _archiveStorageKey(int userId) {
    return 'ingeteen_archive_$userId';
  }

  Future<void> _loadArchiveForUser(int userId) async {
    if (_loadedArchiveUsers.contains(userId)) return;

    final prefs = await SharedPreferences.getInstance();

    final storedData = prefs.getString(
      _archiveStorageKey(userId),
    );

    final items = <ArchivedTask>[];

    if (storedData != null && storedData.isNotEmpty) {
      try {
        final decoded = jsonDecode(storedData) as List;

        for (final entry in decoded) {
          final data = Map<String, dynamic>.from(entry as Map);

          final taskJson =
              Map<String, dynamic>.from(data['task'] as Map);

          items.add(
            ArchivedTask(
              task: TaskModel.fromJson(taskJson),
              archivedAt: DateTime.parse(
                data['archived_at'] as String,
              ),
            ),
          );
        }
      } catch (e) {
        debugPrint('Failed to load local Archive data: $e');
      }
    }

    _archiveItems[userId] = items;
    _loadedArchiveUsers.add(userId);

    // Tugas yang sudah diarsipkan tidak boleh muncul di Home.
    _tasks.removeWhere(
      (task) =>
          task.userId == userId &&
          items.any((item) => item.task.id == task.id),
    );
  }

  Future<void> _saveArchiveForUser(int userId) async {
    final prefs = await SharedPreferences.getInstance();

    final items = _archiveItems[userId] ?? [];

    final data = items.map((item) {
      return {
        'task': _taskToLocalJson(item.task),
        'archived_at': item.archivedAt.toIso8601String(),
      };
    }).toList();

    await prefs.setString(
      _archiveStorageKey(userId),
      jsonEncode(data),
    );
  }

  Future<void> loadArchive(int userId) async {
    await _loadArchiveForUser(userId);
    notifyListeners();
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

      final userIds = result.map((task) => task.userId).toSet();

      // Muat Trash dan Archive setiap pengguna.
      for (final userId in userIds) {
        await _loadTrashForUser(userId);
        await _loadArchiveForUser(userId);
      }

      final filteredTasks = result.where((task) {
        final trashIds = (_trashItems[task.userId] ?? [])
            .map((item) => item.task.id)
            .toSet();

        final archiveIds = (_archiveItems[task.userId] ?? [])
            .map((item) => item.task.id)
            .toSet();

        final deletedIds =
            _permanentlyDeletedIds[task.userId] ?? {};

        return !trashIds.contains(task.id) &&
            !archiveIds.contains(task.id) &&
            !deletedIds.contains(task.id);
      }).toList();

      _tasks
        ..clear()
        ..addAll(filteredTasks);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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
  // MOVE TASK TO TRASH
  // =========================

  Future<void> deleteTask(int id, {int? userId}) async {
    final existingTask = getTaskById(id, userId: userId);

    if (existingTask == null) return;

    final ownerId = existingTask.userId;

    await _loadTrashForUser(ownerId);

    final items = _trashItems.putIfAbsent(
      ownerId,
      () => [],
    );

    if (!items.any((item) => item.task.id == id)) {
      items.add(
        TrashedTask(
          task: existingTask,
          deletedAt: DateTime.now(),
        ),
      );
    }

    _tasks.removeWhere(
      (task) => task.id == id && task.userId == ownerId,
    );

    await _saveTrashForUser(ownerId);
    notifyListeners();
  }

  // =========================
  // ARCHIVE TASK
  // =========================

  Future<void> archiveTask(int id, {int? userId}) async {
    final existingTask = getTaskById(id, userId: userId);

    if (existingTask == null) return;

    final ownerId = existingTask.userId;

    await _loadArchiveForUser(ownerId);

    final items = _archiveItems.putIfAbsent(
      ownerId,
      () => [],
    );

    if (!items.any((item) => item.task.id == id)) {
      items.add(
        ArchivedTask(
          task: existingTask,
          archivedAt: DateTime.now(),
        ),
      );
    }

    _tasks.removeWhere(
      (task) => task.id == id && task.userId == ownerId,
    );

    await _saveArchiveForUser(ownerId);
    notifyListeners();
  }

  // =========================
  // UNARCHIVE TASK
  // =========================

  Future<void> unarchiveTask(
    int id, {
    required int userId,
  }) async {
    await _loadArchiveForUser(userId);

    final items = _archiveItems[userId] ?? [];

    final index = items.indexWhere(
      (item) => item.task.id == id,
    );

    if (index == -1) return;

    final restoredTask = items[index].task;

    items.removeAt(index);

    final alreadyExists = _tasks.any(
      (task) => task.id == id && task.userId == userId,
    );

    if (!alreadyExists) {
      _tasks.add(restoredTask);
    }

    await _saveArchiveForUser(userId);
    notifyListeners();
  }

  // =========================
  // MOVE ARCHIVED TASK TO TRASH
  // =========================

  Future<void> deleteArchivedTask(
    int id, {
    required int userId,
  }) async {
    await _loadArchiveForUser(userId);
    await _loadTrashForUser(userId);

    final archiveItems = _archiveItems[userId] ?? [];

    final index = archiveItems.indexWhere(
      (item) => item.task.id == id,
    );

    if (index == -1) return;

    final archivedTask = archiveItems[index].task;

    final trashItems = _trashItems.putIfAbsent(
      userId,
      () => [],
    );

    if (!trashItems.any((item) => item.task.id == id)) {
      trashItems.add(
        TrashedTask(
          task: archivedTask,
          deletedAt: DateTime.now(),
        ),
      );
    }

    archiveItems.removeAt(index);

    await _saveArchiveForUser(userId);
    await _saveTrashForUser(userId);

    notifyListeners();
  }

  // =========================
  // RESTORE TASK FROM TRASH
  // =========================

  Future<void> restoreTask(
    int id, {
    required int userId,
  }) async {
    await _loadTrashForUser(userId);

    final items = _trashItems[userId] ?? [];

    final index = items.indexWhere(
      (item) => item.task.id == id,
    );

    if (index == -1) return;

    final restoredTask = items[index].task;

    items.removeAt(index);

    final alreadyExists = _tasks.any(
      (task) => task.id == id && task.userId == userId,
    );

    if (!alreadyExists) {
      _tasks.add(restoredTask);
    }

    await _saveTrashForUser(userId);
    notifyListeners();
  }

  // =========================
  // DELETE FOREVER
  // =========================

  Future<void> deleteForever(
    int id, {
    required int userId,
  }) async {
    await _loadTrashForUser(userId);

    final items = _trashItems[userId] ?? [];

    items.removeWhere(
      (item) => item.task.id == id,
    );

    _permanentlyDeletedIds
        .putIfAbsent(userId, () => {})
        .add(id);

    _tasks.removeWhere(
      (task) => task.id == id && task.userId == userId,
    );

    await _saveTrashForUser(userId);
    notifyListeners();
  }

  // =========================
  // TOGGLE STATUS
  // =========================

  Future<void> toggleTaskStatus(
    int id, {
    int? userId,
  }) async {
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

  TaskModel? getTaskById(
    int id, {
    int? userId,
  }) {
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

    if (changed) notifyListeners();
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

    if (changed) notifyListeners();
  }

  // =========================
  // SEARCH
  // =========================

  List<TaskModel> searchTasks(String query) {
    final keyword = query.trim().toLowerCase();

    if (keyword.isEmpty) return tasks;

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