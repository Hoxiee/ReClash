import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';

import 'report.dart';

const redactionMask = '***';

/// Shorter values would mask ordinary words and numbers all over the logs.
const minSecretLength = 6;

/// A secret read from the config or the profile was still in the report after
/// redaction. Carries the section only, never the secret.
final class ReportLeak implements Exception {
  const ReportLeak(this.section);

  final String section;

  @override
  String toString() => 'ReportLeak($section)';
}

const _fieldNames =
    'password|passwd|uuid|private-key|private_key|privatekey|pre-shared-key|'
    'psk|auth-str|auth_str|auth|token|access-token|access_token|secret|'
    'obfs-password|short-id|api-key|apikey|age-secret-key|agesecretkey';

final _field = RegExp(
  '(?<!\\w)($_fieldNames)(["\']?[ \\t]*[:=][ \\t]*)'
  '("[^"\\n]*"|\'[^\'\\n]*\'|[^\\s,"\'{}\\[\\]#&]+)',
  caseSensitive: false,
);

final _secretKey = RegExp('^(?:$_fieldNames)\$', caseSensitive: false);

final _secretQueryKey = RegExp(
  'token|key|auth|sign|secret|pass|uuid|sid|session|code|ticket',
  caseSensitive: false,
);

final _url = RegExp(r'''\b([A-Za-z][A-Za-z0-9+.-]{1,15})://([^\s"'<>`\\]+)''');

final _uuid = RegExp(
  r'\b[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-'
  r'[0-9a-fA-F]{12}\b',
);

final _privateKey = RegExp(
  r'-----BEGIN [A-Z ]*PRIVATE KEY-----[\s\S]*?-----END [A-Z ]*PRIVATE KEY-----',
);

final _ipv4 = RegExp(r'(?<![\d.])(?:\d{1,3}\.){3}\d{1,3}(?!\d)(?!\.\d)');

final _ipv6 = RegExp(
  r'(?<![\w:])(?:[0-9A-Fa-f]{0,4}:){2,7}[0-9A-Fa-f]{0,4}(?![\w:])',
);

final _host = RegExp(
  r'(?<![\w.-])(?:[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?\.)+'
  r'([A-Za-z]{2,24})(?![\w-])',
);

final _tokenChars = RegExp(r'^[A-Za-z0-9_\-=+%.~]+$');
final _digit = RegExp(r'\d');
final _letter = RegExp('[A-Za-z]');

/// Two-letter labels are country domains; these few are file extensions the
/// logs name far more often.
const _notTlds = {'md', 'sh', 'py', 'rs', 'so', 'go', 'js', 'ts', 'db', 'gz'};

const _tlds = {
  'com',
  'net',
  'org',
  'io',
  'dev',
  'app',
  'info',
  'biz',
  'xyz',
  'online',
  'site',
  'top',
  'club',
  'pro',
  'link',
  'live',
  'cloud',
  'host',
  'space',
  'store',
  'tech',
  'fun',
  'icu',
  'vip',
  'work',
  'world',
  'one',
  'network',
  'services',
  'digital',
  'today',
  'global',
  'shop',
  'win',
  'page',
  'run',
  'moe',
  'zone',
  'email',
  'center',
  'systems',
  'solutions',
  'media',
  'news',
  'edu',
  'gov',
  'mil',
  'int',
  'arpa',
  'local',
  'lan',
  'internal',
  'invalid',
};

bool _tokenLike(String value) =>
    value.length >= 16 &&
    _tokenChars.hasMatch(value) &&
    (value.length >= 24 || (_digit.hasMatch(value) && _letter.hasMatch(value)));

/// The values of secret fields in [text], such as a config's passwords and
/// UUIDs, with their quotes removed.
Set<String> fieldSecrets(String text) => {
  for (final match in _field.allMatches(text))
    if (_unquote(match[3]!) case final value
        when value.length >= minSecretLength && value != redactionMask)
      value,
};

/// A subscription URL and the parts of it that would let someone else fetch
/// the subscription.
Set<String> urlSecrets(String url) {
  final uri = Uri.tryParse(url.trim());
  if (uri == null || url.trim().isEmpty) return const {};
  return {
    url.trim(),
    if (uri.userInfo.isNotEmpty) uri.userInfo,
    for (final segment in uri.pathSegments)
      if (segment.length >= 16 ||
          (segment.length >= minSecretLength && _digit.hasMatch(segment)))
        segment,
    for (final value in uri.queryParametersAll.values.expand((v) => v))
      if (value.length >= minSecretLength) value,
    if (uri.hasQuery && uri.query.length >= minSecretLength) uri.query,
  };
}

/// What a report may show of a subscription URL: the scheme and host.
String urlOrigin(String url) {
  final uri = Uri.tryParse(url.trim());
  if (uri == null || uri.host.isEmpty) return url.isEmpty ? '' : redactionMask;
  final path = uri.path.length > 1 || uri.hasQuery ? '/$redactionMask' : '';
  return '${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}$path';
}

