// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../routing.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The routing engine's last reported state. The Core pushes it on change;
/// the host only asks when it has nothing yet.

@ProviderFor(RcxStatusState)
final rcxStatusStateProvider = RcxStatusStateProvider._();

/// The routing engine's last reported state. The Core pushes it on change;
/// the host only asks when it has nothing yet.
final class RcxStatusStateProvider
    extends $NotifierProvider<RcxStatusState, RcxStatus?> {
  /// The routing engine's last reported state. The Core pushes it on change;
  /// the host only asks when it has nothing yet.
  RcxStatusStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rcxStatusStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rcxStatusStateHash();

  @$internal
  @override
  RcxStatusState create() => RcxStatusState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RcxStatus? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RcxStatus?>(value),
    );
  }
}

String _$rcxStatusStateHash() => r'c424862b77dddcaecadb675b6c8aebbd47794eba';

/// The routing engine's last reported state. The Core pushes it on change;
/// the host only asks when it has nothing yet.

abstract class _$RcxStatusState extends $Notifier<RcxStatus?> {
  RcxStatus? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<RcxStatus?, RcxStatus?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RcxStatus?, RcxStatus?>,
              RcxStatus?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The tunnel mode in force: the scenario's while it holds the mode, else
/// the user's own.

@ProviderFor(effectiveMode)
final effectiveModeProvider = EffectiveModeProvider._();

/// The tunnel mode in force: the scenario's while it holds the mode, else
/// the user's own.

final class EffectiveModeProvider extends $FunctionalProvider<Mode, Mode, Mode>
    with $Provider<Mode> {
  /// The tunnel mode in force: the scenario's while it holds the mode, else
  /// the user's own.
  EffectiveModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'effectiveModeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$effectiveModeHash();

  @$internal
  @override
  $ProviderElement<Mode> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Mode create(Ref ref) {
    return effectiveMode(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Mode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Mode>(value),
    );
  }
}

String _$effectiveModeHash() => r'ff460b4a5794859ddacc79e81ce5877bb800c9e8';

@ProviderFor(rcxGroup)
final rcxGroupProvider = RcxGroupFamily._();

final class RcxGroupProvider
    extends
        $FunctionalProvider<RcxGroupStatus?, RcxGroupStatus?, RcxGroupStatus?>
    with $Provider<RcxGroupStatus?> {
  RcxGroupProvider._({
    required RcxGroupFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'rcxGroupProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$rcxGroupHash();

  @override
  String toString() {
    return r'rcxGroupProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<RcxGroupStatus?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RcxGroupStatus? create(Ref ref) {
    final argument = this.argument as String;
    return rcxGroup(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RcxGroupStatus? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RcxGroupStatus?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RcxGroupProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$rcxGroupHash() => r'dd31d382d2974cfc6803e5604294a8450e5eadd5';

final class RcxGroupFamily extends $Family
    with $FunctionalFamilyOverride<RcxGroupStatus?, String> {
  RcxGroupFamily._()
    : super(
        retry: null,
        name: r'rcxGroupProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RcxGroupProvider call(String groupName) =>
      RcxGroupProvider._(argument: groupName, from: this);

  @override
  String toString() => r'rcxGroupProvider';
}

/// The layer the Core runs: the current profile's choices plus the user's
/// own profiles and the hosts its subscription came from.

@ProviderFor(currentRoutingLayer)
final currentRoutingLayerProvider = CurrentRoutingLayerProvider._();

/// The layer the Core runs: the current profile's choices plus the user's
/// own profiles and the hosts its subscription came from.

final class CurrentRoutingLayerProvider
    extends $FunctionalProvider<RcxUserLayer, RcxUserLayer, RcxUserLayer>
    with $Provider<RcxUserLayer> {
  /// The layer the Core runs: the current profile's choices plus the user's
  /// own profiles and the hosts its subscription came from.
  CurrentRoutingLayerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentRoutingLayerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentRoutingLayerHash();

  @$internal
  @override
  $ProviderElement<RcxUserLayer> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RcxUserLayer create(Ref ref) {
    return currentRoutingLayer(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RcxUserLayer value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RcxUserLayer>(value),
    );
  }
}

String _$currentRoutingLayerHash() =>
    r'22873e50b4a15da8a279e3b37b916a4c2ba36c5e';

/// The profile library as the Core sees it; refetched whenever the Core
/// rebuilds it.

@ProviderFor(rcxLibrary)
final rcxLibraryProvider = RcxLibraryProvider._();

/// The profile library as the Core sees it; refetched whenever the Core
/// rebuilds it.

final class RcxLibraryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RcxProfileInfo>>,
          List<RcxProfileInfo>,
          FutureOr<List<RcxProfileInfo>>
        >
    with
        $FutureModifier<List<RcxProfileInfo>>,
        $FutureProvider<List<RcxProfileInfo>> {
  /// The profile library as the Core sees it; refetched whenever the Core
  /// rebuilds it.
  RcxLibraryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rcxLibraryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rcxLibraryHash();

  @$internal
  @override
  $FutureProviderElement<List<RcxProfileInfo>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<RcxProfileInfo>> create(Ref ref) {
    return rcxLibrary(ref);
  }
}

String _$rcxLibraryHash() => r'20f67c04e579ace6af31ba724511665763253beb';

@ProviderFor(RcxRoutingAction)
final rcxRoutingActionProvider = RcxRoutingActionProvider._();

final class RcxRoutingActionProvider
    extends $NotifierProvider<RcxRoutingAction, void> {
  RcxRoutingActionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rcxRoutingActionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rcxRoutingActionHash();

  @$internal
  @override
  RcxRoutingAction create() => RcxRoutingAction();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$rcxRoutingActionHash() => r'e77553b38779c594f25f02e892eafc8b6bc130c7';

abstract class _$RcxRoutingAction extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
