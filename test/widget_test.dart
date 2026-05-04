// This is a basic test file to satisfy the pre-push hook
// Add your actual tests here as you develop features

import 'package:flutter_test/flutter_test.dart';
import 'package:dgv/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MainApp());

    // Verify that the app builds without crashing
    expect(find.text('Hello World!'), findsOneWidget);
  });
}
