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
        // All players are medium male, round 1 optimal = 0.127
        final players = [
          _playerWithReading(
            id: 'a',
            bac: 0.127, // Exactly at optimal - distance 0.0
            round: 1,
          ),
          _playerWithReading(
            id: 'b',
            bac: 0.627, // 0.5 away from optimal
            round: 1,
          ),
          _playerWithReading(
            id: 'c',
            bac: 0.027, // 0.1 away from optimal (lowest BAC, gets lDePracticas)
            round: 1,
          ),
        ];

        final awards = TitleEvaluator.evaluateRound(players, 1);
        // Player 'a' is closest to optimal
        expect(awards['a'], equals(DGTTitle.velocidadDeCrucero));
        // Player 'c' has lowest BAC
        expect(awards['c'], equals(DGTTitle.lDePracticas));
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
        // Note: vehiculoHibrido is now stubbed and returns empty
        // This test will fail until the replacement title is defined
        final players = [
          _playerWithReading(
            id: 'a',
            bac: 0.20,
            round: 2,
            previousBac: 0.30,
            previousRound: 1,
          ), // dropped
          _playerWithReading(
            id: 'b',
            bac: 0.35,
            round: 2,
            previousBac: 0.20,
            previousRound: 1,
          ), // increased
          _playerWithReading(
            id: 'c',
            bac: 0.18,
            round: 2,
            previousBac: 0.22,
            previousRound: 1,
          ), // dropped
        ];

        final awards = TitleEvaluator.evaluateRound(players, 2);
        // vehiculoHibrido is stubbed — no awards expected until replacement defined
        expect(awards['a'], isNot(equals(DGTTitle.vehiculoHibrido)));
        expect(awards['c'], isNot(equals(DGTTitle.vehiculoHibrido)));
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
      test('awards to players back in zone after being out', () {
        // ITV Passed logic: was out of zone last round AND now in zone
        // Round 1 optimal = 0.111 (±10% = [0.100, 0.122])
        // Round 2 optimal = 0.223 (±10% = [0.201, 0.245])
        final players = [
          _playerWithReading(
            id: 'a',
            bac: 0.223, // Round 2: exactly optimal — in zone
            round: 2,
            previousBac: 0.55, // Round 1: >80% above 0.111 — way out of zone
            previousRound: 1,
          ),
          _playerWithReading(
            id: 'b',
            bac: 0.223, // Round 2: in zone
            round: 2,
            previousBac: 0.111, // Round 1: exactly optimal — already in zone
            previousRound: 1,
          ),
        ];

        final awards = TitleEvaluator.evaluateRound(players, 2);
        // Player 'a' was out and is now in → gets ITV
        expect(awards['a'], equals(DGTTitle.itvPassed));
        // Player 'b' was already in zone → no ITV
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

    // ── getMostTitlesPlayer ──────────────────────────────────────────────────

    group('getMostTitlesPlayer', () {
      test('returns player with most accumulated titles', () {
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

        final result = TitleEvaluator.getMostTitlesPlayer(players);
        expect(result?.id, equals('a'));
      });

      test('returns null for empty player list', () {
        final result = TitleEvaluator.getMostTitlesPlayer([]);
        expect(result, isNull);
      });

      test('returns first player when all have same title count', () {
        final players = [
          _playerWithReading(
            id: 'a',
            bac: 2.0,
            round: 1,
            titleCounts: {DGTTitle.velocidadDeCrucero: 1},
          ),
          _playerWithReading(
            id: 'b',
            bac: 2.0,
            round: 1,
            titleCounts: {DGTTitle.lDePracticas: 1},
          ),
        ];

        final result = TitleEvaluator.getMostTitlesPlayer(players);
        expect(result, isNotNull);
        expect(result!.id, equals('a'));
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
