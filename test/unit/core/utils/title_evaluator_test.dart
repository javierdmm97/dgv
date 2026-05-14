import 'package:flutter_test/flutter_test.dart';

import 'package:dgv/core/models/bac_reading.dart';
import 'package:dgv/core/models/dgt_title.dart';
import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/core/utils/title_evaluator.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Build a PlayerProfile with a specific BAC reading for a given round.
PlayerProfile _playerWithReading({
  required String id,
  required double bac,
  required int round,
  double optimalBAC = 2.0,
  double? previousBac,
  int? previousRound,
  bool crossedOptimalLine = false,
  int points = 15,
  Map<DGTTitle, int>? titleCounts,
}) {
  final readings = <BACReading>[];

  if (previousBac != null && previousRound != null) {
    readings.add(
      BACReading(
        id: '${id}_r$previousRound',
        playerId: id,
        bac: previousBac,
        timestamp: DateTime(2025, 1, 1, 14, 0),
        roundNumber: previousRound,
        entryMethod: BACEntryMethod.manual,
      ),
    );
  }

  readings.add(
    BACReading(
      id: '${id}_r$round',
      playerId: id,
      bac: bac,
      timestamp: DateTime(2025, 1, 1, 15, 0),
      roundNumber: round,
      entryMethod: BACEntryMethod.manual,
    ),
  );

  return PlayerProfile(
    id: id,
    name: 'Player',
    surname: id,
    photoPath: '',
    sex: Sex.male,
    bodySize: BodySize.medium,
    optimalBAC: optimalBAC,
    licenseImagePath: '',
    readings: readings,
    titleCounts: titleCounts ?? const {},
    crossedOptimalLine: crossedOptimalLine,
    points: points,
  );
}

