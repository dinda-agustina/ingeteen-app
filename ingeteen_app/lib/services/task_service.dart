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