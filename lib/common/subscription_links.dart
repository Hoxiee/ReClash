/// Share-link import: bare proxy URIs and base64 node lists in, a complete
/// Clash config out, entirely locally; amnezia converts via amnezia_config.dart.
library;

import 'dart:convert';

import 'amnezia_config.dart';
import 'skipped_node.dart';

const _schemes = [
  'vmess://',
  'vless://',
  'ss://',
  'trojan://',
  'hysteria2://',
  'hy2://',
  'tuic://',
  'anytls://',
  'hysteria://',
  'socks://',
  'socks5://',
  'wireguard://',
  'wg://',
  'amneziawg://',
  'awg://',
  'vpn://',
];

abstract interface class ConvertedSubscription {
  String get config;

  List<SkippedNode> get skipped;
}

class ShareLinksResult implements ConvertedSubscription {
  const ShareLinksResult({required this.config, this.skipped = const []});

  @override
  final String config;

  @override
  final List<SkippedNode> skipped;
}

/// Link input mihomo cannot dial — routed to the converter, not the network.
const _unsupportedSchemes = [
  'ssr://',
];

bool _isLinkLine(String line) =>
    _schemes.any(line.startsWith) || _unsupportedSchemes.any(line.startsWith);

bool isShareLinkInput(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return false;
  if (_isLinkLine(trimmed)) return true;
  if (trimmed.contains('\n')) {
    return trimmed
        .split(RegExp(r'[\r\n]+'))
        .any((line) => _isLinkLine(line.trim()));
  }
  final decoded = tryBase64Decode(trimmed);
  return decoded != null && isShareLinkInput(decoded);
}

ShareLinksResult? tryConvertShareLinks(String raw) {
  final (proxies, skipped) = _scanShareLinks(raw);
  if (proxies.isEmpty) return null;
  return ShareLinksResult(config: emitProxiesConfig(proxies), skipped: skipped);
}

List<SkippedNode> probeUnsupportedShareLinks(String raw) {
  final (proxies, skipped) = _scanShareLinks(raw);
  return proxies.isEmpty ? skipped : const [];
}

(List<Map<String, Object?>>, List<SkippedNode>) _scanShareLinks(String raw) {
  final proxies = <Map<String, Object?>>[];
  final skipped = <SkippedNode>[];
  final seen = <String>{};

  void addProxy(Map<String, Object?>? proxy) {
    if (proxy == null) return;
    var name = proxy['name']! as String;
    // Duplicates would collapse into one entry in any group; number them.
    var suffix = 2;
    while (seen.contains(name)) {
      name = '${proxy['name']} $suffix';
      suffix++;
    }
    proxy['name'] = name;
    seen.add(name);
    proxies.add(proxy);
  }

  void addFrom(String text) {
    for (final line in text.split(RegExp(r'[\r\n]+'))) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      if (_unsupportedSchemes.any(trimmed.startsWith)) {
        skipped.add(_unsupportedSchemeNode(trimmed));
        continue;
      }
      if (trimmed.startsWith('vpn://')) {
        final (vpnProxies, vpnSkipped) = parseVpnLink(
          trimmed.substring('vpn://'.length),
        );
        skipped.addAll(vpnSkipped);
        vpnProxies.forEach(addProxy);
        continue;
      }
      // Parsers walk arbitrary provider text; a throw costs one line only.
      try {
        if (trimmed.startsWith('amneziawg://') ||
            trimmed.startsWith('awg://')) {
          addProxy(_parseAmneziaWgLink(trimmed));
          continue;
        }
        addProxy(_parseUri(trimmed));
      } on _UnsupportedLink catch (e) {
        skipped.add(e.node);
      } catch (_) {
        continue;
      }
    }
  }

  final trimmed = raw.trim();
  if (_isLinkLine(trimmed)) {
    addFrom(trimmed);
  } else {
    final decoded = tryBase64Decode(trimmed);
    if (decoded != null && isShareLinkInput(decoded)) {
      addFrom(decoded);
    } else {
      addFrom(trimmed);
    }
  }

  return (proxies, skipped);
}

/// Node fine but undialable — a [SkippedNode]; broken nodes return null.
class _UnsupportedLink implements Exception {
  const _UnsupportedLink(this.node);

  final SkippedNode node;
}

