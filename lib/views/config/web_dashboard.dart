import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/common/web_dashboard/dashboard.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/models/tool_route.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/widgets/settings/setting_spec.dart';
import 'package:reclash/widgets/settings/setting_target.dart';
import 'package:reclash/widgets/widgets.dart';

import 'web_dashboard_page.dart';

final webDashboardSetting = SettingSpec(
  id: 'general.webDashboard',
  keywords: ['web panel', 'web dashboard', 'zashboard', 'metacubexd'],
  page: ToolPage.general,
  title: (l) => l.webDashboard,
);

class WebDashboardItem extends StatelessWidget {
  const WebDashboardItem({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    return SettingTarget(
      spec: webDashboardSetting,
      child: ListItem.open(
        title: Text(l.webDashboard),
        subtitle: Text(l.webDashboardDesc),
        widget: const WebDashboardView(),
      ),
    );
  }
}

class WebDashboardView extends ConsumerStatefulWidget {
  const WebDashboardView({super.key});

  @override
  ConsumerState<WebDashboardView> createState() => _WebDashboardViewState();
}

class _WebDashboardViewState extends ConsumerState<WebDashboardView> {
  late final WebDashboardAction _action;

  @override
  void initState() {
    super.initState();
    _action = ref.read(webDashboardActionProvider.notifier);
    unawaited(_action.refresh());
  }

  @override
  void dispose() {
    _action.cancel();
    super.dispose();
  }

  Future<void> _open(WebDashboardFlavor flavor, {required bool browser}) async {
    final session = await _action.open(flavor, browser: browser);
    if (session == null) return;
    if (browser) return;
    try {
      if (!mounted) return;
      await BaseNavigator.push<void>(
        context,
        WebDashboardPage(session: session),
      );
    } finally {
      await session.close();
    }
  }

  Future<void> _remove(WebDashboardFlavor flavor) async {
    final l = context.appLocalizations;
    final confirmed = await dialogs.showMessage(
      context: context,
      title: l.webDashboard,
      message: TextSpan(text: l.deleteTip(flavor.label)),
      destructive: true,
      confirmText: l.delete,
    );
    if (confirmed == true && mounted) await _action.remove(flavor);
  }

  String _progress(WebDashboardProgress progress) {
    final l = context.appLocalizations;
    return switch (progress.phase) {
      WebDashboardPhase.downloading =>
        progress.total > 0
            ? '${l.webDashboardDownloading}: ${progress.received.traffic.show} / '
                  '${progress.total.traffic.show}'
            : '${l.webDashboardDownloading}: ${progress.received.traffic.show}',
      WebDashboardPhase.verifying => l.webDashboardVerifying,
      WebDashboardPhase.extracting => l.webDashboardExtracting,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final state = ref.watch(webDashboardActionProvider);
    final access = ref.watch(webDashboardAccessProvider);
    final inApp = ref.watch(webDashboardEnvironmentProvider).inApp;
    final flavor = ref.watch(
      appSettingProvider.select((setting) => setting.webDashboardFlavor),
    );
    ref.watch(safeModeProvider);
    ref.watch(coreStatusProvider);
    ref.watch(initProvider);
    ref.watch(currentProfileIdProvider);
    final unavailable = _action.unavailable;
    final installed = state.installations[flavor];
    final enabled = !state.loading && !state.busy;
    final failure = state.failure;
    final progress = state.progress;
    return CommonScaffold(
      title: l.webDashboard,
      primaryAction: IconButtonData(
        glyph: inApp ? AppGlyphs.dashboard : AppGlyphs.openExternal,
        tooltip: inApp ? l.webDashboardOpen : l.webDashboardOpenInBrowser,
        isLoading: state.busy,
        onPressed: enabled && unavailable == null
            ? () => unawaited(_open(flavor, browser: !inApp))
            : null,
      ),
      iconActions: [
        if (state.busy)
          IconButtonData(
            glyph: AppGlyphs.close,
            tooltip: l.cancel,
            onPressed: _action.cancel,
          ),
        if (access.active)
          IconButtonData(
            glyph: AppGlyphs.close,
            tooltip: l.webDashboardEndAccess,
            onPressed: () => unawaited(_action.endAccess()),
          ),
      ],
      menuItems: [
        if (inApp)
          CommonPopupMenuItem(
            glyph: AppGlyphs.openExternal,
            label: l.webDashboardOpenInBrowser,
            onPressed: enabled && unavailable == null
                ? () => unawaited(_open(flavor, browser: true))
                : null,
          ),
        CommonPopupMenuItem(
          glyph: installed == null
              ? AppGlyphs.cloudDownload
              : AppGlyphs.refresh,
          label: installed == null ? l.webDashboardInstall : l.update,
          onPressed: enabled ? () => unawaited(_action.install(flavor)) : null,
        ),
        if (installed != null)
          CommonPopupMenuItem(
            glyph: AppGlyphs.delete,
            label: l.delete,
            danger: true,
            onPressed: enabled ? () => unawaited(_remove(flavor)) : null,
          ),
        CommonPopupMenuItem(
          glyph: AppGlyphs.refresh,
          label: l.webDashboardReload,
          onPressed: enabled ? () => unawaited(_action.refresh()) : null,
        ),
      ],
      body: NullStatusSwitcher(
        isLoading: state.loading,
        loadingStatus: NullStatus(label: l.loading),
        child: SettingsPageScroll(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ).copyWith(top: context.contentTopPadding, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                generateSection(
                  items: [
                    IgnorePointer(
                      ignoring: state.busy,
                      child: ConfigOptionsItem<WebDashboardFlavor>(
                        title: (l) => l.webDashboardFlavor,
                        options: WebDashboardFlavor.values,
                        textBuilder: (flavor) => flavor.label,
                        selector: appSettingProvider.select(
                          (setting) => setting.webDashboardFlavor,
                        ),
                        onChanged: (ref, value) => ref
                            .read(appSettingProvider.notifier)
                            .update(
                              (setting) =>
                                  setting.copyWith(webDashboardFlavor: value),
                            ),
                      ),
                    ),
                    ListItem(
                      title: Text(l.webDashboardFiles),
                      subtitle: Text(
                        installed == null
                            ? l.webDashboardNotInstalled
                            : l.webDashboardInstalledVersion(installed.version),
                      ),
                    ),
                    ListItem(
                      title: Text(l.externalController),
                      subtitle: Text(
                        access.active
                            ? access.browser
                                  ? l.webDashboardBrowserAccess
                                  : l.webDashboardEmbeddedAccess
                            : l.webDashboardNoAccess,
                      ),
                    ),
                  ],
                ),
                if (progress != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(_progress(progress)),
                  ),
                if (failure != null || unavailable != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      (failure ?? unavailable!).label,
                      style: AppTextStyle.footnote
                          .of(context)
                          .copyWith(color: context.colorScheme.error),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(l.webDashboardAccessTip),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
