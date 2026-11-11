library;

import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../config/amnezia_config.dart';
import '../routing/skipped_node.dart';
import '../transport/xhttp.dart';
import 'extension_catalog.dart';

const shareLinkSchemes = [
  'vmess',
  'vless',
  'ss',
  'ssr',
  'trojan',
  'hysteria2',
  'hy2',
  'hysteria2+realm',
  'hy2+realm',
  'tuic',
  'anytls',
  'hysteria',
  'socks',
  'socks5',
  'socks5h',
  'mierus',
  'tt',
  'wireguard',
  'wg',
  'amneziawg',
  'awg',
  'vpn',
];

final _linkScheme = RegExp(r'^([a-zA-Z][a-zA-Z0-9+.-]*)://');

abstract interface class ConvertedSubscription {
  String get config;

  List<SkippedNode> get skipped;
}

abstract interface class LossyConversion implements ConvertedSubscription {
  bool get hasOtherLosses;
}

class ShareLinksResult implements LossyConversion {
  const ShareLinksResult({
    required this.config,
    this.skipped = const [],
    this.hasOtherLosses = false,
  });

  @override
  final String config;

  @override
  final List<SkippedNode> skipped;

  @override
  final bool hasOtherLosses;
}

bool _isLinkLine(String line) {
  final scheme = _nodeScheme(line);
  return shareLinkSchemes.contains(scheme) ||
      extensionForScheme(scheme) != null;
}

String? _nodeScheme(String line) =>
    _linkScheme.firstMatch(line)?.group(1)?.toLowerCase();

bool isShareLinkInput(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return false;
  if (_isLinkLine(trimmed)) return true;
  final compact = trimmed.replaceAll(RegExp(r'\s+'), '');
  final decoded = tryBase64Decode(compact);
  if (decoded != null && isShareLinkInput(decoded)) return true;
  return trimmed
      .split(RegExp(r'[\r\n]+'))
      .any((line) => _isLinkLine(line.trim()));
}

ShareLinksResult? tryConvertShareLinks(String raw) {
  final (proxies, skipped, hasOtherLosses) = _scanShareLinks(raw);
  if (proxies.isEmpty) return null;
  return ShareLinksResult(
    config: emitProxiesConfig(proxies),
    skipped: skipped,
    hasOtherLosses: hasOtherLosses,
  );
}

List<SkippedNode> probeUnsupportedShareLinks(String raw) {
  final (proxies, skipped, _) = _scanShareLinks(raw);
  return proxies.isEmpty ? skipped : const [];
}

(List<Map<String, Object?>>, List<SkippedNode>, bool) _scanShareLinks(
  String raw,
) {
  final proxies = <Map<String, Object?>>[];
  final skipped = <SkippedNode>[];
  final seen = {...reservedProxyNames};
  final extensionCounts = <String, int>{};
  var hasOtherLosses = false;

  void addProxy(Map<String, Object?> proxy) {
    var name = proxy['name']! as String;
    if (reservedProxyNames.contains(name)) name = '$name node';
    var suffix = 2;
    while (seen.contains(name)) {
      name = '${proxy['name']} $suffix';
      suffix++;
    }
    proxy['name'] = name;
    seen.add(name);
    proxies.add(proxy);
  }

  void skip(String line, String scheme) {
    final hashIdx = line.indexOf('#');
    skipped.add(
      SkippedNode(
        name: hashIdx >= 0 ? _displayName(line.substring(hashIdx + 1)) : scheme,
        kind: scheme,
        reason: SkippedNodeReason.protocol,
      ),
    );
  }

  void addFrom(String text) {
    for (final line in text.split(RegExp(r'[\r\n]+'))) {
      final trimmed = line.trim();
      final scheme = _nodeScheme(trimmed);
      if (scheme == null) continue;
      final normalized = '$scheme${trimmed.substring(scheme.length)}';
      try {
        if (scheme == 'vpn') {
          final (vpnProxies, vpnSkipped) = parseVpnLink(
            normalized.substring('vpn://'.length),
          );
          skipped.addAll(vpnSkipped);
          vpnProxies.forEach(addProxy);
          if (vpnProxies.isEmpty && vpnSkipped.isEmpty) {
            skip(normalized, scheme);
          }
          hasOtherLosses = true;
          continue;
        }
        final parsed = scheme == 'amneziawg' || scheme == 'awg'
            ? [?_parseAmneziaWgLink(normalized)]
            : _parseUri(normalized, onLoss: () => hasOtherLosses = true);
        final extension = parsed.isEmpty ? extensionForScheme(scheme) : null;
        if (extension != null) {
          final count = extensionCounts.update(
            extension.id,
            (n) => n + 1,
            ifAbsent: () => 1,
          );
          addProxy(extensionNode(extension, normalized, count));
        } else if (parsed.isEmpty) {
          skip(normalized, scheme);
        } else {
          parsed.forEach(addProxy);
          if (scheme == 'amneziawg' || scheme == 'awg') hasOtherLosses = true;
        }
      } on _UnsupportedLink catch (error) {
        skipped.add(error.node);
      } catch (_) {
        skip(normalized, scheme);
      }
    }
  }

  final trimmed = raw.trim();
  if (_isLinkLine(trimmed)) {
    addFrom(trimmed);
  } else {
    final compact = trimmed.replaceAll(RegExp(r'\s+'), '');
    final decoded = tryBase64Decode(compact);
    if (decoded != null && isShareLinkInput(decoded)) {
      addFrom(decoded);
    } else {
      addFrom(trimmed);
    }
  }

  return (proxies, skipped, hasOtherLosses);
}

