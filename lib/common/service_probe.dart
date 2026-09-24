import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:reclash/common/net/request.dart';
import 'package:reclash/common/regional/regional.dart';
import 'package:reclash/enum/enum.dart';

const serviceProbeTimeout = Duration(seconds: 10);
const serviceProbeConcurrency = 4;

const _serviceSmallMaxBody = 16 * 1024;
const _serviceHtmlMaxBody = 512 * 1024;
const _serviceScanMaxBody = 8 * 1024 * 1024;

// The public browser client token Disney+ hands any web visitor; the device
// and token calls are rejected without it.
const _disneyAuthHeader =
    'Bearer ZGlzbmV5JmJyb3dzZXImMS4wLjA.Cu56AgSfBTDag5NiRA81oLHkDZfu5L3CKadnefEAY84';

enum ServiceTarget {
  google('google', 'Google', 'google'),
  github('github', 'GitHub', 'github'),
  youtube('youtube', 'YouTube', 'youtube'),
  chatgpt('chatgpt', 'ChatGPT', 'openai'),
  claude('claude', 'Claude', 'claude'),
  gemini('gemini', 'Gemini', 'gemini'),
  netflix('netflix', 'Netflix', 'netflix'),
  disneyPlus('disney-plus', 'Disney+', 'disneyplus'),
  primeVideo('prime-video', 'Prime Video', 'primevideo'),
  spotify('spotify', 'Spotify', 'spotify'),
  tiktok('tiktok', 'TikTok', 'tiktok'),
  bilibili('bilibili', 'bilibili', 'bilibili'),
  instagram('instagram', 'Instagram', 'instagram'),
  x('x', 'X', 'x'),
  discord('discord', 'Discord', 'discord'),
  twitch('twitch', 'Twitch', 'twitch'),
  steam('steam', 'Steam', 'steam');

  const ServiceTarget(this.id, this.label, this.icon);

  final String id;
  final String label;
  final String icon;

  static ServiceTarget? byId(String id) {
    for (final target in values) {
      if (target.id == id) return target;
    }
    return null;
  }
}

enum ServiceProbeStatus {
  available('available'),
  unavailable('unavailable'),
  restricted('restricted'),
  disallowedIsp('disallowed-isp'),
  blocked('blocked'),
  unsupportedRegion('unsupported-region'),
  originalsOnly('originals-only'),
  comingSoon('coming-soon'),
  timeout('timeout'),
  failed('failed');

  const ServiceProbeStatus(this.id);

  final String id;

  static ServiceProbeStatus byId(String id) {
    for (final status in values) {
      if (status.id == id) return status;
    }
    return ServiceProbeStatus.failed;
  }
}

// bilibili is China-only; every other region starts from the same set without
// it. Russia adds the RU-5 reachability probes below.
const _serviceWithoutBilibili = [
  ServiceTarget.google,
  ServiceTarget.github,
  ServiceTarget.youtube,
  ServiceTarget.chatgpt,
  ServiceTarget.claude,
  ServiceTarget.gemini,
  ServiceTarget.netflix,
  ServiceTarget.disneyPlus,
  ServiceTarget.primeVideo,
  ServiceTarget.spotify,
  ServiceTarget.tiktok,
];

const _serviceRussia = [
  ..._serviceWithoutBilibili,
  ServiceTarget.instagram,
  ServiceTarget.x,
  ServiceTarget.discord,
  ServiceTarget.twitch,
  ServiceTarget.steam,
];

const _regionalServiceTargets = RegionalDefaults<List<ServiceTarget>>({
  AppRegion.china: [
    ServiceTarget.google,
    ServiceTarget.github,
    ServiceTarget.youtube,
    ServiceTarget.chatgpt,
    ServiceTarget.claude,
    ServiceTarget.gemini,
    ServiceTarget.netflix,
    ServiceTarget.disneyPlus,
    ServiceTarget.primeVideo,
    ServiceTarget.spotify,
    ServiceTarget.tiktok,
    ServiceTarget.bilibili,
  ],
  AppRegion.russia: _serviceRussia,
  AppRegion.iran: _serviceWithoutBilibili,
  AppRegion.other: _serviceWithoutBilibili,
}, _serviceWithoutBilibili);

List<ServiceTarget> serviceTargetsForRegion(AppRegion region) =>
    _regionalServiceTargets.forRegion(region);

