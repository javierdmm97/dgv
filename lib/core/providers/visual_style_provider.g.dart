// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visual_style_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$visualStyleSettingsHash() =>
    r'a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0';

/// Provides the current visual style settings.
///
/// Copied from [visualStyleSettings].
@ProviderFor(visualStyleSettings)
final visualStyleSettingsProvider =
    AutoDisposeFutureProvider<VisualStyleSettings>.internal(
      visualStyleSettings,
      name: r'visualStyleSettingsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$visualStyleSettingsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef VisualStyleSettingsRef =
    AutoDisposeFutureProviderRef<VisualStyleSettings>;
String _$visualStyleNotifierHash() =>
    r'b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0';

/// Notifier for managing visual style settings.
///
/// Copied from [VisualStyleNotifier].
@ProviderFor(VisualStyleNotifier)
final visualStyleNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      VisualStyleNotifier,
      VisualStyleSettings
    >.internal(
      VisualStyleNotifier.new,
      name: r'visualStyleNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$visualStyleNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$VisualStyleNotifier = AutoDisposeAsyncNotifier<VisualStyleSettings>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
