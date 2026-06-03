// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'registration_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$RegistrationFormState {
  int get step => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get surname => throw _privateConstructorUsedError;
  Sex? get sex => throw _privateConstructorUsedError;
  BodySize? get bodySize => throw _privateConstructorUsedError;
  String get photoPath => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of RegistrationFormState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RegistrationFormStateCopyWith<RegistrationFormState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RegistrationFormStateCopyWith<$Res> {
  factory $RegistrationFormStateCopyWith(
    RegistrationFormState value,
    $Res Function(RegistrationFormState) then,
  ) = _$RegistrationFormStateCopyWithImpl<$Res, RegistrationFormState>;
  @useResult
  $Res call({
    int step,
    String name,
    String surname,
    Sex? sex,
    BodySize? bodySize,
    String photoPath,
    bool isLoading,
    String? error,
  });
}

/// @nodoc
class _$RegistrationFormStateCopyWithImpl<
  $Res,
  $Val extends RegistrationFormState
>
    implements $RegistrationFormStateCopyWith<$Res> {
  _$RegistrationFormStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RegistrationFormState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? step = null,
    Object? name = null,
    Object? surname = null,
    Object? sex = freezed,
    Object? bodySize = freezed,
    Object? photoPath = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(
      _value.copyWith(
            step: null == step
                ? _value.step
                : step // ignore: cast_nullable_to_non_nullable
                      as int,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            surname: null == surname
                ? _value.surname
                : surname // ignore: cast_nullable_to_non_nullable
                      as String,
            sex: freezed == sex
                ? _value.sex
                : sex // ignore: cast_nullable_to_non_nullable
                      as Sex?,
            bodySize: freezed == bodySize
                ? _value.bodySize
                : bodySize // ignore: cast_nullable_to_non_nullable
                      as BodySize?,
            photoPath: null == photoPath
                ? _value.photoPath
                : photoPath // ignore: cast_nullable_to_non_nullable
                      as String,
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RegistrationFormStateImplCopyWith<$Res>
    implements $RegistrationFormStateCopyWith<$Res> {
  factory _$$RegistrationFormStateImplCopyWith(
    _$RegistrationFormStateImpl value,
    $Res Function(_$RegistrationFormStateImpl) then,
  ) = __$$RegistrationFormStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int step,
    String name,
    String surname,
    Sex? sex,
    BodySize? bodySize,
    String photoPath,
    bool isLoading,
    String? error,
  });
}

/// @nodoc
class __$$RegistrationFormStateImplCopyWithImpl<$Res>
    extends
        _$RegistrationFormStateCopyWithImpl<$Res, _$RegistrationFormStateImpl>
    implements _$$RegistrationFormStateImplCopyWith<$Res> {
  __$$RegistrationFormStateImplCopyWithImpl(
    _$RegistrationFormStateImpl _value,
    $Res Function(_$RegistrationFormStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RegistrationFormState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? step = null,
    Object? name = null,
    Object? surname = null,
    Object? sex = freezed,
    Object? bodySize = freezed,
    Object? photoPath = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(
      _$RegistrationFormStateImpl(
        step: null == step
            ? _value.step
            : step // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        surname: null == surname
            ? _value.surname
            : surname // ignore: cast_nullable_to_non_nullable
                  as String,
        sex: freezed == sex
            ? _value.sex
            : sex // ignore: cast_nullable_to_non_nullable
                  as Sex?,
        bodySize: freezed == bodySize
            ? _value.bodySize
            : bodySize // ignore: cast_nullable_to_non_nullable
                  as BodySize?,
        photoPath: null == photoPath
            ? _value.photoPath
            : photoPath // ignore: cast_nullable_to_non_nullable
                  as String,
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$RegistrationFormStateImpl implements _RegistrationFormState {
  const _$RegistrationFormStateImpl({
    this.step = 0,
    this.name = '',
    this.surname = '',
    this.sex,
    this.bodySize,
    this.photoPath = '',
    this.isLoading = false,
    this.error,
  });

  @override
  @JsonKey()
  final int step;
  @override
  @JsonKey()
  final String name;
  @override
  @JsonKey()
  final String surname;
  @override
  final Sex? sex;
  @override
  final BodySize? bodySize;
  @override
  @JsonKey()
  final String photoPath;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;

  @override
  String toString() {
    return 'RegistrationFormState(step: $step, name: $name, surname: $surname, sex: $sex, bodySize: $bodySize, photoPath: $photoPath, isLoading: $isLoading, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RegistrationFormStateImpl &&
            (identical(other.step, step) || other.step == step) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.surname, surname) || other.surname == surname) &&
            (identical(other.sex, sex) || other.sex == sex) &&
            (identical(other.bodySize, bodySize) ||
                other.bodySize == bodySize) &&
            (identical(other.photoPath, photoPath) ||
                other.photoPath == photoPath) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    step,
    name,
    surname,
    sex,
    bodySize,
    photoPath,
    isLoading,
    error,
  );

  /// Create a copy of RegistrationFormState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RegistrationFormStateImplCopyWith<_$RegistrationFormStateImpl>
  get copyWith =>
      __$$RegistrationFormStateImplCopyWithImpl<_$RegistrationFormStateImpl>(
        this,
        _$identity,
      );
}

abstract class _RegistrationFormState implements RegistrationFormState {
  const factory _RegistrationFormState({
    final int step,
    final String name,
    final String surname,
    final Sex? sex,
    final BodySize? bodySize,
    final String photoPath,
    final bool isLoading,
    final String? error,
  }) = _$RegistrationFormStateImpl;

  @override
  int get step;
  @override
  String get name;
  @override
  String get surname;
  @override
  Sex? get sex;
  @override
  BodySize? get bodySize;
  @override
  String get photoPath;
  @override
  bool get isLoading;
  @override
  String? get error;

  /// Create a copy of RegistrationFormState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RegistrationFormStateImplCopyWith<_$RegistrationFormStateImpl>
  get copyWith => throw _privateConstructorUsedError;
}