/// Applies the user's [order] on top of the region's [allowed] catalog: it
/// reorders and, together with a disabled filter, prunes — it never re-adds a
/// service the region does not ship.
List<ServiceTarget> orderServiceTargets(
  List<String> order,
  List<ServiceTarget> allowed,
) {
  final allowedSet = allowed.toSet();
  return {
    for (final id in order)
      if (ServiceTarget.byId(id) case final target?
          when allowedSet.contains(target))
        target,
    ...allowed,
  }.toList();
}

@immutable
class ServiceCheck {
  const ServiceCheck(this.status, {this.delay, this.region, this.checkedAt});

  final ServiceProbeStatus status;
  final int? delay;
  final String? region;
  final DateTime? checkedAt;

  @override
  bool operator ==(Object other) =>
      other is ServiceCheck &&
      other.status == status &&
      other.delay == delay &&
      other.region == region &&
      other.checkedAt == checkedAt;

  @override
  int get hashCode => Object.hash(status, delay, region, checkedAt);

  @override
  String toString() =>
      'ServiceCheck(${status.id}, delay: $delay, region: $region)';
}

/// Probes each [targets] entry (or every service when empty) through the local
/// mixed proxy, mirroring the transport [Request.checkIp] uses.
Future<Map<ServiceTarget, ServiceCheck>> checkServices(
  List<ServiceTarget> targets, {
  Duration timeout = serviceProbeTimeout,
  CancelToken? cancelToken,
}) async {
  final list = targets.isEmpty ? ServiceTarget.values.toList() : targets;
  final results = <ServiceTarget, ServiceCheck>{};
  final queue = List<ServiceTarget>.from(list);
  Future<void> worker() async {
    while (queue.isNotEmpty) {
      final target = queue.removeAt(0);
      results[target] = await _runCheck(target, timeout, cancelToken);
    }
  }

  final workers = queue.length < serviceProbeConcurrency
      ? queue.length
      : serviceProbeConcurrency;
  await Future.wait([for (var i = 0; i < workers; i++) worker()]);
  return results;
}

Future<ServiceCheck> _runCheck(
  ServiceTarget target,
  Duration timeout,
  CancelToken? cancelToken,
) async {
  final env = _ServiceEnv(timeout: timeout, cancelToken: cancelToken);
  try {
    final item = await _checkerFor(target)(env);
    return item.build();
  } catch (_) {
    return ServiceCheck(ServiceProbeStatus.failed, checkedAt: DateTime.now());
  }
}

Future<_Item> Function(_ServiceEnv) _checkerFor(ServiceTarget target) {
  return switch (target) {
    ServiceTarget.google => _reachable('https://www.google.com/generate_204'),
    ServiceTarget.github => _reachable('https://github.com/'),
    ServiceTarget.youtube => _checkYouTube,
    ServiceTarget.chatgpt => _checkChatGpt,
    ServiceTarget.claude => _checkClaude,
    ServiceTarget.gemini => _checkGemini,
    ServiceTarget.netflix => _checkNetflix,
    ServiceTarget.disneyPlus => _checkDisneyPlus,
    ServiceTarget.primeVideo => _checkPrimeVideo,
    ServiceTarget.spotify => _checkSpotify,
    ServiceTarget.tiktok => _checkTikTok,
    ServiceTarget.bilibili => _checkBilibili,
    ServiceTarget.instagram => _reachable('https://www.instagram.com/'),
    ServiceTarget.x => _reachable('https://x.com/'),
    ServiceTarget.discord => _reachable('https://discord.com/'),
    ServiceTarget.twitch => _reachable('https://www.twitch.tv/'),
    ServiceTarget.steam => _reachable('https://store.steampowered.com/'),
  };
}

class _Item {
  _Item({this.delay});

  ServiceProbeStatus? status;
  int? delay;
  String? region;

  ServiceCheck build() => ServiceCheck(
    status ?? ServiceProbeStatus.failed,
    delay: (delay ?? 0) > 0 ? delay : null,
    region: (region?.isEmpty ?? true) ? null : region,
    checkedAt: DateTime.now(),
  );
}

enum _ProbeError { timeout, failed }

@immutable
class _ProbeResult {
  const _ProbeResult({
    this.statusCode = 0,
    this.body = '',
    this.finalUrl = '',
    this.location,
    this.delay,
    this.error,
  });

  final int statusCode;
  final String body;
  final String finalUrl;
  final String? location;
  final int? delay;
  final _ProbeError? error;
}

