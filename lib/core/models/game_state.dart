import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_state.freezed.dart';
part 'game_state.g.dart';

/// Game state for persistence and recovery
@freezed
class GameState with _$GameState {
  const factory GameState({
    required String id,
    required DateTime startTime,
    required int currentRound,
    @Default(false) bool isInProgress,
    @Default(false) bool isFinished,
    @Default([]) List<String> playerIds,
    @Default(null) DateTime? lastCheckpointTime,
    @Default(null) DateTime? finishTime,
  }) = _GameState;

  factory GameState.fromJson(Map<String, dynamic> json) =>
      _$GameStateFromJson(json);
}

/// Extension methods for GameState
extension GameStateX on GameState {
  /// Check if this is the baseline round (Round 0)
  bool get isBaselineRound => currentRound == 0;

  /// Check if this is an active round (Round 1+)
  bool get isActiveRound => currentRound > 0;

  /// Get game duration
  Duration get duration {
    final endTime = finishTime ?? DateTime.now();
    return endTime.difference(startTime);
  }

  /// Get formatted game duration
  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '$hours h $minutes min';
    }
    return '$minutes min';
  }

  /// Check if game can be resumed
  bool get canResume => isInProgress && !isFinished;
}
