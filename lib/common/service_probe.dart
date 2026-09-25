import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:reclash/common/regional/regional.dart';
import 'package:reclash/core/controller.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';

const serviceProbeTimeout = Duration(seconds: 10);

/// [directOutbound] forces the direct dialer; [routedOutbound] (empty) lets the tunnel rules pick the egress.
const directOutbound = 'DIRECT';
const routedOutbound = '';

const outboundIpTimeoutDuration = Duration(seconds: 6);

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
  steam('steam', 'Steam', 'steam'),
  telegram('telegram', 'Telegram', 'telegram'),
  whatsapp('whatsapp', 'WhatsApp', 'whatsapp'),
  yandex('yandex', 'Yandex', 'yandex');

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
  ServiceTarget.telegram,
  ServiceTarget.whatsapp,
  ServiceTarget.yandex,
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
  const ServiceCheck(
    this.status, {
    this.delay,
    this.region,
    this.checkedAt,
    this.chains = const [],
    this.coreEpoch = 0,
    this.picksVersion = 0,
  });

  factory ServiceCheck.of(ServiceCheckItem item) {
    return ServiceCheck(
      ServiceProbeStatus.byId(item.status),
      delay: item.delay > 0 ? item.delay : null,
      // The Core already folds the region to the alpha-2 the card renders.
      region: item.region.isEmpty ? null : item.region,
      checkedAt: item.checkedAt > 0
          ? DateTime.fromMillisecondsSinceEpoch(item.checkedAt)
          : null,
      chains: item.chains,
      coreEpoch: item.coreEpoch,
      picksVersion: item.picksVersion,
    );
  }

  final ServiceProbeStatus status;
  final int? delay;
  final String? region;
  final DateTime? checkedAt;
  final List<String> chains;
  final int coreEpoch;
  final int picksVersion;

  /// The egress the Core dialed for this probe — the head of the proxy chain.
  String? get node => chains.isEmpty ? null : chains.first;

  @override
  bool operator ==(Object other) =>
      other is ServiceCheck &&
      other.status == status &&
      other.delay == delay &&
      other.region == region &&
      other.checkedAt == checkedAt &&
      other.coreEpoch == coreEpoch &&
      other.picksVersion == picksVersion &&
      const ListEquality<String>().equals(other.chains, chains);

  @override
  int get hashCode => Object.hash(
    status,
    delay,
    region,
    checkedAt,
    coreEpoch,
    picksVersion,
    Object.hashAll(chains),
  );

  @override
  String toString() =>
      'ServiceCheck(${status.id}, delay: $delay, region: $region, node: $node)';
}

/// Runs the Core's service sweep; it owns concurrency and retries, so Dart only maps each item back to its target.
Future<Map<ServiceTarget, ServiceCheck>> checkServices(
  CoreController core, {
  String proxyName = '',
  List<ServiceTarget> targets = const [],
  Duration timeout = serviceProbeTimeout,
}) async {
  final list = targets.isEmpty ? ServiceTarget.values.toList() : targets;
  final items = await core.serviceCheck(
    ServiceCheckParams(
      proxyName: proxyName,
      names: list.map((target) => target.id).toList(),
      timeout: timeout.inMilliseconds,
    ),
  );
  final results = <ServiceTarget, ServiceCheck>{};
  for (final item in items) {
    if (ServiceTarget.byId(item.name) case final target?) {
      results[target] = ServiceCheck.of(item);
    }
  }
  return results;
}

IpInfo Function(String) _jsonIpInfo(IpInfo Function(Map<String, dynamic>) parse) {
  return (body) => parse(jsonDecode(body) as Map<String, dynamic>);
}

final Map<String, IpInfo Function(String)> outboundIpSources = {
  'https://ipwho.is': _jsonIpInfo(IpInfo.fromIpWhoIsJson),
  'https://api.myip.com': _jsonIpInfo(IpInfo.fromMyIpJson),
  'https://ipapi.co/json': _jsonIpInfo(IpInfo.fromIpApiCoJson),
  'https://ident.me/json': _jsonIpInfo(IpInfo.fromIdentMeJson),
  'https://api.ip.sb/geoip': _jsonIpInfo(IpInfo.fromIpSbJson),
  'https://ipinfo.io/json': _jsonIpInfo(IpInfo.fromIpInfoIoJson),
};

/// Raw so the route stamp survives; [parseOutboundIp] reads the address.
Future<OutboundIpResult?> lookupOutboundIp(
  CoreController core,
  String proxyName, {
  Duration timeout = outboundIpTimeoutDuration,
}) {
  return core.outboundIp(
    OutboundIpParams(
      proxyName: proxyName,
      urls: outboundIpSources.keys.toList(),
      timeout: timeout.inMilliseconds,
    ),
  );
}

IpInfo? parseOutboundIp(OutboundIpResult? result) {
  if (result == null || result.error != null || result.body.isEmpty) {
    return null;
  }
  final parse = outboundIpSources[result.url];
  if (parse == null) {
    return null;
  }
  try {
    return parse(result.body);
  } on FormatException {
    return null;
  } on TypeError {
    return null;
  }
}
