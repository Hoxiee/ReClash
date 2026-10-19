import 'dart:async';
import 'dart:collection';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

import 'print.dart';
import 'protocol.dart';
import 'url_scheme.dart';

String? profileUrlFromQrCodes(Iterable<String?> values) {
  for (final value in values) {
    final text = value?.trim();
    if (text == null || !isProfileLinkInput(text)) continue;
    try {
      final link = parseUrlSchemeLink(text);
      if (link?.command == ReClashCommand.installConfig && link?.name == null) {
        return link!.payload;
      }
    } on UrlSchemeException {
      continue;
    }
    return text;
  }
  return null;
}

class LinkManager {
  static LinkManager? _instance;
  StreamSubscription<String>? subscription;
  String? _pendingLink;
  final _queue = Queue<String>();
  final _queued = <String>{};
  String? _activeLink;
  var _generation = 0;
  Timer? _seedEchoTimer;
  String? _seedEcho;
  static final _schemePrefix = RegExp(r'^([a-zA-Z][a-zA-Z0-9+.-]*):');

  LinkManager._internal();

  @visibleForTesting
  LinkManager.scoped();

  // Uri normalizes opaque Base64 authorities, corrupting vmess/ss payloads.
  @visibleForTesting
  Stream<String> Function() stringLinkStream = () =>
      AppLinks().stringLinkStream;

  String? _scheme(String input) {
    final prefix = input.length > 64 ? input.substring(0, 64) : input;
    return _schemePrefix.firstMatch(prefix)?.group(1)?.toLowerCase();
  }

  /// Linux argv: the gtk plugin hooks GApplication too late to see it.
  void seedInitialLink(List<String> args) {
    for (final arg in args) {
      if (protocolSchemes.contains(_scheme(arg))) {
        _pendingLink = arg;
        return;
      }
    }
  }

  Future<void> initAppLinksListen(
    FutureOr<void> Function(String link) onLink, {
    void Function()? onError,
  }) async {
    final pending = _pendingLink;
    destroy();
    final generation = _generation;
    _seedEcho = pending;
    if (_seedEcho != null) {
      _seedEchoTimer = Timer(
        const Duration(seconds: 2),
        () => _seedEcho = null,
      );
    }
    try {
      subscription = stringLinkStream().listen(
        (link) {
          if (generation != _generation) return;
          if (link == _seedEcho) {
            _seedEcho = null;
            _seedEchoTimer?.cancel();
            return;
          }
          _enqueue(link, generation, onLink, onError);
        },
        onError: (Object _) {
          if (generation == _generation) onError?.call();
        },
      );
    } catch (_) {
      onError?.call();
    }
    if (pending != null) _enqueue(pending, generation, onLink, onError);
  }

  void _enqueue(
    String link,
    int generation,
    FutureOr<void> Function(String link) onLink,
    void Function()? onError,
  ) {
    final scheme = _scheme(link);
    if (generation != _generation || !protocolSchemes.contains(scheme)) {
      return;
    }
    if (link.length > urlSchemeMaxLength) {
      onError?.call();
      return;
    }
    if (link == _activeLink || _queued.contains(link)) return;
    if (_queue.length >= 8) {
      onError?.call();
      return;
    }
    commonPrint.log('onAppLink: $scheme');
    _queue.add(link);
    _queued.add(link);
    if (_activeLink == null) {
      unawaited(_drain(generation, onLink, onError));
    }
  }

  Future<void> _drain(
    int generation,
    FutureOr<void> Function(String link) onLink,
    void Function()? onError,
  ) async {
    while (_queue.isNotEmpty && generation == _generation) {
      final link = _queue.removeFirst();
      _queued.remove(link);
      _activeLink = link;
      try {
        await onLink(link);
      } catch (_) {
        if (generation == _generation) onError?.call();
      } finally {
        if (generation == _generation) _activeLink = null;
      }
    }
  }

  void destroy() {
    _generation++;
    unawaited(subscription?.cancel());
    subscription = null;
    _pendingLink = null;
    _queue.clear();
    _queued.clear();
    _activeLink = null;
    _seedEcho = null;
    _seedEchoTimer?.cancel();
    _seedEchoTimer = null;
  }

  factory LinkManager() {
    _instance ??= LinkManager._internal();
    return _instance!;
  }
}

final linkManager = LinkManager();
