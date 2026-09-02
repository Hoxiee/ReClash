/// Per-profile client emulation: panels serve the body by User-Agent.
library;

import 'package:reclash/common/device_identity.dart';
import 'package:reclash/enum/enum.dart';

// "Happ/1.0" would look like a scraper; Karing is the sing-box client
// actually served sing-box JSON.
const _happUa = 'Happ/3.26.1';
const _incyVersion = '3.3.1';
const _v2rayngUa = 'v2rayNG/1.9.24';
const _singboxUa = 'Karing/1.0.0';

List<SubscriptionClient> probeOrder(SubscriptionClient client, {
  SubscriptionClient? lastWorking,
}) {
  if (client != SubscriptionClient.auto) return [client];
  final order = <SubscriptionClient>[
    ?lastWorking,
    SubscriptionClient.clash,
    SubscriptionClient.happ,
    SubscriptionClient.incy,
    SubscriptionClient.singbox,
  ];
  return order.toSet().toList();
}

Map<String, String> buildSubscriptionHeaders(
  SubscriptionClient client, {
  required DeviceIdentityInfo deviceDetails,
  String? defaultUa,
  String? identityUserAgent,
  String? customUserAgent,
  bool sendDeviceHeaders = true,
  String? locale,
}) {
  final headers = <String, String>{};

  switch (client) {
    case SubscriptionClient.clash:
    case SubscriptionClient.auto:
      headers['User-Agent'] = identityUserAgent ?? defaultUa ?? '';
    case SubscriptionClient.happ:
      headers['User-Agent'] = _happUa;
    case SubscriptionClient.incy:
      headers['User-Agent'] = 'INCY/$_incyVersion/${deviceDetails.os}';
      headers['x-client'] = 'INCY';
      headers['x-app-version'] = _incyVersion;
      if (locale != null && locale.isNotEmpty) {
        headers['x-device-locale'] = locale;
        headers['Accept-Language'] = locale;
      }
    case SubscriptionClient.singbox:
      headers['User-Agent'] = _singboxUa;
    case SubscriptionClient.v2rayng:
      headers['User-Agent'] = _v2rayngUa;
    case SubscriptionClient.custom:
      headers['User-Agent'] =
          customUserAgent?.isNotEmpty == true ? customUserAgent! : defaultUa ?? '';
  }

  if (sendDeviceHeaders) {
    headers['x-hwid'] = deviceDetails.hwid;
    headers['x-device-os'] = deviceDetails.os;
    headers['x-ver-os'] = deviceDetails.osVersion;
    headers['x-device-model'] = deviceDetails.model;
  }

  headers.removeWhere((_, value) => value.isEmpty);
  return headers;
}
