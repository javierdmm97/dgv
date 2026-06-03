// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recovery_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$recoveryNotifierHash() => r'2bac15767f7be817af8a0062b7b7f1b69d719c3a';

/// Reads Hive on app launch and determines the correct initial route.
///
/// - No game in progress → [RecoveryRoute.mainMenu]
/// - Game in progress + checkpoint active → [RecoveryRoute.checkpoint]
/// - Game in progress + no active checkpoint → [RecoveryRoute.leaderboard]
///
/// Also restores the checkpoint timer when a game is in progress.
///
/// Copied from [RecoveryNotifier].
@ProviderFor(RecoveryNotifier)
final recoveryNotifierProvider =
    AutoDisposeAsyncNotifierProvider<RecoveryNotifier, RecoveryRoute>.internal(
      RecoveryNotifier.new,
      name: r'recoveryNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$recoveryNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$RecoveryNotifier = AutoDisposeAsyncNotifier<RecoveryRoute>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
