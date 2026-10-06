// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../nav_path.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A per-tab stack of [NavPaneEntry]: the single source of truth for how deep a
/// tab is drilled. Renderers lay the same stack out their own way (full-screen
/// pages on a phone, a list/detail column with breadcrumbs on desktop), so a
/// resize re-renders the path in place rather than resetting it.

@ProviderFor(NavPath)
final navPathProvider = NavPathFamily._();

/// A per-tab stack of [NavPaneEntry]: the single source of truth for how deep a
/// tab is drilled. Renderers lay the same stack out their own way (full-screen
/// pages on a phone, a list/detail column with breadcrumbs on desktop), so a
/// resize re-renders the path in place rather than resetting it.
final class NavPathProvider
    extends $NotifierProvider<NavPath, List<NavPaneEntry>> {
  /// A per-tab stack of [NavPaneEntry]: the single source of truth for how deep a
  /// tab is drilled. Renderers lay the same stack out their own way (full-screen
  /// pages on a phone, a list/detail column with breadcrumbs on desktop), so a
  /// resize re-renders the path in place rather than resetting it.
  NavPathProvider._({
    required NavPathFamily super.from,
    required PageLabel super.argument,
  }) : super(
         retry: null,
         name: r'navPathProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$navPathHash();

  @override
  String toString() {
    return r'navPathProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  NavPath create() => NavPath();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<NavPaneEntry> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<NavPaneEntry>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is NavPathProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$navPathHash() => r'c659f13b4caa607a2ff7bee603d5ab548b9201e9';

/// A per-tab stack of [NavPaneEntry]: the single source of truth for how deep a
/// tab is drilled. Renderers lay the same stack out their own way (full-screen
/// pages on a phone, a list/detail column with breadcrumbs on desktop), so a
/// resize re-renders the path in place rather than resetting it.

final class NavPathFamily extends $Family
    with
        $ClassFamilyOverride<
          NavPath,
          List<NavPaneEntry>,
          List<NavPaneEntry>,
          List<NavPaneEntry>,
          PageLabel
        > {
  NavPathFamily._()
    : super(
        retry: null,
        name: r'navPathProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// A per-tab stack of [NavPaneEntry]: the single source of truth for how deep a
  /// tab is drilled. Renderers lay the same stack out their own way (full-screen
  /// pages on a phone, a list/detail column with breadcrumbs on desktop), so a
  /// resize re-renders the path in place rather than resetting it.

  NavPathProvider call(PageLabel tab) =>
      NavPathProvider._(argument: tab, from: this);

  @override
  String toString() => r'navPathProvider';
}

/// A per-tab stack of [NavPaneEntry]: the single source of truth for how deep a
/// tab is drilled. Renderers lay the same stack out their own way (full-screen
/// pages on a phone, a list/detail column with breadcrumbs on desktop), so a
/// resize re-renders the path in place rather than resetting it.

abstract class _$NavPath extends $Notifier<List<NavPaneEntry>> {
  late final _$args = ref.$arg as PageLabel;
  PageLabel get tab => _$args;

  List<NavPaneEntry> build(PageLabel tab);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<NavPaneEntry>, List<NavPaneEntry>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<NavPaneEntry>, List<NavPaneEntry>>,
              List<NavPaneEntry>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
