// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../tool_commands.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ToolCommands)
final toolCommandsProvider = ToolCommandsProvider._();

final class ToolCommandsProvider
    extends $NotifierProvider<ToolCommands, Set<ToolCommand>> {
  ToolCommandsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'toolCommandsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$toolCommandsHash();

  @$internal
  @override
  ToolCommands create() => ToolCommands();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<ToolCommand> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<ToolCommand>>(value),
    );
  }
}

String _$toolCommandsHash() => r'99fb3e14af34c2cb4207bf809f64ae7f033adb4b';

abstract class _$ToolCommands extends $Notifier<Set<ToolCommand>> {
  Set<ToolCommand> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Set<ToolCommand>, Set<ToolCommand>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<ToolCommand>, Set<ToolCommand>>,
              Set<ToolCommand>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
