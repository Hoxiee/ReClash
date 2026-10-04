import 'dart:ui' as ui;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/models/wallpaper.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/wallpaper.dart';

import 'wallpaper_scope.dart';

/// A wallpaper appearing or disappearing used to swap the whole content subtree
/// between a bare child and one nested in a `Stack`, so Flutter rebuilt the
/// page from scratch (visible flicker). The backdrop now keeps one fixed
/// structure and only crossfades the image layer, so the content element is
/// never reparented.
const _wallpaperFadeDuration = Duration(milliseconds: 360);

class AppWallpaper extends ConsumerWidget {
  const AppWallpaper({
    super.key,
    required this.builder,
    this.surfaceOpacity,
    this.baseColor,
  });

  final Widget Function(BuildContext context, bool active) builder;
  final double? surfaceOpacity;

  /// The opaque colour painted behind the wallpaper, matching what the content
  /// shows when inactive, so a fade never flashes through to nothing. Defaults
  /// to the scheme surface; the shell passes its `surfaceContainer`.
  final Color? baseColor;

  Widget _scope(BuildContext context, bool active, WallpaperProps settings) {
    return WallpaperSurfaceScope(
      opacity: surfaceOpacity ?? settings.cardOpacity,
      child: Builder(builder: (context) => builder(context, active)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(
      themeSettingProvider.select((value) => value.wallpaper),
    );
    final image = ref.watch(effectiveWallpaperImageProvider);
    // A single ancestor paints the image once, so nested scaffolds/panes share
    // one continuous backdrop instead of each aligning its own crop. Descendants
    // read the backdrop's lingering `active` so they fade out in step with it,
    // instead of snapping opaque the instant the image clears.
    final marker = context
        .dependOnInheritedWidgetOfExactType<_WallpaperPaintedMarker>();
    if (marker != null) {
      return _scope(context, marker.active, settings);
    }
    return WallpaperBackdrop(
      image: image,
      settings: settings,
      baseColor: baseColor ?? context.colorScheme.surface,
      builder: (context, active) => _WallpaperPaintedMarker(
        active: active,
        child: _scope(context, active, settings),
      ),
    );
  }
}

class _WallpaperPaintedMarker extends InheritedWidget {
  const _WallpaperPaintedMarker({required this.active, required super.child});

  final bool active;

  @override
  bool updateShouldNotify(_WallpaperPaintedMarker oldWidget) =>
      active != oldWidget.active;
}

/// Holds a fixed three-slot stack — base colour, crossfading image, content —
/// so the content never changes position in the element tree. The reported
/// `active` lingers through a fade-out so the outgoing image stays visible
/// instead of being covered the instant the image clears.
class WallpaperBackdrop extends StatefulWidget {
  const WallpaperBackdrop({
    super.key,
    required this.image,
    required this.settings,
    required this.baseColor,
    required this.builder,
  });

  final ImageProvider? image;
  final WallpaperProps settings;
  final Color baseColor;
  final Widget Function(BuildContext context, bool active) builder;

  @override
  State<WallpaperBackdrop> createState() => _WallpaperBackdropState();
}

class _WallpaperBackdropState extends State<WallpaperBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _opacity;
  ImageProvider? _shownImage;
  bool _active = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _wallpaperFadeDuration,
      value: widget.image != null ? 1 : 0,
    )..addStatusListener(_onStatus);
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _shownImage = widget.image;
    _active = widget.image != null;
  }

  void _onStatus(AnimationStatus status) {
    // The fade-out finished: drop the retained image and let the content paint
    // its own opaque background again.
    if (status == AnimationStatus.dismissed &&
        (_active || _shownImage != null)) {
      setState(() {
        _shownImage = null;
        _active = false;
      });
    }
  }

  @override
  void didUpdateWidget(WallpaperBackdrop oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = widget.image;
    if (next != null) {
      if (next != _shownImage || !_active) {
        setState(() {
          _shownImage = next;
          _active = true;
        });
      }
      _controller.forward();
    } else {
      // Keep the current image mounted and fade it out; `_onStatus` clears it.
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _opacity.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _controller.duration = context.motionDuration(_wallpaperFadeDuration);
    final image = _shownImage;
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: _active
              ? ColoredBox(color: widget.baseColor)
              : const SizedBox.shrink(),
        ),
        Positioned.fill(
          child: image == null
              ? const SizedBox.shrink()
              : FadeTransition(
                  opacity: _opacity,
                  child: AnimatedSwitcher(
                    duration: context.motionDuration(_wallpaperFadeDuration),
                    child: WallpaperLayer(
                      key: ValueKey(image),
                      image: image,
                      settings: widget.settings,
                    ),
                  ),
                ),
        ),
        widget.builder(context, _active),
      ],
    );
  }
}

class WallpaperLayer extends StatelessWidget {
  const WallpaperLayer({
    super.key,
    required this.image,
    required this.settings,
  });

  final ImageProvider image;
  final WallpaperProps settings;

  @override
  Widget build(BuildContext context) {
    final alignment = Alignment(settings.positionX, settings.positionY);
    return RepaintBoundary(
      child: ExcludeSemantics(
        child: IgnorePointer(
          child: ColoredBox(
            color: context.colorScheme.surface.withValues(alpha: 1),
            child: ClipRect(
              child: Opacity(
                opacity: settings.opacity,
                child: ImageFiltered(
                  enabled: settings.blur > 0,
                  imageFilter: ui.ImageFilter.blur(
                    sigmaX: settings.blur,
                    sigmaY: settings.blur,
                    tileMode: ui.TileMode.clamp,
                  ),
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      Colors.black.withValues(alpha: settings.dimming),
                      BlendMode.srcATop,
                    ),
                    child: Transform.scale(
                      scale: settings.scale,
                      alignment: alignment,
                      child: Image(
                        image: image,
                        width: double.infinity,
                        height: double.infinity,
                        alignment: alignment,
                        fit: switch (settings.fit) {
                          WallpaperFit.cover => BoxFit.cover,
                          WallpaperFit.contain => BoxFit.contain,
                          WallpaperFit.fill => BoxFit.fill,
                        },
                        errorBuilder: (_, _, _) => const SizedBox.expand(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