SkippedNode _unsupportedSchemeNode(String line) {
  final scheme = _unsupportedSchemes.firstWhere(line.startsWith);
  final kind = scheme.substring(0, scheme.length - 3);
  final hashIdx = line.indexOf('#');
  final fragment = hashIdx >= 0 ? line.substring(hashIdx + 1) : '';
  String name;
  if (fragment.length > 1) {
    // Share-link fragments are percent-encoded; ssr remarks are base64.
    name = _tryDecodeFragment(fragment) ?? fragment;
  } else {
    // An ssr body has no readable name; the raw head is the best handle.
    name = line.length > 32 ? '${line.substring(0, 32)}…' : line;
  }
  return SkippedNode(
    name: name,
    kind: kind,
    reason: SkippedNodeReason.protocol,
  );
}

String? _tryDecodeFragment(String fragment) {
  try {
    return Uri.decodeComponent(fragment);
  } catch (_) {}
  final decoded = tryBase64Decode(fragment);
  if (decoded == null) return null;
  final printable = decoded.replaceAll(RegExp(r'[^\x20-\x7eЀ-ӿ]'), '');
  return printable.length >= 2 ? printable : null;
}

Map<String, Object?>? _parseUri(String uri) {
  if (uri.startsWith('vmess://')) return _parseVmess(uri);
  if (uri.startsWith('vless://')) return _parseVless(uri);
  if (uri.startsWith('ss://')) return _parseShadowsocks(uri);
  if (uri.startsWith('trojan://')) return _parseTrojan(uri);
  if (uri.startsWith('hysteria2://') || uri.startsWith('hy2://')) {
    return _parseHysteria2(uri);
  }
  if (uri.startsWith('tuic://')) return _parseTuic(uri);
  if (uri.startsWith('anytls://')) return _parseAnytls(uri);
  if (uri.startsWith('hysteria://')) return _parseHysteria1(uri);
  if (uri.startsWith('socks://') || uri.startsWith('socks5://')) {
    return _parseSocks(uri);
  }
  if (uri.startsWith('wireguard://') || uri.startsWith('wg://')) {
    return _parseWireguard(uri);
  }
  // A bare http(s) line is a subscription URL, not a node.
  if (uri.startsWith('http://') || uri.startsWith('https://')) {
    return _parseHttpProxy(uri);
  }
  return null;
}

Map<String, Object?>? _parseSocks(String uri) {
  final parts = _splitUserinfoUri(uri);
  if (parts == null) return null;
  final (credential, server, port, params, name) = parts;
  final proxy = <String, Object?>{
    'name': name,
    'type': 'socks5',
    'server': server,
    'port': port,
    'udp': true,
  };
  final colonIdx = credential.indexOf(':');
  if (colonIdx >= 0) {
    proxy['username'] = credential.substring(0, colonIdx);
    proxy['password'] = credential.substring(colonIdx + 1);
  } else {
    proxy['username'] = credential;
  }
  if (params['tls'] == '1' || params['tls'] == 'true') {
    proxy['tls'] = true;
  }
  if (params['insecure'] == '1' || params['insecure'] == 'true') {
    proxy['skip-cert-verify'] = true;
  }
  return proxy;
}

Map<String, Object?>? _parseHttpProxy(String uri) {
  if (!uri.contains('@')) return null;
  final parts = _splitUserinfoUri(uri);
  if (parts == null) return null;
  final (credential, server, port, params, name) = parts;
  final colonIdx = credential.indexOf(':');
  return <String, Object?>{
    'name': name,
    'type': 'http',
    'server': server,
    'port': port,
    if (colonIdx >= 0) 'username': credential.substring(0, colonIdx),
    if (colonIdx >= 0) 'password': credential.substring(colonIdx + 1),
    if (params['tls'] == '1' || params['tls'] == 'true') 'tls': true,
  };
}

Map<String, Object?>? _parseWireguard(String uri) {
  final parts = _splitUserinfoUri(uri);
  if (parts == null) return null;
  final (privateKey, server, port, params, name) = parts;

  final reservedValue = params['reserved'] ?? '';
  final reserved =
      reservedValue.isEmpty ? null : _parseReserved(reservedValue);
  final peers = <String, Object?>{
    'server': server,
    'port': port,
    if ((params['publickey'] ?? '').isNotEmpty)
      'public-key': params['publickey'],
    if ((params['presharedkey'] ?? '').isNotEmpty)
      'pre-shared-key': params['presharedkey'],
    // Without allowed-ips the peer routes nothing; /0 tunnels everything.
    'allowed-ips': [(params['allowed-ips'] ?? '0.0.0.0/0,::/0')],
    'reserved': ?reserved,
  };

  final proxy = <String, Object?>{
    'name': name,
    'type': 'wireguard',
    'server': server,
    'port': port,
    'private-key': privateKey,
    // mihomo requires ip/ipv6 as empty strings, not null, when one is absent.
    'ip': '',
    'ipv6': '',
    if ((params['address'] ?? '').isNotEmpty)
      ...splitWireguardAddresses(params['address']!),
    'peers': [peers],
    'udp': true,
  };
  final mtu = int.tryParse(params['mtu'] ?? '');
  if (mtu != null && mtu > 0) proxy['mtu'] = mtu;
  if ((params['dns'] ?? '').isNotEmpty) {
    // dns alone is inert — mihomo only resolves remotely when told to.
    proxy['dns'] = [params['dns']!];
    proxy['remote-dns-resolve'] = true;
  }
  return proxy;
}

