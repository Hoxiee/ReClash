import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

import 'print.dart';
import 'protocol.dart';

typedef IncomingLinkCallback = void Function(IncomingLink link);

class IncomingLink {
  const IncomingLink(this.payload, {this.name});

  final String payload;

  final String? name;
}

/// Null when there is nothing to import; a stray `VIEW` intent must stay inert.
IncomingLink? parseIncomingLink(Uri uri) {
  if (configProtocolSchemes.contains(uri.scheme)) {
    if (uri.host != 'install-config') {
      return null;
    }
    final url = uri.queryParameters['url'];
    if (url == null || url.isEmpty) {
      return null;
    }
    return IncomingLink(url, name: _label(uri));
  }
  if (deepLinkProtocolSchemes.contains(uri.scheme) ||
      shareProtocolSchemes.contains(uri.scheme)) {
    return IncomingLink(uri.toString());
  }
  return null;
}

String? _label(Uri uri) {
  final name = uri.queryParameters['name']?.trim();
  return name == null || name.isEmpty ? null : name;
}

class LinkManager {
  static LinkManager? _instance;
  StreamSubscription? subscription;
  Uri? _pendingUri;

  LinkManager._internal();

  @visibleForTesting
  Stream<Uri> Function() uriLinkStream = () => AppLinks().uriLinkStream;

  /// Linux argv: the gtk plugin hooks GApplication too late to see it.
  void seedInitialLink(List<String> args) {
    for (final arg in args) {
      final uri = Uri.tryParse(arg);
      if (uri != null && allProtocolSchemes.contains(uri.scheme)) {
        _pendingUri = uri;
        return;
      }
    }
  }

  Future<void> initAppLinksListen(IncomingLinkCallback onLink) async {
    commonPrint.log('initAppLinksListen');
    destroy();
    subscription = uriLinkStream().listen((uri) {
      _handle(uri, onLink);
    });
    final pending = _pendingUri;
    _pendingUri = null;
    if (pending != null) {
      _handle(pending, onLink);
    }
  }

  void _handle(Uri uri, IncomingLinkCallback onLink) {
    commonPrint.log('onAppLink: $uri');
    final link = parseIncomingLink(uri);
    if (link == null) {
      return;
    }
    onLink(link);
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
