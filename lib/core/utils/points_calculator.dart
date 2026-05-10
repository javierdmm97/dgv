import '../constants/app_constants.dart';
import '../models/bac_reading.dart';
import 'bac_calculator.dart';

/// Points calculation logic (hybrid system)
class PointsCalculator {
  PointsCalculator._();

  /// Calculate points change based on BAC relative to optimal zone
  /// Returns positive for gains, negative for penalties
  static int calculatePointsChange({
    required double currentBAC,
    required double optimalBAC,
    required double previousBAC,
    required Duration timeDelta,
  }) {
    // Check if in optimal zone (±0.02)
    if (BACCalculator.isInOptimalZone(currentBAC, optimalBAC)) {
      return AppConstants.pointsInOptimalZone; // +2 points
    }

    // Check if close to optimal (±0.02-0.05)
    if (BACCalculator.isCloseToOptimal(currentBAC, optimalBAC)) {
      return AppConstants.pointsCloseToOptimal; // +1 point
    }

    // Check if crossed the optimal line (>+0.05)
    if (BACCalculator.crossedOptimalLine(currentBAC, optimalBAC)) {
      return AppConstants.pointsCrossedOptimalLine; // -3 points
    }

    // Check if too low (<-0.05 from optimal)
    if (BACCalculator.isTooLow(currentBAC, optimalBAC)) {
      return 0; // No points (not drinking enough)
    }

    // Check for dangerous spike (>0.15/hr)
    if (BACCalculator.isDangerousSpike(currentBAC, previousBAC, timeDelta)) {
      return AppConstants.pointsDangerousSpike; // -2 points
    }

    return 0; // Default: no change
  }

  /// Check if player exceeded maximum BAC threshold (impoundment)
  static bool isImpounded(double currentBAC) {
    return currentBAC >= AppConstants.impoundmentThreshold;
  }

  /// Calculate impoundment penalty
  static int getImpoundmentPenalty() {
    return AppConstants.pointsImpounded; // -5 points
  }

  /// Calculate average distance from optimal zone across all readings
  static double calculateAverageDistanceFromOptimal(
    List<BACReading> readings,
    double optimalBAC,
  ) {
    if (readings.isEmpty) return double.infinity;

    final distances = readings.map((r) => (r.bac - optimalBAC).abs());
    return distances.reduce((a, b) => a + b) / readings.length;
  }

  /// Calculate total points for a player (clamped between min and max)
  static int calculateTotalPoints(int currentPoints, int pointsChange) {
    final newPoints = currentPoints + pointsChange;
    return newPoints.clamp(AppConstants.minPoints, AppConstants.maxPoints);
  }

  /// Get feedback message based on points change
  static String getFeedbackMessage(int pointsChange) {
    if (pointsChange >= AppConstants.pointsInOptimalZone) {
      return '¡En la zona óptima!';
    } else if (pointsChange == AppConstants.pointsCloseToOptimal) {
      return 'Cerca del óptimo';
    } else if (pointsChange == AppConstants.pointsCrossedOptimalLine) {
      return '¡Has cruzado la línea!';
    } else if (pointsChange == AppConstants.pointsDangerousSpike) {
      return '¡Subida peligrosa!';
    } else if (pointsChange == AppConstants.pointsImpounded) {
      return '¡VEHÍCULO INMOVILIZADO!';
    } else if (pointsChange == 0) {
      return 'Sin cambios';
    }
    return 'Lectura registrada';
  }

  /// Get feedback color based on points change
  static FeedbackColor getFeedbackColor(int pointsChange) {
    if (pointsChange >= AppConstants.pointsInOptimalZone) {
      return FeedbackColor.green;
    } else if (pointsChange == AppConstants.pointsCloseToOptimal) {
      return FeedbackColor.yellow;
    } else if (pointsChange < 0) {
      return FeedbackColor.red;
    }
    return FeedbackColor.neutral;
  }
}

/// Feedback color for UI
enum FeedbackColor { green, yellow, red, neutral }
