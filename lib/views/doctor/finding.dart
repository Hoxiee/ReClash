import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/doctor/finding.dart';
import 'package:reclash/features/doctor/providers.dart';
import 'package:reclash/features/doctor/remedies/remedy.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';

String findingTitle(AppLocalizations l, Finding finding) =>
    switch (finding.titleKey) {
      'doctorCauseClockSkew' => l.doctorCauseClockSkew,
      'doctorTelegramProxyTitle' => l.doctorTelegramProxyTitle,
      'doctorBatteryOptimizationTitle' => l.doctorBatteryOptimizationTitle,
      'doctorCauseSubscriptionExpired' => l.doctorCauseSubscriptionExpired,
      'doctorCauseTrafficExhausted' => l.doctorCauseTrafficExhausted,
      'doctorDirectModeTitle' => l.doctorDirectModeTitle,
      'doctorVpnRevokedTitle' => l.doctorVpnRevokedTitle,
      'doctorCauseTunnelTaken' => l.doctorCauseTunnelTaken,
      'doctorAlwaysOnOtherTitle' => l.doctorAlwaysOnOtherTitle,
      'doctorAlwaysOnOffTitle' => l.doctorAlwaysOnOffTitle,
      'doctorPrivateDnsTitle' => l.doctorPrivateDnsTitle,
      'doctorCauseCaptivePortal' => l.doctorCauseCaptivePortal,
      'doctorHostsServerTitle' => l.doctorHostsServerTitle,
      'doctorHostsServicesTitle' => l.doctorHostsServicesTitle,
      'doctorHostsLargeTitle' => l.doctorHostsLargeTitle,
      'doctorInterceptorTitle' => l.doctorInterceptorTitle,
      'doctorForeignTunnelTitle' => l.doctorForeignTunnelTitle,
      'doctorTunnelNameTitle' => l.doctorTunnelNameTitle,
      'doctorDeadProxyTitle' => l.doctorDeadProxyTitle,
      'doctorProxyTakenTitle' => l.doctorProxyTakenTitle,
      'doctorPortTakenTitle' => l.doctorPortTakenTitle(
        finding.args['port'] as int? ?? 0,
      ),
      'doctorDeadDnsTitle' => l.doctorDeadDnsTitle,
      'doctorProfileRevokedTitle' => l.doctorProfileRevokedTitle,
      'doctorProfileNoServersTitle' => l.doctorProfileNoServersTitle,
      _ => finding.titleKey,
    };

String findingDetail(AppLocalizations l, Finding finding) {
  final args = finding.args;
  return switch (finding.detailKey) {
    'doctorClockSkewBehind' => l.doctorClockSkewBehind(
      args['seconds'] as int? ?? 0,
    ),
    'doctorTelegramProxyDetail' => l.doctorTelegramProxyDetail(
      args['error'] as String? ?? '',
    ),
    'doctorClockSkewAhead' => l.doctorClockSkewAhead(
      args['seconds'] as int? ?? 0,
    ),
    'doctorBatteryOptimizationDetail' => l.doctorBatteryOptimizationDetail,
    'doctorSubscriptionDetail' => l.doctorSubscriptionDetail,
    'doctorDirectModeDetail' => l.doctorDirectModeDetail,
    'doctorVpnRevokedDetail' => l.doctorVpnRevokedDetail,
    'doctorOtherVpnDetail' => l.doctorOtherVpnDetail,
    'doctorAlwaysOnOtherDetail' => l.doctorAlwaysOnOtherDetail,
    'doctorAlwaysOnOffDetail' => l.doctorAlwaysOnOffDetail,
    'doctorPrivateDnsDetail' => l.doctorPrivateDnsDetail(
      args['host'] as String? ?? '',
    ),
    'doctorCaptivePortalDetail' => l.doctorCaptivePortalDetail,
    'doctorProfileRevokedDetail' => l.doctorProfileRevokedDetail(
      args['status'] as int? ?? 0,
    ),
    'doctorProfileNoServersDetail' => l.doctorProfileNoServersDetail,
    'doctorHostsServerDetail' => l.doctorHostsServerDetail(
      args['domain'] as String? ?? '',
      args['count'] as int? ?? 0,
    ),
    'doctorHostsServicesDetail' => l.doctorHostsServicesDetail(
      args['domains'] as String? ?? '',
      args['count'] as int? ?? 0,
    ),
    'doctorHostsLargeDetail' => l.doctorHostsLargeDetail(
      args['lines'] as int? ?? 0,
    ),
    'doctorInterceptorDetail' => l.doctorInterceptorDetail(
      args['name'] as String? ?? '',
    ),
    'doctorInterceptorUnknownDetail' => l.doctorInterceptorUnknownDetail,
    'doctorForeignTunnelDetail' => l.doctorForeignTunnelDetail(
      args['name'] as String? ?? '',
    ),
    'doctorTunnelNameDetail' => l.doctorTunnelNameDetail(
      args['name'] as String? ?? '',
    ),
    'doctorDeadProxyDetail' => l.doctorDeadProxyDetail(
      args['address'] as String? ?? '',
    ),
    'doctorProxyOffDetail' => l.doctorProxyOffDetail,
    'doctorProxyTakenDetail' => l.doctorProxyTakenDetail(
      args['address'] as String? ?? '',
    ),
    'doctorPortTakenDetail' => l.doctorPortTakenDetail(
      args['owner'] as String? ?? '',
    ),
    'doctorPortReservedDetail' => l.doctorPortReservedDetail(
      args['port'] as int? ?? 0,
    ),
    'doctorDeadDnsDetail' => l.doctorDeadDnsDetail,
    _ => finding.detailKey,
  };
}