String withCidr(String address) {
  if (address.contains('/')) return address;
  return address.contains(':') ? '$address/128' : '$address/32';
}

Map<String, Object?> splitWireguardAddresses(String address) {
  var ip = '';
  var ipv6 = '';
  for (final entry in address.split(',')) {
    final trimmed = entry.trim();
    if (trimmed.isEmpty) continue;
    final cidr = withCidr(trimmed);
    // mihomo parses ip/ipv6 with one netip.ParsePrefix; extra entries would
    // kill the config, so only the first address per family survives.
    if (cidr.contains(':')) {
      ipv6 = ipv6.isEmpty ? cidr : ipv6;
    } else if (ip.isEmpty) {
      ip = cidr;
    }
  }
  return {'ip': ip, 'ipv6': ipv6};
}

/// mihomo hard-fails unless reserved is exactly 3 bytes 0-255; anything else
/// drops the key rather than the node.
List<int>? _parseReserved(String value) {
  final parts = <int>[];
  for (final entry in value.split(',')) {
    final parsed = int.tryParse(entry.trim());
    if (parsed == null || parsed < 0 || parsed > 255) return null;
    parts.add(parsed);
  }
  return parts.length == 3 ? parts : null;
}

Map<String, Object?>? _parseAmneziaWgLink(String uri) {
  final schemeLen = uri.startsWith('amneziawg://')
      ? 'amneziawg://'.length
      : 'awg://'.length;
  final noScheme = uri.substring(schemeLen);
  final hashIdx = noScheme.indexOf('#');
  final fragment = hashIdx >= 0 ? noScheme.substring(hashIdx + 1) : '';
  final body = hashIdx >= 0 ? noScheme.substring(0, hashIdx) : noScheme;
  final conf = tryBase64Decode(body);
  if (conf == null) return null;
  final decoded = fragment.length > 1 ? _tryDecodeFragment(fragment) : null;
  return parseAwgConf(
    conf,
    name: decoded == null || decoded.isEmpty ? null : decoded,
  );
}

Map<String, Object?>? _parseVmess(String uri) {
  final decoded = tryBase64Decode(uri.substring('vmess://'.length));
  if (decoded == null) return null;
  final Map<String, Object?> j;
  try {
    j = json.decode(decoded) as Map<String, Object?>;
  } catch (_) {
    return null;
  }
  final server = j['add']?.toString();
  final port = int.tryParse(j['port']?.toString() ?? '');
  final uuid = j['id']?.toString();
  if (server == null || server.isEmpty || port == null || uuid == null) {
    return null;
  }

  final name = j['ps']?.toString() ?? '';
  final proxy = <String, Object?>{
    // An empty `ps` would emit a nameless proxy no group can reference.
    'name': name.isEmpty ? server : name,
    'type': 'vmess',
    'server': server,
    'port': port,
    'uuid': uuid,
    'alterId': int.tryParse(j['aid']?.toString() ?? '') ?? 0,
    'cipher': j['scy']?.toString() ?? 'auto',
    'udp': true,
  };

  // mihomo dials xhttp for vless only; elsewhere it degrades to TCP.
  final network = j['net']?.toString() ?? 'tcp';
  if (network == 'xhttp' || network == 'splithttp') {
    throw _UnsupportedLink(SkippedNode(
      name: name.isEmpty ? server : name,
      kind: 'xhttp',
      reason: SkippedNodeReason.transport,
    ));
  }
  if (network != 'tcp') proxy['network'] = _mihomoNetwork(network);
  _applyTransport(
    proxy,
    network: network,
    host: j['host']?.toString() ?? '',
    path: j['path']?.toString() ?? '',
    serviceName: j['path']?.toString() ?? '',
  );

  final tls = j['tls']?.toString();
  if (tls == 'tls' || tls == 'reality') {
    proxy['tls'] = true;
    final sni = j['sni']?.toString();
    if (sni != null && sni.isNotEmpty) proxy['servername'] = sni;
  }
  _applyTlsExtras(
    proxy,
    fingerprint: j['fp']?.toString() ?? '',
    alpn: j['alpn']?.toString() ?? '',
    allowInsecure: false,
  );
  return proxy;
}

