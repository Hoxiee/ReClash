import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/widgets/icon.dart';

import 'apply.dart';
import 'link.dart';
import 'providers.dart';
import 'verifier.dart';

/// Checks [link] and, only once the user confirms, applies it.
Future<void> showFixLinkSheet(BuildContext context, {required String link}) =>
    showFormSheet<void>(
      context: context,
      builder: (_) => FixLinkSheet(link: link),
    );

String fixRejectionText(AppLocalizations l, FixLinkRejection reason) =>
    switch (reason) {
      FixLinkRejection.oversized => l.fixLinkRejectOversized,
      FixLinkRejection.malformed => l.fixLinkRejectMalformed,
      FixLinkRejection.unknownKey => l.fixLinkRejectUnknownKey,
      FixLinkRejection.badSignature => l.fixLinkRejectBadSignature,
      FixLinkRejection.expired => l.fixLinkRejectExpired,
      FixLinkRejection.tooFarAhead => l.fixLinkRejectTooFarAhead,
      FixLinkRejection.replayed => l.fixLinkRejectReplayed,
      FixLinkRejection.unknownReport => l.fixLinkRejectUnknownReport,
      FixLinkRejection.otherProfile => l.fixLinkRejectOtherProfile,
      FixLinkRejection.unknownAction => l.fixLinkRejectUnknownAction,
      FixLinkRejection.unknownGroup => l.fixLinkRejectUnknownGroup,
    };

String fixActionText(AppLocalizations l, FixAction action) =>
    switch (action.kind) {
      FixActionKind.profileUpdate => l.fixLinkActionProfileUpdate,
      FixActionKind.profileActivate => l.fixLinkActionProfileActivate,
      FixActionKind.proxySelect => l.fixLinkActionProxySelect(
        action.node!,
        action.group!,
      ),
      FixActionKind.connectionsReset => l.fixLinkActionConnectionsReset,
      FixActionKind.coreRestart => l.fixLinkActionCoreRestart,
      FixActionKind.overridesReset => l.fixLinkActionOverridesReset,
      FixActionKind.remedy => switch (action.id) {
        'config.ruleMode' => l.fixLinkActionRuleMode,
        'device.ignoreBatteryOptimization' => l.fixLinkActionBattery,
        'device.openVpnSettings' => l.fixLinkActionVpnSettings,
        'device.openPrivateDnsSettings' => l.fixLinkActionPrivateDns,
        'device.openDateSettings' => l.fixLinkActionDateSettings,
        'network.openCaptivePortal' => l.fixLinkActionCaptivePortal,
        'device.requestVpnPermission' => l.fixLinkActionVpnPermission,
        'dns.ignoreSystemHosts' => l.fixLinkActionIgnoreSystemHosts,
        'system.openHosts' => l.fixLinkActionOpenHosts,
        'config.freePort' => l.fixLinkActionFreePort,
        'tunnel.freeDeviceName' => l.fixLinkActionFreeDeviceName,
        'tunnel.restart' => l.fixLinkActionTunnelRestart,
        'proxy.clearOwn' => l.fixLinkActionClearOwnProxy,
        final id => l.fixLinkActionOther(id),
      },
    };

class FixLinkSheet extends ConsumerStatefulWidget {
  const FixLinkSheet({super.key, required this.link});

  final String link;

  @override
  ConsumerState<FixLinkSheet> createState() => _FixLinkSheetState();
}

class _FixLinkSheetState extends ConsumerState<FixLinkSheet> {
  VerifiedFixLink? _verified;
  FixLinkRejection? _rejection;
  FixLinkResult? _result;
  bool _applying = false;
  bool _undone = false;

  @override
  void initState() {
    super.initState();
    unawaited(_verify());
  }

  void _reject(Object error) {
    if (!mounted) return;
    setState(
      () => _rejection = error is FixLinkRejected
          ? error.reason
          : FixLinkRejection.malformed,
    );
  }

  Future<void> _verify() async {
    try {
      final verified = await ref
          .read(fixLinkServiceProvider)
          .verify(widget.link);
      if (mounted) setState(() => _verified = verified);
    } on Object catch (error) {
      _reject(error);
    }
  }

  Future<void> _apply(String provider) async {
    setState(() => _applying = true);
    try {
      final result = await ref
          .read(fixLinkServiceProvider)
          .apply(widget.link, provider: provider);
      if (mounted) setState(() => _result = result);
    } on Object catch (error) {
      _reject(error);
    } finally {
      if (mounted) setState(() => _applying = false);
    }
  }

