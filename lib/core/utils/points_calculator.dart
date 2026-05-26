import '../models/bac_reading.dart';
import '../models/player_profile.dart';
import 'bac_calculator.dart';

/// Points calculation logic for Phase 2.5 simplified scoring.
class PointsCalculator {
  PointsCalculator._();

  /// Calculate points change based on BrAC relative to the round optimal.
  ///
  /// Scale: +2 (sweet spot) / +1 (close) / 0 (neutral) / -1 (far) / -2 (>100% below) / -4 fine (>100% above)
  /// Rounds 1-2 use wider thresholds; rounds 3+ use standard thresholds.
  static int calculatePointsChange({
    required double currentBAC,
    required double optimalBAC,
    required int roundNumber,
  }) {
    if (BACCalculator.isInOptimalZone(
      currentBAC,
      optimalBAC,
      roundNumber: roundNumber,
    )) {
      return 2;
    }
    if (BACCalculator.isCloseToOptimal(
      currentBAC,
      optimalBAC,
      roundNumber: roundNumber,
    )) {
      return 1;
    }
    if (BACCalculator.isNeutralZone(
      currentBAC,
      optimalBAC,
      roundNumber: roundNumber,
    )) {
      return 0;
    }
    if (BACCalculator.isFarFromOptimal(
      currentBAC,
      optimalBAC,
      roundNumber: roundNumber,
    )) {
      return -1;
    }
    if (BACCalculator.crossedOptimalLine(
      currentBAC,
      optimalBAC,
      roundNumber: roundNumber,
    )) {
      return -4;
    }
    return -2; // beyond far threshold below optimal
  }

  /// A fine is issued when a measurement results in -4 points.
  static bool shouldIssueFine(int pointsChange) => pointsChange <= -4;

  /// Calculate total points clamped between min (0) and max (15).
  static int calculateTotalPoints(int currentPoints, int pointsChange) {
    final newPoints = currentPoints + pointsChange;
    return newPoints.clamp(0, 15);
  }

  /// Average distance from the per-round optimal across all active readings.
  static double calculateAverageDistanceFromOptimal(
    List<BACReading> readings,
    Sex sex,
    BodySize bodySize,
  ) {
    final activeReadings = readings.where((r) => r.roundNumber > 0).toList();
    if (activeReadings.isEmpty) return double.infinity;

    final distances = activeReadings.map((r) {
      final optimal = BACCalculator.calculateOptimalBrAC(
        r.roundNumber,
        sex,
        bodySize,
      );
      return (r.bac - optimal).abs();
    }).toList();

    return distances.reduce((a, b) => a + b) / distances.length;
  }

  /// Perfection score for leaderboard tiebreaker (lower = better).
  ///
  /// Combines average distance from per-round optimal with its variance.
  static double calculatePerfectionScore(
    List<BACReading> readings,
    Sex sex,
    BodySize bodySize,
  ) {
    final activeReadings = readings.where((r) => r.roundNumber > 0).toList();
    if (activeReadings.isEmpty) return double.infinity;

    final avg = calculateAverageDistanceFromOptimal(readings, sex, bodySize);

    final variance =
        activeReadings
            .map((r) {
              final optimal = BACCalculator.calculateOptimalBrAC(
                r.roundNumber,
                sex,
                bodySize,
              );
              final diff = (r.bac - optimal).abs() - avg;
              return diff * diff;
            })
            .reduce((a, b) => a + b) /
        activeReadings.length;

    return avg + variance;
  }

  /// Feedback message for the given points change.
  static String getFeedbackMessage(int pointsChange) {
    if (pointsChange >= 2) return '¡En la zona!';
    if (pointsChange == 1) return 'Cerca del óptimo';
    if (pointsChange == 0) return 'Sin cambios';
    if (pointsChange == -1) return 'Alejándote del objetivo';
    if (pointsChange == -4) return '¡Te has pasado! — Multa emitida';
    return '¡Policía de la Diversión!'; // -2
  }

  /// Feedback color enum for the given points change.
  static FeedbackColor getFeedbackColor(int pointsChange) {
    if (pointsChange >= 2) return FeedbackColor.green;
    if (pointsChange == 1) return FeedbackColor.yellow;
    if (pointsChange == 0) return FeedbackColor.neutral;
    if (pointsChange == -1) return FeedbackColor.orange;
    if (pointsChange == -4) return FeedbackColor.red;
    return FeedbackColor.blue; // -2
  }
}

/// Feedback color for UI
enum FeedbackColor { green, yellow, orange, red, blue, neutral }
