// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'main_menu_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$MainMenuState {
  bool get isGameInProgress => throw _privateConstructorUsedError;
  List<PlayerProfile> get players => throw _privateConstructorUsedError;
  bool get isFakeErrorVisible => throw _privateConstructorUsedError;

  /// Create a copy of MainMenuState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MainMenuStateCopyWith<MainMenuState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MainMenuStateCopyWith<$Res> {
  factory $MainMenuStateCopyWith(
    MainMenuState value,
    $Res Function(MainMenuState) then,
  ) = _$MainMenuStateCopyWithImpl<$Res, MainMenuState>;
  @useResult
  $Res call({
    bool isGameInProgress,
    List<PlayerProfile> players,
    bool isFakeErrorVisible,
  });
}

/// @nodoc
class _$MainMenuStateCopyWithImpl<$Res, $Val extends MainMenuState>
    implements $MainMenuStateCopyWith<$Res> {
  _$MainMenuStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MainMenuState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isGameInProgress = null,
    Object? players = null,
    Object? isFakeErrorVisible = null,
  }) {
    return _then(
      _value.copyWith(
            isGameInProgress: null == isGameInProgress
                ? _value.isGameInProgress
                : isGameInProgress // ignore: cast_nullable_to_non_nullable
                      as bool,
            players: null == players
                ? _value.players
                : players // ignore: cast_nullable_to_non_nullable
                      as List<PlayerProfile>,
            isFakeErrorVisible: null == isFakeErrorVisible
                ? _value.isFakeErrorVisible
                : isFakeErrorVisible // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MainMenuStateImplCopyWith<$Res>
    implements $MainMenuStateCopyWith<$Res> {
  factory _$$MainMenuStateImplCopyWith(
    _$MainMenuStateImpl value,
    $Res Function(_$MainMenuStateImpl) then,
  ) = __$$MainMenuStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool isGameInProgress,
    List<PlayerProfile> players,
    bool isFakeErrorVisible,
  });
}

/// @nodoc
class __$$MainMenuStateImplCopyWithImpl<$Res>
    extends _$MainMenuStateCopyWithImpl<$Res, _$MainMenuStateImpl>
    implements _$$MainMenuStateImplCopyWith<$Res> {
  __$$MainMenuStateImplCopyWithImpl(
    _$MainMenuStateImpl _value,
    $Res Function(_$MainMenuStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MainMenuState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isGameInProgress = null,
    Object? players = null,
    Object? isFakeErrorVisible = null,
  }) {
    return _then(
      _$MainMenuStateImpl(
        isGameInProgress: null == isGameInProgress
            ? _value.isGameInProgress
            : isGameInProgress // ignore: cast_nullable_to_non_nullable
                  as bool,
        players: null == players
            ? _value._players
            : players // ignore: cast_nullable_to_non_nullable
                  as List<PlayerProfile>,
        isFakeErrorVisible: null == isFakeErrorVisible
            ? _value.isFakeErrorVisible
            : isFakeErrorVisible // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$MainMenuStateImpl implements _MainMenuState {
  const _$MainMenuStateImpl({
    required this.isGameInProgress,
    required final List<PlayerProfile> players,
    this.isFakeErrorVisible = true,
  }) : _players = players;

  @override
  final bool isGameInProgress;
  final List<PlayerProfile> _players;
  @override
  List<PlayerProfile> get players {
    if (_players is EqualUnmodifiableListView) return _players;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_players);
  }

  @override
  @JsonKey()
  final bool isFakeErrorVisible;

  @override
  String toString() {
    return 'MainMenuState(isGameInProgress: $isGameInProgress, players: $players, isFakeErrorVisible: $isFakeErrorVisible)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MainMenuStateImpl &&
            (identical(other.isGameInProgress, isGameInProgress) ||
                other.isGameInProgress == isGameInProgress) &&
            const DeepCollectionEquality().equals(other._players, _players) &&
            (identical(other.isFakeErrorVisible, isFakeErrorVisible) ||
                other.isFakeErrorVisible == isFakeErrorVisible));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    isGameInProgress,
    const DeepCollectionEquality().hash(_players),
    isFakeErrorVisible,
  );

  /// Create a copy of MainMenuState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MainMenuStateImplCopyWith<_$MainMenuStateImpl> get copyWith =>
      __$$MainMenuStateImplCopyWithImpl<_$MainMenuStateImpl>(this, _$identity);
}

abstract class _MainMenuState implements MainMenuState {
  const factory _MainMenuState({
    required final bool isGameInProgress,
    required final List<PlayerProfile> players,
    final bool isFakeErrorVisible,
  }) = _$MainMenuStateImpl;

  @override
  bool get isGameInProgress;
  @override
  List<PlayerProfile> get players;
  @override
  bool get isFakeErrorVisible;

  /// Create a copy of MainMenuState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MainMenuStateImplCopyWith<_$MainMenuStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
