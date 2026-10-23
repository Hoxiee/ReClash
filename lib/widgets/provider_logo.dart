import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/subscriptions/metadata/metadata.dart';

typedef ProviderLogoImage = ({Uint8List bytes, bool svg});

const _maxLogoBytes = 512 * 1024;
const _logoTimeout = Duration(seconds: 8);

/// Fetches a panel's `provider.logo` with a size and time bound of its own:
/// the value comes from the subscription response, so neither is trusted.
Future<ProviderLogoImage?> fetchProviderLogo(String url) async {
  final uri = safeSubscriptionLink(url);
  if (uri == null) return null;
  final client = HttpClient()..connectionTimeout = _logoTimeout;
  try {
    final request = await client.getUrl(uri).timeout(_logoTimeout);
    final response = await request.close().timeout(_logoTimeout);
    if (response.statusCode != HttpStatus.ok ||
        response.contentLength > _maxLogoBytes) {
      return null;
    }
    final builder = BytesBuilder(copy: false);
    await for (final chunk in response.timeout(_logoTimeout)) {
      builder.add(chunk);
      if (builder.length > _maxLogoBytes) return null;
    }
    final bytes = builder.takeBytes();
    if (bytes.isEmpty) return null;
    final type = response.headers.contentType?.mimeType ?? '';
    final svg =
        type.contains('svg') ||
        String.fromCharCodes(bytes.take(64)).trimLeft().startsWith('<');
    return (bytes: bytes, svg: svg);
  } on Object {
    return null;
  } finally {
    client.close(force: true);
  }
}

class ProviderLogo extends StatefulWidget {
  const ProviderLogo({
    super.key,
    required this.url,
    required this.size,
    required this.fallback,
  });

  final String url;
  final double size;
  final Widget fallback;

  @override
  State<ProviderLogo> createState() => _ProviderLogoState();
}

class _ProviderLogoState extends State<ProviderLogo> {
  ProviderLogoImage? _image;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void didUpdateWidget(ProviderLogo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _image = null;
      unawaited(_load());
    }
  }

  Future<void> _load() async {
    final url = widget.url;
    final image = await fetchProviderLogo(url);
    if (!mounted || url != widget.url || image == null) return;
    setState(() => _image = image);
  }

  @override
  Widget build(BuildContext context) {
    final image = _image;
    final size = widget.size;
    final child = switch (image) {
      null => widget.fallback,
      (:final bytes, svg: true) => SvgPicture.memory(
        bytes,
        width: size,
        height: size,
        errorBuilder: (_, _, _) => widget.fallback,
      ),
      (:final bytes, svg: false) => Image.memory(
        bytes,
        width: size,
        height: size,
        fit: BoxFit.cover,
        cacheWidth: (size * MediaQuery.devicePixelRatioOf(context)).round(),
        errorBuilder: (_, _, _) => widget.fallback,
      ),
    };
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: KeyedSubtree(key: ValueKey(image != null), child: child),
    );
  }
}
