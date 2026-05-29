import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dgv/core/models/bac_reading.dart';
import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/core/theme/dgt_colors.dart';
import 'package:dgv/widgets/last_measurement_widget.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

PlayerProfile _playerWithReadings(List<BACReading> readings) {
  return PlayerProfile(
    id: 'p1',
    name: 'Ana',
    surname: 'López',
    photoPath: '',
    sex: Sex.female,
    bodySize: BodySize.small,
    points: 12,
    licenseImagePath: '',
    readings: readings,
  );
}

BACReading _reading({
  required double bac,
  required int round,
  String id = 'r1',
}) {
  return BACReading(
    id: id,
    playerId: 'p1',
    bac: bac,
    timestamp: DateTime(2026),
    roundNumber: round,
    entryMethod: BACEntryMethod.manual,
  );
}

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: ThemeData.light(),
    home: Scaffold(body: child),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('LastMeasurementWidget', () {
    testWidgets('displays correct text format for a reading', (tester) async {
      final player = _playerWithReadings([_reading(bac: 0.45, round: 3)]);
      await tester.pumpWidget(_wrap(LastMeasurementWidget(player: player)));

      expect(find.text('Último registro: 0.45 mg/L — Ronda 3'), findsOneWidget);
    });

    testWidgets('formats BAC to exactly 2 decimal places', (tester) async {
      final player = _playerWithReadings([_reading(bac: 0.3, round: 2)]);
      await tester.pumpWidget(_wrap(LastMeasurementWidget(player: player)));

      expect(find.text('Último registro: 0.30 mg/L — Ronda 2'), findsOneWidget);
    });

    testWidgets('returns SizedBox.shrink when player has no readings', (
      tester,
    ) async {
      final player = _playerWithReadings([]);
      await tester.pumpWidget(_wrap(LastMeasurementWidget(player: player)));

      expect(find.byType(SizedBox), findsWidgets);
      expect(find.textContaining('Último registro'), findsNothing);
    });

    testWidgets(
      'returns SizedBox.shrink when only baseline (round 0) reading',
      (tester) async {
        final player = _playerWithReadings([_reading(bac: 0.05, round: 0)]);
        await tester.pumpWidget(_wrap(LastMeasurementWidget(player: player)));

        expect(find.textContaining('Último registro'), findsNothing);
      },
    );

    testWidgets('shows the most recent active reading when multiple exist', (
      tester,
    ) async {
      final player = _playerWithReadings([
        _reading(bac: 0.20, round: 1, id: 'r1'),
        _reading(bac: 0.35, round: 2, id: 'r2'),
        _reading(bac: 0.48, round: 3, id: 'r3'),
      ]);
      await tester.pumpWidget(_wrap(LastMeasurementWidget(player: player)));

      // Should show round 3 (last active reading)
      expect(find.text('Último registro: 0.48 mg/L — Ronda 3'), findsOneWidget);
    });

    testWidgets('ignores baseline reading and shows last active reading', (
      tester,
    ) async {
      final player = _playerWithReadings([
        _reading(bac: 0.05, round: 0, id: 'r0'), // baseline — ignored
        _reading(bac: 0.22, round: 1, id: 'r1'),
      ]);
      await tester.pumpWidget(_wrap(LastMeasurementWidget(player: player)));

      expect(find.text('Último registro: 0.22 mg/L — Ronda 1'), findsOneWidget);
    });

    testWidgets('text uses font size ≥ 16sp', (tester) async {
      final player = _playerWithReadings([_reading(bac: 0.45, round: 3)]);
      await tester.pumpWidget(_wrap(LastMeasurementWidget(player: player)));

      final textWidget = tester.widget<Text>(
        find.text('Último registro: 0.45 mg/L — Ronda 3'),
      );
      expect(textWidget.style?.fontSize, greaterThanOrEqualTo(16));
    });

    testWidgets('text uses DGTColors.textSecondary color', (tester) async {
      final player = _playerWithReadings([_reading(bac: 0.45, round: 3)]);
      await tester.pumpWidget(_wrap(LastMeasurementWidget(player: player)));

      final textWidget = tester.widget<Text>(
        find.text('Último registro: 0.45 mg/L — Ronda 3'),
      );
      expect(textWidget.style?.color, equals(DGTColors.textSecondary));
    });
  });
}
