/// Amnezia / WireGuard `.conf` import: INI text in, a mihomo wireguard proxy
/// map out. The `amneziawg://`/`awg://` links, the Amnezia app's `vpn://`
/// share links, and the INCY amneziawg JSON container all funnel through the
/// same parser; obfuscation lands in mihomo's `amnezia-wg-option`.
library;

import 'dart:convert';
import 'dart:io' show ZLibDecoder;

import 'skipped_node.dart';
import 'subscription_links.dart';

class WireguardConfResult implements ConvertedSubscription {
  const WireguardConfResult({required this.config, this.skipped = const []});

  @override
  final String config;

  @override
  final List<SkippedNode> skipped;
}

bool isWireguardConfInput(String body) {
  final trimmed = body.trim();
  if (trimmed.isEmpty) return false;
  if (_looksLikeConf(trimmed)) return true;
  final decoded = tryBase64Decode(trimmed);
  return decoded != null && _looksLikeConf(decoded);
}

WireguardConfResult? tryConvertWireguardConf(String body) {
  final trimmed = body.trim();
  var conf = trimmed;
  if (!_looksLikeConf(conf)) {
    conf = tryBase64Decode(trimmed) ?? '';
  }
  final proxy = _looksLikeConf(conf) ? parseAwgConf(conf) : null;
  if (proxy == null) return null;
  return WireguardConfResult(config: emitProxiesConfig([proxy]));
}

bool _looksLikeConf(String text) {
  final lower = text.toLowerCase();
  return lower.contains('[interface]') && lower.contains('privatekey');
}

Map<String, Object?>? parseAwgConf(String conf, {String? name}) {
  final (interface, peer, comments) = _parseIni(conf);
  final privateKey = interface['privatekey'];
  final endpoint = peer['endpoint'];
  if (privateKey == null || privateKey.isEmpty) return null;
  final split = endpoint == null ? null : splitHostPort(endpoint);
  if (split == null) return null;
  final (server, port) = split;

  final publicKey = peer['publickey'];
  final presharedKey = peer['presharedkey'];
  final peerMap = <String, Object?>{
    'server': server,
    'port': port,
    if ((publicKey ?? '').isNotEmpty) 'public-key': _normalizeKey(publicKey!),
    if ((presharedKey ?? '').isNotEmpty)
      'pre-shared-key': _normalizeKey(presharedKey!),
    'allowed-ips': [_normalizeAllowedIps(peer['allowedips'])],
  };

  final proxy = <String, Object?>{
    'name': name ?? _commentName(comments) ?? server,
    'type': 'wireguard',
    'server': server,
    'port': port,
    'private-key': _normalizeKey(privateKey),
    // mihomo requires ip/ipv6 as empty strings, not null, when one is absent.
    'ip': '',
    'ipv6': '',
    if ((interface['address'] ?? '').isNotEmpty)
      ...splitWireguardAddresses(interface['address']!),
    'peers': [peerMap],
    'udp': true,
  };
  final mtu = int.tryParse(interface['mtu'] ?? '');
  if (mtu != null && mtu > 0) proxy['mtu'] = mtu;
  final dns = interface['dns'];
  if (dns != null && dns.isNotEmpty) {
    proxy['dns'] = [
      for (final entry in dns.split(','))
        if (entry.trim().isNotEmpty) entry.trim(),
    ];
  }
  // A 3.x keepalive may be a `min-max` range; any value inside it is valid.
  final keepalive = _leadingInt(peer['persistentkeepalive']);
  if (keepalive != null && keepalive > 0) {
    proxy['persistent-keepalive'] = keepalive;
  }
  final option = _amneziaOption(interface);
  if (option != null) proxy['amnezia-wg-option'] = option;
  return proxy;
}

