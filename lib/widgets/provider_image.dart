import 'package:flutter/widgets.dart';

/// Where a provider's logos and pictures come from: the app reads them
/// through its download cache, the site preview straight from the network.
abstract interface class ProviderImages {
  /// [src] is a URL or data URI; [fallback] shows while it is empty, loading
  /// or unreadable.
  Widget logo(String src, {Widget? fallback});

  /// Null when the picture cannot be shown.
  Future<ImageProvider?> picture(Uri url);
}
