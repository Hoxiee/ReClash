import 'package:material_ui/material_ui.dart';
import 'package:flutter_svg/flutter_svg.dart';

sealed class WallpaperSource {
  const WallpaperSource();
}

class RasterWallpaperSource extends WallpaperSource {
  const RasterWallpaperSource(this.image);

  final ImageProvider image;

  @override
  bool operator ==(Object other) =>
      other is RasterWallpaperSource && other.image == image;

  @override
  int get hashCode => image.hashCode;
}

class SvgWallpaperSource extends WallpaperSource {
  const SvgWallpaperSource(this.loader);

  final BytesLoader loader;

  @override
  bool operator ==(Object other) =>
      other is SvgWallpaperSource && other.loader == loader;

  @override
  int get hashCode => loader.hashCode;
}

class WallpaperImage extends StatelessWidget {
  const WallpaperImage({
    super.key,
    required this.image,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
  });

  final WallpaperSource image;
  final BoxFit fit;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) => switch (image) {
    RasterWallpaperSource(:final image) => Image(
      image: image,
      fit: fit,
      alignment: alignment,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, _, _) => const SizedBox.expand(),
    ),
    SvgWallpaperSource(:final loader) => SvgPicture(
      loader,
      fit: fit,
      alignment: alignment,
      width: double.infinity,
      height: double.infinity,
      excludeFromSemantics: true,
      errorBuilder: (_, _, _) => const SizedBox.expand(),
    ),
  };
}
