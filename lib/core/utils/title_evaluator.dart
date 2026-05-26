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

    // 🟢 Velocidad de Crucero: Closest to their optimal zone
    final closestPlayer = _findClosestToOptimal(
      playersWithReadings,
      currentRound,
    );
    if (closestPlayer != null) {
      awards[closestPlayer.id] = DGTTitle.velocidadDeCrucero;
    }

    // 🔴 Multa por Exceso: Highest BAC spike from last round
    final highestSpikePlayer = _findHighestSpike(
      playersWithReadings,
      currentRound,
    );
    if (highestSpikePlayer != null) {
      awards[highestSpikePlayer.id] = DGTTitle.multaPorExceso;
    }

    // 🔰 L de Prácticas: Lowest BAC in the round
    final lowestBACPlayer = _findLowestBAC(playersWithReadings, currentRound);
    if (lowestBACPlayer != null) {
      awards[lowestBACPlayer.id] = DGTTitle.lDePracticas;
    }

    // 🔋 Vehículo Híbrido: TBD — stubbed until replacement is defined
    final hybridPlayers = _findHybridVehicles(playersWithReadings);
    for (final player in hybridPlayers) {
      awards[player.id] = DGTTitle.vehiculoHibrido;
    }

    // 🛠️ ITV Passed: Lost points last round AND back in zone this round
    final itvPlayers = _findITVPassed(playersWithReadings);
    for (final player in itvPlayers) {
      awards[player.id] = DGTTitle.itvPassed;
    }

    return awards;
  }

  /// Find player closest to their per-round optimal zone.
  static PlayerProfile? _findClosestToOptimal(
    List<PlayerProfile> players,
    int currentRound,
  ) {
    PlayerProfile? closest;
    double minDistance = double.infinity;

    for (final player in players) {
      final reading = player.latestReadingForRound(currentRound);
      if (reading == null) continue;

      final optimal = BACCalculator.calculateOptimalBrAC(
        currentRound,
        player.sex,
        player.bodySize,
      );
      final distance = (reading.bac - optimal).abs();
      if (distance < minDistance) {
        minDistance = distance;
        closest = player;
      }
    }

    return closest;
  }

  /// Find player with highest BAC spike from previous round.
  static PlayerProfile? _findHighestSpike(
    List<PlayerProfile> players,
    int currentRound,
  ) {
    if (currentRound <= 1) return null;

    PlayerProfile? highestSpike;
    double maxSpike = 0.0;

    for (final player in players) {
      final currentReading = player.latestReadingForRound(currentRound);
      final previousReading = player.latestReadingForRound(currentRound - 1);

      if (currentReading == null || previousReading == null) continue;

      final spike = currentReading.bac - previousReading.bac;
      if (spike > maxSpike) {
        maxSpike = spike;
        highestSpike = player;
      }
    }

    return highestSpike;
  }

  /// Find player with lowest BAC in the round.
  static PlayerProfile? _findLowestBAC(
    List<PlayerProfile> players,
    int currentRound,
  ) {
    PlayerProfile? lowest;
    double minBAC = double.infinity;

    for (final player in players) {
      final reading = player.latestReadingForRound(currentRound);
      if (reading == null) continue;

      if (reading.bac < minBAC) {
        minBAC = reading.bac;
        lowest = player;
      }
    }

    return lowest;
  }

  /// Vehículo Híbrido: replacement title is TBD — returns empty until defined.
  static List<PlayerProfile> _findHybridVehicles(List<PlayerProfile> players) {
    // vehiculoHibrido title replacement is TBD — returning empty until defined
    return [];
  }

  /// ITV Passed: player had negative points last round AND is back in zone.
  static List<PlayerProfile> _findITVPassed(List<PlayerProfile> players) {
    return players.where((p) {
      final activeReadings = p.readings.where((r) => r.roundNumber > 0).toList()
        ..sort((a, b) => a.roundNumber.compareTo(b.roundNumber));
      if (activeReadings.length < 2) return false;

      final lastReading = activeReadings[activeReadings.length - 1];
      final prevReading = activeReadings[activeReadings.length - 2];

      final prevOptimal = BACCalculator.calculateOptimalBrAC(
        prevReading.roundNumber,
        p.sex,
        p.bodySize,
      );
      final wasOutOfZone =
          !BACCalculator.isInOptimalZone(
            prevReading.bac,
            prevOptimal,
            roundNumber: prevReading.roundNumber,
          ) &&
          !BACCalculator.isCloseToOptimal(
            prevReading.bac,
            prevOptimal,
            roundNumber: prevReading.roundNumber,
          );

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

      return wasOutOfZone && nowInZone;
    }).toList();
  }

  /// Sort players for leaderboard: primary = points desc, tiebreaker = perfection score asc.
  static List<PlayerProfile> calculateLeaderboard(List<PlayerProfile> players) {
    final sorted = [...players];
    sorted.sort((a, b) {
      if (a.points != b.points) return b.points.compareTo(a.points);
      final aScore = PointsCalculator.calculatePerfectionScore(
        a.readings,
        a.sex,
        a.bodySize,
      );
      final bScore = PointsCalculator.calculatePerfectionScore(
        b.readings,
        b.sex,
        b.bodySize,
      );
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
