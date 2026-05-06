import '../models/dgt_title.dart';
import '../models/player_profile.dart';
import 'points_calculator.dart';

/// DGT Title evaluation logic (per-round awards)
class TitleEvaluator {
  TitleEvaluator._();

  /// Evaluate and award titles for the current round
  /// Returns a map of player IDs to awarded titles
  static Map<String, DGTTitle> evaluateRound(
    List<PlayerProfile> players,
    int currentRound,
  ) {
    final awards = <String, DGTTitle>{};

    // Filter players with readings for this round
    final playersWithReadings = players
        .where((p) => p.latestReadingForRound(currentRound) != null)
        .toList();

    if (playersWithReadings.isEmpty) return awards;

    // 🟢 Velocidad de Crucero: Closest to their optimal zone
    final closestPlayer = _findClosestToOptimal(playersWithReadings, currentRound);
    if (closestPlayer != null) {
      awards[closestPlayer.id] = DGTTitle.velocidadDeCrucero;
    }

    // 🔴 Multa por Exceso: Highest BAC spike from last round
    final highestSpikePlayer = _findHighestSpike(playersWithReadings, currentRound);
    if (highestSpikePlayer != null) {
      awards[highestSpikePlayer.id] = DGTTitle.multaPorExceso;
    }

    // 🔰 L de Prácticas: Lowest BAC in the round
    final lowestBACPlayer = _findLowestBAC(playersWithReadings, currentRound);
    if (lowestBACPlayer != null) {
      awards[lowestBACPlayer.id] = DGTTitle.lDePracticas;
    }

    // 🔋 Vehículo Híbrido: BAC dropped (drank water)
    final hybridPlayers = _findHybridVehicles(playersWithReadings, currentRound);
    for (final player in hybridPlayers) {
      awards[player.id] = DGTTitle.vehiculoHibrido;
    }

    // 🛠️ ITV Passed: Same reading twice in a row (±0.01)
    final itvPlayers = _findITVPassed(playersWithReadings, currentRound);
    for (final player in itvPlayers) {
      awards[player.id] = DGTTitle.itvPassed;
    }

    return awards;
  }

  /// Find player closest to their optimal zone
  static PlayerProfile? _findClosestToOptimal(
    List<PlayerProfile> players,
    int currentRound,
  ) {
    PlayerProfile? closest;
    double minDistance = double.infinity;

    for (final player in players) {
      final reading = player.latestReadingForRound(currentRound);
      if (reading == null) continue;

      final distance = (reading.bac - player.optimalBAC).abs();
      if (distance < minDistance) {
        minDistance = distance;
        closest = player;
      }
    }

    return closest;
  }

  /// Find player with highest BAC spike from previous round
  static PlayerProfile? _findHighestSpike(
    List<PlayerProfile> players,
    int currentRound,
  ) {
    if (currentRound <= 1) return null; // Need at least 2 rounds

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

  /// Find player with lowest BAC in the round
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

  /// Find players whose BAC dropped (drank water)
  static List<PlayerProfile> _findHybridVehicles(
    List<PlayerProfile> players,
    int currentRound,
  ) {
    if (currentRound <= 1) return []; // Need at least 2 rounds

    final hybrids = <PlayerProfile>[];

    for (final player in players) {
      final currentReading = player.latestReadingForRound(currentRound);
      final previousReading = player.latestReadingForRound(currentRound - 1);

      if (currentReading == null || previousReading == null) continue;

      // BAC dropped
      if (currentReading.bac < previousReading.bac) {
        hybrids.add(player);
      }
    }

    return hybrids;
  }

  /// Find players with same reading twice in a row (±0.01)
  static List<PlayerProfile> _findITVPassed(
    List<PlayerProfile> players,
    int currentRound,
  ) {
    if (currentRound <= 1) return []; // Need at least 2 rounds

    final itvPassed = <PlayerProfile>[];

    for (final player in players) {
      final currentReading = player.latestReadingForRound(currentRound);
      final previousReading = player.latestReadingForRound(currentRound - 1);

      if (currentReading == null || previousReading == null) continue;

      // Same reading (±0.01 tolerance)
      final diff = (currentReading.bac - previousReading.bac).abs();
      if (diff <= 0.01) {
        itvPassed.add(player);
      }
    }

    return itvPassed;
  }

  /// Calculate grand prize winners at the end
  static Map<String, String> calculateGrandPrizes(List<PlayerProfile> players) {
    final prizes = <String, String>{};

    if (players.isEmpty) return prizes;

    // 🏆 El Conductor Perfecto: Highest points + never crossed optimal line
    final eligibleForPerfect = players
        .where((p) => !p.crossedOptimalLine)
        .toList();

    if (eligibleForPerfect.isNotEmpty) {
      final perfectDriver = eligibleForPerfect.reduce(
        (a, b) => a.points > b.points ? a : b,
      );
      prizes['conductor_perfecto'] = perfectDriver.id;
    }

    // 🎯 Precisión Absoluta: Closest average to optimal zone
    final mostPrecise = players.reduce((a, b) {
      final aAvg = PointsCalculator.calculateAverageDistanceFromOptimal(
        a.readings,
        a.optimalBAC,
      );
      final bAvg = PointsCalculator.calculateAverageDistanceFromOptimal(
        b.readings,
        b.optimalBAC,
      );
      return aAvg < bAvg ? a : b;
    });
    prizes['precision_absoluta'] = mostPrecise.id;

    // 👑 Coleccionista de Títulos: Most DGT titles accumulated
    final collector = players.reduce((a, b) {
      return a.totalTitles > b.totalTitles ? a : b;
    });
    prizes['coleccionista_titulos'] = collector.id;

    return prizes;
  }

  /// Get top 5 highest BAC players for Environmental Distinctive badges
  static List<PlayerProfile> getEnvironmentalDistinctives(
    List<PlayerProfile> players,
  ) {
    final sorted = [...players]
      ..sort((a, b) {
        final aMax = a.maxBAC;
        final bMax = b.maxBAC;
        return bMax.compareTo(aMax); // Descending
      });

    return sorted.take(5).toList();
  }
}
