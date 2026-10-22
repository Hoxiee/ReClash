import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/web_dashboard/dashboard.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/providers/action.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/database.dart';
import 'package:reclash/providers/web_dashboard.dart';
import 'package:reclash/state.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/views/config/web_dashboard.dart';
import 'package:reclash/views/config/web_dashboard_page.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart'
    as web;

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

class _Action extends WebDashboardAction {
  WebDashboardState initial = const WebDashboardState();
  final calls = <String>[];
  WebDashboardSession? session;
  Completer<void>? refreshGate;
  Completer<WebDashboardSession?>? openGate;

  @override
  WebDashboardState build() => initial;

  void show(WebDashboardState value) => state = value;

  @override
  Future<void> refresh() async {
    calls.add('refresh');
    await refreshGate?.future;
    if (ref.mounted) state = initial;
  }

  @override
  Future<bool> install(WebDashboardFlavor flavor) async {
    calls.add('install:${flavor.name}');
    return true;
  }

  @override
  Future<bool> remove(WebDashboardFlavor flavor) async {
    calls.add('remove:${flavor.name}');
    return true;
  }

  @override
  void cancel() => calls.add('cancel');

  @override
  Future<WebDashboardSession?> open(
    WebDashboardFlavor flavor, {
    required bool browser,
  }) async {
    calls.add('open:${flavor.name}:$browser');
    final gate = openGate;
    if (gate != null) return gate.future;
    return session;
  }

  @override
  Future<bool> openInBrowser(WebDashboardSession session) async {
    calls.add('browser');
    return true;
  }

  @override
  Future<void> endAccess() async {
    calls.add('end');
    ref.read(webDashboardAccessProvider.notifier).end();
  }
}

class _Setup extends SetupAction {
  @override
  Future<void> syncWebDashboardAccess() async {}
}

class _Platform extends web.WebViewPlatform {
  late _Controller controller;
  late _Delegate delegate;
  bool failLoad = false;
  bool finishLoads = true;

  @override
  web.PlatformWebViewController createPlatformWebViewController(
    web.PlatformWebViewControllerCreationParams params,
  ) => controller = _Controller(params, this);

  @override
  web.PlatformNavigationDelegate createPlatformNavigationDelegate(
    web.PlatformNavigationDelegateCreationParams params,
  ) => delegate = _Delegate(params);

  @override
  web.PlatformWebViewWidget createPlatformWebViewWidget(
    web.PlatformWebViewWidgetCreationParams params,
  ) => _WebWidget(params);
}

class _Controller extends web.PlatformWebViewController {
  _Controller(super.params, this.platform) : super.implementation();
  final _Platform platform;
  final loads = <Uri>[];
  late _Delegate delegate;
  Completer<void>? loadGate;
  bool hasBack = false;
  int backs = 0;

  @override
  Future<void> setJavaScriptMode(web.JavaScriptMode mode) async {}

  @override
  Future<void> setPlatformNavigationDelegate(
    web.PlatformNavigationDelegate delegate,
  ) async => this.delegate = delegate as _Delegate;

  @override
  Future<void> loadRequest(web.LoadRequestParams params) async {
    loads.add(params.uri);
    if (platform.failLoad) throw StateError('load failed');
    delegate.started?.call(params.uri.toString());
    await loadGate?.future;
    if (platform.finishLoads) delegate.finished?.call(params.uri.toString());
  }

  @override
  Future<bool> canGoBack() async => hasBack;

  @override
  Future<void> goBack() async {
    backs++;
    hasBack = false;
  }
}

class _Delegate extends web.PlatformNavigationDelegate {
  _Delegate(super.params) : super.implementation();
  web.NavigationRequestCallback? navigate;
  web.PageEventCallback? started;
  web.PageEventCallback? finished;
  web.WebResourceErrorCallback? failed;
  web.HttpResponseErrorCallback? httpFailed;

  @override
  Future<void> setOnNavigationRequest(
    web.NavigationRequestCallback callback,
  ) async => navigate = callback;
  @override
  Future<void> setOnPageStarted(web.PageEventCallback callback) async =>
      started = callback;
  @override
  Future<void> setOnPageFinished(web.PageEventCallback callback) async =>
      finished = callback;
  @override
  Future<void> setOnWebResourceError(
    web.WebResourceErrorCallback callback,
  ) async => failed = callback;
  @override
  Future<void> setOnHttpError(web.HttpResponseErrorCallback callback) async =>
      httpFailed = callback;
}

