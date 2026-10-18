import 'package:reclash/common/common.dart';
import 'package:reclash/features/form/custom_issue.dart';
import 'package:reclash/features/form/form_row.dart';
import 'package:reclash/subscriptions/imports/import.dart';

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
  bool _acceptSections = false;
  bool _acceptPartial = false;
  bool _acceptOtherLosses = false;
  bool _remember = false;

  int get _skippedCount => widget.summary.skippedNodes.isNotEmpty
      ? widget.summary.skippedNodes.length
      : widget.summary.skipped.length;

  bool get _needsSectionConsent => widget.summary.ignoredSections.isNotEmpty;
  bool get _needsPartialConsent => _skippedCount > 0;
  bool get _needsOtherConsent =>
      widget.summary.hasOtherLosses ||
      widget.summary.hasLosses &&
          !_needsSectionConsent &&
          !_needsPartialConsent;

  bool get _canAccept =>
      widget.summary.nodes > 0 &&
      (!_needsSectionConsent || _acceptSections) &&
      (!_needsPartialConsent || _acceptPartial) &&
      (!_needsOtherConsent || _acceptOtherLosses);

  void _accept() {
    if (!_canAccept) return;
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
    final sections = summary.ignoredSections.join(', ');
    return CommonScaffold(
      title: l10n.subscriptionImportReviewTitle,
      confirmationAction: IconButtonData(
        glyph: AppGlyphs.check,
        tooltip: l10n.subscriptionImportAccept,
        onPressed: _canAccept ? _accept : null,
      ),
      body: Builder(
        builder: (context) => ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(
            top: context.contentTopPadding,
            bottom: BottomInsetScope.of(context) + 16,
          ),
          children: [
            if (summary.nodes == 0)
              ErrorBanner(message: l10n.subscriptionImportNoNodes),
            generateSection(
              items: [
                ListItem(
                  title: Text(
                    l10n.subscriptionImportReviewSummary(
                      summary.nodes,
                      widget.format.label,
                    ),
                  ),
                  leading: const GlyphIcon(AppGlyphs.proxies),
                ),
                if (_needsSectionConsent)
                  ListItem(
                    title: Text(
                      l10n.subscriptionImportIgnoredSections(sections),
                    ),
                    leading: const GlyphIcon(AppGlyphs.warning),
                  ),
                if (_needsPartialConsent)
                  ListItem(
                    title: Text(
                      l10n.subscriptionImportSkippedNodes(_skippedCount),
                    ),
                    leading: const GlyphIcon(AppGlyphs.warning),
                  ),
              ],
            ),
            if (_needsSectionConsent)
              generateSection(
                items: [
                  FormRow(
                    title: l10n.subscriptionImportAcceptSections,
                    onPressed: () => setState(() {
                      _acceptSections = !_acceptSections;
                    }),
                    trailing: Checkbox(
                      value: _acceptSections,
                      onChanged: (value) => setState(() {
                        _acceptSections = value ?? false;
                      }),
                    ),
                  ),
                ],
              ),
            if (_needsPartialConsent)
              generateSection(
                items: [
                  FormRow(
                    title: l10n.subscriptionImportAcceptPartial,
                    onPressed: () => setState(() {
                      _acceptPartial = !_acceptPartial;
                    }),
                    trailing: Checkbox(
                      value: _acceptPartial,
                      onChanged: (value) => setState(() {
                        _acceptPartial = value ?? false;
                      }),
                    ),
                  ),
                ],
              ),
            if (_needsOtherConsent)
              generateSection(
                items: [
                  FormRow(
                    title: l10n.subscriptionImportAcceptOtherLosses,
                    onPressed: () => setState(() {
                      _acceptOtherLosses = !_acceptOtherLosses;
                    }),
                    trailing: Checkbox(
                      value: _acceptOtherLosses,
                      onChanged: (value) => setState(() {
                        _acceptOtherLosses = value ?? false;
                      }),
                    ),
                  ),
                ],
              ),
            if (widget.sourceScope.isNotEmpty && summary.hasLosses)
              generateSection(
                items: [
                  FormRow(
                    title: l10n.subscriptionImportRememberConsent,
                    onPressed: () => setState(() => _remember = !_remember),
                    trailing: Switch(
                      value: _remember,
                      onChanged: (value) => setState(() => _remember = value),
                    ),
                  ),
                ],
                footer: l10n.subscriptionImportRememberConsentHint,
              ),
          ].separated(const SizedBox(height: 16)).toList(),
        ),
      ),
    );
  }
}
