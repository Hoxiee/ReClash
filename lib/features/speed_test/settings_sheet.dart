import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/models/speed_test.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/speed_test.dart';
import 'package:reclash/views/dashboard/style.dart';
import 'package:reclash/widgets/widgets.dart';

Future<void> showSpeedTestSettingsSheet(BuildContext context) =>
    showInSheet<void>(context, builder: (_) => const SpeedTestSettingsSheet());

class SpeedTestSettingsSheet extends ConsumerWidget {
  const SpeedTestSettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    final backends = ref.watch(speedTestBackendsProvider);
    return CommonScaffold(
      title: l.speedTestSettings,
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          context.contentTopPadding,
          16,
          context.bottomInset + 24,
        ),
        children: [
          generateSection(
            title: l.speedTestPlatform,
            items: [
              ConfigOptionsItem<String>(
                selector: appSettingProvider.select(
                  (value) => value.speedTest.backendId,
                ),
                title: (l) => l.speedTestPlatform,
                subtitle: (l) => l.speedTestPlatformHint,
                options: backends.map((backend) => backend.id).toList(),
                textBuilder: (id) =>
                    backends
                        .where((backend) => backend.id == id)
                        .firstOrNull
                        ?.name ??
                    id,
                onChanged: (ref, value) => ref
                    .read(appSettingProvider.notifier)
                    .update(
                      (state) => state.copyWith(
                        speedTest: state.speedTest.copyWith(backendId: value),
                      ),
                    ),
              ),
            ],
          ),
          generateSection(
            title: l.speedTestMode,
            items: [
              ConfigOptionsItem<SpeedTestMode>(
                selector: appSettingProvider.select(
                  (value) => value.speedTest.mode,
                ),
                title: (l) => l.speedTestMode,
                options: SpeedTestMode.values,
                textBuilder: (value) => value.label,
                onChanged: (ref, value) => ref
                    .read(appSettingProvider.notifier)
                    .update(
                      (state) => state.copyWith(
                        speedTest: state.speedTest.copyWith(mode: value),
                      ),
                    ),
              ),
              ConfigOptionsItem<int>(
                selector: appSettingProvider.select(
                  (value) => value.speedTest.budgetMiB,
                ),
                title: (l) => l.speedTestBudget,
                subtitle: (l) => l.speedTestBudgetHint,
                options: SpeedTestSettings.budgets,
                textBuilder: (value) => dashboardTraffic(value * 1024 * 1024),
                onChanged: (ref, value) => ref
                    .read(appSettingProvider.notifier)
                    .update(
                      (state) => state.copyWith(
                        speedTest: state.speedTest.copyWith(budgetMiB: value),
                      ),
                    ),
              ),
              ConfigToggleItem(
                selector: appSettingProvider.select(
                  (value) => value.speedTest.alwaysConfirm,
                ),
                title: (l) => l.speedTestAlwaysConfirm,
                onChanged: (ref, value) => ref
                    .read(appSettingProvider.notifier)
                    .update(
                      (state) => state.copyWith(
                        speedTest: state.speedTest.copyWith(
                          alwaysConfirm: value,
                        ),
                      ),
                    ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Text(
              l.speedTestSafetyHint,
              style: AppTextStyle.footnote.of(context),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Text(
              l.speedTestPrivacy,
              style: AppTextStyle.footnote.of(context),
            ),
          ),
        ],
      ),
    );
  }
}
