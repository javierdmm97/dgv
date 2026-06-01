// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bac_reading.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BACReading _$BACReadingFromJson(Map<String, dynamic> json) {
  return _BACReading.fromJson(json);
}

/// @nodoc
mixin _$BACReading {
  String get id => throw _privateConstructorUsedError;
  String get playerId => throw _privateConstructorUsedError;
  double get bac => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  int get roundNumber => throw _privateConstructorUsedError;
  BACEntryMethod get entryMethod => throw _privateConstructorUsedError;
  int get pointsChange => throw _privateConstructorUsedError;
  double get optimalBAC => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this BACReading to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BACReading
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BACReadingCopyWith<BACReading> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BACReadingCopyWith<$Res> {
  factory $BACReadingCopyWith(
    BACReading value,
    $Res Function(BACReading) then,
  ) = _$BACReadingCopyWithImpl<$Res, BACReading>;
  @useResult
  $Res call({
    String id,
    String playerId,
    double bac,
    DateTime timestamp,
    int roundNumber,
    BACEntryMethod entryMethod,
    int pointsChange,
    double optimalBAC,
    String? notes,
  });
}

/// @nodoc
class _$BACReadingCopyWithImpl<$Res, $Val extends BACReading>
    implements $BACReadingCopyWith<$Res> {
  _$BACReadingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BACReading
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? playerId = null,
    Object? bac = null,
    Object? timestamp = null,
    Object? roundNumber = null,
    Object? entryMethod = null,
    Object? pointsChange = null,
    Object? optimalBAC = null,
    Object? notes = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            playerId: null == playerId
                ? _value.playerId
                : playerId // ignore: cast_nullable_to_non_nullable
                      as String,
            bac: null == bac
                ? _value.bac
                : bac // ignore: cast_nullable_to_non_nullable
                      as double,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            roundNumber: null == roundNumber
                ? _value.roundNumber
                : roundNumber // ignore: cast_nullable_to_non_nullable
                      as int,
            entryMethod: null == entryMethod
                ? _value.entryMethod
                : entryMethod // ignore: cast_nullable_to_non_nullable
                      as BACEntryMethod,
            pointsChange: null == pointsChange
                ? _value.pointsChange
                : pointsChange // ignore: cast_nullable_to_non_nullable
                      as int,
            optimalBAC: null == optimalBAC
                ? _value.optimalBAC
                : optimalBAC // ignore: cast_nullable_to_non_nullable
                      as double,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BACReadingImplCopyWith<$Res>
    implements $BACReadingCopyWith<$Res> {
  factory _$$BACReadingImplCopyWith(
    _$BACReadingImpl value,
    $Res Function(_$BACReadingImpl) then,
  ) = __$$BACReadingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String playerId,
    double bac,
    DateTime timestamp,
    int roundNumber,
    BACEntryMethod entryMethod,
    int pointsChange,
    double optimalBAC,
    String? notes,
  });
}

/// @nodoc
class __$$BACReadingImplCopyWithImpl<$Res>
    extends _$BACReadingCopyWithImpl<$Res, _$BACReadingImpl>
    implements _$$BACReadingImplCopyWith<$Res> {
  __$$BACReadingImplCopyWithImpl(
    _$BACReadingImpl _value,
    $Res Function(_$BACReadingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BACReading
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? playerId = null,
    Object? bac = null,
    Object? timestamp = null,
    Object? roundNumber = null,
    Object? entryMethod = null,
    Object? pointsChange = null,
    Object? optimalBAC = null,
    Object? notes = freezed,
  }) {
    return _then(
      _$BACReadingImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        playerId: null == playerId
            ? _value.playerId
            : playerId // ignore: cast_nullable_to_non_nullable
                  as String,
        bac: null == bac
            ? _value.bac
            : bac // ignore: cast_nullable_to_non_nullable
                  as double,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        roundNumber: null == roundNumber
            ? _value.roundNumber
            : roundNumber // ignore: cast_nullable_to_non_nullable
                  as int,
        entryMethod: null == entryMethod
            ? _value.entryMethod
            : entryMethod // ignore: cast_nullable_to_non_nullable
                  as BACEntryMethod,
        pointsChange: null == pointsChange
            ? _value.pointsChange
            : pointsChange // ignore: cast_nullable_to_non_nullable
                  as int,
        optimalBAC: null == optimalBAC
            ? _value.optimalBAC
            : optimalBAC // ignore: cast_nullable_to_non_nullable
                  as double,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BACReadingImpl implements _BACReading {
  const _$BACReadingImpl({
    required this.id,
    required this.playerId,
    required this.bac,
    required this.timestamp,
    required this.roundNumber,
    required this.entryMethod,
    this.pointsChange = 0,
    this.optimalBAC = 0.0,
    this.notes = null,
  });

  factory _$BACReadingImpl.fromJson(Map<String, dynamic> json) =>
      _$$BACReadingImplFromJson(json);

  @override
  final String id;
  @override
  final String playerId;
  @override
  final double bac;
  @override
  final DateTime timestamp;
  @override
  final int roundNumber;
  @override
  final BACEntryMethod entryMethod;
  @override
  @JsonKey()
  final int pointsChange;
  @override
  @JsonKey()
  final double optimalBAC;
  @override
  @JsonKey()
  final String? notes;

  @override
  String toString() {
    return 'BACReading(id: $id, playerId: $playerId, bac: $bac, timestamp: $timestamp, roundNumber: $roundNumber, entryMethod: $entryMethod, pointsChange: $pointsChange, optimalBAC: $optimalBAC, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BACReadingImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.playerId, playerId) ||
                other.playerId == playerId) &&
            (identical(other.bac, bac) || other.bac == bac) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.roundNumber, roundNumber) ||
                other.roundNumber == roundNumber) &&
            (identical(other.entryMethod, entryMethod) ||
                other.entryMethod == entryMethod) &&
            (identical(other.pointsChange, pointsChange) ||
                other.pointsChange == pointsChange) &&
            (identical(other.optimalBAC, optimalBAC) ||
                other.optimalBAC == optimalBAC) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    playerId,
    bac,
    timestamp,
    roundNumber,
    entryMethod,
    pointsChange,
    optimalBAC,
    notes,
  );

  /// Create a copy of BACReading
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BACReadingImplCopyWith<_$BACReadingImpl> get copyWith =>
      __$$BACReadingImplCopyWithImpl<_$BACReadingImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BACReadingImplToJson(this);
  }
}

abstract class _BACReading implements BACReading {
  const factory _BACReading({
    required final String id,
    required final String playerId,
    required final double bac,
    required final DateTime timestamp,
    required final int roundNumber,
    required final BACEntryMethod entryMethod,
    final int pointsChange,
    final double optimalBAC,
    final String? notes,
  }) = _$BACReadingImpl;

  factory _BACReading.fromJson(Map<String, dynamic> json) =
      _$BACReadingImpl.fromJson;

  @override
  String get id;
  @override
  String get playerId;
  @override
  double get bac;
  @override
  DateTime get timestamp;
  @override
  int get roundNumber;
  @override
  BACEntryMethod get entryMethod;
  @override
  int get pointsChange;
  @override
  double get optimalBAC;
  @override
  String? get notes;

  /// Create a copy of BACReading
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BACReadingImplCopyWith<_$BACReadingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
