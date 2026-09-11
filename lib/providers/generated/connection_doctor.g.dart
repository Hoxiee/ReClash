// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../connection_doctor.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ConnectionDoctor)
final connectionDoctorProvider = ConnectionDoctorProvider._();

final class ConnectionDoctorProvider
    extends $NotifierProvider<ConnectionDoctor, DoctorSnapshot> {
  ConnectionDoctorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectionDoctorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectionDoctorHash();

  @$internal
  @override
  ConnectionDoctor create() => ConnectionDoctor();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DoctorSnapshot value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DoctorSnapshot>(value),
    );
  }
}

String _$connectionDoctorHash() => r'1001c6e524e28e182513da77d0d43fbeff15dde2';

abstract class _$ConnectionDoctor extends $Notifier<DoctorSnapshot> {
  DoctorSnapshot build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DoctorSnapshot, DoctorSnapshot>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DoctorSnapshot, DoctorSnapshot>,
              DoctorSnapshot,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