/// `[Interface]` and `[Device]` describe the same device and merge; only the
/// first `[Peer]` is kept.
(Map<String, String>, Map<String, String>, List<String>) _parseIni(String text) {
  final interface = <String, String>{};
  final peer = <String, String>{};
  final comments = <String>[];
  Map<String, String>? section;
  var peerIndex = -1;
  for (final rawLine in text.split('\n')) {
    final line = rawLine.trim();
    if (line.isEmpty) continue;
    if (line.startsWith('#') || line.startsWith(';')) {
      comments.add(line.replaceFirst(RegExp(r'^[#;]\s*'), ''));
      continue;
    }
    if (line.startsWith('[') && line.endsWith(']')) {
      switch (line.substring(1, line.length - 1).trim().toLowerCase()) {
        case 'interface' || 'device':
          section = interface;
        case 'peer':
          peerIndex++;
          section = peerIndex == 0 ? peer : null;
        default:
          section = null;
      }
      continue;
    }
    final eq = line.indexOf('=');
    if (eq <= 0 || section == null) continue;
    section[line.substring(0, eq).trim().toLowerCase()] =
        line.substring(eq + 1).trim();
  }
  return (interface, peer, comments);
}

String? _commentName(List<String> comments) {
  for (final comment in comments) {
    final match = RegExp(
      r'^name\s*=\s*(.+)$',
      caseSensitive: false,
    ).firstMatch(comment);
    if (match != null) return match.group(1)!.trim();
  }
  if (comments.length == 1 && comments.first.isNotEmpty) {
    return comments.first;
  }
  return null;
}

String _normalizeAllowedIps(String? allowedIps) {
  final joined = [
    for (final entry in (allowedIps ?? '').split(','))
      if (entry.trim().isNotEmpty) entry.trim(),
  ].join(',');
  return joined.isEmpty ? '0.0.0.0/0,::/0' : joined;
}

int? _leadingInt(String? value) {
  if (value == null) return null;
  final match = RegExp(r'\d+').firstMatch(value);
  return match == null ? null : int.tryParse(match.group(0)!);
}

const _v3StringKeys = {
  'header-protection-key': 'headerprotectionkey',
  'content-padding-addition': 'contentpaddingaddition',
  'rekey-after-time': 'rekeyaftertime',
  'rekey-timeout': 'rekeytimeout',
  'reject-after-time': 'rejectaftertime',
  'keepalive-timeout': 'keepalivetimeout',
  'max-handshake-attempts': 'maxhandshakeattempts',
};

const _v3BoolKeys = {
  'random-trailers': 'randomtrailers',
  'disable-cookies': 'disablecookies',
};

Map<String, Object?>? _amneziaOption(Map<String, String> fields) {
  final option = <String, Object?>{};
  for (final key in const [
    'jc', 'jmin', 'jmax', 's1', 's2', 's3', 's4',
  ]) {
    final value = int.tryParse(fields[key] ?? '');
    if (value != null && value != 0) option[key] = value;
  }
  for (final key in const ['h1', 'h2', 'h3', 'h4']) {
    final value = fields[key];
    // v1 values are uint32, v2+ also `min-max` ranges; both ride as strings.
    if (value != null && value.isNotEmpty) option[key] = value;
  }
  final hasV3 = _hasV3Markers(fields);
  if (!hasV3) {
    // i1-i5 are v1.5-only; mihomo's v3 implementation rejects them combined.
    for (final key in const ['i1', 'i2', 'i3', 'i4', 'i5']) {
      final value = fields[key];
      if (value != null && value.isNotEmpty) option[key] = value;
    }
  } else {
    option['version'] = 3;
    for (final entry in _v3StringKeys.entries) {
      final value = fields[entry.value];
      if (value != null && value.isNotEmpty) option[entry.key] = value;
    }
    for (final entry in _v3BoolKeys.entries) {
      final value = _parseBool(fields[entry.value]);
      if (value != null) option[entry.key] = value;
    }
    final hpk = fields['headerprotectionkey'];
    if (hpk != null && hpk.isNotEmpty) {
      option['header-protection-key'] = _normalizeKey(hpk);
    }
  }
  return option.isEmpty ? null : option;
}

