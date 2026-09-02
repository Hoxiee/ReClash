import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

import 'print.dart';

typedef InstallConfigCallBack = void Function(String url);

class LinkManager {
  static LinkManager? _instance;
  StreamSubscription? subscription;

  LinkManager._internal();

  @visibleForTesting
  Stream<Uri> Function() uriLinkStream = () => AppLinks().uriLinkStream;

  Future<void> initAppLinksListen(
    Function(String url) installConfigCallBack,
  ) async {
    commonPrint.log('initAppLinksListen');
    destroy();
    subscription = uriLinkStream().listen((uri) {
      commonPrint.log('onAppLink: $uri');
      if (uri.host == 'install-config') {
        final parameters = uri.queryParameters;
        final url = parameters['url'];
        if (url != null) {
          installConfigCallBack(url);
        }
        return;
      }
      // Resolved locally by the subscription pipeline; the scheme
      // registration itself lives in the platform manifests.
      if (uri.scheme == 'incy' || uri.scheme == 'happ') {
        installConfigCallBack(uri.toString());
      }
    });
  }

  void destroy() {
    if (subscription != null) {
      subscription?.cancel();
      subscription = null;
    }
  }

  factory LinkManager() {
    _instance ??= LinkManager._internal();
    return _instance!;
  }
}

final linkManager = LinkManager();
