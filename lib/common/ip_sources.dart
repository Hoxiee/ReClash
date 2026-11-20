import 'package:reclash/common/regional/country_profile.dart';
import 'package:reclash/enum/enum.dart';

/// A service that tells the outbound address, rates it, or both.
enum IpSource {
  cloudflare(
    'cloudflare.com',
    echoUrl: 'https://www.cloudflare.com/cdn-cgi/trace',
  ),
  ipSb('ip.sb', echoUrl: 'https://api.ip.sb/geoip'),
  ipInfo('ipinfo.io', echoUrl: 'https://ipinfo.io/json'),
  ipWhoIs('ipwho.is', echoUrl: 'https://ipwho.is'),
  geoJs('geojs.io', echoUrl: 'https://get.geojs.io/v1/ip/geo.json'),
  countryIs('country.is', echoUrl: 'https://api.country.is'),
  ipQuery(
    'ipquery.io',
    echoUrl: 'https://api.ipquery.io/?format=json',
    quality: IpQualitySource.ipQuery,
  ),
  identMe(
    'ident.me',
    echoUrl: 'https://ident.me/json',
    quality: IpQualitySource.identMe,
  ),
  // ip-api.com serves HTTPS only on its paid plan.
  ipApiCom(
    'ip-api.com',
    echoUrl: 'http://ip-api.com/json?fields=status,countryCode,query',
    quality: IpQualitySource.ipApiCom,
  ),
  seeIp('seeip.org', echoUrl: 'https://api.seeip.org/geoip'),
  ipLocate('iplocate.io', quality: IpQualitySource.ipLocate),
  ipApiIs('ipapi.is', quality: IpQualitySource.ipApiIs),
  proxyCheck('proxycheck.io', quality: IpQualitySource.proxyCheck);

  const IpSource(this.label, {this.echoUrl, this.quality});

  final String label;
  final String? echoUrl;
  final IpQualitySource? quality;

  static IpSource? byId(String id) => values.asNameMap()[id];

  static IpSource? byEchoUrl(String url) {
    for (final source in values) {
      if (source.echoUrl == url) return source;
    }
    return null;
  }
}

List<IpSource> orderIpSources(List<String> order) {
  return {
    for (final id in order) ?IpSource.byId(id),
    ...IpSource.values,
  }.toList();
}

List<IpSource> defaultIpSourcesForRegion(String? regionCode) {
  final ids = sanitizeRegionCode(regionCode) == null
      ? null
      : profileForCode(regionCode).ipSourceIds;
  return ids == null
      ? IpSource.values
      : [for (final id in ids) ?IpSource.byId(id)];
}

List<IpSource> enabledIpSourcesForRegion({
  required String? regionCode,
  required List<String> order,
  required Set<String> enabled,
  required Set<String> disabled,
}) {
  final defaults = defaultIpSourcesForRegion(regionCode).toSet();
  return [
    for (final source in orderIpSources(order))
      if (!disabled.contains(source.name) &&
          (enabled.contains(source.name) || defaults.contains(source)))
        source,
  ];
}

/// Whether switching [source] off would leave no source for the address or
/// none for its quality.
bool isLastIpSourceOfKind(IpSource source, List<IpSource> enabled) {
  bool alone(bool Function(IpSource) has) =>
      has(source) && enabled.where(has).length == 1;
  return alone((it) => it.echoUrl != null) || alone((it) => it.quality != null);
}
