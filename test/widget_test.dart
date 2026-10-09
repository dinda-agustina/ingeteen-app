
import 'package:flutter_test/flutter_test.dart';
import 'package:ingeteen_app/main.dart';

void main() {
  test('IngeTeenApp dapat dibuat', () {
    const app = IngeTeenApp();

    expect(app, isA<IngeTeenApp>());
  });
}