class _UnsupportedLink implements Exception {
  const _UnsupportedLink(this.node);

  final SkippedNode node;
}

String? _tryDecodeFragment(String fragment) {
  try {
    return _stripLinkExtras(Uri.decodeComponent(fragment));
  } catch (_) {}
  final decoded = tryBase64Decode(fragment);
  if (decoded == null) return null;
  final printable = decoded.replaceAll(RegExp(r'[^\x20-\x7eЀ-ӿ]'), '');
  return printable.length >= 2 ? printable : null;
}

const _linkExtraKeys = {
  'serverDescription',
  'resolve-address',
  'host',
  'insecure',
  'fragment',
  'noises',
};

String _displayName(String fragment) =>
    _stripLinkExtras(_decodeComponent(fragment));

String _stripLinkExtras(String name) {
  final cut = name.indexOf('?');
  if (cut < 0) return name;
  final extras = name.substring(cut + 1).split('&').every((pair) {
    final eq = pair.indexOf('=');
    return eq > 0 && _linkExtraKeys.contains(pair.substring(0, eq));
  });
  return extras ? name.substring(0, cut) : name;
}

List<Map<String, Object?>> _parseUri(
  String uri, {
  required void Function() onLoss,
}) {
  if (uri.startsWith('mierus://')) return _parseMieru(uri, onLoss: onLoss);
  if (uri.startsWith('tt://')) return [?_parseTrustTunnel(uri, onLoss: onLoss)];
  final proxy = switch (_nodeScheme(uri)) {
    'vmess' => _parseVmess(uri),
    'vless' => _parseVless(uri, onLoss: onLoss),
    'ssr' => _parseShadowsocksR(uri),
    'ss' => _parseShadowsocks(uri),
    'trojan' => _parseTrojan(uri),
    'hysteria2' ||
    'hy2' ||
    'hysteria2+realm' ||
    'hy2+realm' => _parseHysteria2(uri),
    'tuic' => _parseTuic(uri),
    'anytls' => _parseAnytls(uri),
    'hysteria' => _parseHysteria1(uri),
    'socks' || 'socks5' || 'socks5h' => _parseSocks(uri),
    'wireguard' || 'wg' => _parseWireguard(uri),
    'http' || 'https' => _parseHttpProxy(uri),
    _ => null,
  };
  return [?proxy];
}

List<Map<String, Object?>> _parseMieru(
  String uri, {
  required void Function() onLoss,
}) {
  final link = Uri.parse(uri);
  if (link.host.isEmpty || link.userInfo.isEmpty) return const [];
  final userInfo = _decodeComponent(link.userInfo);
  final colon = userInfo.indexOf(':');
  final params = link.queryParametersAll;
  final ports = params['port'] ?? const [];
  final protocols = params['protocol'] ?? const [];
  if (ports.isEmpty || ports.length != protocols.length) return const [];
  final name = _displayName(link.fragment);
  final baseName = name.isNotEmpty
      ? name
      : params['profile']?.firstOrNull ?? link.host;
  final proxies = <Map<String, Object?>>[];
  for (var i = 0; i < ports.length; i++) {
    final port = ports[i];
    final protocol = protocols[i].toUpperCase();
    final range = port.split('-');
    final bounds = range.map(int.tryParse).toList();
    if (!const {'TCP', 'UDP'}.contains(protocol) ||
        range.length > 2 ||
        bounds.any((value) => value == null || value < 1 || value > 65535) ||
        bounds.first! > bounds.last!) {
      onLoss();
      continue;
    }
    proxies.add({
      'name': '$baseName:$port/$protocol',
      'type': 'mieru',
      'server': link.host,
      if (range.length == 1) 'port': bounds.single else 'port-range': port,
      'transport': protocol,
      'username': colon < 0 ? userInfo : userInfo.substring(0, colon),
      'password': colon < 0 ? '' : userInfo.substring(colon + 1),
      'udp': true,
      for (final field in ['multiplexing', 'handshake-mode', 'traffic-pattern'])
        if (params[field]?.firstOrNull case final value? when value.isNotEmpty)
          field: value,
    });
  }
  return proxies;
}

