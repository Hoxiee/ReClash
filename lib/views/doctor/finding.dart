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
      _ => finding.titleKey,
    };

String findingDetail(AppLocalizations l, Finding finding) {
  final args = finding.args;
  return switch (finding.detailKey) {
    'doctorClockSkewBehind' => l.doctorClockSkewBehind(
      args['seconds'] as int? ?? 0,
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

String fixVerb(AppLocalizations l, FixKind kind) =>
    kind == FixKind.auto ? l.doctorFix : l.doctorOpen;

/// Applies [remedyId] and says how it went; an undoable fix offers Undo.
Future<RemedyOutcome> applyRemedy(
  BuildContext context,
  WidgetRef ref,
  String remedyId,
) async {
  final kernel = ref.read(diagnosticKernelProvider);
  final outcome = await kernel.apply(remedyId);
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
      _failed ? l.doctorDidntHelp : fixVerb(l, widget.kind),
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