class _ProbeRequest {
  const _ProbeRequest({
    required this.url,
    this.method = 'GET',
    this.headers,
    this.body,
    this.maxBody = _serviceSmallMaxBody,
    this.followRedirects = true,
    this.until,
  });

  final String url;
  final String method;
  final Map<String, String>? headers;
  final Object? body;
  final int maxBody;
  final bool followRedirects;
  final bool Function(String tail)? until;
}

class _ServiceEnv {
  _ServiceEnv({required this.timeout, this.cancelToken});

  final Duration timeout;
  final CancelToken? cancelToken;

  Future<_ProbeResult> get(String url, int maxBody) =>
      send(_ProbeRequest(url: url, maxBody: maxBody));

  Future<_ProbeResult> scan(String url, bool Function(String tail) until) =>
      send(_ProbeRequest(url: url, maxBody: _serviceScanMaxBody, until: until));

  Future<_ProbeResult> send(_ProbeRequest req) =>
      _send(req, timeout, cancelToken);
}

Future<_ProbeResult> _send(
  _ProbeRequest req,
  Duration timeout,
  CancelToken? parent,
) async {
  final token = CancelToken();
  if (parent != null) {
    unawaited(
      parent.whenCancel.then((error) {
        if (!token.isCancelled) token.cancel(error);
      }),
    );
  }
  final stopwatch = Stopwatch()..start();
  Future<_ProbeResult> attempt() async {
    final response = await request.dio.request<ResponseBody>(
      req.url,
      data: req.body,
      cancelToken: token,
      options: Options(
        method: req.method,
        responseType: ResponseType.stream,
        headers: req.headers,
        followRedirects: req.followRedirects,
        maxRedirects: req.followRedirects ? 5 : 0,
        validateStatus: (_) => true,
      ),
    );
    final delay = stopwatch.elapsedMilliseconds;
    final body = await _readBody(
      response.data,
      maxBody: req.maxBody,
      until: req.until,
    );
    return _ProbeResult(
      statusCode: response.statusCode ?? 0,
      body: body,
      finalUrl: response.realUri.toString(),
      location: response.headers.value('location'),
      delay: delay,
    );
  }

  try {
    return await attempt().timeout(
      timeout,
      onTimeout: () {
        token.cancel('timeout');
        throw TimeoutException('service probe timed out');
      },
    );
  } on TimeoutException {
    return const _ProbeResult(error: _ProbeError.timeout);
  } catch (_) {
    return const _ProbeResult(error: _ProbeError.failed);
  }
}

Future<String> _readBody(
  ResponseBody? data,
  {required int maxBody,
  bool Function(String tail)? until}) async {
  if (data == null) return '';
  if (maxBody <= 0) {
    await data.stream.listen(null, cancelOnError: true).cancel();
    return '';
  }
  if (until != null) {
    final buffer = StringBuffer();
    var received = 0;
    await for (final chunk in data.stream) {
      received += chunk.length;
      buffer.write(utf8.decode(chunk, allowMalformed: true));
      final tail = buffer.toString();
      if (until(tail) || received >= maxBody) return tail;
    }
    return buffer.toString();
  }
  final builder = BytesBuilder(copy: false);
  var received = 0;
  await for (final chunk in data.stream) {
    received += chunk.length;
    builder.add(chunk);
    if (received >= maxBody) break;
  }
  return utf8.decode(builder.takeBytes(), allowMalformed: true);
}

_Item _itemFrom(_ProbeResult result) {
  final item = _Item(delay: result.delay);
  switch (result.error) {
    case null:
      break;
    case _ProbeError.timeout:
      item.status = ServiceProbeStatus.timeout;
      item.delay = null;
    case _ProbeError.failed:
      item.status = ServiceProbeStatus.failed;
      item.delay = null;
  }
  return item;
}

bool _answered(_Item item) => item.status == null;

ServiceProbeStatus _statusFromCode(int code) {
  if (code >= 200 && code < 300) return ServiceProbeStatus.available;
  if (code == 401 || code == 403 || code == 429 || code == 451) {
    return ServiceProbeStatus.restricted;
  }
  return ServiceProbeStatus.unavailable;
}

bool _bodyContains(String body, List<String> needles) {
  final lower = body.toLowerCase();
  return needles.any(lower.contains);
}

String _firstSubmatch(RegExp pattern, String body) {
  final match = pattern.firstMatch(body);
  if (match == null || match.groupCount < 1) return '';
  return match.group(1) ?? '';
}

