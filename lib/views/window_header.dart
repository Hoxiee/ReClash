import 'dart:async';

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/dashboard/widgets/active_server.dart';
import 'package:reclash/views/dashboard/widgets/hero/hero_status.dart';
import 'package:reclash/widgets/feedback/tooltip.dart';
import 'package:window/window.dart';

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
    return WindowHeaderBar(
      height: kHeaderHeight,
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
    this.title,
    this.leading,
    this.actions,
  });

  final double height;
  final VoidCallback onDragStart;
  final VoidCallback onDoubleTap;
  final Widget? title;
  final Widget? leading;
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: Border(
        bottom: BorderSide(
          color: context.colorScheme.outlineVariant.withValues(alpha: 0.3),
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
                child: ColoredBox(color: context.colorScheme.surface),
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
                        context.colorScheme.onSurface,
                      ),
                      overlayColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.pressed)) {
                          return context.colorScheme.onSurface.withValues(
                            alpha: 0.12,
                          );
                        }
                        if (states.contains(WidgetState.hovered)) {
                          return context.colorScheme.onSurface.withValues(
                            alpha: 0.08,
                          );
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

/// The connection state carried into the title bar, so a window shrunk to a
/// strip still says whether the tunnel is up. Mirrors the hero orb's vocabulary.
class WindowStatusIndicator extends ConsumerWidget {
  const WindowStatusIndicator({super.key});

  static const double _dotSize = 8;
  static const double _maxLabelWidth = 270;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = heroStatusOf(
      ref.watch(heroLifecycleProvider),
      ref.watch(connectionDoctorProvider.select(heroDoctorHealthOf)),
    );
    final configInvalid =
        status == HeroStatus.broken &&
        ref.watch(
          runRequestStateProvider.select(
            (state) => state.fault == RunRequestFault.configInvalid,
          ),
        );
    final dotColor = heroPaletteOf(context, status).accent;
    final baseLabel = _statusLabel(
      context.appLocalizations,
      status,
      configInvalid,
    );
    final serverName = ref.watch(
      activeServerProvider.select((server) => server.displayName),
    );
    final label =
        (status == HeroStatus.secured || status == HeroStatus.degraded) &&
            serverName.isNotEmpty
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
            boxShadow: status.isLive
                ? [
                    BoxShadow(
                      color: dotColor.withValues(alpha: 0.5),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxLabelWidth),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.labelMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

String _statusLabel(
  AppLocalizations l,
  HeroStatus status, [
  bool configInvalid = false,
]) => switch (status) {
  HeroStatus.offline => l.noNetwork,
  HeroStatus.off => l.heroNotProtected,
  HeroStatus.checking || HeroStatus.diagnosing => l.heroChecking,
  HeroStatus.connecting => l.heroConnecting,
  HeroStatus.reconnecting => l.heroReconnecting,
  HeroStatus.paused => l.heroPaused,
  HeroStatus.blocked => l.heroBlockedTitle,
  HeroStatus.broken =>
    configInvalid ? l.heroConfigInvalidTitle : l.heroLinkBroken,
  HeroStatus.subscriptionExpired => l.dashboardSubscriptionExpired,
  HeroStatus.secured || HeroStatus.degraded => l.connected,
};

class AppIcon extends StatelessWidget {
  const AppIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        color: context.colorScheme.surfaceContainerHighest,
        shape: AppShape.md,
      ),
      padding: AppInsets.sm,
      child: Transform.translate(
        offset: const Offset(0, -1),
        child: Image.asset('assets/images/icon.png', width: 34, height: 34),
      ),
    );
  }
}
