import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/widgets/widgets.dart';

/// Pushes the report over the subscription sheet when already inside a nested
/// sheet, otherwise raises a nested sheet rooted at the report.
Future<void> openSubscriptionReportSheet(
  BuildContext context, {
  String? reportUrl,
}) async {
  final page = PagedSheetRoute(
    builder: (_) => SubscriptionReportView(reportUrl: reportUrl),
  );
  if (SheetProvider.of(context)?.nestedNavigatorPop != null) {
    await pushPagedSheet(context, page);
    return;
  }
  await showSheet<void>(
    context: context,
    props: nestedPagedSheetProps,
    builder: (_) => NestedPagedSheet(
      builder: (_) => SubscriptionReportView(reportUrl: reportUrl),
    ),
  );
}

/// Builds the report after the sheet opens, so the page can push over the
/// subscription sheet with a back button while the core export still runs.
class SubscriptionReportView extends ConsumerStatefulWidget {
  const SubscriptionReportView({super.key, this.reportUrl});

  final String? reportUrl;

  @override
  ConsumerState<SubscriptionReportView> createState() =>
      _SubscriptionReportViewState();
}

class _SubscriptionReportViewState
    extends ConsumerState<SubscriptionReportView> {
  SubscriptionReport? _report;
  Object? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _error = null;
    });
    try {
      final report = await ref
          .read(profilesActionProvider.notifier)
          .buildSubscriptionReport();
      if (!mounted) return;
      setState(() {
        _report = report;
      });
    } catch (error, stackTrace) {
      commonPrint.log(
        'subscription report ===> ${compactError(error)}, $stackTrace',
        logLevel: LogLevel.warning,
      );
      if (!mounted) return;
      setState(() {
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget content;
    final report = _report;
    if (report != null) {
      content = SubscriptionReportSheet(
        report: report,
        reportUrl: widget.reportUrl,
      );
    } else {
      final error = _error;
      content = AdaptiveSheetScaffold(
        title: context.appLocalizations.subscriptionReport,
        body: error == null
            ? const _ReportLoading()
            : _ReportError(error: error, onRetry: _load),
      );
    }
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: ref.sheetHeight(context, 0.7)),
      child: content,
    );
  }
}

class _ReportLoading extends StatelessWidget {
  const _ReportLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 64),
      child: Center(child: CommonCircleLoading()),
    );
  }
}

class _ReportError extends StatelessWidget {
  const _ReportError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return NullStatus(
      label: userFacingErrorMessage(error, appLocalizations),
      illustration: NullStatusIllustration.error,
      action: FilledButton.icon(
        onPressed: onRetry,
        icon: const GlyphIcon(AppGlyphs.refresh),
        label: Text(appLocalizations.reload),
      ),
    );
  }
}

enum _FaultTone { caution, bad, neutral }

_FaultTone _toneOf(SubscriptionFault fault) => switch (fault) {
  SubscriptionFault.subscription || SubscriptionFault.server => _FaultTone.bad,
  SubscriptionFault.yourNetwork ||
  SubscriptionFault.client => _FaultTone.caution,
  _ => _FaultTone.neutral,
};

String _headlineOf(AppLocalizations l10n, SubscriptionFault fault) =>
    switch (fault) {
      SubscriptionFault.yourNetwork => l10n.subscriptionFaultYourNetwork,
      SubscriptionFault.client => l10n.subscriptionFaultClient,
      SubscriptionFault.subscription => l10n.subscriptionFaultSubscription,
      SubscriptionFault.server => l10n.subscriptionFaultServer,
      SubscriptionFault.inconclusive => l10n.subscriptionFaultInconclusive,
      SubscriptionFault.unknown => l10n.subscriptionFaultUnknown,
    };

String _bodyOf(AppLocalizations l10n, SubscriptionFault fault) =>
    switch (fault) {
      SubscriptionFault.yourNetwork => l10n.subscriptionFaultYourNetworkDesc,
      SubscriptionFault.client => l10n.subscriptionFaultClientDesc,
      SubscriptionFault.subscription => l10n.subscriptionFaultSubscriptionDesc,
      SubscriptionFault.server => l10n.subscriptionFaultServerDesc,
      SubscriptionFault.inconclusive => l10n.subscriptionFaultInconclusiveDesc,
      SubscriptionFault.unknown => l10n.subscriptionFaultUnknownDesc,
    };

class SubscriptionReportSheet extends ConsumerStatefulWidget {
  const SubscriptionReportSheet({
    super.key,
    required this.report,
    this.reportUrl,
  });

  final SubscriptionReport report;
  final String? reportUrl;

  @override
  ConsumerState<SubscriptionReportSheet> createState() =>
      _SubscriptionReportSheetState();
}

