// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../tools.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ToolsSession)
final toolsSessionProvider = ToolsSessionProvider._();

final class ToolsSessionProvider
    extends $NotifierProvider<ToolsSession, ToolsState> {
  ToolsSessionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'toolsSessionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$toolsSessionHash();

  @$internal
  @override
  ToolsSession create() => ToolsSession();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ToolsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ToolsState>(value),
    );
  }
}

String _$toolsSessionHash() => r'4465d38e1c21a9a93d5ac78cf91c62fd12ee7157';

abstract class _$ToolsSession extends $Notifier<ToolsState> {
  ToolsState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ToolsState, ToolsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ToolsState, ToolsState>,
              ToolsState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