bool _hasV3Markers(Map<String, String> fields) =>
    _v3StringKeys.values.any((k) => (fields[k] ?? '').isNotEmpty) ||
    _v3BoolKeys.values.any((k) => _parseBool(fields[k]) == true);

bool? _parseBool(String? value) {
  if (value == null) return null;
  switch (value.trim().toLowerCase()) {
    case 'on' || 'yes' || 'true' || '1' || 'enabled':
      return true;
    case 'off' || 'no' || 'false' || '0' || 'disabled':
      return false;
    default:
      return null;
  }
}

/// Keys arrive as base64 (`awg genkey` output) or hex; mihomo decodes base64.
final _hexKey = RegExp(r'^[0-9a-fA-F]{64}$');

String _normalizeKey(String value) {
  if (!_hexKey.hasMatch(value)) return value;
  final bytes = <int>[
    for (var i = 0; i < value.length; i += 2)
      int.parse(value.substring(i, i + 2), radix: 16),
  ];
  return base64.encode(bytes);
}

/// `vpn://` + base64url over a raw `.conf` (3x-ui) or a Qt `qCompress`'d
/// JSON config (Amnezia app): a 4-byte big-endian size prefix then zlib.
/// WireGuard-family containers become proxies; the rest become named skips.
(List<Map<String, Object?>>, List<SkippedNode>) parseVpnLink(String payload) {
  final bytes = _tryBase64Bytes(payload);
  if (bytes == null) return (const [], const []);
  final uncompressed = _tryQtUncompress(bytes);
  for (final text in [
    ?uncompressed,
    utf8.decode(bytes, allowMalformed: true),
  ]) {
    final (proxies, skipped) = _parseAmneziaText(text);
    if (proxies.isNotEmpty || skipped.isNotEmpty) return (proxies, skipped);
  }
  return (const [], const []);
}

(List<Map<String, Object?>>, List<SkippedNode>) _parseAmneziaText(String text) {
  final decoded = _tryJson(text);
  if (decoded is Map<String, Object?> && decoded['containers'] is List) {
    return _parseContainers(decoded);
  }
  final proxy = _looksLikeConf(text) ? parseAwgConf(text) : null;
  return (proxy == null ? const [] : [proxy], const []);
}

(List<Map<String, Object?>>, List<SkippedNode>) _parseContainers(
  Map<String, Object?> share,
) {
  final proxies = <Map<String, Object?>>[];
  final skipped = <SkippedNode>[];
  for (final entry in share['containers']! as List) {
    if (entry is! Map<String, Object?>) continue;
    final containerName = entry['container']?.toString();
    final isWireguardFamily = containerName != null &&
        const ['amnezia-awg', 'amnezia-wg', 'wireguard', 'awg']
            .contains(containerName);
    Map<String, Object?>? protocolConfig;
    for (final key in const ['amnezia-awg', 'wireguard']) {
      if (entry[key] is Map<String, Object?>) {
        protocolConfig = entry[key]! as Map<String, Object?>;
      }
    }
    if (protocolConfig == null &&
        isWireguardFamily &&
        entry[containerName] is Map<String, Object?>) {
      protocolConfig = entry[containerName]! as Map<String, Object?>;
    }
    if (protocolConfig == null) {
      final kind = containerName ?? 'container';
      skipped.add(SkippedNode(
        name: kind,
        kind: kind,
        reason: SkippedNodeReason.protocol,
      ));
      continue;
    }
    final proxy = _convertAmneziaContainer(share, protocolConfig);
    if (proxy != null) proxies.add(proxy);
  }
  return (proxies, skipped);
}

