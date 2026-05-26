import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:dgv/core/models/bac_reading.dart';
import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/core/utils/points_calculator.dart';

void main() {
  group('PointsCalculator', () {
    // ── calculatePointsChange ────────────────────────────────────────────────

    group('calculatePointsChange', () {
      // optimal=0.5: proportional zone boundaries for rounds 3+:
      // +2 sweet spot : within 15% = [0.425, 0.575]
      // +1 close      : within 25% = [0.375, 0.625]
      //  0 neutral    : within 50% = [0.25, 0.75]
      // -1 far        : within 90% = [0.05, 0.95]
      // -2 very far   : >90% below (<0.05)
      // -4 fine       : >90% above (>0.95)
      const optimal = 0.5;
      const roundNumber = 3; // Use round 3+ thresholds

      test('returns +2 when BAC is in sweet spot (within 15%)', () {
        expect(
          PointsCalculator.calculatePointsChange(
            currentBAC: 0.5,
            optimalBAC: optimal,
            roundNumber: roundNumber,
          ),
          equals(2),
        );
      });

      test('returns +1 when BAC is close (15-25%)', () {
        // 0.5 * 1.20 = 0.60
        expect(
          PointsCalculator.calculatePointsChange(
            currentBAC: 0.60,
            optimalBAC: optimal,
            roundNumber: roundNumber,
          ),
          equals(1),
        );
      });

      test('returns 0 for neutral zone (25-50%)', () {
        // 0.5 * 1.35 = 0.675
        expect(
          PointsCalculator.calculatePointsChange(
            currentBAC: 0.675,
            optimalBAC: optimal,
            roundNumber: roundNumber,
          ),
          equals(0),
        );
      });

      test('returns -1 when BAC is far (50-90%)', () {
        // 0.5 * 1.70 = 0.85
        expect(
          PointsCalculator.calculatePointsChange(
            currentBAC: 0.85,
            optimalBAC: optimal,
            roundNumber: roundNumber,
          ),
          equals(-1),
        );
      });

      test('returns -4 (fine) when BAC crosses line (>90% above)', () {
        // 0.5 * 1.95 = 0.975
        expect(
          PointsCalculator.calculatePointsChange(
            currentBAC: 0.975,
            optimalBAC: optimal,
            roundNumber: roundNumber,
          ),
          equals(-4),
        );
      });

      test('returns -2 when BAC is way below optimal (>90% below)', () {
        // 0.5 * 0.04 = 0.02
        expect(
          PointsCalculator.calculatePointsChange(
            currentBAC: 0.02,
            optimalBAC: optimal,
            roundNumber: roundNumber,
          ),
          equals(-2),
        );
      });

      test('real scenario: 0.35 at optimal 0.127 round 1 triggers fine (-4)', () {
        // 0.35 is ~175% above 0.127 — way over the fine threshold even for round 1
        expect(
          PointsCalculator.calculatePointsChange(
            currentBAC: 0.35,
            optimalBAC: 0.127,
            roundNumber: 1,
          ),
          equals(-4),
        );
      });
    });

    // ── shouldIssueFine ──────────────────────────────────────────────────────

    group('shouldIssueFine', () {
      test('returns true when points change is -4', () {
        expect(PointsCalculator.shouldIssueFine(-4), isTrue);
      });

      test('returns true when points change is less than -4', () {
        expect(PointsCalculator.shouldIssueFine(-5), isTrue);
      });

      test('returns false when points change is greater than -4', () {
        expect(PointsCalculator.shouldIssueFine(-3), isFalse);
        expect(PointsCalculator.shouldIssueFine(0), isFalse);
        expect(PointsCalculator.shouldIssueFine(2), isFalse);
      });
    });

    // ── calculateTotalPoints ─────────────────────────────────────────────────

    group('calculateTotalPoints', () {
      test('clamps to 15 when result would exceed maximum', () {
        expect(PointsCalculator.calculateTotalPoints(14, 5), equals(15));
      });

      test('clamps to 0 when result would go negative', () {
        expect(PointsCalculator.calculateTotalPoints(1, -5), equals(0));
      });

      test('returns exact sum when within bounds', () {
        expect(PointsCalculator.calculateTotalPoints(10, 2), equals(12));
      });

      test('calculateTotalPoints(14, 2) == 15', () {
        expect(PointsCalculator.calculateTotalPoints(14, 2), equals(15));
      });

      test('calculateTotalPoints(1, -5) == 0', () {
        expect(PointsCalculator.calculateTotalPoints(1, -5), equals(0));
      });
    });

    // ── calculateAverageDistanceFromOptimal ──────────────────────────────────

    group('calculateAverageDistanceFromOptimal', () {
      test('returns infinity for empty readings list', () {
        expect(
          PointsCalculator.calculateAverageDistanceFromOptimal(
            [],
            Sex.male,
            BodySize.medium,
          ),
          equals(double.infinity),
        );
      });

      test('calculates average distance correctly', () {
        // Round 1 optimal male medium = 0.111, reading 0.611 -> distance 0.5
        // Round 2 optimal male medium = 0.223, reading 0.723 -> distance 0.5
        final readings = [
          BACReading(
            id: 'r1',
            playerId: 'p1',
            bac: 0.611,
            timestamp: DateTime.now(),
            roundNumber: 1,
            entryMethod: BACEntryMethod.manual,
          ),
          BACReading(
            id: 'r2',
            playerId: 'p1',
            bac: 0.723,
            timestamp: DateTime.now(),
            roundNumber: 2,
            entryMethod: BACEntryMethod.manual,
          ),
        ];
        // M-M Round 1 optimal: 0.111, Round 2 optimal: 0.223
        // Distance R1: |0.611 - 0.111| = 0.500
        // Distance R2: |0.723 - 0.223| = 0.500
        // Average: 0.500
        expect(
          PointsCalculator.calculateAverageDistanceFromOptimal(
            readings,
            Sex.male,
            BodySize.medium,
          ),
          closeTo(0.5, 0.0001),
        );
      });
    });

    // ── getFeedbackMessage ───────────────────────────────────────────────────

    group('getFeedbackMessage', () {
      test('returns in-zone message for +2', () {
        final msg = PointsCalculator.getFeedbackMessage(2);
        expect(msg, isNotEmpty);
        expect(msg, contains('zona'));
      });

      test('returns close message for +1', () {
        final msg = PointsCalculator.getFeedbackMessage(1);
        expect(msg, isNotEmpty);
        expect(msg, contains('Cerca'));
      });

      test('returns fine message for -4', () {
        final msg = PointsCalculator.getFeedbackMessage(-4);
        expect(msg, isNotEmpty);
        expect(msg, contains('Multa'));
      });

      test('returns too-low message for -2', () {
        final msg = PointsCalculator.getFeedbackMessage(-2);
        expect(msg, isNotEmpty);
        expect(msg, contains('Policía'));
      });

      test('returns no-change message for 0', () {
        final msg = PointsCalculator.getFeedbackMessage(0);
        expect(msg, isNotEmpty);
      });

      test('returns message for -1 (far zone)', () {
        final msg = PointsCalculator.getFeedbackMessage(-1);
        expect(msg, isNotEmpty);
      });
    });

    // ── getFeedbackColor ─────────────────────────────────────────────────────

    group('getFeedbackColor', () {
      test('returns green for +2', () {
        expect(
          PointsCalculator.getFeedbackColor(2),
          equals(FeedbackColor.green),
        );
      });

      test('returns yellow for +1', () {
        expect(
          PointsCalculator.getFeedbackColor(1),
          equals(FeedbackColor.yellow),
        );
      });

      test('returns red for -4', () {
        expect(
          PointsCalculator.getFeedbackColor(-4),
          equals(FeedbackColor.red),
        );
      });

      test('returns blue for -2', () {
        expect(
          PointsCalculator.getFeedbackColor(-2),
          equals(FeedbackColor.blue),
        );
      });

      test('returns neutral for 0', () {
        expect(
          PointsCalculator.getFeedbackColor(0),
          equals(FeedbackColor.neutral),
        );
      });

      test('returns orange for -1', () {
        expect(
          PointsCalculator.getFeedbackColor(-1),
          equals(FeedbackColor.orange),
        );
      });
    });

    // ── Property: Total points always clamped ────────────────────────────────

    group('Property: total points are always clamped', () {
      test('result is always in [0, 15]', () {
        final rng = Random(42);
        for (var i = 0; i < 200; i++) {
          final current = rng.nextInt(16); // [0, 15]
          final change = rng.nextInt(21) - 10; // [-10, 10]

          final result = PointsCalculator.calculateTotalPoints(current, change);

          expect(result, greaterThanOrEqualTo(0));
          expect(result, lessThanOrEqualTo(15));
        }
      });
    });

    // ── Property: Feedback determinism ────────────────────────────────────────

    group('Property: feedback message and color are deterministic', () {
      test('same input always returns same non-null message and color', () {
        final rng = Random(42);
        for (var i = 0; i < 200; i++) {
          final pointsChange = rng.nextInt(21) - 10; // [-10, 10]

          final msg1 = PointsCalculator.getFeedbackMessage(pointsChange);
          final msg2 = PointsCalculator.getFeedbackMessage(pointsChange);
          final color1 = PointsCalculator.getFeedbackColor(pointsChange);
          final color2 = PointsCalculator.getFeedbackColor(pointsChange);

          expect(msg1, isNotNull);
          expect(msg1, isNotEmpty);
          expect(msg1, equals(msg2));
          expect(color1, equals(color2));
        }
      });
    });
  });
}