void main() {
  group('TitleEvaluator', () {
    // ── evaluateRound — velocidadDeCrucero ───────────────────────────────────

    group('evaluateRound — velocidadDeCrucero', () {
      test('awards to player closest to their optimal zone', () {
        final players = [
          _playerWithReading(
            id: 'a',
            bac: 2.0,
            round: 1,
            optimalBAC: 2.0,
          ), // distance 0.0
          _playerWithReading(
            id: 'b',
            bac: 2.5,
            round: 1,
            optimalBAC: 2.0,
          ), // distance 0.5
          _playerWithReading(
            id: 'c',
            bac: 1.7,
            round: 1,
            optimalBAC: 2.0,
          ), // distance 0.3
        ];

        final awards = TitleEvaluator.evaluateRound(players, 1);
        expect(awards['a'], equals(DGTTitle.velocidadDeCrucero));
      });
    });

    // ── evaluateRound — lDePracticas ─────────────────────────────────────────

    group('evaluateRound — lDePracticas', () {
      test('awards to player with lowest BAC in the round', () {
        final players = [
          _playerWithReading(id: 'a', bac: 2.0, round: 1),
          _playerWithReading(id: 'b', bac: 0.5, round: 1), // lowest
          _playerWithReading(id: 'c', bac: 1.5, round: 1),
        ];

        final awards = TitleEvaluator.evaluateRound(players, 1);
        expect(awards['b'], equals(DGTTitle.lDePracticas));
      });
    });

    // ── evaluateRound — vehiculoHibrido ──────────────────────────────────────

    group('evaluateRound — vehiculoHibrido', () {
      test('awards to all players whose BAC dropped from previous round', () {
        final players = [
          _playerWithReading(
            id: 'a',
            bac: 1.5,
            round: 2,
            previousBac: 2.0,
            previousRound: 1,
          ), // dropped
          _playerWithReading(
            id: 'b',
            bac: 2.5,
            round: 2,
            previousBac: 2.0,
            previousRound: 1,
          ), // increased
          _playerWithReading(
            id: 'c',
            bac: 1.8,
            round: 2,
            previousBac: 2.2,
            previousRound: 1,
          ), // dropped
        ];

        final awards = TitleEvaluator.evaluateRound(players, 2);
        expect(awards['a'], equals(DGTTitle.vehiculoHibrido));
        expect(awards['c'], equals(DGTTitle.vehiculoHibrido));
        // Player 'b' did not drop BAC, so should NOT have vehiculoHibrido
        expect(awards['b'], isNot(equals(DGTTitle.vehiculoHibrido)));
      });

      test('does not award vehiculoHibrido in round 1 (no previous round)', () {
        final players = [
          _playerWithReading(id: 'a', bac: 1.5, round: 1),
          _playerWithReading(id: 'b', bac: 2.0, round: 1),
        ];

        final awards = TitleEvaluator.evaluateRound(players, 1);
        expect(awards.values.contains(DGTTitle.vehiculoHibrido), isFalse);
      });
    });

    // ── evaluateRound — itvPassed ────────────────────────────────────────────

    group('evaluateRound — itvPassed', () {
      test('awards to players with same reading twice (±0.01)', () {
        final players = [
          _playerWithReading(
            id: 'a',
            bac: 2.0,
            round: 2,
            previousBac: 2.005,
            previousRound: 1,
          ), // diff = 0.005 ≤ 0.01
          _playerWithReading(
            id: 'b',
            bac: 2.0,
            round: 2,
            previousBac: 2.02,
            previousRound: 1,
          ), // diff = 0.02 > 0.01
        ];

        final awards = TitleEvaluator.evaluateRound(players, 2);
        expect(awards['a'], equals(DGTTitle.itvPassed));
        // Player 'b' diff > 0.01, so should NOT have itvPassed
        expect(awards['b'], isNot(equals(DGTTitle.itvPassed)));
      });

      test('does not award itvPassed in round 1', () {
        final players = [_playerWithReading(id: 'a', bac: 2.0, round: 1)];

        final awards = TitleEvaluator.evaluateRound(players, 1);
        expect(awards.values.contains(DGTTitle.itvPassed), isFalse);
      });
    });

    // ── evaluateRound — multaPorExceso ───────────────────────────────────────

    group('evaluateRound — multaPorExceso', () {
      test('does not award multaPorExceso in round 1', () {
        final players = [
          _playerWithReading(id: 'a', bac: 3.0, round: 1),
          _playerWithReading(id: 'b', bac: 2.0, round: 1),
        ];

        final awards = TitleEvaluator.evaluateRound(players, 1);
        expect(awards.values.contains(DGTTitle.multaPorExceso), isFalse);
      });

      test('awards to player with highest BAC spike in round 2+', () {
        final players = [
          _playerWithReading(
            id: 'a',
            bac: 3.0,
            round: 2,
            previousBac: 1.0,
            previousRound: 1,
          ), // spike = 2.0
          _playerWithReading(
            id: 'b',
            bac: 2.5,
            round: 2,
            previousBac: 1.5,
            previousRound: 1,
          ), // spike = 1.0
        ];

        final awards = TitleEvaluator.evaluateRound(players, 2);
        expect(awards['a'], equals(DGTTitle.multaPorExceso));
      });
    });

    // ── evaluateRound — empty players ────────────────────────────────────────

    group('evaluateRound — edge cases', () {
      test(
        'returns empty map when no players have readings for current round',
        () {
          final players = [_playerWithReading(id: 'a', bac: 2.0, round: 1)];

          // Ask for round 2 but players only have round 1 readings
          final awards = TitleEvaluator.evaluateRound(players, 2);
          expect(awards, isEmpty);
        },
      );

      test('returns empty map for empty player list', () {
        final awards = TitleEvaluator.evaluateRound([], 1);
        expect(awards, isEmpty);
      });
    });

    // ── calculateGrandPrizes ─────────────────────────────────────────────────

    group('calculateGrandPrizes', () {
      test('awards conductorPerfecto to highest-points player who never '
          'crossed optimal line', () {
        final players = [
          _playerWithReading(
            id: 'a',
            bac: 2.0,
            round: 1,
            points: 18,
            crossedOptimalLine: false,
          ),
          _playerWithReading(
            id: 'b',
            bac: 2.0,
            round: 1,
            points: 20,
            crossedOptimalLine: true,
          ), // ineligible
          _playerWithReading(
            id: 'c',
            bac: 2.0,
            round: 1,
            points: 15,
            crossedOptimalLine: false,
          ),
        ];

        final prizes = TitleEvaluator.calculateGrandPrizes(players);
        expect(prizes['conductor_perfecto'], equals('a'));
      });

      test(
        'does not award conductorPerfecto when all players crossed line',
        () {
          final players = [
            _playerWithReading(
              id: 'a',
              bac: 2.0,
              round: 1,
              crossedOptimalLine: true,
            ),
            _playerWithReading(
              id: 'b',
              bac: 2.0,
              round: 1,
              crossedOptimalLine: true,
            ),
          ];

          final prizes = TitleEvaluator.calculateGrandPrizes(players);
          expect(prizes.containsKey('conductor_perfecto'), isFalse);
        },
      );

      test(
        'awards precisionAbsoluta to player with smallest average distance',
        () {
          // Player 'a' always at exactly optimal → avg distance 0
          // Player 'b' always 0.5 away → avg distance 0.5
          final players = [
            _playerWithReading(id: 'a', bac: 2.0, round: 1, optimalBAC: 2.0),
            _playerWithReading(id: 'b', bac: 2.5, round: 1, optimalBAC: 2.0),
          ];

          final prizes = TitleEvaluator.calculateGrandPrizes(players);
          expect(prizes['precision_absoluta'], equals('a'));
        },
      );

      test('awards coleccionistaTitulos to player with most titles', () {
        final players = [
          _playerWithReading(
            id: 'a',
            bac: 2.0,
            round: 1,
            titleCounts: {
              DGTTitle.velocidadDeCrucero: 3,
              DGTTitle.lDePracticas: 2,
            },
          ),
          _playerWithReading(
            id: 'b',
            bac: 2.0,
            round: 1,
            titleCounts: {DGTTitle.velocidadDeCrucero: 1},
          ),
        ];

        final prizes = TitleEvaluator.calculateGrandPrizes(players);
        expect(prizes['coleccionista_titulos'], equals('a'));
      });

      test('returns empty map for empty player list', () {
        final prizes = TitleEvaluator.calculateGrandPrizes([]);
        expect(prizes, isEmpty);
      });
    });

    // ── getEnvironmentalDistinctives ─────────────────────────────────────────

    group('getEnvironmentalDistinctives', () {
      test('returns at most 5 players', () {
        final players = List.generate(
          10,
          (i) => _playerWithReading(id: 'p$i', bac: i.toDouble(), round: 1),
        );

        final result = TitleEvaluator.getEnvironmentalDistinctives(players);
        expect(result.length, lessThanOrEqualTo(5));
      });

      test('returns all players when fewer than 5', () {
        final players = [
          _playerWithReading(id: 'a', bac: 2.0, round: 1),
          _playerWithReading(id: 'b', bac: 1.5, round: 1),
          _playerWithReading(id: 'c', bac: 3.0, round: 1),
        ];

        final result = TitleEvaluator.getEnvironmentalDistinctives(players);
        expect(result.length, equals(3));
      });

      test('returns players sorted descending by max BAC', () {
        final players = [
          _playerWithReading(id: 'a', bac: 1.0, round: 1),
          _playerWithReading(id: 'b', bac: 3.0, round: 1),
          _playerWithReading(id: 'c', bac: 2.0, round: 1),
          _playerWithReading(id: 'd', bac: 4.0, round: 1),
          _playerWithReading(id: 'e', bac: 0.5, round: 1),
        ];

        final result = TitleEvaluator.getEnvironmentalDistinctives(players);
        expect(result[0].id, equals('d')); // 4.0
        expect(result[1].id, equals('b')); // 3.0
        expect(result[2].id, equals('c')); // 2.0
        expect(result[3].id, equals('a')); // 1.0
        expect(result[4].id, equals('e')); // 0.5
      });
    });
  });
}
