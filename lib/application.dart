import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/bootstrap.dart';
import 'package:reclash/common/system_dns.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/manager/hotkey_manager.dart';
import 'package:reclash/manager/manager.dart';
import 'package:reclash/models/profile.dart';
import 'package:reclash/plugins/app.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/providers/setup.dart';
import 'package:reclash/widgets/wallpaper.dart';
import 'package:reclash/views/proxies/routing_import.dart';
import 'package:reclash/views/setup.dart';
import 'package:reclash/state.dart';
import 'package:reclash/subscriptions/compatibility/policy.dart';
import 'package:reclash/subscriptions/transport/transport.dart';
import 'package:reclash/widgets/profile_import_dialog.dart';
import 'package:reclash/widgets/url_scheme_labels.dart';
import 'package:reclash/ui/ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pages/pages.dart';

Widget buildManagerStack({
  required bool isDesktop,
  required Future<void> Function(List<ConnectivityResult> results)
  onConnectivityChanged,
  Stream<ProcessSignal>? terminateSignals,
  required Widget child,
}) {
  final appChild = AppWallpaperScope(child: child);
  final platformApp = isDesktop
      ? WindowHeaderContainer(child: appChild)
      : VpnManager(child: appChild);
  final state = AppStateManager(
    child: CoreManager(
      child: ConnectivityManager(
        onConnectivityChanged: onConnectivityChanged,
        child: platformApp,
      ),
    ),
  );
  final platformState = isDesktop
      ? WindowManager(
          terminateSignals: terminateSignals,
          child: TrayManager(
            child: HotKeyManager(child: ProxyManager(child: state)),
          ),
        )
      : AndroidManager(child: TileManager(child: state));
  return AppEnvManager(
    child: LocaleManager(
      child: StatusManager(child: ThemeManager(child: platformState)),
    ),
  );
}

class Application extends ConsumerStatefulWidget {
  const Application({super.key});

  @override
  ConsumerState<Application> createState() => ApplicationState();
}

class ApplicationState extends ConsumerState<Application> {
  Timer? _autoUpdateProfilesTaskTimer;
  bool _preHasVpn = false;
  // Windows can only watch SIGINT and SIGHUP.
  final _terminateSignals = system.isDesktop && !system.isWindows
      ? ProcessSignal.sigterm.watch()
      : null;

