import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/common/regional/region_labels.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/models/tool_route.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:reclash/widgets/update_sheet.dart';
import 'package:reclash/widgets/settings/setting_spec.dart';
import 'package:reclash/views/config/on_demand.dart';
import 'package:reclash/views/region.dart';
import 'application_notification.dart';
import 'package:reclash/widgets/settings/setting_target.dart';

class ApplicationSettings {
  static final all = <SettingSpec>[
    SettingSpec(
      id: 'application.autoLaunch',
      page: ToolPage.application,
      title: (l) => l.autoLaunch,
      condition: SettingCondition.desktop,
    ),
    SettingSpec(
      id: 'application.silentLaunch',
      page: ToolPage.application,
      title: (l) => l.silentLaunch,
      condition: SettingCondition.desktop,
    ),
    SettingSpec(
      id: 'application.autoRun',
      page: ToolPage.application,
      title: (l) => l.autoRun,
    ),
    SettingSpec(
      id: 'application.onDemand',
      page: ToolPage.application,
      title: (l) => l.onDemand,
    ),
    SettingSpec(
      id: 'application.region',
      page: ToolPage.application,
      title: (l) => l.appRegion,
    ),
    SettingSpec(
      id: 'application.minimizeOnExit',
      page: ToolPage.application,
      title: (l) => l.minimizeOnExit,
    ),
    SettingSpec(
      id: 'application.hidden',
      page: ToolPage.application,
      title: (l) => l.exclude,
      condition: SettingCondition.android,
    ),
    SettingSpec(
      id: 'application.notification',
      page: ToolPage.application,
      title: (l) => l.notification,
      condition: SettingCondition.android,
    ),
    SettingSpec(
      id: 'application.closeConnections',
      page: ToolPage.application,
      title: (l) => l.autoCloseConnections,
    ),
    SettingSpec(
      id: 'application.onlyStatisticsProxy',
      page: ToolPage.application,
      title: (l) => l.onlyStatisticsProxy,
    ),
    SettingSpec(
      id: 'application.preventDuplicateProfiles',
      page: ToolPage.application,
      title: (l) => l.preventDuplicateProfiles,
    ),
    SettingSpec(
      id: 'application.checkCertificate',
      page: ToolPage.application,
      title: (l) => l.checkCertificate,
    ),
    SettingSpec(
      id: 'application.autoCheckUpdate',
      page: ToolPage.application,
      title: (l) => l.autoCheckUpdate,
    ),
    SettingSpec(
      id: 'application.updatePreferences',
      page: ToolPage.application,
      title: (l) => l.updatePreferencesTitle,
    ),
    SettingSpec(
      id: 'application.openLogs',
      page: ToolPage.application,
      title: (l) => l.logcat,
    ),
    SettingSpec(
      id: 'application.logLevel',
      page: ToolPage.application,
      title: (l) => l.logLevel,
    ),
  ];

  static SettingSpec spec(String id) => all.firstWhere((item) => item.id == id);
}

class ApplicationSettingView extends ConsumerWidget {
  const ApplicationSettingView({super.key});

  ConfigToggleItem _toggle({
    required String id,
    required bool Function(AppSettingProps state) select,
    required AppSettingProps Function(AppSettingProps state, bool value) update,
  }) {
    final spec = ApplicationSettings.spec(id);
    return ConfigToggleItem(
      title: spec.title,
      setting: spec,
      selector: appSettingProvider.select(select),
      onChanged: (ref, value) => ref
          .read(appSettingProvider.notifier)
          .update((state) => update(state, value)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    final startup = <Widget>[
      if (system.isDesktop) ...[
        _toggle(
          id: 'application.autoLaunch',
          select: (s) => s.autoLaunch,
          update: (s, v) => s.copyWith(autoLaunch: v),
        ),
        _toggle(
          id: 'application.silentLaunch',
          select: (s) => s.silentLaunch,
          update: (s, v) => s.copyWith(silentLaunch: v),
        ),
      ],
      _toggle(
        id: 'application.autoRun',
        select: (s) => s.autoRun,
        update: (s, v) => s.copyWith(autoRun: v),
      ),
      SettingTarget(
        spec: ApplicationSettings.spec('application.onDemand'),
        child: ListItem.open(
          title: Text(
            ApplicationSettings.spec('application.onDemand').title(l),
          ),
          widget: const OnDemandView(),
        ),
      ),
      _toggle(
        id: 'application.minimizeOnExit',
        select: (s) => s.minimizeOnExit,
        update: (s, v) => s.copyWith(minimizeOnExit: v),
      ),
      if (system.isAndroid) ...[
        _toggle(
          id: 'application.hidden',
          select: (s) => s.hidden,
          update: (s, v) => s.copyWith(hidden: v),
        ),
        SettingTarget(
          spec: ApplicationSettings.spec('application.notification'),
          child: ListItem.open(
            title: Text(l.notification),
            widget: const NotificationSettingsView(),
          ),
        ),
      ],
    ];
    final appOptions = <Widget>[
      _toggle(
        id: 'application.closeConnections',
        select: (s) => s.closeConnections,
        update: (s, v) => s.copyWith(closeConnections: v),
      ),
      _toggle(
        id: 'application.onlyStatisticsProxy',
        select: (s) => s.onlyStatisticsProxy,
        update: (s, v) => s.copyWith(onlyStatisticsProxy: v),
      ),
      _toggle(
        id: 'application.preventDuplicateProfiles',
        select: (s) => s.preventDuplicateProfiles,
        update: (s, v) => s.copyWith(preventDuplicateProfiles: v),
      ),
      _toggle(
        id: 'application.checkCertificate',
        select: (s) => s.checkCertificate,
        update: (s, v) => s.copyWith(checkCertificate: v),
      ),
      _toggle(
        id: 'application.autoCheckUpdate',
        select: (s) => s.autoCheckUpdate,
        update: (s, v) => s.copyWith(autoCheckUpdate: v),
      ),
      SettingTarget(
        spec: ApplicationSettings.spec('application.updatePreferences'),
        child: ListItem(
          title: Text(l.updatePreferencesTitle),
          trailing: const GlyphIcon(AppGlyphs.chevronForward),
          onTap: () => UpdateSheet.show(context, preferences: true),
        ),
      ),
      _toggle(
        id: 'application.openLogs',
        select: (s) => s.openLogs,
        update: (s, v) => s.copyWith(openLogs: v),
      ),
      ConfigOptionsItem<LogLevel>(
        setting: ApplicationSettings.spec('application.logLevel'),
        title: (l) => l.logLevel,
        options: LogLevel.values,
        textBuilder: (logLevel) => logLevel.name,
        selector: patchClashConfigProvider.select((state) => state.logLevel),
        onChanged: (ref, value) => ref
            .read(patchClashConfigProvider.notifier)
            .update((state) => state.copyWith(logLevel: value)),
      ),
    ];
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
                title: l.startupAndBackground,
                items: [...startup],
                footer: [
                  if (system.isDesktop) l.silentLaunchDesc,
                  l.autoRunDesc,
                  l.onDemandDesc,
                ].join('\n'),
              ),
              generateSection(
                title: l.applicationSettings,
                items: appOptions.take(3),
                footer: l.autoCloseConnectionsDesc,
              ),
              generateSection(
                title: l.requestsAndUpdates,
                items: appOptions.skip(3).take(3),
                footer: l.checkCertificateDesc,
              ),
              generateSection(
                title: l.logsAndDiagnostics,
                items: appOptions.skip(6),
                footer: [l.logcatDesc].join('\n'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