String _traceValue(String body, String key) {
  for (final line in body.split('\n')) {
    if (line.startsWith('$key=')) {
      return line.substring(key.length + 1).trim();
    }
  }
  return '';
}

final _youTubeRegionPatterns = <RegExp>[
  RegExp(
    r'''id=["']country-code["'][^>]*>\s*([A-Za-z]{2,3})\s*<''',
    caseSensitive: false,
  ),
  RegExp(r'"GL"\s*:\s*"([A-Za-z]{2})"'),
  RegExp(r'"countryCode"\s*:\s*"([A-Za-z]{2})"'),
  RegExp(r'"country_code"\s*:\s*"([A-Za-z]{2})"'),
];
final _tikTokRegionPattern = RegExp(r'"region"\s*:\s*"([a-zA-Z-]+)"');
final _primeRegionPattern = RegExp(r'"currentTerritory":"([^"]+)"');
final _disneyAssertionPattern = RegExp(r'"assertion"\s*:\s*"([^"]+)"');
final _disneyRefreshPattern = RegExp(r'"refresh_token"\s*:\s*"([^"]+)"');
final _disneyCountryPattern = RegExp(r'"countryCode"\s*:\s*"([^"]+)"');
final _disneySupportedPattern = RegExp(r'"inSupportedLocation"\s*:\s*(false|true)');
final _spotifyCountryPattern = RegExp(r'"countryCode"\s*:\s*"([^"]+)"');
const _geminiRegionMarker = ',2,1,200,"';
const _claudeBlockedRegions = [
  'AF', 'BY', 'CN', 'CU', 'HK', 'IR', 'KP', 'MO', 'RU', 'SY',
];
const _geminiBlockedRegions = [
  'CHN', 'RUS', 'BLR', 'CUB', 'IRN', 'PRK', 'SYR', 'HKG', 'MAC',
];

Future<_Item> Function(_ServiceEnv) _reachable(String url) {
  return (env) async {
    final result = await env.get(url, 0);
    final item = _itemFrom(result);
    if (!_answered(item)) return item;
    item.status = _statusFromCode(result.statusCode);
    return item;
  };
}

Future<_Item> _checkClaude(_ServiceEnv env) async {
  final result = await env.get(
    'https://claude.ai/cdn-cgi/trace',
    _serviceSmallMaxBody,
  );
  final item = _itemFrom(result);
  if (!_answered(item)) return item;
  final region = _normalizeRegion(_traceValue(result.body, 'loc'));
  if (region.isEmpty) {
    item.status = ServiceProbeStatus.failed;
    return item;
  }
  item.region = region;
  item.status = _claudeBlockedRegions.contains(region)
      ? ServiceProbeStatus.unsupportedRegion
      : ServiceProbeStatus.available;
  return item;
}

Future<_Item> _checkGemini(_ServiceEnv env) async {
  final result = await env.scan('https://gemini.google.com', (tail) {
    final index = tail.indexOf(_geminiRegionMarker);
    return index >= 0 && index + _geminiRegionMarker.length + 3 <= tail.length;
  });
  final item = _itemFrom(result);
  if (!_answered(item)) return item;
  final index = result.body.indexOf(_geminiRegionMarker);
  if (index < 0 ||
      index + _geminiRegionMarker.length + 3 > result.body.length) {
    item.status = ServiceProbeStatus.failed;
    return item;
  }
  final start = index + _geminiRegionMarker.length;
  final code = result.body.substring(start, start + 3);
  if (!_isAsciiUpper(code)) {
    item.status = ServiceProbeStatus.failed;
    return item;
  }
  item.region = _normalizeRegion(code);
  item.status = _geminiBlockedRegions.contains(code)
      ? ServiceProbeStatus.unsupportedRegion
      : ServiceProbeStatus.available;
  return item;
}

Future<_Item> _checkChatGpt(_ServiceEnv env) async {
  final ios = await env.get('https://ios.chat.openai.com/', _serviceSmallMaxBody);
  final item = _itemFrom(ios);
  if (_answered(item)) {
    item.status = _chatGptIosStatus(ios);
  }
  final trace = await env.get(
    'https://chat.openai.com/cdn-cgi/trace',
    _serviceSmallMaxBody,
  );
  if (_answered(_itemFrom(trace))) {
    item.region = _normalizeRegion(_traceValue(trace.body, 'loc'));
  }
  final web = await env.get(
    'https://api.openai.com/compliance/cookie_requirements',
    _serviceSmallMaxBody,
  );
  if (_answered(_itemFrom(web)) &&
      _bodyContains(web.body, ['unsupported_country'])) {
    item.status = ServiceProbeStatus.unsupportedRegion;
  }
  return item;
}

