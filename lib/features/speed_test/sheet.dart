import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/common/network_cost.dart';
import 'package:reclash/models/speed_test.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/speed_test.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/views/dashboard/style.dart';
import 'package:reclash/widgets/widgets.dart';

import 'dial.dart';
import 'settings_sheet.dart';

Future<void> showSpeedTestSheet(BuildContext context) {
  if (isSheetPage(context)) {
    return Navigator.of(
      context,
    ).push(PagedSheetRoute(builder: (_) => const SpeedTestSheet()));
  }
  return showSheet<void>(
    context: context,
    props: const SheetProps(
      backgroundColor: Colors.transparent,
      detents: [0.9, 1],
    ),
    builder: (_) => NestedPagedSheet(builder: (_) => const SpeedTestSheet()),
  );
}

class SpeedTestSheet extends ConsumerStatefulWidget {
  const SpeedTestSheet({super.key});

  @override
  ConsumerState<SpeedTestSheet> createState() => _SpeedTestSheetState();
}

class _SpeedTestSheetState extends ConsumerState<SpeedTestSheet> {
  late final SpeedTest _notifier;
  bool _checking = false;
  String? _preflightError;

  @override
  void initState() {
    super.initState();
    _notifier = ref.read(speedTestProvider.notifier);
  }

  @override
  void dispose() {
    scheduleMicrotask(_notifier.cancel);
    super.dispose();
  }