Map<String, Object?>? _parseSocks(String uri) {
  final parts = _splitUserinfoUri(uri, requireUserinfo: false);
  if (parts == null) return null;
  final (rawCredential, server, port, params, name) = parts;
  final decoded = tryBase64Decode(rawCredential);
  final credential =
      !rawCredential.contains(':') && decoded?.contains(':') == true
      ? decoded!
      : rawCredential;
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
  final reserved = reservedValue.isEmpty ? null : _parseReserved(reservedValue);
  final allowedIps = (params['allowed-ips'] ?? '0.0.0.0/0,::/0')
      .split(',')
      .map((entry) => entry.trim())
      .where((entry) => entry.isNotEmpty)
      .toList(growable: false);
  final peers = <String, Object?>{
    'server': server,
    'port': port,
    if ((params['publickey'] ?? '').isNotEmpty)
      'public-key': params['publickey'],
    if ((params['presharedkey'] ?? '').isNotEmpty)
      'pre-shared-key': params['presharedkey'],
    'allowed-ips': allowedIps,
    'reserved': ?reserved,
  };

  final proxy = <String, Object?>{
    'name': name,
    'type': 'wireguard',
    'server': server,
    'port': port,
    'private-key': privateKey,
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
    if (cidr.contains(':')) {
      ipv6 = ipv6.isEmpty ? cidr : ipv6;
    } else if (ip.isEmpty) {
      ip = cidr;
    }
  }
  return {'ip': ip, 'ipv6': ipv6};
}

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
  final decoded = fragment.length > 1 ? _tryDecodeFragment(fragment) : null;
  final displayName = decoded == null || decoded.isEmpty ? null : decoded;
  if (body.contains('@')) {
    final parts = _splitUserinfoUri(uri);
    if (parts == null) return null;
    final conf = awgConfFromLinkParams(
      privateKey: parts.$1,
      server: parts.$2,
      port: parts.$3,
      params: parts.$4,
    );
    return conf == null
        ? null
        : parseAwgConf(conf, name: displayName ?? parts.$5);
  }
  final conf = tryBase64Decode(body);
  if (conf == null) return null;
  return parseAwgConf(conf, name: displayName);
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
    'name': name.isEmpty ? server : name,
    'type': 'vmess',
    'server': server,
    'port': port,
    'uuid': uuid,
    'alterId': int.tryParse(j['aid']?.toString() ?? '') ?? 0,
    'cipher': sanitizeVmessCipher(j['scy']?.toString() ?? 'auto'),
    'udp': true,
  };

  final rawNet = j['net']?.toString() ?? 'tcp';
  if (rawNet == 'xhttp' || rawNet == 'splithttp') {
    throw _UnsupportedLink(
      SkippedNode(
        name: name.isEmpty ? server : name,
        kind: 'xhttp',
        reason: SkippedNodeReason.transport,
      ),
    );
  }
  final host = j['host']?.toString() ?? '';
  final path = j['path']?.toString() ?? '';
  final headerType = j['type']?.toString() ?? '';
  if (rawNet == 'tcp' && headerType == 'http') {
    proxy['network'] = 'http';
    proxy['http-opts'] = {
      if (path.isNotEmpty) 'path': [path],
      if (host.isNotEmpty)
        'headers': {
          'Host': [host],
        },
    };
  } else {
    final network = rawNet == 'http' ? 'h2' : rawNet;
    if (network != 'tcp') proxy['network'] = _mihomoNetwork(network);
    _applyTransport(
      proxy,
      network: network,
      host: host,
      path: path,
      serviceName: path,
    );
  }

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
    emulateXray: true,
  );
  return proxy;
}