ServiceProbeStatus _chatGptIosStatus(_ProbeResult result) {
  if (_bodyContains(result.body, ['you may be connected to a disallowed isp'])) {
    return ServiceProbeStatus.disallowedIsp;
  }
  if (_bodyContains(result.body, ['sorry, you have been blocked'])) {
    return ServiceProbeStatus.blocked;
  }
  // Being turned away as an API client is what a reachable region looks like
  // here; anything else means the request never got that far.
  if (_bodyContains(result.body, [
    'request is not allowed. please try again later.',
  ])) {
    return ServiceProbeStatus.available;
  }
  return ServiceProbeStatus.failed;
}

Future<_Item> _checkYouTube(_ServiceEnv env) async {
  final result = await env.get(
    'https://www.youtube.com/premium?hl=en',
    _serviceHtmlMaxBody,
  );
  final item = _itemFrom(result);
  if (!_answered(item)) return item;
  for (final pattern in _youTubeRegionPatterns) {
    final code = _firstSubmatch(pattern, result.body);
    if (code.isNotEmpty) {
      item.region = _normalizeRegion(code);
      break;
    }
  }
  if (_bodyContains(result.body, [
    'youtube premium is not available in your country',
    'premium is not available in your country',
    'premium is not available in your region',
  ])) {
    item.status = ServiceProbeStatus.unsupportedRegion;
  } else if (result.statusCode >= 200 &&
      result.statusCode < 300 &&
      _bodyContains(result.body, [
        'youtube premium',
        'ad-free',
        '"browseid":"spunlimited"',
      ])) {
    item.status = ServiceProbeStatus.available;
  } else {
    item.status = _statusFromCode(result.statusCode);
  }
  return item;
}

Future<_Item> _checkSpotify(_ServiceEnv env) async {
  final result = await env.get(
    'https://www.spotify.com/api/content/v1/country-selector?platform=web&format=json',
    _serviceSmallMaxBody,
  );
  final item = _itemFrom(result);
  if (!_answered(item)) return item;
  item.region = _normalizeRegion(_spotifyRegion(result));
  if (result.statusCode == 403 || result.statusCode == 451) {
    item.status = ServiceProbeStatus.unsupportedRegion;
  } else if (result.statusCode < 200 || result.statusCode >= 300) {
    item.status = _statusFromCode(result.statusCode);
  } else if (_bodyContains(result.body, ['not available in your country'])) {
    item.status = ServiceProbeStatus.unsupportedRegion;
  } else {
    item.status = ServiceProbeStatus.available;
  }
  return item;
}

// Prefers the country Spotify redirected the request into, and falls back to
// the one named in the payload.
String _spotifyRegion(_ProbeResult result) {
  final finalUri = Uri.tryParse(result.finalUrl);
  if (finalUri != null) {
    final trimmed = finalUri.path.replaceAll(RegExp(r'^/+|/+$'), '');
    final segments = trimmed.split('/');
    final first = segments.isEmpty ? '' : segments.first;
    if (first.isNotEmpty && first != 'api') {
      return first.split('-').first;
    }
  }
  return _firstSubmatch(_spotifyCountryPattern, result.body);
}

Future<_Item> _checkTikTok(_ServiceEnv env) async {
  final result = await env.get(
    'https://www.tiktok.com/cdn-cgi/trace',
    _serviceSmallMaxBody,
  );
  final item = _itemFrom(result);
  if (_answered(item)) {
    item.status = _tikTokStatus(result);
    item.region = _normalizeRegion(_tikTokRegion(result.body));
  }
  if ((item.region?.isNotEmpty ?? false) &&
      item.status != ServiceProbeStatus.failed) {
    return item;
  }
  final fallback = await env.get('https://www.tiktok.com/', _serviceHtmlMaxBody);
  final fallbackItem = _itemFrom(fallback);
  if (!_answered(fallbackItem)) return item;
  if (item.status != ServiceProbeStatus.unsupportedRegion) {
    item.status = _tikTokStatus(fallback);
  }
  if (item.region?.isEmpty ?? true) {
    item.region = _normalizeRegion(_tikTokRegion(fallback.body));
  }
  if ((item.delay ?? 0) == 0) {
    item.delay = fallbackItem.delay;
  }
  return item;
}

