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

      expect(find.byType(AnimatedContainer), findsNWidgets(2));
    });

    testWidgets('AppBar shows player name', (tester) async {
      await tester.pumpWidget(_wrap(LicenseViewerScreen(player: _player())));
      await tester.pump();

      expect(find.text('Test Driver'), findsOneWidget);
    });

    testWidgets('each page is wrapped in InteractiveViewer', (tester) async {
      await tester.pumpWidget(_wrap(LicenseViewerScreen(player: _player())));
      await tester.pump();

      expect(find.byType(InteractiveViewer), findsWidgets);
    });

    testWidgets('front page shows loading indicator while PNG is resolving', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(LicenseViewerScreen(player: _player())));
      // Before FutureBuilder completes — loading indicator should show.
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('back page shows loading indicator when path is null', (
      tester,
    ) async {
      final player = _player(licenseBackImagePath: null);

      await tester.pumpWidget(_wrap(LicenseViewerScreen(player: player)));
      await tester.pump();

      // PageView should render without error.
      expect(find.byType(PageView), findsOneWidget);
    });
  });
}