Map<String, Object?>? _parseVless(String uri) {
  final parts = _splitUserinfoUri(uri);
  if (parts == null) return null;
  final (userinfo, server, port, params, name) = parts;

  final proxy = <String, Object?>{
    'name': name,
    'type': 'vless',
    'server': server,
    'port': port,
    'uuid': userinfo,
    'udp': true,
  };

  final security = params['security'] ?? 'none';
  final sni = params['sni'] ?? params['peer'] ?? server;
  if (security == 'reality') {
    proxy['tls'] = true;
    proxy['servername'] = sni;
    proxy['reality-opts'] = {
      'public-key': params['pbk'] ?? '',
      if ((params['sid'] ?? '').isNotEmpty) 'short-id': params['sid'],
    };
  } else if (security == 'tls') {
    proxy['tls'] = true;
    proxy['servername'] = sni;
  }
  if ((params['flow'] ?? '').isNotEmpty) proxy['flow'] = params['flow'];
  final encryption = params['encryption'] ?? '';
  if (encryption.isNotEmpty && encryption != 'none') {
    proxy['encryption'] = encryption;
  }
  _applyTlsExtras(
    proxy,
    fingerprint: params['fp'] ?? '',
    alpn: params['alpn'] ?? '',
    allowInsecure: params['allowInsecure'] == '1',
  );

  // `splithttp` is the sing-box spelling of xhttp, normalised to mihomo's.
  final network = params['type'] ?? 'tcp';
  final transport = network == 'splithttp' ? 'xhttp' : network;
  if (transport == 'xhttp') {
    proxy['network'] = 'xhttp';
    final mode = params['mode'] ?? '';
    proxy['xhttp-opts'] = {
      if ((params['path'] ?? '').isNotEmpty) 'path': params['path'],
      if ((params['host'] ?? '').isNotEmpty) 'host': params['host'],
      if (mode.isNotEmpty) 'mode': mode,
    };
  } else if (transport != 'tcp') {
    proxy['network'] = _mihomoNetwork(transport);
  }
  _applyTransport(
    proxy,
    network: transport,
    host: params['host'] ?? '',
    path: params['path'] ?? '',
    serviceName: params['serviceName'] ?? '',
  );
  return proxy;
}

Map<String, Object?>? _parseShadowsocks(String uri) {
  final noScheme = uri.substring('ss://'.length);
  final hashIdx = noScheme.indexOf('#');
  final name = hashIdx >= 0
      ? _decodeComponent(noScheme.substring(hashIdx + 1))
      : '';
  final withoutName =
      hashIdx >= 0 ? noScheme.substring(0, hashIdx) : noScheme;
  final queryIdx = withoutName.indexOf('?');
  final params = queryIdx >= 0
      ? _splitQuery(withoutName.substring(queryIdx + 1))
      : const <String, String>{};
  final payload =
      queryIdx >= 0 ? withoutName.substring(0, queryIdx) : withoutName;

  final atIdx = payload.lastIndexOf('@');
  String method, password, server;
  int port;
  if (atIdx > 0) {
    final credential = tryBase64Decode(payload.substring(0, atIdx)) ??
        _decodeComponent(payload.substring(0, atIdx));
    final colonIdx = credential.indexOf(':');
    if (colonIdx < 0) return null;
    method = credential.substring(0, colonIdx);
    password = credential.substring(colonIdx + 1);
    final hostPort = payload.substring(atIdx + 1);
    final split = splitHostPort(hostPort);
    if (split == null) return null;
    (server, port) = split;
  } else {
    // Legacy shape: the base64 covers credentials AND host:port.
    final decoded = tryBase64Decode(payload);
    if (decoded == null) return null;
    final atIdx = decoded.lastIndexOf('@');
    if (atIdx < 0) return null;
    final credential = decoded.substring(0, atIdx);
    final colonIdx = credential.indexOf(':');
    if (colonIdx < 0) return null;
    method = credential.substring(0, colonIdx);
    password = credential.substring(colonIdx + 1);
    final split = splitHostPort(decoded.substring(atIdx + 1));
    if (split == null) return null;
    (server, port) = split;
  }

  if (method.isEmpty || server.isEmpty) return null;

  final proxy = <String, Object?>{
    // An empty `#name` would emit a nameless proxy no group can reference.
    'name': name.isEmpty ? server : name,
    'type': 'ss',
    'server': server,
    'port': port,
    'cipher': method,
    'password': password,
    'udp': true,
  };
  if (!_applyPlugin(proxy, params['plugin'] ?? '')) return null;
  return proxy;
}

