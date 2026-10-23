import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reclash/models/wallpaper.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/wallpaper.dart';
import 'package:reclash/ui/page_background.dart';

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
    Widget content = Image(
      image: image,
      fit: switch (settings.fit) {
        WallpaperFit.cover => BoxFit.cover,
        WallpaperFit.contain => BoxFit.contain,
        WallpaperFit.fill => BoxFit.fill,
      },
      alignment: alignment,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, _, _) => const SizedBox.expand(),
    );
    if (settings.scale != 1) {
      content = Transform.scale(
        scale: settings.scale,
        alignment: alignment,
        child: content,
      );
    }
    if (settings.blur > 0) {
      content = ImageFiltered(
        imageFilter: ui.ImageFilter.blur(
          sigmaX: settings.blur,
          sigmaY: settings.blur,
          tileMode: ui.TileMode.clamp,
        ),
        child: content,
      );
    }
    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Opacity(opacity: settings.opacity.clamp(0.0, 1.0), child: content),
          ColoredBox(
            color: Colors.black.withValues(
              alpha: settings.dimming.clamp(0.0, 1.0),
            ),
          ),
        ],
      ),
    );
  }
}

class AppWallpaperScope extends ConsumerWidget {
  const AppWallpaperScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(
      themeSettingProvider.select((value) => value.wallpaper),
    );
    final image = ref.watch(effectiveWallpaperImageProvider);
    return PageBackgroundRegistration(
      builder: (context, baseColor, content) => WallpaperBackdrop(
        image: image,
        settings: settings,
        baseColor: baseColor,
        builder: (_, _) => content,
      ),
      child: child,
    );
  }
}

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
    with TickerProviderStateMixin {
  late final AnimationController _visibility = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
    reverseDuration: const Duration(milliseconds: 220),
  )..addStatusListener(_onVisibilityStatus);
  late final AnimationController _replacement = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
    value: 1,
  )..addStatusListener(_onReplacementStatus);
  ImageProvider? _image;
  ImageProvider? _outgoing;
  ImageProvider? _requested;
  ImageConfiguration? _configuration;
  ImageStream? _stream;
  ImageStreamListener? _listener;
  bool _failed = false;
  bool _built = false;

  bool get _active => widget.settings.enabled && _image != null && !_failed;

  void _onVisibilityStatus(AnimationStatus status) {
    if (status == AnimationStatus.dismissed &&
        (_requested == null || _failed) &&
        mounted) {
      setState(() {
        _image = null;
        _outgoing = null;
      });
    }
  }

  void _onReplacementStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && _outgoing != null && mounted) {
      setState(() => _outgoing = null);
    }
  }

  void _removeListener() {
    final stream = _stream;
    final listener = _listener;
    if (stream != null && listener != null) stream.removeListener(listener);
    _stream = null;
    _listener = null;
  }

  void _resolveImage() {
    final image = widget.image;
    final configuration = createLocalImageConfiguration(context);
    if (image == _requested && configuration == _configuration) return;
    _removeListener();
    _requested = image;
    _configuration = configuration;
    _failed = false;
    if (image == null) {
      _setVisibility(false);
      return;
    }
    final stream = image.resolve(configuration);
    final listener = ImageStreamListener(
      (info, _) {
        info.dispose();
        if (!mounted || _stream != stream) return;
        _removeListener();
        setState(() {
          if (image != _image) {
            _outgoing = _image;
            _image = image;
            _replacement.value = _outgoing == null ? 1 : 0;
          }
          _failed = false;
        });
        final visible = _requested == image && widget.settings.enabled;
        // An image decoded before the first frame shows with the page it
        // backs, as a page backdrop finds it in the image cache.
        if (_built) {
          _setVisibility(visible);
        } else {
          _visibility.value = visible ? 1 : 0;
        }
        if (MediaQuery.disableAnimationsOf(context)) {
          _replacement.value = 1;
          _outgoing = null;
        } else {
          _replacement.forward();
        }
      },
      onError: (Object error, StackTrace? stackTrace) {
        if (!mounted || _stream != stream) return;
        _removeListener();
        setState(() => _failed = true);
        _setVisibility(false);
      },
    );
    _stream = stream;
    _listener = listener;
    stream.addListener(listener);
  }

  void _setVisibility(bool visible) {
    if (MediaQuery.disableAnimationsOf(context)) {
      _visibility.value = visible ? 1 : 0;
      if (!visible && (_requested == null || _failed)) {
        _image = null;
        _outgoing = null;
      }
    } else if (visible) {
      _visibility.forward();
    } else {
      _visibility.reverse();
    }
  }

  @override
  void didUpdateWidget(covariant WallpaperBackdrop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.image != widget.image) _resolveImage();
    if (oldWidget.settings.enabled != widget.settings.enabled) {
      _setVisibility(_active);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveImage();
    if (MediaQuery.disableAnimationsOf(context)) {
      _setVisibility(widget.settings.enabled && _image != null && !_failed);
      _replacement.value = 1;
      _outgoing = null;
    }
  }

  @override
  void dispose() {
    _removeListener();
    _visibility
      ..removeStatusListener(_onVisibilityStatus)
      ..dispose();
    _replacement
      ..removeStatusListener(_onReplacementStatus)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _built = true;
    final image = _image;
    final outgoing = _outgoing;
    return ColoredBox(
      color: widget.baseColor,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (image != null)
            IgnorePointer(
              child: ExcludeSemantics(
                child: RepaintBoundary(
                  child: FadeTransition(
                    opacity: _visibility,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (outgoing != null)
                          FadeTransition(
                            opacity: ReverseAnimation(_replacement),
                            child: WallpaperLayer(
                              image: outgoing,
                              settings: widget.settings,
                            ),
                          ),
                        FadeTransition(
                          opacity: _replacement,
                          child: WallpaperLayer(
                            image: image,
                            settings: widget.settings,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          PageBackgroundScope(
            cardOpacity: _active ? widget.settings.cardOpacity : 1,
            route: ModalRoute.of(context),
            child: widget.builder(context, _active),
          ),
        ],
      ),
    );
  }
}
