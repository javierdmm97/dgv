import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:dgv/core/models/visual_style_settings.dart';
import 'package:dgv/core/providers/repository_providers.dart';

part 'visual_style_provider.g.dart';

/// Provides the current visual style settings.
@riverpod
Future<VisualStyleSettings> visualStyleSettings(
  VisualStyleSettingsRef ref,
) async {
  final repo = ref.watch(visualStyleRepositoryProvider);
  return repo.load();
}

/// Notifier for managing visual style settings.
@riverpod
class VisualStyleNotifier extends _$VisualStyleNotifier {
  @override
  Future<VisualStyleSettings> build() async {
    final repo = ref.watch(visualStyleRepositoryProvider);
    return repo.load();
  }

  /// Updates the border radius style.
  Future<void> setBorderRadiusStyle(String style) async {
    final current = await future;
    final updated = current.copyWith(borderRadiusStyle: style);
    await _save(updated);
  }

  /// Updates the font family.
  Future<void> setFontFamily(String family) async {
    final current = await future;
    final updated = current.copyWith(fontFamily: family);
    await _save(updated);
  }

  Future<void> _save(VisualStyleSettings settings) async {
    final repo = ref.read(visualStyleRepositoryProvider);
    await repo.save(settings);
    state = AsyncValue.data(settings);
  }
}
