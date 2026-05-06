import 'package:freezed_annotation/freezed_annotation.dart';

part 'checkpoint_state.freezed.dart';
part 'checkpoint_state.g.dart';

/// Group checkpoint data - each group has its own timer
@freezed
class GroupCheckpoint with _$GroupCheckpoint {
  const factory GroupCheckpoint({
    required int groupIndex,
    required List<String> playerIds,
    required DateTime lastMeasurement,
    required int intervalMinutes,
    @Default(null) DateTime? nextCheckpoint,
  }) = _GroupCheckpoint;

  factory GroupCheckpoint.fromJson(Map<String, dynamic> json) =>
      _$GroupCheckpointFromJson(json);
}

/// Checkpoint state for per-group timer management
@freezed
class CheckpointState with _$CheckpointState {
  const factory CheckpointState({
    required int currentRound,
    required int intervalMinutes, // User-configurable (30, 45, or 60)
    required List<GroupCheckpoint> groups,
    @Default(false) bool isCheckpointActive,
    @Default(null) int? activeGroupIndex, // Which group is currently measuring
  }) = _CheckpointState;

  factory CheckpointState.fromJson(Map<String, dynamic> json) =>
      _$CheckpointStateFromJson(json);
}

/// Extension methods for GroupCheckpoint
extension GroupCheckpointX on GroupCheckpoint {
  /// Get time remaining until next checkpoint
  Duration get timeRemaining {
    final next = nextCheckpoint ?? lastMeasurement.add(Duration(minutes: intervalMinutes));
    final remaining = next.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Check if checkpoint is due
  bool get isDue => timeRemaining.inSeconds <= 0;

  /// Get formatted time remaining (MM:SS)
  String get formattedTimeRemaining {
    final minutes = timeRemaining.inMinutes;
    final seconds = timeRemaining.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Extension methods for CheckpointState
extension CheckpointStateX on CheckpointState {
  /// Get total number of groups
  int get totalGroups => groups.length;

  /// Get total number of players
  int get totalPlayers {
    return groups.fold(0, (sum, group) => sum + group.playerIds.length);
  }

  /// Get groups that are due for measurement
  List<GroupCheckpoint> get dueGroups {
    return groups.where((g) => g.isDue).toList();
  }

  /// Get active group (currently measuring)
  GroupCheckpoint? get activeGroup {
    if (activeGroupIndex == null || activeGroupIndex! >= groups.length) {
      return null;
    }
    return groups[activeGroupIndex!];
  }

  /// Check if any group is due
  bool get anyGroupDue => dueGroups.isNotEmpty;
}
