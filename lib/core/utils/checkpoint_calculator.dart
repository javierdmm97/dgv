import '../constants/app_constants.dart';
import '../models/player_profile.dart';

/// Checkpoint timer logic - per-group intervals
/// Each group has its own timer (e.g., Group 1 measures at 14:00, 14:45; Group 2 at 14:30, 15:15)
class CheckpointCalculator {
  CheckpointCalculator._();

  /// Calculate next checkpoint time for a group based on their last measurement
  static DateTime calculateNextCheckpoint(
    DateTime lastMeasurement,
    int intervalMinutes,
  ) {
    return lastMeasurement.add(Duration(minutes: intervalMinutes));
  }

  /// Check if a group's checkpoint is due
  static bool isCheckpointDue(DateTime lastMeasurement, int intervalMinutes) {
    final nextCheckpoint = calculateNextCheckpoint(
      lastMeasurement,
      intervalMinutes,
    );
    return DateTime.now().isAfter(nextCheckpoint);
  }

  /// Get time remaining until next checkpoint for a group
  static Duration getTimeRemaining(
    DateTime lastMeasurement,
    int intervalMinutes,
  ) {
    final nextCheckpoint = calculateNextCheckpoint(
      lastMeasurement,
      intervalMinutes,
    );
    final remaining = nextCheckpoint.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Divide players into groups (for initial setup)
  /// Groups can measure independently at their own intervals
  static List<List<PlayerProfile>> divideIntoGroups(
    List<PlayerProfile> players,
    int numberOfGroups,
  ) {
    if (numberOfGroups <= 0) numberOfGroups = 1;
    if (numberOfGroups > players.length) numberOfGroups = players.length;

    final groups = <List<PlayerProfile>>[];
    final groupSize = (players.length / numberOfGroups).ceil();

    for (int i = 0; i < players.length; i += groupSize) {
      final end = (i + groupSize < players.length)
          ? i + groupSize
          : players.length;
      groups.add(players.sublist(i, end));
    }

    return groups;
  }

  /// Suggest optimal number of groups based on player count
  /// Keeps groups manageable (3-8 players per group)
  static int suggestNumberOfGroups(int playerCount) {
    if (playerCount <= 8) return 1;
    if (playerCount <= 16) return 2;
    if (playerCount <= 24) return 3;
    return (playerCount / 8).ceil().clamp(1, 7);
  }

  /// Format time remaining as MM:SS
  static String formatTimeRemaining(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Format time remaining as human-readable string
  static String formatTimeRemainingHuman(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '$hours h $minutes min';
    } else if (minutes > 0) {
      return '$minutes min';
    } else {
      return '$seconds s';
    }
  }

  /// Calculate estimated BAC from number of beers consumed
  static double estimateBACFromBeers(
    int beersConsumed,
    Sex sex,
    BodySize bodySize,
    Duration timeSinceFirstBeer,
  ) {
    final totalAlcoholGrams =
        beersConsumed * AppConstants.gramsAlcoholPerStandardBeer;
    final bodyWeight = _getBodyWeight(bodySize);
    final r = sex == Sex.male
        ? AppConstants.widmarkRMale
        : AppConstants.widmarkRFemale;

    // Widmark formula
    final peakBAC = (totalAlcoholGrams / (bodyWeight * 1000 * r)) * 100;

    // Account for alcohol metabolism (~0.015% per hour)
    final hoursElapsed = timeSinceFirstBeer.inMinutes / 60.0;
    final metabolizedBAC = hoursElapsed * 0.015;

    final currentBAC = peakBAC - metabolizedBAC;
    return currentBAC > 0 ? currentBAC : 0;
  }

  static double _getBodyWeight(BodySize size) {
    switch (size) {
      case BodySize.small:
        return AppConstants.bodyWeightSmall;
      case BodySize.medium:
        return AppConstants.bodyWeightMedium;
      case BodySize.large:
        return AppConstants.bodyWeightLarge;
    }
  }
}
