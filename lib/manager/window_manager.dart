import 'dart:async';
import 'dart:io';

import 'package:reclash/common/common.dart';
import 'package:reclash/common/launch.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/config.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';
import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window/window.dart';

const _windowGeometryDelay = Duration(milliseconds: 120);

class WindowManager extends ConsumerStatefulWidget {
  final Widget child;

  /// A request to quit from outside the window, such as SIGTERM from `kill`
  /// or the session ending; exits like the tray's quit.
  final Stream<ProcessSignal>? terminateSignals;

  const WindowManager({super.key, this.terminateSignals, required this.child});

  @override
  ConsumerState<WindowManager> createState() => _WindowContainerState();
}

class _WindowContainerState extends ConsumerState<WindowManager>
    with WindowListener {
  Timer? _windowGeometryTimer;
  StreamSubscription<ProcessSignal>? _terminateSubscription;
  int _windowGeometryRevision = 0;
  int _windowBlurRevision = 0;

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
    ref.listenManual(windowBlurRequestProvider, (prev, next) {
      if (prev != next) {
        unawaited(_applyWindowBlur(next));
      }
    }, fireImmediately: true);
    desktopWindow.addListener(this);
    _terminateSubscription = widget.terminateSignals?.listen(
      (_) => unawaited(onWindowShouldTerminate()),
    );
  }

  Future<void> _applyWindowBlur(WindowBlurRequest request) async {
    final port = windowPort;
    if (port == null) {
      return;
    }
    final revision = ++_windowBlurRevision;
    bool active;
    try {
      active = await port.setBlur(
        enabled: request.enabled,
        brightness: request.brightness,
        tint: request.tint,
      );
    } catch (error) {
      commonPrint.log(
        'Window blur failed: ${compactError(error)}',
        logLevel: LogLevel.warning,
      );
      active = false;
    }
    if (!mounted || revision != _windowBlurRevision) {
      return;
    }
    ref.read(windowBlurProvider.notifier).value = active;
  }

  @override
  void onWindowClose() async {
    await ref.read(systemActionProvider.notifier).handleClose();
    super.onWindowClose();
  }

  /// Another launch, or a Dock reopen, asked for the window.
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
    super.onWindowMinimize();
  }

  @override
  void onWindowRestore() {
    super.onWindowRestore();
    _scheduleWindowGeometryCapture();
  }

  @override
  void dispose() {
    _invalidateWindowGeometryCapture();
    unawaited(_terminateSubscription?.cancel());
    desktopWindow.removeListener(this);
    super.dispose();
  }
}

class WindowHeaderContainer extends StatelessWidget {
  final Widget child;

  const WindowHeaderContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (_, ref, child) {
        final isMobileView = ref.watch(isMobileViewProvider);
        final version = ref.watch(versionProvider);
        final showsHeader = showsWindowHeader(
          isDesktop: system.isDesktop,
          isMacOS: system.isMacOS,
          version: version,
          isMobileView: isMobileView,
        );
        if (!showsHeader) {
          return child!;
        }
        return WindowHeaderLayout(
          height: kHeaderHeight,
          header: const WindowHeader(),
          child: child!,
        );
      },
      child: child,
    );
  }
}

class WindowHeaderLayout extends StatelessWidget {
  const WindowHeaderLayout({
    super.key,
    required this.height,
    required this.header,
    required this.child,
  });

  final double height;
  final Widget header;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Overlay.wrap(
      child: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: height),
              Expanded(flex: 1, child: child),
            ],
          ),
          Positioned(top: 0, left: 0, right: 0, child: header),
        ],
      ),
    );
  }
}

@immutable
class WindowCaptionState {
  const WindowCaptionState({
    this.isPinned = false,
    this.isMaximized = false,
    this.isFullScreen = false,
  });

  final bool isPinned;
  final bool isMaximized;
  final bool isFullScreen;