class _WebWidget extends web.PlatformWebViewWidget {
  _WebWidget(super.params) : super.implementation();
  @override
  Widget build(BuildContext context) => const Text('embedded dashboard');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ProviderContainer container;
  late _Action action;
  late _Platform platform;
  web.WebViewPlatform? previousPlatform;
  late bool inApp;
  late bool safe;
  late List<Uri> launched;

  setUp(() {
    action = _Action();
    platform = _Platform();
    previousPlatform = web.WebViewPlatform.instance;
    web.WebViewPlatform.instance = platform;
    inApp = false;
    safe = false;
    launched = [];
    container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(TestProfiles.new),
        setupActionProvider.overrideWith(_Setup.new),
        webDashboardActionProvider.overrideWith(() => action),
        safeModeProvider.overrideWith((_) => safe),
        webDashboardEnvironmentProvider.overrideWith(
          (_) => WebDashboardEnvironment(
            inApp: inApp,
            launch: (uri) async {
              launched.add(uri);
              return true;
            },
          ),
        ),
      ],
    );
    globalState.container = container;
    container.listen(
      currentProfileIdProvider,
      (_, _) {},
      fireImmediately: true,
    );
    container.read(currentProfileIdProvider.notifier).value = 1;
    container.read(coreStatusProvider.notifier).value = CoreStatus.connected;
    container.read(initProvider.notifier).value = true;
  });

  tearDown(() {
    final gate = action.refreshGate;
    if (gate != null && !gate.isCompleted) gate.complete();
    final opening = action.openGate;
    if (opening != null && !opening.isCompleted) opening.complete(null);
    container.dispose();
    if (previousPlatform != null) {
      web.WebViewPlatform.instance = previousPlatform;
    }
  });

  Future<void> pump(
    WidgetTester tester, {
    Widget child = const WebDashboardView(),
    Size size = const Size(1000, 1000),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    container.read(viewSizeProvider.notifier).value = size;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(locale: const Locale('en'), child: child),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  Future<void> menu(WidgetTester tester, String label) async {
    await tester.tap(find.byTooltip('More'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(label).last);
    await tester.pumpAndSettle();
  }

  WebDashboardSession session() {
    final access = container.read(webDashboardAccessProvider.notifier);
    final owner = access.acquire(WebDashboardFlavor.zashboard);
    return WebDashboardSession(
      owner: owner,
      flavor: WebDashboardFlavor.zashboard,
      endpoint: WebDashboardEndpoint(
        controller: Uri.parse('http://127.0.0.1:19090'),
        secret: 'test',
      ),
      isActive: () => access.contains(owner),
      close: () => access.close(owner),
    );
  }

  testWidgets(
    'loads on mount and shows installation state without body action buttons',
    (tester) async {
      await pump(tester);
      expect(action.calls, ['refresh']);
      expect(find.text('Not installed'), findsOneWidget);
      expect(find.text('Off'), findsOneWidget);
      expect(find.byTooltip('Open in browser'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Open dashboard'), findsNothing);
      expect(
        find.widgetWithText(FilledButton, 'Install dashboard'),
        findsNothing,
      );
      await tester.tap(find.byTooltip('Open in browser'));
      await tester.pumpAndSettle();
      expect(action.calls, contains('open:zashboard:true'));
    },
  );

  testWidgets('loading waits for metadata before exposing settings', (
    tester,
  ) async {
    action.initial = const WebDashboardState(loading: true);
    action.refreshGate = Completer<void>();
    await pump(tester);
    expect(find.text('Not installed'), findsNothing);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Loading…'), findsWidgets);
    action.initial = const WebDashboardState();
    action.refreshGate!.complete();
    await tester.pumpAndSettle();
    expect(find.text('Not installed'), findsOneWidget);
  });

  testWidgets('install, update and storage retry live in the app bar menu', (
    tester,
  ) async {
    await pump(tester);
    await menu(tester, 'Install dashboard');
    expect(action.calls, contains('install:zashboard'));
    action.show(
      const WebDashboardState(
        installations: {
          WebDashboardFlavor.zashboard: WebDashboardInstallation(
            version: 'test-version',
          ),
        },
      ),
    );
    await tester.pumpAndSettle();
    final latest = WebDashboardFlavor.zashboard.release.version;
    expect(find.text('test-version → $latest'), findsOneWidget);
    await menu(tester, 'Update');
    expect(
      action.calls.where((call) => call == 'install:zashboard'),
      hasLength(2),
    );
    action.show(
      WebDashboardState(
        installations: {
          WebDashboardFlavor.zashboard: WebDashboardInstallation(
            version: latest,
          ),
        },
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(latest), findsOneWidget);
    await tester.tap(find.byTooltip('More'));
    await tester.pumpAndSettle();
    expect(find.text('Update'), findsNothing);
    expect(find.text('Reload'), findsNothing);
    await tester.tapAt(Offset.zero);
    await tester.pumpAndSettle();
    action.show(const WebDashboardState(failure: WebDashboardFailure.storage));
    await tester.pumpAndSettle();
    await menu(tester, 'Reload');
    expect(action.calls.where((call) => call == 'refresh'), hasLength(2));
  });

  testWidgets('deletion is confirmed and cancellation keeps the dashboard', (
    tester,
  ) async {
    action.initial = const WebDashboardState(
      installations: {
        WebDashboardFlavor.zashboard: WebDashboardInstallation(
          version: 'fixture',
        ),
      },
    );
    await pump(tester);
    await menu(tester, 'Delete');
    await tester.tap(find.text('Cancel').last);
    await tester.pumpAndSettle();
    expect(action.calls, isNot(contains('remove:zashboard')));
    await menu(tester, 'Delete');
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();
    expect(action.calls, contains('remove:zashboard'));
  });

  testWidgets('progress is cancellable and errors do not leave a spinner', (
    tester,
  ) async {
    await pump(tester);
    action.show(
      const WebDashboardState(
        busy: true,
        progress: WebDashboardProgress(
          WebDashboardPhase.downloading,
          received: 1024,
          total: 2048,
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Downloading dashboard'), findsOneWidget);
    expect(
      tester
          .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
          .value,
      0.5,
    );
    await tester.tap(find.byTooltip('Cancel'));
    expect(action.calls, contains('cancel'));
    action.show(const WebDashboardState(failure: WebDashboardFailure.checksum));
    await tester.pumpAndSettle();
    expect(find.textContaining('checksum does not match'), findsOneWidget);
    expect(find.text('Downloading dashboard'), findsNothing);
    expect(find.byTooltip('Cancel'), findsNothing);
  });

  testWidgets('unavailable Core profile and Safe Mode disable opening', (
    tester,
  ) async {
    container.read(coreStatusProvider.notifier).value = CoreStatus.disconnected;
    await pump(tester);
    expect(find.text('The Core is not ready.'), findsOneWidget);
    expect(
      tester
          .widget<CommonScaffold>(find.byType(CommonScaffold))
          .primaryAction!
          .onPressed,
      isNull,
    );
    container.read(coreStatusProvider.notifier).value = CoreStatus.connected;
    container.read(currentProfileIdProvider.notifier).value = null;
    await tester.pumpAndSettle();
    expect(
      find.text('Select a profile before opening the dashboard.'),
      findsOneWidget,
    );
    safe = true;
    container.invalidate(safeModeProvider);
    await tester.pumpAndSettle();
    expect(
      find.text('Dashboard access is disabled in Safe Mode.'),
      findsOneWidget,
    );
    expect(
      tester
          .widget<CommonScaffold>(find.byType(CommonScaffold))
          .primaryAction!
          .onPressed,
      isNull,
    );
  });

  testWidgets('browser access has an explicit end command', (tester) async {
    final active = session();
    container
        .read(webDashboardAccessProvider.notifier)
        .keepForBrowser(active.owner);
    await pump(tester);
    expect(
      find.text('Browser access stays active until you end it or quit ReClash'),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip('End dashboard access'));
    await tester.pumpAndSettle();
    expect(action.calls, contains('end'));
    expect(active.isActive(), isFalse);
  });

  testWidgets(
    'embedded platform opens a WebView and disposal releases access',
    (tester) async {
      inApp = true;
      action.session = session();
      await pump(tester);
      await tester.tap(find.byTooltip('Open dashboard'));
      await tester.pumpAndSettle();
      expect(action.calls, contains('open:zashboard:false'));
      expect(find.text('embedded dashboard'), findsOneWidget);
      expect(platform.controller.loads.single, action.session!.uri);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      expect(action.session!.isActive(), isFalse);
    },
  );

  testWidgets('embedded navigation rejects Core API and external subframes', (
    tester,
  ) async {
    final active = session();
    await pump(tester, child: WebDashboardPage(session: active));
    final navigate = platform.delegate.navigate!;
    expect(
      await navigate(
        web.NavigationRequest(
          url: '${active.uri.origin}/ui/zashboard/#/proxies',
          isMainFrame: true,
        ),
      ),
      web.NavigationDecision.navigate,
    );
    expect(
      await navigate(
        web.NavigationRequest(
          url: '${active.uri.origin}/configs',
          isMainFrame: true,
        ),
      ),
      web.NavigationDecision.prevent,
    );
    expect(
      await navigate(
        const web.NavigationRequest(
          url: 'https://example.com/frame',
          isMainFrame: false,
        ),
      ),
      web.NavigationDecision.prevent,
    );
    expect(launched, isEmpty);
    expect(
      await navigate(
        const web.NavigationRequest(url: 'http:invalid', isMainFrame: true),
      ),
      web.NavigationDecision.prevent,
    );
    expect(launched, isEmpty);
    expect(
      await navigate(
        const web.NavigationRequest(
          url: 'https://example.com/help',
          isMainFrame: true,
        ),
      ),
      web.NavigationDecision.prevent,
    );
    expect(launched.single, Uri.parse('https://example.com/help'));
  });

  testWidgets(
    'WebView failure releases access and reload acquires a new session',
    (tester) async {
      final old = session();
      await pump(tester, child: WebDashboardPage(session: old));
      platform.delegate.failed!(
        const web.WebResourceError(
          errorCode: -1,
          description: 'failed',
          isForMainFrame: false,
        ),
      );
      await tester.pumpAndSettle();
      expect(old.isActive(), isTrue);
      platform.delegate.failed!(
        const web.WebResourceError(
          errorCode: -1,
          description: 'failed',
          isForMainFrame: true,
        ),
      );
      await tester.pumpAndSettle();
      expect(old.isActive(), isFalse);
      platform.delegate.started!(old.uri.toString());
      platform.delegate.finished!(old.uri.toString());
      await tester.pumpAndSettle();
      expect(
        find.text('The Core is not serving this dashboard.'),
        findsOneWidget,
      );
      final next = session();
      action.session = next;
      await tester.tap(find.widgetWithText(FilledButton, 'Reload'));
      await tester.pumpAndSettle();
      expect(next.isActive(), isTrue);
      expect(platform.controller.loads.last, next.uri);
      expect(find.text('embedded dashboard'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      expect(next.isActive(), isFalse);
    },
  );

  testWidgets('resource errors without frame metadata do not end access', (
    tester,
  ) async {
    final active = session();
    await pump(tester, child: WebDashboardPage(session: active));
    for (final url in [
      '${active.uri.origin}/ui/zashboard/assets/app.js',
      'data:text/plain,resource',
      'http:invalid',
      'https://example.com/ui/zashboard/',
    ]) {
      platform.delegate.failed!(
        web.WebResourceError(errorCode: -1, description: 'failed', url: url),
      );
      platform.delegate.httpFailed!(
        web.HttpResponseError(
          request: web.WebResourceRequest(uri: Uri.parse(url)),
        ),
      );
      await tester.pump();
      expect(active.isActive(), isTrue);
      expect(find.text('embedded dashboard'), findsOneWidget);
    }
    platform.delegate.failed!(
      web.WebResourceError(
        errorCode: -1,
        description: 'failed',
        url: '${active.uri.origin}/ui/zashboard/index.html',
      ),
    );
    await tester.pumpAndSettle();
    expect(active.isActive(), isFalse);
    expect(find.widgetWithText(FilledButton, 'Reload'), findsOneWidget);
  });

  for (final withRequest in [true, false]) {
    testWidgets('HTTP document error ends access with request=$withRequest', (
      tester,
    ) async {
      final active = session();
      await pump(tester, child: WebDashboardPage(session: active));
      platform.delegate.httpFailed!(
        web.HttpResponseError(
          request: withRequest
              ? web.WebResourceRequest(
                  uri: active.uri.replace(path: '${active.uri.path}index.html'),
                )
              : null,
        ),
      );
      await tester.pumpAndSettle();
      expect(active.isActive(), isFalse);
      expect(
        find.text('The Core is not serving this dashboard.'),
        findsOneWidget,
      );
      expect(find.widgetWithText(FilledButton, 'Reload'), findsOneWidget);
    });
  }

  testWidgets('callbacks from an old WebView never alter the new session', (
    tester,
  ) async {
    final old = session();
    await pump(tester, child: WebDashboardPage(session: old));
    final delegate = platform.delegate;
    delegate.failed!(
      const web.WebResourceError(
        errorCode: -1,
        description: 'failed',
        isForMainFrame: true,
      ),
    );
    await tester.pumpAndSettle();
    final next = session();
    action.session = next;
    platform.finishLoads = false;
    await tester.tap(find.widgetWithText(FilledButton, 'Reload'));
    await tester.pump();
    expect(platform.delegate, isNot(same(delegate)));
    expect(platform.controller.loads.single, next.uri);
    delegate.finished!(old.uri.toString());
    delegate.failed!(
      const web.WebResourceError(
        errorCode: -1,
        description: 'late failure',
        isForMainFrame: true,
      ),
    );
    delegate.httpFailed!(
      web.HttpResponseError(request: web.WebResourceRequest(uri: old.uri)),
    );
    expect(
      await delegate.navigate!(
        const web.NavigationRequest(
          url: 'https://example.com/late',
          isMainFrame: true,
        ),
      ),
      web.NavigationDecision.prevent,
    );
    await tester.pump();
    expect(next.isActive(), isTrue);
    expect(find.byType(CommonCircleLoading), findsOneWidget);
    expect(launched, isEmpty);
    platform.delegate.finished!(next.uri.toString());
    await tester.pumpAndSettle();
    delegate.started!(old.uri.toString());
    await tester.pump();
    expect(find.byType(CommonCircleLoading), findsNothing);
    expect(next.isActive(), isTrue);
  });

  testWidgets('repeated reload waits for the same opening operation', (
    tester,
  ) async {
    final old = session();
    await pump(tester, child: WebDashboardPage(session: old));
    platform.delegate.failed!(
      const web.WebResourceError(
        errorCode: -1,
        description: 'failed',
        isForMainFrame: true,
      ),
    );
    await tester.pumpAndSettle();
    action.openGate = Completer<WebDashboardSession?>();
    await tester.tap(find.widgetWithText(FilledButton, 'Reload'));
    await tester.tap(find.widgetWithText(FilledButton, 'Reload'));
    await tester.pump();
    expect(
      action.calls.where((call) => call == 'open:zashboard:false'),
      hasLength(1),
    );
    final next = session();
    action.openGate!.complete(next);
    await tester.pumpAndSettle();
    expect(next.isActive(), isTrue);
    expect(platform.controller.loads.single, next.uri);
  });

  testWidgets('a late reload exception cannot close a replacement session', (
    tester,
  ) async {
    final old = session();
    await pump(tester, child: WebDashboardPage(session: old));
    final previous = platform.controller;
    final gate = previous.loadGate = Completer<void>();
    addTearDown(() {
      if (!gate.isCompleted) gate.complete();
    });
    await tester.tap(find.byTooltip('Reload'));
    await tester.pump();
    expect(previous.loads, hasLength(2));
    previous.delegate.failed!(
      const web.WebResourceError(
        errorCode: -1,
        description: 'failed',
        isForMainFrame: true,
      ),
    );
    await tester.pumpAndSettle();
    final next = session();
    action.session = next;
    await tester.tap(find.widgetWithText(FilledButton, 'Reload'));
    await tester.pumpAndSettle();
    gate.completeError(StateError('late reload failure'));
    await tester.pumpAndSettle();
    expect(next.isActive(), isTrue);
    expect(find.text('embedded dashboard'), findsOneWidget);
    expect(find.text('The Core is not serving this dashboard.'), findsNothing);
  });

  testWidgets('back leaves the page instead of replaying dashboard history', (
    tester,
  ) async {
    final active = session();
    await pump(tester, child: const SizedBox.shrink());
    final navigator = tester.state<NavigatorState>(find.byType(Navigator).last);
    unawaited(
      navigator
          .push(
            MaterialPageRoute<void>(
              builder: (_) => WebDashboardPage(session: active),
            ),
          )
          .then((_) => active.close()),
    );
    await tester.pumpAndSettle();
    expect(find.text('embedded dashboard'), findsOneWidget);
    platform.controller.hasBack = true;
    expect(await navigator.maybePop(), isTrue);
    await tester.pumpAndSettle();
    expect(platform.controller.backs, 0);
    expect(find.text('embedded dashboard'), findsNothing);
    expect(active.isActive(), isFalse);
  });

  testWidgets('WebView load exception closes access and remains retryable', (
    tester,
  ) async {
    platform.failLoad = true;
    final active = session();
    await pump(tester, child: WebDashboardPage(session: active));
    expect(active.isActive(), isFalse);
    expect(find.widgetWithText(FilledButton, 'Reload'), findsOneWidget);
    expect(
      find.text('The Core is not serving this dashboard.'),
      findsOneWidget,
    );
  });

  testWidgets('phone width keeps actions and content usable', (tester) async {
    await pump(tester, size: const Size(390, 844));
    expect(find.text('Not installed'), findsOneWidget);
    expect(find.byTooltip('Open in browser'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await menu(tester, 'Install dashboard');
    expect(action.calls, contains('install:zashboard'));
  });
}
