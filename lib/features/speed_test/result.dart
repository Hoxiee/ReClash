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

(String, String) speedTestRateParts(BuildContext context, double? value) {
  final l = context.appLocalizations;
  return value != null && value >= 1000
      ? (speedTestNumber(value / 1000), l.speedTestGbpsUnit)
      : (speedTestNumber(value), l.simpleSpeedUnit);
}

String speedTestRate(BuildContext context, double? value) {
  if (value == null) return '—';
  final (number, unit) = speedTestRateParts(context, value);
  return '$number $unit';
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
    return CommonCard(
      radius: AppCorner.xl,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        spacing: 4,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!test.latencyOnly) ...[
            Expanded(
              child: _Metric(
                glyph: AppGlyphs.arrowDown,
                label: l.speedTestDownload,
                value: speedTestRateParts(context, download),
                active: test.running && test.stage == SpeedTestStage.download,
              ),
            ),
            Expanded(
              child: _Metric(
                glyph: AppGlyphs.arrowUp,
                label: l.speedTestUpload,
                value: speedTestRateParts(context, upload),
                active: test.running && test.stage == SpeedTestStage.upload,
              ),
            ),
          ],
          Expanded(
            child: _Metric(
              glyph: AppGlyphs.clock,
              label: l.speedTestPing,
              value: (
                speedTestNumber(test.latency?.medianMs),
                l.speedTestMsUnit,
              ),
              active: test.running && test.stage == SpeedTestStage.latency,
            ),
          ),
          if (test.latencyOnly)
            Expanded(
              child: _Metric(
                glyph: AppGlyphs.connections,
                label: l.speedTestJitter,
                value: (
                  speedTestNumber(test.latency?.jitterMs),
                  l.speedTestMsUnit,
                ),
              ),
            ),
        ],
      ),
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
  final (String, String) value;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final muted = context.colorScheme.onSurfaceVariant;
    final (number, unit) = value;
    return MergeSemantics(
      child: Column(
        spacing: 2,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: [
                GlyphIcon(
                  glyph,
                  size: 14,
                  color: active ? context.colorScheme.primary : muted,
                ),
                Text(
                  label,
                  style: AppTextStyle.caption1
                      .of(context)
                      .copyWith(color: muted),
                ),
              ],
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              number,
              style: AppTextStyle.title2.of(context, emphasized: true),
            ),
          ),
          Text(
            unit,
            style: AppTextStyle.caption2.of(context).copyWith(color: muted),
          ),
        ],
      ),
    );
  }
}

/// Jitter and what a full run measured under load, which the metrics leave out.
class SpeedTestLatencyDetails extends StatelessWidget {
  const SpeedTestLatencyDetails({super.key, required this.test});

  final SpeedTestState test;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    String ms(double? value) =>
        value == null ? '—' : l.speedTestMs(speedTestNumber(value));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        _Detail(label: l.speedTestJitter, value: ms(test.latency?.jitterMs)),
        _Detail(
          label: l.speedTestDownloadLatency,
          value: ms(test.downloadLatency?.medianMs),
        ),
        _Detail(
          label: l.speedTestUploadLatency,
          value: ms(test.uploadLatency?.medianMs),
        ),
        Tooltip(
          message: l.speedTestRpmHint,
          triggerMode: TooltipTriggerMode.tap,
          child: _Detail(
            label: l.speedTestResponsiveness,
            value: '${test.rpm ?? '—'} ${l.speedTestRpmUnit}',
          ),
        ),
      ],
    );
  }
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
        child: Text(
          label,
          style: AppTextStyle.footnote
              .of(context)
              .copyWith(color: context.colorScheme.onSurfaceVariant),
        ),
      ),
      Expanded(
        child: Text(
          value,
          textAlign: TextAlign.end,
          style: AppTextStyle.footnote.of(context),
        ),
      ),
    ],
  );
}