String _unquote(String value) {
  if (value.length >= 2 &&
      (value.startsWith('"') && value.endsWith('"') ||
          value.startsWith("'") && value.endsWith("'"))) {
    return value.substring(1, value.length - 1);
  }
  return value;
}

/// Finds many literal secrets in one pass (Aho–Corasick), so checking a
/// report stays linear in its size however many nodes the profile has.
final class SecretMatcher {
  SecretMatcher(Iterable<String> secrets) {
    for (final secret in secrets) {
      if (secret.length >= minSecretLength) _insert(secret);
    }
    _link();
  }

  final List<Map<int, int>> _next = [{}];
  final List<int> _fail = [0];

  /// The longest secret that ends at a node, 0 for none.
  final List<int> _longest = [0];

  bool get isEmpty => _next.length == 1;

  void _insert(String secret) {
    var node = 0;
    for (final unit in secret.codeUnits) {
      node = _next[node][unit] ??= _add();
    }
    _longest[node] = max(_longest[node], secret.length);
  }

  int _add() {
    _next.add({});
    _fail.add(0);
    _longest.add(0);
    return _next.length - 1;
  }

  void _link() {
    final queue = [..._next[0].values];
    for (var i = 0; i < queue.length; i++) {
      final node = queue[i];
      for (final MapEntry(key: unit, value: child) in _next[node].entries) {
        var fallback = _fail[node];
        while (fallback != 0 && !_next[fallback].containsKey(unit)) {
          fallback = _fail[fallback];
        }
        final target = _next[fallback][unit];
        _fail[child] = target != null && target != child ? target : 0;
        _longest[child] = max(_longest[child], _longest[_fail[child]]);
        queue.add(child);
      }
    }
  }

  /// Merged `[start, end)` ranges covered by secrets, in order.
  List<(int, int)> ranges(String text) {
    final ranges = <(int, int)>[];
    if (isEmpty) return ranges;
    var node = 0;
    for (var i = 0; i < text.length; i++) {
      final unit = text.codeUnitAt(i);
      while (node != 0 && !_next[node].containsKey(unit)) {
        node = _fail[node];
      }
      node = _next[node][unit] ?? 0;
      final length = _longest[node];
      if (length == 0) continue;
      var start = i + 1 - length;
      final end = i + 1;
      while (ranges.isNotEmpty && ranges.last.$2 >= start) {
        start = min(start, ranges.removeLast().$1);
      }
      ranges.add((start, end));
    }
    return ranges;
  }

  bool foundIn(String text) => ranges(text).isNotEmpty;

  String mask(String text) {
    final found = ranges(text);
    if (found.isEmpty) return text;
    final out = StringBuffer();
    var last = 0;
    for (final (start, end) in found) {
      out
        ..write(text.substring(last, start))
        ..write(redactionMask);
      last = end;
    }
    return (out..write(text.substring(last))).toString();
  }
}

final class Redactor {
  Redactor({
    required this.level,
    required Iterable<String> secrets,
    List<int>? salt,
  }) : matcher = SecretMatcher(secrets),
       _salt = salt ?? _randomSalt();

  final ReportRedaction level;
  final SecretMatcher matcher;

  /// Fresh per report, so a hashed host cannot be looked up in a table built
  /// from another report.
  final List<int> _salt;
  final Map<String, String> _hashes = {};

  String text(String input) {
    if (input.isEmpty) return input;
    var out = matcher.mask(input);
    out = out.replaceAll(_privateKey, redactionMask);
    out = out.replaceAllMapped(_url, _redactUrl);
    out = out.replaceAllMapped(
      _field,
      (m) => '${m[1]}${m[2]}${_maskQuoted(m[3]!)}',
    );
    out = out.replaceAll(_uuid, redactionMask);
    if (level == ReportRedaction.public) {
      out = out.replaceAllMapped(_ipv4, (m) => _ip(m[0]!));
      out = out.replaceAllMapped(_ipv6, (m) => _ip(m[0]!));
      out = out.replaceAllMapped(_host, _hostMatch);
    }
    return out;
  }

  /// Every string in a JSON value, map keys included.
  Object? json(Object? value) => switch (value) {
    final String text => this.text(text),
    final Map<Object?, Object?> map => <String, Object?>{
      for (final MapEntry(:key, :value) in map.entries)
        text('$key'):
            (value is String || value is num) &&
                '$value'.isNotEmpty &&
                _secretKey.hasMatch('$key')
            ? redactionMask
            : json(value),
    },
    final List<Object?> list => [for (final item in list) json(item)],
    _ => value,
  };

  List<String> lines(List<String> lines) {
    if (lines.isEmpty) return lines;
    return const LineSplitter().convert(text(lines.join('\n')));
  }

