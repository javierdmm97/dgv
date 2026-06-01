import '../constants/app_constants.dart';
import '../models/dgt_title.dart';
import '../models/player_profile.dart';
import 'bac_calculator.dart';
import 'points_calculator.dart';

/// DGT Title evaluation logic (per-round awards)
class TitleEvaluator {
  TitleEvaluator._();

  /// Evaluate and award titles for the current round.
  /// Returns a map of player IDs to awarded titles.
  static Map<String, DGTTitle> evaluateRound(
    List<PlayerProfile> players,
    int currentRound,
  ) {
    final awards = <String, DGTTitle>{};

    final playersWithReadings = players
        .where((p) => p.latestReadingForRound(currentRound) != null)
        .toList();

    if (playersWithReadings.isEmpty) return awards;

    // Helper: set of player IDs that already have a title this round.
    // Each subsequent title skips already-awarded players so no title
    // is silently overwritten (e.g. lDePracticas overwriting velocidadDeCrucero).
    Set<String> awarded() => awards.keys.toSet();

    // 🟢 Velocidad de Crucero: Closest to their optimal zone
    final closestPlayer = _findClosestToOptimal(
      playersWithReadings,
      currentRound,
      skip: const {},
    );
    if (closestPlayer != null) {
      awards[closestPlayer.id] = DGTTitle.velocidadDeCrucero;
    }

    // 🔴 Multa por Exceso: Highest BAC spike (skips already-awarded players)
    _awardMultaPorExceso(
      awards,
      playersWithReadings,
      currentRound,
      skip: awarded(),
    );

    // 🔰 L de Prácticas: Lowest BAC among non-sober, non-awarded players
    final lowestBACPlayer = _findLowestBAC(
      playersWithReadings,
      currentRound,
      skip: awarded(),
    );
    if (lowestBACPlayer != null) {
      awards[lowestBACPlayer.id] = DGTTitle.lDePracticas;
    }

    // 🔋 El favorito de la DGV: sober players (multiple ok, skip if awarded)
    final hybridPlayers = _findHybridVehicles(
      playersWithReadings,
      currentRound,
      skip: awarded(),
    );
    for (final player in hybridPlayers) {
      awards[player.id] = DGTTitle.vehiculoHibrido;
    }

    // 🛠️ ITV Passed: Lost points last round AND back in zone (skip if awarded)
    final itvPlayers = _findITVPassed(playersWithReadings, skip: awarded());
    for (final player in itvPlayers) {
      awards[player.id] = DGTTitle.itvPassed;
    }

    return awards;
  }

  static PlayerProfile? _findClosestToOptimal(
    List<PlayerProfile> players,
    int currentRound, {
    required Set<String> skip,
  }) {
    PlayerProfile? closest;
    double minDistance = double.infinity;

    for (final player in players) {
      if (skip.contains(player.id)) continue;
      final reading = player.latestReadingForRound(currentRound);
      if (reading == null) continue;

      final optimal = BACCalculator.calculateOptimalBrAC(
        currentRound,
        player.sex,
        player.bodySize,
      );
      final distance = (reading.bac - optimal).abs();
      if (distance < minDistance ||
          (distance == minDistance &&
              closest != null &&
              player.name.compareTo(closest.name) < 0)) {
        minDistance = distance;
        closest = player;
      }
    }

    return closest;
  }

  /// Award `multaPorExceso` to the player(s) with the highest absolute BAC
  /// this round. Skips already-awarded players.
  static void _awardMultaPorExceso(
    Map<String, DGTTitle> awards,
    List<PlayerProfile> players,
    int currentRound, {
    required Set<String> skip,
  }) {
    final eligible = players.where((p) => !skip.contains(p.id)).toList();

    double maxBAC = 0.0;
    for (final p in eligible) {
      final cur = p.latestReadingForRound(currentRound);
      if (cur == null) continue;
      if (cur.bac > maxBAC) maxBAC = cur.bac;
    }

    if (maxBAC <= 0) return;

    for (final p in eligible) {
      final cur = p.latestReadingForRound(currentRound);
      if (cur == null) continue;
      if (cur.bac == maxBAC) {
        awards[p.id] = DGTTitle.multaPorExceso;
      }
    }
  }

