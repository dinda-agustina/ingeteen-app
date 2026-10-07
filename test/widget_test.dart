import 'package:flutter_test/flutter_test.dart';
import 'package:ingeteen_app/main.dart';

void main() {
  testWidgets('IngeTeen app tampil dengan benar', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskManagerApp());

    expect(find.text('Tugas'), findsOneWidget);
    expect(find.text('PENDING'), findsOneWidget);
    expect(find.text('COMPLETED'), findsOneWidget);
  });
}