class _SubscriptionReportSheetState
    extends ConsumerState<SubscriptionReportSheet> {
  bool _saving = false;

  Future<void> _copy(String text) async {
    final message = context.appLocalizations.subscriptionReportCopied;
    await Clipboard.setData(ClipboardData(text: text));
    dialogs.showNotifier(message);
  }

  void _copyLink(SubscriptionReport report) {
    final lang = Localizations.localeOf(context).languageCode;
    unawaited(
      _copy(
        subscriptionReportDecoderUrl(
          encodeSubscriptionReportBlob(report),
          lang: lang,
        ),
      ),
    );
  }

  Future<void> _save(SubscriptionReport report) async {
    setState(() => _saving = true);
    final appLocalizations = context.appLocalizations;
    final saved = await globalState.safeRun<bool>(
      () async {
        final text = const JsonEncoder.withIndent(
          '  ',
        ).convert(report.toJson());
        final stamp = DateTime.now().toUtc().toIso8601String().replaceAll(
          ':',
          '-',
        );
        final uri = await picker.saveFile(
          'reclash-subscription-report-$stamp.json',
          Uint8List.fromList(utf8.encode(text)),
        );
        return uri != null;
      },
      title: appLocalizations.subscriptionReport,
      silence: false,
    );
    if (mounted) setState(() => _saving = false);
    if (saved == true) {
      dialogs.showNotifier(
        appLocalizations.exportSuccess,
        level: MessageLevel.success,
      );
    }
  }

  List<CommonPopupMenuItem> _exportMenu(SubscriptionReport report) {
    final appLocalizations = context.appLocalizations;
    final reportUrl = widget.reportUrl;
    return [
      if (reportUrl != null)
        CommonPopupMenuItem(
          glyph: AppGlyphs.send,
          label: appLocalizations.subscriptionReportSend,
          onPressed: () => dialogs.openUrl(reportUrl),
        ),
      CommonPopupMenuItem(
        glyph: AppGlyphs.copy,
        label: appLocalizations.subscriptionReportCopyCode,
        onPressed: () => unawaited(_copy(encodeSubscriptionReportBlob(report))),
      ),
      CommonPopupMenuItem(
        glyph: AppGlyphs.save,
        label: appLocalizations.subscriptionReportSave,
        onPressed: _saving ? null : () => unawaited(_save(report)),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final report = widget.report;
    return AdaptiveSheetScaffold(
      title: context.appLocalizations.subscriptionReport,
      body: Padding(
        // The scaffold already reserves the toolbar height above the body.
        padding: EdgeInsets.fromLTRB(
          16,
          0,
          16,
          16 + BottomInsetScope.of(context),
        ),
        child: _ReportBody(
          report: report,
          onCopyLink: () => _copyLink(report),
          exportItems: _exportMenu(report),
        ),
      ),
    );
  }
}

class _ReportBody extends StatelessWidget {
  const _ReportBody({
    required this.report,
    required this.onCopyLink,
    required this.exportItems,
  });

  final SubscriptionReport report;
  final VoidCallback onCopyLink;
  final List<CommonPopupMenuItem> exportItems;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final fault = report.verdict?.fault ?? SubscriptionFault.unknown;
    // A shrink-wrapping scroll view lets the sheet hug its short content.
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _VerdictCard(
            headline: _headlineOf(appLocalizations, fault),
            body: _bodyOf(appLocalizations, fault),
            tone: _toneOf(fault),
          ),
          const SizedBox(height: AppSpacing.xl),
          _OverviewSection(report: report),
          const SizedBox(height: AppSpacing.xxl),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  autofocus: true,
                  onPressed: onCopyLink,
                  icon: const GlyphIcon(AppGlyphs.link),
                  label: Text(appLocalizations.subscriptionReportCopyLink),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              CommonPopupBox(
                targetBuilder: (open) => IconButton.filledTonal(
                  tooltip: appLocalizations.more,
                  onPressed: () =>
                      open(offset: Offset(0, context.isMobileView ? 0 : 20)),
                  icon: const GlyphIcon(AppGlyphs.more),
                ).withAppTooltip(),
                popupBuilder: (_) => CommonPopupMenu(items: exportItems),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VerdictCard extends StatelessWidget {
  const _VerdictCard({
    required this.headline,
    required this.body,
    required this.tone,
  });

  final String headline;
  final String body;
  final _FaultTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final (accent, glyph) = switch (tone) {
      _FaultTone.bad => (colors.error, AppGlyphs.error),
      _FaultTone.caution => (colors.tertiary, AppGlyphs.warning),
      _FaultTone.neutral => (colors.onSurfaceVariant, AppGlyphs.help),
    };
    return CommonCard(
      type: CommonCardType.filled,
      radius: AppCorner.xl,
      isError: tone == _FaultTone.bad,
      child: Padding(
        padding: AppInsets.lg,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: ShapeDecoration(
                color: accent.opacity12,
                shape: AppShape.full,
              ),
              child: GlyphIcon(glyph, color: accent),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    headline,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    body,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
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

class _OverviewSection extends StatelessWidget {
  const _OverviewSection({required this.report});

  final SubscriptionReport report;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final dial = report.runtimeDial;
    final update = report.subscriptionUpdate;
    return generateSectionV3(
      title: appLocalizations.basicInfo,
      items: [
        _StatRow(
          label: appLocalizations.subscriptionReportRuntimeDials,
          value: '${dial.success}/${dial.attempts}',
        ),
        _StatRow(
          label: appLocalizations.subscriptionReportFlaggedNodes,
          value: '${report.nodes.length}',
        ),
        if (update != null && update.attempted)
          _StatRow(
            label: appLocalizations.subscriptionReportUpdateFailures,
            value: '${update.failures}/${update.attempts}',
          ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecorationListItem(
      title: Text(label),
      trailing: Text(
        value,
        style: context.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
