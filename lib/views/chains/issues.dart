import 'package:material_ui/material_ui.dart';
import 'package:reclash/features/proxy_chains/proxy_chains.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/views/dashboard/simple/flag.dart';
import 'package:reclash/views/dashboard/style.dart';
import 'package:reclash/views/dashboard/widgets/card.dart';

enum IssueTone { warning, error }

typedef IssueCopy = ({String title, String body});

String _hopAt(List<String> hops, int index) =>
    index >= 0 && index < hops.length ? serverTitle(hops[index]) : '';

String _role(AppLocalizations l, List<String> hops, int index) {
  if (index <= 0) return l.chainsRoleEntry;
  if (index >= hops.length - 1) return l.chainsRoleExit;
  return l.chainsRoleMiddle;
}

/// [group] is the group the chain is offered in, for the copy that names it.
IssueCopy chainIssueCopy(
  AppLocalizations l,
  ChainIssue issue,
  List<String> hops, {
  required String group,
  String? name,
}) {
  final hop = _hopAt(hops, issue.hop);
  final entry = _hopAt(hops, 0);
  return switch (issue.code) {
    ChainIssueCode.missingHop => (
      title: l.chainsIssueMissingTitle(hop),
      body: l.chainsIssueMissingBody(_role(l, hops, issue.hop)),
    ),
    ChainIssueCode.unchainableHop => (
      title: l.chainsIssueUnchainableTitle(hop),
      body: l.chainsIssueUnchainableBody,
    ),
    ChainIssueCode.loop => (
      title: l.chainsIssueLoopTitle,
      body: l.chainsIssueLoopBody(hop, group),
    ),
    ChainIssueCode.emptyExit => (
      title: l.chainsIssueEmptyTitle(
        hop.isEmpty ? _hopAt(hops, hops.length - 1) : hop,
      ),
      body: l.chainsIssueEmptyBody,
    ),
    ChainIssueCode.providerPending => (
      title: l.chainsIssueProviderTitle,
      body: l.chainsIssueProviderBody,
    ),
    ChainIssueCode.udpTransportMissing => (
      title: l.chainsIssueUdpMissingTitle(
        hop.isEmpty ? _hopAt(hops, hops.length - 1) : hop,
      ),
      body: l.chainsIssueUdpMissingBody(entry),
    ),
    ChainIssueCode.udpLost => (
      title: l.chainsIssueUdpLostTitle,
      body: l.chainsIssueUdpLostBody(entry),
    ),
    ChainIssueCode.dialerReplaced => (
      title: l.chainsIssueDialerTitle(hop),
      body: l.chainsIssueDialerBody(_hopAt(hops, issue.hop - 1)),
    ),
    ChainIssueCode.mainGroupAutomatic => (
      title: l.chainsIssueAutomaticTitle(group),
      body: l.chainsIssueAutomaticBody,
    ),
    ChainIssueCode.nameClash => (
      title: l.chainsIssueNameTitle(name ?? autoChainName(hops)),
      body: l.chainsIssueNameBody,
    ),
    ChainIssueCode.missingTarget => (
      title: l.chainsIssueTargetTitle,
      body: l.chainsIssueTargetBody,
    ),
    ChainIssueCode.unknown => (
      title: l.chainsIssueUnknownTitle,
      body: l.chainsIssueUnknownBody,
    ),
  };
}

/// The one line a chain's worst issue gets in a list row or a tile.
String chainShortReason(
  AppLocalizations l,
  ChainIssue issue,
  List<String> hops, {
  required String group,
}) => switch (issue.code) {
  ChainIssueCode.missingHop => l.chainsShortMissing(_hopAt(hops, issue.hop)),
  ChainIssueCode.udpLost ||
  ChainIssueCode.udpTransportMissing => l.chainsShortUdp,
  ChainIssueCode.emptyExit => l.chainsShortEmpty,
  ChainIssueCode.dialerReplaced => l.chainsShortDialer,
  _ => chainIssueCopy(l, issue, hops, group: group).title,
};

/// Why the picker can't offer a candidate for the slot being filled.
String chainBlockedReason(
  AppLocalizations l,
  ChainIssueCode code, {
  required String entry,
}) => l.chainsBlocked(switch (code) {
  ChainIssueCode.loop => l.chainsBlockedLoop,
  ChainIssueCode.udpTransportMissing => l.chainsBlockedUdp(entry),
  ChainIssueCode.emptyExit => l.chainsBlockedEmpty,
  ChainIssueCode.providerPending => l.chainsBlockedProvider,
  _ => l.chainsBlockedOther,
});

/// The issue that speaks for a chain: the first error, else the first
/// warning.
ChainIssue? leadingIssue(Iterable<ChainIssue> issues) =>
    issues.where((issue) => issue.code.isError).firstOrNull ??
    issues.firstOrNull;

/// What a chain needs, in one title and one sentence, with at most one fix.
class IssueCard extends StatelessWidget {
  const IssueCard({
    super.key,
    required this.tone,
    required this.title,
    required this.body,
    this.action,
    this.onAction,
  });

  final IssueTone tone;
  final String title;
  final String body;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final colors = DashboardColors.of(context);
    final (fill, ink, glyph) = switch (tone) {
      IssueTone.error => (
        colorScheme.errorContainer,
        colorScheme.onErrorContainer,
        AppGlyphs.error,
      ),
      IssueTone.warning => (
        colors.warnContainer,
        colors.onWarnContainer,
        AppGlyphs.warning,
      ),
    };
    return DecoratedBox(
      decoration: ShapeDecoration(color: fill, shape: AppShape.xl),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            GlyphIcon(glyph, size: 22, color: ink),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Text(
                    title,
                    style: AppTextStyle.subheadline
                        .of(context, emphasized: true)
                        .copyWith(color: ink),
                  ),
                  Text(
                    body,
                    style: AppTextStyle.footnote
                        .of(context)
                        .copyWith(color: ink.withValues(alpha: 0.85)),
                  ),
                  if ((action, onAction) case (final action?, final onAction?))
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: DashboardBlock(
                        radius: AppCorner.full,
                        color: ink.withValues(alpha: 0.12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        onTap: onAction,
                        child: Text(
                          action,
                          style: AppTextStyle.footnote
                              .of(context, emphasized: true)
                              .copyWith(color: ink),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
