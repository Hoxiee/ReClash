// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../on_demand.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LocationPermissions)
final locationPermissionsProvider = LocationPermissionsProvider._();

final class LocationPermissionsProvider
    extends $NotifierProvider<LocationPermissions, WifiSsidPermission> {
  LocationPermissionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'locationPermissionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$locationPermissionsHash();

  @$internal
  @override
  LocationPermissions create() => LocationPermissions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WifiSsidPermission value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WifiSsidPermission>(value),
    );
  }
}

String _$locationPermissionsHash() =>
    r'c94eea2c1c5640d86955e23d0e754ce27cf0de1d';

abstract class _$LocationPermissions extends $Notifier<WifiSsidPermission> {
  WifiSsidPermission build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<WifiSsidPermission, WifiSsidPermission>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<WifiSsidPermission, WifiSsidPermission>,
              WifiSsidPermission,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(BatteryOptimizationIgnored)
final batteryOptimizationIgnoredProvider =
    BatteryOptimizationIgnoredProvider._();

final class BatteryOptimizationIgnoredProvider
    extends $StreamNotifierProvider<BatteryOptimizationIgnored, bool> {
  BatteryOptimizationIgnoredProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'batteryOptimizationIgnoredProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$batteryOptimizationIgnoredHash();

  @$internal
  @override
  BatteryOptimizationIgnored create() => BatteryOptimizationIgnored();
}

String _$batteryOptimizationIgnoredHash() =>
    r'57dec1c4aa0a54c5af1a6934a3d4f78407df8013';

abstract class _$BatteryOptimizationIgnored extends $StreamNotifier<bool> {
  Stream<bool> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(onDemandNeedsSsid)
final onDemandNeedsSsidProvider = OnDemandNeedsSsidProvider._();

final class OnDemandNeedsSsidProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  OnDemandNeedsSsidProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onDemandNeedsSsidProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onDemandNeedsSsidHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return onDemandNeedsSsid(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$onDemandNeedsSsidHash() => r'a3e8f724065037b353aa5b7895b90429d9e37549';

@ProviderFor(PhysicalAddresses)
final physicalAddressesProvider = PhysicalAddressesProvider._();

final class PhysicalAddressesProvider
    extends $NotifierProvider<PhysicalAddresses, List<String>> {
  PhysicalAddressesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'physicalAddressesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$physicalAddressesHash();

  @$internal
  @override
  PhysicalAddresses create() => PhysicalAddresses();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$physicalAddressesHash() => r'4ac4041f60032b2e77c63ffdbeae7a4b678d96da';

abstract class _$PhysicalAddresses extends $Notifier<List<String>> {
  List<String> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<String>, List<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<String>, List<String>>,
              List<String>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(NativeOnDemandPause)
final nativeOnDemandPauseProvider = NativeOnDemandPauseProvider._();

final class NativeOnDemandPauseProvider
    extends $NotifierProvider<NativeOnDemandPause, bool> {
  NativeOnDemandPauseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nativeOnDemandPauseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nativeOnDemandPauseHash();

  @$internal
  @override
  NativeOnDemandPause create() => NativeOnDemandPause();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$nativeOnDemandPauseHash() =>
    r'39b960489cd647aaea1cb298fa7c2fc7c17f2b80';

abstract class _$NativeOnDemandPause extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(OnDemandOverride)
final onDemandOverrideProvider = OnDemandOverrideProvider._();

final class OnDemandOverrideProvider
    extends
        $NotifierProvider<
          OnDemandOverride,
          ({List<String> anchor, bool? paused})
        > {
  OnDemandOverrideProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onDemandOverrideProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onDemandOverrideHash();

  @$internal
  @override
  OnDemandOverride create() => OnDemandOverride();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(({List<String> anchor, bool? paused}) value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<({List<String> anchor, bool? paused})>(value),
    );
  }
}

String _$onDemandOverrideHash() => r'd7a943afce7530d69ae6b7e52f0f09e80de98093';

abstract class _$OnDemandOverride
    extends $Notifier<({List<String> anchor, bool? paused})> {
  ({List<String> anchor, bool? paused}) build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              ({List<String> anchor, bool? paused}),
              ({List<String> anchor, bool? paused})
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                ({List<String> anchor, bool? paused}),
                ({List<String> anchor, bool? paused})
              >,
              ({List<String> anchor, bool? paused}),
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(onDemandNetworkAnchor)
final onDemandNetworkAnchorProvider = OnDemandNetworkAnchorProvider._();

final class OnDemandNetworkAnchorProvider
    extends $FunctionalProvider<List<String>, List<String>, List<String>>
    with $Provider<List<String>> {
  OnDemandNetworkAnchorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onDemandNetworkAnchorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onDemandNetworkAnchorHash();

  @$internal
  @override
  $ProviderElement<List<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<String> create(Ref ref) {
    return onDemandNetworkAnchor(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$onDemandNetworkAnchorHash() =>
    r'9c7e62f200aebc6ed6b39411d268a04b3162b03d';

@ProviderFor(onDemandMatchedNetworks)
final onDemandMatchedNetworksProvider = OnDemandMatchedNetworksProvider._();

final class OnDemandMatchedNetworksProvider
    extends $FunctionalProvider<List<String>, List<String>, List<String>>
    with $Provider<List<String>> {
  OnDemandMatchedNetworksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onDemandMatchedNetworksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onDemandMatchedNetworksHash();

  @$internal
  @override
  $ProviderElement<List<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<String> create(Ref ref) {
    return onDemandMatchedNetworks(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$onDemandMatchedNetworksHash() =>
    r'bde587bb690c05d90fceabcb84aaccea302cbd03';
