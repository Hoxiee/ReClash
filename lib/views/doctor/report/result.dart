import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/doctor/report/report.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';

import 'delivery.dart';
import 'stage.dart';

String _byteSize(num bytes) {
  final size = bytes.traffic;
  return '${size.value} ${size.unit}';
}

/// "Send to support" when the subscription names a way, otherwise the one
/// thing this platform does with a file.
enum ReportSend { upload, shareToChat, downloadsToChat, share, save }

ReportSend reportSendOf(ReportSupport support, {required bool canShare}) =>
    switch (support) {
      ReportSupport(upload: _?) => ReportSend.upload,
      ReportSupport(chat: _?) =>
        canShare ? ReportSend.shareToChat : ReportSend.downloadsToChat,
      _ => canShare ? ReportSend.share : ReportSend.save,
    };

String reportSendLabel(
  AppLocalizations l,
  ReportSend send, {
  String? provider,
}) => switch (send) {
  ReportSend.upload when provider != null => l.reportSendToProvider(provider),
  ReportSend.upload => l.reportSend,
  ReportSend.shareToChat => l.reportSendChat,
  ReportSend.downloadsToChat => l.reportOpenChat,
  ReportSend.share => l.reportShare,
  ReportSend.save => l.save,
};

String _nextStep(AppLocalizations l, ReportSend send) => switch (send) {
  ReportSend.upload => l.reportNextUpload,
  ReportSend.shareToChat => l.reportNextShareChat,
  ReportSend.downloadsToChat => l.reportNextDownloadsChat,
  ReportSend.share || ReportSend.save => l.reportNextFile,
};

String _shortSummary(String summary) => summary
    .split('\n')
    .where((line) => line.isNotEmpty && !line.startsWith('#'))
    .map((line) => line.startsWith('- ') ? line.substring(2) : line)
    .join('\n');

/// The finished report: its id and the one way it goes on to the provider,
/// then what it holds.
class ReportResultView extends ConsumerStatefulWidget {
  const ReportResultView({super.key, required this.result});

  final ReportResult result;

  @override
  ConsumerState<ReportResultView> createState() => _ReportResultViewState();
}

class _ReportResultViewState extends ConsumerState<ReportResultView> {
  bool _sending = false;
  ReportReceipt? _receipt;
  bool _dropHint = false;
  bool _filesExpanded = false;

  ReportResult get _result => widget.result;

  void _notify(String text, {MessageLevel level = MessageLevel.success}) {
    if (mounted) context.showNotifier(text, level: level);
  }

  Future<void> _copy(String text) async {
    final copied = context.appLocalizations.copySuccess;
    await Clipboard.setData(ClipboardData(text: text));
    _notify(copied);
  }

  Future<void> _share() async {
    final l = context.appLocalizations;
    final shared = await ref
        .read(reportDeliveryProvider)
        .share(_result)
        .catchError((Object _) => false);
    if (!shared) _notify(l.reportShareFailed, level: MessageLevel.error);
  }

  Future<void> _save() async {
    final l = context.appLocalizations;
    try {
      if (await ref.read(reportDeliveryProvider).save(_result)) {
        _notify(l.reportSaved);
      }
    } on Object {
      _notify(l.cannotSave, level: MessageLevel.error);
    }
  }

  Future<void> _copySummary() async {
    final copied = context.appLocalizations.copySuccess;
    await ref.read(reportDeliveryProvider).copySummary(_result);
    _notify(copied);
  }

  Future<void> _upload(Uri target) async {
    final l = context.appLocalizations;
    final confirmed = await dialogs.showMessage(
      title: l.reportSendTitle,
      message: TextSpan(text: l.reportSendTo(target.host)),
      confirmText: l.reportSendConfirm,
    );
    if (confirmed != true) return;
    final uploader = ref.read(reportUploaderProvider);
    while (mounted) {
      setState(() => _sending = true);
      String problem;
      try {
        final receipt = await uploader.upload(target, _result);
        if (mounted) setState(() => _receipt = receipt);
        return;
      } on ReportUploadFailure catch (failure) {
        problem = switch (failure.error) {
          ReportUploadError.offline => l.reportSendOffline,
          ReportUploadError.rejected => l.reportSendRejected(failure.status!),
        };
      } on Object {
        problem = l.reportSendOffline;
      } finally {
        if (mounted) setState(() => _sending = false);
      }
      final retry = await dialogs.showMessage(
        title: l.reportSendFailed,
        message: TextSpan(text: problem),
        confirmText: l.retry,
      );
      if (retry != true) return;
    }
  }

  Future<void> _downloadsToChat(Uri chat) async {
    final cannotSave = context.appLocalizations.cannotSave;
    final delivery = ref.read(reportDeliveryProvider);
    try {
      if (!await delivery.saveToDownloads(_result) &&
          !await delivery.save(_result)) {
        return;
      }
    } on Object {
      _notify(cannotSave, level: MessageLevel.error);
      return;
    }
    await delivery.copySummary(_result);
    if (!mounted) return;
    setState(() => _dropHint = true);
    await dialogs.openUrl(chat.toString());
  }

  Future<void> _send(ReportSend send, ReportSupport support) async {
    switch (send) {
      case ReportSend.upload:
        await _upload(support.upload!);
      case ReportSend.shareToChat || ReportSend.share:
        await _share();
      case ReportSend.downloadsToChat:
        await _downloadsToChat(support.chat!);
      case ReportSend.save:
        await _save();
    }
  }

