// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaderboard_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sortedLeaderboardHash() => r'0c8e16164e03cb8c52fe5ffcc7d87a0a46c19890';

/// Players sorted descending by points for leaderboard display.
///
/// Copied from [sortedLeaderboard].
@ProviderFor(sortedLeaderboard)
final sortedLeaderboardProvider =
    AutoDisposeFutureProvider<List<PlayerProfile>>.internal(
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
typedef SortedLeaderboardRef =
    AutoDisposeFutureProviderRef<List<PlayerProfile>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
