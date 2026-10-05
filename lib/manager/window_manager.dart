import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/common/desktop/launch.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/config.dart';
import 'package:reclash/providers/providers.dart';
import 'package:window/window.dart';

const _windowGeometryDelay = Duration(milliseconds: 120);

class WindowManager extends ConsumerStatefulWidget {
  final Widget child;

  const WindowManager({super.key, required this.child});

  @override
  ConsumerState<WindowManager> createState() => _WindowContainerState();
}

class _WindowContainerState extends ConsumerState<WindowManager>
    with WindowListener {
  Timer? _windowGeometryTimer;
  int _windowGeometryRevision = 0;

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void initState() {
    super.initState();
    ref.listenManual(appSettingProvider.select((state) => state.autoLaunch), (
      prev,
      next,
    ) {
      if (prev != next) {
        debouncer.call(FunctionTag.autoLaunch, () {
          autoLaunch?.updateStatus(next);
        });
      }
    });
    desktopWindow.addListener(this);
  }

  @override
  void onWindowClose() async {
    await ref.read(systemActionProvider.notifier).handleClose();
    super.onWindowClose();
  }

  @override
  void onWindowFocus() {
    super.onWindowFocus();
    commonPrint.log('focus');
    render?.resume();
  }

  /// Another launch, or a Dock reopen, asked for the window; showing it from
  /// here keeps the render loop running before it becomes visible.
  @override
  void onWindowActivate() {
    super.onWindowActivate();
    unawaited(windowPort?.show());
  }

  @override
  Future<void> onWindowShouldTerminate() async {
    await ref.read(systemActionProvider.notifier).handleExit();
    super.onWindowShouldTerminate();
  }

  void _scheduleWindowGeometryCapture() {
    final revision = ++_windowGeometryRevision;
    _windowGeometryTimer?.cancel();
    _windowGeometryTimer = Timer(_windowGeometryDelay, () {
      _windowGeometryTimer = null;
      unawaited(_captureWindowGeometry(revision));
    });
  }

  Future<void> _captureWindowGeometry(int revision) async {
    final port = windowPort;
    if (port == null || !mounted) {
      return;
    }
    final current = ref.read(windowSettingProvider);
    WindowProps? geometry;
    try {
      geometry = await port.captureNormalGeometry(current);
    } catch (error) {
      commonPrint.log(
        'Window geometry capture failed: ${compactError(error)}',
        logLevel: LogLevel.warning,
      );
      return;
    }
    if (!mounted || revision != _windowGeometryRevision || geometry == null) {
      return;
    }
    ref.read(windowSettingProvider.notifier).value = geometry;
  }

  void _invalidateWindowGeometryCapture() {
    _windowGeometryRevision++;
    _windowGeometryTimer?.cancel();
    _windowGeometryTimer = null;
  }

  @override
  void onWindowGeometryChanged() {
    super.onWindowGeometryChanged();
    _scheduleWindowGeometryCapture();
  }

  @override
  void onWindowMaximize() {
    _invalidateWindowGeometryCapture();
    super.onWindowMaximize();
    if (system.isWindows) {
      unawaited(desktopWindow.setRoundedCorners(false));
    }
  }

  @override
  void onWindowUnmaximize() {
    super.onWindowUnmaximize();
    if (system.isWindows) {
      unawaited(desktopWindow.setRoundedCorners(true));
    }
    _scheduleWindowGeometryCapture();
  }

  @override
  void onWindowEnterFullScreen() {
    _invalidateWindowGeometryCapture();
    super.onWindowEnterFullScreen();
  }

  @override
  void onWindowLeaveFullScreen() {
    super.onWindowLeaveFullScreen();
    _scheduleWindowGeometryCapture();
  }

  @override
  void onWindowMinimize() async {
    _invalidateWindowGeometryCapture();
    ref.read(storeActionProvider.notifier).savePreferencesDebounce();
    commonPrint.log('minimize');
    _enterBackground();
    super.onWindowMinimize();
  }

  @override
  void onWindowRestore() {
    commonPrint.log('restore');
    _leaveBackground();
    super.onWindowRestore();
    _scheduleWindowGeometryCapture();
  }

  @override
  void onWindowHide() {
    _invalidateWindowGeometryCapture();
    commonPrint.log('hide');
    _enterBackground();
    super.onWindowHide();
  }

  @override
  void onWindowShow() {
    commonPrint.log('show');
    _leaveBackground();
    super.onWindowShow();
  }

  // Hiding to the tray and minimizing both leave no one watching, so they park
  // the same background consumers; show/restore resume them symmetrically.
  void _enterBackground() {
    render?.pause();
    ref.read(routeTrackerProvider.notifier).setVisible(false);
    ref.read(setupActionProvider.notifier).setVisible(false);
    unawaited(ref.read(connectionDoctorProvider.notifier).setVisible(false));
    _syncCoreScreenOff(true);
  }

  void _leaveBackground() {
    render?.resume();
    ref.read(routeTrackerProvider.notifier).setVisible(true);
    ref.read(setupActionProvider.notifier).setVisible(true);
    unawaited(ref.read(connectionDoctorProvider.notifier).setVisible(true));
    _syncCoreScreenOff(false);
  }

  // Desktop has no OS screen-off signal, so a window hidden to the tray or
  // minimized is the only cue that no one is watching: park the core's RCX
  // reach and watchdog like a screen-off would, without suspending the data
  // plane. The tunnel keeps routing; only the engine's probing quiets until
  // the window returns.
  void _syncCoreScreenOff(bool off) {
    if (ref.read(coreStatusProvider) != CoreStatus.connected) {
      return;
    }
    unawaited(
      ref.read(coreHandlerProvider).setScreenOff(off).catchError((
        Object error,
      ) {
        commonPrint.log(
          'Core screen-off sync failed: $error',
          logLevel: LogLevel.warning,
        );
        return false;
      }),
    );
  }

  @override
  void dispose() {
    _invalidateWindowGeometryCapture();
    desktopWindow.removeListener(this);
    super.dispose();
  }
}
