import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/widgets/widgets.dart';

import 'history.dart';
import 'result.dart';
import 'types.dart';

class SpeedTestHistorySheet extends ConsumerStatefulWidget {
  const SpeedTestHistorySheet({super.key});

  @override
  ConsumerState<SpeedTestHistorySheet> createState() =>
      _SpeedTestHistorySheetState();
}

class _SpeedTestHistorySheetState extends ConsumerState<SpeedTestHistorySheet> {
  bool _clearing = false;

  Future<void> _clear() async {
    final l = context.appLocalizations;
    final confirmed = await showFloatingDialog<bool>(
      context: context,
      child: CommonDialog(
        title: l.speedTestClearHistory,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l.delete),
          ),
        ],
        child: Text(l.speedTestClearHistoryConfirm),
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _clearing = true);
    try {
      await ref.read(speedTestHistoryProvider.notifier).clear();
    } on Object {
      if (mounted) context.showNotifier(l.speedTestHistorySaveFailed);
    } finally {
      if (mounted) setState(() => _clearing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final history = ref.watch(speedTestHistoryProvider);
    return CommonScaffold(
      title: l.speedTestHistory,
      iconActions: [
        IconButtonData(
          glyph: AppGlyphs.delete,
          tooltip: l.speedTestClearHistory,
          onPressed: _clearing || history.value?.isNotEmpty != true
              ? null
              : _clear,
        ),
      ],
      body: history.when(
        loading: () => const SizedBox.shrink(),
        error: (_, _) => Center(child: Text(l.speedTestHistorySaveFailed)),
        data: (records) => ListView.builder(
          padding: EdgeInsets.fromLTRB(
            16,
            context.contentTopPadding + 12,
            16,
            context.bottomInset + 24,
          ),
          itemCount: records.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  records.isEmpty
                      ? l.speedTestHistoryEmpty
                      : l.speedTestHistoryHint,
                  style: AppTextStyle.footnote.of(context),
                ),
              );
            }
            final record = records[index - 1];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: CommonCard(
                child: ListItem(
                  title: Text(record.platformName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      Text(
                        '${l.speedTestDownload} ${speedTestRate(context, record.downloadMbps)} · ${l.speedTestUpload} ${speedTestRate(context, record.uploadMbps)}',
                      ),
                      LastUpdateTimeText(lastUpdateDate: record.checkedAt),
                    ],
                  ),
                  trailing: const GlyphIcon(AppGlyphs.chevronForward, size: 18),
                  onTap: () => showInSheet<void>(
                    context,
                    builder: (_) => _HistoryResult(test: record),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HistoryResult extends StatelessWidget {
  const _HistoryResult({required this.test});

  final SpeedTestState test;

  @override
  Widget build(BuildContext context) => CommonScaffold(
    title: context.appLocalizations.speedTestResult,
    body: ListView(
      padding: EdgeInsets.fromLTRB(
        16,
        context.contentTopPadding + 12,
        16,
        context.bottomInset + 24,
      ),
      children: [
        if (test.checkedAt != null)
          LastUpdateTimeText(lastUpdateDate: test.checkedAt),
        const SizedBox(height: 12),
        CommonCard(
          padding: const EdgeInsets.all(16),
          child: SpeedTestMetrics(test: test),
        ),
        const SizedBox(height: 12),
        CommonCard(
          padding: const EdgeInsets.all(16),
          child: SpeedTestResultDetails(test: test),
        ),
        if (speedTestMessage(context, test) case final message?)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(message),
          ),
      ],
    ),
  );
}
