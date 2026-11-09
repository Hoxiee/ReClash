import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:reclash/widgets/provider_image.dart';

class PreviewImages implements ProviderImages {
  const PreviewImages(this.base);

  final Uri base;

  Uri? resolve(String src) {
    if (src.isEmpty) return null;
    final uri = Uri.tryParse(src);
    if (uri == null) return null;
    if (uri.scheme == 'data') {
      try {
        return uri.data!.mimeType.startsWith('image/') ? uri : null;
      } on FormatException {
        return null;
      }
    }
    final resolved = base.resolveUri(uri);
    return const {'http', 'https'}.contains(resolved.scheme) &&
            const {'http', 'https'}.contains(base.scheme) &&
            resolved.hasAuthority &&
            resolved.host.isNotEmpty &&
            resolved.userInfo.isEmpty &&
            resolved.origin == base.origin
        ? resolved
        : null;
  }

  ImageProvider? source(Uri url) {
    final uri = resolve(url.toString());
    if (uri == null) return null;
    if (uri.data case final data?) {
      try {
        final bytes = data.contentAsBytes();
        return bytes.isEmpty ? null : MemoryImage(bytes);
      } on FormatException {
        return null;
      }
    }
    return NetworkImage(uri.toString());
  }

  @override
  Widget logo(String src, {Widget? fallback}) {
    final placeholder = fallback ?? const SizedBox.shrink();
    final uri = resolve(src);
    if (uri == null) return placeholder;
    if (uri.data case final data?) {
      try {
        final bytes = data.contentAsBytes();
        if (bytes.isEmpty) return placeholder;
        return data.mimeType.contains('svg')
            ? SvgPicture.memory(bytes, errorBuilder: (_, _, _) => placeholder)
            : Image.memory(bytes, errorBuilder: (_, _, _) => placeholder);
      } on FormatException {
        return placeholder;
      }
    }
    return uri.path.toLowerCase().endsWith('.svg')
        ? SvgPicture.network(
            uri.toString(),
            errorBuilder: (_, _, _) => placeholder,
            placeholderBuilder: (_) => placeholder,
          )
        : Image.network(uri.toString(), errorBuilder: (_, _, _) => placeholder);
  }

  @override
  Future<ImageProvider?> picture(Uri url) async => source(url);
}
