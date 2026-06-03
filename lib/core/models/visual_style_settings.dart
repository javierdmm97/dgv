import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'visual_style_settings.freezed.dart';
part 'visual_style_settings.g.dart';

/// Visual style settings for the app UI.
///
/// Allows users to customize border radius and font family.
///
/// Requirements: 5.6 (Visual Style Mod)
@freezed
@HiveType(typeId: 6)
class VisualStyleSettings with _$VisualStyleSettings {
  const factory VisualStyleSettings({
    /// Border radius style: 'rounded' (12px) or 'boxy' (4px)
    @HiveField(0) @Default('rounded') String borderRadiusStyle,

    /// Font family: 'default', 'roboto', or 'montserrat'
    @HiveField(1) @Default('default') String fontFamily,
  }) = _VisualStyleSettings;

  factory VisualStyleSettings.fromJson(Map<String, dynamic> json) =>
      _$VisualStyleSettingsFromJson(json);
}

/// Extension to get numeric border radius from style string.
extension VisualStyleSettingsX on VisualStyleSettings {
  double get borderRadius {
    return switch (borderRadiusStyle) {
      'boxy' => 4.0,
      'rounded' => 12.0,
      _ => 12.0,
    };
  }

  String get fontFamilyName {
    return switch (fontFamily) {
      'roboto' => 'Roboto',
      'montserrat' => 'Montserrat',
      _ => 'System Default',
    };
  }
}
