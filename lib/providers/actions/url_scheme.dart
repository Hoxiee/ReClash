part of '../action.dart';

@Riverpod(keepAlive: true)
class UrlSchemeAction extends _$UrlSchemeAction {
  @override
  void build() {}

  Future<void> handleLink(
    String input, {
    required Future<bool> Function(ReClashCommand action) confirmCommand,
    required Future<SubscriptionClientSettings?> Function(
      ProfileLinkSource source,
    )
    confirmImport,
    bool Function()? isCurrent,
  }) async {
    bool current() => ref.mounted && (isCurrent?.call() ?? true);
    final link = await readUrlSchemeLink(input);
    if (!current()) return;
    if (link != null && !link.command.isProfile) {
      await execute(
        link.command,
        confirm: (action) async =>
            current() && await confirmCommand(action) && current(),
      );
      return;
    }
    await windowPort?.show();
    if (!current()) return;
    if (ref.read(setupSessionProvider).active) {
      ref.read(setupSessionProvider.notifier).offerLink(input);
      return;
    }
    final source = await resolveProfileLink(input);
    final clientSettings = await confirmImport(source);
    if (!current() || clientSettings == null) return;
    if (ref.read(setupSessionProvider).active) {
      ref.read(setupSessionProvider.notifier).offerLink(input);
      return;
    }
    await ref
        .read(profilesActionProvider.notifier)
        .addProfileLinkSource(source, clientSettings: clientSettings);
  }

  Future<void> execute(
    ReClashCommand command, {
    required Future<bool> Function(ReClashCommand action) confirm,
  }) async {
    if (command.isProfile) return;
    await windowPort?.show();
    if (!ref.mounted) return;
    if (command == ReClashCommand.open) return;
    if (command.changesConnection && ref.read(setupSessionProvider).active) {
      throw MessageException(currentAppLocalizations.urlSchemeSetupRequired);
    }
    final action = command == ReClashCommand.toggle
        ? ref.read(isStartProvider)
              ? ReClashCommand.disconnect
              : ReClashCommand.connect
        : command;
    if (!await confirm(action) || !ref.mounted) return;
    if (action.changesConnection && ref.read(setupSessionProvider).active) {
      throw MessageException(currentAppLocalizations.urlSchemeSetupRequired);
    }
    if (action == ReClashCommand.close) {
      await ref.read(systemActionProvider.notifier).handleClose();
      return;
    }
    final running = action == ReClashCommand.connect;
    await ref.read(commonActionProvider.notifier).setRunning(running);
  }
}