  WindowCaptionState copyWith({
    bool? isPinned,
    bool? isMaximized,
    bool? isFullScreen,
  }) {
    return WindowCaptionState(
      isPinned: isPinned ?? this.isPinned,
      isMaximized: isMaximized ?? this.isMaximized,
      isFullScreen: isFullScreen ?? this.isFullScreen,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is WindowCaptionState &&
        other.isPinned == isPinned &&
        other.isMaximized == isMaximized &&
        other.isFullScreen == isFullScreen;
  }

  @override
  int get hashCode => Object.hash(isPinned, isMaximized, isFullScreen);
}

/// Maximize and fullscreen are written only from window events: the window
/// manager can change both on its own, and on Linux a maximize request is
/// applied later, so reading the state back right after the call is stale.
class WindowCaptionController extends ValueNotifier<WindowCaptionState>
    with WindowListener {
  WindowCaptionController() : super(const WindowCaptionState()) {
    desktopWindow.addListener(this);
    unawaited(_syncFromWindow());
  }

  bool _disposed = false;

  Future<void> _syncFromWindow() async {
    final states = await Future.wait<bool>([
      desktopWindow.isAlwaysOnTop(),
      desktopWindow.isMaximized(),
      desktopWindow.isFullScreen(),
    ]);
    _set(
      WindowCaptionState(
        isPinned: states[0],
        isMaximized: states[1],
        isFullScreen: states[2],
      ),
    );
  }

  void _set(WindowCaptionState state) {
    if (_disposed) return;
    value = state;
  }

  @override
  void onWindowMaximize() {
    super.onWindowMaximize();
    _set(value.copyWith(isMaximized: true));
  }

  @override
  void onWindowUnmaximize() {
    super.onWindowUnmaximize();
    _set(value.copyWith(isMaximized: false));
  }

  @override
  void onWindowEnterFullScreen() {
    super.onWindowEnterFullScreen();
    _set(value.copyWith(isFullScreen: true));
  }

  @override
  void onWindowLeaveFullScreen() {
    super.onWindowLeaveFullScreen();
    _set(value.copyWith(isFullScreen: false));
  }

  Future<void> toggleMaximized() async {
    if (await desktopWindow.isFullScreen()) {
      await desktopWindow.setFullScreen(false);
    } else if (await desktopWindow.isMaximized()) {
      await desktopWindow.unmaximize();
    } else {
      await desktopWindow.maximize();
    }
  }

  Future<void> togglePin() async {
    final isPinned = await desktopWindow.isAlwaysOnTop();
    await desktopWindow.setAlwaysOnTop(!isPinned);
    _set(value.copyWith(isPinned: await desktopWindow.isAlwaysOnTop()));
  }

  @override
  void dispose() {
    _disposed = true;
    desktopWindow.removeListener(this);
    super.dispose();
  }
}

class WindowHeader extends ConsumerStatefulWidget {
  const WindowHeader({super.key});

  @override
  ConsumerState<WindowHeader> createState() => _WindowHeaderState();
}

class _WindowHeaderState extends ConsumerState<WindowHeader> {
  final caption = WindowCaptionController();

  @override
  void dispose() {
    caption.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final translucent =
        ref.watch(windowBlurProvider) && !ref.watch(isMobileViewProvider);
    return WindowHeaderBar(
      height: kHeaderHeight,
      translucent: translucent,
      onDragStart: desktopWindow.startDragging,
      onDoubleTap: caption.toggleMaximized,
      title: system.isMacOS ? const Text(appName) : null,
      leading: system.isMacOS ? null : const WindowStatusIndicator(),
      actions: system.isMacOS
          ? null
          : WindowHeaderActions(
              state: caption,
              onPin: caption.togglePin,
              onMinimize: desktopWindow.minimize,
              onMaximize: caption.toggleMaximized,
              onClose: () {
                ref.read(systemActionProvider.notifier).handleClose();
              },
            ),
    );
  }
}

class WindowHeaderBar extends StatelessWidget {
  const WindowHeaderBar({
    super.key,
    required this.height,
    required this.onDragStart,
    required this.onDoubleTap,
    this.translucent = false,
    this.title,
    this.leading,
    this.actions,
  });