  void _close() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      context.safeNestedPop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final support = ref.watch(reportSupportProvider);
    final canShare = ref.watch(reportDeliveryProvider).canShare;
    final send = reportSendOf(support, canShare: canShare);
    final sent = _receipt;
    final provider = support.provider;
    return CommonScaffold(
      title: l.reportProblem,
      iconActions: [
        if (canShare)
          IconButtonData(
            glyph: AppGlyphs.export,
            tooltip: l.reportShare,
            onPressed: () => unawaited(_share()),
          ),
        IconButtonData(
          glyph: AppGlyphs.arrowDown,
          tooltip: l.save,
          onPressed: () => unawaited(_save()),
        ),
      ],
      body: ReportStageLayout(
        hero: ReportHero(
          badge: ReportBadge(
            color: colorScheme.success,
            value: 1,
            child: GlyphIcon(sent == null ? AppGlyphs.check : AppGlyphs.send),
          ),
          title: switch ((sent, provider)) {
            (null, _) => l.reportReady,
            (_?, final provider?) => l.reportSentTo(provider),
            (_?, null) => l.reportSent,
          },
          subtitle: Column(
            children: [
              const SizedBox(height: 10),
              _IdPill(id: _result.id, onCopy: () => _copy(_result.id)),
              const SizedBox(height: 10),
              Text(switch (sent?.ticket) {
                final ticket? => l.reportTicket(ticket),
                null => l.reportIdHint,
              }, key: const ValueKey('report-id-hint')),
            ],
          ),
        ),
        body: [
          if (sent?.message case final message?)
            _Notice(
              key: const ValueKey('report-sent'),
              glyph: AppGlyphs.support,
              color: colorScheme.primary,
              text: message,
            ),
          if (_dropHint && sent == null)
            _Notice(
              key: const ValueKey('report-drop-hint'),
              glyph: AppGlyphs.info,
              color: colorScheme.primary,
              text: l.reportDropHint,
            ),
          if (sent == null)
            generateSection(
              title: l.reportSupportText,
              actions: [
                IconButtonData(
                  glyph: AppGlyphs.copy,
                  tooltip: l.reportCopySummary,
                  onPressed: () => unawaited(_copySummary()),
                ),
              ],
              items: [
                DecorationListItem(
                  title: Text(
                    _shortSummary(_result.summary),
                    key: const ValueKey('report-summary'),
                    style: AppTextStyle.subheadline.of(context),
                  ),
                ),
              ],
            ),
          generateAnimatedSection(
            items: [
              Semantics(
                button: true,
                expanded: _filesExpanded,
                child: DecorationListItem(
                  key: const ValueKey('report-files'),
                  title: Text(l.reportFiles),
                  onPressed: () =>
                      setState(() => _filesExpanded = !_filesExpanded),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 4,
                    children: [
                      Text(
                        '${_result.sizes.length} · '
                        '${_byteSize(_result.sizes.values.sum)}',
                        style: AppTextStyle.body
                            .of(context)
                            .copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                      GlyphIcon(
                        _filesExpanded
                            ? AppGlyphs.chevronUp
                            : AppGlyphs.chevronDown,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
              if (_filesExpanded)
                for (final MapEntry(key: name, value: size)
                    in _result.sizes.entries)
                  DecorationListItem(
                    key: ValueKey(('report-file', name)),
                    title: Text(name),
                    trailing: Text(
                      _byteSize(size),
                      style: AppTextStyle.footnote
                          .of(context)
                          .copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
            ],
          ),
        ],
        primary: sent != null
            ? FilledButton(
                key: const ValueKey('report-done'),
                onPressed: _close,
                child: Text(l.done),
              )
            : FilledButton.icon(
                key: const ValueKey('report-send'),
                onPressed: _sending
                    ? null
                    : () => unawaited(_send(send, support)),
                icon: _sending
                    ? const CommonCircleLoading(size: 18)
                    : GlyphIcon(switch (send) {
                        ReportSend.upload ||
                        ReportSend.shareToChat ||
                        ReportSend.downloadsToChat => AppGlyphs.send,
                        ReportSend.share => AppGlyphs.export,
                        ReportSend.save => AppGlyphs.arrowDown,
                      }, fill: 1),
                label: Text(reportSendLabel(l, send, provider: provider)),
              ),
        secondary: sent != null
            ? null
            : Text(
                _nextStep(l, send),
                key: const ValueKey('report-next'),
                textAlign: TextAlign.center,
                style: AppTextStyle.footnote
                    .of(context)
                    .copyWith(color: colorScheme.onSurfaceVariant),
              ),
      ),
    );
  }
}

/// The report id, large enough to read out over the phone; a tap copies it.
class _IdPill extends StatelessWidget {
  const _IdPill({required this.id, required this.onCopy});

  final String id;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final colorScheme = context.colorScheme;
    return Tooltip(
      message: l.copy,
      child: CommonCard(
        shape: AppShape.full,
        padding: const EdgeInsets.fromLTRB(20, 10, 16, 10),
        onPressed: onCopy,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: [
            Flexible(
              child: Text(
                id,
                key: const ValueKey('report-id'),
                style: AppTextStyle.headline
                    .of(context)
                    .copyWith(
                      color: colorScheme.onSurface,
                      letterSpacing: 0.5,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
              ),
            ),
            GlyphIcon(
              AppGlyphs.copy,
              fill: 1,
              size: 20,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({
    super.key,
    required this.glyph,
    required this.color,
    required this.text,
  });

  final Glyph glyph;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: generateGroup([
        DecorationListItem(
          leading: GlyphIcon(glyph, color: color),
          title: Text(text),
        ),
      ]),
    );
  }
}
