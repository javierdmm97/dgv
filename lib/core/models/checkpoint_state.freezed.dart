// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'checkpoint_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

GroupCheckpoint _$GroupCheckpointFromJson(Map<String, dynamic> json) {
  return _GroupCheckpoint.fromJson(json);
}

/// @nodoc
mixin _$GroupCheckpoint {
  int get groupIndex => throw _privateConstructorUsedError;
  List<String> get playerIds => throw _privateConstructorUsedError;
  DateTime get lastMeasurement => throw _privateConstructorUsedError;
  int get intervalMinutes => throw _privateConstructorUsedError;
  DateTime? get nextCheckpoint => throw _privateConstructorUsedError;

  /// Serializes this GroupCheckpoint to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GroupCheckpoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GroupCheckpointCopyWith<GroupCheckpoint> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GroupCheckpointCopyWith<$Res> {
  factory $GroupCheckpointCopyWith(
    GroupCheckpoint value,
    $Res Function(GroupCheckpoint) then,
  ) = _$GroupCheckpointCopyWithImpl<$Res, GroupCheckpoint>;
  @useResult
  $Res call({
    int groupIndex,
    List<String> playerIds,
    DateTime lastMeasurement,
    int intervalMinutes,
    DateTime? nextCheckpoint,
  });
}

