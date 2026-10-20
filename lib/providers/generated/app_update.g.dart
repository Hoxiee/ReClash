// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../app_update.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appUpdateRuntime)
final appUpdateRuntimeProvider = AppUpdateRuntimeProvider._();

final class AppUpdateRuntimeProvider
    extends
        $FunctionalProvider<
          AppUpdateRuntime,
          AppUpdateRuntime,
          AppUpdateRuntime
        >
    with $Provider<AppUpdateRuntime> {
  AppUpdateRuntimeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appUpdateRuntimeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appUpdateRuntimeHash();

  @$internal
  @override
  $ProviderElement<AppUpdateRuntime> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppUpdateRuntime create(Ref ref) {
    return appUpdateRuntime(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppUpdateRuntime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppUpdateRuntime>(value),
    );
  }
}

String _$appUpdateRuntimeHash() => r'd27120eaffe76e7f5312a512fd4f06ffa77ebcac';
