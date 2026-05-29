import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dgv/core/models/bac_reading.dart';
import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/features/fake_id/presentation/license_viewer_screen.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

PlayerProfile _player({
  String? licenseBackImagePath,
  List<BACReading> readings = const [],
}) {
  return PlayerProfile(
    id: 'p1',
    name: 'Test',
    surname: 'Driver',
    photoPath: '',
    sex: Sex.male,
    bodySize: BodySize.medium,
    points: 12,
    licenseImagePath: '', // empty — no file on disk in tests
    licenseBackImagePath: licenseBackImagePath,
    readings: readings,
  );
}

Widget _wrap(Widget child) {
  return MaterialApp(theme: ThemeData.light(), home: child);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('LicenseViewerScreen', () {
    testWidgets('renders exactly two pages in PageView', (tester) async {
      await tester.pumpWidget(_wrap(LicenseViewerScreen(player: _player())));
      await tester.pump();

      final pageView = tester.widget<PageView>(find.byType(PageView));
      expect(pageView.childrenDelegate.estimatedChildCount, equals(2));
    });

    testWidgets('shows page indicator with two dots', (tester) async {
      await tester.pumpWidget(_wrap(LicenseViewerScreen(player: _player())));
      await tester.pump();

      // Two AnimatedContainers are used as dots.
      expect(find.byType(AnimatedContainer), findsNWidgets(2));
    });

    testWidgets(
      'null licenseBackImagePath shows dynamic fallback without crash',
      (tester) async {
        final player = _player(licenseBackImagePath: null);

        // Should not throw during build
        await tester.pumpWidget(_wrap(LicenseViewerScreen(player: player)));
        await tester.pump();

        // PageView renders without error — no exception thrown
        expect(find.byType(PageView), findsOneWidget);
      },
    );

    testWidgets('dynamic back widget shows when licenseBackImagePath is null', (
      tester,
    ) async {
      final player = _player(licenseBackImagePath: null);

      await tester.pumpWidget(_wrap(LicenseViewerScreen(player: player)));
      await tester.pump();

      // Navigate to page 2 via the PageController by scrolling
      final pageView = tester.widget<PageView>(find.byType(PageView));
      pageView.controller?.animateToPage(
        1,
        duration: const Duration(milliseconds: 1),
        curve: Curves.linear,
      );
      await tester.pumpAndSettle();

      expect(find.text('HISTORIAL DE MEDICIONES'), findsOneWidget);
    });

    testWidgets('dynamic back widget shows readings when present', (
      tester,
    ) async {
      final player = _player(
        licenseBackImagePath: null,
        readings: [
          BACReading(
            id: 'r1',
            playerId: 'p1',
            bac: 0.33,
            timestamp: DateTime(2026),
            roundNumber: 1,
            entryMethod: BACEntryMethod.manual,
            pointsChange: 2,
          ),
        ],
      );

      await tester.pumpWidget(_wrap(LicenseViewerScreen(player: player)));
      await tester.pump();

      // Navigate to page 2
      final pageView = tester.widget<PageView>(find.byType(PageView));
      pageView.controller?.animateToPage(
        1,
        duration: const Duration(milliseconds: 1),
        curve: Curves.linear,
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('R1: 0.33 mg/L'), findsOneWidget);
    });

    testWidgets('each page is wrapped in InteractiveViewer', (tester) async {
      await tester.pumpWidget(_wrap(LicenseViewerScreen(player: _player())));
      await tester.pump();

      expect(find.byType(InteractiveViewer), findsWidgets);
    });

    testWidgets('AppBar shows player name', (tester) async {
      await tester.pumpWidget(_wrap(LicenseViewerScreen(player: _player())));
      await tester.pump();

      expect(find.text('Test Driver'), findsOneWidget);
    });
  });
}
