// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../milestones.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(milestoneRoutingHistory)
final milestoneRoutingHistoryProvider = MilestoneRoutingHistoryProvider._();

final class MilestoneRoutingHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RcxSwitchReport>>,
          List<RcxSwitchReport>,
          FutureOr<List<RcxSwitchReport>>
        >
    with
        $FutureModifier<List<RcxSwitchReport>>,
        $FutureProvider<List<RcxSwitchReport>> {
  MilestoneRoutingHistoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'milestoneRoutingHistoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$milestoneRoutingHistoryHash();

  @$internal
  @override
  $FutureProviderElement<List<RcxSwitchReport>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<RcxSwitchReport>> create(Ref ref) {
    return milestoneRoutingHistory(ref);
  }
}

String _$milestoneRoutingHistoryHash() =>
    r'a5991c4bdd8059600d5f233a881548ae918e677d';

@ProviderFor(Milestones)
final milestonesProvider = MilestonesProvider._();

final class MilestonesProvider
    extends $NotifierProvider<Milestones, OdometerSnapshot?> {
  MilestonesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'milestonesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$milestonesHash();

  @$internal
  @override
  Milestones create() => Milestones();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OdometerSnapshot? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OdometerSnapshot?>(value),
    );
  }
}

String _$milestonesHash() => r'dee5377e4b19cb46d2d3ae3c0a8a8d4a25082692';

abstract class _$Milestones extends $Notifier<OdometerSnapshot?> {
  OdometerSnapshot? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<OdometerSnapshot?, OdometerSnapshot?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<OdometerSnapshot?, OdometerSnapshot?>,
              OdometerSnapshot?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
