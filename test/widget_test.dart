// Basic smoke test for YogaAI app.
import 'package:flutter_test/flutter_test.dart';
import 'package:yoga_ai/app.dart';

void main() {
  testWidgets('App smoke test — widget tree builds', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    // Just verify the widget tree builds without throwing.
    expect(find.byType(App), findsOneWidget);
  });
}