  Future<void> _start() async {
    if (_checking || ref.read(speedTestProvider).running) return;
    setState(() {
      _checking = true;
      _preflightError = null;
    });
    try {
      var settings = ref.read(appSettingProvider).speedTest;
      final network = await ref.read(speedTestNetworkProvider).read();
      if (!mounted) return;
      if (network.cost == NetworkCost.offline) {
        setState(
          () => _preflightError = context.appLocalizations.speedTestOffline,
        );
        return;
      }
      if (settings.alwaysConfirm || network.cost != NetworkCost.unmetered) {
        final decision = await showFloatingDialog<SpeedTestMode>(
          context: context,
          child: _TrafficConfirmation(
            network: network.cost,
            settings: settings,
          ),
        );
        if (!mounted || decision == null) return;
        settings = settings.copyWith(mode: decision);
      }
      unawaited(_notifier.start(settings: settings, expectedNetwork: network));
    } on Object {
      if (mounted) {
        setState(
          () => _preflightError = context.appLocalizations.simpleSpeedFailed,
        );
      }
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final test = ref.watch(speedTestProvider);
    final settings = ref.watch(
      appSettingProvider.select((value) => value.speedTest),
    );
    final backends = ref.watch(speedTestBackendsProvider);
    final available = backends.any((value) => value.id == settings.backendId);
    final idle = test.phase == SpeedTestPhase.idle;
    final backend = backends
        .where(
          (value) => value.id == (idle ? settings.backendId : test.backendId),
        )
        .firstOrNull;
    final viaCore = idle ? ref.watch(speedTestViaVpnProvider) : test.viaVpn;
    final latencyOnly = idle
        ? settings.mode == SpeedTestMode.latencyOnly
        : test.byteLimit == 0;
    final transferring =
        test.running &&
        (test.stage == SpeedTestStage.download ||
            test.stage == SpeedTestStage.upload);
    final shownStage = transferring
        ? test.stage
        : test.downloadMbps == null && test.uploadMbps != null
        ? SpeedTestStage.upload
        : SpeedTestStage.download;
    final rate = transferring
        ? test.liveMbps ?? 0
        : test.running || latencyOnly
        ? null
        : test.downloadMbps ?? test.uploadMbps;
    final figure = latencyOnly ? test.latency?.medianMs : rate;
    final caption = switch (test.phase) {
      SpeedTestPhase.running when transferring => test.stage.label,
      SpeedTestPhase.running => SpeedTestStage.latency.label,
      _ when latencyOnly && test.latency != null => l.speedTestPing,
      _ when rate != null => shownStage.label,
      _ => test.phase.label,
    };
    final failed =
        _preflightError != null || test.phase == SpeedTestPhase.failed;
    final message =
        _preflightError ??
        switch (test.failure) {
          _ when !available => l.speedTestPlatformUnavailable,
          'routeChanged' => l.speedTestNetworkChanged,
          'backendUnavailable' => l.speedTestPlatformUnavailable,
          _ when test.phase == SpeedTestPhase.failed => l.simpleSpeedFailed,
          _ when test.errors.isNotEmpty => l.speedTestPartial,
          _ when test.limited => l.speedTestLimited,
          _ => null,
        };
    final muted = colorScheme.onSurfaceVariant;
    final details = [
      viaCore ? l.speedTestRouteCore : l.speedTestRouteSystem,
      ?backend?.name,
      if (test.byteLimit > 0)
        l.speedTestDataUsed(
          dashboardTraffic(test.transferredBytes),
          dashboardTraffic(test.byteLimit),
        )
      else if (settings.mode == SpeedTestMode.complete)
        '${l.speedTestBudget}: ${dashboardTraffic(settings.byteLimit)}',
    ];
    return CommonScaffold(
      title: l.speedTestTitle,
      iconActions: [
        IconButtonData(
          glyph: AppGlyphs.settings,
          tooltip: l.speedTestSettings,
          onPressed: test.running || _checking
              ? null
              : () => showSpeedTestSettingsSheet(context),
        ),
      ],
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          context.contentTopPadding + 12,
          16,
          context.bottomInset + 24,
        ),
        children: [
          _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 18,
                  child: test.checkedAt == null || test.running
                      ? null
                      : LastUpdateTimeText(
                          lastUpdateDate: test.checkedAt,
                          style: AppTextStyle.caption1
                              .of(context)
                              .copyWith(color: muted),
                        ),
                ),
                Semantics(
                  liveRegion: !test.running,
                  child: SpeedTestDial(
                    mbps: latencyOnly ? null : rate,
                    footer: _LatencyLine(
                      summary: test.latency,
                      jitterOnly: latencyOnly,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          figure == null ? '—' : _number(figure),
                          style: AppTextStyle.display
                              .of(context, emphasized: true)
                              .copyWith(
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                        ),
                        Text(
                          latencyOnly ? l.speedTestMsUnit : l.simpleSpeedUnit,
                          style: AppTextStyle.subheadline
                              .of(context)
                              .copyWith(color: muted),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyle.footnote.of(
                            context,
                            emphasized: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(child: _runButton(context, test, available)),
                if (message != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: AppTextStyle.footnote
                        .of(context)
                        .copyWith(color: failed ? colorScheme.error : muted),
                  ),
                ],
                if (!latencyOnly) ...[
                  const SizedBox(height: 16),
                  Row(
                    spacing: 8,
                    children: [
                      _ResultTile(
                        label: l.speedTestDownload,
                        glyph: AppGlyphs.arrowDown,
                        value: test.downloadMbps,
                        live:
                            test.running &&
                                test.stage == SpeedTestStage.download
                            ? test.liveMbps
                            : null,
                      ),
                      _ResultTile(
                        label: l.speedTestUpload,
                        glyph: AppGlyphs.arrowUp,
                        value: test.uploadMbps,
                        live:
                            test.running && test.stage == SpeedTestStage.upload
                            ? test.liveMbps
                            : null,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              [
                details.join(' · '),
                if (viaCore) l.speedTestRouteHint,
              ].join('\n'),
              style: AppTextStyle.caption1.of(context).copyWith(color: muted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _runButton(BuildContext context, SpeedTestState test, bool available) {
    final l = context.appLocalizations;
    if (test.running) {
      return FilledButton.tonalIcon(
        onPressed: _notifier.cancel,
        icon: const GlyphIcon(AppGlyphs.close, fill: 1, size: 20),
        label: Text(l.speedTestStop),
      );
    }
    return FilledButton.icon(
      onPressed: _checking || !available ? null : _start,
      icon: _checking
          ? const CommonCircleLoading(size: 18)
          : GlyphIcon(
              test.phase == SpeedTestPhase.idle
                  ? AppGlyphs.playPause(0)
                  : AppGlyphs.refresh,
              fill: 1,
              size: 20,
            ),
      label: Text(
        test.phase == SpeedTestPhase.idle ? l.speedTestStart : l.speedTestAgain,
      ),
    );
  }
}

class _TrafficConfirmation extends StatelessWidget {
  const _TrafficConfirmation({required this.network, required this.settings});

  final NetworkCost network;
  final SpeedTestSettings settings;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    return CommonDialog(
      title: switch (network) {
        NetworkCost.metered => l.speedTestMeteredTitle,
        NetworkCost.unknown => l.speedTestUnknownTitle,
        _ => l.speedTestConfirmTitle,
      },
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.cancel),
        ),
        if (settings.mode == SpeedTestMode.complete)
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(SpeedTestMode.latencyOnly),
            child: Text(l.speedTestLatencyOnly),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(settings.mode),
          child: Text(l.speedTestStart),
        ),
      ],
      child: Text(
        settings.mode == SpeedTestMode.latencyOnly
            ? l.speedTestLatencyWarning
            : l.speedTestTrafficWarning(dashboardTraffic(settings.byteLimit)),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final level = context.raisedSurfaceLevel;
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: level.colorOf(context.colorScheme),
        shape: AppShape.xl,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: SurfaceScope(level: level, child: child),
      ),
    );
  }
}

class _LatencyLine extends StatelessWidget {
  const _LatencyLine({required this.summary, required this.jitterOnly});

  final LatencySummary? summary;
  final bool jitterOnly;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final muted = context.colorScheme.onSurfaceVariant;
    String ms(double? value) =>
        value == null ? '—' : l.speedTestMs(_number(value));
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!jitterOnly)
          Text(
            '${l.speedTestPing} ${ms(summary?.medianMs)}',
            style: AppTextStyle.footnote.of(context, emphasized: true),
          ),
        Text(
          '${l.speedTestJitter} ${ms(summary?.jitterMs)}',
          style: AppTextStyle.caption1.of(context).copyWith(color: muted),
        ),
      ],
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({
    required this.label,
    required this.glyph,
    required this.value,
    required this.live,
  });

  final String label;
  final Glyph glyph;
  final double? value;
  final double? live;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final rate = live ?? value;
    return Expanded(
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: context.raisedSurfaceLevel.colorOf(colorScheme),
          shape: AppShape.lg,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text.rich(
                  TextSpan(
                    text: rate == null ? '—' : _number(rate),
                    children: [
                      TextSpan(
                        text: ' ${context.appLocalizations.simpleSpeedUnit}',
                        style: AppTextStyle.caption1
                            .of(context)
                            .copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                  style: AppTextStyle.title2
                      .of(context, emphasized: true)
                      .copyWith(
                        color: live == null ? null : colorScheme.primary,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                ),
              ),
              Row(
                spacing: 4,
                children: [
                  GlyphIcon(
                    glyph,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.caption1
                          .of(context)
                          .copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _number(double value) =>
    value.abs() < 100 ? value.toStringAsFixed(1) : value.round().toString();