ServiceProbeStatus _tikTokStatus(_ProbeResult result) {
  if (result.statusCode == 403 || result.statusCode == 451) {
    return ServiceProbeStatus.unsupportedRegion;
  }
  if (result.statusCode < 200 || result.statusCode >= 300) {
    return ServiceProbeStatus.failed;
  }
  if (_bodyContains(result.body, [
    'access denied',
    'not available in your region',
    'tiktok is not available',
  ])) {
    return ServiceProbeStatus.unsupportedRegion;
  }
  return ServiceProbeStatus.available;
}

String _tikTokRegion(String body) {
  final raw = _firstSubmatch(_tikTokRegionPattern, body);
  if (raw.isEmpty) return '';
  return raw.split('-').first;
}

Future<_Item> _checkBilibili(_ServiceEnv env) async {
  const url =
      'https://api.bilibili.com/pgc/player/web/playurl?avid=18281381&cid=29892777&qn=0&type=&otype=json&ep_id=183799&fourk=1&fnver=0&fnval=16&module=bangumi';
  final result = await env.get(url, _serviceSmallMaxBody);
  final item = _itemFrom(result);
  if (!_answered(item)) return item;
  final dynamic decoded;
  try {
    decoded = jsonDecode(result.body);
  } catch (_) {
    item.status = ServiceProbeStatus.failed;
    return item;
  }
  if (decoded is! Map<String, dynamic>) {
    item.status = ServiceProbeStatus.failed;
    return item;
  }
  final rawCode = decoded['code'];
  final code = rawCode is num ? rawCode.toInt() : 0;
  item.status = switch (code) {
    0 => ServiceProbeStatus.available,
    -10403 => ServiceProbeStatus.unsupportedRegion,
    _ => ServiceProbeStatus.failed,
  };
  return item;
}

Future<_Item> _checkPrimeVideo(_ServiceEnv env) async {
  final result = await env.scan('https://www.primevideo.com', (tail) {
    return tail.contains('isServiceRestricted') ||
        _primeRegionPattern.hasMatch(tail);
  });
  final item = _itemFrom(result);
  if (!_answered(item)) return item;
  if (result.body.contains('isServiceRestricted')) {
    item.status = ServiceProbeStatus.unsupportedRegion;
    return item;
  }
  final region = _firstSubmatch(_primeRegionPattern, result.body);
  if (region.isEmpty) {
    item.status = ServiceProbeStatus.failed;
    return item;
  }
  item.region = _normalizeRegion(region);
  item.status = ServiceProbeStatus.available;
  return item;
}

Future<_Item> _checkNetflix(_ServiceEnv env) async {
  final cdn = await _netflixFromCdn(env);
  if (cdn.status == ServiceProbeStatus.available ||
      cdn.status == ServiceProbeStatus.blocked) {
    return cdn;
  }
  final first = await env.get('https://www.netflix.com/title/81280792', 0);
  final firstItem = _itemFrom(first);
  if (!_answered(firstItem)) return firstItem;
  final second = await env.get('https://www.netflix.com/title/70143836', 0);
  final secondItem = _itemFrom(second);
  if (!_answered(secondItem)) return secondItem;
  final item = firstItem;
  if (first.statusCode == 404 && second.statusCode == 404) {
    item.status = ServiceProbeStatus.originalsOnly;
  } else if (first.statusCode == 403 || second.statusCode == 403) {
    item.status = ServiceProbeStatus.unsupportedRegion;
  } else if (_netflixServed(first.statusCode) ||
      _netflixServed(second.statusCode)) {
    item.status = ServiceProbeStatus.available;
    item.region = await _netflixRegion(env);
  } else {
    item.status = _statusFromCode(first.statusCode);
  }
  return item;
}

bool _netflixServed(int code) => code == 200 || code == 301;

// Reads the country out of the redirect Netflix would send a visitor to, so
// the redirect must not be followed.
Future<String> _netflixRegion(_ServiceEnv env) async {
  final result = await env.send(
    const _ProbeRequest(
      url: 'https://www.netflix.com/title/80018499',
      maxBody: 0,
      followRedirects: false,
    ),
  );
  final location = result.location;
  if (result.error != null || location == null) return '';
  final segments = location.split('/');
  if (segments.length < 4) return '';
  return _normalizeRegion(segments[3].split('-').first);
}

