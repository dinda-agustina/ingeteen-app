
import 'package:flutter/foundation.dart';

import '../models/task_model.dart';
import '../services/task_service.dart';

// Data tugas yang ditampilkan di Trash.
class TrashedTask {
  final TaskModel task;
  final DateTime deletedAt;

  const TrashedTask({
    required this.task,
    required this.deletedAt,
  });
}

// Data tugas yang ditampilkan di Archive.
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

  TaskProvider({TaskService? taskService})
      : _taskService = taskService ?? TaskService();

  // =========================
  // STATE
  // =========================

  final List<TaskModel> _tasks = [];

  final Map<int, List<TrashedTask>> _trashItems = {};
  final Map<int, List<ArchivedTask>> _archiveItems = {};

  bool _isLoading = false;
  String? _errorMessage;

  List<TaskModel> get tasks => List.unmodifiable(_tasks);

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  List<TaskModel> get pendingTasks =>
      _tasks.where((task) => !task.isCompleted).toList();

  List<TaskModel> get completedTasks =>
      _tasks.where((task) => task.isCompleted).toList();

  // =========================
  // TRASH & ARCHIVE ACCESSOR
  // =========================

  List<TrashedTask> trashItemsForUser(int userId) {
    return List.unmodifiable(_trashItems[userId] ?? []);
  }

  List<ArchivedTask> archiveItemsForUser(int userId) {
    return List.unmodifiable(_archiveItems[userId] ?? []);
  }

  // =========================
  // LOAD TASKS (HOME)
  // =========================

  Future<void> loadTasks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _taskService.getTasks();

      // Endpoint /tasks seharusnya hanya mengembalikan
      // tugas aktif milik pengguna yang sedang login.
      _tasks
        ..clear()
        ..addAll(
          result.where(
            (task) =>
                task.archivedAt == null &&
                task.deletedAt == null,
          ),
        );
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
  // LOAD ARCHIVE FROM API
  // =========================

  Future<void> loadArchive(int userId) async {
    try {
      final result = await _taskService.getArchivedTasks();

      final items = result
          .where((task) =>
              task.userId == userId &&
              task.archivedAt != null &&
              task.deletedAt == null)
          .map(
            (task) => ArchivedTask(
              task: task,
              archivedAt: task.archivedAt!,
            ),
          )
          .toList()
        ..sort(
          (a, b) => b.archivedAt.compareTo(a.archivedAt),
        );

      _archiveItems[userId] = items;

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // =========================
  // LOAD TRASH FROM API
  // =========================

  Future<void> loadTrash(int userId) async {
    try {
      final result = await _taskService.getTrashedTasks();

      final items = result
          .where((task) =>
              task.userId == userId &&
              task.deletedAt != null)
          .map(
            (task) => TrashedTask(
              task: task,
              deletedAt: task.deletedAt!,
            ),
          )
          .toList()
        ..sort(
          (a, b) => b.deletedAt.compareTo(a.deletedAt),
        );

      _trashItems[userId] = items;

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
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

      if (newTask.archivedAt == null &&
          newTask.deletedAt == null) {
        _tasks.add(newTask);
      }

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
        (task) =>
            task.id == id &&
            task.userId == existingTask.userId,
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

    try {
      // Soft delete melalui Laravel API.
      await _taskService.deleteTask(id);

      // Muat ulang Home dan Trash dari database.
      await loadTasks();
      await loadTrash(ownerId);

    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    }
  }

  // =========================
  // ARCHIVE TASK
  // =========================

  Future<void> archiveTask(int id, {int? userId}) async {
    final existingTask = getTaskById(id, userId: userId);

    if (existingTask == null) return;

    final ownerId = existingTask.userId;

    try {
      // Simpan archived_at melalui Laravel API.
      await _taskService.archiveTask(id);

      // Perbarui Home dan Archive dari database.
      await loadTasks();
      await loadArchive(ownerId);

    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    }
  }

  // =========================
  // UNARCHIVE TASK
  // =========================

  Future<void> unarchiveTask(
    int id, {
    required int userId,
  }) async {
    try {
      // Hapus archived_at melalui Laravel API.
      await _taskService.unarchiveTask(id);

      // Muat ulang data agar status sesuai database.
      await loadTasks();
      await loadArchive(userId);

    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    }
  }

  // =========================
  // MOVE ARCHIVED TASK TO TRASH
  // =========================

  Future<void> deleteArchivedTask(
    int id, {
    required int userId,
  }) async {
    try {
      // Soft delete juga berlaku untuk tugas yang diarsipkan.
      await _taskService.deleteTask(id);

      // Perbarui kedua daftar.
      await loadArchive(userId);
      await loadTrash(userId);

    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    }
  }

  // =========================
  // RESTORE TASK FROM TRASH
  // =========================

  Future<void> restoreTask(
    int id, {
    required int userId,
  }) async {
    try {
      // Restore deleted_at melalui Laravel API.
      await _taskService.restoreTask(id);

      // archived_at tidak dihapus oleh proses restore.
      // Jika sebelumnya diarsipkan, tugas kembali ke Archive.
      // Jika tidak, tugas kembali ke Home.
      await loadTasks();
      await loadArchive(userId);
      await loadTrash(userId);

    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    }
  }

  // =========================
  // DELETE FOREVER
  // =========================

  Future<void> deleteForever(
    int id, {
    required int userId,
  }) async {
    try {
      // Hapus permanen melalui endpoint /force.
      await _taskService.deleteTaskForever(id);

      // Perbarui daftar Trash dari database.
      await loadTrash(userId);

    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    }
  }

  // =========================
  // TOGGLE TASK STATUS
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
        (task) =>
            task.id == id &&
            task.userId == existingTask.userId,
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
  // GET TASK BY ID
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
    _trashItems.clear();
    _archiveItems.clear();
    _errorMessage = null;

    notifyListeners();
  }
}