Map<String, Object?>? _parseTrojan(String uri) {
  final parts = _splitUserinfoUri(uri);
  if (parts == null) return null;
  final (password, server, port, params, name) = parts;

  final proxy = <String, Object?>{
    'name': name,
    'type': 'trojan',
    'server': server,
    'port': port,
    'password': password,
    'udp': true,
  };
  final sni = params['sni'] ?? params['peer'] ?? server;
  if (sni.isNotEmpty) proxy['sni'] = sni;
  _applyTlsExtras(
    proxy,
    fingerprint: params['fp'] ?? '',
    alpn: params['alpn'] ?? '',
    allowInsecure: params['allowInsecure'] == '1',
  );
  final network = params['type'] ?? 'tcp';
  // xhttp is vless-only; see _parseVmess.
  if (network == 'xhttp' || network == 'splithttp') {
    throw _UnsupportedLink(SkippedNode(
      name: name,
      kind: 'xhttp',
      reason: SkippedNodeReason.transport,
    ));
  }
  if (network != 'tcp') proxy['network'] = _mihomoNetwork(network);
  _applyTransport(
    proxy,
    network: network,
    host: params['host'] ?? '',
    path: params['path'] ?? '',
    serviceName: params['serviceName'] ?? '',
  );
  return proxy;
}

Map<String, Object?>? _parseHysteria2(String uri) {
  final parts = _splitUserinfoUri(uri);
  if (parts == null) return null;
  final (auth, server, port, params, name) = parts;

  final proxy = <String, Object?>{
    'name': name,
    'type': 'hysteria2',
    'server': server,
    'port': port,
    'password': auth,
  };
  final sni = params['sni'] ?? server;
  if (sni.isNotEmpty) proxy['sni'] = sni;
  if (params['insecure'] == '1' || params['insecure'] == 'true') {
    proxy['skip-cert-verify'] = true;
  }
  if ((params['obfs'] ?? '').isNotEmpty) {
    proxy['obfs'] = params['obfs'];
    final obfsPassword = params['obfs-password'];
    if (obfsPassword != null && obfsPassword.isNotEmpty) {
      proxy['obfs-password'] = obfsPassword;
    }
  }
  for (final field in ['up', 'down']) {
    final value = params[field];
    if (value != null && value.isNotEmpty) proxy[field] = value;
  }
  return proxy;
}

/// The v5 URI scheme; the v4 token form has no mihomo fields to map.
Map<String, Object?>? _parseTuic(String uri) {
  final parts = _splitUserinfoUri(uri);
  if (parts == null) return null;
  final (userinfo, server, port, params, name) = parts;
  final colonIdx = userinfo.indexOf(':');
  if (colonIdx <= 0) return null;
  final uuid = userinfo.substring(0, colonIdx);
  final password = userinfo.substring(colonIdx + 1);

  final proxy = <String, Object?>{
    'name': name,
    'type': 'tuic',
    'server': server,
    'port': port,
    'uuid': uuid,
    'password': password,
    'udp': true,
  };
  // TUIC is QUIC-native: TLS is always on, alpn defaults to h3.
  final sni = params['sni'] ?? params['peer'] ?? server;
  if (sni.isNotEmpty) proxy['sni'] = sni;
  final alpnList = (params['alpn'] ?? 'h3')
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
  proxy['alpn'] = alpnList.isEmpty ? ['h3'] : alpnList;
  final congestion = params['congestion_control'] ?? params['congestion'];
  if (congestion != null && congestion.isNotEmpty) {
    proxy['congestion-controller'] = congestion;
  }
  final udpRelayMode = params['udp_relay_mode'] ?? '';
  if (udpRelayMode.isNotEmpty) proxy['udp-relay-mode'] = udpRelayMode;
  if (params['allow_insecure'] == '1' || params['insecure'] == '1') {
    proxy['skip-cert-verify'] = true;
  }
  _applyTlsExtras(
    proxy,
    fingerprint: params['fp'] ?? '',
    alpn: '',
    allowInsecure: false,
  );
  return proxy;
}

