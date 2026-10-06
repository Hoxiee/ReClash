// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../tools_pane.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A one-shot handoff: any surface asks the Tools tab to open a pane stack. The
/// first entry is the root, the rest are pushed on top, so a caller can land
/// the reader a few steps deep with a back-path. The Tools view consumes the
/// request on its next build and clears it, so a return trip does not reopen
/// the panes on its own; a view too narrow for the two-pane stack drops it.

@ProviderFor(ToolsPaneRequest)
final toolsPaneRequestProvider = ToolsPaneRequestProvider._();

/// A one-shot handoff: any surface asks the Tools tab to open a pane stack. The
/// first entry is the root, the rest are pushed on top, so a caller can land
/// the reader a few steps deep with a back-path. The Tools view consumes the
/// request on its next build and clears it, so a return trip does not reopen
/// the panes on its own; a view too narrow for the two-pane stack drops it.
final class ToolsPaneRequestProvider
    extends $NotifierProvider<ToolsPaneRequest, List<SettingsPaneSelection>?> {
  /// A one-shot handoff: any surface asks the Tools tab to open a pane stack. The
  /// first entry is the root, the rest are pushed on top, so a caller can land
  /// the reader a few steps deep with a back-path. The Tools view consumes the
  /// request on its next build and clears it, so a return trip does not reopen
  /// the panes on its own; a view too narrow for the two-pane stack drops it.
  ToolsPaneRequestProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'toolsPaneRequestProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$toolsPaneRequestHash();

  @$internal
  @override
  ToolsPaneRequest create() => ToolsPaneRequest();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<SettingsPaneSelection>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<SettingsPaneSelection>?>(value),
    );
  }
}

String _$toolsPaneRequestHash() => r'693aa4a2dd0122c5e48f073ab15096f8e78588bf';

/// A one-shot handoff: any surface asks the Tools tab to open a pane stack. The
/// first entry is the root, the rest are pushed on top, so a caller can land
/// the reader a few steps deep with a back-path. The Tools view consumes the
/// request on its next build and clears it, so a return trip does not reopen
/// the panes on its own; a view too narrow for the two-pane stack drops it.

abstract class _$ToolsPaneRequest
    extends $Notifier<List<SettingsPaneSelection>?> {
  List<SettingsPaneSelection>? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<List<SettingsPaneSelection>?, List<SettingsPaneSelection>?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                List<SettingsPaneSelection>?,
                List<SettingsPaneSelection>?
              >,
              List<SettingsPaneSelection>?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
