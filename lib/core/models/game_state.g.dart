// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GameStateImpl _$$GameStateImplFromJson(Map<String, dynamic> json) =>
    _$GameStateImpl(
      id: json['id'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      currentRound: (json['currentRound'] as num).toInt(),
      isInProgress: json['isInProgress'] as bool? ?? false,
      isFinished: json['isFinished'] as bool? ?? false,
      playerIds:
          (json['playerIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      lastCheckpointTime: json['lastCheckpointTime'] == null
          ? null
          : DateTime.parse(json['lastCheckpointTime'] as String),
      finishTime: json['finishTime'] == null
          ? null
          : DateTime.parse(json['finishTime'] as String),
    );

Map<String, dynamic> _$$GameStateImplToJson(_$GameStateImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'startTime': instance.startTime.toIso8601String(),
      'currentRound': instance.currentRound,
      'isInProgress': instance.isInProgress,
      'isFinished': instance.isFinished,
      'playerIds': instance.playerIds,
      'lastCheckpointTime': instance.lastCheckpointTime?.toIso8601String(),
      'finishTime': instance.finishTime?.toIso8601String(),
    };
