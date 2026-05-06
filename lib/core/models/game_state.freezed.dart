// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

GameState _$GameStateFromJson(Map<String, dynamic> json) {
  return _GameState.fromJson(json);
}

/// @nodoc
mixin _$GameState {
  String get id => throw _privateConstructorUsedError;
  DateTime get startTime => throw _privateConstructorUsedError;
  int get currentRound => throw _privateConstructorUsedError;
  bool get isInProgress => throw _privateConstructorUsedError;
  bool get isFinished => throw _privateConstructorUsedError;
  List<String> get playerIds => throw _privateConstructorUsedError;
  DateTime? get lastCheckpointTime => throw _privateConstructorUsedError;
  DateTime? get finishTime => throw _privateConstructorUsedError;

  /// Serializes this GameState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameStateCopyWith<GameState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameStateCopyWith<$Res> {
  factory $GameStateCopyWith(GameState value, $Res Function(GameState) then) =
      _$GameStateCopyWithImpl<$Res, GameState>;
  @useResult
  $Res call({
    String id,
    DateTime startTime,
    int currentRound,
    bool isInProgress,
    bool isFinished,
    List<String> playerIds,
    DateTime? lastCheckpointTime,
    DateTime? finishTime,
  });
}

/// @nodoc
class _$GameStateCopyWithImpl<$Res, $Val extends GameState>
    implements $GameStateCopyWith<$Res> {
  _$GameStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? startTime = null,
    Object? currentRound = null,
    Object? isInProgress = null,
    Object? isFinished = null,
    Object? playerIds = null,
    Object? lastCheckpointTime = freezed,
    Object? finishTime = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            startTime: null == startTime
                ? _value.startTime
                : startTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            currentRound: null == currentRound
                ? _value.currentRound
                : currentRound // ignore: cast_nullable_to_non_nullable
                      as int,
            isInProgress: null == isInProgress
                ? _value.isInProgress
                : isInProgress // ignore: cast_nullable_to_non_nullable
                      as bool,
            isFinished: null == isFinished
                ? _value.isFinished
                : isFinished // ignore: cast_nullable_to_non_nullable
                      as bool,
            playerIds: null == playerIds
                ? _value.playerIds
                : playerIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            lastCheckpointTime: freezed == lastCheckpointTime
                ? _value.lastCheckpointTime
                : lastCheckpointTime // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            finishTime: freezed == finishTime
                ? _value.finishTime
                : finishTime // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GameStateImplCopyWith<$Res>
    implements $GameStateCopyWith<$Res> {
  factory _$$GameStateImplCopyWith(
    _$GameStateImpl value,
    $Res Function(_$GameStateImpl) then,
  ) = __$$GameStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    DateTime startTime,
    int currentRound,
    bool isInProgress,
    bool isFinished,
    List<String> playerIds,
    DateTime? lastCheckpointTime,
    DateTime? finishTime,
  });
}

/// @nodoc
class __$$GameStateImplCopyWithImpl<$Res>
    extends _$GameStateCopyWithImpl<$Res, _$GameStateImpl>
    implements _$$GameStateImplCopyWith<$Res> {
  __$$GameStateImplCopyWithImpl(
    _$GameStateImpl _value,
    $Res Function(_$GameStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? startTime = null,
    Object? currentRound = null,
    Object? isInProgress = null,
    Object? isFinished = null,
    Object? playerIds = null,
    Object? lastCheckpointTime = freezed,
    Object? finishTime = freezed,
  }) {
    return _then(
      _$GameStateImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        startTime: null == startTime
            ? _value.startTime
            : startTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        currentRound: null == currentRound
            ? _value.currentRound
            : currentRound // ignore: cast_nullable_to_non_nullable
                  as int,
        isInProgress: null == isInProgress
            ? _value.isInProgress
            : isInProgress // ignore: cast_nullable_to_non_nullable
                  as bool,
        isFinished: null == isFinished
            ? _value.isFinished
            : isFinished // ignore: cast_nullable_to_non_nullable
                  as bool,
        playerIds: null == playerIds
            ? _value._playerIds
            : playerIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        lastCheckpointTime: freezed == lastCheckpointTime
            ? _value.lastCheckpointTime
            : lastCheckpointTime // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        finishTime: freezed == finishTime
            ? _value.finishTime
            : finishTime // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GameStateImpl implements _GameState {
  const _$GameStateImpl({
    required this.id,
    required this.startTime,
    required this.currentRound,
    this.isInProgress = false,
    this.isFinished = false,
    final List<String> playerIds = const [],
    this.lastCheckpointTime = null,
    this.finishTime = null,
  }) : _playerIds = playerIds;

  factory _$GameStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameStateImplFromJson(json);

  @override
  final String id;
  @override
  final DateTime startTime;
  @override
  final int currentRound;
  @override
  @JsonKey()
  final bool isInProgress;
  @override
  @JsonKey()
  final bool isFinished;
  final List<String> _playerIds;
  @override
  @JsonKey()
  List<String> get playerIds {
    if (_playerIds is EqualUnmodifiableListView) return _playerIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_playerIds);
  }

  @override
  @JsonKey()
  final DateTime? lastCheckpointTime;
  @override
  @JsonKey()
  final DateTime? finishTime;

  @override
  String toString() {
    return 'GameState(id: $id, startTime: $startTime, currentRound: $currentRound, isInProgress: $isInProgress, isFinished: $isFinished, playerIds: $playerIds, lastCheckpointTime: $lastCheckpointTime, finishTime: $finishTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameStateImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.currentRound, currentRound) ||
                other.currentRound == currentRound) &&
            (identical(other.isInProgress, isInProgress) ||
                other.isInProgress == isInProgress) &&
            (identical(other.isFinished, isFinished) ||
                other.isFinished == isFinished) &&
            const DeepCollectionEquality().equals(
              other._playerIds,
              _playerIds,
            ) &&
            (identical(other.lastCheckpointTime, lastCheckpointTime) ||
                other.lastCheckpointTime == lastCheckpointTime) &&
            (identical(other.finishTime, finishTime) ||
                other.finishTime == finishTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    startTime,
    currentRound,
    isInProgress,
    isFinished,
    const DeepCollectionEquality().hash(_playerIds),
    lastCheckpointTime,
    finishTime,
  );

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameStateImplCopyWith<_$GameStateImpl> get copyWith =>
      __$$GameStateImplCopyWithImpl<_$GameStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GameStateImplToJson(this);
  }
}

abstract class _GameState implements GameState {
  const factory _GameState({
    required final String id,
    required final DateTime startTime,
    required final int currentRound,
    final bool isInProgress,
    final bool isFinished,
    final List<String> playerIds,
    final DateTime? lastCheckpointTime,
    final DateTime? finishTime,
  }) = _$GameStateImpl;

  factory _GameState.fromJson(Map<String, dynamic> json) =
      _$GameStateImpl.fromJson;

  @override
  String get id;
  @override
  DateTime get startTime;
  @override
  int get currentRound;
  @override
  bool get isInProgress;
  @override
  bool get isFinished;
  @override
  List<String> get playerIds;
  @override
  DateTime? get lastCheckpointTime;
  @override
  DateTime? get finishTime;

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameStateImplCopyWith<_$GameStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
