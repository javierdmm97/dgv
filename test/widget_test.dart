// This is a basic test file to satisfy the pre-push hook
// Add your actual tests here as you develop features

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dgv/app.dart';

void main() {
  testWidgets('App smoke test — renders without crashing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: DGVApp()));
    // Before async providers resolve, the main menu shows a loading indicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