  Future<void> _undo(FixLinkResult result) async {
    setState(() => _undone = true);
    final undone = await ref.read(fixLinkServiceProvider).undo(result);
    if (!mounted) return;
    final l = context.appLocalizations;
    context.showNotifier(
      undone ? l.fixLinkUndone : l.fixLinkUndoStale,
      level: undone ? MessageLevel.success : MessageLevel.warning,
    );
  }

  Future<void> _copy(FixLinkResult result) async {
    await Clipboard.setData(ClipboardData(text: result.summary));
    if (!mounted) return;
    context.showNotifier(
      context.appLocalizations.copySuccess,
      level: MessageLevel.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final verified = _verified;
    final rejection = _rejection;
    final result = _result;
    final profile = verified == null
        ? null
        : ref.watch(profilesProvider).getProfile(verified.profileId);
    final metadata = profile?.subscriptionSnapshot?.metadata;
    final provider = metadata?.name ?? profile?.realLabel ?? '';
    void close() => Navigator.of(context).pop();
    return CommonScaffold(
      title: l.fixLinkTitle,
      isLoading: _applying || rejection == null && verified == null,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ).copyWith(top: context.contentTopPadding, bottom: 8),
              child: switch ((rejection, verified)) {
                (final reason?, _) => generateSection(
                  items: [
                    DecorationListItem(
                      leading: GlyphIcon(
                        AppGlyphs.warning,
                        color: context.colorScheme.error,
                      ),
                      title: Text(l.fixLinkRejectedTitle),
                      subtitle: Text(fixRejectionText(l, reason)),
                    ),
                  ],
                  footer: l.fixLinkNothingChanged,
                ),
                (_, final verified?) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    generateSection(
                      items: [
                        DecorationListItem(
                          leading: SizedBox.square(
                            dimension: 32,
                            child: CommonTargetIcon(
                              src:
                                  metadata?.logoFor(
                                    dark:
                                        context.colorScheme.brightness ==
                                        Brightness.dark,
                                  ) ??
                                  '',
                              fallback: const GlyphIcon(AppGlyphs.profiles),
                            ),
                          ),
                          title: EmojiText(provider),
                          subtitle: Row(
                            spacing: 4,
                            children: [
                              GlyphIcon(
                                AppGlyphs.verified,
                                size: 16,
                                color: context.colorScheme.success,
                              ),
                              Flexible(child: Text(l.fixLinkVerified)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    generateSection(
                      title: switch (result) {
                        null => l.fixLinkActions,
                        FixLinkResult(ok: true) => l.fixLinkApplied,
                        _ => l.fixLinkPartlyFailed,
                      },
                      items: [
                        for (final (index, action)
                            in verified.payload.actions.indexed)
                          DecorationListItem(
                            leading: _StepGlyph(step: result?.steps[index]),
                            title: Text(fixActionText(l, action)),
                          ),
                      ],
                      footer: l.fixLinkReport(verified.payload.reportId),
                    ),
                  ],
                ),
                _ => const SizedBox.shrink(),
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: AlertActions(
              actions: switch ((rejection, verified, result)) {
                (null, _?, final result?) => [
                  if (result.canUndo)
                    TextButton(
                      onPressed: _undone
                          ? null
                          : () => unawaited(_undo(result)),
                      child: Text(l.undo),
                    ),
                  TextButton(
                    onPressed: () => unawaited(_copy(result)),
                    child: Text(l.fixLinkCopyResult),
                  ),
                  TextButton(onPressed: close, child: Text(l.done)),
                ],
                (null, _?, null) => [
                  TextButton(
                    onPressed: _applying ? null : close,
                    child: Text(l.cancel),
                  ),
                  TextButton(
                    onPressed: _applying
                        ? null
                        : () => unawaited(_apply(provider)),
                    child: Text(l.fixLinkApply),
                  ),
                ],
                _ => [TextButton(onPressed: close, child: Text(l.close))],
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StepGlyph extends StatelessWidget {
  const _StepGlyph({required this.step});

  final FixStep? step;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return switch (step) {
      null => const GlyphIcon(AppGlyphs.wrench),
      FixStep(ok: true) => GlyphIcon(
        AppGlyphs.checkCircle,
        color: colors.success,
      ),
      _ => GlyphIcon(AppGlyphs.error, color: colors.error),
    };
  }
}
