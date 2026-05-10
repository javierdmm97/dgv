// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'player_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PlayerProfile _$PlayerProfileFromJson(Map<String, dynamic> json) {
  return _PlayerProfile.fromJson(json);
}

/// @nodoc
mixin _$PlayerProfile {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get surname => throw _privateConstructorUsedError;
  String get photoPath => throw _privateConstructorUsedError;
  Sex get sex => throw _privateConstructorUsedError;
  BodySize get bodySize => throw _privateConstructorUsedError;
  int get points => throw _privateConstructorUsedError;
  List<BACReading> get readings => throw _privateConstructorUsedError;
  Map<DGTTitle, int> get titleCounts => throw _privateConstructorUsedError;
  bool get crossedOptimalLine => throw _privateConstructorUsedError;
  bool get isImpounded => throw _privateConstructorUsedError;
  double get optimalBAC => throw _privateConstructorUsedError;
  String get licenseImagePath => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this PlayerProfile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlayerProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlayerProfileCopyWith<PlayerProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlayerProfileCopyWith<$Res> {
  factory $PlayerProfileCopyWith(
    PlayerProfile value,
    $Res Function(PlayerProfile) then,
  ) = _$PlayerProfileCopyWithImpl<$Res, PlayerProfile>;
  @useResult
  $Res call({
    String id,
    String name,
    String surname,
    String photoPath,
    Sex sex,
    BodySize bodySize,
    int points,
    List<BACReading> readings,
    Map<DGTTitle, int> titleCounts,
    bool crossedOptimalLine,
    bool isImpounded,
    double optimalBAC,
    String licenseImagePath,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$PlayerProfileCopyWithImpl<$Res, $Val extends PlayerProfile>
    implements $PlayerProfileCopyWith<$Res> {
  _$PlayerProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlayerProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? surname = null,
    Object? photoPath = null,
    Object? sex = null,
    Object? bodySize = null,
    Object? points = null,
    Object? readings = null,
    Object? titleCounts = null,
    Object? crossedOptimalLine = null,
    Object? isImpounded = null,
    Object? optimalBAC = null,
    Object? licenseImagePath = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            surname: null == surname
                ? _value.surname
                : surname // ignore: cast_nullable_to_non_nullable
                      as String,
            photoPath: null == photoPath
                ? _value.photoPath
                : photoPath // ignore: cast_nullable_to_non_nullable
                      as String,
            sex: null == sex
                ? _value.sex
                : sex // ignore: cast_nullable_to_non_nullable
                      as Sex,
            bodySize: null == bodySize
                ? _value.bodySize
                : bodySize // ignore: cast_nullable_to_non_nullable
                      as BodySize,
            points: null == points
                ? _value.points
                : points // ignore: cast_nullable_to_non_nullable
                      as int,
            readings: null == readings
                ? _value.readings
                : readings // ignore: cast_nullable_to_non_nullable
                      as List<BACReading>,
            titleCounts: null == titleCounts
                ? _value.titleCounts
                : titleCounts // ignore: cast_nullable_to_non_nullable
                      as Map<DGTTitle, int>,
            crossedOptimalLine: null == crossedOptimalLine
                ? _value.crossedOptimalLine
                : crossedOptimalLine // ignore: cast_nullable_to_non_nullable
                      as bool,
            isImpounded: null == isImpounded
                ? _value.isImpounded
                : isImpounded // ignore: cast_nullable_to_non_nullable
                      as bool,
            optimalBAC: null == optimalBAC
                ? _value.optimalBAC
                : optimalBAC // ignore: cast_nullable_to_non_nullable
                      as double,
            licenseImagePath: null == licenseImagePath
                ? _value.licenseImagePath
                : licenseImagePath // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PlayerProfileImplCopyWith<$Res>
    implements $PlayerProfileCopyWith<$Res> {
  factory _$$PlayerProfileImplCopyWith(
    _$PlayerProfileImpl value,
    $Res Function(_$PlayerProfileImpl) then,
  ) = __$$PlayerProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String surname,
    String photoPath,
    Sex sex,
    BodySize bodySize,
    int points,
    List<BACReading> readings,
    Map<DGTTitle, int> titleCounts,
    bool crossedOptimalLine,
    bool isImpounded,
    double optimalBAC,
    String licenseImagePath,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$PlayerProfileImplCopyWithImpl<$Res>
    extends _$PlayerProfileCopyWithImpl<$Res, _$PlayerProfileImpl>
    implements _$$PlayerProfileImplCopyWith<$Res> {
  __$$PlayerProfileImplCopyWithImpl(
    _$PlayerProfileImpl _value,
    $Res Function(_$PlayerProfileImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PlayerProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? surname = null,
    Object? photoPath = null,
    Object? sex = null,
    Object? bodySize = null,
    Object? points = null,
    Object? readings = null,
    Object? titleCounts = null,
    Object? crossedOptimalLine = null,
    Object? isImpounded = null,
    Object? optimalBAC = null,
    Object? licenseImagePath = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$PlayerProfileImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        surname: null == surname
            ? _value.surname
            : surname // ignore: cast_nullable_to_non_nullable
                  as String,
        photoPath: null == photoPath
            ? _value.photoPath
            : photoPath // ignore: cast_nullable_to_non_nullable
                  as String,
        sex: null == sex
            ? _value.sex
            : sex // ignore: cast_nullable_to_non_nullable
                  as Sex,
        bodySize: null == bodySize
            ? _value.bodySize
            : bodySize // ignore: cast_nullable_to_non_nullable
                  as BodySize,
        points: null == points
            ? _value.points
            : points // ignore: cast_nullable_to_non_nullable
                  as int,
        readings: null == readings
            ? _value._readings
            : readings // ignore: cast_nullable_to_non_nullable
                  as List<BACReading>,
        titleCounts: null == titleCounts
            ? _value._titleCounts
            : titleCounts // ignore: cast_nullable_to_non_nullable
                  as Map<DGTTitle, int>,
        crossedOptimalLine: null == crossedOptimalLine
            ? _value.crossedOptimalLine
            : crossedOptimalLine // ignore: cast_nullable_to_non_nullable
                  as bool,
        isImpounded: null == isImpounded
            ? _value.isImpounded
            : isImpounded // ignore: cast_nullable_to_non_nullable
                  as bool,
        optimalBAC: null == optimalBAC
            ? _value.optimalBAC
            : optimalBAC // ignore: cast_nullable_to_non_nullable
                  as double,
        licenseImagePath: null == licenseImagePath
            ? _value.licenseImagePath
            : licenseImagePath // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PlayerProfileImpl implements _PlayerProfile {
  const _$PlayerProfileImpl({
    required this.id,
    required this.name,
    required this.surname,
    required this.photoPath,
    required this.sex,
    required this.bodySize,
    this.points = 15,
    final List<BACReading> readings = const [],
    final Map<DGTTitle, int> titleCounts = const {},
    this.crossedOptimalLine = false,
    this.isImpounded = false,
    required this.optimalBAC,
    required this.licenseImagePath,
    this.createdAt = null,
  }) : _readings = readings,
       _titleCounts = titleCounts;

  factory _$PlayerProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlayerProfileImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String surname;
  @override
  final String photoPath;
  @override
  final Sex sex;
  @override
  final BodySize bodySize;
  @override
  @JsonKey()
  final int points;
  final List<BACReading> _readings;
  @override
  @JsonKey()
  List<BACReading> get readings {
    if (_readings is EqualUnmodifiableListView) return _readings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_readings);
  }

  final Map<DGTTitle, int> _titleCounts;
  @override
  @JsonKey()
  Map<DGTTitle, int> get titleCounts {
    if (_titleCounts is EqualUnmodifiableMapView) return _titleCounts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_titleCounts);
  }

  @override
  @JsonKey()
  final bool crossedOptimalLine;
  @override
  @JsonKey()
  final bool isImpounded;
  @override
  final double optimalBAC;
  @override
  final String licenseImagePath;
  @override
  @JsonKey()
  final DateTime? createdAt;

  @override
  String toString() {
    return 'PlayerProfile(id: $id, name: $name, surname: $surname, photoPath: $photoPath, sex: $sex, bodySize: $bodySize, points: $points, readings: $readings, titleCounts: $titleCounts, crossedOptimalLine: $crossedOptimalLine, isImpounded: $isImpounded, optimalBAC: $optimalBAC, licenseImagePath: $licenseImagePath, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlayerProfileImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.surname, surname) || other.surname == surname) &&
            (identical(other.photoPath, photoPath) ||
                other.photoPath == photoPath) &&
            (identical(other.sex, sex) || other.sex == sex) &&
            (identical(other.bodySize, bodySize) ||
                other.bodySize == bodySize) &&
            (identical(other.points, points) || other.points == points) &&
            const DeepCollectionEquality().equals(other._readings, _readings) &&
            const DeepCollectionEquality().equals(
              other._titleCounts,
              _titleCounts,
            ) &&
            (identical(other.crossedOptimalLine, crossedOptimalLine) ||
                other.crossedOptimalLine == crossedOptimalLine) &&
            (identical(other.isImpounded, isImpounded) ||
                other.isImpounded == isImpounded) &&
            (identical(other.optimalBAC, optimalBAC) ||
                other.optimalBAC == optimalBAC) &&
            (identical(other.licenseImagePath, licenseImagePath) ||
                other.licenseImagePath == licenseImagePath) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    surname,
    photoPath,
    sex,
    bodySize,
    points,
    const DeepCollectionEquality().hash(_readings),
    const DeepCollectionEquality().hash(_titleCounts),
    crossedOptimalLine,
    isImpounded,
    optimalBAC,
    licenseImagePath,
    createdAt,
  );

  /// Create a copy of PlayerProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlayerProfileImplCopyWith<_$PlayerProfileImpl> get copyWith =>
      __$$PlayerProfileImplCopyWithImpl<_$PlayerProfileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlayerProfileImplToJson(this);
  }
}

abstract class _PlayerProfile implements PlayerProfile {
  const factory _PlayerProfile({
    required final String id,
    required final String name,
    required final String surname,
    required final String photoPath,
    required final Sex sex,
    required final BodySize bodySize,
    final int points,
    final List<BACReading> readings,
    final Map<DGTTitle, int> titleCounts,
    final bool crossedOptimalLine,
    final bool isImpounded,
    required final double optimalBAC,
    required final String licenseImagePath,
    final DateTime? createdAt,
  }) = _$PlayerProfileImpl;

  factory _PlayerProfile.fromJson(Map<String, dynamic> json) =
      _$PlayerProfileImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get surname;
  @override
  String get photoPath;
  @override
  Sex get sex;
  @override
  BodySize get bodySize;
  @override
  int get points;
  @override
  List<BACReading> get readings;
  @override
  Map<DGTTitle, int> get titleCounts;
  @override
  bool get crossedOptimalLine;
  @override
  bool get isImpounded;
  @override
  double get optimalBAC;
  @override
  String get licenseImagePath;
  @override
  DateTime? get createdAt;

  /// Create a copy of PlayerProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlayerProfileImplCopyWith<_$PlayerProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
