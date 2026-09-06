import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/common/window.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/bootstrap.dart';
import 'package:reclash/common/system_dns.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/manager/hotkey_manager.dart';
import 'package:reclash/manager/manager.dart';
import 'package:reclash/plugins/app.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pages/pages.dart';

Widget buildManagerStack({
  required bool isDesktop,
  required Future<void> Function(List<ConnectivityResult> results)
  onConnectivityChanged,
  required Widget child,
}) {
  final platformApp = isDesktop
      ? WindowHeaderContainer(child: child)
      : VpnManager(child: child);
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

  final _pageTransitionsTheme = const PageTransitionsTheme(
    builders: <TargetPlatform, PageTransitionsBuilder>{
      TargetPlatform.android: commonSharedXPageTransitions,
      TargetPlatform.windows: commonSharedXPageTransitions,
      TargetPlatform.linux: commonSharedXPageTransitions,
      TargetPlatform.macOS: commonSharedXPageTransitions,
    },
  );

  ColorScheme _getAppColorScheme({required Brightness brightness}) {
    return ref.read(genColorSchemeProvider(brightness));
  }

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
      _autoUpdateProfilesTask();
      _initLink();
      unawaited(app?.initShortcuts());
    });
  }

  void _initLink() {
    final color = context.colorScheme.primary;
    linkManager.initAppLinksListen((uri) async {
      final command = parseReClashCommand(uri);
      if (command != null) {
        await _handleReClashCommand(command);
        return;
      }
      final link = parseIncomingLink(uri);
      if (link == null) return;
      unawaited(window?.show());
      ResolvedExternalLink? resolved;
      try {
        resolved = await resolveExternalLink(link.payload);
      } on IncyLinkException catch (e) {
        await dialogs.showMessage(
          title: currentAppLocalizations.addProfile,
          message: TextSpan(text: e.message),
        );
        return;
      }
      final target = resolved?.url ?? link.payload;
      final content = target.isEmpty ? resolved?.data : null;
      final full = target.isEmpty ? link.payload : target;
      await _confirmAddProfile(
        source: full,
        name: resolved?.name ?? link.name,
        target: target,
        content: content,
        preset: resolved?.preset ?? SubscriptionClient.auto,
        color: color,
      );
    });
  }

  Future<void> _handleReClashCommand(IncomingCommand command) async {
    final action = ref.read(systemActionProvider.notifier);
    switch (command.command) {
      case ReClashCommand.connect:
        await ref
            .read(setupActionProvider.notifier)
            .setRunning(true, initialize: true);
      case ReClashCommand.disconnect:
        await ref.read(setupActionProvider.notifier).setRunning(false);
      case ReClashCommand.toggle:
        ref.read(commonActionProvider.notifier).toggleRunning();
      case ReClashCommand.open:
        await window?.show();
      case ReClashCommand.close:
        await action.handleClose();
      case ReClashCommand.importProfile:
        final payload = command.payload!;
        final importColor = context.colorScheme.primary;
        String content;
        try {
          content = utf8.decode(base64Decode(payload));
        } on FormatException {
          await dialogs.showMessage(
            title: currentAppLocalizations.addProfile,
            message: TextSpan(
              text: currentAppLocalizations.urlSchemeImportInvalid,
            ),
          );
          return;
        }
        await window?.show();
        await _confirmAddProfile(
          source: content,
          name: null,
          target: '',
          content: content,
          preset: SubscriptionClient.auto,
          color: importColor,
        );
      case ReClashCommand.addProfile:
        final addColor = context.colorScheme.primary;
        await window?.show();
        await _confirmAddProfile(
          source: command.payload!,
          name: null,
          target: command.payload!,
          content: null,
          preset: SubscriptionClient.auto,
          color: addColor,
        );
    }
  }

  Future<void> _confirmAddProfile({
    required String source,
    required String? name,
    required String target,
    required String? content,
    required SubscriptionClient preset,
    required Color color,
  }) async {
    // A share link or an inlined config can be arbitrarily long.
    final trimmed = source.length > 120 ? '${source.substring(0, 119)}…' : source;
    final message = currentAppLocalizations.createProfileFromUrlTip(trimmed);
    final parts = message.split(trimmed);
    final res = await dialogs.showMessage(
      title: currentAppLocalizations.addProfile,
      message: TextSpan(
        children: [
          TextSpan(text: parts.first),
          TextSpan(
            text: trimmed,
            style: TextStyle(
              color: color,
              decoration: TextDecoration.underline,
              decorationColor: color,
            ),
          ),
          if (parts.length > 1) TextSpan(text: parts.last),
        ],
      ),
    );
    if (res != true) return;
    final action = ref.read(profilesActionProvider.notifier);
    if (content != null) {
      unawaited(action.addProfileFromLocalContent(content));
      return;
    }
    unawaited(
      action.addProfileFormURL(target, client: preset, name: name),
    );
  }

  void _autoUpdateProfilesTask() {
    _autoUpdateProfilesTaskTimer = Timer(const Duration(minutes: 20), () async {
      await ref.read(profilesActionProvider.notifier).autoUpdateProfiles();
      if (!mounted) {
        return;
      }
      _autoUpdateProfilesTask();
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
      ref.read(checkIpNumProvider.notifier).add();
    }
    _preHasVpn = hasVpn;
  }

  @override
  Widget build(context) {
    return Consumer(
      builder: (_, ref, child) {
        final locale = ref.watch(
          appSettingProvider.select((state) => state.locale),
        );
        final themeProps = ref.watch(effectiveThemePropsProvider);
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: globalState.navigatorKey,
          onNavigationNotification: (_) => true,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          builder: (_, child) {
            // ignore: deprecated_member_use
            return MaterialUiCompatibilityBridge(
              child: buildManagerStack(
                isDesktop: system.isDesktop,
                onConnectivityChanged: _handleConnectivityChanged,
                child: child!,
              ),
            );
          },
          scrollBehavior: const BaseScrollBehavior(),
          title: appName,
          locale: getLocaleForString(locale),
          supportedLocales: AppLocalizations.delegate.supportedLocales,
          themeMode: ref.watch(effectiveThemeModeProvider),
          theme: ThemeData(
            useMaterial3: true,
            pageTransitionsTheme: _pageTransitionsTheme,
            colorScheme: _getAppColorScheme(brightness: Brightness.light),
          ).withAppShapes,
          darkTheme: ThemeData(
            useMaterial3: true,
            pageTransitionsTheme: _pageTransitionsTheme,
            colorScheme: _getAppColorScheme(
              brightness: Brightness.dark,
            ).toPureBlack(themeProps.pureBlack),
          ).withAppShapes,
          home: child!,
        );
      },
      child: const HomePage(),
    );
  }

  @override
  void dispose() {
    linkManager.destroy();
    _autoUpdateProfilesTaskTimer?.cancel();
    super.dispose();
  }
}
