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
      context: sheetNavigatorOf(context).context,
      title: l.webDashboard,
      message: TextSpan(text: l.deleteTip(flavor.label)),
      destructive: true,
      confirmText: l.delete,
    );
    if (confirmed == true && mounted) await _action.remove(flavor);
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
    final latest = flavor.release.version;
    final outdated = installed != null && installed.version != latest;
    final enabled = !state.loading && !state.busy;
    final failure = state.failure;
    final progress = state.progress;
    final colorScheme = context.colorScheme;
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
          label: installed == null
              ? l.webDashboardInstall
              : outdated
              ? l.update
              : l.webDashboardReinstall,
          onPressed: enabled ? () => unawaited(_action.install(flavor)) : null,
        ),
        if (installed != null)
          CommonPopupMenuItem(
            glyph: AppGlyphs.delete,
            label: l.delete,
            danger: true,
            onPressed: enabled ? () => unawaited(_remove(flavor)) : null,
          ),
        if (failure == WebDashboardFailure.storage)
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
                AnimatedReveal(
                  visible: failure != null || unavailable != null,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: failure != null
                        ? _Notice(text: failure.label, error: true)
                        : _Notice(text: unavailable?.label ?? ''),
                  ),
                ),
                AnimatedReveal(
                  visible: progress != null,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: progress != null
                        ? _Progress(progress: progress)
                        : const SizedBox.shrink(),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    generateGroup([
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
                      _ValueRow(
                        title: l.webDashboardVersion,
                        value: Text(switch (installed?.version) {
                          null => l.webDashboardNotInstalled,
                          final version when outdated => '$version → $latest',
                          final version => version,
                        }),
                      ),
                    ]),
                    ListFooter(text: l.webDashboardInstallTip),
                  ],
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    generateGroup([
                      _ValueRow(
                        title: l.webDashboardAccess,
                        value: access.active
                            ? TonalChip(
                                label: access.browser
                                    ? l.webDashboardAccessInBrowser
                                    : l.webDashboardAccessInApp,
                                color: colorScheme.successContainer,
                                foregroundColor: colorScheme.onSuccessContainer,
                              )
                            : Text(l.webDashboardAccessOff),
                      ),
                    ]),
                    ListFooter(
                      text: access.active
                          ? access.browser
                                ? l.webDashboardBrowserAccess
                                : l.webDashboardEmbeddedAccess
                          : l.webDashboardAccessTip,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.text, this.error = false});

  final String text;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final foreground = error
        ? colorScheme.onErrorContainer
        : colorScheme.onSurfaceVariant;
    return CommonCard(
      isError: error,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          GlyphIcon(
            error ? AppGlyphs.error : AppGlyphs.info,
            size: 20,
            color: foreground,
          ),
          Expanded(
            child: Text(
              text,
              style: AppTextStyle.subheadline
                  .of(context)
                  .copyWith(
                    color: error
                        ? colorScheme.onErrorContainer
                        : colorScheme.onSurface,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.progress});

  final WebDashboardProgress progress;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final downloading = progress.phase == WebDashboardPhase.downloading;
    return CommonCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Row(
            spacing: 12,
            children: [
              Expanded(
                child: Text(
                  switch (progress.phase) {
                    WebDashboardPhase.downloading => l.webDashboardDownloading,
                    WebDashboardPhase.verifying => l.webDashboardVerifying,
                    WebDashboardPhase.extracting => l.webDashboardExtracting,
                  },
                  style: AppTextStyle.subheadline.of(context, emphasized: true),
                ),
              ),
              if (downloading)
                Text(
                  [
                    progress.received.traffic.show,
                    if (progress.total > 0) progress.total.traffic.show,
                  ].join(' / '),
                  style: AppTextStyle.footnote
                      .of(context)
                      .copyWith(color: context.colorScheme.onSurfaceVariant),
                ),
            ],
          ),
          LinearProgressIndicator(
            value: downloading && progress.total > 0
                ? (progress.received / progress.total).clamp(0, 1)
                : null,
          ),
        ],
      ),
    );
  }
}

class _ValueRow extends StatelessWidget {
  const _ValueRow({required this.title, required this.value});

  final String title;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    return ListItem(
      title: Text(title),
      trailing: DefaultTextStyle.merge(
        style: context.listTitleStyle.copyWith(
          color: context.colorScheme.onSurfaceVariant,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        child: value,
      ),
    );
  }
}
