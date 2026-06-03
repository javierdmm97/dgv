// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'visual_style_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

VisualStyleSettings _$VisualStyleSettingsFromJson(Map<String, dynamic> json) {
  return _VisualStyleSettings.fromJson(json);
}

/// @nodoc
mixin _$VisualStyleSettings {
  /// Border radius style: 'rounded' (12px) or 'boxy' (4px)
  @HiveField(0)
  String get borderRadiusStyle => throw _privateConstructorUsedError;

  /// Font family: 'default', 'roboto', or 'montserrat'
  @HiveField(1)
  String get fontFamily => throw _privateConstructorUsedError;

  /// Serializes this VisualStyleSettings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VisualStyleSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VisualStyleSettingsCopyWith<VisualStyleSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VisualStyleSettingsCopyWith<$Res> {
  factory $VisualStyleSettingsCopyWith(
    VisualStyleSettings value,
    $Res Function(VisualStyleSettings) then,
  ) = _$VisualStyleSettingsCopyWithImpl<$Res, VisualStyleSettings>;
  @useResult
  $Res call({
    @HiveField(0) String borderRadiusStyle,
    @HiveField(1) String fontFamily,
  });
}

/// @nodoc
class _$VisualStyleSettingsCopyWithImpl<$Res, $Val extends VisualStyleSettings>
    implements $VisualStyleSettingsCopyWith<$Res> {
  _$VisualStyleSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VisualStyleSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? borderRadiusStyle = null, Object? fontFamily = null}) {
    return _then(
      _value.copyWith(
            borderRadiusStyle: null == borderRadiusStyle
                ? _value.borderRadiusStyle
                : borderRadiusStyle // ignore: cast_nullable_to_non_nullable
                      as String,
            fontFamily: null == fontFamily
                ? _value.fontFamily
                : fontFamily // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VisualStyleSettingsImplCopyWith<$Res>
    implements $VisualStyleSettingsCopyWith<$Res> {
  factory _$$VisualStyleSettingsImplCopyWith(
    _$VisualStyleSettingsImpl value,
    $Res Function(_$VisualStyleSettingsImpl) then,
  ) = __$$VisualStyleSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @HiveField(0) String borderRadiusStyle,
    @HiveField(1) String fontFamily,
  });
}

/// @nodoc
class __$$VisualStyleSettingsImplCopyWithImpl<$Res>
    extends _$VisualStyleSettingsCopyWithImpl<$Res, _$VisualStyleSettingsImpl>
    implements _$$VisualStyleSettingsImplCopyWith<$Res> {
  __$$VisualStyleSettingsImplCopyWithImpl(
    _$VisualStyleSettingsImpl _value,
    $Res Function(_$VisualStyleSettingsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VisualStyleSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? borderRadiusStyle = null, Object? fontFamily = null}) {
    return _then(
      _$VisualStyleSettingsImpl(
        borderRadiusStyle: null == borderRadiusStyle
            ? _value.borderRadiusStyle
            : borderRadiusStyle // ignore: cast_nullable_to_non_nullable
                  as String,
        fontFamily: null == fontFamily
            ? _value.fontFamily
            : fontFamily // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VisualStyleSettingsImpl implements _VisualStyleSettings {
  const _$VisualStyleSettingsImpl({
    @HiveField(0) this.borderRadiusStyle = 'rounded',
    @HiveField(1) this.fontFamily = 'default',
  });

  factory _$VisualStyleSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$VisualStyleSettingsImplFromJson(json);

  /// Border radius style: 'rounded' (12px) or 'boxy' (4px)
  @override
  @HiveField(0)
  final String borderRadiusStyle;

  /// Font family: 'default', 'roboto', or 'montserrat'
  @override
  @HiveField(1)
  final String fontFamily;

  @override
  String toString() {
    return 'VisualStyleSettings(borderRadiusStyle: $borderRadiusStyle, fontFamily: $fontFamily)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VisualStyleSettingsImpl &&
            (identical(other.borderRadiusStyle, borderRadiusStyle) ||
                other.borderRadiusStyle == borderRadiusStyle) &&
            (identical(other.fontFamily, fontFamily) ||
                other.fontFamily == fontFamily));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, borderRadiusStyle, fontFamily);

  /// Create a copy of VisualStyleSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VisualStyleSettingsImplCopyWith<_$VisualStyleSettingsImpl> get copyWith =>
      __$$VisualStyleSettingsImplCopyWithImpl<_$VisualStyleSettingsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$VisualStyleSettingsImplToJson(this);
  }
}

abstract class _VisualStyleSettings implements VisualStyleSettings {
  const factory _VisualStyleSettings({
    @HiveField(0) final String borderRadiusStyle,
    @HiveField(1) final String fontFamily,
  }) = _$VisualStyleSettingsImpl;

  factory _VisualStyleSettings.fromJson(Map<String, dynamic> json) =
      _$VisualStyleSettingsImpl.fromJson;

  /// Border radius style: 'rounded' (12px) or 'boxy' (4px)
  @override
  @HiveField(0)
  String get borderRadiusStyle;

  /// Font family: 'default', 'roboto', or 'montserrat'
  @override
  @HiveField(1)
  String get fontFamily;

  /// Create a copy of VisualStyleSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VisualStyleSettingsImplCopyWith<_$VisualStyleSettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
