import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

const fixLinkMaxBytes = 2048;
const fixLinkMaxLifetime = Duration(days: 7);
const fixLinkReportAge = Duration(days: 30);
const _maxActions = 16;
const _maxArgument = 256;

/// Why a fix link was refused, one per check and in the order they run.
enum FixLinkRejection {
  oversized,
  malformed,
  unknownKey,
  badSignature,
  expired,
  tooFarAhead,
  replayed,
  unknownReport,
  otherProfile,
  unknownAction,
  unknownGroup,
}

class FixLinkRejected implements Exception {
  const FixLinkRejected(this.reason);

  final FixLinkRejection reason;

  @override
  String toString() => 'FixLinkRejected(${reason.name})';
}

enum FixActionKind {
  remedy,
  profileUpdate,
  profileActivate,
  proxySelect,
  connectionsReset,
  coreRestart,
  overridesReset,
}

const _fixedActions = {
  'profile.update': FixActionKind.profileUpdate,
  'profile.activate': FixActionKind.profileActivate,
  'proxy.select': FixActionKind.proxySelect,
  'connections.reset': FixActionKind.connectionsReset,
  'core.restart': FixActionKind.coreRestart,
  'overrides.reset': FixActionKind.overridesReset,
};

@immutable
final class FixAction {
  const FixAction(this.id, {this.group, this.node});

  final String id;
  final String? group;
  final String? node;

  /// Anything not fixed here names a catalogue remedy.
  FixActionKind get kind => _fixedActions[id] ?? FixActionKind.remedy;

  @override
  bool operator ==(Object other) =>
      other is FixAction &&
      other.id == id &&
      other.group == group &&
      other.node == node;

  @override
  int get hashCode => Object.hash(id, group, node);

  @override
  String toString() => group == null ? id : '$id($group, $node)';
}

@immutable
final class FixPayload {
  const FixPayload({
    required this.keyId,
    required this.reportId,
    required this.expires,
    required this.nonce,
    required this.actions,
  });

  final String keyId;
  final String reportId;
  final DateTime expires;
  final String nonce;
  final List<FixAction> actions;
}

/// A parsed link whose signature is still unchecked.
@immutable
final class FixLinkEnvelope {
  const FixLinkEnvelope({
    required this.payload,
    required this.signed,
    required this.signature,
  });

  final FixPayload payload;

  /// Exactly the bytes the signature covers.
  final Uint8List signed;
  final Uint8List signature;
}

final _base64Url = RegExp(r'^[A-Za-z0-9_-]*$');
final _reportId = RegExp(r'^RC-[0-9A-HJKMNP-TV-Z]{4}-[0-9A-HJKMNP-TV-Z]{4}$');
final _actionId = RegExp(r'^[a-z][A-Za-z0-9]*(\.[A-Za-z][A-Za-z0-9]*)+$');
final _controls = RegExp(r'[\x00-\x1f\x7f]');
const _payloadKeys = {'v', 'kid', 'rid', 'exp', 'nonce', 'fix'};

String encodeBase64Url(List<int> bytes) =>
    base64Url.encode(bytes).replaceAll('=', '');

/// Unpadded base64url in its one canonical spelling, else null.
Uint8List? decodeBase64Url(String text) {
  if (!_base64Url.hasMatch(text) || text.length % 4 == 1) return null;
  try {
    final bytes = base64Url.decode(base64Url.normalize(text));
    return encodeBase64Url(bytes) == text ? bytes : null;
  } on FormatException {
    return null;
  }
}

/// The first 8 bytes of the key's SHA-256, in base64url.
String supportKeyId(List<int> key) =>
    encodeBase64Url(sha256.convert(key).bytes.sublist(0, 8));

/// The raw 32-byte key of one `ed25519:<base64url>` header value.
Uint8List? parseSupportKey(String value) {
  if (!value.startsWith('ed25519:')) return null;
  final bytes = decodeBase64Url(value.substring(8));
  return bytes?.length == 32 ? bytes : null;
}

/// Check 1: size, shape and fields; nothing else is trusted yet.
FixLinkEnvelope parseFixLink(String input) {
  if (utf8.encode(input).length > fixLinkMaxBytes) {
    throw const FixLinkRejected(FixLinkRejection.oversized);
  }
  const malformed = FixLinkRejected(FixLinkRejection.malformed);
  final uri = Uri.tryParse(input.trim());
  if (uri == null ||
      uri.scheme != 'reclash' ||
      uri.host != 'fix' ||
      uri.userInfo.isNotEmpty ||
      uri.hasPort ||
      uri.hasFragment ||
      uri.path.isNotEmpty && uri.path != '/') {
    throw malformed;
  }
  final parameters = <String, String>{};
  for (final part in uri.query.split('&')) {
    final separator = part.indexOf('=');
    if (separator <= 0) throw malformed;
    final key = part.substring(0, separator);
    if (parameters.containsKey(key)) throw malformed;
    parameters[key] = part.substring(separator + 1);
  }
  if (parameters.length != 2) throw malformed;
  final signed = decodeBase64Url(parameters['p'] ?? '');
  final signature = decodeBase64Url(parameters['s'] ?? '');
  if (signed == null || signed.isEmpty || signature?.length != 64) {
    throw malformed;
  }
  final Object? json;
  try {
    json = jsonDecode(utf8.decode(signed));
  } on FormatException {
    throw malformed;
  }
  return FixLinkEnvelope(
    payload: _payload(json) ?? (throw malformed),
    signed: signed,
    signature: signature!,
  );
}

FixPayload? _payload(Object? json) {
  if (json is! Map<String, Object?> ||
      json.length != _payloadKeys.length ||
      !json.keys.every(_payloadKeys.contains)) {
    return null;
  }
  final (v, kid, rid, exp, nonce, fix) = (
    json['v'],
    json['kid'],
    json['rid'],
    json['exp'],
    json['nonce'],
    json['fix'],
  );
  if (v != 1 ||
      kid is! String ||
      decodeBase64Url(kid)?.length != 8 ||
      rid is! String ||
      !_reportId.hasMatch(rid) ||
      exp is! int ||
      exp <= 0 ||
      nonce is! String ||
      decodeBase64Url(nonce)?.length != 12 ||
      fix is! List ||
      fix.isEmpty ||
      fix.length > _maxActions) {
    return null;
  }
  final actions = <FixAction>[];
  for (final entry in fix) {
    final action = _action(entry);
    if (action == null) return null;
    actions.add(action);
  }
  return FixPayload(
    keyId: kid,
    reportId: rid,
    expires: DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true),
    nonce: nonce,
    actions: List.unmodifiable(actions),
  );
}

FixAction? _action(Object? entry) {
  if (entry is! Map<String, Object?>) return null;
  final id = entry['id'];
  if (id is! String || id.length > 64 || !_actionId.hasMatch(id)) return null;
  if (_fixedActions[id] != FixActionKind.proxySelect) {
    return entry.length == 1 ? FixAction(id) : null;
  }
  final group = _argument(entry['group']);
  final node = _argument(entry['node']);
  if (entry.length != 3 || group == null || node == null) return null;
  return FixAction(id, group: group, node: node);
}

String? _argument(Object? value) =>
    value is String &&
        value.isNotEmpty &&
        value.length <= _maxArgument &&
        !_controls.hasMatch(value)
    ? value
    : null;
