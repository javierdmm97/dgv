import 'package:hive/hive.dart';

import 'package:dgv/core/models/visual_style_settings.dart';
import 'package:dgv/data/repositories/visual_style_repository.dart';

/// Hive implementation of [VisualStyleRepository].
///
/// Stores visual style settings in a Hive box with JSON serialization.
class HiveVisualStyleRepository implements VisualStyleRepository {
  HiveVisualStyleRepository(this._box);

  final Box<Map<dynamic, dynamic>> _box;

  static const _key = 'visual_style_settings';

  @override
  Future<VisualStyleSettings> load() async {
    final json = _box.get(_key);
    if (json == null) {
      return const VisualStyleSettings();
    }
    return VisualStyleSettings.fromJson(Map<String, dynamic>.from(json));
  }

  @override
  Future<void> save(VisualStyleSettings settings) async {
    await _box.put(_key, settings.toJson());
  }

  @override
  Stream<VisualStyleSettings> watch() async* {
    yield await load();
    await for (final _ in _box.watch(key: _key)) {
      yield await load();
    }
  }
}
