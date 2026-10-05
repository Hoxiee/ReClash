// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../core.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(coreHandler)
final coreHandlerProvider = CoreHandlerProvider._();

final class CoreHandlerProvider
    extends
        $FunctionalProvider<
          CoreHandlerInterface,
          CoreHandlerInterface,
          CoreHandlerInterface
        >
    with $Provider<CoreHandlerInterface> {
  CoreHandlerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'coreHandlerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$coreHandlerHash();

  @$internal
  @override
  $ProviderElement<CoreHandlerInterface> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CoreHandlerInterface create(Ref ref) {
    return coreHandler(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CoreHandlerInterface value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CoreHandlerInterface>(value),
    );
  }
}

String _$coreHandlerHash() => r'594b1e105a02bd2e415dca12b7b9448ff9141bfc';
