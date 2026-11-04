import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/views/dashboard/style.dart';
import 'package:reclash/widgets/widgets.dart';

import 'types.dart';

String speedTestNumber(double? value) {
  if (value == null || !value.isFinite || value < 0) return '—';
  return value < 100 ? value.toStringAsFixed(1) : value.round().toString();
}

String speedTestRate(BuildContext context, double? value) {
  if (value == null) return '—';
  final l = context.appLocalizations;
  return value >= 1000
      ? '${speedTestNumber(value / 1000)} ${l.speedTestGbpsUnit}'
      : '${speedTestNumber(value)} ${l.simpleSpeedUnit}';
}

String? speedTestMessage(BuildContext context, SpeedTestState test) {
  final l = context.appLocalizations;
  return switch (test.failure) {
    'routeChanged' => l.speedTestNetworkChanged,
    'offline' => l.speedTestOffline,
    'backendUnavailable' => l.speedTestPlatformUnavailable,
    'coreUnavailable' => l.speedTestCoreUnavailable,
    'proxyUnavailable' || 'proxy_not_found' => l.speedTestProxyUnavailable,
    'rejected' || 'blocked' => l.speedTestRejected,
    'timeout' => l.speedTestTimeout,
    _ when test.phase == SpeedTestPhase.failed => l.simpleSpeedFailed,
    _ when test.historySaveFailed => l.speedTestHistorySaveFailed,
    _ when test.errors.isNotEmpty => l.speedTestPartial,
    _ when test.limited => l.speedTestLimited,
    _ => null,
  };
}

class SpeedTestMetrics extends StatelessWidget {
  const SpeedTestMetrics({super.key, required this.test});

  final SpeedTestState test;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final download = test.running && test.stage == SpeedTestStage.download
        ? test.liveMbps
        : test.downloadMbps;
    final upload = test.running && test.stage == SpeedTestStage.upload
        ? test.liveMbps
        : test.uploadMbps;
    String ms(double? value) =>
        value == null ? '—' : l.speedTestMs(speedTestNumber(value));
    return Column(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!test.latencyOnly)
          Row(
            spacing: 10,
            children: [
              Expanded(
                child: _Metric(
                  glyph: AppGlyphs.arrowDown,
                  label: l.speedTestDownload,
                  value: speedTestRate(context, download),
                  active: test.running && test.stage == SpeedTestStage.download,
                ),
              ),
              Expanded(
                child: _Metric(
                  glyph: AppGlyphs.arrowUp,
                  label: l.speedTestUpload,
                  value: speedTestRate(context, upload),
                  active: test.running && test.stage == SpeedTestStage.upload,
                ),
              ),
            ],
          ),
        Row(
          spacing: 10,
          children: [
            Expanded(
              child: _Metric(
                glyph: AppGlyphs.clock,
                label: l.speedTestPing,
                value: ms(test.latency?.medianMs),
                active: test.running && test.stage == SpeedTestStage.latency,
              ),
            ),
            Expanded(
              child: _Metric(
                glyph: AppGlyphs.connections,
                label: l.speedTestJitter,
                value: ms(test.latency?.jitterMs),
              ),
            ),
          ],
        ),
        if (!test.latencyOnly) ...[
          const SizedBox(height: 2),
          Text(
            l.speedTestLoadedLatency,
            style: AppTextStyle.footnote.of(context, emphasized: true),
          ),
          Wrap(
            spacing: 16,
            runSpacing: 6,
            children: [
              Text(
                '${l.speedTestDownload}: ${ms(test.downloadLatency?.medianMs)}',
              ),
              Text('${l.speedTestUpload}: ${ms(test.uploadLatency?.medianMs)}'),
            ],
          ),
          Row(
            spacing: 8,
            children: [
              Expanded(
                child: Text(
                  l.speedTestResponsiveness,
                  style: AppTextStyle.footnote.of(context),
                ),
              ),
              Text(
                '${test.rpm ?? '—'} ${l.speedTestRpmUnit}',
                style: AppTextStyle.footnote.of(context, emphasized: true),
              ),
              Tooltip(
                message: l.speedTestRpmHint,
                triggerMode: TooltipTriggerMode.tap,
                child: GlyphIcon(
                  AppGlyphs.info,
                  size: 18,
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.glyph,
    required this.label,
    required this.value,
    this.active = false,
  });

  final Glyph glyph;
  final String label;
  final String value;
  final bool active;

  @override
  Widget build(BuildContext context) => CommonCard(
    radius: AppCorner.lg,
    padding: const EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        Row(
          spacing: 5,
          children: [
            GlyphIcon(
              glyph,
              size: 16,
              color: active
                  ? context.colorScheme.primary
                  : context.colorScheme.onSurfaceVariant,
            ),
            Expanded(
              child: Text(
                label,
                style: AppTextStyle.caption1.of(context),
                maxLines: 2,
              ),
            ),
          ],
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            value,
            style: AppTextStyle.title3.of(context, emphasized: true),
          ),
        ),
      ],
    ),
  );
}

class SpeedTestResultDetails extends StatelessWidget {
  const SpeedTestResultDetails({super.key, required this.test});

  final SpeedTestState test;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final server = test.server;
    final route = test.chains.isNotEmpty
        ? test.chains.join(' → ')
        : test.proxyName.isNotEmpty
        ? test.proxyName
        : test.viaVpn
        ? l.speedTestCurrentRoute
        : l.speedTestRouteSystem;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        _Detail(label: l.speedTestPlatform, value: test.platformName),
        _Detail(label: l.speedTestProxy, value: route),
        if (server != null) ...[
          _Detail(
            label: l.speedTestServer,
            value: server.title.isEmpty ? server.host : server.title,
          ),
          if (server.title.isNotEmpty && server.host.isNotEmpty)
            Text(
              server.host,
              style: AppTextStyle.caption1
                  .of(context)
                  .copyWith(color: context.colorScheme.onSurfaceVariant),
            ),
        ],
        _Detail(label: l.speedTestProtocol, value: test.protocolLabel),
        _Detail(
          label: l.speedTestElapsed,
          value: l.speedTestDurationValue(test.elapsed.inSeconds),
        ),
        _Detail(
          label: l.speedTestData,
          value: test.byteLimit > 0
              ? l.speedTestDataUsed(
                  dashboardTraffic(test.transferredBytes),
                  dashboardTraffic(test.byteLimit),
                )
              : dashboardTraffic(test.transferredBytes),
        ),
        if (test.protocolFallback)
          Text(
            l.speedTestProtocolFallback(test.protocolLabel),
            style: AppTextStyle.caption1.of(context),
          ),
      ],
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 16,
    children: [
      Expanded(
        flex: 2,
        child: Text(
          label,
          style: AppTextStyle.footnote
              .of(context)
              .copyWith(color: context.colorScheme.onSurfaceVariant),
        ),
      ),
      Expanded(
        flex: 3,
        child: Text(
          value,
          textAlign: TextAlign.end,
          style: AppTextStyle.footnote.of(context),
        ),
      ),
    ],
  );
}
