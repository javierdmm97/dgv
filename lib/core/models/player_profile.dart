import 'package:freezed_annotation/freezed_annotation.dart';
import 'bac_reading.dart';
import 'dgt_title.dart';

part 'player_profile.freezed.dart';
part 'player_profile.g.dart';

/// Player sex for BrAC table lookup
enum Sex {
  @JsonValue('male')
  male,
  @JsonValue('female')
  female,
}

/// Body size for optimal BrAC calculation
enum BodySize {
  @JsonValue('small')
  small,
  @JsonValue('medium')
  medium,
  @JsonValue('large')
  large,
}

/// Player profile with all game data
@freezed
class PlayerProfile with _$PlayerProfile {
  const factory PlayerProfile({
    required String id,
    required String name,
    required String surname,
    required String photoPath,
    required Sex sex,
    required BodySize bodySize,
    @Default(15) int points,
    @Default([]) List<BACReading> readings,
    @Default({}) Map<DGTTitle, int> titleCounts,
    @Default(false) bool crossedOptimalLine,
    @Default(0) int fineCount,
    @Default(0) int moneyLost,
    required String licenseImagePath,
    @Default(null) DateTime? createdAt,
    @Default(null) String? licenseBackImagePath,
  }) = _PlayerProfile;

  factory PlayerProfile.fromJson(Map<String, dynamic> json) =>
      _$PlayerProfileFromJson(json);
}

/// Extension methods for PlayerProfile
extension PlayerProfileX on PlayerProfile {
  /// Get current BAC (latest reading)
  double? get currentBAC {
    if (readings.isEmpty) return null;
    return readings.last.bac;
  }

  /// Get previous BAC (second to last reading)
  double? get previousBAC {
    if (readings.length < 2) return null;
    return readings[readings.length - 2].bac;
  }

  /// Get maximum BAC across all readings
  double get maxBAC {
    if (readings.isEmpty) return 0.0;
    return readings.map((r) => r.bac).reduce((a, b) => a > b ? a : b);
  }

  /// Get average BAC across all readings
  double get averageBAC {
    if (readings.isEmpty) return 0.0;
    final sum = readings.map((r) => r.bac).reduce((a, b) => a + b);
    return sum / readings.length;
  }

  /// Get total number of titles earned
  int get totalTitles {
    return titleCounts.values.fold(0, (sum, count) => sum + count);
  }

  /// Check if player has any readings
  bool get hasReadings => readings.isNotEmpty;

  /// Get readings for a specific round
  List<BACReading> readingsForRound(int roundNumber) {
    return readings.where((r) => r.roundNumber == roundNumber).toList();
  }

  /// Get latest reading for a specific round
  BACReading? latestReadingForRound(int roundNumber) {
    final roundReadings = readingsForRound(roundNumber);
    if (roundReadings.isEmpty) return null;
    return roundReadings.last;
  }
}
