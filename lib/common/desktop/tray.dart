import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart';
import 'package:tray/tray.dart';

import '../app/app_localizations.dart';
import '../app/app_ports.dart';
import '../app/l10n_labels.dart';
import '../net/proxy.dart';
import '../ui/keyboard.dart';
import '../util/constant.dart';
import '../util/provider_reader.dart';
import 'system.dart';
import 'window.dart';

class AppTray implements TrayPort {
  static AppTray? _instance;

  final bool isMacOS;
  final bool isWindows;
  final Future<void> Function(String title) _setTitle;
  final Future<void> Function(Brightness brightness) _setMenuBrightness;

  bool _isShutDown = false;
  String? _lastTrayTitle;
  Brightness? _lastMenuBrightness;

  AppTray._internal({
    required this.isMacOS,
    required this.isWindows,
    required Future<void> Function(String title) setTitle,
    required Future<void> Function(Brightness brightness) setMenuBrightness,
  }) : _setTitle = setTitle,
       _setMenuBrightness = setMenuBrightness;

  factory AppTray() {
    _instance ??= AppTray._internal(
      isMacOS: system.isMacOS,
      isWindows: system.isWindows,
      setTitle: (title) async {
        await Tray.instance.setTitle(title);
      },
      setMenuBrightness: _defaultSetMenuBrightness,
    );
    return _instance!;
  }

  @visibleForTesting
  factory AppTray.forPlatform({
    required bool isMacOS,
    required bool isWindows,
    Future<void> Function(String title)? setTitle,
    Future<void> Function(Brightness brightness)? setMenuBrightness,
  }) {
    return AppTray._internal(
      isMacOS: isMacOS,
      isWindows: isWindows,
      setTitle:
          setTitle ??
          (title) async {
            await Tray.instance.setTitle(title);
          },
      setMenuBrightness: setMenuBrightness ?? _defaultSetMenuBrightness,
    );
  }

  static const MethodChannel _trayChannel = MethodChannel('tray');

  static Future<void> _defaultSetMenuBrightness(Brightness brightness) async {
    await _trayChannel.invokeMethod('setMenuBrightness', <String, Object?>{
      'brightness': brightness.name,
    });
  }

  String get _trayIconSuffix {
    return isWindows ? 'ico' : 'png';
  }

  String get _trayIconDir {
    return isWindows ? 'assets/images/tray/windows' : 'assets/images/tray/unix';
  }

  String getTrayIcon({
    required bool isStart,
    required bool tunEnable,
    required bool paused,
  }) {
    // A paused core still runs unprotected traffic, matching a disabled TUN.
    final status = switch ((isMacOS || !isStart, paused || !tunEnable)) {
      (true, _) => 1,
      (false, false) => 3,
      (false, true) => 2,
    };
    return '$_trayIconDir/status_$status.$_trayIconSuffix';
  }

  @override
  Future<void> shutdown() async {
    _isShutDown = true;
    _lastTrayTitle = null;
    _lastMenuBrightness = null;
    await Tray.instance.hide();
  }

  @override
  Future<void> update({
    required TrayState trayState,
    required Traffic traffic,
    required ProviderReader read,
  }) async {
    if (_isShutDown) {
      return;
    }
    if (isWindows) {
      final brightness = read(currentBrightnessProvider);
      if (_lastMenuBrightness != brightness) {
        await _setMenuBrightness(brightness);
        _lastMenuBrightness = brightness;
      }
    }
    await Tray.instance.show(
      TraySpec(
        icon: TrayIcon.asset(
          getTrayIcon(
            isStart: trayState.isStart,
            tunEnable: trayState.tunEnable,
            paused: trayState.paused,
          ),
          isTemplate: isMacOS,
        ),
        toolTip: appName,
        menu: _buildMenu(trayState: trayState, read: read),
      ),
    );
    await updateTitle(showTrayTitle: trayState.showTrayTitle, traffic: traffic);
  }

  Future<void> updateTitle({
    required bool showTrayTitle,
    required Traffic traffic,
  }) async {
    if (_isShutDown || !isMacOS) {
      return;
    }
    final title = showTrayTitle ? traffic.trayTitle : '';
    if (_lastTrayTitle == title) {
      return;
    }
    await _setTitle(title);
    _lastTrayTitle = title;
  }

