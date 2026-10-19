import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/web_dashboard/dashboard.dart';
import 'package:reclash/common/web_dashboard/installation.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/action.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/database.dart';
import 'package:reclash/providers/state.dart';
import 'package:reclash/providers/web_dashboard.dart';
import 'package:reclash/state.dart';
import 'package:riverpod/riverpod.dart';

import '../helpers/test_profiles.dart';

class _Store extends WebDashboardStore {
  _Store()
    : super(
        homeDirectory: () async => '',
        download:
            (
              uri,
              destination, {
              required onProgress,
              required cancelToken,
            }) async => null,
      );

  final installed = <WebDashboardFlavor, WebDashboardInstallation>{
    for (final flavor in WebDashboardFlavor.values)
      flavor: const WebDashboardInstallation(version: 'fixture'),
  };
  int downloads = 0;
  WebDashboardException? error;
  Completer<void>? installStarted;
  Completer<void>? installGate;

  @override
  Future<Map<WebDashboardFlavor, WebDashboardInstallation>>
  installations() async => Map.of(installed);

  @override
  Future<void> install(
    WebDashboardFlavor flavor, {
    required CancelToken cancelToken,
    required ValueChanged<WebDashboardProgress> onProgress,
    WebDashboardRelease? release,
  }) async {
    downloads++;
    onProgress(
      const WebDashboardProgress(
        WebDashboardPhase.downloading,
        received: 1,
        total: 10,
      ),
    );
    installStarted?.complete();
    final gate = installGate;
    if (gate != null) await Future.any([gate.future, cancelToken.whenCancel]);
    if (cancelToken.isCancelled) {
      throw const WebDashboardException(WebDashboardFailure.cancelled);
    }
    final failure = error;
    if (failure != null) throw failure;
    installed[flavor] = const WebDashboardInstallation(version: 'new');
  }

  @override
  Future<void> remove(WebDashboardFlavor flavor) async {
    installed.remove(flavor);
  }
}

class _Setup extends SetupAction {
  int preparations = 0;
  int syncs = 0;
  bool prepared = true;
  WebDashboardException? syncError;
  Completer<void>? started;
  Completer<bool>? gate;

  @override
  Future<bool> prepareWebDashboard() async {
    preparations++;
    started?.complete();
    if (gate != null) return gate!.future;
    return prepared;
  }

