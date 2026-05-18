// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bac_entry_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$bACEntryNotifierHash() => r'1aed41224f7324f128915d6a9250e1e752dad05b';

/// Processes a single BAC entry for a player.
///
/// For Round 0: records baseline with no points change.
/// For Round 1+: calculates points, checks impoundment, updates Hive.
///
/// Copied from [BACEntryNotifier].
@ProviderFor(BACEntryNotifier)
final bACEntryNotifierProvider =
    AutoDisposeNotifierProvider<BACEntryNotifier, void>.internal(
      BACEntryNotifier.new,
      name: r'bACEntryNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$bACEntryNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$BACEntryNotifier = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
