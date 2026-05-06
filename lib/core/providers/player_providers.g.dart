// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$playerListHash() => r'a15933b8ae61e7091989a73a8bdebedf16812b85';

/// Player list provider
///
/// Copied from [playerList].
@ProviderFor(playerList)
final playerListProvider =
    AutoDisposeFutureProvider<List<PlayerProfile>>.internal(
      playerList,
      name: r'playerListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$playerListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PlayerListRef = AutoDisposeFutureProviderRef<List<PlayerProfile>>;
String _$playerByIdHash() => r'5f497942494cd34165507a84ce60bdc3cee79eb2';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Player by ID provider
///
/// Copied from [playerById].
@ProviderFor(playerById)
const playerByIdProvider = PlayerByIdFamily();

/// Player by ID provider
///
/// Copied from [playerById].
class PlayerByIdFamily extends Family<AsyncValue<PlayerProfile?>> {
  /// Player by ID provider
  ///
  /// Copied from [playerById].
  const PlayerByIdFamily();

  /// Player by ID provider
  ///
  /// Copied from [playerById].
  PlayerByIdProvider call(String id) {
    return PlayerByIdProvider(id);
  }

  @override
  PlayerByIdProvider getProviderOverride(
    covariant PlayerByIdProvider provider,
  ) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'playerByIdProvider';
}

/// Player by ID provider
///
/// Copied from [playerById].
class PlayerByIdProvider extends AutoDisposeFutureProvider<PlayerProfile?> {
  /// Player by ID provider
  ///
  /// Copied from [playerById].
  PlayerByIdProvider(String id)
    : this._internal(
        (ref) => playerById(ref as PlayerByIdRef, id),
        from: playerByIdProvider,
        name: r'playerByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$playerByIdHash,
        dependencies: PlayerByIdFamily._dependencies,
        allTransitiveDependencies: PlayerByIdFamily._allTransitiveDependencies,
        id: id,
      );

  PlayerByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    FutureOr<PlayerProfile?> Function(PlayerByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PlayerByIdProvider._internal(
        (ref) => create(ref as PlayerByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<PlayerProfile?> createElement() {
    return _PlayerByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PlayerByIdProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PlayerByIdRef on AutoDisposeFutureProviderRef<PlayerProfile?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _PlayerByIdProviderElement
    extends AutoDisposeFutureProviderElement<PlayerProfile?>
    with PlayerByIdRef {
  _PlayerByIdProviderElement(super.provider);

  @override
  String get id => (origin as PlayerByIdProvider).id;
}

String _$playerCountHash() => r'422e1025373245281e650f95bcb1b63ed55d0729';

/// Player count provider
///
/// Copied from [playerCount].
@ProviderFor(playerCount)
final playerCountProvider = AutoDisposeFutureProvider<int>.internal(
  playerCount,
  name: r'playerCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$playerCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PlayerCountRef = AutoDisposeFutureProviderRef<int>;
String _$playerListNotifierHash() =>
    r'673215f9b8493b11bf3af71df1da51fa99ba860b';

/// Player list notifier (for mutations)
///
/// Copied from [PlayerListNotifier].
@ProviderFor(PlayerListNotifier)
final playerListNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      PlayerListNotifier,
      List<PlayerProfile>
    >.internal(
      PlayerListNotifier.new,
      name: r'playerListNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$playerListNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PlayerListNotifier = AutoDisposeAsyncNotifier<List<PlayerProfile>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