Future<_Item> _netflixFromCdn(_ServiceEnv env) async {
  const url =
      'https://api.fast.com/netflix/speedtest/v2?https=true&token=YXNkZmFzZGxmbnNkYWZoYXNkZmhrYWxm&urlCount=5';
  final result = await env.get(url, _serviceSmallMaxBody);
  final item = _itemFrom(result);
  if (!_answered(item)) return item;
  if (result.statusCode == 403) {
    item.status = ServiceProbeStatus.blocked;
    return item;
  }
  final dynamic decoded;
  try {
    decoded = jsonDecode(result.body);
  } catch (_) {
    item.status = ServiceProbeStatus.failed;
    return item;
  }
  final targets = decoded is Map<String, dynamic> ? decoded['targets'] : null;
  if (targets is! List || targets.isEmpty) {
    item.status = ServiceProbeStatus.failed;
    return item;
  }
  final firstTarget = targets.first;
  final location =
      firstTarget is Map<String, dynamic> ? firstTarget['location'] : null;
  final country = location is Map<String, dynamic> && location['country'] is String
      ? location['country'] as String
      : '';
  item.region = _normalizeRegion(country);
  item.status = ServiceProbeStatus.available;
  return item;
}

// Walks the browser hand-shake: register a device, exchange the assertion for
// a refresh token, then ask the session which region it landed in. Any step
// can answer on its own that the address is not welcome.
Future<_Item> _checkDisneyPlus(_ServiceEnv env) async {
  final device = await env.send(
    const _ProbeRequest(
      url: 'https://disney.api.edge.bamgrid.com/devices',
      method: 'POST',
      headers: {
        'authorization': _disneyAuthHeader,
        'content-type': 'application/json; charset=UTF-8',
      },
      body:
          '{"deviceFamily":"browser","applicationRuntime":"chrome","deviceProfile":"windows","attributes":{}}',
      maxBody: _serviceSmallMaxBody,
    ),
  );
  final item = _itemFrom(device);
  if (!_answered(item)) return item;
  if (device.statusCode == 403) {
    item.status = ServiceProbeStatus.blocked;
    return item;
  }
  final assertion = _firstSubmatch(_disneyAssertionPattern, device.body);
  if (assertion.isEmpty) {
    item.status = ServiceProbeStatus.failed;
    return item;
  }
  final form =
      'grant_type=urn:ietf:params:oauth:grant-type:token-exchange'
      '&latitude=0&longitude=0&platform=browser'
      '&subject_token=${Uri.encodeQueryComponent(assertion)}'
      '&subject_token_type=urn:bamtech:params:oauth:token-type:device';
  final token = await env.send(
    _ProbeRequest(
      url: 'https://disney.api.edge.bamgrid.com/token',
      method: 'POST',
      headers: const {
        'authorization': _disneyAuthHeader,
        'content-type': 'application/x-www-form-urlencoded',
      },
      body: form,
      maxBody: _serviceSmallMaxBody,
    ),
  );
  if (!_answered(_itemFrom(token))) return _itemFrom(token);
  if (token.body.contains('forbidden-location') ||
      token.body.contains('403 ERROR')) {
    item.status = ServiceProbeStatus.blocked;
    return item;
  }
  final refresh = _firstSubmatch(_disneyRefreshPattern, token.body);
  if (refresh.isEmpty) {
    item.status = ServiceProbeStatus.failed;
    return item;
  }
  final query =
      '{"query":"mutation refreshToken(\$input: RefreshTokenInput!) { refreshToken(refreshToken: \$input) { activeSession { sessionId } } }","variables":{"input":{"refreshToken":"$refresh"}}}';
  final session = await env.send(
    _ProbeRequest(
      url: 'https://disney.api.edge.bamgrid.com/graph/v1/device/graphql',
      method: 'POST',
      headers: const {
        'authorization': _disneyAuthHeader,
        'content-type': 'application/json',
      },
      body: query,
      maxBody: _serviceSmallMaxBody,
    ),
  );
  if (!_answered(_itemFrom(session)) ||
      session.body.isEmpty ||
      session.statusCode >= 400) {
    item.status = ServiceProbeStatus.failed;
    return item;
  }
  final region = _normalizeRegion(
    _firstSubmatch(_disneyCountryPattern, session.body),
  );
  if (region.isEmpty) {
    item.status = ServiceProbeStatus.unavailable;
    return item;
  }
  item.region = region;
  item.status = switch (_firstSubmatch(_disneySupportedPattern, session.body)) {
    'true' => ServiceProbeStatus.available,
    'false' => ServiceProbeStatus.comingSoon,
    _ => ServiceProbeStatus.failed,
  };
  return item;
}

