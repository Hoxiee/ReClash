import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/widgets.dart' show BuildContext;
import 'package:reclash/common/url_scheme.dart';
import 'package:reclash/common/protocol.dart';

import 'compatibility/clients.dart';
import 'transport/transport.dart';

typedef ProfileLinkInput = ({String label, String url, String ageSecretKey});

typedef ProfileLinkCommit =
    Future<void> Function(
      ProfileLinkImport choice, {
      BuildContext? reviewContext,
      SubscriptionCancellation? cancellation,
    });

class ProfileLinkSource {
  const ProfileLinkSource({
    this.url,
    this.bytes,
    this.name,
    this.preset,
    this.shareLink,
  });

  final String? url;
  final Uint8List? bytes;
  final String? name;
  final SubscriptionClientPreset? preset;
  final String? shareLink;

  String get displaySource => url != null
      ? profileLinkDisplaySource(url!)
      : shareLink != null
      ? profileLinkDisplaySource(shareLink!)
      : '';
}

class ProfileLinkImport {
  const ProfileLinkImport({
    this.clientSettings = const SubscriptionClientSettings.forNewProfile(),
    this.label,
  });

  final SubscriptionClientSettings clientSettings;
  final String? label;
}

Future<ProfileLinkSource> resolveProfileLink(String input) => Isolate.run(() {
  if (input.length > urlSchemeMaxLength) {
    throw const UrlSchemeException(UrlSchemeIssue.tooLarge);
  }
  return _resolve(_decodeEncodedProtocolLink(input.trim()), 0);
});

String _decodeEncodedProtocolLink(String input) {
  if (Uri.tryParse(input)?.hasScheme == true) return input;
  try {
    final decoded = Uri.decodeComponent(input);
    final scheme = Uri.tryParse(decoded)?.scheme;
    return protocolSchemes.contains(scheme) ? decoded : input;
  } on FormatException {
    return input;
  }
}

Future<ProfileLinkSource> _resolve(String input, int depth) async {
  if (depth > urlSchemeMaxDepth) {
    throw const UrlSchemeException(UrlSchemeIssue.tooDeep);
  }
  final uri = checkedLinkUri(input);
  if (isSubscriptionUrl(input)) {
    final embedded = _embeddedLink(input, uri);
    return embedded == null
        ? ProfileLinkSource(url: input)
        : _resolve(embedded, depth + 1);
  }
  if (uri.scheme == 'http' || uri.scheme == 'https') {
    throw const UrlSchemeException(UrlSchemeIssue.invalidUrl);
  }
  final command = parseUrlSchemeLink(input);
  if (command != null) {
    if (!command.command.isProfile) {
      throw const UrlSchemeException(UrlSchemeIssue.invalidLink);
    }
    return command.command == ReClashCommand.importProfile
        ? ProfileLinkSource(
            bytes: await decodeUrlSchemeConfig(command.payload!),
            name: command.name,
          )
        : _withMetadata(
            await _resolve(command.payload!, depth + 1),
            name: command.name,
          );
  }
  if (shareProtocolSchemes.contains(uri.scheme)) {
    if (input.length <= uri.scheme.length + 3) {
      throw const UrlSchemeException(UrlSchemeIssue.missingPayload);
    }
    return ProfileLinkSource(shareLink: input);
  }
  if (!deepLinkProtocolSchemes.contains(uri.scheme) ||
      uri.userInfo.isNotEmpty ||
      uri.hasPort) {
    throw const UrlSchemeException(UrlSchemeIssue.invalidLink);
  }
  if (uri.host.startsWith('crypt') &&
      (uri.scheme != 'incy' || uri.host != 'crypt1')) {
    throw const UrlSchemeException(UrlSchemeIssue.unsupportedEncryption);
  }
  if (uri.scheme == 'incy' && uri.host == 'crypt1') {
    if (uri.hasQuery || uri.hasFragment) {
      throw const UrlSchemeException(UrlSchemeIssue.invalidLink);
    }
    if (uri.path.length <= 1) {
      throw const UrlSchemeException(UrlSchemeIssue.missingPayload);
    }
    return _decryptCrypt1(uri.path.substring(1).replaceAll(RegExp(r'/+$'), ''));
  }
  if (uri.scheme == 'incy' && !{'add', 'import'}.contains(uri.host) ||
      uri.scheme == 'happ' && uri.host != 'add') {
    throw const UrlSchemeException(UrlSchemeIssue.unknownCommand);
  }
  if (uri.path.length <= 1) {
    throw const UrlSchemeException(UrlSchemeIssue.missingPayload);
  }
  final path = uri.path.substring(1);
  final rawUrl = path.startsWith('https://') || path.startsWith('http://');
  String payload;
  try {
    payload = rawUrl
        ? '$path${uri.hasQuery ? '?${uri.query}' : ''}'
              '${uri.hasFragment ? '#${uri.fragment}' : ''}'
        : Uri.decodeComponent(path);
  } on FormatException {
    throw const UrlSchemeException(UrlSchemeIssue.invalidLink);
  }
  final preset = uri.scheme == 'incy'
      ? SubscriptionClientPreset.incy
      : SubscriptionClientPreset.happ;
  final parameters = rawUrl
      ? <String, List<String>>{}
      : checkedLinkParameters(uri);
  if (parameters.entries.any(
        (entry) => entry.key != 'name' || entry.value.length != 1,
      ) ||
      !rawUrl && uri.hasFragment) {
    throw const UrlSchemeException(UrlSchemeIssue.invalidLink);
  }
  final name = checkedLinkName(parameters['name']?.single);
  var content = payload;
  Uint8List bytes;
  try {
    bytes = base64.decode(base64.normalize(payload.trim()));
    content = utf8.decode(bytes);
  } on FormatException {
    bytes = Uint8List.fromList(utf8.encode(payload));
  }
  if (bytes.isEmpty || bytes.length > urlSchemeMaxContentBytes) {
    throw UrlSchemeException(
      bytes.isEmpty ? UrlSchemeIssue.missingPayload : UrlSchemeIssue.tooLarge,
    );
  }
  if (!content.contains('\n') &&
      !content.contains('\r') &&
      _isNestedLink(content.trim())) {
    return _withMetadata(
      await _resolve(content.trim(), depth + 1),
      name: name,
      preset: preset,
    );
  }
  return ProfileLinkSource(bytes: bytes, name: name, preset: preset);
}

