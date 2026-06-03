import 'package:dgv/core/models/visual_style_settings.dart';

/// Repository interface for visual style settings persistence.
abstract interface class VisualStyleRepository {
  /// Loads the current visual style settings.
  Future<VisualStyleSettings> load();

  /// Saves the visual style settings.
  Future<void> save(VisualStyleSettings settings);

  /// Watches for changes to visual style settings.
  Stream<VisualStyleSettings> watch();
}