Map<String, Object?>? _parseAnytls(String uri) {
  final parts = _splitUserinfoUri(uri);
  if (parts == null) return null;
  final (password, server, port, params, name) = parts;

  final proxy = <String, Object?>{
    'name': name,
    'type': 'anytls',
    'server': server,
    'port': port,
    'password': password,
    'udp': true,
  };
  final sni = params['sni'] ?? server;
  if (sni.isNotEmpty) proxy['sni'] = sni;
  if (params['insecure'] == '1' || params['allow_insecure'] == '1') {
    proxy['skip-cert-verify'] = true;
  }
  _applyTlsExtras(
    proxy,
    fingerprint: params['fp'] ?? '',
    alpn: params['alpn'] ?? '',
    allowInsecure: false,
  );
  return proxy;
}

/// Hysteria v1: `upmbps`/`downmbps` map to mihomo's unit-less `up`/`down`.
Map<String, Object?>? _parseHysteria1(String uri) {
  // Hysteria v1 carries no userinfo — the auth rides in `?auth=`.
  const schemeEnd = 'hysteria://'.length;
  final noScheme = uri.substring(schemeEnd);

  final hashIdx = noScheme.indexOf('#');
  final name = hashIdx >= 0
      ? _decodeComponent(noScheme.substring(hashIdx + 1))
      : '';
  final withoutName = hashIdx >= 0 ? noScheme.substring(0, hashIdx) : noScheme;

  final queryIdx = withoutName.indexOf('?');
  final hostPort = queryIdx >= 0 ? withoutName.substring(0, queryIdx) : withoutName;
  final params = queryIdx >= 0
      ? _splitQuery(withoutName.substring(queryIdx + 1))
      : const <String, String>{};
  final split = splitHostPort(hostPort);
  if (split == null) return null;
  final (server, port) = split;

  final auth = params['auth'] ?? '';
  if (auth.isEmpty) return null;
  final displayName = name.isEmpty ? server : name;
  final up = params['upmbps'] ?? params['up'] ?? '';
  final down = params['downmbps'] ?? params['down'] ?? '';
  // mihomo rejects up/down of 0 outright, and one bad proxy kills the whole
  // config — a link without bandwidth is skipped, not emitted broken.
  if (up.isEmpty || down.isEmpty) {
    throw _UnsupportedLink(SkippedNode(
      name: displayName,
      kind: 'hysteria',
      reason: SkippedNodeReason.bandwidth,
    ));
  }
  final proxy = <String, Object?>{
    'name': displayName,
    'type': 'hysteria',
    'server': server,
    'port': port,
    'auth-str': auth,
    'up': up,
    'down': down,
  };
  final peer = params['peer'] ?? params['sni'] ?? server;
  if (peer.isNotEmpty) proxy['sni'] = peer;
  final alpn = params['alpn'] ?? '';
  if (alpn.isNotEmpty) proxy['alpn'] = alpn.split(',');
  if (params['insecure'] == '1' || params['insecure'] == 'true') {
    proxy['skip-cert-verify'] = true;
  }
  // HysteriaOption.Obfs is the XPlus key itself, not a family name.
  final obfsParam = params['obfsParam'] ?? params['obfs-param'] ?? '';
  final obfs = params['obfs'] ?? '';
  if (obfsParam.isNotEmpty) {
    proxy['obfs'] = obfsParam;
  } else if (obfs.isNotEmpty) {
    proxy['obfs'] = obfs;
  }
  return proxy;
}

(String userinfo, String server, int port, Map<String, String> params,
        String name)?
    _splitUserinfoUri(String uri) {
  final schemeEnd = uri.indexOf('://') + 3;
  final noScheme = uri.substring(schemeEnd);

  final hashIdx = noScheme.indexOf('#');
  final name = hashIdx >= 0
      ? _decodeComponent(noScheme.substring(hashIdx + 1))
      : '';
  final withoutName = hashIdx >= 0 ? noScheme.substring(0, hashIdx) : noScheme;

  final queryIdx = withoutName.indexOf('?');
  final params = queryIdx >= 0
      ? _splitQuery(withoutName.substring(queryIdx + 1))
      : const <String, String>{};
  final hostPort = queryIdx >= 0
      ? withoutName.substring(0, queryIdx)
      : withoutName;

  final atIdx = hostPort.lastIndexOf('@');
  if (atIdx < 0) return null;
  final userinfo = _decodeComponent(hostPort.substring(0, atIdx));
  if (userinfo.isEmpty) return null;
  final split = splitHostPort(hostPort.substring(atIdx + 1));
  if (split == null) return null;
  final (server, port) = split;
  return (
    userinfo,
    server,
    port,
    params,
    name.isEmpty ? server : name,
  );
}