bool _isNestedLink(String input) {
  final scheme = Uri.tryParse(input)?.scheme;
  return scheme == 'http' ||
      scheme == 'https' ||
      protocolSchemes.contains(scheme);
}

ProfileLinkSource _withMetadata(
  ProfileLinkSource source, {
  String? name,
  SubscriptionClientPreset? preset,
}) => ProfileLinkSource(
  url: source.url,
  bytes: source.bytes,
  shareLink: source.shareLink,
  name: name ?? source.name,
  preset: source.preset ?? preset,
);

String? _embeddedLink(String input, Uri uri) {
  final candidates = <String>{};
  for (final entry in checkedLinkParameters(uri).entries) {
    for (final value in entry.value) {
      final scheme = Uri.tryParse(value)?.scheme;
      final candidate = protocolSchemes.contains(scheme)
          ? value
          : _embeddedDeepLink(value);
      if (candidate == null) continue;
      if (entry.value.length != 1) {
        throw const UrlSchemeException(UrlSchemeIssue.invalidLink);
      }
      candidates.add(candidate);
    }
  }
  if (candidates.length > 1) {
    throw const UrlSchemeException(UrlSchemeIssue.invalidLink);
  }
  if (candidates.isNotEmpty) return candidates.single;
  try {
    return _embeddedDeepLink(Uri.decodeComponent(input));
  } on FormatException {
    throw const UrlSchemeException(UrlSchemeIssue.invalidLink);
  }
}

String? _embeddedDeepLink(String input) => RegExp(
  r'(?:incy|happ)://[^\s<>\])]+',
  caseSensitive: false,
).firstMatch(input)?.group(0);

// @incy/link-encoder (MIT): salt plus keymatA[1024:1056], keymatB[2048:2080].
const _keyPartA = '7odqBjr3BNe0CfGRDZcxzBQZCB7AiZOgEnBVaHPh7y0=';
const _keyPartB = 'z1EN9DsquX6phHju5fGxz4DjpIT8k2kxbM2H5Ut5l7c=';
const _keyFingerprint =
    'b6bf708471cc90043232967660aade86a50b4e57929db2e53c5fa34db624c08c';

Future<ProfileLinkSource> _decryptCrypt1(String payload) async {
  const nonceLength = 12;
  const tagLength = 16;
  try {
    final wire = base64.decode(base64.normalize(payload));
    if (wire.length <= nonceLength + tagLength) {
      throw const UrlSchemeException(UrlSchemeIssue.invalidBase64);
    }
    final key = sha256.convert([
      ...utf8.encode('incydeepcrypt1v2026.06'),
      ...base64.decode(_keyPartA),
      ...base64.decode(_keyPartB),
    ]).bytes;
    if (sha256.convert(key).toString() != _keyFingerprint) {
      throw const UrlSchemeException(UrlSchemeIssue.unsupportedEncryption);
    }
    final clear = await AesGcm.with256bits().decrypt(
      SecretBox(
        wire.sublist(nonceLength, wire.length - tagLength),
        nonce: wire.sublist(0, nonceLength),
        mac: Mac(wire.sublist(wire.length - tagLength)),
      ),
      secretKey: SecretKey(key),
    );
    final decoded = jsonDecode(utf8.decode(clear));
    if (decoded is! Map<String, dynamic> ||
        decoded['url'] is! String ||
        !isSubscriptionUrl(decoded['url'] as String)) {
      throw const UrlSchemeException(UrlSchemeIssue.invalidUrl);
    }
    final name = decoded['n'];
    if (name != null && name is! String) {
      throw const UrlSchemeException(UrlSchemeIssue.invalidName);
    }
    return ProfileLinkSource(
      url: decoded['url'] as String,
      name: checkedLinkName(name as String?),
      preset: SubscriptionClientPreset.incy,
    );
  } on SecretBoxAuthenticationError {
    throw const UrlSchemeException(UrlSchemeIssue.authenticationFailed);
  } on FormatException {
    throw const UrlSchemeException(UrlSchemeIssue.invalidBase64);
  }
}