  /// Lowest BAC among drinking (bac > soberThreshold) non-awarded players.
  static PlayerProfile? _findLowestBAC(
    List<PlayerProfile> players,
    int currentRound, {
    required Set<String> skip,
  }) {
    PlayerProfile? lowest;
    double minBAC = double.infinity;

    for (final player in players) {
      if (skip.contains(player.id)) continue;
      final reading = player.latestReadingForRound(currentRound);
      if (reading == null) continue;
      if (reading.bac <= AppConstants.soberThreshold) continue;

      if (reading.bac < minBAC) {
        minBAC = reading.bac;
        lowest = player;
      }
    }

    return lowest;
  }

  /// El favorito de la DGV: sober players (BAC ≤ soberThreshold).
  /// Multiple winners allowed; skips already-awarded players.
  static List<PlayerProfile> _findHybridVehicles(
    List<PlayerProfile> players,
    int currentRound, {
    required Set<String> skip,
  }) {
    return players.where((p) {
      if (skip.contains(p.id)) return false;
      final reading = p.latestReadingForRound(currentRound);
      if (reading == null) return false;
      return reading.bac <= AppConstants.soberThreshold;
    }).toList();
  }

  /// ITV Passed: lost points last round AND back in zone. Skips awarded players.
  static List<PlayerProfile> _findITVPassed(
    List<PlayerProfile> players, {
    required Set<String> skip,
  }) {
    return players.where((p) {
      if (skip.contains(p.id)) return false;
      final activeReadings = p.readings.where((r) => r.roundNumber > 0).toList()
        ..sort((a, b) => a.roundNumber.compareTo(b.roundNumber));
      if (activeReadings.length < 2) return false;

      final lastReading = activeReadings[activeReadings.length - 1];
      final prevReading = activeReadings[activeReadings.length - 2];

      final lostPointsLastRound = prevReading.pointsChange < 0;

      final lastOptimal = BACCalculator.calculateOptimalBrAC(
        lastReading.roundNumber,
        p.sex,
        p.bodySize,
      );
      final nowInZone = BACCalculator.isInOptimalZone(
        lastReading.bac,
        lastOptimal,
        roundNumber: lastReading.roundNumber,
      );

      return lostPointsLastRound && nowInZone;
    }).toList();
  }

  /// Sort players for leaderboard: primary = points desc, tiebreaker = perfection score asc.
  static List<PlayerProfile> calculateLeaderboard(List<PlayerProfile> players) {
    final sorted = [...players];
    sorted.sort((a, b) {
      if (a.points != b.points) return b.points.compareTo(a.points);
      final aScore = PointsCalculator.calculatePerfectionScore(a.readings);
      final bScore = PointsCalculator.calculatePerfectionScore(b.readings);
      return aScore.compareTo(bScore);
    });
    return sorted;
  }

  /// Returns the player with most accumulated DGT titles.
  static PlayerProfile? getMostTitlesPlayer(List<PlayerProfile> players) {
    if (players.isEmpty) return null;
    return players.reduce((a, b) {
      final aTotal = a.titleCounts.values.fold(0, (s, c) => s + c);
      final bTotal = b.titleCounts.values.fold(0, (s, c) => s + c);
      return aTotal >= bTotal ? a : b;
    });
  }

  /// Get top 5 highest BAC players for Environmental Distinctive badges.
  static List<PlayerProfile> getEnvironmentalDistinctives(
    List<PlayerProfile> players,
  ) {
    final sorted = [...players]
      ..sort((a, b) {
        final aMax = a.maxBAC;
        final bMax = b.maxBAC;
        return bMax.compareTo(aMax);
      });

    return sorted.take(5).toList();
  }
}
