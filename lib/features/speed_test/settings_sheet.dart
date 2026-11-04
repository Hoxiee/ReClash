import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/models/speed_test.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/speed_test.dart';
import 'package:reclash/views/dashboard/style.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/widgets/widgets.dart';

import 'server_picker.dart';

Future<void> showSpeedTestSettingsSheet(BuildContext context) =>
    showInSheet<void>(context, builder: (_) => const SpeedTestSettingsSheet());

void updateSpeedTestSettings(
  WidgetRef ref,
  SpeedTestSettings Function(SpeedTestSettings value) update,
) => ref
    .read(appSettingProvider.notifier)
    .update((state) => state.copyWith(speedTest: update(state.speedTest)));

class SpeedTestSettingsSheet extends ConsumerWidget {
  const SpeedTestSettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    final settings = ref.watch(
      appSettingProvider.select((value) => value.speedTest),
    );
    final complete = settings.mode == SpeedTestMode.complete;
    final viaCore = ref.watch(speedTestViaVpnProvider);
    return CommonScaffold(
      title: l.speedTestSettings,
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          context.sectionsTopPadding,
          16,
          context.bottomInset + 24,
        ),
        children: [
          generateSection(
            footer: '${l.speedTestPlatformHint} ${l.speedTestPrivacy}',
            items: [
              ConfigOptionsItem<String>(
                selector: appSettingProvider.select(
                  (value) => value.speedTest.backendId,
                ),
                title: (l) => l.speedTestPlatform,
                options: SpeedTestSettings.platforms.keys.toList(),
                textBuilder: (id) => SpeedTestSettings.platforms[id] ?? id,
                onChanged: (ref, value) => updateSpeedTestSettings(
                  ref,
                  (state) => state.copyWith(backendId: value),
                ),
              ),
              if (settings.backendId == 'speedtest')
                ListItem(
                  title: Text(l.speedTestServer),
                  subtitle: Text(
                    settings.server?.title ?? l.speedTestServerAutomatic,
                  ),
                  trailing: const GlyphIcon(AppGlyphs.chevronForward, size: 18),
                  onTap: () => showInSheet<void>(
                    context,
                    builder: (_) => const SpeedTestServerPicker(),
                  ),
                ),
            ],
          ),
          generateSection(
            footer: complete ? l.speedTestBudgetHint : null,
            items: [
              ConfigOptionsItem<SpeedTestMode>(
                selector: appSettingProvider.select(
                  (value) => value.speedTest.mode,
                ),
                title: (l) => l.speedTestMode,
                options: SpeedTestMode.values,
                textBuilder: (value) => value.label,
                onChanged: (ref, value) => updateSpeedTestSettings(
                  ref,
                  (state) => state.copyWith(mode: value),
                ),
              ),
              if (complete) ...[
                ConfigOptionsItem<int>(
                  selector: appSettingProvider.select(
                    (value) => value.speedTest.durationSeconds,
                  ),
                  title: (l) => l.speedTestDuration,
                  options: SpeedTestSettings.durations,
                  textBuilder: l.speedTestDurationValue,
                  onChanged: (ref, value) => updateSpeedTestSettings(
                    ref,
                    (state) => state.copyWith(durationSeconds: value),
                  ),
                ),
                ConfigOptionsItem<int>(
                  selector: appSettingProvider.select(
                    (value) => value.speedTest.budgetMiB,
                  ),
                  title: (l) => l.speedTestBudget,
                  options: SpeedTestSettings.budgets,
                  textBuilder: (value) => dashboardTraffic(value * 1024 * 1024),
                  onChanged: (ref, value) => updateSpeedTestSettings(
                    ref,
                    (state) => state.copyWith(budgetMiB: value),
                  ),
                ),
              ],
            ],
          ),
          generateSection(
            title: l.rcxAdvanced,
            footer: viaCore ? null : l.speedTestSystemDnsHint,
            items: [
              if (complete)
                ConfigOptionsItem<bool>(
                  selector: appSettingProvider.select(
                    (value) => value.speedTest.multiThread,
                  ),
                  title: (l) => l.speedTestConnections,
                  options: const [true, false],
                  textBuilder: (value) => value
                      ? l.speedTestMultipleConnections
                      : l.speedTestSingleConnection,
                  onChanged: (ref, value) => updateSpeedTestSettings(
                    ref,
                    (state) => state.copyWith(multiThread: value),
                  ),
                ),
              ConfigOptionsItem<SpeedTestProtocol>(
                selector: appSettingProvider.select(
                  (value) => value.speedTest.protocol,
                ),
                title: (l) => l.speedTestProtocol,
                options: SpeedTestProtocol.values,
                textBuilder: (value) => value.label,
                onChanged: (ref, value) => updateSpeedTestSettings(
                  ref,
                  (state) => state.copyWith(protocol: value),
                ),
              ),
              if (!viaCore)
                ConfigToggleItem(
                  selector: appSettingProvider.select(
                    (value) => value.speedTest.useSystemDns,
                  ),
                  title: (l) => l.speedTestSystemDns,
                  onChanged: (ref, value) => updateSpeedTestSettings(
                    ref,
                    (state) => state.copyWith(useSystemDns: value),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
