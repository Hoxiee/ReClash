import 'package:reclash/models/tool_route.dart';
import 'package:reclash/widgets/settings/setting_spec.dart';
import 'package:reclash/widgets/settings/setting_target.dart';
import 'dart:async';

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/common.dart';
import 'package:reclash/providers/action.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/setup.dart';
import 'package:reclash/state.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeveloperView extends ConsumerWidget {
  const DeveloperView({super.key});

  Widget _getDeveloperList(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    return generateSection(
      title: appLocalizations.options,
      items: [
        SettingTarget(
          spec: developerToolSettings[0],
          child: ListItem(
            title: Text(developerToolSettings[0].title(appLocalizations)),
            onTap: () {
              for (final level in MessageLevel.values) {
                context.showNotifier(
                  '${level.name}: ${appLocalizations.messageTestTip}',
                  level: level,
                );
              }
            },
          ),
        ),
        SettingTarget(
          spec: developerToolSettings[1],
          child: ListItem(
            title: Text(developerToolSettings[1].title(appLocalizations)),
            onTap: () {
              for (int i = 0; i < 1000; i++) {
                ref
                    .read(logsProvider.notifier)
                    .add(
                      Log.app(
                        '[$i]${generateRandomString(maxLength: 200, minLength: 20)}',
                      ),
                    );
              }
            },
          ),
        ),
        if (globalState.canCrashCore)
          SettingTarget(
            spec: developerToolSettings[2],
            child: ListItem(
              title: Text(developerToolSettings[2].title(appLocalizations)),
              onTap: () async {
                final coreAction = ref.read(coreActionProvider.notifier);
                final res = await dialogs.showMessage(
                  message: TextSpan(
                    text: appLocalizations.confirmForceCrashCore,
                  ),
                );
                if (res != true) {
                  return;
                }
                unawaited(coreAction.crash());
              },
            ),
          ),
        SettingTarget(
          spec: developerToolSettings[3],
          child: ListItem(
            title: Text(developerToolSettings[3].title(appLocalizations)),
            onTap: () async {
              final storeAction = ref.read(storeActionProvider.notifier);
              final res = await dialogs.showMessage(
                message: TextSpan(text: appLocalizations.confirmClearAllData),
                destructive: true,
              );
              if (res != true) {
                return;
              }
              await storeAction.handleClear();
            },
          ),
        ),
        SettingTarget(
          spec: developerToolSettings[6],
          child: ListItem(
            title: Text(appLocalizations.setupRestart),
            subtitle: Text(appLocalizations.setupFinishDescription),
            onTap: () {
              Navigator.of(
                context,
                rootNavigator: true,
              ).popUntil((route) => route.isFirst);
              ref.read(setupSessionProvider.notifier).reopen();
            },
          ),
        ),
        SettingTarget(
          spec: developerToolSettings[4],
          child: ListItem(
            title: Text(developerToolSettings[4].title(appLocalizations)),
            onTap: () async {
              await ref.read(storeActionProvider.notifier).shakingStore();
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, ref) {
    final appLocalizations = context.appLocalizations;
    final enable = ref.watch(
      appSettingProvider.select((state) => state.developerMode),
    );
    return BaseScaffold(
      title: appLocalizations.developerMode,
      body: SettingsPageScroll(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ).copyWith(top: context.contentTopPadding, bottom: 16),
          child: Column(
            children: [
              generateSection(
                items: [
                  SettingTarget(
                    spec: developerToolSettings[5],
                    child: ListItem.toggle(
                      title: Text(
                        developerToolSettings[5].title(appLocalizations),
                      ),
                      value: enable,
                      onChanged: (value) {
                        ref
                            .read(appSettingProvider.notifier)
                            .update(
                              (state) => state.copyWith(developerMode: value),
                            );
                      },
                    ),
                  ),
                ],
              ),
              _getDeveloperList(context, ref),
            ],
          ),
        ),
      ),
    );
  }
}

final developerToolSettings = <SettingSpec>[
  SettingSpec(
    id: 'developer.messageTest',
    page: ToolPage.developer,
    title: (l) => l.messageTest,
    keywords: ['messageTest'],
    condition: SettingCondition.developer,
  ),
  SettingSpec(
    id: 'developer.logsTest',
    page: ToolPage.developer,
    title: (l) => l.logsTest,
    keywords: ['logsTest'],
    condition: SettingCondition.developer,
  ),
  SettingSpec(
    id: 'developer.crashTest',
    page: ToolPage.developer,
    title: (l) => l.crashTest,
    keywords: ['crashTest'],
    condition: SettingCondition.developer,
  ),
  SettingSpec(
    id: 'developer.clearData',
    page: ToolPage.developer,
    title: (l) => l.clearData,
    keywords: ['clearData'],
    condition: SettingCondition.developer,
  ),
  SettingSpec(
    id: 'developer.pruneCache',
    page: ToolPage.developer,
    title: (l) => l.pruneCache,
    keywords: ['pruneCache'],
    condition: SettingCondition.developer,
  ),
  SettingSpec(
    id: 'developer.developerMode',
    page: ToolPage.developer,
    title: (l) => l.developerMode,
    keywords: ['developerMode'],
    condition: SettingCondition.developer,
  ),
  SettingSpec(
    id: 'developer.setup',
    page: ToolPage.developer,
    title: (l) => l.setupRestart,
    condition: SettingCondition.developer,
  ),
];
