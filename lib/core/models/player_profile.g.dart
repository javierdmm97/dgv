// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlayerProfileImpl _$$PlayerProfileImplFromJson(Map<String, dynamic> json) =>
    _$PlayerProfileImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      surname: json['surname'] as String,
      photoPath: json['photoPath'] as String,
      sex: $enumDecode(_$SexEnumMap, json['sex']),
      bodySize: $enumDecode(_$BodySizeEnumMap, json['bodySize']),
      points: (json['points'] as num?)?.toInt() ?? 15,
      readings:
          (json['readings'] as List<dynamic>?)
              ?.map((e) => BACReading.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      titleCounts:
          (json['titleCounts'] as Map<String, dynamic>?)?.map(
            (k, e) =>
                MapEntry($enumDecode(_$DGTTitleEnumMap, k), (e as num).toInt()),
          ) ??
          const {},
      crossedOptimalLine: json['crossedOptimalLine'] as bool? ?? false,
      fineCount: (json['fineCount'] as num?)?.toInt() ?? 0,
      moneyLost: (json['moneyLost'] as num?)?.toInt() ?? 0,
      licenseImagePath: json['licenseImagePath'] as String,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$PlayerProfileImplToJson(_$PlayerProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'surname': instance.surname,
      'photoPath': instance.photoPath,
      'sex': _$SexEnumMap[instance.sex]!,
      'bodySize': _$BodySizeEnumMap[instance.bodySize]!,
      'points': instance.points,
      'readings': instance.readings,
      'titleCounts': instance.titleCounts.map(
        (k, e) => MapEntry(_$DGTTitleEnumMap[k]!, e),
      ),
      'crossedOptimalLine': instance.crossedOptimalLine,
      'fineCount': instance.fineCount,
      'moneyLost': instance.moneyLost,
      'licenseImagePath': instance.licenseImagePath,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

const _$SexEnumMap = {Sex.male: 'male', Sex.female: 'female'};

const _$BodySizeEnumMap = {
  BodySize.small: 'small',
  BodySize.medium: 'medium',
  BodySize.large: 'large',
};

const _$DGTTitleEnumMap = {
  DGTTitle.velocidadDeCrucero: 'velocidad_de_crucero',
  DGTTitle.multaPorExceso: 'multa_por_exceso',
  DGTTitle.lDePracticas: 'l_de_practicas',
  DGTTitle.vehiculoHibrido: 'vehiculo_hibrido',
  DGTTitle.itvPassed: 'itv_pasada',
};
