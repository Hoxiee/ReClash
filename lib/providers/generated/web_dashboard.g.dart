// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../web_dashboard.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(webDashboardEnvironment)
final webDashboardEnvironmentProvider = WebDashboardEnvironmentProvider._();

final class WebDashboardEnvironmentProvider
    extends
        $FunctionalProvider<
          WebDashboardEnvironment,
          WebDashboardEnvironment,
          WebDashboardEnvironment
        >
    with $Provider<WebDashboardEnvironment> {
  WebDashboardEnvironmentProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'webDashboardEnvironmentProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$webDashboardEnvironmentHash();

  @$internal
  @override
  $ProviderElement<WebDashboardEnvironment> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WebDashboardEnvironment create(Ref ref) {
    return webDashboardEnvironment(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WebDashboardEnvironment value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WebDashboardEnvironment>(value),
    );
  }
}

String _$webDashboardEnvironmentHash() =>
    r'c30d9e48a6c1d57551b0da2ae893ba4c2524098f';

@ProviderFor(webDashboardStore)
final webDashboardStoreProvider = WebDashboardStoreProvider._();

final class WebDashboardStoreProvider
    extends
        $FunctionalProvider<
          WebDashboardStore,
          WebDashboardStore,
          WebDashboardStore
        >
    with $Provider<WebDashboardStore> {
  WebDashboardStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'webDashboardStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$webDashboardStoreHash();

  @$internal
  @override
  $ProviderElement<WebDashboardStore> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WebDashboardStore create(Ref ref) {
    return webDashboardStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WebDashboardStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WebDashboardStore>(value),
    );
  }
}

String _$webDashboardStoreHash() => r'18da691a7eac1c4893f9a8fca4ff34675d5bf31d';

@ProviderFor(WebDashboardAccess)
final webDashboardAccessProvider = WebDashboardAccessProvider._();

final class WebDashboardAccessProvider
    extends $NotifierProvider<WebDashboardAccess, WebDashboardAccessState> {
  WebDashboardAccessProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'webDashboardAccessProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$webDashboardAccessHash();

  @$internal
  @override
  WebDashboardAccess create() => WebDashboardAccess();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WebDashboardAccessState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WebDashboardAccessState>(value),
    );
  }
}

String _$webDashboardAccessHash() =>
    r'58bd68d7ca28e8e0e0519f1396e407c76e9e2cd0';

abstract class _$WebDashboardAccess extends $Notifier<WebDashboardAccessState> {
  WebDashboardAccessState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<WebDashboardAccessState, WebDashboardAccessState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<WebDashboardAccessState, WebDashboardAccessState>,
              WebDashboardAccessState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(WebDashboardAction)
final webDashboardActionProvider = WebDashboardActionProvider._();

final class WebDashboardActionProvider
    extends $NotifierProvider<WebDashboardAction, WebDashboardState> {
  WebDashboardActionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'webDashboardActionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$webDashboardActionHash();

  @$internal
  @override
  WebDashboardAction create() => WebDashboardAction();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WebDashboardState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WebDashboardState>(value),
    );
  }
}

String _$webDashboardActionHash() =>
    r'93c12ed1e7425d64b6cc2b0dfdf210786cb9c4c0';

abstract class _$WebDashboardAction extends $Notifier<WebDashboardState> {
  WebDashboardState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<WebDashboardState, WebDashboardState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<WebDashboardState, WebDashboardState>,
              WebDashboardState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
