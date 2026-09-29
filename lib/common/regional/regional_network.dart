import 'package:reclash/common/regional/country_profile.dart';
import 'package:reclash/common/util/constant.dart';
import 'package:reclash/models/models.dart';

Dns dnsForRegion(String? code) => dnsForCode(code);

bool isShippedDns(Dns dns) => isShippedDnsValue(dns);

List<String> bypassForRegion(String? code) => bypassForCode(code);

bool isShippedBypass(List<String> domains) => isShippedBypassValue(domains);

String systemDnsFallbackForRegion(String? code) {
  final servers = dnsForRegion(code).defaultNameserver;
  return servers.isEmpty ? defaultSystemDnsFallback : servers.first;
}
