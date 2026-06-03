// Smoke test — verifies the app widget tree mounts without throwing.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dgv/app.dart';

void main() {
  testWidgets('App smoke test — renders without crashing', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: DGVApp()));
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
