import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/common/web_dashboard/access.dart';
import 'package:reclash/common/web_dashboard/dashboard.dart';
import 'package:reclash/common/web_dashboard/installation.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/providers/action.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/config.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

part 'generated/web_dashboard.g.dart';

class WebDashboardEnvironment {
  const WebDashboardEnvironment({
    required this.inApp,
    required this.launch,
    this.probe = probeWebDashboard,
    this.launchTimeout = const Duration(seconds: 10),
  });

  final bool inApp;
  final Future<bool> Function(Uri uri) launch;
  final Duration launchTimeout;
  final Future<void> Function(
    WebDashboardEndpoint endpoint,
    WebDashboardFlavor flavor, {
    CancelToken? cancelToken,
    Duration timeout,
  })
  probe;
}

@Riverpod(keepAlive: true)
WebDashboardEnvironment webDashboardEnvironment(Ref ref) =>
    WebDashboardEnvironment(
      inApp:
          (system.isAndroid || system.isMacOS) &&
          WebViewPlatform.instance != null,
      launch: (uri) => launchUrl(uri, mode: LaunchMode.externalApplication),
    );

@Riverpod(keepAlive: true)
WebDashboardStore webDashboardStore(Ref ref) => WebDashboardStore(
  homeDirectory: () => appPath.homeDirPath,
  download: request.downloadUpdateFile,
);

class WebDashboardAccessState {
  const WebDashboardAccessState({
    this.temporarySecret = '',
    this.owners = const {},
  });

  final String temporarySecret;
  final Map<Object, ({WebDashboardFlavor flavor, bool browser})> owners;

  bool get active => owners.isNotEmpty;
  bool get browser => owners.values.any((value) => value.browser);

  @override
  String toString() => 'WebDashboardAccessState(sessions: ${owners.length})';
}

@Riverpod(keepAlive: true)
class WebDashboardAccess extends _$WebDashboardAccess {
  @override
  WebDashboardAccessState build() {
    ref.listen(
      patchClashConfigProvider.select(
        (config) => (config.externalController, config.secret),
      ),
      (previous, next) {
        if (previous != next && state.active) {
          end();
          unawaited(_sync());
        }
      },
    );
    ref.listen(coreStatusProvider, (_, next) {
      if (next != CoreStatus.connected) end();
    });
    ref.listen(safeModeProvider, (_, next) {
      if (next) {
        end();
        unawaited(_sync());
      }
    });
    ref.listen(currentProfileIdProvider, (_, next) {
      if (next == null) {
        end();
        unawaited(_sync());
      }
    });
    return const WebDashboardAccessState();
  }

  Object acquire(WebDashboardFlavor flavor) {
    final owner = Object();
    final config = ref.read(patchClashConfigProvider);
    final temporarySecret =
        config.externalController == ExternalControllerStatus.close
        ? state.temporarySecret.isEmpty
              ? generateRandomSecret(32)
              : state.temporarySecret
        : '';
    state = WebDashboardAccessState(
      temporarySecret: temporarySecret,
      owners: Map.unmodifiable({
        ...state.owners,
        owner: (flavor: flavor, browser: false),
      }),
    );
    return owner;
  }

  bool contains(Object owner) => ref.mounted && state.owners.containsKey(owner);

  void keepForBrowser(Object owner) {
    if (!contains(owner)) return;
    state = WebDashboardAccessState(
      temporarySecret: state.temporarySecret,
      owners: Map.unmodifiable({
        ...state.owners,
        owner: (flavor: state.owners[owner]!.flavor, browser: true),
      }),
    );
  }

  bool release(Object owner, {bool force = false}) {
    if (!contains(owner) || (!force && state.owners[owner]!.browser)) {
      return false;
    }
    final owners = Map.of(state.owners)..remove(owner);
    state = WebDashboardAccessState(
      temporarySecret: owners.isEmpty ? '' : state.temporarySecret,
      owners: Map.unmodifiable(owners),
    );
    return true;
  }

  void end({WebDashboardFlavor? flavor}) {
    if (!ref.mounted || !state.active) {
      return;
    }
    final owners = Map.of(state.owners)
      ..removeWhere((_, value) => flavor == null || value.flavor == flavor);
    state = WebDashboardAccessState(
      temporarySecret: owners.isEmpty ? '' : state.temporarySecret,
      owners: Map.unmodifiable(owners),
    );
  }

  Future<void> close(Object owner, {bool force = false}) async {
    if (release(owner, force: force)) {
      await _sync();
    }
  }

  Future<void> _sync() async {
    if (!ref.mounted || ref.read(coreStatusProvider) != CoreStatus.connected) {
      return;
    }
    try {
      await ref.read(setupActionProvider.notifier).syncWebDashboardAccess();
    } catch (_) {}
  }
}

class WebDashboardSession {
  WebDashboardSession({
    required this.owner,
    required this.flavor,
    required this.endpoint,
    required this.isActive,
    required this.close,
  });

  final Object owner;
  final WebDashboardFlavor flavor;
  final WebDashboardEndpoint endpoint;
  final bool Function() isActive;
  final Future<void> Function() close;

