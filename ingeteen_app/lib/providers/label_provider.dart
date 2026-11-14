import 'package:flutter/foundation.dart';

import '../models/label_model.dart';
import '../services/dummy_data.dart';

class LabelProvider extends ChangeNotifier {
  final List<LabelModel> _labels = [];
  final Set<int> _initializedUserIds = {};

  late int _nextId;

  LabelProvider() {
    final labelIds = DummyData.labels.map((label) => label.id);

    final taskLabelIds = DummyData.tasks
        .map((task) => task.labelId)
        .whereType<int>();

    final allIds = [...labelIds, ...taskLabelIds];

    _nextId = allIds.isEmpty
        ? 1
        : allIds.reduce((a, b) => a > b ? a : b) + 1;
  }

  // Get labels belonging to a user.
  List<LabelModel> getLabelsForUser(int userId) {
    return _labels
        .where((label) => label.userId == userId)
        .toList();
  }

  // Initialize default labels for a user.
  void ensureDefaultLabelsForUser(int userId) {
    if (_initializedUserIds.contains(userId)) return;

    for (final defaultLabel in DummyData.labels) {
      _labels.add(
        LabelModel(
          id: defaultLabel.id,
          userId: userId,
          namaLabel: defaultLabel.namaLabel,
          kodeWarna: defaultLabel.kodeWarna,
        ),
      );
    }

    _initializedUserIds.add(userId);
    notifyListeners();
  }

  // Add a new label.
  bool addLabel({
    required int userId,
    required String labelName,
    String? colorCode,
  }) {
    final trimmedName = labelName.trim();

    if (trimmedName.isEmpty) return false;

    final alreadyExists = _labels.any(
      (label) =>
          label.userId == userId &&
          label.namaLabel.toLowerCase() ==
              trimmedName.toLowerCase(),
    );

    if (alreadyExists) return false;

    _labels.add(
      LabelModel(
        id: _nextId++,
        userId: userId,
        namaLabel: trimmedName,
        kodeWarna: colorCode,
      ),
    );

    notifyListeners();
    return true;
  }

  // Update an existing label.
  bool updateLabel({
    required int userId,
    required int labelId,
    required String labelName,
    String? colorCode,
    bool clearColor = false,
  }) {
    final trimmedName = labelName.trim();

    if (trimmedName.isEmpty) return false;

    final index = _labels.indexWhere(
      (label) =>
          label.id == labelId &&
          label.userId == userId,
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

    _labels[index] = LabelModel(
      id: currentLabel.id,
      userId: currentLabel.userId,
      namaLabel: trimmedName,
      kodeWarna: clearColor
          ? null
          : colorCode ?? currentLabel.kodeWarna,
    );

    notifyListeners();
    return true;
  }

  // Delete a label.
  bool deleteLabel({
    required int userId,
    required int labelId,
  }) {
    final index = _labels.indexWhere(
      (label) =>
          label.id == labelId &&
          label.userId == userId,
    );

    if (index == -1) return false;

    _labels.removeAt(index);

    notifyListeners();
    return true;
  }
}