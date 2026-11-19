import 'package:flutter/foundation.dart';

import '../models/label_model.dart';
import '../services/dummy_data.dart';

class LabelProvider extends ChangeNotifier {
  final List<LabelModel> _labels =
      List<LabelModel>.from(DummyData.labels);

  List<LabelModel> get labels =>
      List.unmodifiable(_labels);

  List<LabelModel> labelsForUser(int userId) {
    return _labels
        .where((label) => label.userId == userId)
        .toList();
  }

  void addLabel(LabelModel label) {
    _labels.add(label);
    notifyListeners();
  }

  void updateLabel(LabelModel updatedLabel) {
    final index = _labels.indexWhere(
      (label) => label.id == updatedLabel.id,
    );

    if (index == -1) return;

    _labels[index] = updatedLabel;
    notifyListeners();
  }

  void deleteLabel(int id) {
    _labels.removeWhere((label) => label.id == id);
    notifyListeners();
  }
}