  final double height;
  final VoidCallback onDragStart;
  final VoidCallback onDoubleTap;
  final bool translucent;
  final Widget? title;
  final Widget? leading;
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Material(
      color: translucent ? Colors.transparent : null,
      shape: Border(
        bottom: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: SizedBox(
        height: height,
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Positioned.fill(
              child: GestureDetector(
                onPanStart: (_) {
                  onDragStart();
                },
                onDoubleTap: onDoubleTap,
                child: ColoredBox(
                  color: translucent
                      ? colorScheme.surface.withValues(
                          alpha: kSidebarBlurOpacity,
                        )
                      : colorScheme.surface,
                ),
              ),
            ),
            if (title != null)
              Positioned.fill(
                child: IgnorePointer(child: Center(child: title)),
              ),
            if (leading != null)
              PositionedDirectional(
                top: 0,
                bottom: 0,
                start: 0,
                child: IgnorePointer(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(start: 10),
                    child: Center(child: leading),
                  ),
                ),
              ),
            if (actions != null)
              Positioned(
                top: 0,
                bottom: 0,
                right: 0,
                child: IconButtonTheme(
                  data: IconButtonThemeData(
                    style: ButtonStyle(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      minimumSize: WidgetStatePropertyAll(
                        getCaptionButtonSize(height),
                      ),
                      maximumSize: WidgetStatePropertyAll(
                        getCaptionButtonSize(height),
                      ),
                      padding: const WidgetStatePropertyAll(EdgeInsets.zero),
                      shape: const WidgetStatePropertyAll(AppShape.none),
                      foregroundColor: WidgetStatePropertyAll(
                        colorScheme.onSurface,
                      ),
                      overlayColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.pressed)) {
                          return colorScheme.onSurface.withValues(alpha: 0.12);
                        }
                        if (states.contains(WidgetState.hovered)) {
                          return colorScheme.onSurface.withValues(alpha: 0.08);
                        }
                        return null;
                      }),
                    ),
                  ),
                  child: actions!,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Fixed rather than themed: the close affordance stays the same alarming red
/// in every colour scheme, matching the platform convention.
const _closeHoverColor = Color(0xFFEE2C3C);

class WindowHeaderActions extends StatelessWidget {
  const WindowHeaderActions({
    super.key,
    required this.state,
    required this.onPin,
    required this.onMinimize,
    required this.onMaximize,
    required this.onClose,
  });

  final ValueListenable<WindowCaptionState> state;
  final VoidCallback onPin;
  final VoidCallback onMinimize;
  final VoidCallback onMaximize;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return ValueListenableBuilder(
      valueListenable: state,
      builder: (_, state, _) {
        final (maximizeGlyph, maximizeTooltip) = switch (state) {
          WindowCaptionState(isFullScreen: true) => (
            CaptionGlyph.restore,
            appLocalizations.exitFullScreen,
          ),
          WindowCaptionState(isMaximized: true) => (
            CaptionGlyph.restore,
            appLocalizations.unmaximize,
          ),
          _ => (CaptionGlyph.maximize, appLocalizations.maximize),
        };
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: IconButton(
                tooltip: state.isPinned
                    ? appLocalizations.unpinWindow
                    : appLocalizations.pinWindow,
                style: const ButtonStyle(
                  shape: WidgetStatePropertyAll(AppShape.circle),
                  minimumSize: WidgetStatePropertyAll(Size.zero),
                  maximumSize: WidgetStatePropertyAll(Size.infinite),
                  iconSize: WidgetStatePropertyAll(pinIconSize),
                ),
                onPressed: onPin,
                icon: GlyphIcon(AppGlyphs.pin, fill: state.isPinned ? 1 : 0),
              ).withAppTooltip(),
            ),
            IconButton(
              tooltip: appLocalizations.minimize,
              onPressed: onMinimize,
              icon: const CaptionIcon(CaptionGlyph.minimize),
            ).withAppTooltip(),
            IconButton(
              tooltip: maximizeTooltip,
              onPressed: onMaximize,
              icon: CaptionIcon(maximizeGlyph),
            ).withAppTooltip(),
            IconButton(
              tooltip: appLocalizations.close,
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  final active =
                      states.contains(WidgetState.hovered) ||
                      states.contains(WidgetState.pressed);
                  return active ? _closeHoverColor : null;
                }),
                foregroundColor: WidgetStateProperty.resolveWith((states) {
                  final active =
                      states.contains(WidgetState.hovered) ||
                      states.contains(WidgetState.pressed);
                  return active ? Colors.white : null;
                }),
                overlayColor: WidgetStateProperty.resolveWith((states) {
                  return states.contains(WidgetState.pressed)
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.transparent;
                }),
              ),
              onPressed: onClose,
              icon: const CaptionIcon(CaptionGlyph.close),
            ).withAppTooltip(),
          ],
        );
      },
    );
  }
}

/// The tunnel state the title bar dot carries, drawn from this repo's own
/// status providers.
enum WindowStatus { off, connecting, running, suspended, disconnected }

