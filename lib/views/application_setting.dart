import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/common/regional/region_labels.dart';
import 'package:reclash/models/tool_route.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:reclash/widgets/update_sheet.dart';
import 'package:reclash/widgets/settings/setting_spec.dart';
import 'package:reclash/views/region.dart';
import 'package:reclash/widgets/settings/setting_target.dart';

class ApplicationSettings {
  static final all = <SettingSpec>[
    SettingSpec(
      id: 'application.autoLaunch',
      page: ToolPage.general,
      title: (l) => l.autoLaunch,
      condition: SettingCondition.desktop,
    ),
    SettingSpec(
      id: 'application.silentLaunch',
      page: ToolPage.general,
      title: (l) => l.silentLaunch,
      condition: SettingCondition.desktop,
    ),
    SettingSpec(
      id: 'application.autoRun',
      page: ToolPage.general,
      title: (l) => l.autoRun,
    ),
    SettingSpec(
      id: 'application.onDemand',
      page: ToolPage.general,
      title: (l) => l.onDemand,
    ),
    SettingSpec(
      id: 'application.region',
      page: ToolPage.application,
      title: (l) => l.appRegion,
    ),
    SettingSpec(
      id: 'application.minimizeOnExit',
      page: ToolPage.general,
      title: (l) => l.minimizeOnExit,
    ),
    SettingSpec(
      id: 'application.hidden',
      page: ToolPage.general,
      title: (l) => l.exclude,
      condition: SettingCondition.android,
    ),
    SettingSpec(
      id: 'application.notification',
      page: ToolPage.general,
      title: (l) => l.notification,
      condition: SettingCondition.android,
    ),
    SettingSpec(
      id: 'application.closeConnections',
      page: ToolPage.general,
      title: (l) => l.autoCloseConnections,
    ),
    SettingSpec(
      id: 'application.onlyStatisticsProxy',
      page: ToolPage.general,
      title: (l) => l.onlyStatisticsProxy,
    ),
    SettingSpec(
      id: 'application.preventDuplicateProfiles',
      page: ToolPage.application,
      title: (l) => l.preventDuplicateProfiles,
    ),
    SettingSpec(
      id: 'application.checkCertificate',
      page: ToolPage.general,
      title: (l) => l.checkCertificate,
    ),
    SettingSpec(
      id: 'application.autoCheckUpdate',
      page: ToolPage.general,
      title: (l) => l.autoCheckUpdate,
    ),
    SettingSpec(
      id: 'application.updatePreferences',
      page: ToolPage.application,
      title: (l) => l.updatePreferencesTitle,
    ),
    SettingSpec(
      id: 'application.openLogs',
      page: ToolPage.general,
      title: (l) => l.logcat,
    ),
    SettingSpec(
      id: 'application.logLevel',
      page: ToolPage.general,
      title: (l) => l.logLevel,
    ),
  ];

  static SettingSpec spec(String id) => all.firstWhere((item) => item.id == id);
}

class ApplicationSettingView extends ConsumerWidget {
  const ApplicationSettingView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    return BaseScaffold(
      title: l.applicationSettings,
      body: SettingsPageScroll(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ).copyWith(top: context.appBarInset, bottom: 20),
          child: Column(
            children: [
              generateSection(
                title: l.regionalAdaptation,
                items: [
                  SettingTarget(
                    spec: ApplicationSettings.spec('application.region'),
                    child: ListItem.open(
                      title: Text(l.appRegion),
                      subtitle: Text(
                        regionLabel(
                          l,
                          ref.watch(
                            appSettingProvider.select(
                              (state) => state.regionCode,
                            ),
                          ),
                        ),
                      ),
                      widget: const RegionView(),
                    ),
                  ),
                ],
                footer: l.regionIntro,
              ),
              generateSection(
                items: [
                  ConfigToggleItem(
                    title: (l) => l.preventDuplicateProfiles,
                    setting: ApplicationSettings.spec(
                      'application.preventDuplicateProfiles',
                    ),
                    selector: appSettingProvider.select(
                      (s) => s.preventDuplicateProfiles,
                    ),
                    onChanged: (ref, value) => ref
                        .read(appSettingProvider.notifier)
                        .update(
                          (s) => s.copyWith(preventDuplicateProfiles: value),
                        ),
                  ),
                  SettingTarget(
                    spec: ApplicationSettings.spec(
                      'application.updatePreferences',
                    ),
                    child: ListItem(
                      title: Text(l.updatePreferencesTitle),
                      trailing: const GlyphIcon(AppGlyphs.chevronForward),
                      onTap: () => UpdateSheet.show(context, preferences: true),
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