  String _maskQuoted(String value) => switch (value[0]) {
    '"' => '"$redactionMask"',
    "'" => "'$redactionMask'",
    _ => redactionMask,
  };

  String _redactUrl(Match match) {
    var rest = match[2]!;
    var fragment = '';
    final hash = rest.indexOf('#');
    if (hash >= 0) {
      fragment = rest.substring(hash);
      rest = rest.substring(0, hash);
    }
    var query = '';
    final question = rest.indexOf('?');
    if (question >= 0) {
      query = '?${_redactQuery(rest.substring(question + 1))}';
      rest = rest.substring(0, question);
    }
    final slash = rest.indexOf('/');
    var authority = slash >= 0 ? rest.substring(0, slash) : rest;
    final path = slash >= 0
        ? rest
              .substring(slash)
              .split('/')
              .map((s) => _tokenLike(s) ? redactionMask : s)
              .join('/')
        : '';
    final at = authority.lastIndexOf('@');
    if (at >= 0) {
      authority = '$redactionMask@${authority.substring(at + 1)}';
    } else if (_tokenLike(authority) && !authority.contains('.')) {
      authority = redactionMask;
    }
    return '${match[1]}://$authority$path$query$fragment';
  }

  String _redactQuery(String query) => query
      .split('&')
      .map((pair) {
        final equals = pair.indexOf('=');
        if (equals < 0) return _tokenLike(pair) ? redactionMask : pair;
        final key = pair.substring(0, equals);
        final value = pair.substring(equals + 1);
        if (value.isEmpty) return pair;
        return _secretQueryKey.hasMatch(key) || _tokenLike(value)
            ? '$key=$redactionMask'
            : pair;
      })
      .join('&');

  String _ip(String candidate) {
    final address = InternetAddress.tryParse(candidate);
    if (address == null) return candidate;
    if (address.type == InternetAddressType.IPv6 &&
        !candidate.contains('::') &&
        ':'.allMatches(candidate).length < 3) {
      return candidate;
    }
    if (address.isLoopback || address.address == '0.0.0.0') return candidate;
    if (address.type == InternetAddressType.IPv6 &&
        address.rawAddress.every((byte) => byte == 0)) {
      return candidate;
    }
    return 'ip-${_hash(address.address)}';
  }

  String _hostMatch(Match match) {
    final host = match[0]!;
    final tld = match[1]!.toLowerCase();
    final known = tld.length == 2
        ? !_notTlds.contains(tld)
        : _tlds.contains(tld);
    if (!known) return host;
    return 'host-${_hash(host.toLowerCase())}';
  }

  String _hash(String value) => _hashes[value] ??= sha256
      .convert([..._salt, ...utf8.encode(value)])
      .toString()
      .substring(0, 8);
}

List<int> _randomSalt() {
  final random = Random.secure();
  return [for (var i = 0; i < 16; i++) random.nextInt(256)];
}

ReportData redactReport(ReportData data, Redactor redactor) {
  List<Map<String, Object?>>? rows(List<Map<String, Object?>>? rows) =>
      rows == null
      ? null
      : [for (final row in rows) redactor.json(row)! as Map<String, Object?>];
  Map<String, Object?>? map(Map<String, Object?>? map) =>
      map == null ? null : redactor.json(map)! as Map<String, Object?>;
  return ReportData(
    manifest: data.manifest,
    summary: map(data.summary)!,
    findings: rows(data.findings),
    path: map(data.path),
    services: map(data.services),
    environment: map(data.environment),
    profile: map(data.profile),
    history: map(data.history),
    servers: rows(data.servers),
    config: data.config == null ? null : redactor.text(data.config!),
    logs: data.logs?.map(
      (name, lines) => MapEntry(name, redactor.lines(lines)),
    ),
  );
}

/// The first section that still holds a secret verbatim, or null.
String? findLeak(ReportData data, SecretMatcher matcher) {
  if (matcher.isEmpty) return null;
  bool leaks(Object? value) => switch (value) {
    final String text => matcher.foundIn(text),
    final Map<Object?, Object?> map => map.entries.any(
      (e) => leaks(e.key) || leaks(e.value),
    ),
    final List<Object?> list => list.any(leaks),
    _ => false,
  };
  final sections = <String, Object?>{
    'manifest': data.manifest,
    'summary': data.summary,
    'findings': data.findings,
    'path': data.path,
    'services': data.services,
    'environment': data.environment,
    'profile': data.profile,
    'history': data.history,
    'servers': data.servers,
    'config': data.config,
  };
  for (final MapEntry(:key, :value) in sections.entries) {
    if (leaks(value)) return key;
  }
  for (final MapEntry(:key, :value) in (data.logs ?? const {}).entries) {
    if (matcher.foundIn(value.join('\n'))) return 'logs/$key';
  }
  return null;
}
