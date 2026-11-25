import '../models/task_model.dart';
import 'api_service.dart';
import '../core/config/api_config.dart';

class TaskService {
  final ApiService _apiService;

  TaskService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  // Mengambil seluruh task user yang sedang login.
  Future<List<TaskModel>> getTasks() async {
    final response = await _apiService.get(
      ApiConfig.tasks,
      withToken: true,
    );

    final data = response['data'] as List;

    return data.map((item) {
      return TaskModel.fromJson(_normalizeTaskJson(item));
    }).toList();
  }

  // Mengambil seluruh task yang diarsipkan.
  Future<List<TaskModel>> getArchivedTasks() async {
    final response = await _apiService.get(
      '${ApiConfig.tasks}/archived',
      withToken: true,
    );

    final data = response['data'] as List;

    return data.map((item) {
      return TaskModel.fromJson(_normalizeTaskJson(item));
    }).toList();
  }

// Mengambil seluruh task yang berada di Trash.
  Future<List<TaskModel>> getTrashedTasks() async {
    final response = await _apiService.get(
      '${ApiConfig.tasks}/trash',
      withToken: true,
    );

    final data = response['data'] as List;

    return data.map((item) {
      return TaskModel.fromJson(_normalizeTaskJson(item));
    }).toList();
  }

  // Memindahkan task ke Archive.
  Future<TaskModel> archiveTask(int id) async {
    final response = await _apiService.post(
      '${ApiConfig.tasks}/$id/archive',
      withToken: true,
    );

    return TaskModel.fromJson(
      _normalizeTaskJson(response['data']),
    );
  }

  // Mengembalikan task dari Archive ke Home.
  Future<TaskModel> unarchiveTask(int id) async {
    final response = await _apiService.post(
      '${ApiConfig.tasks}/$id/unarchive',
      withToken: true,
    );

    return TaskModel.fromJson(
      _normalizeTaskJson(response['data']),
    );
  }

  // Memulihkan task dari Trash.
  Future<TaskModel> restoreTask(int id) async {
    final response = await _apiService.post(
      '${ApiConfig.tasks}/$id/restore',
      withToken: true,
    );

    return TaskModel.fromJson(
      _normalizeTaskJson(response['data']),
    );
  }

  // Menghapus task secara permanen dari database.
  Future<void> deleteTaskForever(int id) async {
    await _apiService.delete(
      '${ApiConfig.tasks}/$id/force',
      withToken: true,
    );
  }

  // Menambahkan task baru.
  Future<TaskModel> createTask({
    required String judul,
    required String deskripsi,
    required DateTime deadline,
    int? labelId,
    bool isCompleted = false,
  }) async {
    final response = await _apiService.post(
      ApiConfig.tasks,
      withToken: true,
      body: {
        'judul': judul.trim(),
        'deskripsi': deskripsi.trim(),
        'deadline': deadline.toIso8601String(),
        'label_id': labelId,
        'is_completed': isCompleted,
      },
    );

    return TaskModel.fromJson(
      _normalizeTaskJson(response['data']),
    );
  }

  // Memperbarui task.
  Future<TaskModel> updateTask({
    required int id,
    required String judul,
    required String deskripsi,
    required DateTime deadline,
    int? labelId,
    bool isCompleted = false,
  }) async {
    final response = await _apiService.patch(
      '${ApiConfig.tasks}/$id',
      withToken: true,
      body: {
        'judul': judul.trim(),
        'deskripsi': deskripsi.trim(),
        'deadline': deadline.toIso8601String(),
        'label_id': labelId,
        'is_completed': isCompleted,
      },
    );

    return TaskModel.fromJson(
      _normalizeTaskJson(response['data']),
    );
  }

  // Mengubah status task.
  Future<TaskModel> updateTaskStatus({
    required int id,
    required bool isCompleted,
  }) async {
    final response = await _apiService.patch(
      '${ApiConfig.tasks}/$id/status',
      withToken: true,
      body: {
        'is_completed': isCompleted,
      },
    );

    return TaskModel.fromJson(
      _normalizeTaskJson(response['data']),
    );
  }

  // Menghapus task.
  Future<void> deleteTask(int id) async {
    await _apiService.delete(
      '${ApiConfig.tasks}/$id',
      withToken: true,
    );
  }

  // Menyesuaikan data relasi label Laravel dengan TaskModel Flutter.
  Map<String, dynamic> _normalizeTaskJson(dynamic item) {
    final json = Map<String, dynamic>.from(item);

    final label = json['label'];

    json['label_name'] = label is Map
        ? label['nama_label']
        : null;

    return json;
  }
}