Map<String, Object?>? _convertAmneziaContainer(
  Map<String, Object?> share,
  Map<String, Object?> protocolConfig,
) {
  final lastConfig = _tryJson(protocolConfig['last_config']?.toString() ?? '');
  final source =
      lastConfig is Map<String, Object?> ? lastConfig : protocolConfig;
  final client = source['clientConfig'] is Map<String, Object?>
      ? source['clientConfig']! as Map<String, Object?>
      : source;
  final shareName = share['description']?.toString();

  final conf = (source['config'] ?? client['config'])?.toString();
  if (conf != null && conf.isNotEmpty) {
    return parseAwgConf(conf, name: shareName);
  }

  // Older exports flatten the client fields; rebuild a .conf and reparse.
  final privateKey = client['client_priv_key']?.toString() ?? '';
  final serverPublicKey = client['server_pub_key']?.toString() ?? '';
  final host =
      client['hostName']?.toString() ?? share['hostName']?.toString() ?? '';
  final port = _toInt(client['port']);
  final psk = client['psk_key']?.toString() ?? '';
  if (privateKey.isEmpty ||
      serverPublicKey.isEmpty ||
      host.isEmpty ||
      port == null ||
      // The values ride through an INI round-trip; a newline would inject.
      [privateKey, serverPublicKey, host, psk]
          .any((value) => value.contains(RegExp(r'[\r\n]')))) {
    return null;
  }
  final buffer = StringBuffer('[Interface]\n')
    ..writeln('PrivateKey = $privateKey');
  final address = _flatAddress(client);
  if (address != null) buffer.writeln('Address = $address');
  for (final key in _awgConfKeys) {
    final value = source[key]?.toString();
    if (value != null && value.isNotEmpty && !value.contains('\n')) {
      buffer.writeln('$key = $value');
    }
  }
  buffer
    ..writeln('[Peer]')
    ..writeln('PublicKey = $serverPublicKey');
  if (psk.isNotEmpty) buffer.writeln('PresharedKey = $psk');
  buffer.writeln('Endpoint = $host:$port');
  return parseAwgConf(buffer.toString(), name: shareName);
}

String? _flatAddress(Map<String, Object?> client) {
  final clientIp = client['client_ip']?.toString();
  if (clientIp != null && clientIp.isNotEmpty) return clientIp;
  final allowedIps = client['allowed_ips'];
  if (allowedIps is List && allowedIps.isNotEmpty) {
    return allowedIps.map((e) => e.toString()).join(',');
  }
  return null;
}

const _awgConfKeys = [
  'Jc', 'Jmin', 'Jmax', 'S1', 'S2', 'S3', 'S4',
  'H1', 'H2', 'H3', 'H4', 'I1', 'I2', 'I3', 'I4', 'I5',
  'HeaderProtectionKey', 'ContentPaddingAddition', 'RekeyAfterTime',
  'RekeyTimeout', 'RejectAfterTime', 'KeepaliveTimeout',
  'MaxHandshakeAttempts', 'RandomTrailers', 'DisableCookies',
];

Object? _tryJson(String body) {
  try {
    return jsonDecode(body);
  } catch (_) {
    return null;
  }
}

int? _toInt(Object? value) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  if (value is num) return value.toInt();
  return null;
}

/// Byte-level counterpart of `tryBase64Decode`: qCompress payloads are not
/// valid UTF-8, so a string decode would corrupt them.
List<int>? _tryBase64Bytes(String input) {
  final clean = input.replaceAll(RegExp(r'\s'), '');
  if (clean.isEmpty) return null;
  final padded = clean.padRight((clean.length + 3) ~/ 4 * 4, '=');
  final normalized = padded.replaceAll('-', '+').replaceAll('_', '/');
  try {
    return base64.decode(normalized);
  } catch (_) {
    return null;
  }
}

String? _tryQtUncompress(List<int> bytes) {
  if (bytes.length <= 4) return null;
  try {
    return utf8.decode(
      ZLibDecoder().convert(bytes.sublist(4)),
      allowMalformed: true,
    );
  } catch (_) {
    return null;
  }
}
