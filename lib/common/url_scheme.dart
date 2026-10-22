import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

import 'protocol.dart';

const urlSchemeMaxLength = 4 * 1024 * 1024;
const urlSchemeMaxContentBytes = 2 * 1024 * 1024;
const urlSchemeMaxDepth = 5;
const urlSchemeMaxNameLength = 64;
const urlSchemeMaxRoutingPayloadLength = 128 * 1024;

final _invalidEscape = RegExp(r'%(?![0-9a-fA-F]{2})');
final _controls = RegExp(r'[\x00-\x20\x7f]');

enum ReClashCommand {
  connect('connect'),
  disconnect('disconnect'),
  toggle('toggle'),
  open('open'),
  close('close'),
  add('add'),
  importProfile('import'),
  installConfig('install-config'),
  routing('routing');

  const ReClashCommand(this.host);

  final String host;

  bool get isProfile => switch (this) {
    add || importProfile || installConfig => true,
    _ => false,
  };

  bool get changesConnection => switch (this) {
    connect || disconnect || toggle => true,
    _ => false,
  };

  static ReClashCommand? fromHost(String host) =>
      values.where((command) => command.host == host).firstOrNull;
}

enum UrlSchemeIssue {
  invalidLink,
  unknownCommand,
  missingPayload,
  invalidUrl,
  invalidName,
  invalidBase64,
  tooLarge,
  tooDeep,
  unsupportedEncryption,
  authenticationFailed,
}

class UrlSchemeException implements Exception {
  const UrlSchemeException(this.issue);

  final UrlSchemeIssue issue;

  @override
  String toString() => 'Invalid external link: ${issue.name}';
}

class UrlSchemeLink {
  const UrlSchemeLink({required this.command, this.payload, this.name});

  final ReClashCommand command;
  final String? payload;
  final String? name;
}

Uri checkedLinkUri(String input) {
  if (input.length > urlSchemeMaxLength) {
    throw const UrlSchemeException(UrlSchemeIssue.tooLarge);
  }
  if (_invalidEscape.hasMatch(input) || _controls.hasMatch(input)) {
    throw const UrlSchemeException(UrlSchemeIssue.invalidLink);
  }
  final uri = Uri.tryParse(input);
  if (uri == null || !uri.hasScheme) {
    throw const UrlSchemeException(UrlSchemeIssue.invalidLink);
  }
  return uri;
}

Map<String, List<String>> checkedLinkParameters(Uri uri) {
  try {
    return uri.queryParametersAll;
  } on FormatException {
    throw const UrlSchemeException(UrlSchemeIssue.invalidLink);
  }
}