/// @nodoc
class _$GroupCheckpointCopyWithImpl<$Res, $Val extends GroupCheckpoint>
    implements $GroupCheckpointCopyWith<$Res> {
  _$GroupCheckpointCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GroupCheckpoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? groupIndex = null,
    Object? playerIds = null,
    Object? lastMeasurement = null,
    Object? intervalMinutes = null,
    Object? nextCheckpoint = freezed,
  }) {
    return _then(
      _value.copyWith(
            groupIndex: null == groupIndex
                ? _value.groupIndex
                : groupIndex // ignore: cast_nullable_to_non_nullable
                      as int,
            playerIds: null == playerIds
                ? _value.playerIds
                : playerIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            lastMeasurement: null == lastMeasurement
                ? _value.lastMeasurement
                : lastMeasurement // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            intervalMinutes: null == intervalMinutes
                ? _value.intervalMinutes
                : intervalMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            nextCheckpoint: freezed == nextCheckpoint
                ? _value.nextCheckpoint
                : nextCheckpoint // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GroupCheckpointImplCopyWith<$Res>
    implements $GroupCheckpointCopyWith<$Res> {
  factory _$$GroupCheckpointImplCopyWith(
    _$GroupCheckpointImpl value,
    $Res Function(_$GroupCheckpointImpl) then,
  ) = __$$GroupCheckpointImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int groupIndex,
    List<String> playerIds,
    DateTime lastMeasurement,
    int intervalMinutes,
    DateTime? nextCheckpoint,
  });
}

/// @nodoc
class __$$GroupCheckpointImplCopyWithImpl<$Res>
    extends _$GroupCheckpointCopyWithImpl<$Res, _$GroupCheckpointImpl>
    implements _$$GroupCheckpointImplCopyWith<$Res> {
  __$$GroupCheckpointImplCopyWithImpl(
    _$GroupCheckpointImpl _value,
    $Res Function(_$GroupCheckpointImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GroupCheckpoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? groupIndex = null,
    Object? playerIds = null,
    Object? lastMeasurement = null,
    Object? intervalMinutes = null,
    Object? nextCheckpoint = freezed,
  }) {
    return _then(
      _$GroupCheckpointImpl(
        groupIndex: null == groupIndex
            ? _value.groupIndex
            : groupIndex // ignore: cast_nullable_to_non_nullable
                  as int,
        playerIds: null == playerIds
            ? _value._playerIds
            : playerIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        lastMeasurement: null == lastMeasurement
            ? _value.lastMeasurement
            : lastMeasurement // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        intervalMinutes: null == intervalMinutes
            ? _value.intervalMinutes
            : intervalMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        nextCheckpoint: freezed == nextCheckpoint
            ? _value.nextCheckpoint
            : nextCheckpoint // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GroupCheckpointImpl implements _GroupCheckpoint {
  const _$GroupCheckpointImpl({
    required this.groupIndex,
    required final List<String> playerIds,
    required this.lastMeasurement,
    required this.intervalMinutes,
    this.nextCheckpoint = null,
  }) : _playerIds = playerIds;

  factory _$GroupCheckpointImpl.fromJson(Map<String, dynamic> json) =>
      _$$GroupCheckpointImplFromJson(json);

  @override
  final int groupIndex;
  final List<String> _playerIds;
  @override
  List<String> get playerIds {
    if (_playerIds is EqualUnmodifiableListView) return _playerIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_playerIds);
  }

  @override
  final DateTime lastMeasurement;
  @override
  final int intervalMinutes;
  @override
  @JsonKey()
  final DateTime? nextCheckpoint;

  @override
  String toString() {
    return 'GroupCheckpoint(groupIndex: $groupIndex, playerIds: $playerIds, lastMeasurement: $lastMeasurement, intervalMinutes: $intervalMinutes, nextCheckpoint: $nextCheckpoint)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GroupCheckpointImpl &&
            (identical(other.groupIndex, groupIndex) ||
                other.groupIndex == groupIndex) &&
            const DeepCollectionEquality().equals(
              other._playerIds,
              _playerIds,
            ) &&
            (identical(other.lastMeasurement, lastMeasurement) ||
                other.lastMeasurement == lastMeasurement) &&
            (identical(other.intervalMinutes, intervalMinutes) ||
                other.intervalMinutes == intervalMinutes) &&
            (identical(other.nextCheckpoint, nextCheckpoint) ||
                other.nextCheckpoint == nextCheckpoint));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    groupIndex,
    const DeepCollectionEquality().hash(_playerIds),
    lastMeasurement,
    intervalMinutes,
    nextCheckpoint,
  );

  /// Create a copy of GroupCheckpoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GroupCheckpointImplCopyWith<_$GroupCheckpointImpl> get copyWith =>
      __$$GroupCheckpointImplCopyWithImpl<_$GroupCheckpointImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$GroupCheckpointImplToJson(this);
  }
}

abstract class _GroupCheckpoint implements GroupCheckpoint {
  const factory _GroupCheckpoint({
    required final int groupIndex,
    required final List<String> playerIds,
    required final DateTime lastMeasurement,
    required final int intervalMinutes,
    final DateTime? nextCheckpoint,
  }) = _$GroupCheckpointImpl;

  factory _GroupCheckpoint.fromJson(Map<String, dynamic> json) =
      _$GroupCheckpointImpl.fromJson;

  @override
  int get groupIndex;
  @override
  List<String> get playerIds;
  @override
  DateTime get lastMeasurement;
  @override
  int get intervalMinutes;
  @override
  DateTime? get nextCheckpoint;

  /// Create a copy of GroupCheckpoint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GroupCheckpointImplCopyWith<_$GroupCheckpointImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CheckpointState _$CheckpointStateFromJson(Map<String, dynamic> json) {
  return _CheckpointState.fromJson(json);
}

/// @nodoc
mixin _$CheckpointState {
  int get currentRound => throw _privateConstructorUsedError;
  int get intervalMinutes =>
      throw _privateConstructorUsedError; // User-configurable (30, 45, or 60)
  List<GroupCheckpoint> get groups => throw _privateConstructorUsedError;
  bool get isCheckpointActive => throw _privateConstructorUsedError;
  int? get activeGroupIndex => throw _privateConstructorUsedError;

  /// Serializes this CheckpointState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CheckpointState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CheckpointStateCopyWith<CheckpointState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CheckpointStateCopyWith<$Res> {
  factory $CheckpointStateCopyWith(
    CheckpointState value,
    $Res Function(CheckpointState) then,
  ) = _$CheckpointStateCopyWithImpl<$Res, CheckpointState>;
  @useResult
  $Res call({
    int currentRound,
    int intervalMinutes,
    List<GroupCheckpoint> groups,
    bool isCheckpointActive,
    int? activeGroupIndex,
  });
}

/// @nodoc
class _$CheckpointStateCopyWithImpl<$Res, $Val extends CheckpointState>
    implements $CheckpointStateCopyWith<$Res> {
  _$CheckpointStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CheckpointState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentRound = null,
    Object? intervalMinutes = null,
    Object? groups = null,
    Object? isCheckpointActive = null,
    Object? activeGroupIndex = freezed,
  }) {
    return _then(
      _value.copyWith(
            currentRound: null == currentRound
                ? _value.currentRound
                : currentRound // ignore: cast_nullable_to_non_nullable
                      as int,
            intervalMinutes: null == intervalMinutes
                ? _value.intervalMinutes
                : intervalMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            groups: null == groups
                ? _value.groups
                : groups // ignore: cast_nullable_to_non_nullable
                      as List<GroupCheckpoint>,
            isCheckpointActive: null == isCheckpointActive
                ? _value.isCheckpointActive
                : isCheckpointActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            activeGroupIndex: freezed == activeGroupIndex
                ? _value.activeGroupIndex
                : activeGroupIndex // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CheckpointStateImplCopyWith<$Res>
    implements $CheckpointStateCopyWith<$Res> {
  factory _$$CheckpointStateImplCopyWith(
    _$CheckpointStateImpl value,
    $Res Function(_$CheckpointStateImpl) then,
  ) = __$$CheckpointStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int currentRound,
    int intervalMinutes,
    List<GroupCheckpoint> groups,
    bool isCheckpointActive,
    int? activeGroupIndex,
  });
}

/// @nodoc
class __$$CheckpointStateImplCopyWithImpl<$Res>
    extends _$CheckpointStateCopyWithImpl<$Res, _$CheckpointStateImpl>
    implements _$$CheckpointStateImplCopyWith<$Res> {
  __$$CheckpointStateImplCopyWithImpl(
    _$CheckpointStateImpl _value,
    $Res Function(_$CheckpointStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CheckpointState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentRound = null,
    Object? intervalMinutes = null,
    Object? groups = null,
    Object? isCheckpointActive = null,
    Object? activeGroupIndex = freezed,
  }) {
    return _then(
      _$CheckpointStateImpl(
        currentRound: null == currentRound
            ? _value.currentRound
            : currentRound // ignore: cast_nullable_to_non_nullable
                  as int,
        intervalMinutes: null == intervalMinutes
            ? _value.intervalMinutes
            : intervalMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        groups: null == groups
            ? _value._groups
            : groups // ignore: cast_nullable_to_non_nullable
                  as List<GroupCheckpoint>,
        isCheckpointActive: null == isCheckpointActive
            ? _value.isCheckpointActive
            : isCheckpointActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        activeGroupIndex: freezed == activeGroupIndex
            ? _value.activeGroupIndex
            : activeGroupIndex // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CheckpointStateImpl implements _CheckpointState {
  const _$CheckpointStateImpl({
    required this.currentRound,
    required this.intervalMinutes,
    required final List<GroupCheckpoint> groups,
    this.isCheckpointActive = false,
    this.activeGroupIndex = null,
  }) : _groups = groups;

  factory _$CheckpointStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$CheckpointStateImplFromJson(json);

  @override
  final int currentRound;
  @override
  final int intervalMinutes;
  // User-configurable (30, 45, or 60)
  final List<GroupCheckpoint> _groups;
  // User-configurable (30, 45, or 60)
  @override
  List<GroupCheckpoint> get groups {
    if (_groups is EqualUnmodifiableListView) return _groups;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_groups);
  }

  @override
  @JsonKey()
  final bool isCheckpointActive;
  @override
  @JsonKey()
  final int? activeGroupIndex;

  @override
  String toString() {
    return 'CheckpointState(currentRound: $currentRound, intervalMinutes: $intervalMinutes, groups: $groups, isCheckpointActive: $isCheckpointActive, activeGroupIndex: $activeGroupIndex)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CheckpointStateImpl &&
            (identical(other.currentRound, currentRound) ||
                other.currentRound == currentRound) &&
            (identical(other.intervalMinutes, intervalMinutes) ||
                other.intervalMinutes == intervalMinutes) &&
            const DeepCollectionEquality().equals(other._groups, _groups) &&
            (identical(other.isCheckpointActive, isCheckpointActive) ||
                other.isCheckpointActive == isCheckpointActive) &&
            (identical(other.activeGroupIndex, activeGroupIndex) ||
                other.activeGroupIndex == activeGroupIndex));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    currentRound,
    intervalMinutes,
    const DeepCollectionEquality().hash(_groups),
    isCheckpointActive,
    activeGroupIndex,
  );

  /// Create a copy of CheckpointState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CheckpointStateImplCopyWith<_$CheckpointStateImpl> get copyWith =>
      __$$CheckpointStateImplCopyWithImpl<_$CheckpointStateImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CheckpointStateImplToJson(this);
  }
}

abstract class _CheckpointState implements CheckpointState {
  const factory _CheckpointState({
    required final int currentRound,
    required final int intervalMinutes,
    required final List<GroupCheckpoint> groups,
    final bool isCheckpointActive,
    final int? activeGroupIndex,
  }) = _$CheckpointStateImpl;

  factory _CheckpointState.fromJson(Map<String, dynamic> json) =
      _$CheckpointStateImpl.fromJson;

  @override
  int get currentRound;
  @override
  int get intervalMinutes; // User-configurable (30, 45, or 60)
  @override
  List<GroupCheckpoint> get groups;
  @override
  bool get isCheckpointActive;
  @override
  int? get activeGroupIndex;

  /// Create a copy of CheckpointState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CheckpointStateImplCopyWith<_$CheckpointStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
