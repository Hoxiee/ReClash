import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/common/web_dashboard/access.dart';
import 'package:reclash/common/web_dashboard/dashboard.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/providers/web_dashboard.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebDashboardPage extends ConsumerStatefulWidget {
  const WebDashboardPage({super.key, required this.session});

  final WebDashboardSession session;

  @override
  ConsumerState<WebDashboardPage> createState() => _WebDashboardPageState();
}

class _WebDashboardPageState extends ConsumerState<WebDashboardPage> {
  late WebDashboardSession _session;
  WebViewController? _controller;
  bool _loading = true;
  bool _launching = false;
  WebDashboardFailure? _failure;

  @override
  void initState() {
    super.initState();
    _session = widget.session;
    unawaited(_initialize());
  }

  Future<void> _initialize() async {
    final session = _session;
    bool isCurrent() => mounted && identical(_session, session);
    bool isDocument(Uri uri) =>
        uri.scheme == session.uri.scheme &&
        uri.host == session.uri.host &&
        uri.port == session.uri.port &&
        uri.userInfo.isEmpty &&
        (uri.path == session.uri.path ||
            uri.path == '${session.uri.path}index.html');
    try {
      final controller = WebViewController();
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      await controller.setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (isCurrent() && session.isActive() && _failure == null) {
              _setLoading();
            }
          },
          onPageFinished: (_) {
            if (isCurrent() && session.isActive() && _failure == null) {
              setState(() => _loading = false);
            }
          },
          onNavigationRequest: (request) async {
            final target = Uri.tryParse(request.url);
            if (!isCurrent() || !session.isActive() || target == null) {
              return NavigationDecision.prevent;
            }
            if (isWebDashboardNavigation(session.uri, target)) {
              return NavigationDecision.navigate;
            }
            if (request.isMainFrame &&
                ['http', 'https'].contains(target.scheme) &&
                target.host.isNotEmpty &&
                target.userInfo.isEmpty &&
                target.origin != session.endpoint.controller.origin) {
              try {
                final environment = ref.read(webDashboardEnvironmentProvider);
                if (!await environment
                    .launch(target)
                    .timeout(environment.launchTimeout)) {
                  throw const WebDashboardException(WebDashboardFailure.launch);
                }
              } catch (_) {
                if (mounted && isCurrent()) {
                  context.showNotifier(WebDashboardFailure.launch.label);
                }
              }
            }
            return NavigationDecision.prevent;
          },
          onWebResourceError: (error) {
            final uri = Uri.tryParse(error.url ?? '');
            if (isCurrent() &&
                (error.isForMainFrame == true ||
                    (error.isForMainFrame == null &&
                        (uri == null || !uri.hasScheme || isDocument(uri))))) {
              _setFailure();
            }
          },
          onHttpError: (error) {
            final uri = error.request?.uri;
            if (isCurrent() && (uri == null || isDocument(uri))) {
              _setFailure();
            }
          },
        ),
      );
      if (!isCurrent() || !session.isActive()) return;
      setState(() => _controller = controller);
      await controller.loadRequest(session.uri);
    } catch (_) {
      if (isCurrent()) _setFailure();
    }
  }

  void _setLoading() {
    if (mounted) {
      setState(() {
        _loading = true;
        _failure = null;
      });
    }
  }

  void _setFailure() {
    if (mounted) {
      setState(() {
        _loading = false;
        _failure = WebDashboardFailure.unreachable;
      });
      unawaited(_session.close());
    }
  }

  Future<void> _reload() async {
    if (_loading) return;
    var session = _session;
    bool isCurrent() => mounted && identical(_session, session);
    _setLoading();
    try {
      if (!session.isActive()) {
        final next = await ref
            .read(webDashboardActionProvider.notifier)
            .open(session.flavor, browser: false);
        if (!isCurrent()) {
          await next?.close();
          return;
        }
        if (next == null) {
          _setFailure();
          return;
        }
        _session = session = next;
        _controller = null;
      }
      final controller = _controller;
      if (controller == null) {
        await _initialize();
      } else {
        await controller.loadRequest(session.uri);
      }
    } catch (_) {
      if (isCurrent()) _setFailure();
    }
  }

  Future<void> _browser() async {
    if (_launching) return;
    setState(() => _launching = true);
    try {
      final opened = await ref
          .read(webDashboardActionProvider.notifier)
          .openInBrowser(_session);
      if (!opened && mounted) {
        context.showNotifier(WebDashboardFailure.launch.label);
      }
    } finally {
      if (mounted) setState(() => _launching = false);
    }
  }

  Future<bool> _back(BuildContext context) async {
    try {
      final controller = _controller;
      if (_session.isActive() &&
          controller != null &&
          await controller.canGoBack()) {
        await controller.goBack();
        return false;
      }
    } catch (_) {}
    return true;
  }

  @override
  void dispose() {
    unawaited(_session.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final access = ref.watch(webDashboardAccessProvider);
    final active = access.owners.containsKey(_session.owner);
    final failure = _failure;
    final controller = _controller;
    final retryable = active || failure != null;
    return CommonPopScope(
      onPop: _back,
      child: CommonScaffold(
        title: _session.flavor.label,
        iconActions: [
          IconButtonData(
            glyph: AppGlyphs.refresh,
            tooltip: l.webDashboardReload,
            onPressed: retryable && !_loading
                ? () => unawaited(_reload())
                : null,
          ),
          IconButtonData(
            glyph: AppGlyphs.openExternal,
            tooltip: l.webDashboardOpenInBrowser,
            isLoading: _launching,
            onPressed: active && !_launching
                ? () => unawaited(_browser())
                : null,
          ),
        ],
        body: AppBarClearance(
          child: !active || failure != null
              ? NullStatus(
                  illustration: NullStatusIllustration.error,
                  label: failure != null
                      ? l.webDashboard
                      : l.webDashboardAccessEnded,
                  description: failure?.label ?? l.webDashboardNoAccess,
                  action: retryable
                      ? FilledButton.tonal(
                          onPressed: () => unawaited(_reload()),
                          child: Text(l.webDashboardReload),
                        )
                      : null,
                )
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    if (controller != null)
                      WebViewWidget(controller: controller),
                    if (_loading) const Center(child: CommonCircleLoading()),
                  ],
                ),
        ),
      ),
    );
  }
}
