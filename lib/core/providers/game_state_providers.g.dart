// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_state_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentGameStateHash() => r'1411c3fdfae84d5fddfe07a328a4b9d104db0bb2';

/// Current game state provider
///
/// Copied from [currentGameState].
@ProviderFor(currentGameState)
final currentGameStateProvider = AutoDisposeFutureProvider<GameState?>.internal(
  currentGameState,
  name: r'currentGameStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentGameStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentGameStateRef = AutoDisposeFutureProviderRef<GameState?>;
String _$isGameInProgressHash() => r'6ec6234af01db8183728747d86666ba430ea1102';

/// Is game in progress provider
///
/// Copied from [isGameInProgress].
@ProviderFor(isGameInProgress)
final isGameInProgressProvider = AutoDisposeFutureProvider<bool>.internal(
  isGameInProgress,
  name: r'isGameInProgressProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isGameInProgressHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsGameInProgressRef = AutoDisposeFutureProviderRef<bool>;
String _$gameStateNotifierHash() => r'c257aadb20f9772609d55806833fe77bbd3a4053';

/// Game state notifier (for mutations)
///
/// Copied from [GameStateNotifier].
@ProviderFor(GameStateNotifier)
final gameStateNotifierProvider =
    AutoDisposeAsyncNotifierProvider<GameStateNotifier, GameState?>.internal(
      GameStateNotifier.new,
      name: r'gameStateNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$gameStateNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$GameStateNotifier = AutoDisposeAsyncNotifier<GameState?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
