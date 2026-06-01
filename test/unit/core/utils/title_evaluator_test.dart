import 'package:flutter_test/flutter_test.dart';

import 'package:dgv/core/models/bac_reading.dart';
import 'package:dgv/core/models/dgt_title.dart';
import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/core/utils/bac_calculator.dart';
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
  int previousPointsChange = 0,
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
        pointsChange: previousPointsChange,
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
        // Medium male, round 1 optimal ≈ 0.111
        // 'a' is 0.004 above optimal (closest), 'c' is 0.010 below optimal (lowest drinker BAC)
        final players = [
          _playerWithReading(
            id: 'a',
            bac: 0.115, // above optimal, distance=0.004 → velocidadDeCrucero
            round: 1,
          ),
          _playerWithReading(
            id: 'b',
            bac: 0.627, // far above optimal
            round: 1,
          ),
          _playerWithReading(
            id: 'c',
            bac:
                0.101, // below optimal, distance=0.010; lowest BAC drinker → lDePracticas
            round: 1,
          ),
        ];

        final awards = TitleEvaluator.evaluateRound(players, 1);
        // Player 'a' is closest to optimal (distance 0.004 < 0.010)
        expect(awards['a'], equals(DGTTitle.velocidadDeCrucero));
        // Player 'c' has lowest BAC among drinkers
        expect(awards['c'], equals(DGTTitle.lDePracticas));
      });

      test('tie-breaking: awards to player with alphabetically earlier name when '
          'equidistant from optimal', () {
        // Both players are medium male, round 1 optimal ≈ 0.111
        // Both are exactly 0.05 above optimal — same distance, neither is lowest BAC.
        // A third player has a lower BAC so lDePracticas goes elsewhere.
        final optimal1 = BACCalculator.calculateOptimalBrAC(
          1,
          Sex.male,
          BodySize.medium,
        );
        final players = [
          PlayerProfile(
            id: 'id_zebra',
            name: 'Zebra',
            surname: 'Z',
            photoPath: '',
            sex: Sex.male,
            bodySize: BodySize.medium,
            licenseImagePath: '',
            readings: [
              BACReading(
                id: 'id_zebra_r1',
                playerId: 'id_zebra',
                bac: optimal1 + 0.05, // 0.05 above optimal
                timestamp: DateTime(2025, 1, 1, 15, 0),
                roundNumber: 1,
                entryMethod: BACEntryMethod.manual,
              ),
            ],
            titleCounts: const {},
            crossedOptimalLine: false,
            points: 15,
          ),
          PlayerProfile(
            id: 'id_alice',
            name: 'Alice',
            surname: 'A',
            photoPath: '',
            sex: Sex.male,
            bodySize: BodySize.medium,
            licenseImagePath: '',
            readings: [
              BACReading(
                id: 'id_alice_r1',
                playerId: 'id_alice',
                bac: optimal1 + 0.05, // same distance above optimal
                timestamp: DateTime(2025, 1, 1, 15, 0),
                roundNumber: 1,
                entryMethod: BACEntryMethod.manual,
              ),
            ],
            titleCounts: const {},
            crossedOptimalLine: false,
            points: 15,
          ),
          // Third player has a very high BAC so lDePracticas goes to Alice/Zebra.
          // The point of this player is only to confirm the tie-breaking logic.
          PlayerProfile(
            id: 'id_carlos',
            name: 'Carlos',
            surname: 'C',
            photoPath: '',
            sex: Sex.male,
            bodySize: BodySize.medium,
            licenseImagePath: '',
            readings: [
              BACReading(
                id: 'id_carlos_r1',
                playerId: 'id_carlos',
                bac: 0.80, // highest BAC — far above optimal
                timestamp: DateTime(2025, 1, 1, 15, 0),
                roundNumber: 1,
                entryMethod: BACEntryMethod.manual,
              ),
            ],
            titleCounts: const {},
            crossedOptimalLine: false,
            points: 15,
          ),
        ];

        final awards = TitleEvaluator.evaluateRound(players, 1);
        // Both Alice and Zebra are equidistant; 'Alice' < 'Zebra' alphabetically → Alice wins
        expect(awards['id_alice'], equals(DGTTitle.velocidadDeCrucero));
        expect(awards['id_zebra'], isNot(equals(DGTTitle.velocidadDeCrucero)));
        // Carlos has highest BAC, not lowest — lDePracticas goes to Alice or Zebra, not Carlos
        expect(awards['id_carlos'], isNot(equals(DGTTitle.lDePracticas)));
      });
    });

    // ── evaluateRound — lDePracticas ─────────────────────────────────────────

    group('evaluateRound — lDePracticas', () {
      test(
        'awards to player with lowest BAC not already holding another title',
        () {
          // optimal ≈ 0.111 for round 1 medium male
          // 'a' (0.115) is closest to optimal → velocidadDeCrucero (distance 0.004)
          // 'c' (0.20) is lowest BAC among non-awarded players → lDePracticas
          // 'b' (0.50) is furthest
          final players = [
            _playerWithReading(id: 'a', bac: 0.115, round: 1),
            _playerWithReading(id: 'b', bac: 0.50, round: 1),
            _playerWithReading(id: 'c', bac: 0.20, round: 1),
          ];

          final awards = TitleEvaluator.evaluateRound(players, 1);
          expect(awards['a'], equals(DGTTitle.velocidadDeCrucero));
          expect(awards['c'], equals(DGTTitle.lDePracticas));
        },
      );
    });

    // ── evaluateRound — vehiculoHibrido ──────────────────────────────────────

    group('evaluateRound — vehiculoHibrido (El favorito de la DGV)', () {
      test('awards to all sober players not already holding another title', () {
        // 'd' (0.115) is closest to optimal → velocidadDeCrucero
        // 'a' (0.00) and 'c' (0.08) are sober → both get vehiculoHibrido
        // 'b' (0.35) is a drinker → does not get vehiculoHibrido
        final players = [
          _playerWithReading(id: 'a', bac: 0.00, round: 1),
          _playerWithReading(id: 'b', bac: 0.35, round: 1),
          _playerWithReading(id: 'c', bac: 0.08, round: 1),
          _playerWithReading(id: 'd', bac: 0.115, round: 1),
        ];

        final awards = TitleEvaluator.evaluateRound(players, 1);
        expect(awards['a'], equals(DGTTitle.vehiculoHibrido));
        expect(awards['c'], equals(DGTTitle.vehiculoHibrido));
        expect(awards['b'], isNot(equals(DGTTitle.vehiculoHibrido)));
        expect(awards['d'], equals(DGTTitle.velocidadDeCrucero));
      });

      test('does not award vehiculoHibrido when no sober players', () {
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
        // ITV Passed logic: lost points last round AND now back in zone
        // Round 2 optimal = 0.223 (±10% = [0.201, 0.245])
        // 'b' is exactly at optimal → gets velocidadDeCrucero
        // 'a' is in zone (0.21 ∈ [0.201, 0.245]) AND lost points → gets itvPassed
        final players = [
          _playerWithReading(
            id: 'a',
            bac: 0.21, // Round 2: in zone + lost points → itvPassed
            round: 2,
            previousBac: 0.55,
            previousRound: 1,
            previousPointsChange: -4,
          ),
          _playerWithReading(
            id: 'b',
            bac: 0.223, // Round 2: exactly optimal → velocidadDeCrucero
            round: 2,
            previousBac: 0.111,
            previousRound: 1,
            previousPointsChange: 2,
          ),
          // 'c' absorbs lDePracticas so 'a' is not claimed by it first
          _playerWithReading(id: 'c', bac: 0.15, round: 2),
          // 'd' absorbs multaPorExceso (highest BAC) so 'a' is free for itvPassed
          _playerWithReading(id: 'd', bac: 0.80, round: 2),
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
      test('awards multaPorExceso to player with highest absolute BAC', () {
        final players = [
          _playerWithReading(id: 'a', bac: 3.0, round: 1), // highest → multa
          _playerWithReading(id: 'b', bac: 2.0, round: 1),
        ];

        final awards = TitleEvaluator.evaluateRound(players, 1);
        expect(awards['a'], equals(DGTTitle.multaPorExceso));
        expect(awards['b'], isNot(equals(DGTTitle.multaPorExceso)));
      });

      test('awards multaPorExceso in round 1 (no previous round needed)', () {
        final players = [
          _playerWithReading(id: 'a', bac: 2.5, round: 1),
          _playerWithReading(id: 'b', bac: 3.5, round: 1), // highest
        ];

        final awards = TitleEvaluator.evaluateRound(players, 1);
        expect(awards['b'], equals(DGTTitle.multaPorExceso));
      });

      test('awards multaPorExceso to all players sharing the maximum BAC', () {
        final players = [
          _playerWithReading(id: 'a', bac: 3.0, round: 2), // tied highest
          _playerWithReading(id: 'b', bac: 3.0, round: 2), // tied highest
          _playerWithReading(id: 'c', bac: 2.0, round: 2),
        ];

        final awards = TitleEvaluator.evaluateRound(players, 2);
        expect(awards['a'], equals(DGTTitle.multaPorExceso));
        expect(awards['b'], equals(DGTTitle.multaPorExceso));
        expect(awards['c'], isNot(equals(DGTTitle.multaPorExceso)));
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