bool isSubscriptionUrl(String input) {
  if (input.isEmpty || input.length > urlSchemeMaxLength) return false;
  try {
    final uri = checkedLinkUri(input);
    return (uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.hasAuthority &&
        uri.host.isNotEmpty;
  } on UrlSchemeException {
    return false;
  }
}

String? checkedLinkName(String? value) {
  final name = value?.trim();
  if (name == null || name.isEmpty) return null;
  if (name.runes.length > urlSchemeMaxNameLength ||
      RegExp(r'[\x00-\x1f\x7f]').hasMatch(name)) {
    throw const UrlSchemeException(UrlSchemeIssue.invalidName);
  }
  return name;
}

Future<UrlSchemeLink?> readUrlSchemeLink(String input) =>
    Isolate.run(() => parseUrlSchemeLink(input));

UrlSchemeLink? parseUrlSchemeLink(String input) {
  if (input.length > urlSchemeMaxLength) {
    throw const UrlSchemeException(UrlSchemeIssue.tooLarge);
  }
  final uri = checkedLinkUri(input.trim());
  if (!configProtocolSchemes.contains(uri.scheme)) return null;
  final command = ReClashCommand.fromHost(uri.host);
  if (command == null ||
      uri.scheme != 'reclash' && command != ReClashCommand.installConfig) {
    throw const UrlSchemeException(UrlSchemeIssue.unknownCommand);
  }
  if (uri.userInfo.isNotEmpty || uri.hasPort) {
    throw const UrlSchemeException(UrlSchemeIssue.invalidLink);
  }
  if (command == ReClashCommand.routing) return _parseRoutingLink(uri);
  if (!command.isProfile) {
    if (uri.path.isNotEmpty && uri.path != '/' ||
        uri.hasQuery ||
        uri.hasFragment) {
      throw const UrlSchemeException(UrlSchemeIssue.invalidLink);
    }
    return UrlSchemeLink(command: command);
  }

  final path = uri.path.isEmpty ? '' : uri.path.substring(1);
  final rawUrl =
      command == ReClashCommand.add &&
      (path.startsWith('https://') || path.startsWith('http://'));
  final parameters = rawUrl
      ? <String, List<String>>{}
      : checkedLinkParameters(uri);
  final payloadKey = command == ReClashCommand.importProfile ? 'data' : 'url';
  if (parameters.entries.any(
    (entry) =>
        !{payloadKey, 'name'}.contains(entry.key) || entry.value.length != 1,
  )) {
    throw const UrlSchemeException(UrlSchemeIssue.invalidLink);
  }
  if (uri.hasFragment && !rawUrl ||
      command == ReClashCommand.installConfig && path.isNotEmpty ||
      path.isNotEmpty && parameters.containsKey(payloadKey)) {
    throw const UrlSchemeException(UrlSchemeIssue.invalidLink);
  }
  String? payload;
  try {
    payload = path.isNotEmpty
        ? rawUrl
              ? '$path${uri.hasQuery ? '?${uri.query}' : ''}'
                    '${uri.hasFragment ? '#${uri.fragment}' : ''}'
              : Uri.decodeComponent(path)
        : parameters[payloadKey]?.single;
  } on FormatException {
    throw const UrlSchemeException(UrlSchemeIssue.invalidLink);
  }
  payload = payload?.trim();
  if (payload == null || payload.isEmpty) {
    throw const UrlSchemeException(UrlSchemeIssue.missingPayload);
  }
  if (command != ReClashCommand.importProfile && !isSubscriptionUrl(payload)) {
    throw const UrlSchemeException(UrlSchemeIssue.invalidUrl);
  }
  return UrlSchemeLink(
    command: command,
    payload: payload,
    name: checkedLinkName(parameters['name']?.single),
  );
}

UrlSchemeLink _parseRoutingLink(Uri uri) {
  final parameters = checkedLinkParameters(uri);
  if ((uri.path.isNotEmpty && uri.path != '/') ||
      uri.hasFragment ||
      parameters.length != 1 ||
      !{'p', 'url'}.contains(parameters.keys.single) ||
      parameters.values.single.length != 1) {
    throw const UrlSchemeException(UrlSchemeIssue.invalidLink);
  }
  final value = parameters.values.single.single.trim();
  if (value.isEmpty) {
    throw const UrlSchemeException(UrlSchemeIssue.missingPayload);
  }
  if (parameters.keys.single == 'url') {
    if (!value.startsWith('https://') || !isSubscriptionUrl(value)) {
      throw const UrlSchemeException(UrlSchemeIssue.invalidUrl);
    }
  } else if (value.length > urlSchemeMaxRoutingPayloadLength) {
    throw const UrlSchemeException(UrlSchemeIssue.tooLarge);
  }
  return UrlSchemeLink(command: ReClashCommand.routing, payload: value);
}

bool isProfileLinkInput(String input) {
  if (input.length > urlSchemeMaxLength) return false;
  final text = input.trim();
  try {
    final uri = checkedLinkUri(text);
    if (isSubscriptionUrl(text)) return true;
    if (shareProtocolSchemes.contains(uri.scheme)) {
      return text.length > uri.scheme.length + 3;
    }
    if (deepLinkProtocolSchemes.contains(uri.scheme)) {
      return uri.path.length > 1 &&
          switch (uri.scheme) {
            'incy' => {'crypt1', 'add', 'import'}.contains(uri.host),
            'happ' => uri.host == 'add',
            _ => false,
          };
    }
    return parseUrlSchemeLink(text)?.command.isProfile == true;
  } on UrlSchemeException {
    return false;
  } on FormatException {
    return false;
  }
}

Future<Uint8List> decodeUrlSchemeConfig(String payload) => Isolate.run(() {
  if (payload.length > urlSchemeMaxLength) {
    throw const UrlSchemeException(UrlSchemeIssue.tooLarge);
  }
  try {
    final bytes = base64.decode(base64.normalize(payload));
    if (bytes.isEmpty) {
      throw const UrlSchemeException(UrlSchemeIssue.missingPayload);
    }
    if (bytes.length > urlSchemeMaxContentBytes) {
      throw const UrlSchemeException(UrlSchemeIssue.tooLarge);
    }
    utf8.decode(bytes);
    return bytes;
  } on FormatException {
    throw const UrlSchemeException(UrlSchemeIssue.invalidBase64);
  }
});

Future<String> buildUrlSchemeLink(
  ReClashCommand command, {
  String payload = '',
  String name = '',
}) => Isolate.run(() {
  final label = checkedLinkName(name);
  String? data;
  if (command.isProfile) {
    final value = payload.trim();
    if (value.isEmpty) {
      throw const UrlSchemeException(UrlSchemeIssue.missingPayload);
    }
    if (command == ReClashCommand.importProfile) {
      final bytes = utf8.encode(payload);
      if (bytes.length > urlSchemeMaxContentBytes) {
        throw const UrlSchemeException(UrlSchemeIssue.tooLarge);
      }
      data = base64Url.encode(bytes);
    } else {
      if (!isSubscriptionUrl(value)) {
        throw const UrlSchemeException(UrlSchemeIssue.invalidUrl);
      }
      data = value;
    }
  } else if (command == ReClashCommand.routing) {
    final value = payload.trim();
    if (value.isEmpty) {
      throw const UrlSchemeException(UrlSchemeIssue.missingPayload);
    }
    if (label != null) {
      throw const UrlSchemeException(UrlSchemeIssue.invalidLink);
    }
    data = value;
  } else if (payload.isNotEmpty || label != null) {
    throw const UrlSchemeException(UrlSchemeIssue.invalidLink);
  }
  final uri = Uri(
    scheme: 'reclash',
    host: command.host,
    queryParameters: command == ReClashCommand.routing
        ? {data!.startsWith('https://') ? 'url' : 'p': data}
        : command.isProfile
        ? {
            command == ReClashCommand.importProfile ? 'data' : 'url': data!,
            'name': ?label,
          }
        : null,
  ).toString();
  if (uri.length > urlSchemeMaxLength) {
    throw const UrlSchemeException(UrlSchemeIssue.tooLarge);
  }
  return uri;
});

String profileLinkDisplaySource(String input) {
  final uri = Uri.tryParse(input);
  if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
    return Uri(
      scheme: uri.scheme,
      host: uri.host,
      port: uri.hasPort ? uri.port : null,
    ).toString();
  }
  return uri == null ? '' : '${uri.scheme}://';
}
