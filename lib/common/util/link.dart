import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

import 'print.dart';
import '../config/protocol.dart';

typedef IncomingLinkCallback = void Function(Uri uri);

class IncomingLink {
  const IncomingLink(this.payload, {this.name});

  final String payload;

  final String? name;
}

/// Automation commands on our own scheme.
enum ReClashCommand {
  connect._('connect'),
  disconnect._('disconnect'),
  toggle._('toggle'),
  open._('open'),
  close._('close'),
  importProfile._('import'),
  addProfile._('add');

  const ReClashCommand._(this.host);

  /// The `reclash://<host>` segment the command is written as.
  final String host;

  bool get requiresConfirmation => switch (this) {
    connect || disconnect || toggle || close => true,
    open || importProfile || addProfile => false,
  };

  static ReClashCommand? tryParse(String value) {
    return ReClashCommand.values
        .where((item) => item.host == value)
        .firstOrNull;
  }
}

class IncomingCommand {
  const IncomingCommand({required this.command, this.payload});

  final ReClashCommand command;

  final String? payload;
}

/// Null when there is nothing to import; a stray `VIEW` intent must stay inert.
IncomingLink? parseIncomingLink(Uri uri) {
  if (configProtocolSchemes.contains(uri.scheme)) {
    if (uri.host == 'install-config') {
      final url = uri.queryParameters['url'];
      if (url == null || url.isEmpty) {
        return null;
      }
      return IncomingLink(url, name: _label(uri));
    }
    if (uri.scheme == 'reclash') {
      return null;
    }
    return null;
  }
  if (deepLinkProtocolSchemes.contains(uri.scheme) ||
      shareProtocolSchemes.contains(uri.scheme)) {
    return IncomingLink(uri.toString());
  }
  return null;
}

/// Null when the command is unknown or its payload is missing.
IncomingCommand? parseReClashCommand(Uri uri) {
  if (uri.scheme != 'reclash') {
    return null;
  }
  if (uri.host.isEmpty) {
    return null;
  }
  final command = ReClashCommand.tryParse(uri.host);
  if (command == null) {
    return null;
  }
  final argument = uri.path.isEmpty
      ? ''
      : Uri.decodeComponent(uri.path.substring(1)).trim();
  switch (command) {
    case ReClashCommand.importProfile:
      if (argument.isEmpty) return null;
    case ReClashCommand.addProfile:
      if (argument.isEmpty) return null;
    case ReClashCommand.connect:
    case ReClashCommand.disconnect:
    case ReClashCommand.toggle:
    case ReClashCommand.open:
    case ReClashCommand.close:
      break;
  }
  return IncomingCommand(
    command: command,
    payload: argument.isEmpty ? null : argument,
  );
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
    commonPrint.log('onAppLink: ${uri.scheme}://${uri.host}');
    if (!allProtocolSchemes.contains(uri.scheme)) {
      return;
    }
    onLink(uri);
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
