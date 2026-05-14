import 'package:flutter_test/flutter_test.dart';
import 'package:waka/main.dart';

void main() {
  testWidgets('Waka app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const WakaApp());
    expect(find.byType(WakaApp), findsOneWidget);
  });
}
