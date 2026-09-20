// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../finding_preview.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FindingPreview)
final findingPreviewProvider = FindingPreviewProvider._();

final class FindingPreviewProvider
    extends $NotifierProvider<FindingPreview, FindingPreviewState> {
  FindingPreviewProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'findingPreviewProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$findingPreviewHash();

  @$internal
  @override
  FindingPreview create() => FindingPreview();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FindingPreviewState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FindingPreviewState>(value),
    );
  }
}

String _$findingPreviewHash() => r'e62344b72a00ea2e98d7cca351c4d8eb8bcb3a65';

abstract class _$FindingPreview extends $Notifier<FindingPreviewState> {
  FindingPreviewState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<FindingPreviewState, FindingPreviewState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FindingPreviewState, FindingPreviewState>,
              FindingPreviewState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(visibleMilestones)
final visibleMilestonesProvider = VisibleMilestonesProvider._();

final class VisibleMilestonesProvider
    extends $FunctionalProvider<MilestoneProps, MilestoneProps, MilestoneProps>
    with $Provider<MilestoneProps> {
  VisibleMilestonesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'visibleMilestonesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$visibleMilestonesHash();

  @$internal
  @override
  $ProviderElement<MilestoneProps> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MilestoneProps create(Ref ref) {
    return visibleMilestones(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MilestoneProps value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MilestoneProps>(value),
    );
  }
}

String _$visibleMilestonesHash() => r'8766c6e0e4f85f6f6792f2efc1fe60995a0fe915';

@ProviderFor(visibleOdometer)
final visibleOdometerProvider = VisibleOdometerProvider._();

final class VisibleOdometerProvider
    extends
        $FunctionalProvider<
          OdometerSnapshot?,
          OdometerSnapshot?,
          OdometerSnapshot?
        >
    with $Provider<OdometerSnapshot?> {
  VisibleOdometerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'visibleOdometerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$visibleOdometerHash();

  @$internal
  @override
  $ProviderElement<OdometerSnapshot?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  OdometerSnapshot? create(Ref ref) {
    return visibleOdometer(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OdometerSnapshot? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OdometerSnapshot?>(value),
    );
  }
}

String _$visibleOdometerHash() => r'1c62a5d43be16278dad67ad787070f42c9a2629d';

@ProviderFor(visibleSeason)
final visibleSeasonProvider = VisibleSeasonProvider._();

final class VisibleSeasonProvider
    extends $FunctionalProvider<SeasonalMotif, SeasonalMotif, SeasonalMotif>
    with $Provider<SeasonalMotif> {
  VisibleSeasonProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'visibleSeasonProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$visibleSeasonHash();

  @$internal
  @override
  $ProviderElement<SeasonalMotif> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SeasonalMotif create(Ref ref) {
    return visibleSeason(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SeasonalMotif value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SeasonalMotif>(value),
    );
  }
}

String _$visibleSeasonHash() => r'7fca7068f4c36e0b8bce3df9246edaee750f1bd8';
