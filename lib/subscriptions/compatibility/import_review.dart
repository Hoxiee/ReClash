import 'package:reclash/common/common.dart';
import 'package:reclash/subscriptions/imports/import.dart';
import 'package:reclash/subscriptions/imports/routing/skipped_node.dart';
import 'package:reclash/ui/code_label.dart';

import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';

import 'client_labels.dart';
import 'import_policy.dart';

class SubscriptionImportReviewRoute {
  const SubscriptionImportReviewRoute({
    required this.navigator,
    required this.isMobile,
    required this.backgroundColor,
    required this.barrierColor,
    required this.barrierLabel,
  });

  final NavigatorState navigator;
  final bool isMobile;
  final Color? backgroundColor;
  final Color barrierColor;
  final String barrierLabel;

  factory SubscriptionImportReviewRoute.fromContext(BuildContext context) =>
      SubscriptionImportReviewRoute(
        navigator: sheetNavigatorOf(context),
        isMobile: context.isMobileView,
        backgroundColor: null,
        barrierColor: context.colorScheme.modalScrim,
        barrierLabel: MaterialLocalizations.of(
          context,
        ).modalBarrierDismissLabel,
      );
}

Future<bool?> reviewSubscriptionImport(
  BuildContext context, {
  required SubscriptionFormat format,
  required SubscriptionImportSummary summary,
}) => reviewSubscriptionImportAt(
  SubscriptionImportReviewRoute.fromContext(context),
  format: format,
  summary: summary,
);

Future<bool?> reviewSubscriptionImportAt(
  SubscriptionImportReviewRoute route, {
  required SubscriptionFormat format,
  required SubscriptionImportSummary summary,
}) async =>
    await approveSubscriptionImportAt(
      route,
      format: format,
      summary: summary,
    ) !=
    null;

Future<SubscriptionImportApproval?> approveSubscriptionImportAt(
  SubscriptionImportReviewRoute route, {
  required SubscriptionFormat format,
  required SubscriptionImportSummary summary,
  String sourceScope = '',
}) {
  if (!summary.hasLosses &&
      (summary.nodes > 0 ||
          summary.groups > 0 ||
          summary.remoteProviders > 0)) {
    return Future.value(const SubscriptionImportApproval());
  }
  if (!route.navigator.mounted) return Future.value(null);
  final page = SubscriptionImportReviewPage(
    format: format,
    summary: summary,
    sourceScope: sourceScope,
  );
  if (route.isMobile) {
    return route.navigator.push(
      SnapSheetRoute<SubscriptionImportApproval>(
        builder: (context, _) => page,
        detents: snapSheetDetents,
        fitsContent: true,
        sheetBarrierColor: route.barrierColor,
        barrierLabel: route.barrierLabel,
      ),
    );
  }
  return route.navigator.push(
    FormSheetRoute<SubscriptionImportApproval>(
      builder: (_) => page,
      backgroundColor: route.backgroundColor,
      barrierColor: route.barrierColor,
      barrierLabel: route.barrierLabel,
    ),
  );
}

class SubscriptionImportReviewPage extends StatefulWidget {
  const SubscriptionImportReviewPage({
    super.key,
    required this.format,
    required this.summary,
    this.sourceScope = '',
  });

  final SubscriptionFormat format;
  final SubscriptionImportSummary summary;
  final String sourceScope;

  @override
  State<SubscriptionImportReviewPage> createState() =>
      _SubscriptionImportReviewPageState();
}