  @override
  Future<void> syncWebDashboardAccess() async {
    syncs++;
    final failure = syncError;
    if (failure != null) throw failure;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ProviderContainer container;
  late _Store store;
  late _Setup setup;
  late WebDashboardAction action;
  late bool safeMode;
  late Future<bool> Function(Uri) launch;
  late Future<void> Function(
    WebDashboardEndpoint,
    WebDashboardFlavor,
    CancelToken?,
  )
  probe;
  late List<Uri> launched;
  late List<WebDashboardEndpoint> endpoints;

  setUp(() {
    store = _Store();
    setup = _Setup();
    safeMode = false;
    launched = [];
    endpoints = [];
    launch = (_) async => true;
    probe = (_, _, _) async {};
    container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(TestProfiles.new),
        safeModeProvider.overrideWith((_) => safeMode),
        setupActionProvider.overrideWith(() => setup),
        webDashboardStoreProvider.overrideWithValue(store),
        webDashboardEnvironmentProvider.overrideWithValue(
          WebDashboardEnvironment(
            inApp: true,
            launchTimeout: const Duration(milliseconds: 50),
            launch: (uri) {
              launched.add(uri);
              return launch(uri);
            },
            probe:
                (
                  endpoint,
                  flavor, {
                  cancelToken,
                  timeout = const Duration(seconds: 5),
                }) {
                  endpoints.add(endpoint);
                  return probe(endpoint, flavor, cancelToken);
                },
          ),
        ),
      ],
    );
    globalState.container = container;
    container.listen(configProvider, (_, _) {}, fireImmediately: true);
    container.listen(updateParamsProvider, (_, _) {}, fireImmediately: true);
    container.read(initProvider.notifier).value = true;
    container.read(coreStatusProvider.notifier).value = CoreStatus.connected;
    container.read(currentProfileIdProvider.notifier).value = 1;
    action = container.read(webDashboardActionProvider.notifier);
  });

  tearDown(() async {
    action.cancel();
    final gate = setup.gate;
    if (gate != null && !gate.isCompleted) gate.complete(false);
    final installGate = store.installGate;
    if (installGate != null && !installGate.isCompleted) installGate.complete();
    await action.cancelAndWait();
    container.dispose();
  });

  WebDashboardAccessState access() =>
      container.read(webDashboardAccessProvider);
  Future<WebDashboardSession?> open({
    WebDashboardFlavor flavor = WebDashboardFlavor.zashboard,
    bool browser = false,
  }) => action.open(flavor, browser: browser);

  test(
    'embedded session changes only runtime parameters and closes with its owner',
    () async {
      final saved = container.read(configProvider);
      final session = await open();
      expect(session, isNotNull);
      expect(access().temporarySecret, hasLength(32));
      expect(container.read(configProvider), saved);
      expect(
        container.read(updateParamsProvider).externalController,
        ExternalControllerStatus.open,
      );
      expect(
        container.read(updateParamsProvider).secret,
        access().temporarySecret,
      );
      expect(endpoints.single.controller.host, '127.0.0.1');
      expect(launched, isEmpty);
      await session!.close();
      expect(session.isActive(), isFalse);
      expect(access().temporarySecret, isEmpty);
      expect(
        container.read(updateParamsProvider).externalController,
        ExternalControllerStatus.close,
      );
      expect(container.read(configProvider), saved);
    },
  );

  test(
    'saved external controller and secret survive session closure',
    () async {
      container
          .read(patchClashConfigProvider.notifier)
          .value = const PatchClashConfig(
        externalController: ExternalControllerStatus.open,
        secret: 'saved-secret',
      );
      final saved = container.read(configProvider);
      final session = await open();
      expect(session, isNotNull);
      expect(access().temporarySecret, isEmpty);
      expect(endpoints.single.secret, 'saved-secret');
      await session!.close();
      expect(container.read(configProvider), saved);
      expect(
        container.read(updateParamsProvider).externalController,
        ExternalControllerStatus.open,
      );
      expect(container.read(updateParamsProvider).secret, 'saved-secret');
    },
  );

  test(
    'browser ownership survives page close until explicitly ended',
    () async {
      final session = await open(browser: true);
      expect(launched.single, session!.uri);
      expect(access().browser, isTrue);
      await session.close();
      expect(session.isActive(), isTrue);
      await action.endAccess();
      expect(session.isActive(), isFalse);
      expect(access().temporarySecret, isEmpty);
      expect(
        container.read(updateParamsProvider).externalController,
        ExternalControllerStatus.close,
      );
    },
  );

  test(
    'browser handoff retains the same owner without another apply or download',
    () async {
      final session = (await open())!;
      expect(await action.openInBrowser(session), isTrue);
      expect(access().owners.keys, [session.owner]);
      expect(access().browser, isTrue);
      expect(setup.preparations, 1);
      expect(store.downloads, 0);
      await session.close();
      expect(session.isActive(), isTrue);
      await action.endAccess();
    },
  );

  test(
    'closing an older session does not close a newer dashboard owner',
    () async {
      final old = (await open())!;
      final secret = access().temporarySecret;
      final next = (await open(flavor: WebDashboardFlavor.metacubexd))!;
      expect(access().temporarySecret, secret);
      await old.close();
      await old.close();
      expect(next.isActive(), isTrue);
      expect(access().temporarySecret, secret);
      expect(store.downloads, 0);
      await next.close();
      expect(access().active, isFalse);
    },
  );

  test('removing one dashboard ends only its own sessions', () async {
    final first = (await open(browser: true))!;
    final second = (await open(
      flavor: WebDashboardFlavor.metacubexd,
      browser: true,
    ))!;
    expect(await action.remove(WebDashboardFlavor.zashboard), isTrue);
    expect(first.isActive(), isFalse);
    expect(second.isActive(), isTrue);
    expect(store.installed.keys, [WebDashboardFlavor.metacubexd]);
  });

  test(
    'explicit controller close ends the session without fighting user settings',
    () async {
      container
          .read(patchClashConfigProvider.notifier)
          .value = const PatchClashConfig(
        externalController: ExternalControllerStatus.open,
        secret: 'saved',
      );
      final session = (await open())!;
      container.read(patchClashConfigProvider.notifier).value =
          const PatchClashConfig();
      await container.pump();
      expect(session.isActive(), isFalse);
      expect(
        container.read(updateParamsProvider).externalController,
        ExternalControllerStatus.close,
      );
      expect(container.read(patchClashConfigProvider).secret, isEmpty);
    },
  );

  test('Core disconnect and profile removal revoke runtime access', () async {
    final first = (await open())!;
    container.read(coreStatusProvider.notifier).value = CoreStatus.disconnected;
    await container.pump();
    expect(first.isActive(), isFalse);
    container.read(coreStatusProvider.notifier).value = CoreStatus.connected;
    final second = (await open())!;
    container.read(currentProfileIdProvider.notifier).value = null;
    await container.pump();
    expect(second.isActive(), isFalse);
    expect(access().temporarySecret, isEmpty);
  });

  test('Safe Mode refuses download, apply, probe and launch', () async {
    safeMode = true;
    container.invalidate(safeModeProvider);
    store.installed.clear();
    expect(await open(browser: true), isNull);
    expect(
      container.read(webDashboardActionProvider).failure,
      WebDashboardFailure.safeMode,
    );
    expect(store.downloads, 0);
    expect(setup.preparations, 0);
    expect(endpoints, isEmpty);
    expect(launched, isEmpty);
    expect(access().active, isFalse);
  });

  test('entering Safe Mode revokes an existing session', () async {
    final session = (await open(browser: true))!;
    safeMode = true;
    container.invalidate(safeModeProvider);
    await container.pump();
    expect(session.isActive(), isFalse);
    expect(access().temporarySecret, isEmpty);
    expect(
      container.read(updateParamsProvider).externalController,
      ExternalControllerStatus.close,
    );
  });

  test(
    'uninitialized, disconnected and missing-profile states refuse to open',
    () async {
      container.read(initProvider.notifier).value = false;
      expect(await open(), isNull);
      expect(
        container.read(webDashboardActionProvider).failure,
        WebDashboardFailure.coreUnavailable,
      );
      container.read(initProvider.notifier).value = true;
      container.read(coreStatusProvider.notifier).value =
          CoreStatus.disconnected;
      expect(await open(), isNull);
      expect(
        container.read(webDashboardActionProvider).failure,
        WebDashboardFailure.coreUnavailable,
      );
      container.read(coreStatusProvider.notifier).value = CoreStatus.connected;
      container.read(currentProfileIdProvider.notifier).value = null;
      expect(await open(), isNull);
      expect(
        container.read(webDashboardActionProvider).failure,
        WebDashboardFailure.noProfile,
      );
      expect(setup.preparations, 0);
    },
  );

  test('first open installs only the selected dashboard', () async {
    store.installed.remove(WebDashboardFlavor.zashboard);
    final session = await open();
    expect(session, isNotNull);
    expect(store.downloads, 1);
    expect(store.installed[WebDashboardFlavor.zashboard]!.version, 'new');
    expect(store.installed[WebDashboardFlavor.metacubexd]!.version, 'fixture');
    expect(container.read(webDashboardActionProvider).progress, isNull);
  });

  for (final reason in [
    WebDashboardFailure.apply,
    WebDashboardFailure.authentication,
    WebDashboardFailure.unreachable,
    WebDashboardFailure.launch,
  ]) {
    test(
      '${reason.name} failure releases only the unsuccessful opening',
      () async {
        final existing = (await open(flavor: WebDashboardFlavor.metacubexd))!;
        switch (reason) {
          case WebDashboardFailure.apply:
            setup.prepared = false;
          case WebDashboardFailure.launch:
            launch = (_) async => false;
          default:
            probe = (_, _, _) async => throw WebDashboardException(reason);
        }
        expect(await open(browser: true), isNull);
        expect(container.read(webDashboardActionProvider).failure, reason);
        expect(existing.isActive(), isTrue);
        expect(access().owners.keys, [existing.owner]);
        expect(container.read(webDashboardActionProvider).busy, isFalse);
        expect(container.read(webDashboardActionProvider).progress, isNull);
      },
    );
  }

  test('a failed live patch releases runtime access', () async {
    setup.syncError = const WebDashboardException(WebDashboardFailure.apply);
    expect(await open(), isNull);
    expect(access().active, isFalse);
    expect(
      container.read(webDashboardActionProvider).failure,
      WebDashboardFailure.apply,
    );
  });

  test(
    'a browser launch exception and deadline both release ownership',
    () async {
      launch = (_) async => throw StateError('launcher failed');
      expect(await open(browser: true), isNull);
      expect(access().active, isFalse);
      expect(
        container.read(webDashboardActionProvider).failure,
        WebDashboardFailure.launch,
      );
      final gate = Completer<bool>();
      addTearDown(() {
        if (!gate.isCompleted) gate.complete(false);
      });
      launch = (_) => gate.future;
      expect(await open(browser: true), isNull);
      expect(access().active, isFalse);
      expect(
        container.read(webDashboardActionProvider).failure,
        WebDashboardFailure.launch,
      );
    },
  );

  test('failed browser handoff closes the original embedded session', () async {
    final session = (await open())!;
    launch = (_) async => false;
    expect(await action.openInBrowser(session), isFalse);
    expect(session.isActive(), isFalse);
    expect(access().active, isFalse);
  });

  test(
    'concurrent open is refused and cancelled apply cannot resurrect access',
    () async {
      setup.started = Completer<void>();
      setup.gate = Completer<bool>();
      final pending = open();
      await setup.started!.future;
      expect(await open(), isNull);
      expect(setup.preparations, 1);
      await action.cancelAndWait();
      expect(await pending, isNull);
      expect(access().active, isFalse);
      setup.gate!.complete(true);
      setup.gate = null;
      setup.started = null;
      final next = (await open())!;
      await container.pump();
      expect(next.isActive(), isTrue);
      expect(access().owners.keys, [next.owner]);
    },
  );

  test(
    'cancelled probe closes its token and never reaches the browser',
    () async {
      final entered = Completer<void>();
      CancelToken? probing;
      probe = (_, _, token) async {
        probing = token;
        entered.complete();
        await token!.whenCancel;
        throw const WebDashboardException(WebDashboardFailure.cancelled);
      };
      final pending = open(browser: true);
      await entered.future;
      await action.cancelAndWait();
      expect(await pending, isNull);
      expect(probing!.isCancelled, isTrue);
      expect(launched, isEmpty);
      expect(access().active, isFalse);
      expect(container.read(webDashboardActionProvider).failure, isNull);
    },
  );

  test('disposal during opening revokes its owner', () async {
    setup.started = Completer<void>();
    setup.gate = Completer<bool>();
    final pending = open();
    await setup.started!.future;
    container.invalidate(webDashboardActionProvider);
    await container.pump();
    expect(await pending, isNull);
    expect(access().active, isFalse);
    setup.gate!.complete(false);
  });

  test(
    'cancelled installation clears busy and progress before subsequent work',
    () async {
      store.installed.clear();
      store.installStarted = Completer<void>();
      store.installGate = Completer<void>();
      final pending = action.install(WebDashboardFlavor.zashboard);
      await store.installStarted!.future;
      expect(container.read(webDashboardActionProvider).busy, isTrue);
      expect(container.read(webDashboardActionProvider).progress, isNotNull);
      await action.cancelAndWait();
      expect(await pending, isFalse);
      expect(container.read(webDashboardActionProvider).busy, isFalse);
      expect(container.read(webDashboardActionProvider).progress, isNull);
      expect(container.read(webDashboardActionProvider).failure, isNull);
    },
  );
}
