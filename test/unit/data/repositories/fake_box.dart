import 'dart:async';

import 'package:hive/hive.dart';

/// In-memory fake implementation of Hive [Box] for unit tests.
///
/// Implements only the methods actually called by the repository
/// implementations in this project:
/// - [get] / [put] / [delete] / [clear]
/// - [keys] / [length] / [containsKey]
///
/// Stream support is provided via a [StreamController] so that
/// repository [watch()] calls can be tested.
class FakeBox<E> implements Box<E> {
  FakeBox({String name = 'fake'}) : _name = name;

  final String _name;
  final _data = <String, E>{};
  final _streamController = StreamController<BoxEvent>.broadcast();

  // ── BoxBase ────────────────────────────────────────────────────────────────

  @override
  String get name => _name;

  @override
  bool get isOpen => true;

  @override
  String? get path => null;

  @override
  bool get lazy => false;

  @override
  Iterable<dynamic> get keys => _data.keys;

  @override
  int get length => _data.length;

  @override
  bool get isEmpty => _data.isEmpty;

  @override
  bool get isNotEmpty => _data.isNotEmpty;

  @override
  dynamic keyAt(int index) {
    if (index >= _data.keys.length) return null;
    return _data.keys.elementAt(index);
  }

  @override
  Stream<BoxEvent> watch({dynamic key}) {
    if (key == null) return _streamController.stream;
    return _streamController.stream.where((e) => e.key == key);
  }

  @override
  bool containsKey(dynamic key) => _data.containsKey(key as String);

  @override
  Future<void> put(dynamic key, E value) async {
    _data[key as String] = value;
    _streamController.add(BoxEvent(key, value, false));
  }

  @override
  Future<void> putAt(int index, E value) async {
    final key = _data.keys.elementAt(index);
    await put(key, value);
  }

  @override
  Future<void> putAll(Map<dynamic, E> entries) async {
    for (final entry in entries.entries) {
      await put(entry.key, entry.value);
    }
  }

  @override
  Future<int> add(E value) async {
    final key = _data.length.toString();
    await put(key, value);
    return _data.length - 1;
  }

  @override
  Future<Iterable<int>> addAll(Iterable<E> values) async {
    final indices = <int>[];
    for (final v in values) {
      indices.add(await add(v));
    }
    return indices;
  }

  @override
  Future<void> delete(dynamic key) async {
    _data.remove(key as String);
    _streamController.add(BoxEvent(key, null, true));
  }

  @override
  Future<void> deleteAt(int index) async {
    final key = _data.keys.elementAt(index);
    await delete(key);
  }

  @override
  Future<void> deleteAll(Iterable<dynamic> keys) async {
    for (final key in keys) {
      await delete(key);
    }
  }

  @override
  Future<void> compact() async {}

  @override
  Future<int> clear() async {
    _data.clear();
    return 0;
  }

  @override
  Future<void> close() async {
    await _streamController.close();
  }

  @override
  Future<void> deleteFromDisk() async {
    _data.clear();
  }

  @override
  Future<void> flush() async {}

  // ── Box<E> ─────────────────────────────────────────────────────────────────

  @override
  Iterable<E> get values => _data.values;

  @override
  Iterable<E> valuesBetween({dynamic startKey, dynamic endKey}) => _data.values;

  @override
  E? get(dynamic key, {E? defaultValue}) {
    return _data[key as String] ?? defaultValue;
  }

  @override
  E? getAt(int index) {
    if (index >= _data.length) return null;
    return _data.values.elementAt(index);
  }

  @override
  Map<dynamic, E> toMap() => Map<dynamic, E>.from(_data);

  // ── Test helpers ───────────────────────────────────────────────────────────

  /// Dispose the stream controller after tests.
  Future<void> dispose() async {
    if (!_streamController.isClosed) {
      await _streamController.close();
    }
  }
}
