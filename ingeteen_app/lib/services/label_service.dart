import '../models/label_model.dart';
import '../core/config/api_config.dart';
import 'api_service.dart';

class LabelService {
  final ApiService _apiService;

  LabelService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  // Mengambil seluruh label milik user.
  Future<List<LabelModel>> getLabels() async {
    final response = await _apiService.get(
      ApiConfig.labels,
      withToken: true,
    );

    final data = response['data'] as List;

    return data.map((item) {
      return LabelModel.fromJson(
        Map<String, dynamic>.from(item),
      );
    }).toList();
  }

  // Membuat label baru.
  Future<LabelModel> createLabel({
    required String namaLabel,
    String? kodeWarna,
  }) async {
    final response = await _apiService.post(
      ApiConfig.labels,
      withToken: true,
      body: {
        'nama_label': namaLabel.trim(),
        // Backend mewajibkan kode warna.
        'kode_warna': kodeWarna ?? '#E3DDD0',
      },
    );

    return LabelModel.fromJson(
      Map<String, dynamic>.from(response['data']),
    );
  }

  // Memperbarui label.
  Future<LabelModel> updateLabel({
    required int id,
    required String namaLabel,
    String? kodeWarna,
  }) async {
    final response = await _apiService.patch(
      '${ApiConfig.labels}/$id',
      withToken: true,
      body: {
        'nama_label': namaLabel.trim(),
        'kode_warna': kodeWarna ?? '#E3DDD0',
      },
    );

    return LabelModel.fromJson(
      Map<String, dynamic>.from(response['data']),
    );
  }

  // Menghapus label.
  Future<void> deleteLabel(int id) async {
    await _apiService.delete(
      '${ApiConfig.labels}/$id',
      withToken: true,
    );
  }
}