  @override
  void initState() {
    super.initState();
    SystemNavigator.setFrameworkHandlesBack(true);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (globalState.navigatorKey.currentContext != null) {
        await bootstrap.attach();
      } else {
        exit(0);
      }
      if (!ref.read(setupSessionProvider).active) _autoUpdateProfilesTask();
      _initLink();
      if (!safeModeBuild) {
        unawaited(app?.initShortcuts());
      }
    });
  }

  void _initLink() {
    unawaited(
      linkManager.initAppLinksListen(
        _handleLink,
        onError: () {
          if (mounted) {
            dialogs.showNotifier(
              currentAppLocalizations.urlSchemeDeliveryError,
            );
          }
        },
      ),
    );
  }

  Future<void> _handleLink(String input) async {
    if (!mounted) return;
    try {
      await ref
          .read(urlSchemeActionProvider.notifier)
          .handleLink(
            input,
            isCurrent: () => mounted,
            confirmCommand: (action) async =>
                await dialogs.showMessage(
                  title: currentAppLocalizations.urlSchemeConfirmTitle,
                  confirmText: urlSchemeCommandLabel(
                    action,
                    currentAppLocalizations,
                  ),
                  destructive: action == ReClashCommand.close,
                  message: TextSpan(
                    text: currentAppLocalizations.urlSchemeConfirmMessage(
                      urlSchemeCommandLabel(action, currentAppLocalizations),
                    ),
                  ),
                ) ==
                true,
            confirmImport: (source) {
              final profiles = ref.read(profilesActionProvider.notifier);
              return showProfileImportDialog(
                source,
                preview: profiles.previewProfileLinkSource,
                duplicateOf: profiles.duplicateProfileLabel(source),
              );
            },
            openRouting: (text, origin) =>
                openRoutingImport(context, text: text, origin: origin),
          );
    } catch (error) {
      if (!mounted) return;
      if (error is SubscriptionException) {
        if (error.failure == SubscriptionFailure.cancelled ||
            error.failure == SubscriptionFailure.superseded) {
          return;
        }
        await dialogs.showSubscriptionFailure(error);
        return;
      }
      if (error is SubscriptionUpdateRejected) {
        if (error.reason == SubscriptionRetryReason.cancelled) return;
        await dialogs.showSubscriptionFailure(error);
        return;
      }
      await dialogs.showMessage(
        title: currentAppLocalizations.urlScheme,
        message: TextSpan(
          text: userFacingErrorMessage(error, currentAppLocalizations),
        ),
        cancelable: false,
      );
    }
  }

  void _autoUpdateProfilesTask() {
    _autoUpdateProfilesTaskTimer = Timer(const Duration(minutes: 20), () async {
      try {
        if (!ref.read(setupSessionProvider).active) {
          await ref.read(profilesActionProvider.notifier).autoUpdateProfiles();
          await ref.read(resourcesActionProvider.notifier).autoUpdate();
        }
      } catch (e) {
        commonPrint.log('autoUpdate failed: $e');
      } finally {
        if (mounted) _autoUpdateProfilesTask();
      }
    });
  }

  Future<void> _handleConnectivityChanged(
    List<ConnectivityResult> results,
  ) async {
    commonPrint.log('connectivityChanged ${results.toString()}');
    unawaited(systemDnsCoordinator?.resync() ?? Future.value());
    unawaited(ref.read(systemActionProvider.notifier).updateLocalIp());
    final hasVpn = results.contains(ConnectivityResult.vpn);
    if (_preHasVpn == hasVpn) {
      ref.read(routeTrackerProvider.notifier).bumpHostEpoch();
      // Android's NetworkObserver tells the Core about a new network itself.
      if (system.isDesktop) {
        debouncer.call(
          FunctionTag.clearDnsCache,
          ref.read(coreActionProvider.notifier).clearDnsCacheOnNetworkChange,
          duration: const Duration(milliseconds: 200),
        );
      }
    }
    _preHasVpn = hasVpn;
  }

  @override
  Widget build(context) {
    ref.listen(setupSessionProvider.select((state) => state.active), (
      previous,
      active,
    ) {
      if (previous == true && !active) {
        unawaited(bootstrap.completeSetup());
        _autoUpdateProfilesTaskTimer?.cancel();
        _autoUpdateProfilesTask();
      }
    });
    return Consumer(
      builder: (_, ref, child) {
        final locale = ref.watch(
          appSettingProvider.select((state) => state.locale),
        );
        final themeMode = ref.watch(
          themeSettingProvider.select((state) => state.themeMode),
        );
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: globalState.navigatorKey,
          onNavigationNotification: (_) => true,
          localizationsDelegates: [
            AppLocalizations.delegate,
            AppUiLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
            ...fallbackMaterialLocalizationsDelegates,
          ],
          builder: (context, child) {
            return ThemeCrossFade(
              child: buildManagerStack(
                isDesktop: system.isDesktop,
                onConnectivityChanged: _handleConnectivityChanged,
                terminateSignals: _terminateSignals,
                child: RemoteFocusAdapter(
                  enabled: system.isTV,
                  floatingKeyboard: app?.floatingKeyboard,
                  child: child!,
                ),
              ),
            );
          },
          scrollBehavior: const BaseScrollBehavior(),
          title: appName,
          locale: getLocaleForString(locale),
          supportedLocales: AppLocalizations.delegate.supportedLocales,
          themeMode: themeMode,
          theme: watchAppTheme(ref, Brightness.light),
          darkTheme: watchAppTheme(ref, Brightness.dark),
          themeAnimationStyle: AnimationStyle.noAnimation,
          home: const KeyboardInsetHold(child: ApplicationRoot()),
        );
      },
    );
  }

  @override
  void dispose() {
    linkManager.destroy();
    _autoUpdateProfilesTaskTimer?.cancel();
    super.dispose();
  }
}

class ApplicationRoot extends ConsumerWidget {
  const ApplicationRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      ref.watch(setupSessionProvider.select((state) => state.active))
      ? const SetupWizard()
      : const HomePage();
}