// Five bytes per entry, alpha-3 then alpha-2, sorted by alpha-3.
const _iso3166Packed =
    'ABWAWAFGAFAGOAOAIAAIALAAXALBALANDADAREAEARGARARMAMASMASATAAQ'
    'ATFTFATGAGAUSAUAUTATAZEAZBDIBIBELBEBENBJBESBQBFABFBGDBDBGRBG'
    'BHRBHBHSBSBIHBABLMBLBLRBYBLZBZBMUBMBOLBOBRABRBRBBBBRNBNBTNBT'
    'BVTBVBWABWCAFCFCANCACCKCCCHECHCHLCLCHNCNCIVCICMRCMCODCDCOGCG'
    'COKCKCOLCOCOMKMCPVCVCRICRCUBCUCUWCWCXRCXCYMKYCYPCYCZECZDEUDE'
    'DJIDJDMADMDNKDKDOMDODZADZECUECEGYEGERIERESHEHESPESESTEEETHET'
    'FINFIFJIFJFLKFKFRAFRFROFOFSMFMGABGAGBRGBGEOGEGGYGGGHAGHGIBGI'
    'GINGNGLPGPGMBGMGNBGWGNQGQGRCGRGRDGDGRLGLGTMGTGUFGFGUMGUGUYGY'
    'HKGHKHMDHMHNDHNHRVHRHTIHTHUNHUIDNIDIMNIMINDINIOTIOIRLIEIRNIR'
    'IRQIQISLISISRILITAITJAMJMJEYJEJORJOJPNJPKAZKZKENKEKGZKGKHMKH'
    'KIRKIKNAKNKORKRKWTKWLAOLALBNLBLBRLRLBYLYLCALCLIELILKALKLSOLS'
    'LTULTLUXLULVALVMACMOMAFMFMARMAMCOMCMDAMDMDGMGMDVMVMEXMXMHLMH'
    'MKDMKMLIMLMLTMTMMRMMMNEMEMNGMNMNPMPMOZMZMRTMRMSRMSMTQMQMUSMU'
    'MWIMWMYSMYMYTYTNAMNANCLNCNERNENFKNFNGANGNICNINIUNUNLDNLNORNO'
    'NPLNPNRUNRNZLNZOMNOMPAKPKPANPAPCNPNPERPEPHLPHPLWPWPNGPGPOLPL'
    'PRIPRPRKKPPRTPTPRYPYPSEPSPYFPFQATQAREUREROURORUSRURWARWSAUSA'
    'SDNSDSENSNSGPSGSGSGSSHNSHSJMSJSLBSBSLESLSLVSVSMRSMSOMSOSPMPM'
    'SRBRSSSDSSSTPSTSURSRSVKSKSVNSISWESESWZSZSXMSXSYCSCSYRSYTCATC'
    'TCDTDTGOTGTHATHTJKTJTKLTKTKMTMTLSTLTONTOTTOTTTUNTNTURTRTUVTV'
    'TWNTWTZATZUGAUGUKRUAUMIUMURYUYUSAUSUZBUZVATVAVCTVCVENVEVGBVG'
    'VIRVIVNMVNVUTVUWLFWFWSMWSYEMYEZAFZAZMBZMZWEZW';

// Folds a country code to the alpha-2 form the card renders, or '' when it is
// not one. Only Gemini reports alpha-3.
String _normalizeRegion(String code) {
  code = code.trim().toUpperCase();
  switch (code.length) {
    case 2:
      return _isAsciiUpper(code) ? code : '';
    case 3:
      if (!_isAsciiUpper(code)) return '';
      var low = 0;
      var high = _iso3166Packed.length ~/ 5;
      while (low < high) {
        final mid = (low + high) ~/ 2;
        final entry = _iso3166Packed.substring(mid * 5, mid * 5 + 3);
        final order = entry.compareTo(code);
        if (order < 0) {
          low = mid + 1;
        } else if (order > 0) {
          high = mid;
        } else {
          return _iso3166Packed.substring(mid * 5 + 3, mid * 5 + 5);
        }
      }
      return '';
    default:
      return '';
  }
}

bool _isAsciiUpper(String value) {
  for (final unit in value.codeUnits) {
    if (unit < 0x41 || unit > 0x5A) return false;
  }
  return true;
}
