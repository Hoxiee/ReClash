import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/widgets/widgets.dart';

import 'chart.dart';
import 'result.dart';
import 'types.dart';

/// Everything one run measured: the running test while it lasts, or a finished
/// one, whose saved record keeps no samples to chart.
class SpeedTestResultPage extends StatelessWidget {
  const SpeedTestResultPage({super.key, required this.test});

  final SpeedTestState test;

  @override
  Widget build(BuildContext context) {
    final hasSamples =
        test.downloadSamples.isNotEmpty || test.uploadSamples.isNotEmpty;
    return CommonScaffold(
      title: context.appLocalizations.speedTestResult,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          16,
          context.contentTopPadding + 12,
          16,
          context.bottomInset + 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            if (test.checkedAt != null)
              LastUpdateTimeText(lastUpdateDate: test.checkedAt),
            SpeedTestMetrics(test: test),
            if (speedTestMessage(context, test) case final message?)
              Text(message, style: AppTextStyle.footnote.of(context)),
            if (!test.latencyOnly) ...[
              if (test.running || hasSamples) SpeedTestCharts(test: test),
              CommonCard(
                radius: AppCorner.xl,
                padding: const EdgeInsets.all(16),
                child: SpeedTestLatencyDetails(test: test),
              ),
            ],
            CommonCard(
              radius: AppCorner.xl,
              padding: const EdgeInsets.all(16),
              child: SpeedTestResultDetails(test: test),
            ),
          ],
        ),
      ),
    );
  }
}
