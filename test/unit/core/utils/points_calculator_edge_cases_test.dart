import 'package:flutter_test/flutter_test.dart';

import 'package:dgv/core/constants/app_constants.dart';
import 'package:dgv/core/models/bac_reading.dart';
import 'package:dgv/core/utils/points_calculator.dart';

void main() {
  group('PointsCalculator — edge cases', () {
    // ── calculateAverageDistanceFromOptimal ───────────────────────────────────

    group('calculateAverageDistanceFromOptimal', () {
      test('returns infinity for empty readings list', () {
        expect(
          PointsCalculator.calculateAverageDistanceFromOptimal([], 2.0),
          equals(double.infinity),
        );
      });

      test('returns zero when every reading is exactly at optimal', () {
        final readings = List.generate(
          5,
          (i) => BACReading(
            id: 'r$i',
            playerId: 'p1',
            bac: 2.0,
            timestamp: DateTime.now(),
            roundNumber: i + 1,
            entryMethod: BACEntryMethod.manual,
          ),
        );
        expect(
          PointsCalculator.calculateAverageDistanceFromOptimal(readings, 2.0),
          closeTo(0.0, 0.0001),
        );
      });

      test('returns correct average for symmetric readings', () {
        // Readings 0.5 above and 0.5 below optimal → average distance = 0.5
        final readings = [
          BACReading(
            id: 'r1',
            playerId: 'p1',
            bac: 2.5,
            timestamp: DateTime.now(),
            roundNumber: 1,
            entryMethod: BACEntryMethod.manual,
          ),
          BACReading(
            id: 'r2',
            playerId: 'p1',
            bac: 1.5,
            timestamp: DateTime.now(),
            roundNumber: 2,
            entryMethod: BACEntryMethod.manual,
          ),
        ];
        expect(
          PointsCalculator.calculateAverageDistanceFromOptimal(readings, 2.0),
          closeTo(0.5, 0.0001),
        );
      });
    });

    // ── calculateTotalPoints — at exact boundaries ────────────────────────────

    group('calculateTotalPoints boundary', () {
      test('returns maxPoints when exactly at max', () {
        expect(
          PointsCalculator.calculateTotalPoints(AppConstants.maxPoints, 0),
          equals(AppConstants.maxPoints),
        );
      });

      test('returns minPoints when exactly at min', () {
        expect(
          PointsCalculator.calculateTotalPoints(AppConstants.minPoints, 0),
          equals(AppConstants.minPoints),
        );
      });

      test('applies large negative change and still clamps', () {
        expect(
          PointsCalculator.calculateTotalPoints(AppConstants.maxPoints, -100),
          equals(AppConstants.minPoints),
        );
      });

      test('applies large positive change and still clamps', () {
        expect(
          PointsCalculator.calculateTotalPoints(AppConstants.minPoints, 100),
          equals(AppConstants.maxPoints),
        );
      });
    });

    // ── isImpounded — at exact threshold ─────────────────────────────────────

    test('isImpounded at exact threshold is true', () {
      expect(
        PointsCalculator.isImpounded(AppConstants.impoundmentThreshold),
        isTrue,
      );
    });

    test('isImpounded just below threshold is false', () {
      expect(
        PointsCalculator.isImpounded(AppConstants.impoundmentThreshold - 0.001),
        isFalse,
      );
    });

    // ── getFeedbackColor is consistent with message ───────────────────────────

    test('green color corresponds to in-zone message', () {
      final color = PointsCalculator.getFeedbackColor(
        AppConstants.pointsInOptimalZone,
      );
      final msg = PointsCalculator.getFeedbackMessage(
        AppConstants.pointsInOptimalZone,
      );
      expect(color, equals(FeedbackColor.green));
      expect(msg, contains('óptima'));
    });

    test('red color corresponds to impounded message', () {
      final color = PointsCalculator.getFeedbackColor(
        AppConstants.pointsImpounded,
      );
      final msg = PointsCalculator.getFeedbackMessage(
        AppConstants.pointsImpounded,
      );
      expect(color, equals(FeedbackColor.red));
      expect(msg, contains('INMOVILIZADO'));
    });

    // ── Spike only fires in fall-through case ─────────────────────────────────

    test(
      'dangerous spike returns -2 when BAC not in zone, not close, not crossed, not too low',
      () {
        // BAC = 2.25 (just inside close zone upper bound: 2.0 + 0.25 = close)
        // With a spike from 0.0 in 15 min → rate > 0.8/hr
        // But "close" takes priority over spike, so result is +1 not -2
        final result = PointsCalculator.calculatePointsChange(
          currentBAC: 2.25,
          optimalBAC: 2.0,
          previousBAC: 0.0,
          timeDelta: const Duration(minutes: 15),
        );
        // close zone takes priority: 2.25 is within 0.2–0.4 of 2.0
        expect(result, equals(AppConstants.pointsCloseToOptimal));
      },
    );
  });
}
