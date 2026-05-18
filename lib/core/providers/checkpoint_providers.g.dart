// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkpoint_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$checkpointStreamHash() => r'9052433f3f23b2fa1662637b8836e7715dec8319';

/// Stream of checkpoint state for reactive widgets.
///
/// Copied from [checkpointStream].
@ProviderFor(checkpointStream)
final checkpointStreamProvider =
    AutoDisposeStreamProvider<CheckpointState?>.internal(
      checkpointStream,
      name: r'checkpointStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$checkpointStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CheckpointStreamRef = AutoDisposeStreamProviderRef<CheckpointState?>;
String _$isCheckpointDueHash() => r'6312b86f6487ce4841c55d5c52e063e79c6c4a1a';

/// Whether any group is currently due for measurement.
///
/// Copied from [isCheckpointDue].
@ProviderFor(isCheckpointDue)
final isCheckpointDueProvider = AutoDisposeProvider<bool>.internal(
  isCheckpointDue,
  name: r'isCheckpointDueProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isCheckpointDueHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsCheckpointDueRef = AutoDisposeProviderRef<bool>;
String _$activeGroupProgressHash() =>
    r'22b0b83c61deb25540475b6113583a67945018e6';

/// Progress for the active group: (completed, total).
///
/// Returns `(0, 0)` when no group is active.
///
/// Copied from [activeGroupProgress].
@ProviderFor(activeGroupProgress)
final activeGroupProgressProvider = AutoDisposeProvider<(int, int)>.internal(
  activeGroupProgress,
  name: r'activeGroupProgressProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeGroupProgressHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveGroupProgressRef = AutoDisposeProviderRef<(int, int)>;
String _$checkpointNotifierHash() =>
    r'1dba34c631321533bc62260b8d4f9eafb80fee72';

/// Central provider for per-group checkpoint timer management.
///
/// Owns a single [Timer.periodic] that ticks every second and recomputes
/// [timeRemaining] for each group from absolute [lastMeasurement] timestamps.
/// All mutations are persisted to Hive immediately.
///
/// Copied from [CheckpointNotifier].
@ProviderFor(CheckpointNotifier)
final checkpointNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      CheckpointNotifier,
      CheckpointState?
    >.internal(
      CheckpointNotifier.new,
      name: r'checkpointNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$checkpointNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CheckpointNotifier = AutoDisposeAsyncNotifier<CheckpointState?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