Map<String, Object?>? _parseVless(
  String uri, {
  required void Function() onLoss,
}) {
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
    proxy['reality-opts'] = <String, Object?>{
      'public-key': params['pbk'] ?? '',
      if ((params['sid'] ?? '').isNotEmpty) 'short-id': params['sid'],
    };
  } else if (security == 'tls') {
    proxy['tls'] = true;
    proxy['servername'] = sni;
  }
  final flow = sanitizeVlessFlow(params['flow'] ?? '');
  if (flow != null) proxy['flow'] = flow;
  final encryption = params['encryption'] ?? '';
  if (encryption.isNotEmpty &&
      encryption != 'none' &&
      isValidVlessEncryption(encryption)) {
    proxy['encryption'] = encryption;
  }
  _applyTlsExtras(
    proxy,
    fingerprint: params['fp'] ?? '',
    alpn: params['alpn'] ?? '',
    allowInsecure: params['allowInsecure'] == '1',
    emulateXray: true,
  );

  final network = params['type'] ?? 'tcp';
  final transport = network == 'splithttp' ? 'xhttp' : network;
  if (transport == 'xhttp') {
    proxy['network'] = 'xhttp';
    final converted = convertXhttpOptions(
      path: params['path'] ?? '',
      host: params['host'] ?? '',
      mode: params['mode'] ?? '',
      extra: params['extra'],
    );
    proxy['xhttp-opts'] = converted.options;
    if (converted.hasLosses) onLoss();
  } else if (transport != 'tcp') {
    proxy['network'] = _mihomoNetwork(transport);
  }
  var path = params['path'] ?? '';
  if (transport == 'ws' || transport == 'httpupgrade') {
    path = _withTopLevelEarlyData(path, params['ed'] ?? '', params['eh'] ?? '');
  }
  _applyTransport(
    proxy,
    network: transport,
    host: params['host'] ?? '',
    path: path,
    serviceName: params['serviceName'] ?? '',
  );
  return proxy;
}

Map<String, Object?>? _parseShadowsocks(String uri) {
  final noScheme = uri.substring('ss://'.length);
  final hashIdx = noScheme.indexOf('#');
  final name = hashIdx >= 0
      ? _displayName(noScheme.substring(hashIdx + 1))
      : '';
  final withoutName = hashIdx >= 0 ? noScheme.substring(0, hashIdx) : noScheme;
  final queryIdx = withoutName.indexOf('?');
  final params = queryIdx >= 0
      ? _splitQuery(withoutName.substring(queryIdx + 1))
      : const <String, String>{};
  final payload = queryIdx >= 0
      ? withoutName.substring(0, queryIdx)
      : withoutName;

  final atIdx = payload.lastIndexOf('@');
  String method, password, server;
  int port;
  if (atIdx > 0) {
    final credential =
        tryBase64Decode(payload.substring(0, atIdx)) ??
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
    'name': name.isEmpty ? server : name,
    'type': 'ss',
    'server': server,
    'port': port,
    'cipher': method,
    'password': password,
    'udp': true,
  };
  if (params['udp-over-tcp'] == 'true' || params['uot'] == '1') {
    proxy['udp-over-tcp'] = true;
    final version = int.tryParse(params['udp-over-tcp-version'] ?? '');
    if (version != null && version > 0) {
      proxy['udp-over-tcp-version'] = version;
    }
  }
  if (!_applyPlugin(proxy, params['plugin'] ?? '')) return null;
  return proxy;
}