class _SubscriptionImportReviewPageState
    extends State<SubscriptionImportReviewPage> {
  static const _collapsedSkipped = 5;

  bool _remember = false;
  bool _showAllSkipped = false;

  void _accept() {
    if (widget.summary.nodes == 0) return;
    Navigator.of(context).pop(
      SubscriptionImportApproval(
        rememberedPolicy: _remember && widget.sourceScope.isNotEmpty
            ? SubscriptionImportPolicy.accepted(
                scope: widget.sourceScope,
                format: widget.format,
                summary: widget.summary,
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.appLocalizations;
    final summary = widget.summary;
    final skipped = summary.skippedNodes;
    final shown = _showAllSkipped
        ? skipped
        : skipped.take(_collapsedSkipped).toList();
    final hidden = skipped.length - shown.length;
    final canAccept = summary.nodes > 0;
    return CommonScaffold(
      title: l10n.subscriptionImportReviewTitle,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ).copyWith(top: context.contentTopPadding, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ReviewHero(
                    kept: summary.nodes,
                    lost: skipped.length,
                    format: widget.format.label,
                  ),
                  if (skipped.isNotEmpty)
                    AnimatedSize(
                      duration: context.motionDuration(commonDuration),
                      curve: Curves.easeOutCubic,
                      alignment: Alignment.topCenter,
                      child: generateSection(
                        title: l10n.subscriptionImportSkippedTitle,
                        items: [
                          for (final node in shown) _SkippedRow(node: node),
                          if (hidden > 0)
                            DecorationListItem(
                              onPressed: () =>
                                  setState(() => _showAllSkipped = true),
                              title: Text(
                                l10n.subscriptionImportShowAll(skipped.length),
                                style: TextStyle(
                                  color: context.colorScheme.primary,
                                ),
                              ),
                              trailing: GlyphIcon(
                                AppGlyphs.chevronDown,
                                color: context.colorScheme.primary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  if (summary.ignoredSections.isNotEmpty ||
                      summary.hasOtherLosses)
                    generateSection(
                      title: l10n.subscriptionImportLeftOutTitle,
                      footer: summary.ignoredSections.isEmpty
                          ? null
                          : l10n.subscriptionImportLeftOutHint,
                      items: [
                        if (summary.ignoredSections.isNotEmpty)
                          DecorationListItem(
                            leading: const GlyphIcon(AppGlyphs.layers),
                            title: Text(l10n.subscriptionImportIgnoredSections),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  for (final section in summary.ignoredSections)
                                    CodeLabel(section),
                                ],
                              ),
                            ),
                          ),
                        if (summary.hasOtherLosses)
                          DecorationListItem(
                            leading: const GlyphIcon(AppGlyphs.sliders),
                            title: Text(l10n.subscriptionImportOtherLosses),
                          ),
                      ],
                    ),
                  if (canAccept && widget.sourceScope.isNotEmpty)
                    generateSection(
                      footer: l10n.subscriptionImportRememberConsentHint,
                      items: [
                        DecorationListItem(
                          onPressed: () =>
                              setState(() => _remember = !_remember),
                          title: Text(l10n.subscriptionImportRememberConsent),
                          trailing: Switch(
                            value: _remember,
                            onChanged: (value) =>
                                setState(() => _remember = value),
                          ),
                        ),
                      ],
                    ),
                ].separated(const SizedBox(height: 12)).toList(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: AlertActions(
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(canAccept ? l10n.cancel : l10n.close),
                ),
                if (canAccept)
                  TextButton(
                    onPressed: _accept,
                    child: Text(l10n.subscriptionImportAdd(summary.nodes)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewHero extends StatelessWidget {
  const _ReviewHero({
    required this.kept,
    required this.lost,
    required this.format,
  });

  static const _well = 64.0;

  final int kept;
  final int lost;
  final String format;

  @override
  Widget build(BuildContext context) {
    final l10n = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final empty = kept == 0;
    final accent = empty ? colorScheme.error : colorScheme.warning;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        children: [
          Container(
            width: _well,
            height: _well,
            alignment: Alignment.center,
            decoration: ShapeDecoration(
              color: empty
                  ? colorScheme.errorContainer
                  : colorScheme.warningContainer,
              shape: AppShape.circle,
            ),
            child: GlyphIcon(
              empty ? AppGlyphs.block : AppGlyphs.warning,
              size: 30,
              color: accent,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            empty
                ? l10n.subscriptionImportNoNodes
                : lost == 0
                ? l10n.subscriptionImportAllAdded(kept)
                : l10n.subscriptionImportPartial(kept, kept + lost),
            textAlign: TextAlign.center,
            style: AppTextStyle.title3.of(context, emphasized: true),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.subscriptionImportSourceFormat(format),
            textAlign: TextAlign.center,
            style: AppTextStyle.subheadline
                .of(context)
                .copyWith(color: colorScheme.onSurfaceVariant),
          ),
          if (kept + lost > 0) ...[
            const SizedBox(height: 16),
            _ShareBar(share: kept / (kept + lost)),
          ],
        ],
      ),
    );
  }
}

class _ShareBar extends StatelessWidget {
  const _ShareBar({required this.share});

  static const _height = 8.0;

  final double share;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return SizedBox(
      width: double.infinity,
      height: _height,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: colorScheme.primary.opacity15,
          shape: AppShape.full,
        ),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: share),
          duration: context.motionDuration(const Duration(milliseconds: 700)),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) => FractionallySizedBox(
            alignment: AlignmentDirectional.centerStart,
            widthFactor: value,
            child: DecoratedBox(
              decoration: ShapeDecoration(
                color: colorScheme.primary,
                shape: AppShape.full,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SkippedRow extends StatelessWidget {
  const _SkippedRow({required this.node});

  final SkippedNode node;

  @override
  Widget build(BuildContext context) {
    final l10n = context.appLocalizations;
    final reason = switch (node.reason) {
      SkippedNodeReason.protocol => l10n.subscriptionImportReasonProtocol,
      SkippedNodeReason.transport => l10n.subscriptionImportReasonTransport,
      SkippedNodeReason.bandwidth => l10n.subscriptionImportReasonBandwidth,
    };
    return DecorationListItem(
      title: Text(node.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(reason, style: context.listSubtitleStyle),
      trailing: node.kind.isEmpty ? null : CodeLabel(node.kind.toUpperCase()),
    );
  }
}
