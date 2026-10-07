import 'package:flutter_test/flutter_test.dart';
import 'package:ingeteen_app/main.dart';

void main() {
  testWidgets('IngeTeen app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const IngeTeenApp());

    expect(find.text('Tugas'), findsOneWidget);
    expect(find.text('PENDING'), findsOneWidget);
    expect(find.text('COMPLETED'), findsOneWidget);
  });
}