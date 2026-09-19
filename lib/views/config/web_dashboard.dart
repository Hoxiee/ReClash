import 'dart:async';

import 'package:dio/dio.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'web_dashboard_page.dart';

class WebDashboardItem extends StatelessWidget {
  const WebDashboardItem({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return DecorationListItem.open(
      leading: const Icon(Icons.dashboard_customize_outlined),
      title: Text(appLocalizations.webDashboard),
      subtitle: Text(appLocalizations.webDashboardDesc),
      blur: false,
      widget: const WebDashboardView(),
    );
  }
}

class WebDashboardView extends ConsumerStatefulWidget {
  const WebDashboardView({super.key});

  @override
  ConsumerState<WebDashboardView> createState() => _WebDashboardViewState();
}

class _WebDashboardViewState extends ConsumerState<WebDashboardView> {
  late final WebDashboardSession _session = WebDashboardSession(
    status: () => ref.read(patchClashConfigProvider).externalController,
    setStatus: (status) async => _setController(status),
  );

  bool _installed = false;
  bool _opening = false;
  CancelToken? _cancelToken;
  String? _progress;

  @override
  void initState() {
    super.initState();
    unawaited(_refresh());
  }

  @override
  void dispose() {
    _cancelToken?.cancel();
    super.dispose();
  }

  bool get _busy => _cancelToken != null || _opening;

  Future<void> _refresh() async {
    final installed = await webDashboard.isInstalled;
    if (!mounted) {
      return;
    }
    setState(() {
      _installed = installed;
    });
  }

  /// A patch reaches the Core on its own debounce, which the readiness probe
  /// outwaits.
  void _setController(ExternalControllerStatus status) {
    ref
        .read(patchClashConfigProvider.notifier)
        .update((state) => state.copyWith(externalController: status));
  }

  /// The Core reads `external-ui` only while applying a profile, so an install
  /// or a removal stays invisible until the config is written again.
  Future<void> _apply() async {
    await ref.read(setupActionProvider.notifier).applyProfile(force: true);
  }

  Future<bool> _install() async {
    final cancelToken = CancelToken();
    setState(() {
      _cancelToken = cancelToken;
      _progress = null;
    });
    final error = await webDashboard.install(
      cancelToken: cancelToken,
      onProgress: (received, total) {
        if (!mounted) {
          return;
        }
        setState(() {
          _progress = total > 0
              ? '${received.traffic.show} / ${total.traffic.show}'
              : received.traffic.show;
        });
      },
    );
    if (!mounted) {
      return false;
    }
    setState(() {
      _cancelToken = null;
      _progress = null;
    });
    if (error != null) {
      if (error.isNotEmpty) {
        dialogs.showNotifier(error, level: MessageLevel.error);
      }
      return false;
    }
    await _refresh();
    await _apply();
    return true;
  }

  Future<void> _handleInstall() async {
    if (_busy) {
      return;
    }
    await _install();
  }

  Future<void> _handleRemove() async {
    final appLocalizations = context.appLocalizations;
    final res = await dialogs.showMessage(
      dangerous: true,
      title: appLocalizations.tip,
      message: TextSpan(
        text: appLocalizations.deleteTip(appLocalizations.webDashboard),
      ),
    );
    if (res != true) {
      return;
    }
    await webDashboard.remove();
    await _refresh();
    await _apply();
  }

  Future<void> _handleOpen() async {
    if (_busy) {
      return;
    }
    if (!_installed && !await _install()) {
      return;
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _opening = true;
    });
    try {
      await _session.open();
      final uri = await _serveUri();
      if (uri == null) {
        await _session.close();
        return;
      }
      if (!supportsInAppWebDashboard) {
        await _launchBrowser(uri);
        return;
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _opening = false;
      });
      await BaseNavigator.push<void>(context, WebDashboardPage(uri: uri));
      await _session.close();
    } finally {
      if (mounted) {
        setState(() {
          _opening = false;
        });
      }
    }
  }

  /// A dashboard the Core is not serving yet means the running config carries no
  /// `external-ui`, and only a profile apply can put it there.
  Future<Uri?> _serveUri() async {
    final uri = webDashboardUri(
      ref.read(patchClashConfigProvider).externalController.value,
    );
    var readiness = await probeWebDashboard(uri);
    if (readiness == WebDashboardReadiness.unmounted) {
      await _apply();
      readiness = await probeWebDashboard(uri);
    }
    if (readiness == WebDashboardReadiness.serving) {
      return uri;
    }
    if (mounted) {
      dialogs.showNotifier(
        context.appLocalizations.webDashboardUnreachable,
        level: MessageLevel.error,
      );
    }
    return null;
  }

  /// A browser window cannot report that it closed, so the controller it needed
  /// stays on until the user turns it off.
  Future<void> _launchBrowser(Uri uri) async {
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (error) {
      if (!mounted) {
        return;
      }
      dialogs.showNotifier(compactError(error), level: MessageLevel.error);
    }
  }

  String _openSubtitle(AppLocalizations appLocalizations) {
    if (_cancelToken != null) {
      return _progress ?? appLocalizations.loading;
    }
    if (_opening) {
      return appLocalizations.loading;
    }
    if (!_installed) {
      return appLocalizations.webDashboardInstallTip;
    }
    return appLocalizations.webDashboardSessionTip;
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final cancelToken = _cancelToken;
    return BaseScaffold(
      title: appLocalizations.webDashboard,
      body: SettingsListView(
        children: [
          SettingSection(
            top: 16,
            items: [
              DecorationListItem(
                leading: Icon(
                  supportsInAppWebDashboard
                      ? Icons.dashboard_outlined
                      : Icons.open_in_browser,
                ),
                title: Text(
                  supportsInAppWebDashboard
                      ? appLocalizations.webDashboardOpen
                      : appLocalizations.openInBrowser,
                ),
                subtitle: Text(_openSubtitle(appLocalizations)),
                trailing: cancelToken != null
                    ? IconButton(
                        tooltip: appLocalizations.cancel,
                        onPressed: cancelToken.cancel,
                        icon: const Icon(Icons.close),
                      )
                    : null,
                onPressed: _busy ? null : () => unawaited(_handleOpen()),
              ),
              if (_installed)
                DecorationListItem(
                  leading: const Icon(Icons.refresh),
                  title: Text(appLocalizations.update),
                  subtitle: Text(appLocalizations.webDashboardDesc),
                  onPressed: _busy ? null : () => unawaited(_handleInstall()),
                ),
              if (_installed)
                DecorationListItem(
                  leading: const Icon(Icons.delete_outline),
                  title: Text(appLocalizations.delete),
                  onPressed: _busy ? null : () => unawaited(_handleRemove()),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
