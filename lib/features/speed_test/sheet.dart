import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/models/speed_test.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/speed_test.dart';
import 'package:reclash/views/dashboard/style.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/widgets/widgets.dart';

import 'chart.dart';
import 'dial.dart';
import 'history_sheet.dart';
import 'proxy_picker.dart';
import 'result.dart';
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

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final test = ref.watch(speedTestProvider);
    final settings = ref.watch(
      appSettingProvider.select((value) => value.speedTest),
    );
    final choice = ref.watch(speedTestProxyProvider);
    final viaCore = ref.watch(speedTestViaVpnProvider);
    final idle = test.phase == SpeedTestPhase.idle;
    final display = idle
        ? test.copyWith(
            backendId: settings.backendId,
            byteLimit: settings.mode == SpeedTestMode.complete
                ? settings.byteLimit
                : 0,
            protocol: settings.protocol.value,
            viaVpn: viaCore,
            proxyName: choice,
          )
        : test;
    final transferring =
        test.running &&
        (test.stage == SpeedTestStage.download ||
            test.stage == SpeedTestStage.upload);
    final rate = transferring
        ? test.liveMbps
        : test.downloadMbps ?? test.uploadMbps;
    final figure = display.latencyOnly ? test.latency?.medianMs : rate;
    final gigabit = !display.latencyOnly && (figure ?? 0) >= 1000;
    final caption = test.running ? test.stage.label : test.phase.label;
    final message = speedTestMessage(context, test);
    final route = choice.isEmpty
        ? viaCore
              ? l.speedTestCurrentRoute
              : l.speedTestRouteSystem
        : choice == 'DIRECT'
        ? l.speedTestDirect
        : choice;
    final hero = CommonCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            liveRegion: !test.running,
            child: SpeedTestDial(
              mbps: display.latencyOnly ? null : rate,
              footer: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    display.protocolLabel,
                    style: AppTextStyle.caption1.of(context, emphasized: true),
                  ),
                  Text(
                    settings.multiThread
                        ? l.speedTestMultipleConnections
                        : l.speedTestSingleConnection,
                    style: AppTextStyle.caption2.of(context),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      speedTestNumber(gigabit ? figure! / 1000 : figure),
                      style: AppTextStyle.display.of(context, emphasized: true),
                    ),
                  ),
                  Text(
                    display.latencyOnly
                        ? l.speedTestMsUnit
                        : gigabit
                        ? l.speedTestGbpsUnit
                        : l.simpleSpeedUnit,
                    style: AppTextStyle.subheadline
                        .of(context)
                        .copyWith(color: context.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    caption,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: AppTextStyle.footnote.of(context, emphasized: true),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _PhaseSteps(test: display),
          const SizedBox(height: 16),
          Center(
            child: test.running
                ? FilledButton.tonalIcon(
                    onPressed: _notifier.cancel,
                    icon: const GlyphIcon(AppGlyphs.close, fill: 1, size: 20),
                    label: Text(l.speedTestStop),
                  )
                : FilledButton.icon(
                    onPressed: () => unawaited(_notifier.start()),
                    icon: GlyphIcon(
                      idle ? AppGlyphs.playPause(0) : AppGlyphs.refresh,
                      fill: 1,
                      size: 20,
                    ),
                    label: Text(idle ? l.speedTestStart : l.speedTestAgain),
                  ),
          ),
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyle.footnote
                  .of(context)
                  .copyWith(
                    color: test.phase == SpeedTestPhase.failed
                        ? context.colorScheme.error
                        : context.colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
          const SizedBox(height: 20),
          SpeedTestMetrics(test: display),
        ],
      ),
    );
    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        CommonCard(
          child: ListItem(
            leading: const GlyphIcon(AppGlyphs.proxies),
            title: Text(l.speedTestProxy),
            subtitle: Text(route),
            trailing: const GlyphIcon(AppGlyphs.chevronForward, size: 18),
            onTap: test.running
                ? null
                : () => showInSheet<void>(
                    context,
                    builder: (_) => const SpeedTestProxyPicker(),
                  ),
          ),
        ),
        if (!idle)
          CommonCard(
            padding: const EdgeInsets.all(16),
            child: SpeedTestResultDetails(test: test),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '${l.speedTestDuration}: ${l.speedTestDurationValue(settings.durationSeconds)} · ${l.speedTestBudget}: ${dashboardTraffic(settings.byteLimit)}',
              style: AppTextStyle.caption1
                  .of(context)
                  .copyWith(color: context.colorScheme.onSurfaceVariant),
            ),
          ),
        if (!display.latencyOnly) SpeedTestCharts(test: test),
        Text(
          l.speedTestPrivacy,
          style: AppTextStyle.caption1
              .of(context)
              .copyWith(color: context.colorScheme.onSurfaceVariant),
        ),
      ],
    );
    return CommonScaffold(
      title: l.speedTestTitle,
      iconActions: [
        IconButtonData(
          glyph: AppGlyphs.clock,
          tooltip: l.speedTestHistory,
          onPressed: () => showInSheet<void>(
            context,
            builder: (_) => const SpeedTestHistorySheet(),
          ),
        ),
        IconButtonData(
          glyph: AppGlyphs.settings,
          tooltip: l.speedTestSettings,
          onPressed: test.running
              ? null
              : () => showSpeedTestSettingsSheet(context),
        ),
      ],
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 840;
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              16,
              context.contentTopPadding + 12,
              16,
              context.bottomInset + 24,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1160),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 16,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final platform
                            in SpeedTestSettings.platforms.entries)
                          CommonCard(
                            isSelected: settings.backendId == platform.key,
                            fillsSelection: true,
                            radius: AppCorner.full,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            onPressed: test.running
                                ? null
                                : () => updateSpeedTestSettings(
                                    ref,
                                    (value) =>
                                        value.copyWith(backendId: platform.key),
                                  ),
                            child: Text(
                              platform.value,
                              style: AppTextStyle.footnote.of(
                                context,
                                emphasized: true,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (wide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 16,
                        children: [
                          Expanded(child: hero),
                          Expanded(child: details),
                        ],
                      )
                    else ...[
                      hero,
                      details,
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PhaseSteps extends StatelessWidget {
  const _PhaseSteps({required this.test});

  final SpeedTestState test;

  @override
  Widget build(BuildContext context) {
    final stages = test.latencyOnly
        ? const [SpeedTestStage.warmup, SpeedTestStage.latency]
        : SpeedTestStage.values;
    return Column(
      spacing: 12,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final stage in stages)
              Expanded(
                child: Column(
                  spacing: 5,
                  children: [
                    GlyphIcon(
                      test.phase == SpeedTestPhase.done ||
                              stage.index < test.stage.index
                          ? AppGlyphs.checkCircle
                          : AppGlyphs.clock,
                      size: 18,
                      color:
                          test.phase == SpeedTestPhase.done ||
                              (test.running && stage == test.stage)
                          ? context.colorScheme.primary
                          : context.colorScheme.onSurfaceVariant,
                    ),
                    Text(
                      stage.label,
                      textAlign: TextAlign.center,
                      style: AppTextStyle.caption2.of(context),
                    ),
                  ],
                ),
              ),
          ],
        ),
        LinearProgressIndicator(value: test.progress.clamp(0, 1)),
      ],
    );
  }
}
