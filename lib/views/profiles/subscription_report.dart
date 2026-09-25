import 'dart:async';
import 'package:reclash/icons/icons.dart';
import 'dart:convert';

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> showSubscriptionReportSheet(BuildContext context) {
  return showSheet(
    context: context,
    props: const SheetProps(isScrollControlled: true),
    builder: (_) => const SubscriptionReportSheet(),
  );
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
  const SubscriptionReportSheet({super.key});

  @override
  ConsumerState<SubscriptionReportSheet> createState() =>
      _SubscriptionReportSheetState();
}

class _SubscriptionReportSheetState
    extends ConsumerState<SubscriptionReportSheet> {
  SubscriptionReport? _report;
  Object? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    try {
      final report = await ref
          .read(profilesActionProvider.notifier)
          .buildSubscriptionReport();
      if (mounted) setState(() => _report = report);
    } catch (error) {
      if (mounted) setState(() => _error = error);
    }
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

  @override
  Widget build(BuildContext context) {
    return AdaptiveSheetScaffold(
      title: context.appLocalizations.subscriptionReport,
      body: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          context.sheetTopPadding,
          16,
          16 + BottomInsetScope.of(context),
        ),
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    if (_error != null) {
      return Center(
        child: Text(userFacingErrorMessage(_error!, appLocalizations)),
      );
    }
    final report = _report;
    if (report == null) {
      return _Loading(label: appLocalizations.subscriptionReportGenerating);
    }
    return _ReportBody(report: report, saving: _saving, onSave: _save);
  }
}

class _Loading extends StatelessWidget {
  const _Loading({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text(label, style: context.textTheme.bodyMedium),
      ],
    );
  }
}

class _ReportBody extends StatelessWidget {
  const _ReportBody({
    required this.report,
    required this.saving,
    required this.onSave,
  });

  final SubscriptionReport report;
  final bool saving;
  final ValueChanged<SubscriptionReport> onSave;

  Future<void> _copy(BuildContext context, String text) async {
    final message = context.appLocalizations.subscriptionReportCopied;
    await Clipboard.setData(ClipboardData(text: text));
    dialogs.showNotifier(message);
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final fault = report.verdict?.fault ?? SubscriptionFault.unknown;
    final lang = Localizations.localeOf(context).languageCode;
    return ListView(
      children: [
        _VerdictCard(
          headline: _headlineOf(appLocalizations, fault),
          body: _bodyOf(appLocalizations, fault),
          tone: _toneOf(fault),
        ),
        const SizedBox(height: 16),
        _FactsCard(report: report),
        const SizedBox(height: 24),
        FilledButton.icon(
          autofocus: true,
          onPressed: () => _copy(
            context,
            subscriptionReportDecoderUrl(
              encodeSubscriptionReportBlob(report),
              lang: lang,
            ),
          ),
          icon: const GlyphIcon(AppGlyphs.link),
          label: Text(appLocalizations.subscriptionReportCopyLink),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: () =>
                  _copy(context, encodeSubscriptionReportBlob(report)),
              icon: const GlyphIcon(AppGlyphs.copy),
              label: Text(appLocalizations.subscriptionReportCopyCode),
            ),
            OutlinedButton.icon(
              onPressed: saving ? null : () => onSave(report),
              icon: const GlyphIcon(AppGlyphs.save),
              label: Text(appLocalizations.subscriptionReportSave),
            ),
          ],
        ),
      ],
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
    final accent = switch (tone) {
      _FaultTone.bad => colors.error,
      _FaultTone.caution => colors.tertiary,
      _FaultTone.neutral => colors.onSurfaceVariant,
    };
    final icon = switch (tone) {
      _FaultTone.bad => AppGlyphs.error,
      _FaultTone.caution => AppGlyphs.warning,
      _FaultTone.neutral => AppGlyphs.help,
    };
    return CommonCard(
      type: CommonCardType.filled,
      radius: AppCorner.xl,
      isError: tone == _FaultTone.bad,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlyphIcon(icon, color: accent),
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

class _FactsCard extends StatelessWidget {
  const _FactsCard({required this.report});

  final SubscriptionReport report;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final dial = report.runtimeDial;
    final update = report.subscriptionUpdate;
    return CommonCard(
      type: CommonCardType.filled,
      radius: AppCorner.xl,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            _FactRow(
              label: appLocalizations.subscriptionReportRuntimeDials,
              value: '${dial.success}/${dial.attempts}',
            ),
            _FactRow(
              label: appLocalizations.subscriptionReportFlaggedNodes,
              value: '${report.nodes.length}',
            ),
            if (update != null && update.attempted)
              _FactRow(
                label: appLocalizations.subscriptionReportUpdateFailures,
                value: '${update.failures}/${update.attempts}',
              ),
          ],
        ),
      ),
    );
  }
}

class _FactRow extends StatelessWidget {
  const _FactRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: context.textTheme.bodyMedium),
          Text(
            value,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
