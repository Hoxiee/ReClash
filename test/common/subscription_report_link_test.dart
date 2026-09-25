import 'dart:convert';
import 'dart:io';

import 'package:reclash/common/common.dart';
import 'package:reclash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

// Mirror of the site fixture gen/report_demo.py: the exact JSON the decoder's
// report.js reads. Keeping it here pins app toJson() to the decoder contract.
const _demo = {
  'verdict': {
    'headline': '',
    'fault': 'server',
    'health': 'degraded',
    'causeCode': 'egress_unreachable',
    'layer': 'transport',
    'terrain': 'ru-home',
    'env': 'cellular',
  },
  'schemaVersion': 1,
  'generatedAt': 1758758400000,
  'coreVersion': 'mihomo 1.19.15',
  'appVersion': 'ReClash 1.7.0',
  'platform': 'android',
  'architecture': 'arm64',
  'windowStart': 1758754800000,
  'windowEnd': 1758758400000,
  'terrain': 'ru-home',
  'env': 'cellular',
  'presets': ['route=auto', 'desync=off'],
  'droppedEvents': 0,
  'configNodeCount': 24,
  'observedNodeCount': 18,
  'subscriptionUpdate': {
    'attempted': true,
    'succeeded': false,
    'generatedAt': 1758758400000,
    'hostCount': 2,
    'attempts': 6,
    'failures': 5,
    'hwidRejected': false,
    'emptyResponse': false,
    'undialable': true,
    'dominantError': 'timeout',
    'byStage': [
      {'stage': 'fetch', 'attempts': 4, 'failures': 4, 'dominantError': 'timeout'},
      {'stage': 'parse', 'attempts': 2, 'failures': 1, 'dominantError': 'empty'},
    ],
    'hosts': [
      {'host': 'host-01', 'attempts': 4, 'failures': 4, 'succeeded': false, 'lastError': 'timeout'},
      {'host': 'host-02', 'attempts': 2, 'failures': 1, 'succeeded': true, 'lastError': ''},
    ],
  },
  'runtimeDial': {
    'attempts': 210,
    'success': 61,
    'failure': 149,
    'byTransport': [
      {'key': 'tcp', 'attempts': 150, 'failure': 120},
      {'key': 'ws', 'attempts': 60, 'failure': 29},
    ],
    'byStage': [
      {'key': 'connect', 'attempts': 210, 'failure': 132},
      {'key': 'handshake', 'attempts': 78, 'failure': 17},
    ],
    'byErrorClass': [
      {'class': 'timeout', 'count': 96},
      {'class': 'reset', 'count': 41},
      {'class': 'refused', 'count': 12},
    ],
    'byProtocol': [
      {'key': 'vless', 'attempts': 130, 'failure': 101},
      {'key': 'trojan', 'attempts': 80, 'failure': 48},
    ],
    'byGroup': [
      {'group': 'Netherlands', 'attempts': 120, 'failure': 98},
      {'group': 'Germany', 'attempts': 90, 'failure': 51},
    ],
    'byEgress': [
      {'key': 'NL', 'attempts': 120, 'failure': 98},
      {'key': 'DE', 'attempts': 90, 'failure': 51},
    ],
  },
  'nodes': [
    {'alias': 'node-01', 'protocol': 'vless', 'transport': 'tcp', 'egressCountry': 'NL', 'groups': ['Netherlands', 'Premium'], 'positionHint': 2, 'attempts': 60, 'failures': 58, 'successes': 2, 'failStreak': 21, 'dominantClass': 'timeout', 'delayBucketMs': 2000},
    {'alias': 'node-02', 'protocol': 'vless', 'transport': 'ws', 'egressCountry': 'NL', 'groups': ['Netherlands'], 'positionHint': 4, 'attempts': 45, 'failures': 40, 'successes': 5, 'failStreak': 9, 'dominantClass': 'reset', 'delayBucketMs': 1000},
    {'alias': 'node-03', 'protocol': 'trojan', 'transport': 'tcp', 'egressCountry': 'DE', 'groups': ['Germany'], 'positionHint': 1, 'attempts': 50, 'failures': 31, 'successes': 19, 'failStreak': 4, 'dominantClass': 'refused', 'delayBucketMs': 500},
  ],
};

Map<String, Object?> _decodeBlob(String blob) {
  final parts = blob.split('.');
  expect(parts.first, 'R1');
  var b64 = parts[1];
  b64 += '=' * ((4 - b64.length % 4) % 4);
  final bytes = base64Url.decode(b64);
  return jsonDecode(utf8.decode(gzip.decode(bytes))) as Map<String, Object?>;
}

void main() {
  test('app toJson matches the site decoder fixture field for field', () {
    final encoded = jsonDecode(
      jsonEncode(SubscriptionReport.fromJson(_demo).toJson()),
    );
    expect(encoded, _demo);
  });

  test('R1 envelope round-trips through the decoder algorithm', () {
    final report = SubscriptionReport.fromJson(_demo);
    final blob = encodeSubscriptionReportBlob(report);
    expect(blob, startsWith('R1.'));
    expect(_decodeBlob(blob), _demo);
  });

  test('decoder URL targets the official ru/en report page', () {
    const blob = 'R1.test';
    expect(
      subscriptionReportDecoderUrl(blob, lang: 'ru'),
      'https://hoxiee.github.io/ReClash-site/ru/report.html#d=R1.test',
    );
    expect(
      subscriptionReportDecoderUrl(blob, lang: 'de'),
      'https://hoxiee.github.io/ReClash-site/en/report.html#d=R1.test',
    );
  });
}