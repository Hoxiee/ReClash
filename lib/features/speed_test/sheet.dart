import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/models/speed_test.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/speed_test.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/widgets/widgets.dart';

import 'dial.dart';
import 'history_sheet.dart';
import 'proxy_picker.dart';
import 'result.dart';
import 'result_page.dart';
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

/// What stands below the dial: the progress bar, button, metrics and rows. A
/// short window takes the difference out of the dial, about 0.85 as tall as wide.
const double _belowDial = 300;
const double _dialAspect = 0.85;

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
    final (figure, unit) = display.latencyOnly
        ? (speedTestNumber(test.latency?.medianMs), l.speedTestMsUnit)
        : speedTestRateParts(context, rate);
    final caption = test.running ? test.stage.label : test.phase.label;
    final message = speedTestMessage(context, test);
    final route = choice.isEmpty
        ? viaCore
              ? l.speedTestCurrentRoute
              : l.speedTestRouteSystem
        : choice == 'DIRECT'
        ? l.speedTestDirect
        : choice;
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
          final top = context.contentTopPadding + 12;
          final bottom = context.bottomInset + 24;
          final content = math.max(0.0, constraints.maxHeight - top - bottom);
          final dialSize = ((content - _belowDial) / _dialAspect).clamp(
            212.0,
            340.0,
          );
          final controlWidth = math.max(dialSize - 52, 200.0);
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16, top, 16, bottom),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 520, minHeight: content),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 12,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: SizedBox(
                            width: dialSize,
                            child: Semantics(
                              liveRegion: !test.running,
                              child: SpeedTestDial(
                                mbps: display.latencyOnly ? null : rate,
                                footer: Text(
                                  display.platformName,
                                  style: AppTextStyle.caption1
                                      .of(context)
                                      .copyWith(
                                        color: context
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        figure,
                                        style: AppTextStyle.display.of(
                                          context,
                                          emphasized: true,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      unit,
                                      style: AppTextStyle.subheadline
                                          .of(context)
                                          .copyWith(
                                            color: context
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      caption,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      style: AppTextStyle.footnote.of(
                                        context,
                                        emphasized: true,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Center(
                          child: SizedBox(
                            width: controlWidth,
                            child: AnimatedOpacity(
                              opacity: test.running ? 1 : 0,
                              duration: context.motionDuration(
                                const Duration(milliseconds: 200),
                              ),
                              child: LinearProgressIndicator(
                                value: test.progress.clamp(0, 1),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: SizedBox(
                            width: controlWidth,
                            child: test.running
                                ? FilledButton.tonalIcon(
                                    onPressed: _notifier.cancel,
                                    icon: const GlyphIcon(
                                      AppGlyphs.close,
                                      fill: 1,
                                      size: 20,
                                    ),
                                    label: Text(l.speedTestStop),
                                  )
                                : FilledButton.icon(
                                    onPressed: () =>
                                        unawaited(_notifier.start()),
                                    icon: GlyphIcon(
                                      idle
                                          ? AppGlyphs.playPause(0)
                                          : AppGlyphs.refresh,
                                      fill: 1,
                                      size: 20,
                                    ),
                                    label: Text(
                                      idle
                                          ? l.speedTestStart
                                          : l.speedTestAgain,
                                    ),
                                  ),
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
                        const SizedBox(height: 12),
                        SpeedTestMetrics(test: display),
                      ],
                    ),
                    generateGroup([
                      if (!idle)
                        ListItem(
                          leading: const GlyphIcon(AppGlyphs.speed),
                          title: Text(l.speedTestResult),
                          trailing: const GlyphIcon(
                            AppGlyphs.chevronForward,
                            size: 18,
                          ),
                          onTap: () => showInSheet<void>(
                            context,
                            builder: (_) => const _CurrentResult(),
                          ),
                        ),
                      ListItem(
                        leading: const GlyphIcon(AppGlyphs.proxies),
                        title: Text(l.speedTestProxy),
                        subtitle: Text(route),
                        trailing: const GlyphIcon(
                          AppGlyphs.chevronForward,
                          size: 18,
                        ),
                        onTap: test.running
                            ? null
                            : () => showInSheet<void>(
                                context,
                                builder: (_) => const SpeedTestProxyPicker(),
                              ),
                      ),
                    ]),
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

class _CurrentResult extends ConsumerWidget {
  const _CurrentResult();

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      SpeedTestResultPage(test: ref.watch(speedTestProvider));
}
