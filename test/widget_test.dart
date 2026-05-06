// This is a basic test file to satisfy the pre-push hook
// Add your actual tests here as you develop features

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dgv/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: DGVApp(),
      ),
    );

    // Verify that the app builds without crashing
    expect(find.text('Operación DGV - Core Infrastructure Ready'), findsOneWidget);
  });
}
