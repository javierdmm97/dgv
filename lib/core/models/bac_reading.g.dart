// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bac_reading.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BACReadingImpl _$$BACReadingImplFromJson(Map<String, dynamic> json) =>
    _$BACReadingImpl(
      id: json['id'] as String,
      playerId: json['playerId'] as String,
      bac: (json['bac'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      roundNumber: (json['roundNumber'] as num).toInt(),
      entryMethod: $enumDecode(_$BACEntryMethodEnumMap, json['entryMethod']),
      pointsChange: (json['pointsChange'] as num?)?.toInt() ?? 0,
      optimalBAC: (json['optimalBAC'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'] as String? ?? null,
    );

Map<String, dynamic> _$$BACReadingImplToJson(_$BACReadingImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'playerId': instance.playerId,
      'bac': instance.bac,
      'timestamp': instance.timestamp.toIso8601String(),
      'roundNumber': instance.roundNumber,
      'entryMethod': _$BACEntryMethodEnumMap[instance.entryMethod]!,
      'pointsChange': instance.pointsChange,
      'optimalBAC': instance.optimalBAC,
      'notes': instance.notes,
    };

const _$BACEntryMethodEnumMap = {
  BACEntryMethod.manual: 'manual',
  BACEntryMethod.ocr: 'ocr',
  BACEntryMethod.roundRobin: 'roundRobin',
};