Map<String, Object?>? _parseShadowsocksR(String uri) {
  final decoded = tryBase64Decode(uri.substring('ssr://'.length));
  if (decoded == null) return null;
  final cutIdx = decoded.indexOf('/?');
  final head = cutIdx >= 0 ? decoded.substring(0, cutIdx) : decoded;
  final params = cutIdx >= 0
      ? _splitQuery(decoded.substring(cutIdx + 2))
      : const <String, String>{};

  final fields = head.split(':');
  if (fields.length != 6) return null;
  final port = int.tryParse(fields[1]);
  final password = tryBase64Decode(fields[5]);
  if (fields[0].isEmpty || port == null || password == null) return null;

  final remarks = tryBase64Decode(params['remarks'] ?? '') ?? '';
  final obfsParam = tryBase64Decode(params['obfsparam'] ?? '') ?? '';
  final protocolParam = tryBase64Decode(params['protoparam'] ?? '') ?? '';
  return <String, Object?>{
    'name': remarks.isEmpty ? fields[0] : remarks,
    'type': 'ssr',
    'server': fields[0],
    'port': port,
    'cipher': fields[3],
    'password': password,
    'obfs': fields[4],
    'protocol': fields[2],
    if (obfsParam.isNotEmpty) 'obfs-param': obfsParam,
    if (protocolParam.isNotEmpty) 'protocol-param': protocolParam,
    'udp': true,
  };
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
    emulateXray: true,
  );
  final network = params['type'] ?? 'tcp';
  if (network == 'xhttp' || network == 'splithttp') {
    throw _UnsupportedLink(
      SkippedNode(
        name: name,
        kind: 'xhttp',
        reason: SkippedNodeReason.transport,
      ),
    );
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
  final (hopUri, hopPorts) = splitHysteria2Ports(uri);
  final link = Uri.parse(hopUri);
  final server = link.host;
  final port = link.hasPort ? link.port : 443;
  if (server.isEmpty || port < 1 || port > 65535) return null;
  final params = link.queryParameters;
  final auth = _decodeComponent(link.userInfo);
  final name = _displayName(link.fragment);
  final realm = link.scheme.endsWith('+realm');
  final ports = hopPorts.isNotEmpty ? hopPorts : (params['mport'] ?? '');
  final proxy = <String, Object?>{
    'name': name.isEmpty ? server : name,
    'type': 'hysteria2',
    'server': server,
    'port': port,
    if (!realm) 'password': auth,
    if (realm) ...{
      if ((params['auth'] ?? '').isNotEmpty) 'password': params['auth'],
      'realm-opts': {
        'enable': true,
        'server-url': Uri(
          scheme: 'https',
          host: server,
          port: link.hasPort ? port : null,
        ).toString(),
        if (auth.isNotEmpty) 'token': auth,
        if (link.path.length > 1)
          'realm-id': _decodeComponent(link.path.substring(1)),
        'stun-servers': ?link.queryParametersAll['stun'],
      },
    },
  };
  final cleanPorts = ports.replaceAll(' ', '');
  if (cleanPorts.isNotEmpty && isValidPortHopping(cleanPorts)) {
    proxy['ports'] = cleanPorts;
    final hopInterval = int.tryParse(params['hop-interval'] ?? '');
    if (hopInterval != null && hopInterval >= 5) {
      proxy['hop-interval'] = hopInterval;
    }
  }
  final sni = params['sni'] ?? server;
  if (sni.isNotEmpty) proxy['sni'] = sni;
  if (params['insecure'] == '1' || params['insecure'] == 'true') {
    proxy['skip-cert-verify'] = true;
  }
  final obfs = params['obfs'] ?? '';
  final obfsPassword = params['obfs-password'] ?? '';
  if ((obfs == 'salamander' || obfs == 'gecko') && obfsPassword.isNotEmpty) {
    proxy['obfs'] = obfs;
    proxy['obfs-password'] = obfsPassword;
  }
  for (final field in ['up', 'down']) {
    final value = params[field];
    if (value != null && value.isNotEmpty) proxy[field] = value;
  }
  final alpn = params['alpn'] ?? '';
  if (alpn.isNotEmpty) {
    proxy['alpn'] = alpn.split(',').map((e) => e.trim()).toList();
  }
  final pin = params['pinSHA256'] ?? '';
  if (pin.isNotEmpty) proxy['fingerprint'] = pin;
  return proxy;
}

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

const _ttHostname = 0x01;
const _ttAddress = 0x02;
const _ttCustomSni = 0x03;
const _ttUsername = 0x05;
const _ttPassword = 0x06;
const _ttSkipVerification = 0x07;
const _ttCertificate = 0x08;
const _ttUpstreamProtocol = 0x09;
const _ttAntiDpi = 0x0A;
const _ttClientRandomPrefix = 0x0B;
const _ttName = 0x0C;

Map<String, Object?>? _parseTrustTunnel(
  String uri, {
  required void Function() onLoss,
}) {
  final hashIdx = uri.indexOf('#');
  final fragment = hashIdx >= 0 ? _displayName(uri.substring(hashIdx + 1)) : '';
  final body = hashIdx >= 0 ? uri.substring(0, hashIdx) : uri;
  if (!body.startsWith('tt://?')) return null;
  final fields = _readTrustTunnelFields(body.substring('tt://?'.length));
  if (fields == null) return null;

  String text(int tag) {
    final value = fields[tag]?.first;
    return value == null ? '' : utf8.decode(value, allowMalformed: true);
  }

  bool flag(int tag) => fields[tag]?.first.any((b) => b != 0) ?? false;

  final username = text(_ttUsername);
  final password = text(_ttPassword);
  if (username.isEmpty || password.isEmpty) return null;

  final hostname = text(_ttHostname);
  final addresses = fields[_ttAddress] ?? const [];
  var server = hostname;
  var port = 443;
  if (addresses.isNotEmpty) {
    final split = splitHostPort(
      utf8.decode(addresses.first, allowMalformed: true),
    );
    if (split == null) return null;
    (server, port) = split;
  }
  if (server.isEmpty) return null;
  if (addresses.length > 1) onLoss();

  final name = text(_ttName);
  final proxy = <String, Object?>{
    'name': name.isNotEmpty
        ? name
        : fragment.isNotEmpty
        ? fragment
        : hostname.isNotEmpty
        ? hostname
        : server,
    'type': 'trusttunnel',
    'server': server,
    'port': port,
    'username': username,
    'password': password,
    'udp': true,
  };
  final sni = text(_ttCustomSni).isNotEmpty ? text(_ttCustomSni) : hostname;
  if (sni.isNotEmpty) proxy['sni'] = sni;
  final skipVerification = flag(_ttSkipVerification);
  if (skipVerification) proxy['skip-cert-verify'] = true;
  final chain = fields[_ttCertificate]?.first;
  if (chain != null && !skipVerification) {
    final der = _firstDerCertificate(chain);
    if (der == null) {
      onLoss();
    } else {
      proxy['fingerprint'] = sha256.convert(der).toString();
    }
  }
  final upstream = fields[_ttUpstreamProtocol]?.first;
  if (upstream != null && upstream.length == 1 && upstream.first == 2) {
    proxy['quic'] = true;
  }
  if (flag(_ttAntiDpi) || fields.containsKey(_ttClientRandomPrefix)) onLoss();
  return proxy;
}

