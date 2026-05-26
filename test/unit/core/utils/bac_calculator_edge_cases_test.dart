import 'package:flutter_test/flutter_test.dart';

import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/core/utils/bac_calculator.dart';

void main() {
  group('BACCalculator — edge cases', () {
    // ── calculateOptimalBrAC covers all BodySize values ──────────────────────

    test('calculateOptimalBrAC returns distinct values for each body size', () {
      final small = BACCalculator.calculateOptimalBrAC(
        1,
        Sex.male,
        BodySize.small,
      );
      final medium = BACCalculator.calculateOptimalBrAC(
        1,
        Sex.male,
        BodySize.medium,
      );
      final large = BACCalculator.calculateOptimalBrAC(
        1,
        Sex.male,
        BodySize.large,
      );

      expect(small, isNot(equals(medium)));
      expect(medium, isNot(equals(large)));
      expect(small, isNot(equals(large)));
    });

    test(
      'optimal BAC rises early and can decline once elimination dominates',
      () {
        final round1 = BACCalculator.calculateOptimalBrAC(
          1,
          Sex.male,
          BodySize.medium,
        );
        final round5 = BACCalculator.calculateOptimalBrAC(
          5,
          Sex.male,
          BodySize.medium,
        );
        final round10 = BACCalculator.calculateOptimalBrAC(
          10,
          Sex.male,
          BodySize.medium,
        );

        expect(round5, greaterThan(round1));
        expect(round10, lessThan(round5));
      },
    );

    // ── isInOptimalZone — proportional boundary ──────────────────────────────

    test(
      'isInOptimalZone returns true just inside +10% boundary (all rounds)',
      () {
        // optimal=0.4: +10% threshold = 0.44; test 0.439
        const optimal = 0.4;
        const roundNumber = 3;
        expect(
          BACCalculator.isInOptimalZone(
            optimal * 1.10 - 0.001,
            optimal,
            roundNumber: roundNumber,
          ),
          isTrue,
        );
      },
    );

    test(
      'isInOptimalZone returns false just outside +10% boundary (all rounds)',
      () {
        // optimal=0.4: +10% threshold = 0.44; test 0.441
        const optimal = 0.4;
        const roundNumber = 3;
        expect(
          BACCalculator.isInOptimalZone(
            optimal * 1.10 + 0.001,
            optimal,
            roundNumber: roundNumber,
          ),
          isFalse,
        );
      },
    );

    // ── Zero BAC ─────────────────────────────────────────────────────────────

    test('zero BAC is never in optimal zone for active rounds', () {
      for (final size in BodySize.values) {
        final round5Optimal = BACCalculator.calculateOptimalBrAC(
          5,
          Sex.male,
          size,
        );
        expect(
          BACCalculator.isInOptimalZone(0.0, round5Optimal, roundNumber: 5),
          isFalse,
        );
      }
    });

    // ── Extreme BAC ──────────────────────────────────────────────────────────

    test('extreme high BAC (10.0) always crosses optimal line', () {
      for (final size in BodySize.values) {
        final optimal = BACCalculator.calculateOptimalBrAC(1, Sex.male, size);
        expect(
          BACCalculator.crossedOptimalLine(10.0, optimal, roundNumber: 1),
          isTrue,
        );
        expect(
          BACCalculator.isInOptimalZone(10.0, optimal, roundNumber: 1),
          isFalse,
        );
        expect(
          BACCalculator.isCloseToOptimal(10.0, optimal, roundNumber: 1),
          isFalse,
        );
      }
    });
  });
}