extension FindingSeverityView on CheckSeverity {
  Glyph get glyph => switch (this) {
    CheckSeverity.critical => AppGlyphs.error,
    CheckSeverity.warning => AppGlyphs.warning,
    CheckSeverity.tip => AppGlyphs.info,
  };

  Color color(ColorScheme colorScheme) => switch (this) {
    CheckSeverity.critical => colorScheme.error,
    CheckSeverity.warning => colorScheme.warning,
    CheckSeverity.tip => colorScheme.onSurfaceVariant,
  };
}

/// The first of [remedyIds] this platform can apply.
String? availableRemedy(Map<String, FixKind> kinds, List<String> remedyIds) =>
    remedyIds
        .where((id) => kinds[id] != null && kinds[id] != FixKind.none)
        .firstOrNull;

/// A foreign fix ends in an ellipsis, since a confirmation comes first.
String fixVerb(AppLocalizations l, FixKind kind, {bool foreign = false}) =>
    switch (kind) {
      FixKind.auto => foreign ? l.doctorFixConfirm : l.doctorFix,
      _ => l.doctorOpen,
    };

bool isForeignRemedy(WidgetRef ref, String remedyId) => ref
    .read(diagnosticRemediesProvider)
    .any((r) => r.id == remedyId && r.reach == RemedyReach.foreign);

/// Applies [remedyId] and says how it went; an undoable fix offers Undo.
Future<RemedyOutcome> applyRemedy(
  BuildContext context,
  WidgetRef ref,
  String remedyId,
) async {
  final kernel = ref.read(diagnosticKernelProvider);
  var outcome = isForeignRemedy(ref, remedyId)
      ? RemedyOutcome(
          remedyId: remedyId,
          status: RemedyStatus.needsConfirmation,
        )
      : await kernel.apply(remedyId);
  if (outcome.status == RemedyStatus.needsConfirmation) {
    if (!context.mounted || !await _confirmForeign(context)) return outcome;
    outcome = await kernel.apply(remedyId, confirmed: true);
  }
  if (!context.mounted) return outcome;
  final l = context.appLocalizations;
  switch (outcome.status) {
    case RemedyStatus.fixed || RemedyStatus.applied:
      context.showNotifier(
        l.doctorFixed,
        level: MessageLevel.success,
        actionState: outcome.canUndo
            ? MessageActionState(
                actionText: l.undo,
                action: () => unawaited(kernel.undo(remedyId)),
              )
            : null,
      );
    case RemedyStatus.notFixed || RemedyStatus.failed:
      context.showNotifier(l.doctorDidntHelp, level: MessageLevel.warning);
    default:
  }
  return outcome;
}

Future<bool> _confirmForeign(BuildContext context) async {
  final l = context.appLocalizations;
  final confirmed = await dialogs.showMessage(
    context: context,
    title: l.doctorConfirmForeignTitle,
    message: TextSpan(text: l.doctorConfirmForeignDetail),
    confirmText: l.doctorConfirmForeignAction,
  );
  return confirmed ?? false;
}

/// The button of one finding, verb by its remedy's kind; it stays pressed
/// while the remedy runs and remembers a fix that did not help.
class FindingFixButton extends ConsumerStatefulWidget {
  const FindingFixButton({
    super.key,
    required this.remedyId,
    required this.kind,
    this.onError = false,
  });

  final String remedyId;
  final FixKind kind;

  /// Sits on the error container, so it fills with the error role.
  final bool onError;

  @override
  ConsumerState<FindingFixButton> createState() => _FindingFixButtonState();
}

class _FindingFixButtonState extends ConsumerState<FindingFixButton> {
  bool _busy = false;
  bool _failed = false;

  Future<void> _apply() async {
    setState(() => _busy = true);
    try {
      final outcome = await applyRemedy(context, ref, widget.remedyId);
      _failed =
          outcome.status == RemedyStatus.notFixed ||
          outcome.status == RemedyStatus.failed;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final label = Text(
      _failed
          ? l.doctorDidntHelp
          : fixVerb(
              l,
              widget.kind,
              foreign: isForeignRemedy(ref, widget.remedyId),
            ),
      maxLines: 1,
    );
    final onPressed = _busy ? null : () => unawaited(_apply());
    return CommonMinFilledButtonTheme(
      child: widget.onError
          ? FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: context.colorScheme.error,
                foregroundColor: context.colorScheme.onError,
              ),
              onPressed: onPressed,
              child: label,
            )
          : FilledButton.tonal(onPressed: onPressed, child: label),
    );
  }
}