Map<int, List<List<int>>>? _readTrustTunnelFields(String payload) {
  final List<int> bytes;
  try {
    bytes = base64Url.decode(base64Url.normalize(payload));
  } on FormatException {
    return null;
  }
  final fields = <int, List<List<int>>>{};
  var offset = 0;

  int? readVarint() {
    if (offset >= bytes.length) return null;
    final size = 1 << (bytes[offset] >> 6);
    if (offset + size > bytes.length) return null;
    var value = bytes[offset] & 0x3f;
    for (var i = 1; i < size; i++) {
      value = (value << 8) | bytes[offset + i];
    }
    offset += size;
    return value;
  }

  while (offset < bytes.length) {
    final tag = readVarint();
    final length = tag == null ? null : readVarint();
    if (length == null || offset + length > bytes.length) return null;
    fields
        .putIfAbsent(tag!, () => [])
        .add(bytes.sublist(offset, offset + length));
    offset += length;
  }
  return fields;
}

List<int>? _firstDerCertificate(List<int> chain) {
  if (chain.length < 2 || chain[0] != 0x30) return null;
  var length = chain[1];
  var header = 2;
  if (length & 0x80 != 0) {
    final count = length & 0x7f;
    if (count == 0 || count > 4 || chain.length < 2 + count) return null;
    length = 0;
    for (var i = 0; i < count; i++) {
      length = (length << 8) | chain[2 + i];
    }
    header += count;
  }
  return header + length > chain.length
      ? null
      : chain.sublist(0, header + length);
}

