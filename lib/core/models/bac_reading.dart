import 'package:freezed_annotation/freezed_annotation.dart';

part 'bac_reading.freezed.dart';
part 'bac_reading.g.dart';

/// BAC reading entry method
enum BACEntryMethod {
  @JsonValue('manual')
  manual,
  @JsonValue('ocr')
  ocr,
  @JsonValue('roundRobin')
  roundRobin,
}

/// Single BAC (Blood Alcohol Content) reading
@freezed
class BACReading with _$BACReading {
  const factory BACReading({
    required String id,
    required String playerId,
    required double bac,
    required DateTime timestamp,
    required int roundNumber,
    required BACEntryMethod entryMethod,
    @Default(0) int pointsChange,
    @Default(0.0) double optimalBAC,
    @Default(null) String? notes,
  }) = _BACReading;

  factory BACReading.fromJson(Map<String, dynamic> json) =>
      _$BACReadingFromJson(json);
}

/// Extension methods for BACReading
extension BACReadingX on BACReading {
  /// Check if this is a baseline reading (Round 0)
  bool get isBaseline => roundNumber == 0;

  /// Check if this is an active round reading (Round 1+)
  bool get isActiveRound => roundNumber > 0;

  /// Get formatted BAC string (e.g., "0.45")
  String get formattedBAC => bac.toStringAsFixed(2);

  /// Get formatted timestamp
  String get formattedTimestamp {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Get points change with sign (e.g., "+2", "-3")
  String get formattedPointsChange {
    if (pointsChange > 0) return '+$pointsChange';
    return pointsChange.toString();
  }
}