WindowStatus windowStatusOf({
  required bool isStart,
  required bool suspended,
  required CoreStatus coreStatus,
}) {
  if (coreStatus == CoreStatus.connecting) {
    return isStart && suspended
        ? WindowStatus.suspended
        : WindowStatus.connecting;
  }
  if (!isStart) return WindowStatus.off;
  if (suspended) return WindowStatus.suspended;
  return switch (coreStatus) {
    CoreStatus.connecting => WindowStatus.connecting,
    CoreStatus.connected => WindowStatus.running,
    CoreStatus.disconnected => WindowStatus.disconnected,
  };
}

final windowStatusProvider = Provider<WindowStatus>((ref) {
  return windowStatusOf(
    isStart: ref.watch(isStartProvider),
    suspended: ref.watch(suspendProvider),
    coreStatus: ref.watch(coreStatusProvider),
  );
});

/// Alpha appends the active server to the connected label. Here only global
/// mode names a single server - the GLOBAL group's selection - while rule
/// mode routes each request on its own.
final windowServerNameProvider = Provider<String>((ref) {
  if (ref.watch(windowStatusProvider) != WindowStatus.running) {
    return '';
  }
  if (ref.watch(effectiveModeProvider) != Mode.global) {
    return '';
  }
  return _stripLeadingEmoji(
    ref.watch(selectedProxyNameProvider(GroupName.GLOBAL.name)) ?? '',
  );
});

/// The connection state carried into the title bar, so a window shrunk to a
/// strip still says whether the tunnel is up.
class WindowStatusIndicator extends ConsumerWidget {
  const WindowStatusIndicator({super.key});

  static const double _dotSize = 8;
  static const double _maxLabelWidth = 270;
  static const double _labelSpacing = 8;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(windowStatusProvider);
    final colorScheme = context.colorScheme;
    final dotColor = switch (status) {
      WindowStatus.off => colorScheme.onSurfaceVariant,
      WindowStatus.connecting => colorScheme.primary,
      WindowStatus.running => colorScheme.success,
      WindowStatus.suspended => colorScheme.warning,
      WindowStatus.disconnected => colorScheme.error,
    };
    final baseLabel = _statusLabel(context.appLocalizations, status);
    final serverName = ref.watch(windowServerNameProvider);
    final label = status == WindowStatus.running && serverName.isNotEmpty
        ? '$baseLabel • $serverName'
        : baseLabel;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: context.motionDuration(const Duration(milliseconds: 320)),
          width: _dotSize,
          height: _dotSize,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
            boxShadow: status == WindowStatus.off
                ? null
                : [
                    BoxShadow(
                      color: dotColor.withValues(alpha: 0.5),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
          ),
        ),
        const SizedBox(width: _labelSpacing),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxLabelWidth),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.caption1
                .of(context)
                .copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

String _statusLabel(AppLocalizations appLocalizations, WindowStatus status) =>
    switch (status) {
      WindowStatus.off => appLocalizations.notRunning,
      WindowStatus.connecting => appLocalizations.connecting,
      WindowStatus.running => appLocalizations.connected,
      WindowStatus.suspended => appLocalizations.suspended,
      WindowStatus.disconnected => appLocalizations.disconnected,
    };

/// Subscription names open with a flag emoji; a title bar label reads the
/// server, not its flag.
String _stripLeadingEmoji(String text) {
  bool isEmojiRune(int rune) =>
      (rune >= 0x1F000 && rune <= 0x1FAFF) ||
      (rune >= 0x2600 && rune <= 0x27BF) ||
      (rune >= 0x2190 && rune <= 0x21FF) ||
      (rune >= 0x2B00 && rune <= 0x2BFF) ||
      (rune >= 0x2300 && rune <= 0x23FF) ||
      rune == 0x200D ||
      rune == 0xFE0F;
  bool isSpace(int rune) =>
      rune == 0x20 || rune == 0x09 || rune == 0xA0 || rune == 0x0A;

  final runes = text.runes.toList();
  var start = 0;
  while (start < runes.length &&
      (isEmojiRune(runes[start]) || isSpace(runes[start]))) {
    start++;
  }
  return String.fromCharCodes(
    runes.sublist(start),
  ).replaceAll(RegExp(r'\s+'), ' ').trim();
}
