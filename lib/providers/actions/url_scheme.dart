part of '../action.dart';

@Riverpod(keepAlive: true)
class UrlSchemeAction extends _$UrlSchemeAction {
  @override
  void build() {}

  Future<void> handleLink(
    String input, {
    required Future<bool> Function(ReClashCommand action) confirmCommand,
    required Future<ProfileLinkImport?> Function(
      ProfileLinkSource source,
      ProfileLinkCommit commit,
    )
    confirmImport,
    required Future<void> Function(String text, String origin) openRouting,
    bool Function()? isCurrent,
  }) async {
    bool current() => ref.mounted && (isCurrent?.call() ?? true);
    final link = await readUrlSchemeLink(input);
    if (!current()) return;
    if (link != null &&
        !link.command.isProfile &&
        link.command != ReClashCommand.routing) {
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
    if (link != null && link.command == ReClashCommand.routing) {
      final (text, origin) = await _resolveRouting(link.payload!);
      if (!current()) return;
      await openRouting(text, origin);
      return;
    }
    final source = await resolveProfileLink(input);
    var imported = false;
    final choice = await confirmImport(source, (
      choice, {
      reviewContext,
      cancellation,
    }) async {
      if (!current() || ref.read(setupSessionProvider).active) return;
      await ref
          .read(profilesActionProvider.notifier)
          .addConfirmedLinkSource(
            source,
            label: choice.label,
            clientSettings: choice.clientSettings,
            reviewContext: reviewContext,
            cancellation: cancellation,
          );
      imported = true;
    });
    if (!current() || choice == null) return;
    if (imported) {
      ref.read(profilesActionProvider.notifier).showProfiles();
    } else if (ref.read(setupSessionProvider).active) {
      ref.read(setupSessionProvider.notifier).offerLink(input);
    }
  }

  Future<(String, String)> _resolveRouting(String payload) async {
    if (!payload.startsWith('https://')) {
      try {
        return (decodeRcxPayload(payload), 'link');
      } on RcxPayloadTooLarge {
        throw const UrlSchemeException(UrlSchemeIssue.tooLarge);
      } on FormatException {
        throw const UrlSchemeException(UrlSchemeIssue.invalidBase64);
      }
    }
    final response = await request.getFileResponseForUrl(payload);
    final bytes = response.data;
    if (bytes == null || bytes.isEmpty) {
      throw const UrlSchemeException(UrlSchemeIssue.missingPayload);
    }
    if (bytes.length > rcxLinkMaxBytes) {
      throw const UrlSchemeException(UrlSchemeIssue.tooLarge);
    }
    try {
      return (utf8.decode(bytes), Uri.parse(payload).host);
    } on FormatException {
      throw const UrlSchemeException(UrlSchemeIssue.invalidLink);
    }
  }

  Future<void> execute(
    ReClashCommand command, {
    required Future<bool> Function(ReClashCommand action) confirm,
  }) async {
    if (command.isProfile || command == ReClashCommand.routing) return;
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
