import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:reclash/common/regional/regional.dart';
import 'package:reclash/core/controller.dart';
import 'package:reclash/models/models.dart';

const serviceProbeTimeout = Duration(seconds: 10);

/// [directOutbound] forces the direct dialer; [routedOutbound] (empty) lets the tunnel rules pick the egress.
const directOutbound = 'DIRECT';
const routedOutbound = '';

const outboundIpTimeoutDuration = Duration(seconds: 6);

/// Groups the catalog in the manage sheet. The declaration order is the order
/// the sections render in; [ServiceTarget.values] is kept in the same grouping
/// so the catalog reads category by category without a separate sort key.
enum ServiceCategory {
  core('core'),
  messengers('messengers'),
  ai('ai'),
  streaming('streaming'),
  social('social'),
  gaming('gaming');

  const ServiceCategory(this.id);

  final String id;
}

enum ServiceTarget {
  google('google', 'Google', 'google', ServiceCategory.core),
  github('github', 'GitHub', 'github', ServiceCategory.core),
  yandex('yandex', 'Yandex', 'yandex', ServiceCategory.core),
  telegram('telegram', 'Telegram', 'telegram', ServiceCategory.messengers),
  whatsapp('whatsapp', 'WhatsApp', 'whatsapp', ServiceCategory.messengers),
  discord('discord', 'Discord', 'discord', ServiceCategory.messengers),
  chatgpt('chatgpt', 'ChatGPT', 'openai', ServiceCategory.ai),
  claude('claude', 'Claude', 'claude', ServiceCategory.ai),
  gemini('gemini', 'Gemini', 'gemini', ServiceCategory.ai),
  youtube('youtube', 'YouTube', 'youtube', ServiceCategory.streaming),
  netflix('netflix', 'Netflix', 'netflix', ServiceCategory.streaming),
  disneyPlus('disney-plus', 'Disney+', 'disneyplus', ServiceCategory.streaming),
  primeVideo(
    'prime-video',
    'Prime Video',
    'primevideo',
    ServiceCategory.streaming,
  ),
  spotify('spotify', 'Spotify', 'spotify', ServiceCategory.streaming),
  twitch('twitch', 'Twitch', 'twitch', ServiceCategory.streaming),
  bilibili('bilibili', 'bilibili', 'bilibili', ServiceCategory.streaming),
  instagram('instagram', 'Instagram', 'instagram', ServiceCategory.social),
  x('x', 'X', 'x', ServiceCategory.social),
  tiktok('tiktok', 'TikTok', 'tiktok', ServiceCategory.social),
  steam('steam', 'Steam', 'steam', ServiceCategory.gaming);

  const ServiceTarget(this.id, this.label, this.icon, this.category);

  final String id;
  final String label;
  final String icon;
  final ServiceCategory category;

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

// The catalog is region-independent: every region can enable every service in
// the manage sheet. A region only decides which services are checked out of the
// box, below. Picks lean on what the region actually tends to restrict, so the
// card answers "does my connection reach what I came for" without noise.
const _defaultServicesRussia = [
  ServiceTarget.telegram,
  ServiceTarget.youtube,
  ServiceTarget.instagram,
  ServiceTarget.discord,
  ServiceTarget.chatgpt,
  ServiceTarget.claude,
  ServiceTarget.x,
];

const _defaultServicesIran = [
  ServiceTarget.telegram,
  ServiceTarget.instagram,
  ServiceTarget.whatsapp,
  ServiceTarget.youtube,
  ServiceTarget.chatgpt,
  ServiceTarget.claude,
];

const _defaultServicesChina = [
  ServiceTarget.google,
  ServiceTarget.youtube,
  ServiceTarget.chatgpt,
  ServiceTarget.claude,
  ServiceTarget.telegram,
  ServiceTarget.bilibili,
];

const _defaultServicesEgypt = [
  ServiceTarget.google,
  ServiceTarget.youtube,
  ServiceTarget.chatgpt,
  ServiceTarget.claude,
  ServiceTarget.whatsapp,
];

const _defaultServicesOther = [
  ServiceTarget.google,
  ServiceTarget.youtube,
  ServiceTarget.chatgpt,
  ServiceTarget.claude,
  ServiceTarget.netflix,
];

const _regionalDefaultServices = RegionalDefaults<List<ServiceTarget>>({
  'RU': _defaultServicesRussia,
  'IR': _defaultServicesIran,
  'CN': _defaultServicesChina,
  'EG': _defaultServicesEgypt,
}, _defaultServicesOther);

/// The services a region checks before the user touches the manage sheet.
List<ServiceTarget> defaultServicesForRegion(String? code) =>
    _regionalDefaultServices.forRegion(code);

/// The whole catalog grouped by [ServiceCategory] (section order), with the
/// user's [order] deciding the sequence inside each group; services the order
/// does not mention keep their catalog position. The result stays category by
/// category so the manage sheet and the card's reel read the same way.
List<ServiceTarget> catalogInUserOrder(List<String> order) {
  final rank = <String, int>{
    for (final (index, id) in order.indexed) id: index,
  };
  final targets = [...ServiceTarget.values];
  targets.sort((a, b) {
    final byCategory = a.category.index.compareTo(b.category.index);
    if (byCategory != 0) return byCategory;
    final ra = rank[a.id] ?? order.length + a.index;
    final rb = rank[b.id] ?? order.length + b.index;
    return ra.compareTo(rb);
  });
  return targets;
}

/// The services checked right now: the region's defaults minus the ones the
/// user switched off ([disabled]), plus any non-default the user switched on
/// ([enabled]). Returned in catalog (category/user) order.
List<ServiceTarget> enabledServiceTargets({
  required List<String> order,
  required List<ServiceTarget> defaults,
  required Set<String> disabled,
  required Set<String> enabled,
}) {
  final defaultSet = defaults.toSet();
  bool isOn(ServiceTarget target) => defaultSet.contains(target)
      ? !disabled.contains(target.id)
      : enabled.contains(target.id);
  return [
    for (final target in catalogInUserOrder(order))
      if (isOn(target)) target,
  ];
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

IpInfo Function(String) _jsonIpInfo(
  IpInfo Function(Map<String, dynamic>) parse,
) {
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
