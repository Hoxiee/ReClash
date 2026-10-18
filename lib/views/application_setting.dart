import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/common/update.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/models/tool_route.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:reclash/widgets/settings/setting_spec.dart';
import 'package:reclash/views/config/on_demand.dart';
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
      title: (l) => l.showNotificationStopAction,
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
      id: 'application.updateChannel',
      page: ToolPage.application,
      title: (l) => l.updateChannel,
    ),
    SettingSpec(
      id: 'application.openLogs',
      page: ToolPage.application,
      title: (l) => l.logcat,
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
        _toggle(
          id: 'application.notification',
          select: (s) => s.showNotificationStopAction,
          update: (s, v) => s.copyWith(showNotificationStopAction: v),
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
        spec: ApplicationSettings.spec('application.updateChannel'),
        child: ListItem<UpdateChannel>.options(
          title: Text(l.updateChannel),
          options: UpdateChannel.values,
          value: effectiveUpdateChannel(
            configured: ref.watch(
              appSettingProvider.select((state) => state.updateChannel),
            ),
            isPreBuild: globalState.isPre,
          ),
          textBuilder: (value) => value == UpdateChannel.release
              ? l.updateChannelRelease
              : l.updateChannelPre,
          onChanged: (value) => ref
              .read(appSettingProvider.notifier)
              .update((state) => state.copyWith(updateChannel: value)),
        ),
      ),
      _toggle(
        id: 'application.openLogs',
        select: (s) => s.openLogs,
        update: (s, v) => s.copyWith(openLogs: v),
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
                title: l.startupAndBackground,
                items: startup,
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