  Uri get uri => endpoint.uriFor(flavor);
}

class WebDashboardState {
  const WebDashboardState({
    this.loading = false,
    this.busy = false,
    this.installations = const {},
    this.progress,
    this.failure,
  });

  final bool loading;
  final bool busy;
  final Map<WebDashboardFlavor, WebDashboardInstallation> installations;
  final WebDashboardProgress? progress;
  final WebDashboardFailure? failure;
}

@Riverpod(keepAlive: true)
class WebDashboardAction extends _$WebDashboardAction {
  CancelToken? _operation;
  int _refreshRevision = 0;
  WebDashboardAccess? _openingAccess;
  Object? _openingOwner;
  Completer<void>? _done;

  @override
  WebDashboardState build() {
    ref.onDispose(() {
      _operation?.cancel();
      final access = _openingAccess;
      final owner = _openingOwner;
      if (access != null && owner != null) {
        scheduleMicrotask(() => unawaited(access.close(owner, force: true)));
      }
    });
    return const WebDashboardState(loading: true);
  }

  Future<void> refresh() async {
    if (state.busy) return;
    final revision = ++_refreshRevision;
    try {
      final installed = await ref
          .read(webDashboardStoreProvider)
          .installations();
      if (!ref.mounted || revision != _refreshRevision || state.busy) return;
      state = WebDashboardState(installations: installed);
    } catch (_) {
      if (ref.mounted && revision == _refreshRevision && !state.busy) {
        state = WebDashboardState(
          installations: state.installations,
          failure: WebDashboardFailure.storage,
        );
      }
    }
  }

  WebDashboardFailure? get unavailable {
    if (ref.read(safeModeProvider)) return WebDashboardFailure.safeMode;
    if (ref.read(coreStatusProvider) != CoreStatus.connected ||
        !ref.read(initProvider)) {
      return WebDashboardFailure.coreUnavailable;
    }
    if (ref.read(currentProfileIdProvider) == null) {
      return WebDashboardFailure.noProfile;
    }
    return null;
  }

  CancelToken _begin() {
    _refreshRevision++;
    final token = CancelToken();
    _operation = token;
    _done = Completer<void>();
    state = WebDashboardState(installations: state.installations, busy: true);
    return token;
  }

  void cancel() {
    _operation?.cancel();
    final owner = _openingOwner;
    if (owner != null) {
      unawaited(_openingAccess?.close(owner, force: true));
    }
  }

  Future<void> cancelAndWait() async {
    final done = _done;
    cancel();
    await done?.future;
  }

  Future<T> _wait<T>(Future<T> operation, CancelToken token) => Future.any([
    operation,
    token.whenCancel.then<T>(
      (_) => throw const WebDashboardException(WebDashboardFailure.cancelled),
    ),
  ]);

  void _check(CancelToken token) {
    if (!ref.mounted || token.isCancelled) {
      throw const WebDashboardException(WebDashboardFailure.cancelled);
    }
  }

  void _requireAvailable(CancelToken token) {
    _check(token);
    final failure = unavailable;
    if (failure != null) throw WebDashboardException(failure);
  }

  Future<void> _install(WebDashboardFlavor flavor, CancelToken token) async {
    await ref
        .read(webDashboardStoreProvider)
        .install(
          flavor,
          cancelToken: token,
          onProgress: (progress) {
            if (ref.mounted && !token.isCancelled) {
              state = WebDashboardState(
                installations: state.installations,
                busy: true,
                progress: progress,
              );
            }
          },
        );
  }

  Future<bool> install(WebDashboardFlavor flavor) async {
    if (state.busy) return false;
    final token = _begin();
    WebDashboardFailure? failure;
    try {
      await _install(flavor, token);
      return true;
    } catch (error) {
      failure = _failure(error);
      return false;
    } finally {
      await _finish(failure);
    }
  }

  Future<bool> remove(WebDashboardFlavor flavor) async {
    if (state.busy) return false;
    _begin();
    WebDashboardFailure? failure;
    try {
      ref.read(webDashboardAccessProvider.notifier).end(flavor: flavor);
      await _syncAccess();
      await ref.read(webDashboardStoreProvider).remove(flavor);
      return true;
    } catch (error) {
      failure = _failure(error);
      return false;
    } finally {
      await _finish(failure);
    }
  }

