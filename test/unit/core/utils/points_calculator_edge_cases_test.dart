import 'package:flutter_test/flutter_test.dart';

import 'package:dgv/core/models/bac_reading.dart';
import 'package:dgv/core/utils/points_calculator.dart';

void main() {
  group('PointsCalculator — edge cases', () {
    // ── calculateAverageDistanceFromOptimal ───────────────────────────────────

    group('calculateAverageDistanceFromOptimal', () {
      test('returns infinity for empty readings list', () {
        expect(
          PointsCalculator.calculateAverageDistanceFromOptimal([]),
          equals(double.infinity),
        );
      });

      test('returns zero when every reading is exactly at optimal', () {
        final readings = [
          BACReading(
            id: 'r1',
            playerId: 'p1',
            bac: 0.111,
            timestamp: DateTime.now(),
            roundNumber: 1,
            entryMethod: BACEntryMethod.manual,
            optimalBAC: 0.111,
          ),
          BACReading(
            id: 'r2',
            playerId: 'p1',
            bac: 0.223,
            timestamp: DateTime.now(),
            roundNumber: 2,
            entryMethod: BACEntryMethod.manual,
            optimalBAC: 0.223,
          ),
        ];
        expect(
          PointsCalculator.calculateAverageDistanceFromOptimal(readings),
          closeTo(0.0, 0.0001),
        );
      });

      test('returns correct average for symmetric readings', () {
        // Distance R1: |0.611 - 0.111| = 0.5, Distance R2: |0.723 - 0.223| = 0.5
        final readings = [
          BACReading(
            id: 'r1',
            playerId: 'p1',
            bac: 0.611,
            timestamp: DateTime.now(),
            roundNumber: 1,
            entryMethod: BACEntryMethod.manual,
            optimalBAC: 0.111,
          ),
          BACReading(
            id: 'r2',
            playerId: 'p1',
            bac: 0.723,
            timestamp: DateTime.now(),
            roundNumber: 2,
            entryMethod: BACEntryMethod.manual,
            optimalBAC: 0.223,
          ),
        ];
        expect(
          PointsCalculator.calculateAverageDistanceFromOptimal(readings),
          closeTo(0.5, 0.0001),
        );
      });
    });

    // ── calculateTotalPoints — at exact boundaries ────────────────────────────

    group('calculateTotalPoints boundary', () {
      test('returns 15 when exactly at max', () {
        expect(PointsCalculator.calculateTotalPoints(15, 0), equals(15));
      });

      test('returns 0 when exactly at min', () {
        expect(PointsCalculator.calculateTotalPoints(0, 0), equals(0));
      });

      test('applies large negative change and still clamps', () {
        expect(PointsCalculator.calculateTotalPoints(15, -100), equals(0));
      });

      test('applies large positive change and still clamps', () {
        expect(PointsCalculator.calculateTotalPoints(0, 100), equals(15));
      });
    });

    // ── shouldIssueFine — at exact threshold ──────────────────────────────────

    test('shouldIssueFine at -4 is true', () {
      expect(PointsCalculator.shouldIssueFine(-4), isTrue);
    });

    test('shouldIssueFine just above -4 is false', () {
      expect(PointsCalculator.shouldIssueFine(-3), isFalse);
    });

    // ── getFeedbackColor is consistent with message ───────────────────────────

    test('green color corresponds to in-zone message', () {
      final color = PointsCalculator.getFeedbackColor(2);
      final msg = PointsCalculator.getFeedbackMessage(2);
      expect(color, equals(FeedbackColor.green));
      expect(msg, contains('zona'));
    });

    test('red color corresponds to fine message', () {
      final color = PointsCalculator.getFeedbackColor(-4);
      final msg = PointsCalculator.getFeedbackMessage(-4);
      expect(color, equals(FeedbackColor.red));
      expect(msg, contains('Multa'));
    });

    // ── Points change covers all zones ────────────────────────────────────────

    test('calculatePointsChange returns expected value for each zone', () {
      // optimal=0.5: boundaries for round 3+ at 15/25/50/90% = 0.075/0.125/0.25/0.45
      const optimal = 0.5;
      const roundNumber = 3;

      // Sweet spot: +2
      expect(
        PointsCalculator.calculatePointsChange(
          currentBAC: 0.5,
          optimalBAC: optimal,
          roundNumber: roundNumber,
        ),
        equals(2),
      );

      // Close: +1 (0.5 * 1.20 = 0.60, within 25%)
      expect(
        PointsCalculator.calculatePointsChange(
          currentBAC: 0.60,
          optimalBAC: optimal,
          roundNumber: roundNumber,
        ),
        equals(1),
      );

      // Fine: -4 (0.5 * 1.95 = 0.975, >90% above)
      expect(
        PointsCalculator.calculatePointsChange(
          currentBAC: 0.975,
          optimalBAC: optimal,
          roundNumber: roundNumber,
        ),
        equals(-4),
      );

      // Very far below: -2 (0.5 * 0.04 = 0.02, >90% below)
      expect(
        PointsCalculator.calculatePointsChange(
          currentBAC: 0.02,
          optimalBAC: optimal,
          roundNumber: roundNumber,
        ),
        equals(-2),
      );

      // Far: -1 (0.5 * 1.70 = 0.85, 50-90% above)
      expect(
        PointsCalculator.calculatePointsChange(
          currentBAC: 0.85,
          optimalBAC: optimal,
          roundNumber: roundNumber,
        ),
        equals(-1),
      );
    });
  });
}
