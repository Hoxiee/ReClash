import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/core/desktop/privilege.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';

/// Asks before ReClash installs or updates what TUN runs its Core through, so
/// the system password or UAC prompt never appears unexplained.
class TunPrivilegeSetupDialog extends ConsumerStatefulWidget {
  const TunPrivilegeSetupDialog({
    super.key,
    required this.setup,
    required this.platform,
  });

  final DesktopPrivilegeSetup setup;

  /// `linux`, `windows` or `macos`, as `Platform.operatingSystem` names it.
  final String platform;

  @override
  ConsumerState<TunPrivilegeSetupDialog> createState() =>
      _TunPrivilegeSetupDialogState();
}

class _TunPrivilegeSetupDialogState
    extends ConsumerState<TunPrivilegeSetupDialog> {
  bool _busy = false;
  Object? _error;

  DesktopPrivilegeSetup get _setup => widget.setup;

  bool get _actionable => _setup != DesktopPrivilegeSetup.unavailable;

  Future<void> _authorize() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final failure = await ref
          .read(setupActionProvider.notifier)
          .authorizeTun();
      if (!mounted) return;
      if (failure == null) {
        Navigator.of(context).pop();
        context.showNotifier(context.appLocalizations.tunSetupDone);
      } else {
        setState(() => _error = failure);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _later() {
    ref.read(tunPrivilegeSetupProvider.notifier).dismiss();
    Navigator.of(context).pop();
  }

  void _withoutTun() {
    Navigator.of(context).pop();
    unawaited(ref.read(setupActionProvider.notifier).setTunEnabled(false));
  }

  String _title(AppLocalizations l) => switch (_setup) {
    DesktopPrivilegeSetup.update => l.tunSetupUpdateTitle,
    DesktopPrivilegeSetup.approval => l.tunSetupApprovalTitle,
    DesktopPrivilegeSetup.unavailable => l.tunSetupUnavailableTitle,
    _ => l.tunSetupInstallTitle,
  };

  String _description(AppLocalizations l) {
    final update = _setup == DesktopPrivilegeSetup.update;
    return switch ((widget.platform, _setup)) {
      (_, DesktopPrivilegeSetup.unavailable) => l.desktopHelperUnavailable,
      ('macos', DesktopPrivilegeSetup.approval) =>
        l.desktopHelperApprovalRequired,
      ('macos', _) => l.tunSetupMacosInstall,
      ('windows', _) =>
        update ? l.tunSetupWindowsUpdate : l.tunSetupWindowsInstall,
      _ => update ? l.tunSetupLinuxUpdate : l.tunSetupLinuxInstall,
    };
  }

  List<(Glyph, String)> _points(AppLocalizations l) =>
      switch (widget.platform) {
        _ when !_actionable => const [],
        'linux' => [
          (AppGlyphs.lock, l.tunSetupOncePassword),
          (AppGlyphs.bolt, l.tunSetupInstantStart),
          (AppGlyphs.verified, l.tunSetupLinuxScope),
        ],
        'windows' => [
          (AppGlyphs.lock, l.tunSetupOnceConfirm),
          (AppGlyphs.bolt, l.tunSetupInstantStart),
          (AppGlyphs.verified, l.tunSetupWindowsScope),
        ],
        _ => const [],
      };

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final points = _points(l);
    final footnote = AppTextStyle.footnote
        .of(context)
        .copyWith(color: colorScheme.onSurfaceVariant);
    return PopScope(
      canPop: !_busy,
      child: CommonDialog(
        title: _title(l),
        actions: [
          TextButton(
            onPressed: _busy ? null : _later,
            child: Text(_actionable ? l.tunSetupLater : l.close),
          ),
          TextButton(
            onPressed: _busy ? null : _withoutTun,
            child: Text(l.tunSetupWithoutTun),
          ),
          if (_actionable)
            TextButton(
              onPressed: _busy ? null : _authorize,
              child: Text(switch (_setup) {
                _ when _error != null => l.retry,
                DesktopPrivilegeSetup.update => l.update,
                _ => l.tunSetupConfirm,
              }),
            ),
        ],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_description(l)),
            if (points.isNotEmpty) ...[
              const SizedBox(height: 16),
              for (final (glyph, label) in points)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 12,
                    children: [
                      GlyphIcon(glyph, size: 20, color: colorScheme.primary),
                      Expanded(child: Text(label)),
                    ],
                  ),
                ),
            ],
            if (widget.platform == 'linux' && _actionable) ...[
              const SizedBox(height: 12),
              Text(l.tunSetupPasswordPrivacy, style: footnote),
            ],
            if (_busy) ...[
              const SizedBox(height: 20),
              const LinearProgressIndicator(),
              const SizedBox(height: 12),
              Text(l.tunSetupWaiting, style: footnote),
            ],
            if (_error case final error? when !_busy) ...[
              const SizedBox(height: 16),
              Text(
                userFacingErrorMessage(error, l),
                style: footnote.copyWith(color: colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