  Future<WebDashboardSession?> open(
    WebDashboardFlavor flavor, {
    required bool browser,
  }) async {
    if (state.busy) return null;
    final token = _begin();
    Object? owner;
    WebDashboardAccess? access;
    WebDashboardFailure? failure;
    var succeeded = false;
    try {
      _requireAvailable(token);
      final installed = await ref
          .read(webDashboardStoreProvider)
          .installations();
      if (!installed.containsKey(flavor)) await _install(flavor, token);
      _requireAvailable(token);
      final acquiredAccess = ref.read(webDashboardAccessProvider.notifier);
      access = acquiredAccess;
      owner = acquiredAccess.acquire(flavor);
      _openingAccess = access;
      _openingOwner = owner;
      final setup = ref.read(setupActionProvider.notifier);
      if (!await _wait(setup.prepareWebDashboard(), token)) {
        throw const WebDashboardException(WebDashboardFailure.apply);
      }
      _requireAvailable(token);
      if (!acquiredAccess.contains(owner)) {
        throw const WebDashboardException(WebDashboardFailure.cancelled);
      }
      await _wait(setup.syncWebDashboardAccess(), token);
      _requireAvailable(token);
      final config = webDashboardEffectiveConfig(
        ref.read(patchClashConfigProvider),
        temporarySecret: ref.read(webDashboardAccessProvider).temporarySecret,
        safeMode: ref.read(safeModeProvider),
      );
      if (!acquiredAccess.contains(owner) || config.secret.isEmpty) {
        throw const WebDashboardException(WebDashboardFailure.cancelled);
      }
      final endpoint = WebDashboardEndpoint(
        controller: Uri.parse('http://${config.externalController.value}'),
        secret: config.secret,
      );
      final environment = ref.read(webDashboardEnvironmentProvider);
      await _wait(
        environment.probe(endpoint, flavor, cancelToken: token),
        token,
      );
      _requireAvailable(token);
      if (!acquiredAccess.contains(owner)) {
        throw const WebDashboardException(WebDashboardFailure.cancelled);
      }
      final acquiredOwner = owner;
      final session = WebDashboardSession(
        owner: acquiredOwner,
        flavor: flavor,
        endpoint: endpoint,
        isActive: () => acquiredAccess.contains(acquiredOwner),
        close: () => acquiredAccess.close(acquiredOwner),
      );
      if (browser) {
        try {
          if (!await _wait(
            environment.launch(session.uri).timeout(environment.launchTimeout),
            token,
          )) {
            throw const WebDashboardException(WebDashboardFailure.launch);
          }
        } on WebDashboardException {
          rethrow;
        } catch (_) {
          throw const WebDashboardException(WebDashboardFailure.launch);
        }
        _check(token);
        if (!acquiredAccess.contains(owner)) {
          throw const WebDashboardException(WebDashboardFailure.cancelled);
        }
        acquiredAccess.keepForBrowser(owner);
      }
      succeeded = true;
      return session;
    } catch (error) {
      failure = _failure(error, fallback: WebDashboardFailure.unreachable);
      return null;
    } finally {
      if (!succeeded && owner != null) {
        await access?.close(owner, force: true);
      }
      _openingAccess = null;
      _openingOwner = null;
      await _finish(failure);
    }
  }

  Future<bool> openInBrowser(WebDashboardSession session) async {
    if (state.busy || !session.isActive()) {
      return false;
    }
    final token = _begin();
    final access = ref.read(webDashboardAccessProvider.notifier);
    _openingAccess = access;
    _openingOwner = session.owner;
    WebDashboardFailure? failure;
    var succeeded = false;
    try {
      _requireAvailable(token);
      final environment = ref.read(webDashboardEnvironmentProvider);
      if (!await _wait(
        environment.launch(session.uri).timeout(environment.launchTimeout),
        token,
      )) {
        throw const WebDashboardException(WebDashboardFailure.launch);
      }
      _requireAvailable(token);
      if (!session.isActive()) {
        throw const WebDashboardException(WebDashboardFailure.cancelled);
      }
      access.keepForBrowser(session.owner);
      succeeded = true;
      return true;
    } catch (error) {
      failure = _failure(error, fallback: WebDashboardFailure.launch);
      return false;
    } finally {
      if (!succeeded) {
        await access.close(session.owner, force: true);
      }
      _openingAccess = null;
      _openingOwner = null;
      await _finish(failure);
    }
  }

  Future<void> endAccess() async {
    cancel();
    ref.read(webDashboardAccessProvider.notifier).end();
    await _syncAccess();
  }

  Future<void> _syncAccess() async {
    if (!ref.mounted || ref.read(coreStatusProvider) != CoreStatus.connected) {
      return;
    }
    try {
      await ref.read(setupActionProvider.notifier).syncWebDashboardAccess();
    } catch (_) {
      if (ref.mounted) {
        state = WebDashboardState(
          installations: state.installations,
          busy: state.busy,
          failure: WebDashboardFailure.unreachable,
        );
      }
    }
  }

  Future<void> _finish(WebDashboardFailure? failure) async {
    final done = _done;
    WebDashboardState? next;
    try {
      if (!ref.mounted) return;
      var installed = state.installations;
      try {
        installed = await ref.read(webDashboardStoreProvider).installations();
      } catch (_) {
        failure ??= WebDashboardFailure.storage;
      }
      next = WebDashboardState(
        installations: installed,
        failure: failure == WebDashboardFailure.cancelled ? null : failure,
      );
    } finally {
      _operation = null;
      _done = null;
      if (ref.mounted && next != null) state = next;
      done?.complete();
    }
  }

  WebDashboardFailure _failure(
    Object error, {
    WebDashboardFailure fallback = WebDashboardFailure.storage,
  }) => error is WebDashboardException ? error.failure : fallback;
}
