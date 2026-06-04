import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/core/utils/bac_calculator.dart';

void main() {
  group('BACCalculator', () {
    // ── calculateOptimalBrAC ─────────────────────────────────────────────────

    group('calculateOptimalBrAC', () {
      test('returns 0.0 for round 0 (baseline)', () {
        expect(
          BACCalculator.calculateOptimalBrAC(0, Sex.male, BodySize.medium),
          equals(0.0),
        );
      });

      test('returns correct value for round 1 (party mode)', () {
        // Reads directly from the table so the test stays valid when targets change.
        final expected = BACCalculator.optimalTargetAt(
          1,
          Sex.male,
          BodySize.medium,
        );
        expect(
          BACCalculator.calculateOptimalBrAC(1, Sex.male, BodySize.medium),
          equals(expected),
        );
      });

      test('returns correct value for round 5 (party mode)', () {
        // Reads directly from the table so the test stays valid when targets change.
        final expected = BACCalculator.optimalTargetAt(
          5,
          Sex.male,
          BodySize.medium,
        );
        expect(
          BACCalculator.calculateOptimalBrAC(5, Sex.male, BodySize.medium),
          equals(expected),
        );
      });

      test('caps at hour 10 target for later rounds', () {
        // Later rounds stay at the hour-10 value (behavioral test).
        final round10 = BACCalculator.calculateOptimalBrAC(
          10,
          Sex.male,
          BodySize.medium,
        );
        final round15 = BACCalculator.calculateOptimalBrAC(
          15,
          Sex.male,
          BodySize.medium,
        );
        // Structural: any round beyond 10 returns the round-10 value.
        expect(round15, equals(round10));
        // Regression snapshot: update this when the table changes intentionally.
        expect(
          round15,
          equals(BACCalculator.optimalTargetAt(10, Sex.male, BodySize.medium)),
        );
      });

      test('women have higher BrAC targets than men for the same size category', () {
        // Widmark: females have lower body-water ratio (r=0.55 vs 0.68), so the
        // same drink produces a higher BrAC even though they drink at a lower rate.
        final maleValue = BACCalculator.calculateOptimalBrAC(
          5,
          Sex.male,
          BodySize.medium,
        );
        final femaleValue = BACCalculator.calculateOptimalBrAC(
          5,
          Sex.female,
          BodySize.medium,
        );
        expect(femaleValue, greaterThan(maleValue));
      });

      // ── Curve multiplier ─────────────────────────────────────────────────

      test('applies 0.80 multiplier — returns rawTarget × 0.80', () {
        // Validates: Requirements 12.7, 12.8
        final raw = BACCalculator.optimalTargetAt(3, Sex.male, BodySize.medium);
        final result = BACCalculator.calculateOptimalBrAC(
          3,
          Sex.male,
          BodySize.medium,
          curveMultiplier: 0.80,
        );
        expect(result, closeTo(raw! * 0.80, 1e-10));
      });

      test(
        'applies 1.00 multiplier — returns rawTarget × 1.00 (unchanged)',
        () {
          // Validates: Requirements 12.7, 12.8
          final raw = BACCalculator.optimalTargetAt(
            3,
            Sex.male,
            BodySize.medium,
          );
          final result = BACCalculator.calculateOptimalBrAC(
            3,
            Sex.male,
            BodySize.medium,
            curveMultiplier: 1.00,
          );
          expect(result, closeTo(raw! * 1.00, 1e-10));
        },
      );

      test('applies 1.20 multiplier — returns rawTarget × 1.20', () {
        // Validates: Requirements 12.7, 12.8
        final raw = BACCalculator.optimalTargetAt(3, Sex.male, BodySize.medium);
        final result = BACCalculator.calculateOptimalBrAC(
          3,
          Sex.male,
          BodySize.medium,
          curveMultiplier: 1.20,
        );
        expect(result, closeTo(raw! * 1.20, 1e-10));
      });

      test('default multiplier (1.0) matches explicit 1.0 call', () {
        // Validates: Requirements 12.7
        final withDefault = BACCalculator.calculateOptimalBrAC(
          5,
          Sex.female,
          BodySize.large,
        );
        final withExplicit = BACCalculator.calculateOptimalBrAC(
          5,
          Sex.female,
          BodySize.large,
          curveMultiplier: 1.0,
        );
        expect(withDefault, equals(withExplicit));
      });

      test('multiplier does not affect round 0 (always returns 0.0)', () {
        // Validates: Requirements 12.7
        expect(
          BACCalculator.calculateOptimalBrAC(
            0,
            Sex.male,
            BodySize.medium,
            curveMultiplier: 1.20,
          ),
          equals(0.0),
        );
      });
    });

    // ── isInOptimalZone ───────────────────────────────────────────────────────

    group('isInOptimalZone', () {
      const optimal = 0.5;

      group('all rounds (±10% sweet spot)', () {
        const roundNumber = 3;

        test('returns true when BAC equals optimal', () {
          expect(
            BACCalculator.isInOptimalZone(
              0.5,
              optimal,
              roundNumber: roundNumber,
            ),
            isTrue,
          );
        });

        test('returns true when BAC is just inside +10% boundary', () {
          // 0.5 * 1.10 - 0.001 = 0.549
          expect(
            BACCalculator.isInOptimalZone(
              0.549,
              optimal,
              roundNumber: roundNumber,
            ),
            isTrue,
          );
        });

        test('returns true when BAC is just inside -10% boundary', () {
          // 0.5 * 0.90 + 0.001 = 0.451
          expect(
            BACCalculator.isInOptimalZone(
              0.451,
              optimal,
              roundNumber: roundNumber,
            ),
            isTrue,
          );
        });

        test('returns false when BAC is just outside +10% boundary', () {
          // 0.5 * 1.10 + 0.001 = 0.551
          expect(
            BACCalculator.isInOptimalZone(
              0.551,
              optimal,
              roundNumber: roundNumber,
            ),
            isFalse,
          );
        });

        test('returns false when BAC is just outside -10% boundary', () {
          // 0.5 * 0.90 - 0.001 = 0.449
          expect(
            BACCalculator.isInOptimalZone(
              0.449,
              optimal,
              roundNumber: roundNumber,
            ),
            isFalse,
          );
        });
      });
    });

    // ── isCloseToOptimal ─────────────────────────────────────────────────────

    group('isCloseToOptimal', () {
      const optimal = 0.5;

      group('all rounds (±10-20% close)', () {
        const roundNumber = 3;

        test(
          'returns true when BAC is just outside +10% (entering close zone)',
          () {
            // 0.5 * 1.10 + 0.001 = 0.551
            expect(
              BACCalculator.isCloseToOptimal(
                0.551,
                optimal,
                roundNumber: roundNumber,
              ),
              isTrue,
            );
          },
        );

        test('returns true when BAC is just inside +20% boundary', () {
          // 0.5 * 1.20 - 0.001 = 0.599
          expect(
            BACCalculator.isCloseToOptimal(
              0.599,
              optimal,
              roundNumber: roundNumber,
            ),
            isTrue,
          );
        });

        test('returns false when BAC is in optimal zone', () {
          expect(
            BACCalculator.isCloseToOptimal(
              0.5,
              optimal,
              roundNumber: roundNumber,
            ),
            isFalse,
          );
        });

        test('returns false when BAC exceeds +20%', () {
          // 0.5 * 1.20 + 0.001 = 0.601
          expect(
            BACCalculator.isCloseToOptimal(
              0.601,
              optimal,
              roundNumber: roundNumber,
            ),
            isFalse,
          );
        });
      });
    });

    // ── isNeutralZone ────────────────────────────────────────────────────────

    group('isNeutralZone', () {
      const optimal = 0.5;

      group('all rounds (±20-40% neutral)', () {
        const roundNumber = 3;

        test('returns true at 30% above optimal', () {
          // 0.5 * 1.30 = 0.65
          expect(
            BACCalculator.isNeutralZone(
              0.65,
              optimal,
              roundNumber: roundNumber,
            ),
            isTrue,
          );
        });

        test('returns true at 30% below optimal', () {
          // 0.5 * 0.70 = 0.35
          expect(
            BACCalculator.isNeutralZone(
              0.35,
              optimal,
              roundNumber: roundNumber,
            ),
            isTrue,
          );
        });

        test('returns false when BAC is in close zone', () {
          expect(
            BACCalculator.isNeutralZone(
              0.55,
              optimal,
              roundNumber: roundNumber,
            ),
            isFalse,
          );
        });

        test('returns false when BAC is in far zone', () {
          // 0.5 * 1.50 = 0.75 (beyond 40%)
          expect(
            BACCalculator.isNeutralZone(
              0.75,
              optimal,
              roundNumber: roundNumber,
            ),
            isFalse,
          );
        });
      });
    });

    // ── isFarFromOptimal ─────────────────────────────────────────────────────

    group('isFarFromOptimal', () {
      const optimal = 0.5;

      group('all rounds (±40-80% far)', () {
        const roundNumber = 3;

        test('returns true at 60% above optimal', () {
          // 0.5 * 1.60 = 0.80
          expect(
            BACCalculator.isFarFromOptimal(
              0.80,
              optimal,
              roundNumber: roundNumber,
            ),
            isTrue,
          );
        });

        test('returns true at 60% below optimal', () {
          // 0.5 * 0.40 = 0.20
          expect(
            BACCalculator.isFarFromOptimal(
              0.20,
              optimal,
              roundNumber: roundNumber,
            ),
            isTrue,
          );
        });

        test('returns false when BAC is in neutral zone', () {
          expect(
            BACCalculator.isFarFromOptimal(
              0.65,
              optimal,
              roundNumber: roundNumber,
            ),
            isFalse,
          );
        });

        test('returns false when BAC has crossed the line (>80% above)', () {
          // 0.5 * 1.85 = 0.925 (beyond 80% above)
          expect(
            BACCalculator.isFarFromOptimal(
              0.925,
              optimal,
              roundNumber: roundNumber,
            ),
            isFalse,
          );
        });
      });
    });

    // ── crossedOptimalLine ───────────────────────────────────────────────────

    group('crossedOptimalLine', () {
      const optimal = 0.5;

      group('all rounds (>80% above)', () {
        const roundNumber = 3;

        test('returns true when BAC exceeds +80% threshold', () {
          // 0.5 * 1.80 + 0.001 = 0.901
          expect(
            BACCalculator.crossedOptimalLine(
              0.901,
              optimal,
              roundNumber: roundNumber,
            ),
            isTrue,
          );
        });

        test('returns false when BAC is exactly at +80% boundary', () {
          // 0.5 * 1.80 = 0.90
          expect(
            BACCalculator.crossedOptimalLine(
              0.90,
              optimal,
              roundNumber: roundNumber,
            ),
            isFalse,
          );
        });

        test('returns false when BAC is below optimal', () {
          expect(
            BACCalculator.crossedOptimalLine(
              0.1,
              optimal,
              roundNumber: roundNumber,
            ),
            isFalse,
          );
        });
      });

      test('real scenario: 0.35 at optimal 0.125 round 1 triggers fine', () {
        // 0.35 / 0.125 = 2.8 = 180% above → fine (>80% threshold)
        expect(
          BACCalculator.crossedOptimalLine(0.35, 0.125, roundNumber: 1),
          isTrue,
        );
      });
    });

    // ── Property 1: All zone functions are mutually exclusive ────────────────

    group('Property 1: zone functions are mutually exclusive', () {
      test(
        'at most one zone function returns true for any BAC/optimal pair',
        () {
          final rng = Random(42);
          for (var i = 0; i < 200; i++) {
            final bac = rng.nextDouble() * 5.0;
            final optimal = rng.nextDouble() * 3.0 + 0.1;

            final inZone = BACCalculator.isInOptimalZone(bac, optimal);
            final close = BACCalculator.isCloseToOptimal(bac, optimal);
            final neutral = BACCalculator.isNeutralZone(bac, optimal);
            final far = BACCalculator.isFarFromOptimal(bac, optimal);
            final crossed = BACCalculator.crossedOptimalLine(bac, optimal);

            final trueCount = [
              inZone,
              close,
              neutral,
              far,
              crossed,
            ].where((v) => v).length;

            expect(
              trueCount,
              lessThanOrEqualTo(1),
              reason:
                  'bac=$bac, optimal=$optimal: '
                  'inZone=$inZone, close=$close, neutral=$neutral, '
                  'far=$far, crossed=$crossed',
            );
          }
        },
      );
    });

    // ── Property 2: Optimal BrAC is consistent per round ─────────────────────

    group('Property 2: Optimal BrAC is deterministic per round', () {
      test('same round/sex/bodySize always returns same optimal', () {
        final rng = Random(42);
        for (var i = 0; i < 50; i++) {
          final round = rng.nextInt(10) + 1;
          final sex = rng.nextBool() ? Sex.male : Sex.female;
          final bodySize = BodySize.values[rng.nextInt(BodySize.values.length)];

          final opt1 = BACCalculator.calculateOptimalBrAC(round, sex, bodySize);
          final opt2 = BACCalculator.calculateOptimalBrAC(round, sex, bodySize);

          expect(opt1, equals(opt2));
        }
      });
    });
  });
}
