import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/tools.dart';
import 'package:reclash/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/tool_commands.g.dart';

@Riverpod(keepAlive: true)
class ToolCommands extends _$ToolCommands {
  @override
  Set<ToolCommand> build() => const {};

  bool available(ToolCommand command) =>
      command == ToolCommand.checkUpdates ||
      ref.read(coreStatusProvider) == CoreStatus.connected;

  Future<bool> execute(
    ToolCommand command, {
    required Future<bool> Function() confirm,
  }) async {
    if (state.contains(command) || !available(command)) return false;
    state = {...state, command};
    try {
      if (command != ToolCommand.checkUpdates && !await confirm()) return false;
      if (!ref.mounted || !available(command)) return false;
      switch (command) {
        case ToolCommand.checkUpdates:
          await ref.read(commonActionProvider.notifier).checkForUpdates();
        case ToolCommand.updateResources:
          final failures = await ref
              .read(resourcesActionProvider.notifier)
              .updateAll();
          dialogs.showFailures(failures);
          return failures.isEmpty;
        case ToolCommand.closeConnections:
          await ref.read(coreActionProvider.notifier).closeConnections();
        case ToolCommand.restartCore:
          return await ref.read(coreActionProvider.notifier).restartCore();
      }
      return true;
    } finally {
      if (ref.mounted) state = {...state}..remove(command);
    }
  }
}
