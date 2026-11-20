import 'package:flutter/foundation.dart';

import '../models/label_model.dart';
import '../services/label_service.dart';

class LabelProvider extends ChangeNotifier {
  final LabelService _labelService;

  final List<LabelModel> _labels = [];

  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _errorMessage;

  int _requestVersion = 0;

  LabelProvider({LabelService? labelService})
      : _labelService = labelService ?? LabelService();

  // Status loading.
  bool get isLoading => _isLoading;

  // Pesan error.
  String? get errorMessage => _errorMessage;

  // Mengambil label milik user.
  List<LabelModel> getLabelsForUser(int userId) {
    return _labels
        .where((label) => label.userId == userId)
        .toList();
  }

  // READ: Mengambil label dari API.
  Future<void> loadLabels({bool forceRefresh = false}) async {
    if (_isLoading) return;
    if (_hasLoaded && !forceRefresh) return;

    final currentVersion = _requestVersion;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final loadedLabels = await _labelService.getLabels();

      if (currentVersion != _requestVersion) return;

      _labels
        ..clear()
        ..addAll(loadedLabels);

      _hasLoaded = true;
    } catch (error) {
      if (currentVersion == _requestVersion) {
        _errorMessage = error.toString();
      }
    } finally {
      if (currentVersion == _requestVersion) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  // CREATE: Membuat label melalui API.
  Future<bool> addLabel({
    required int userId,
    required String labelName,
    String? colorCode,
  }) async {
    final trimmedName = labelName.trim();

    if (trimmedName.isEmpty) return false;

    final alreadyExists = _labels.any(
      (label) =>
          label.userId == userId &&
          label.namaLabel.toLowerCase() ==
              trimmedName.toLowerCase(),
    );

    if (alreadyExists) return false;

    final newLabel = await _labelService.createLabel(
      namaLabel: trimmedName,
      kodeWarna: colorCode,
    );

    if (newLabel.userId != userId) {
      throw StateError('Label owner does not match the logged-in user.');
    }

    _labels.add(newLabel);

    notifyListeners();
    return true;
  }

  // UPDATE: Memperbarui label melalui API.
  Future<bool> updateLabel({
    required int userId,
    required int labelId,
    required String labelName,
    String? colorCode,
    bool clearColor = false,
  }) async {
    final trimmedName = labelName.trim();

    if (trimmedName.isEmpty) return false;

    final index = _labels.indexWhere(
      (label) => label.id == labelId && label.userId == userId,
    );

    if (index == -1) return false;

    final alreadyExists = _labels.any(
      (label) =>
          label.userId == userId &&
          label.id != labelId &&
          label.namaLabel.toLowerCase() ==
              trimmedName.toLowerCase(),
    );

    if (alreadyExists) return false;

    final currentLabel = _labels[index];

    final selectedColor = clearColor
        ? '#E3DDD0'
        : colorCode ?? currentLabel.kodeWarna ?? '#E3DDD0';

    final updatedLabel = await _labelService.updateLabel(
      id: labelId,
      namaLabel: trimmedName,
      kodeWarna: selectedColor,
    );

    if (updatedLabel.userId != userId) {
      throw StateError('Label owner does not match the logged-in user.');
    }

    _labels[index] = updatedLabel;

    notifyListeners();
    return true;
  }

  // DELETE: Menghapus label melalui API.
  Future<bool> deleteLabel({
    required int userId,
    required int labelId,
  }) async {
    final index = _labels.indexWhere(
      (label) => label.id == labelId && label.userId == userId,
    );

    if (index == -1) return false;

    await _labelService.deleteLabel(labelId);

    _labels.removeAt(index);

    notifyListeners();
    return true;
  }

  // Membersihkan label saat logout.
  void clearLabels() {
    _requestVersion++;

    _labels.clear();
    _isLoading = false;
    _hasLoaded = false;
    _errorMessage = null;

    notifyListeners();
  }
}