// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../service_status.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ServiceStatus)
final serviceStatusProvider = ServiceStatusProvider._();

final class ServiceStatusProvider
    extends $NotifierProvider<ServiceStatus, ServiceStatusState> {
  ServiceStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serviceStatusProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serviceStatusHash();

  @$internal
  @override
  ServiceStatus create() => ServiceStatus();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ServiceStatusState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ServiceStatusState>(value),
    );
  }
}

String _$serviceStatusHash() => r'2c44db8d97277727be6fbd5f02bbf02077b13399';

abstract class _$ServiceStatus extends $Notifier<ServiceStatusState> {
  ServiceStatusState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ServiceStatusState, ServiceStatusState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ServiceStatusState, ServiceStatusState>,
              ServiceStatusState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
