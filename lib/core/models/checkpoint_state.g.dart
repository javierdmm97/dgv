// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkpoint_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GroupCheckpointImpl _$$GroupCheckpointImplFromJson(
  Map<String, dynamic> json,
) => _$GroupCheckpointImpl(
  groupIndex: (json['groupIndex'] as num).toInt(),
  playerIds: (json['playerIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  lastMeasurement: DateTime.parse(json['lastMeasurement'] as String),
  intervalMinutes: (json['intervalMinutes'] as num).toInt(),
  nextCheckpoint: json['nextCheckpoint'] == null
      ? null
      : DateTime.parse(json['nextCheckpoint'] as String),
);

Map<String, dynamic> _$$GroupCheckpointImplToJson(
  _$GroupCheckpointImpl instance,
) => <String, dynamic>{
  'groupIndex': instance.groupIndex,
  'playerIds': instance.playerIds,
  'lastMeasurement': instance.lastMeasurement.toIso8601String(),
  'intervalMinutes': instance.intervalMinutes,
  'nextCheckpoint': instance.nextCheckpoint?.toIso8601String(),
};

_$CheckpointStateImpl _$$CheckpointStateImplFromJson(
  Map<String, dynamic> json,
) => _$CheckpointStateImpl(
  currentRound: (json['currentRound'] as num).toInt(),
  intervalMinutes: (json['intervalMinutes'] as num).toInt(),
  groups: (json['groups'] as List<dynamic>)
      .map((e) => GroupCheckpoint.fromJson(e as Map<String, dynamic>))
      .toList(),
  isCheckpointActive: json['isCheckpointActive'] as bool? ?? false,
  activeGroupIndex: (json['activeGroupIndex'] as num?)?.toInt() ?? null,
);

Map<String, dynamic> _$$CheckpointStateImplToJson(
  _$CheckpointStateImpl instance,
) => <String, dynamic>{
  'currentRound': instance.currentRound,
  'intervalMinutes': instance.intervalMinutes,
  'groups': instance.groups,
  'isCheckpointActive': instance.isCheckpointActive,
  'activeGroupIndex': instance.activeGroupIndex,
};
