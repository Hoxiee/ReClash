import 'dart:async';

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// `webview_flutter` ships an implementation for these only; the rest of the
/// desktop opens the dashboard in the system browser.
bool get supportsInAppWebDashboard => system.isAndroid || system.isMacOS;

class WebDashboardPage extends StatefulWidget {
  const WebDashboardPage({super.key, required this.uri});

  final Uri uri;

  @override
  State<WebDashboardPage> createState() => _WebDashboardPageState();
}

class _WebDashboardPageState extends State<WebDashboardPage> {
  static const _retryLimit = 2;
  static const _retryDelay = Duration(milliseconds: 700);

  late final WebViewController _controller;
  Timer? _retryTimer;
  int _retries = 0;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => _handleStarted(),
          onPageFinished: (_) => _handleFinished(),
          onWebResourceError: _handleResourceError,
        ),
      )
      ..loadRequest(widget.uri);
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    super.dispose();
  }

  void _handleStarted() {
    if (!mounted) {
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
  }

  void _handleFinished() {
    if (!mounted) {
      return;
    }
    setState(() {
      _loading = false;
      _retries = 0;
    });
  }

  /// The Core brings its controller up asynchronously, so the first load can
  /// still lose the race with the listener.
  void _handleResourceError(WebResourceError error) {
    if (error.isForMainFrame == false || !mounted) {
      return;
    }
    if (_retries < _retryLimit) {
      _retries++;
      _retryTimer?.cancel();
      _retryTimer = Timer(_retryDelay, () => unawaited(_controller.reload()));
      return;
    }
    setState(() {
      _loading = false;
      _error = error.description;
    });
  }

  Future<void> _handleReload() async {
    _retries = 0;
    await _controller.reload();
  }

  Future<void> _handleBrowser() async {
    try {
      await launchUrl(widget.uri, mode: LaunchMode.externalApplication);
    } catch (error) {
      if (!mounted) {
        return;
      }
      dialogs.showNotifier(compactError(error), level: MessageLevel.error);
    }
  }

  Future<bool> _handlePop(BuildContext context) async {
    if (!await _controller.canGoBack()) {
      return true;
    }
    await _controller.goBack();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final error = _error;
    return CommonPopScope(
      onPop: _handlePop,
      child: BaseScaffold(
        title: appLocalizations.webDashboard,
        actions: [
          IconButton(
            tooltip: appLocalizations.reload,
            onPressed: () => unawaited(_handleReload()),
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: appLocalizations.openInBrowser,
            onPressed: () => unawaited(_handleBrowser()),
            icon: const Icon(Icons.open_in_browser),
          ),
        ],
        body: error != null
            ? _WebDashboardError(
                message: error,
                onRetry: () => unawaited(_handleReload()),
              )
            : Stack(
                children: [
                  WebViewWidget(controller: _controller),
                  if (_loading) const Center(child: CommonCircleLoading()),
                ],
              ),
      ),
    );
  }
}

class _WebDashboardError extends StatelessWidget {
  const _WebDashboardError({required this.message, required this.onRetry});

  final String message;

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 16,
          children: [
            const Icon(Icons.cloud_off, size: 48),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium,
            ),
            FilledButton.tonal(
              onPressed: onRetry,
              child: Text(appLocalizations.reload),
            ),
          ],
        ),
      ),
    );
  }
}
