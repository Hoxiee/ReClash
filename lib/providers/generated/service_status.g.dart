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
    extends
        $NotifierProvider<
          ServiceStatus,
          RoutedProbeState<ServiceTarget, ServiceCheck>
        > {
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
  Override overrideWithValue(
    RoutedProbeState<ServiceTarget, ServiceCheck> value,
  ) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<RoutedProbeState<ServiceTarget, ServiceCheck>>(
            value,
          ),
    );
  }
}

String _$serviceStatusHash() => r'3ea6e4ac5844063393502ad539b17041a6dc6d54';

abstract class _$ServiceStatus
    extends $Notifier<RoutedProbeState<ServiceTarget, ServiceCheck>> {
  RoutedProbeState<ServiceTarget, ServiceCheck> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              RoutedProbeState<ServiceTarget, ServiceCheck>,
              RoutedProbeState<ServiceTarget, ServiceCheck>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                RoutedProbeState<ServiceTarget, ServiceCheck>,
                RoutedProbeState<ServiceTarget, ServiceCheck>
              >,
              RoutedProbeState<ServiceTarget, ServiceCheck>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
