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
    Future<void> Function(String? check)? openDoctor,
    bool Function()? isCurrent,
  }) async {
    bool current() => ref.mounted && (isCurrent?.call() ?? true);
    final link = await readUrlSchemeLink(input);
    if (!current()) return;
    if (link != null &&
        !link.command.isProfile &&
        link.command != ReClashCommand.routing &&
        link.command != ReClashCommand.doctor) {
      await execute(
        link.command,
        confirm: (action) async =>
            current() && await confirmCommand(action) && current(),
      );
      return;
    }
    await windowPort?.show();
    if (!current()) return;
    if (_holdLink(input)) return;
    if (link?.command == ReClashCommand.doctor) {
      await openDoctor?.call(link!.payload);
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
      if (!current() || ref.read(setupSessionProvider.notifier).holdsLinks) {
        return;
      }
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
    } else {
      _holdLink(input);
    }
  }

  bool _holdLink(String input) {
    final session = ref.read(setupSessionProvider.notifier);
    if (!session.holdsLinks) return false;
    session.offerLink(input);
    return true;
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

  bool get _awaitsConsent => ref.read(setupSessionProvider.notifier).holdsLinks;

  Future<void> execute(
    ReClashCommand command, {
    required Future<bool> Function(ReClashCommand action) confirm,
  }) async {
    if (command.isProfile || command == ReClashCommand.routing) return;
    await windowPort?.show();
    if (!ref.mounted) return;
    if (command == ReClashCommand.open) return;
    if (_awaitsConsent) {
      throw MessageException(currentAppLocalizations.urlSchemeSetupRequired);
    }
    final action = command == ReClashCommand.toggle
        ? ref.read(isStartProvider)
              ? ReClashCommand.disconnect
              : ReClashCommand.connect
        : command;
    if (!await confirm(action) || !ref.mounted) return;
    if (_awaitsConsent) {
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
