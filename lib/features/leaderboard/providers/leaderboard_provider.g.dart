// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaderboard_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sortedLeaderboardHash() => r'f912f33d5492d73241b6401fca6972e78922f301';

/// Players sorted for leaderboard: primary = points desc, tiebreaker = perfection score asc.
///
/// Uses ref.watch so the leaderboard rebuilds immediately when any player changes.
///
/// Copied from [sortedLeaderboard].
@ProviderFor(sortedLeaderboard)
final sortedLeaderboardProvider =
    AutoDisposeProvider<List<PlayerProfile>>.internal(
      sortedLeaderboard,
      name: r'sortedLeaderboardProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$sortedLeaderboardHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SortedLeaderboardRef = AutoDisposeProviderRef<List<PlayerProfile>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
