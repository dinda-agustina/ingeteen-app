import 'package:flutter_test/flutter_test.dart';
import 'package:ingeteen_app/models/task_model.dart';
import 'package:ingeteen_app/services/dummy_data.dart';

void main() {
  test('Level deadline dihitung dengan benar', () {
    final urgent = DummyData.tasks.firstWhere((t) => t.id == 1);
    final safe = DummyData.tasks.firstWhere((t) => t.id == 3);

    expect(urgent.deadlineLevel, DeadlineLevel.urgent);
    expect(safe.deadlineLevel, DeadlineLevel.safe);
  });

  test('Dummy data punya tugas pending dan completed', () {
    expect(DummyData.tasks.any((t) => t.isCompleted), isTrue);
    expect(DummyData.tasks.any((t) => !t.isCompleted), isTrue);
  });
}