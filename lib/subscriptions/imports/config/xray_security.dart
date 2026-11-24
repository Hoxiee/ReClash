library;

import 'xray_fingerprint.dart';

/// Copies the client-side TLS and REALITY fields of an Xray [streamSettings]
/// into a mihomo proxy. Returns true when a field mihomo cannot express was
/// present, so the caller can require the usual loss review.
bool applyXraySecurity(
  Map<String, Object?> proxy,
  Map<String, Object?> stream, {
  required String type,
}) {
  final security = (stream['security']?.toString() ?? '').toLowerCase();
  final tls = _map(stream['tlsSettings']);
  final reality = _map(stream['realitySettings']);
  var losses = false;

  if (security == 'reality') {
    proxy['tls'] = true;
    final options = <String, Object?>{};
    final password = _text(reality?['password']);
    final publicKey = _text(reality?['publicKey']) ?? password;
    if (publicKey != null) options['public-key'] = publicKey;
    final shortId = _text(reality?['shortId']);
    if (shortId != null) options['short-id'] = shortId;
    final mldsa = _text(reality?['mldsa65Verify']);
    if (mldsa != null) options['mldsa65-verify'] = mldsa;
    if (_text(reality?['spiderX']) != null) losses = true;
    proxy['reality-opts'] = options;
    _applyTlsCommon(proxy, tls, type: type, losses: () => losses = true);
    final serverName =
        _text(reality?['serverName']) ?? _text(tls?['serverName']);
    if (serverName != null) _setServerName(proxy, type, serverName);
    applyClientFingerprint(proxy, _text(reality?['fingerprint']) ?? '');
    if (publicKey == null) losses = true;
    losses = _serverOnlyRealityFields(reality) || losses;
    return losses;
  }

  if (security == 'tls' || security == 'xtls') {
    proxy['tls'] = true;
    _applyTlsCommon(proxy, tls, type: type, losses: () => losses = true);
    applyClientFingerprint(proxy, _text(tls?['fingerprint']) ?? '');
    if (reality != null) losses = true;
    if (security == 'xtls') losses = true;
    return losses;
  }

  if (_present(tls) ||
      _present(reality) ||
      security.isNotEmpty && security != 'none') {
    losses = true;
  }
  return losses;
}

void _applyTlsCommon(
  Map<String, Object?> proxy,
  Map<String, Object?>? tls, {
  required String type,
  required void Function() losses,
}) {
  if (tls == null) return;
  final serverName = _text(tls['serverName']);
  if (serverName != null) _setServerName(proxy, type, serverName);
  if (tls['allowInsecure'] == true) proxy['skip-cert-verify'] = true;
  final alpn = tls['alpn'];
  if (alpn is List && alpn.every((entry) => entry is String)) {
    proxy['alpn'] = alpn.cast<String>();
  } else if (alpn != null) {
    losses();
  }
  final pin = _text(tls['pinnedPeerCertSha256']);
  if (pin != null) proxy['fingerprint'] = pin;
  final verifyName = _text(tls['verifyPeerCertByName']);
  if (verifyName != null) proxy['name-cert-verify'] = verifyName;
  final ech = xrayEchOptions(tls['echConfigList']);
  if (ech != null) proxy['ech-opts'] = ech;

  for (final key in const [
    'minVersion',
    'maxVersion',
    'cipherSuites',
    'curvePreferences',
    'disableSystemRoot',
    'useSystemCA',
    'enableSessionResumption',
    'rejectUnknownSni',
    'certificates',
    'masterKeyLog',
    'echSockopt',
    'echServerKeys',
  ]) {
    if (_present(tls[key])) losses();
  }
}

bool _serverOnlyRealityFields(Map<String, Object?>? reality) {
  if (reality == null) return false;
  for (final key in const [
    'show',
    'target',
    'xver',
    'serverNames',
    'privateKey',
    'minClientVer',
    'maxClientVer',
    'maxTimeDiff',
    'shortIds',
    'mldsa65Seed',
    'limitFallbackUpload',
    'limitFallbackDownload',
  ]) {
    if (_present(reality[key])) return true;
  }
  return false;
}

/// Xray's ECHConfig sources: a fixed config, a DNS URL, or a forced
/// `name+https://resolver` pair. Mihomo takes the same three forms through
/// `ech-opts`.
Map<String, Object?>? xrayEchOptions(Object? value) {
  final raw = _text(value);
  if (raw == null) return null;
  final plus = raw.indexOf('+');
  if (plus > 0) {
    final resolver = raw.substring(plus + 1);
    if (_isEchResolver(resolver)) {
      return {
        'enable': true,
        'query-server-name': raw.substring(0, plus),
        'query-server': resolver,
      };
    }
  }
  if (_isEchResolver(raw)) return {'enable': true, 'query-server': raw};
  return {'enable': true, 'config': raw};
}

bool _isEchResolver(String value) =>
    value.startsWith('udp://') ||
    value.startsWith('https://') ||
    value.startsWith('h2c://');

String xrayServerNameKey(String type) => switch (type) {
  'trojan' || 'http' || 'socks5' => 'sni',
  _ => 'servername',
};

void _setServerName(
  Map<String, Object?> proxy,
  String type,
  String serverName,
) {
  proxy[xrayServerNameKey(type)] = serverName;
}

/// Applies the Xray `streamSettings.sockopt` fields mihomo supports and marks
/// the rest as losses.
bool applyXraySockopt(Map<String, Object?> proxy, Object? value) {
  final sockopt = _map(value);
  if (sockopt == null) return false;
  var losses = false;
  if (sockopt['tcpFastOpen'] == true) proxy['tfo'] = true;
  if (sockopt['tcpMptcp'] == true) proxy['mptcp'] = true;
  final mark = switch (sockopt['mark']) {
    final num value => value.toInt(),
    final String value => int.tryParse(value),
    _ => null,
  };
  if (mark != null) {
    proxy['routing-mark'] = mark;
  } else if (_present(sockopt['mark'])) {
    losses = true;
  }
  final interface = _text(sockopt['interface']);
  if (interface != null) proxy['interface-name'] = interface;
  for (final key in const [
    'tcpKeepAliveInterval',
    'tcpKeepAliveIdle',
    'tcpUserTimeout',
    'tcpNoDelay',
    'tcpCongestion',
    'tcpWindowClamp',
    'domainStrategy',
    'tproxy',
    'acceptProxyProtocol',
    'bindToDevice',
    'v6only',
  ]) {
    if (_present(sockopt[key])) losses = true;
  }
  return losses;
}

Map<String, Object?>? _map(Object? value) =>
    value is Map<String, Object?> ? value : null;

String? _text(Object? value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}

bool _present(Object? value) => switch (value) {
  null || '' || false => false,
  List() => value.isNotEmpty,
  Map() => value.isNotEmpty,
  _ => true,
};