Map<String, Object?>? _parseHysteria1(String uri) {
  const schemeEnd = 'hysteria://'.length;
  final noScheme = uri.substring(schemeEnd);

  final hashIdx = noScheme.indexOf('#');
  final name = hashIdx >= 0
      ? _displayName(noScheme.substring(hashIdx + 1))
      : '';
  final withoutName = hashIdx >= 0 ? noScheme.substring(0, hashIdx) : noScheme;

  final queryIdx = withoutName.indexOf('?');
  final hostPort = queryIdx >= 0
      ? withoutName.substring(0, queryIdx)
      : withoutName;
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
  if (up.isEmpty || down.isEmpty) {
    throw _UnsupportedLink(
      SkippedNode(
        name: displayName,
        kind: 'hysteria',
        reason: SkippedNodeReason.bandwidth,
      ),
    );
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
  final obfsParam = params['obfsParam'] ?? params['obfs-param'] ?? '';
  final obfs = params['obfs'] ?? '';
  if (obfsParam.isNotEmpty) {
    proxy['obfs'] = obfsParam;
  } else if (obfs.isNotEmpty) {
    proxy['obfs'] = obfs;
  }
  return proxy;
}

(
  String userinfo,
  String server,
  int port,
  Map<String, String> params,
  String name,
)?
_splitUserinfoUri(String uri, {bool requireUserinfo = true}) {
  final schemeEnd = uri.indexOf('://') + 3;
  final noScheme = uri.substring(schemeEnd);

  final hashIdx = noScheme.indexOf('#');
  final name = hashIdx >= 0
      ? _displayName(noScheme.substring(hashIdx + 1))
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
  if (atIdx < 0 && requireUserinfo) return null;
  final userinfo = atIdx < 0
      ? ''
      : _decodeComponent(hostPort.substring(0, atIdx));
  if (userinfo.isEmpty && requireUserinfo) return null;
  final authority = hostPort.substring(atIdx + 1);
  final slashIdx = authority.indexOf('/');
  final split = splitHostPort(
    slashIdx >= 0 ? authority.substring(0, slashIdx) : authority,
  );
  if (split == null) return null;
  final (server, port) = split;
  return (userinfo, server, port, params, name.isEmpty ? server : name);
}

(String, String) splitHysteria2Ports(String uri) {
  final schemeIdx = uri.indexOf('://');
  if (schemeIdx < 0) return (uri, '');
  final head = uri.substring(0, schemeIdx + 3);
  final rest = uri.substring(schemeIdx + 3);

  final tailIdx = rest.indexOf(RegExp(r'[/?#]'));
  var auth = tailIdx >= 0 ? rest.substring(0, tailIdx) : rest;
  final tail = tailIdx >= 0 ? rest.substring(tailIdx) : '';

  var userinfo = '';
  final atIdx = auth.lastIndexOf('@');
  if (atIdx >= 0) {
    userinfo = auth.substring(0, atIdx + 1);
    auth = auth.substring(atIdx + 1);
  }
  if (auth.contains(']')) return (uri, '');
  final colonIdx = auth.lastIndexOf(':');
  if (colonIdx < 0) return (uri, '');

  final host = auth.substring(0, colonIdx);
  final ports = auth.substring(colonIdx + 1);
  if (!ports.contains(',') && !ports.contains('-')) return (uri, '');
  final firstIdx = ports.indexOf(RegExp('[,-]'));
  final first = firstIdx >= 0 ? ports.substring(0, firstIdx) : ports;
  if (int.tryParse(first) == null) return (uri, '');
  return ('$head$userinfo$host:$first$tail', ports);
}

(String, int)? splitHostPort(String hostPort) {
  final bracketIdx = hostPort.lastIndexOf(']');
  final colonIdx = bracketIdx >= 0
      ? hostPort.indexOf(':', bracketIdx + 1)
      : hostPort.lastIndexOf(':');
  if (colonIdx <= 0) return null;
  final server =
      (bracketIdx >= 0
              ? hostPort.substring(0, bracketIdx + 1)
              : hostPort.substring(0, colonIdx))
          .replaceAll('[', '')
          .replaceAll(']', '');
  final port = int.tryParse(hostPort.substring(colonIdx + 1));
  if (server.isEmpty || port == null) return null;
  return (server, port);
}

String _mihomoNetwork(String network) =>
    network == 'httpupgrade' ? 'ws' : network;

const reservedProxyNames = <String>{
  'PROXY',
  'GLOBAL',
  'DIRECT',
  'REJECT',
  'REJECT-DROP',
  'COMPATIBLE',
  'PASS',
  'PASS-RULE',
};

const _vlessVisionFlow = 'xtls-rprx-vision';
const _vmessCiphers = {'auto', 'aes-128-gcm', 'chacha20-poly1305', 'none'};
final _portHopPattern = RegExp(r'^\d{1,5}(-\d{1,5})?(,\d{1,5}(-\d{1,5})?)*$');

String sanitizeVmessCipher(String cipher) {
  final lower = cipher.toLowerCase();
  return _vmessCiphers.contains(lower) ? lower : 'auto';
}

String? sanitizeVlessFlow(String flow) {
  if (flow.isEmpty) return null;
  if (flow.length >= 16 && flow.substring(0, 16) != _vlessVisionFlow) {
    return null;
  }
  return flow;
}

bool isValidVlessEncryption(String encryption) {
  final parts = encryption.split('.');
  return parts.length >= 4 && parts.first == 'mlkem768x25519plus';
}

bool isValidPortHopping(String ports) => _portHopPattern.hasMatch(ports);

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

String _withTopLevelEarlyData(String path, String ed, String eh) {
  if (ed.isEmpty && eh.isEmpty) return path;
  if (path.contains('ed=') || path.contains('eh=')) return path;
  final extra = [
    if (ed.isNotEmpty) 'ed=$ed',
    if (eh.isNotEmpty) 'eh=$eh',
  ].join('&');
  return path.contains('?') ? '$path&$extra' : '$path?$extra';
}

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

const _mihomoFingerprints = {
  'chrome',
  'firefox',
  'safari',
  'ios',
  'android',
  'edge',
  '360',
  'qq',
  'random',
  'randomized',
  'chrome120',
  'firefox120',
  'safari16',
  'chrome_psk',
  'chrome_psk_shuffle',
  'chrome_padding_psk_shuffle',
  'chrome_pq',
  'chrome_pq_psk',
};

const _fingerprintFamilies = [
  ('hellochrome', 'chrome'),
  ('hellofirefox', 'firefox'),
  ('hellosafari', 'safari'),
  ('helloios', 'ios'),
  ('helloedge', 'edge'),
  ('hello360', '360'),
  ('helloqq', 'qq'),
  ('helloandroid', 'android'),
  ('hellorandomized', 'randomized'),
  ('randomized', 'randomized'),
];

// Xray reads an empty fingerprint as Chrome; mihomo reads it, and any name it
// does not know, as Go TLS. REALITY needs uTLS, so only plain TLS keeps opt-outs.
String? resolveClientFingerprint(String raw, {required bool reality}) {
  final name = raw.trim().toLowerCase();
  if (name.isEmpty) return 'chrome';
  if (name == 'unsafe' || name == 'none') return reality ? 'chrome' : null;
  if (_mihomoFingerprints.contains(name)) return name;
  if (name == 'hellochrome_120') return 'chrome120';
  if (name == 'hellofirefox_120') return 'firefox120';
  if (name == 'hellosafari_16_0') return 'safari16';
  for (final (prefix, target) in _fingerprintFamilies) {
    if (name.startsWith(prefix)) return target;
  }
  return 'chrome';
}

void applyClientFingerprint(Map<String, Object?> proxy, String raw) {
  final reality = proxy['reality-opts'];
  final fingerprint = resolveClientFingerprint(raw, reality: reality is Map);
  if (fingerprint == null) return;
  proxy['client-fingerprint'] = fingerprint;
  // mihomo strips X25519MLKEM768 from REALITY hellos unless this is set.
  if (fingerprint == 'chrome' && reality is Map<String, Object?>) {
    reality['support-x25519mlkem768'] = true;
  }
}

void _applyTlsExtras(
  Map<String, Object?> proxy, {
  required String fingerprint,
  required String alpn,
  required bool allowInsecure,
  bool emulateXray = false,
}) {
  if (emulateXray) {
    if (proxy['tls'] == true || proxy['type'] == 'trojan') {
      applyClientFingerprint(proxy, fingerprint);
    }
  } else if (fingerprint.isNotEmpty) {
    proxy['client-fingerprint'] = fingerprint;
  }
  if (alpn.isNotEmpty) {
    proxy['alpn'] = alpn.split(',').map((e) => e.trim()).toList();
  }
  if (allowInsecure) proxy['skip-cert-verify'] = true;
}

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
        if ((opts['obfs-host'] ?? '').isNotEmpty) 'host': opts['obfs-host'],
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

final _goDurationPart = RegExp(r'(\d+(?:\.\d+)?)(ns|us|µs|ms|s|m|h)');

int? goDurationMilliseconds(Object? value) {
  final text = value?.toString().trim() ?? '';
  final parts = _goDurationPart.allMatches(text).toList();
  if (parts.isEmpty ||
      parts.fold(0, (n, m) => n + m.end - m.start) != text.length) {
    return null;
  }
  var total = 0.0;
  for (final part in parts) {
    total +=
        double.parse(part[1]!) *
        switch (part[2]) {
          'ns' => 1e-6,
          'us' || 'µs' => 1e-3,
          'ms' => 1,
          's' => 1000,
          'm' => 60000,
          _ => 3600000,
        };
  }
  return total.round();
}

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
      params[_decodeComponent(key.replaceAll('+', ' '))] = _decodeComponent(
        value.replaceAll('+', ' '),
      );
    }
    return params;
  }
}