(String, int)? splitHostPort(String hostPort) {
  final bracketIdx = hostPort.lastIndexOf(']');
  // IPv6 literals carry colons; the port separator is the first past `]`.
  final colonIdx = bracketIdx >= 0
      ? hostPort.indexOf(':', bracketIdx + 1)
      : hostPort.lastIndexOf(':');
  if (colonIdx <= 0) return null;
  final server = (bracketIdx >= 0
          ? hostPort.substring(0, bracketIdx + 1)
          : hostPort.substring(0, colonIdx))
      .replaceAll('[', '')
      .replaceAll(']', '');
  final port = int.tryParse(hostPort.substring(colonIdx + 1));
  if (server.isEmpty || port == null) return null;
  return (server, port);
}

/// mihomo has no network "httpupgrade"; the HTTP Upgrade dial rides the ws
/// transport with `v2ray-http-upgrade`.
String _mihomoNetwork(String network) => network == 'httpupgrade' ? 'ws' : network;

void _applyTransport(
  Map<String, Object?> proxy, {
  required String network,
  required String host,
  required String path,
  required String serviceName,
}) {
  final isHttpUpgrade = network == 'httpupgrade';
  switch (isHttpUpgrade ? 'ws' : network) {
    case 'ws':
      // v2rayN convention: the 0-RTT hint rides in the path (`/ws?ed=2048`)
      // — the server's path is `/ws`, the tail is the early-data size. Left
      // as is, mihomo requests `/ws?ed=2048` and the handshake 404s.
      final (cleanPath, earlyData, earlyHeader) = _splitWsEarlyData(path);
      final wsOpts = <String, Object?>{
        if (cleanPath.isNotEmpty) 'path': cleanPath,
        if (host.isNotEmpty) 'headers': {'Host': host},
        if (!isHttpUpgrade && earlyData != null) 'max-early-data': earlyData,
        ?earlyHeader == null ? null : 'early-data-header-name': earlyHeader,
      };
      if (isHttpUpgrade) {
        wsOpts['v2ray-http-upgrade'] = true;
        if (earlyData != null) wsOpts['v2ray-http-upgrade-fast-open'] = true;
      }
      proxy['ws-opts'] = wsOpts;
    case 'grpc':
      if (serviceName.isNotEmpty) {
        proxy['grpc-opts'] = {'grpc-service-name': serviceName};
      }
    case 'h2':
      proxy['h2-opts'] = {
        if (path.isNotEmpty) 'path': path,
        if (host.isNotEmpty) 'host': [host],
      };
  }
}

/// `eh` names the early-data header (default `Sec-WebSocket-Protocol`).
(String, int?, String?) _splitWsEarlyData(String path) {
  final queryIdx = path.indexOf('?');
  if (queryIdx < 0) return (path, null, null);
  final base = path.substring(0, queryIdx);
  var earlyData = 0;
  String? earlyHeader;
  final kept = <String>[];
  for (final segment in path.substring(queryIdx + 1).split('&')) {
    if (segment.startsWith('ed=')) {
      earlyData = int.tryParse(segment.substring(3)) ?? 0;
    } else if (segment.startsWith('eh=')) {
      earlyHeader = _decodeComponent(segment.substring(3));
    } else if (segment.isNotEmpty) {
      kept.add(segment);
    }
  }
  if (earlyData == 0 && earlyHeader == null) return (path, null, null);
  return (
    kept.isEmpty ? base : '$base?${kept.join('&')}',
    earlyData > 0 ? earlyData : null,
    earlyHeader ?? (earlyData > 0 ? 'Sec-WebSocket-Protocol' : null),
  );
}

void _applyTlsExtras(
  Map<String, Object?> proxy, {
  required String fingerprint,
  required String alpn,
  required bool allowInsecure,
}) {
  if (fingerprint.isNotEmpty) proxy['client-fingerprint'] = fingerprint;
  if (alpn.isNotEmpty) {
    proxy['alpn'] = alpn.split(',').map((e) => e.trim()).toList();
  }
  if (allowInsecure) proxy['skip-cert-verify'] = true;
}

