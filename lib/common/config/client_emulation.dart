/// Per-profile compatibility preset for panels that vary by User-Agent.
library;

import 'package:reclash/common/app/device_identity.dart';
import 'package:reclash/enum/enum.dart';

// "Happ/1.0" would look like a scraper; Karing is the sing-box client
// actually served sing-box JSON.
const legacyClashUserAgent = 'ClashForAndroid/2.5.12';
const metaClashUserAgent = 'ClashMetaForAndroid/2.11.7.Meta';
const _happUa = 'Happ/3.26.1';
const _incyVersion = '3.3.1';
const _v2rayngUa = 'v2rayNG/1.9.24';
const _singboxUa = 'Karing/1.0.0';

bool isNativeSubscriptionClient(SubscriptionClient client) => switch (client) {
  SubscriptionClient.auto ||
  SubscriptionClient.clashMeta ||
  SubscriptionClient.clash => true,
  SubscriptionClient.happ ||
  SubscriptionClient.incy ||
  SubscriptionClient.singbox ||
  SubscriptionClient.v2rayng ||
  SubscriptionClient.custom => false,
};

List<SubscriptionClient> probeOrder(
  SubscriptionClient client, {
  SubscriptionClient? lastWorking,
}) {
  if (client != SubscriptionClient.auto) return [client];
  final order = <SubscriptionClient>[
    ?lastWorking,
    SubscriptionClient.clashMeta,
    SubscriptionClient.clash,
    SubscriptionClient.happ,
    SubscriptionClient.incy,
    SubscriptionClient.singbox,
    SubscriptionClient.v2rayng,
  ];
  return order.toSet().toList();
}

bool hasDeviceIdentityHeaders(Map<String, String>? headers) {
  return headers?.containsKey('x-hwid') == true;
}

Map<String, String> buildSubscriptionHeaders(
  SubscriptionClient client, {
  required DeviceIdentityInfo deviceDetails,
  String? defaultUa,
  String? identityUserAgent,
  String? customUserAgent,
  bool sendDeviceHeaders = false,
  String? locale,
}) {
  final headers = <String, String>{};

  switch (client) {
    case SubscriptionClient.auto:
      headers['User-Agent'] = identityUserAgent ?? defaultUa ?? '';
    case SubscriptionClient.clashMeta:
      headers['User-Agent'] = metaClashUserAgent;
    case SubscriptionClient.clash:
      headers['User-Agent'] = legacyClashUserAgent;
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
      headers['User-Agent'] = customUserAgent?.isNotEmpty == true
          ? customUserAgent!
          : defaultUa ?? '';
  }

  headers.removeWhere((_, value) => value.isEmpty);
  return sendDeviceHeaders
      ? withDeviceIdentityHeaders(headers, deviceDetails)
      : headers;
}

Map<String, String> withDeviceIdentityHeaders(
  Map<String, String> headers,
  DeviceIdentityInfo deviceDetails,
) {
  return {
    ...headers,
    'x-hwid': deviceDetails.hwid,
    'x-device-os': deviceDetails.os,
    'x-ver-os': deviceDetails.osVersion,
    'x-device-model': deviceDetails.model,
  }..removeWhere((_, value) => value.isEmpty);
}
