import 'package:flutter_test/flutter_test.dart';

import 'package:dgv/core/constants/app_constants.dart';
import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/core/utils/bac_calculator.dart';

void main() {
  group('BACCalculator — edge cases', () {
    // ── calculateOptimalBAC covers all BodySize values ────────────────────────

    test('calculateOptimalBAC returns distinct values for each body size', () {
      final small = BACCalculator.calculateOptimalBAC(BodySize.small);
      final medium = BACCalculator.calculateOptimalBAC(BodySize.medium);
      final large = BACCalculator.calculateOptimalBAC(BodySize.large);

      expect(small, isNot(equals(medium)));
      expect(medium, isNot(equals(large)));
      expect(small, isNot(equals(large)));
    });

    test('optimal BAC is ordered: small > medium > large', () {
      final small = BACCalculator.calculateOptimalBAC(BodySize.small);
      final medium = BACCalculator.calculateOptimalBAC(BodySize.medium);
      final large = BACCalculator.calculateOptimalBAC(BodySize.large);

      expect(small, greaterThan(medium));
      expect(medium, greaterThan(large));
    });

    // ── isInOptimalZone — just inside vs just outside tolerance ──────────────

    test('isInOptimalZone returns true just inside +toleranceClose', () {
      const optimal = 2.0;
      expect(
        BACCalculator.isInOptimalZone(
          optimal + AppConstants.optimalToleranceClose - 0.001,
          optimal,
        ),
        isTrue,
      );
    });

    test('isInOptimalZone returns false just outside +toleranceClose', () {
      const optimal = 2.0;
      expect(
        BACCalculator.isInOptimalZone(
          optimal + AppConstants.optimalToleranceClose + 0.001,
          optimal,
        ),
        isFalse,
      );
    });

    // ── Zero BAC ─────────────────────────────────────────────────────────────

    test('zero BAC is never in optimal zone for any body size', () {
      for (final size in BodySize.values) {
        final optimal = BACCalculator.calculateOptimalBAC(size);
        expect(BACCalculator.isInOptimalZone(0.0, optimal), isFalse);
        expect(BACCalculator.isTooLow(0.0, optimal), isTrue);
      }
    });

    // ── Extreme BAC ──────────────────────────────────────────────────────────

    test('extreme high BAC (10.0) always crosses optimal line', () {
      for (final size in BodySize.values) {
        final optimal = BACCalculator.calculateOptimalBAC(size);
        expect(BACCalculator.crossedOptimalLine(10.0, optimal), isTrue);
        expect(BACCalculator.isInOptimalZone(10.0, optimal), isFalse);
        expect(BACCalculator.isCloseToOptimal(10.0, optimal), isFalse);
      }
    });

    // ── calculateBAC via Widmark formula ─────────────────────────────────────

    test(
      'calculateBAC returns higher value for women than men of same size',
      () {
        const gramsAlcohol = 50.0;
        final maleBac = BACCalculator.calculateBAC(
          alcoholGrams: gramsAlcohol,
          sex: Sex.male,
          bodySize: BodySize.medium,
        );
        final femaleBac = BACCalculator.calculateBAC(
          alcoholGrams: gramsAlcohol,
          sex: Sex.female,
          bodySize: BodySize.medium,
        );
        expect(femaleBac, greaterThan(maleBac));
      },
    );

    test('calculateBAC increases proportionally with alcohol consumed', () {
      final bac1 = BACCalculator.calculateBAC(
        alcoholGrams: 13.0,
        sex: Sex.male,
        bodySize: BodySize.medium,
      );
      final bac2 = BACCalculator.calculateBAC(
        alcoholGrams: 26.0,
        sex: Sex.male,
        bodySize: BodySize.medium,
      );
      expect(bac2, closeTo(bac1 * 2, 0.0001));
    });

    // ── calculateBACRatePerHour — very short intervals ────────────────────────

    test('calculates rate correctly for a 1-minute interval', () {
      // delta = 0.1 mg/L in 1 min → 6.0 mg/L/hr
      final rate = BACCalculator.calculateBACRatePerHour(
        2.1,
        2.0,
        const Duration(minutes: 1),
      );
      expect(rate, closeTo(6.0, 0.01));
    });

    // ── isDangerousSpike — exactly at threshold ───────────────────────────────

    test(
      'isDangerousSpike returns false when rate exactly equals threshold',
      () {
        // 0.8 mg/L in 60 min = 0.8 mg/L/hr — NOT strictly greater than threshold
        expect(
          BACCalculator.isDangerousSpike(2.8, 2.0, const Duration(minutes: 60)),
          isFalse,
        );
      },
    );
  });
}