/// SIP003 `plugin=<name>;k=v`. False when the plugin has no mihomo counterpart.
bool _applyPlugin(Map<String, Object?> proxy, String pluginParam) {
  if (pluginParam.isEmpty) return true;
  final segments = pluginParam.split(';');
  final pluginName = segments.first;
  final opts = <String, String>{};
  for (final segment in segments.skip(1)) {
    final eq = segment.indexOf('=');
    if (eq > 0) opts[segment.substring(0, eq)] = segment.substring(eq + 1);
  }
  switch (pluginName) {
    case 'obfs-local':
    case 'simple-obfs':
      proxy['plugin'] = 'obfs';
      proxy['plugin-opts'] = {
        'mode': opts['obfs'] ?? 'http',
        if ((opts['obfs-host'] ?? '').isNotEmpty)
          'host': opts['obfs-host'],
      };
    case 'v2ray-plugin':
      proxy['plugin'] = 'v2ray-plugin';
      proxy['plugin-opts'] = {
        'mode': opts['mode'] ?? 'websocket',
        if (opts.containsKey('tls')) 'tls': true,
        if ((opts['host'] ?? '').isNotEmpty) 'host': opts['host'],
        if ((opts['path'] ?? '').isNotEmpty) 'path': opts['path'],
      };
    default:
      return false;
  }
  return true;
}

/// Lenient: share links arrive with missing padding and URL-safe chars.
String? tryBase64Decode(String input) {
  final clean = input.replaceAll(RegExp(r'\s'), '');
  if (clean.isEmpty) return null;
  final padded = clean.padRight((clean.length + 3) ~/ 4 * 4, '=');
  final normalized = padded.replaceAll('-', '+').replaceAll('_', '/');
  try {
    return utf8.decode(base64.decode(normalized), allowMalformed: true);
  } catch (_) {
    return null;
  }
}

/// Lenient: hands [value] back untouched when not valid percent-encoding.
String _decodeComponent(String value) {
  try {
    return Uri.decodeComponent(value);
  } catch (_) {
    return value;
  }
}

Map<String, String> _splitQuery(String query) {
  try {
    return Uri.splitQueryString(query);
  } catch (_) {
    final params = <String, String>{};
    for (final pair in query.split('&')) {
      if (pair.isEmpty) continue;
      final eq = pair.indexOf('=');
      final key = eq >= 0 ? pair.substring(0, eq) : pair;
      final value = eq >= 0 ? pair.substring(eq + 1) : '';
      params[_decodeComponent(key.replaceAll('+', ' '))] =
          _decodeComponent(value.replaceAll('+', ' '));
    }
    return params;
  }
}

/// Every string is double-quoted — node names freely contain emoji, `#`, `:`
/// and CJK. Public for the xray converter, which shares this emitter.
String emitProxiesConfig(List<Map<String, Object?>> proxies) {
  final buffer = StringBuffer()..writeln('proxies:');
  for (final proxy in proxies) {
    buffer.writeln('  - {${_emitMap(proxy)}}');
  }

  final groupEntries = [
    for (final proxy in proxies) _yamlString(proxy['name']! as String),
    'DIRECT',
  ].join(', ');
  buffer
    ..writeln('proxy-groups:')
    ..writeln('  - name: "PROXY"')
    ..writeln('    type: select')
    ..writeln('    proxies: [$groupEntries]')
    ..writeln('rules:')
    ..writeln('  - MATCH,PROXY');
  return buffer.toString();
}

String _emitMap(Map<String, Object?> map) {
  final parts = <String>[];
  map.forEach((key, value) {
    if (value is Map<String, Object?>) {
      parts.add('$key: {${_emitMap(value)}}');
    } else {
      parts.add('$key: ${_yamlString(value)}');
    }
  });
  return parts.join(', ');
}

String _yamlString(Object? value) {
  if (value == null) return '""';
  if (value is bool) return value ? 'true' : 'false';
  if (value is int) return value.toString();
  if (value is List) {
    return '[${value.map(_yamlValue).join(', ')}]';
  }
  final escaped = value
      .toString()
      .replaceAll(r'\', r'\\')
      .replaceAll('"', r'\"')
      .replaceAll('\n', r'\n')
      .replaceAll('\r', r'\r')
      .replaceAll('\t', r'\t')
      // go-yaml rejects raw C0 controls and DEL; \xNN keeps the config loadable.
      .replaceAllMapped(
        RegExp('[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'),
        (m) =>
            '\\x${m[0]!.codeUnitAt(0).toRadixString(16).padLeft(2, '0')}',
      );
  return '"$escaped"';
}

String _yamlValue(Object? value) {
  if (value is Map<String, Object?>) return '{${_emitMap(value)}}';
  return _yamlString(value);
}
