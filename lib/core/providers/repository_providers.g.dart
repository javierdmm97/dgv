// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repository_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$playerRepositoryHash() => r'5c56c479440eed51cf5305ed329246051799c6a5';

/// Player repository provider
///
/// Copied from [playerRepository].
@ProviderFor(playerRepository)
final playerRepositoryProvider = AutoDisposeProvider<PlayerRepository>.internal(
  playerRepository,
  name: r'playerRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$playerRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PlayerRepositoryRef = AutoDisposeProviderRef<PlayerRepository>;
String _$gameStateRepositoryHash() =>
    r'816bdc55fbec870e99cde655178da4b6bea32cad';

/// Game state repository provider
///
/// Copied from [gameStateRepository].
@ProviderFor(gameStateRepository)
final gameStateRepositoryProvider =
    AutoDisposeProvider<GameStateRepository>.internal(
      gameStateRepository,
      name: r'gameStateRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$gameStateRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GameStateRepositoryRef = AutoDisposeProviderRef<GameStateRepository>;
String _$checkpointRepositoryHash() =>
    r'308ed75c7225752ca49fb5e9d7dbe64871426e02';

/// Checkpoint repository provider
///
/// Copied from [checkpointRepository].
@ProviderFor(checkpointRepository)
final checkpointRepositoryProvider =
    AutoDisposeProvider<CheckpointRepository>.internal(
      checkpointRepository,
      name: r'checkpointRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$checkpointRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CheckpointRepositoryRef = AutoDisposeProviderRef<CheckpointRepository>;
String _$curveSettingsRepositoryHash() =>
    r'6b86a8a04b3146cdc3c5c3db1d88586f4e2387bf';

/// Curve settings repository provider
///
/// Copied from [curveSettingsRepository].
@ProviderFor(curveSettingsRepository)
final curveSettingsRepositoryProvider =
    AutoDisposeProvider<CurveSettingsRepository>.internal(
      curveSettingsRepository,
      name: r'curveSettingsRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$curveSettingsRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurveSettingsRepositoryRef =
    AutoDisposeProviderRef<CurveSettingsRepository>;
String _$curveMultiplierHash() => r'5c0847fed3deb38e03a0338f2e796dc1463e4ad5';

/// Current curve multiplier value (defaults to 1.00 if not persisted)
///
/// Copied from [curveMultiplier].
@ProviderFor(curveMultiplier)
final curveMultiplierProvider = AutoDisposeFutureProvider<double>.internal(
  curveMultiplier,
  name: r'curveMultiplierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$curveMultiplierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurveMultiplierRef = AutoDisposeFutureProviderRef<double>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
