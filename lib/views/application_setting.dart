import 'package:reclash/common/common.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/views/application_notification.dart';
import 'package:reclash/views/appearance/appearance.dart';
import 'package:reclash/views/setup/setup.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

ConfigToggleItem _appSettingToggle({
  required ConfigLabel title,
  required ConfigLabel subtitle,
  required bool Function(AppSettingProps state) select,
  required AppSettingProps Function(AppSettingProps state, bool value) update,
}) {
  return ConfigToggleItem(
    title: title,
    subtitle: subtitle,
    selector: appSettingProvider.select(select),
    onChanged: (ref, value) => ref
        .read(appSettingProvider.notifier)
        .update((state) => update(state, value)),
  );
}

class ApplicationSettingView extends StatelessWidget {
  const ApplicationSettingView({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return BaseScaffold(
      title: appLocalizations.application,
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            SettingsTabs(
              labels: [appLocalizations.general, appLocalizations.notification],
            ),
            const Expanded(
              child: TabBarView(
                children: [_ApplicationGeneralTab(), NotificationSettingsTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ApplicationGeneralTab extends StatelessWidget {
  const _ApplicationGeneralTab();

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final behaviorItems = <Widget>[
      _appSettingToggle(
        title: (l) => l.minimizeOnExit,
        subtitle: (l) => l.minimizeOnExitDesc,
        select: (state) => state.minimizeOnExit,
        update: (state, value) => state.copyWith(minimizeOnExit: value),
      ),
      if (system.isDesktop) ...[
        _appSettingToggle(
          title: (l) => l.autoLaunch,
          subtitle: (l) => l.autoLaunchDesc,
          select: (state) => state.autoLaunch,
          update: (state, value) => state.copyWith(autoLaunch: value),
        ),
        _appSettingToggle(
          title: (l) => l.silentLaunch,
          subtitle: (l) => l.silentLaunchDesc,
          select: (state) => state.silentLaunch,
          update: (state, value) => state.copyWith(silentLaunch: value),
        ),
      ],
      _appSettingToggle(
        title: (l) => l.autoRun,
        subtitle: (l) => l.autoRunDesc,
        select: (state) => state.autoRun,
        update: (state, value) => state.copyWith(autoRun: value),
      ),
      if (system.isAndroid)
        _appSettingToggle(
          title: (l) => l.exclude,
          subtitle: (l) => l.excludeDesc,
          select: (state) => state.hidden,
          update: (state, value) => state.copyWith(hidden: value),
        ),
      _appSettingToggle(
        title: (l) => l.autoCloseConnections,
        subtitle: (l) => l.autoCloseConnectionsDesc,
        select: (state) => state.closeConnections,
        update: (state, value) => state.copyWith(closeConnections: value),
      ),
    ];
    final otherItems = <Widget>[
      _appSettingToggle(
        title: (l) => l.logcat,
        subtitle: (l) => l.logcatDesc,
        select: (state) => state.openLogs,
        update: (state, value) => state.copyWith(openLogs: value),
      ),
      _appSettingToggle(
        title: (l) => l.onlyStatisticsProxy,
        subtitle: (l) => l.onlyStatisticsProxyDesc,
        select: (state) => state.onlyStatisticsProxy,
        update: (state, value) => state.copyWith(onlyStatisticsProxy: value),
      ),
      if (system.isAndroid)
        _appSettingToggle(
          title: (l) => l.crashlytics,
          subtitle: (l) => l.crashlyticsTip,
          select: (state) => state.crashlytics,
          update: (state, value) => state.copyWith(crashlytics: value),
        ),
      _appSettingToggle(
        title: (l) => l.autoCheckUpdate,
        subtitle: (l) => l.autoCheckUpdateDesc,
        select: (state) => state.autoCheckUpdate,
        update: (state, value) => state.copyWith(autoCheckUpdate: value),
      ),
      _appSettingToggle(
        title: (l) => l.checkCertificate,
        subtitle: (l) => l.checkCertificateDesc,
        select: (state) => state.checkCertificate,
        update: (state, value) => state.copyWith(checkCertificate: value),
      ),
    ];
    return SettingsScrollView(
      slivers: [
        SettingSection.sliver(top: 12, items: behaviorItems),
        SettingSection.sliver(title: appLocalizations.other, items: otherItems),
        SettingSection.sliver(
          title: appLocalizations.settings,
          items: [
            DecorationListItem(
              title: Text(appLocalizations.setupRerun),
              subtitle: Text(appLocalizations.setupRerunDesc),
              leading: const Icon(Icons.restart_alt_rounded),
              trailing: const Icon(Icons.chevron_right_rounded, size: 20),
              onPressed: () => SetupWizard.show(context, revisit: true),
            ),
          ],
        ),
        const SettingBottomInset.sliver(),
      ],
    );
  }
}