String emitProxiesConfig(
  List<Map<String, Object?>> proxies, {
  List<Map<String, Object?>> groups = const [],
  List<String> rules = const [],
  List<String>? entries,
}) {
  final buffer = StringBuffer()..writeln('proxies:');
  for (final proxy in proxies) {
    buffer.writeln('  - {${_emitMap(proxy)}}');
  }

  final claimed = <String>{
    for (final group in groups)
      ...?(group['proxies'] as List?)?.map((e) => e.toString()),
  };
  final groupEntries = [
    if (entries != null)
      for (final entry in entries) _yamlString(entry)
    else ...[
      for (final group in groups)
        if (!claimed.contains(group['name']))
          _yamlString(group['name']! as String),
      for (final proxy in proxies)
        if (!claimed.contains(proxy['name']))
          _yamlString(proxy['name']! as String),
    ],
    'DIRECT',
  ].join(', ');
  buffer.writeln('proxy-groups:');
  for (final group in groups) {
    buffer.writeln('  - {${_emitMap(group)}}');
  }
  buffer
    ..writeln('  - name: "PROXY"')
    ..writeln('    type: select')
    ..writeln('    proxies: [$groupEntries]')
    ..writeln('rules:');
  for (final rule in rules) {
    buffer.writeln('  - ${_yamlString(rule)}');
  }
  if (!rules.any((rule) => rule.startsWith('MATCH,'))) {
    buffer.writeln('  - MATCH,PROXY');
  }
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
      .replaceAllMapped(
        RegExp('[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'),
        (m) => '\\x${m[0]!.codeUnitAt(0).toRadixString(16).padLeft(2, '0')}',
      );
  return '"$escaped"';
}

String _yamlValue(Object? value) {
  if (value is Map<String, Object?>) return '{${_emitMap(value)}}';
  return _yamlString(value);
}