  List<TrayMenuItem> _buildMenu({
    required TrayState trayState,
    required ProviderReader read,
  }) {
    final commonAction = read(commonActionProvider.notifier);
    final systemAction = read(systemActionProvider.notifier);
    final setupAction = read(setupActionProvider.notifier);
    final appLocalizations = currentAppLocalizations;

    return [
      TrayMenuAction(
        label: appLocalizations.show,
        detail: _shortcut(trayState, HotAction.view),
        onSelected: () {
          window?.show();
        },
      ),
      TrayMenuCheckbox(
        label: trayState.isStart
            ? appLocalizations.stop
            : appLocalizations.start,
        checked: false,
        detail: _shortcut(trayState, HotAction.start),
        onSelected: commonAction.toggleRunning,
      ),
      if (trayState.isStart && (trayState.tunEnable || trayState.paused))
        TrayMenuCheckbox(
          label: trayState.paused
              ? appLocalizations.resume
              : appLocalizations.pause,
          checked: trayState.paused,
          onSelected: commonAction.togglePaused,
        ),
      if (isMacOS)
        TrayMenuCheckbox(
          label: appLocalizations.speedStatistics,
          checked: trayState.showTrayTitle,
          onSelected: commonAction.updateSpeedStatistics,
        ),
      const TrayMenuSeparator(),
      for (final mode in Mode.values)
        TrayMenuCheckbox(
          label: mode.label,
          checked: mode == trayState.mode,
          detail: _shortcut(trayState, _modeHotAction(mode)),
          onSelected: () {
            setupAction.changeMode(mode);
          },
        ),
      const TrayMenuSeparator(),
      if (isMacOS) ..._buildGroupMenu(trayState: trayState, read: read),
      if (trayState.isStart) ...[
        TrayMenuCheckbox(
          label: appLocalizations.tun,
          checked: trayState.tunEnable,
          detail: _shortcut(trayState, HotAction.tun),
          onSelected: systemAction.updateTun,
        ),
        TrayMenuCheckbox(
          label: appLocalizations.systemProxy,
          checked: trayState.systemProxy,
          detail: _shortcut(trayState, HotAction.proxy),
          onSelected: systemAction.updateSystemProxy,
        ),
        const TrayMenuSeparator(),
      ],
      TrayMenuCheckbox(
        label: appLocalizations.autoLaunch,
        checked: trayState.autoLaunch,
        onSelected: systemAction.updateAutoLaunch,
      ),
      TrayMenuAction(
        label: appLocalizations.copyEnvVar,
        detail: _shortcut(trayState, HotAction.copyEnv),
        onSelected: () {
          _copyEnv(trayState.port);
        },
      ),
      const TrayMenuSeparator(),
      TrayMenuAction(
        label: appLocalizations.exit,
        detail: _shortcut(trayState, HotAction.exit),
        onSelected: () {
          systemAction.handleExit();
        },
      ),
    ];
  }

  HotAction _modeHotAction(Mode mode) {
    return switch (mode) {
      Mode.rule => HotAction.ruleMode,
      Mode.global => HotAction.globalMode,
      Mode.direct => HotAction.directMode,
    };
  }

  String? _shortcut(TrayState trayState, HotAction action) {
    final hotKeyAction = trayState.hotKeys[action];
    if (hotKeyAction == null) {
      return null;
    }
    return hotKeyLabel(hotKeyAction.key, hotKeyAction.modifiers);
  }

  List<TrayMenuItem> _buildGroupMenu({
    required TrayState trayState,
    required ProviderReader read,
  }) {
    if (trayState.groups.isEmpty) {
      return const [];
    }
    return [
      for (final group in trayState.groups)
        TrayMenuSubmenu(
          label: groupDisplayName(group.name),
          items: [
            for (final proxy in group.all)
              TrayMenuCheckbox(
                label: proxy.name,
                checked:
                    read(selectedProxyNameProvider(group.name)) == proxy.name,
                onSelected: () {
                  read(
                    proxiesActionProvider.notifier,
                  ).changeProxy(groupName: group.name, proxyName: proxy.name);
                },
              ),
          ],
        ),
      const TrayMenuSeparator(),
    ];
  }

  Future<void> _copyEnv(int port) async {
    await Clipboard.setData(
      ClipboardData(text: proxyEnvCommand(port, isWindows: isWindows)),
    );
  }
}

final appTray = system.isDesktop ? AppTray() : null;
