import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/common/desktop/launch.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/views/settings/application_notification.dart';
import 'package:reclash/views/setup/setup.dart';
import 'package:reclash/widgets/widgets.dart';

ConfigToggleItem _appSettingToggle({
  required ConfigLabel title,
  required ConfigLabel subtitle,
  required bool Function(AppSettingProps state) select,
  required AppSettingProps Function(AppSettingProps state, bool value) update,
  SettingSearch? search,
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

class LogLevelItem extends ConsumerWidget {
  const LogLevelItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return ConfigOptionsItem<LogLevel>(
      search: const SettingSearch(),
      title: (l) => l.logLevel,
      options: LogLevel.values,
      textBuilder: (logLevel) => logLevel.name,
      selector: patchClashConfigProvider.select((state) => state.logLevel),
      onChanged: (ref, value) => ref
          .read(patchClashConfigProvider.notifier)
          .update((state) => state.copyWith(logLevel: value)),
    );
  }
}

class ApplicationSettingView extends StatelessWidget {
  const ApplicationSettingView({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return BaseScaffold(
      title: appLocalizations.application,
      body: const _ApplicationGeneralTab(),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  const _NotificationItem();

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return DecorationListItem.open(
      leading: const GlyphIcon(AppGlyphs.bell),
      search: const SettingSearch(gate: SettingGate.android),
      title: Text(appLocalizations.notification),
      subtitle: Text(appLocalizations.notificationProtectionDesc),
      widget: BaseScaffold(
        title: appLocalizations.notification,
        body: const NotificationSettingsView(),
      ),
      paneId: 'notification',
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
        search: const SettingSearch(),
        title: (l) => l.minimizeOnExit,
        subtitle: (l) => l.minimizeOnExitDesc,
        select: (state) => state.minimizeOnExit,
        update: (state, value) => state.copyWith(minimizeOnExit: value),
      ),
      if (system.isDesktop) ...[
        _appSettingToggle(
          search: const SettingSearch(gate: SettingGate.desktop),
          title: (l) => l.autoLaunch,
          subtitle: (l) => l.autoLaunchDesc,
          select: (state) => state.autoLaunch,
          update: (state, value) => state.copyWith(autoLaunch: value),
        ),
        _appSettingToggle(
          search: const SettingSearch(gate: SettingGate.desktop),
          title: (l) => l.silentLaunch,
          subtitle: (l) => l.silentLaunchDesc,
          select: (state) => state.silentLaunch,
          update: (state, value) => state.copyWith(silentLaunch: value),
        ),
        if (system.isWindows)
          ConfigToggleItem(
            search: const SettingSearch(gate: SettingGate.windows),
            title: (l) => l.highPriorityAutoLaunch,
            subtitle: (l) => l.highPriorityAutoLaunchDesc,
            selector: appSettingProvider.select(
              (state) => state.highPriorityAutoLaunch,
            ),
            onChanged: (ref, value) {
              ref
                  .read(appSettingProvider.notifier)
                  .update(
                    (state) => state.copyWith(highPriorityAutoLaunch: value),
                  );
              unawaited(
                autoLaunch?.updateStatus(
                  ref.read(appSettingProvider).autoLaunch,
                ),
              );
            },
          ),
      ],
      _appSettingToggle(
        search: const SettingSearch(),
        title: (l) => l.autoRun,
        subtitle: (l) => l.autoRunDesc,
        select: (state) => state.autoRun,
        update: (state, value) => state.copyWith(autoRun: value),
      ),
      if (system.isAndroid)
        _appSettingToggle(
          search: const SettingSearch(gate: SettingGate.android),
          title: (l) => l.exclude,
          subtitle: (l) => l.excludeDesc,
          select: (state) => state.hidden,
          update: (state, value) => state.copyWith(hidden: value),
        ),
      _appSettingToggle(
        search: const SettingSearch(),
        title: (l) => l.autoCloseConnections,
        subtitle: (l) => l.autoCloseConnectionsDesc,
        select: (state) => state.closeConnections,
        update: (state, value) => state.copyWith(closeConnections: value),
      ),
    ];
    final otherItems = <Widget>[
      _appSettingToggle(
        search: const SettingSearch(),
        title: (l) => l.onlyStatisticsProxy,
        subtitle: (l) => l.onlyStatisticsProxyDesc,
        select: (state) => state.onlyStatisticsProxy,
        update: (state, value) => state.copyWith(onlyStatisticsProxy: value),
      ),
      _appSettingToggle(
        search: const SettingSearch(),
        title: (l) => l.autoCheckUpdate,
        subtitle: (l) => l.autoCheckUpdateDesc,
        select: (state) => state.autoCheckUpdate,
        update: (state, value) => state.copyWith(autoCheckUpdate: value),
      ),
      _appSettingToggle(
        search: const SettingSearch(),
        title: (l) => l.prereleaseUpdates,
        subtitle: (l) => l.prereleaseUpdatesDesc,
        select: (state) => state.acceptPrereleaseUpdates,
        update: (state, value) =>
            state.copyWith(acceptPrereleaseUpdates: value),
      ),
      _appSettingToggle(
        search: const SettingSearch(),
        title: (l) => l.checkCertificate,
        subtitle: (l) => l.checkCertificateDesc,
        select: (state) => state.checkCertificate,
        update: (state, value) => state.copyWith(checkCertificate: value),
      ),
    ];
    final logItems = <Widget>[
      const LogLevelItem(),
      _appSettingToggle(
        search: const SettingSearch(),
        title: (l) => l.logcat,
        subtitle: (l) => l.logcatDesc,
        select: (state) => state.openLogs,
        update: (state, value) => state.copyWith(openLogs: value),
      ),
      if (system.isAndroid)
        _appSettingToggle(
          search: const SettingSearch(gate: SettingGate.android),
          title: (l) => l.crashlytics,
          subtitle: (l) => l.crashlyticsTip,
          select: (state) => state.crashlytics,
          update: (state, value) => state.copyWith(crashlytics: value),
        ),
    ];
    return SettingsScrollView(
      slivers: [
        SliverToBoxAdapter(child: SizedBox(height: context.appBarInset)),
        SettingSection.sliver(top: 12, items: behaviorItems),
        SettingSection.sliver(
          search: const SettingSearch(),
          title: appLocalizations.other,
          items: otherItems,
        ),
        SettingSection.sliver(
          search: const SettingSearch(),
          title: appLocalizations.logsAndDiagnostics,
          items: logItems,
        ),
        SettingSection.sliver(
          search: const SettingSearch(),
          title: appLocalizations.settings,
          items: [
            if (system.isAndroid) const _NotificationItem(),
            DecorationListItem(
              search: const SettingSearch(),
              title: Text(appLocalizations.setupRerun),
              subtitle: Text(appLocalizations.setupRerunDesc),
              leading: const GlyphIcon(AppGlyphs.reset),
              trailing: const GlyphIcon(AppGlyphs.chevronForward, size: 20),
              onPressed: () => SetupWizard.show(context, revisit: true),
            ),
          ],
        ),
        const SettingBottomInset.sliver(),
      ],
    );
  }
}
