import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:dgv/core/constants/app_constants.dart';
import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/core/utils/bac_calculator.dart';

void main() {
  group('BACCalculator', () {
    // ── calculateOptimalBAC ──────────────────────────────────────────────────

    group('calculateOptimalBAC', () {
      test('returns 2.5 for small body size', () {
        expect(
          BACCalculator.calculateOptimalBAC(BodySize.small),
          equals(AppConstants.optimalBACSmall),
        );
      });

      test('returns 2.0 for medium body size', () {
        expect(
          BACCalculator.calculateOptimalBAC(BodySize.medium),
          equals(AppConstants.optimalBACMedium),
        );
      });

      test('returns 1.8 for large body size', () {
        expect(
          BACCalculator.calculateOptimalBAC(BodySize.large),
          equals(AppConstants.optimalBACLarge),
        );
      });
    });

    // ── isInOptimalZone ──────────────────────────────────────────────────────

    group('isInOptimalZone', () {
      const optimal = 2.0;

      test('returns true when BAC equals optimal', () {
        expect(BACCalculator.isInOptimalZone(2.0, optimal), isTrue);
      });

      test('returns true when BAC is within +toleranceClose boundary', () {
        // Use a value clearly inside the zone (not at the floating-point boundary)
        expect(
          BACCalculator.isInOptimalZone(
            optimal + AppConstants.optimalToleranceClose - 0.01,
            optimal,
          ),
          isTrue,
        );
      });

      test('returns true when BAC is within -toleranceClose boundary', () {
        expect(
          BACCalculator.isInOptimalZone(
            optimal - AppConstants.optimalToleranceClose + 0.01,
            optimal,
          ),
          isTrue,
        );
      });

      test('returns false when BAC is just above +toleranceClose', () {
        expect(
          BACCalculator.isInOptimalZone(
            optimal + AppConstants.optimalToleranceClose + 0.01,
            optimal,
          ),
          isFalse,
        );
      });

      test('returns false when BAC is just below -toleranceClose', () {
        expect(
          BACCalculator.isInOptimalZone(
            optimal - AppConstants.optimalToleranceClose - 0.01,
            optimal,
          ),
          isFalse,
        );
      });
    });

    // ── isCloseToOptimal ─────────────────────────────────────────────────────

    group('isCloseToOptimal', () {
      const optimal = 2.0;

      test('returns true when BAC is just above +toleranceClose', () {
        expect(
          BACCalculator.isCloseToOptimal(
            optimal + AppConstants.optimalToleranceClose + 0.01,
            optimal,
          ),
          isTrue,
        );
      });

      test('returns true when BAC is within +toleranceFar boundary', () {
        expect(
          BACCalculator.isCloseToOptimal(
            optimal + AppConstants.optimalToleranceFar - 0.01,
            optimal,
          ),
          isTrue,
        );
      });

      test('returns false when BAC is in optimal zone', () {
        expect(BACCalculator.isCloseToOptimal(2.0, optimal), isFalse);
      });

      test('returns false when BAC exceeds +toleranceFar', () {
        expect(
          BACCalculator.isCloseToOptimal(
            optimal + AppConstants.optimalToleranceFar + 0.01,
            optimal,
          ),
          isFalse,
        );
      });
    });

    // ── crossedOptimalLine ───────────────────────────────────────────────────

    group('crossedOptimalLine', () {
      const optimal = 2.0;

      test('returns true when BAC exceeds optimal + toleranceFar', () {
        expect(
          BACCalculator.crossedOptimalLine(
            optimal + AppConstants.optimalToleranceFar + 0.01,
            optimal,
          ),
          isTrue,
        );
      });

      test('returns false when BAC is exactly at +toleranceFar', () {
        expect(
          BACCalculator.crossedOptimalLine(
            optimal + AppConstants.optimalToleranceFar,
            optimal,
          ),
          isFalse,
        );
      });

      test('returns false when BAC is in optimal zone', () {
        expect(BACCalculator.crossedOptimalLine(2.0, optimal), isFalse);
      });
    });

    // ── isTooLow ─────────────────────────────────────────────────────────────

    group('isTooLow', () {
      const optimal = 2.0;

      test('returns true when BAC is below optimal - toleranceFar', () {
        expect(
          BACCalculator.isTooLow(
            optimal - AppConstants.optimalToleranceFar - 0.01,
            optimal,
          ),
          isTrue,
        );
      });

      test('returns false when BAC is exactly at -toleranceFar', () {
        expect(
          BACCalculator.isTooLow(
            optimal - AppConstants.optimalToleranceFar,
            optimal,
          ),
          isFalse,
        );
      });

      test('returns false when BAC is in optimal zone', () {
        expect(BACCalculator.isTooLow(2.0, optimal), isFalse);
      });

      test('returns true for zero BAC with non-zero optimal', () {
        expect(BACCalculator.isTooLow(0.0, 2.0), isTrue);
      });
    });

    // ── calculateBACRatePerHour ──────────────────────────────────────────────

    group('calculateBACRatePerHour', () {
      test('returns 0.0 when time delta is zero minutes', () {
        expect(
          BACCalculator.calculateBACRatePerHour(2.0, 1.0, Duration.zero),
          equals(0.0),
        );
      });

      test('calculates correct rate for positive delta', () {
        // delta = 1.0 mg/L over 60 minutes → 1.0 mg/L per hour
        expect(
          BACCalculator.calculateBACRatePerHour(
            2.0,
            1.0,
            const Duration(minutes: 60),
          ),
          closeTo(1.0, 0.001),
        );
      });

      test('calculates correct rate for negative delta (BAC decreased)', () {
        // delta = -0.5 mg/L over 30 minutes → -1.0 mg/L per hour
        expect(
          BACCalculator.calculateBACRatePerHour(
            1.5,
            2.0,
            const Duration(minutes: 30),
          ),
          closeTo(-1.0, 0.001),
        );
      });

      test('rate is halved when duration doubles', () {
        const current = 2.0;
        const previous = 1.0;
        final rate30 = BACCalculator.calculateBACRatePerHour(
          current,
          previous,
          const Duration(minutes: 30),
        );
        final rate60 = BACCalculator.calculateBACRatePerHour(
          current,
          previous,
          const Duration(minutes: 60),
        );
        expect(rate30, closeTo(rate60 * 2, 0.001));
      });

      test('rate doubles when delta doubles', () {
        final rate1 = BACCalculator.calculateBACRatePerHour(
          2.0,
          1.0,
          const Duration(minutes: 60),
        );
        final rate2 = BACCalculator.calculateBACRatePerHour(
          3.0,
          1.0,
          const Duration(minutes: 60),
        );
        expect(rate2, closeTo(rate1 * 2, 0.001));
      });
    });

    // ── isDangerousSpike ─────────────────────────────────────────────────────

    group('isDangerousSpike', () {
      test('returns true when rate exceeds dangerousSpikeRate', () {
        // 1.0 mg/L in 30 min = 2.0 mg/L/hr > 0.8 threshold
        expect(
          BACCalculator.isDangerousSpike(2.0, 1.0, const Duration(minutes: 30)),
          isTrue,
        );
      });

      test('returns false when rate is below dangerousSpikeRate', () {
        // 0.3 mg/L in 60 min = 0.3 mg/L/hr < 0.8 threshold
        expect(
          BACCalculator.isDangerousSpike(2.3, 2.0, const Duration(minutes: 60)),
          isFalse,
        );
      });

      test('returns false when BAC decreased', () {
        expect(
          BACCalculator.isDangerousSpike(1.5, 2.0, const Duration(minutes: 30)),
          isFalse,
        );
      });
    });

    // ── Property 1: Zone functions are mutually exclusive ────────────────────

    group('Property 1: zone functions are mutually exclusive', () {
      // Feature: phase-1-completion, Property 1: BAC zone functions are mutually exclusive
      test(
        'at most one zone function returns true for any BAC/optimal pair',
        () {
          final rng = Random(42);
          for (var i = 0; i < 200; i++) {
            final bac = rng.nextDouble() * 5.0;
            final optimal = rng.nextDouble() * 3.0 + 0.5;

            final inZone = BACCalculator.isInOptimalZone(bac, optimal);
            final close = BACCalculator.isCloseToOptimal(bac, optimal);
            final crossed = BACCalculator.crossedOptimalLine(bac, optimal);
            final tooLow = BACCalculator.isTooLow(bac, optimal);

            final trueCount = [
              inZone,
              close,
              crossed,
              tooLow,
            ].where((v) => v).length;

            expect(
              trueCount,
              lessThanOrEqualTo(1),
              reason:
                  'bac=$bac, optimal=$optimal: '
                  'inZone=$inZone, close=$close, '
                  'crossed=$crossed, tooLow=$tooLow',
            );
          }
        },
      );
    });

    // ── Property 2: Rate calculation is linear in time ───────────────────────

    group('Property 2: BAC rate calculation is linear in time', () {
      // Feature: phase-1-completion, Property 2: BAC rate calculation is linear in time
      test('rate equals delta / (minutes / 60)', () {
        final rng = Random(42);
        for (var i = 0; i < 200; i++) {
          final delta = (rng.nextDouble() * 4.0) - 2.0; // [-2, 2)
          final minutes = (rng.nextInt(119) + 1); // [1, 120)
          final previous = rng.nextDouble() * 2.0;
          final current = previous + delta;

          final rate = BACCalculator.calculateBACRatePerHour(
            current,
            previous,
            Duration(minutes: minutes),
          );

          final expected = delta / (minutes / 60.0);
          expect(
            rate,
            closeTo(expected, 0.0001),
            reason: 'delta=$delta, minutes=$minutes',
          );
        }
      });
    });
  });
}
