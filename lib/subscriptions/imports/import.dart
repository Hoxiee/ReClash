import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:yaml/yaml.dart';

import '../metadata/metadata.dart';

import 'config/amnezia_config.dart';
import 'config/singbox_config.dart';
import 'config/xray_config.dart';
import 'routing/skipped_node.dart';
import 'subscription/subscription_links.dart';

const maxSubscriptionImportBytes = 16 * 1024 * 1024;
const maxSubscriptionImportDecompressedBytes = 32 * 1024 * 1024;
const maxSubscriptionImportNodes = 20000;

enum SubscriptionFormat {
  clash,
  shareLinks,
  xray,
  singbox,
  wireguard,
  amnezia,
  encrypted,
  unknown,
}

class SubscriptionImportSummary {
  const SubscriptionImportSummary({
    this.nodes = 0,
    this.groups = 0,
    this.remoteProviders = 0,
    this.skipped = const [],
    this.undialable = const [],
    this.skippedNodes = const [],
    this.ignoredSections = const [],
    this.hasLosses = false,
    this.hasOtherLosses = false,
    this.rejectCoreFallback = false,
    this.excludedPackages = const [],
    this.includedPackages = const [],
  });

  final int nodes;
  final int groups;
  final int remoteProviders;
  final List<String> skipped;
  final List<String> undialable;
  final List<SkippedNode> skippedNodes;
  final List<String> ignoredSections;
  final bool hasLosses;
  final bool hasOtherLosses;
  final bool rejectCoreFallback;

  /// The Clash config's `tun.exclude-package` and `tun.include-package`.
  final List<String> excludedPackages;
  final List<String> includedPackages;
}

class SubscriptionImportResult {
  const SubscriptionImportResult({
    required this.bytes,
    required this.format,
    required this.summary,
  });

  final Uint8List bytes;
  final SubscriptionFormat format;
  final SubscriptionImportSummary summary;
}

class SubscriptionImportException implements Exception {
  const SubscriptionImportException(this.message);
  final String message;

  @override
  String toString() => message;
}

Future<SubscriptionImportResult> prepareSubscriptionImport(
  Uint8List bytes, {
  bool encrypted = false,
}) => compute(_convertSubscriptionImport, (bytes, encrypted));

SubscriptionImportResult convertSubscriptionImport(
  Uint8List bytes, {
  bool encrypted = false,
}) => _convert(bytes, encrypted: encrypted);

SubscriptionImportResult _convertSubscriptionImport((Uint8List, bool) input) =>
    _convert(input.$1, encrypted: input.$2);

SubscriptionImportResult _convert(Uint8List input, {required bool encrypted}) {
  if (input.length > maxSubscriptionImportBytes) {
    throw const SubscriptionImportException('Import exceeds byte limit');
  }
  if (encrypted) return _passthrough(input, SubscriptionFormat.encrypted);

  final content = utf8.decode(input, allowMalformed: true).trim();
  if (content.isEmpty) return _passthrough(input, SubscriptionFormat.unknown);
  final json = _decodeJson(content);
  if (content.startsWith('{') && json == null) {
    return _passthrough(input, SubscriptionFormat.unknown);
  }
  try {
    final yaml =
        json == null &&
            _looksLikeYaml(content) &&
            !isWireguardConfInput(content) &&
            !isShareLinkInput(content)
        ? loadYaml(content)
        : null;
    final value = json ?? yaml;
    if (value != null) _checkValueLimits(value);
    final format = _detectFormat(content, json, yaml);
    if (format == SubscriptionFormat.unknown) {
      final rejectCoreFallback =
          json is Map &&
          (json.containsKey('outbounds') || json.containsKey('outbound'));
      return _passthrough(
        input,
        format,
        rejectCoreFallback: rejectCoreFallback,
      );
    }
    if (format == SubscriptionFormat.clash) {
      return SubscriptionImportResult(
        bytes: Uint8List.fromList(input),
        format: format,
        summary: _clashSummary(yaml),
      );
    }

    final converted = switch (format) {
      SubscriptionFormat.shareLinks ||
      SubscriptionFormat.amnezia => tryConvertShareLinks(content),
      SubscriptionFormat.xray => tryConvertXrayConfigValue(json),
      SubscriptionFormat.singbox => tryConvertSingboxConfigValue(json),
      SubscriptionFormat.wireguard => tryConvertWireguardConf(content),
      _ => null,
    };
    if (converted == null) {
      final skipped =
          format == SubscriptionFormat.shareLinks ||
              format == SubscriptionFormat.amnezia
          ? probeUnsupportedShareLinks(content)
          : const <SkippedNode>[];
      if (skipped.isNotEmpty) {
        return SubscriptionImportResult(
          bytes: Uint8List.fromList(input),
          format: format,
          summary: _lossSummary(skipped, const []),
        );
      }
      throw const SubscriptionImportException('Recognized import is invalid');
    }

    final output = Uint8List.fromList(utf8.encode(converted.config));
    if (output.length > maxSubscriptionImportDecompressedBytes) {
      throw const SubscriptionImportException(
        'Converted import exceeds byte limit',
      );
    }
    final outputYaml = loadYaml(converted.config);
    final outputSummary = _clashSummary(outputYaml);
    final ignored = _ignoredSections(format, json);
    return SubscriptionImportResult(
      bytes: output,
      format: format,
      summary: _lossSummary(
        converted.skipped,
        ignored,
        nodes: outputSummary.nodes,
        groups: outputSummary.groups,
        remoteProviders: outputSummary.remoteProviders,
        hasOtherLosses:
            format == SubscriptionFormat.wireguard ||
            format == SubscriptionFormat.amnezia,
      ),
    );
  } on SubscriptionImportException {
    rethrow;
  } on Object {
    throw const SubscriptionImportException('Import conversion failed');
  }
}

SubscriptionImportResult _passthrough(
  Uint8List input,
  SubscriptionFormat format, {
  bool rejectCoreFallback = false,
}) => SubscriptionImportResult(
  bytes: Uint8List.fromList(input),
  format: format,
  summary: SubscriptionImportSummary(rejectCoreFallback: rejectCoreFallback),
);

Object? _decodeJson(String content) {
  if (!content.trimLeft().startsWith('{') &&
      !content.trimLeft().startsWith('[')) {
    return null;
  }
  try {
    return jsonDecode(content);
  } on FormatException {
    return null;
  }
}

bool _looksLikeYaml(String content) =>
    content.contains(':') || content.startsWith('- ');

SubscriptionFormat _detectFormat(String content, Object? json, Object? yaml) {
  final lowerContent = content.toLowerCase();
  if (lowerContent.contains('[interface]') &&
      lowerContent.contains('privatekey')) {
    return SubscriptionFormat.wireguard;
  }
  if (isShareLinkInput(content)) {
    final trimmed = content.trimLeft();
    return trimmed.startsWith('vpn://') ||
            trimmed.startsWith('amneziawg://') ||
            trimmed.startsWith('awg://')
        ? SubscriptionFormat.amnezia
        : SubscriptionFormat.shareLinks;
  }
  if (isWireguardConfInput(content)) return SubscriptionFormat.wireguard;
  if (json is List && isXrayConfigValue(json)) {
    return SubscriptionFormat.xray;
  }
  if (json is Map<String, Object?>) {
    final outbounds = json['outbounds'];
    final xray =
        outbounds is List &&
        outbounds.any(
          (item) =>
              item is Map &&
              const {
                'vless',
                'vmess',
                'trojan',
                'shadowsocks',
                'socks',
                'http',
                'wireguard',
                'freedom',
                'blackhole',
                'dns',
              }.contains(item['protocol']) &&
              (item['settings'] is Map ||
                  ['inbounds', 'routing', 'dns', 'log'].any(json.containsKey)),
        );
    if (xray) return SubscriptionFormat.xray;
    final singbox =
        outbounds is List &&
        outbounds.any(
          (item) =>
              item is Map &&
              const {
                'vless',
                'vmess',
                'trojan',
                'shadowsocks',
                'socks',
                'http',
                'wireguard',
                'hysteria',
                'hysteria2',
                'tuic',
                'anytls',
                'selector',
                'urltest',
                'direct',
                'block',
                'dns',
              }.contains(item['type']),
        );
    if (singbox) return SubscriptionFormat.singbox;
  }
  if (yaml is YamlMap &&
      (yaml['proxies'] is YamlList ||
          yaml['proxy-groups'] is YamlList ||
          yaml['proxy-providers'] is YamlMap)) {
    return SubscriptionFormat.clash;
  }
  return SubscriptionFormat.unknown;
}

void _checkValueLimits(Object? root) {
  var visited = 0;
  final pending = <Object?>[root];
  while (pending.isNotEmpty) {
    final value = pending.removeLast();
    if (value is List) {
      if (value.length > maxSubscriptionImportNodes) {
        throw const SubscriptionImportException('Import exceeds node limit');
      }
      pending.addAll(value);
    } else if (value is Map) {
      if (value.length > maxSubscriptionImportNodes) {
        throw const SubscriptionImportException('Import exceeds node limit');
      }
      pending.addAll(value.values);
    }
    visited++;
    if (visited > maxSubscriptionImportNodes) {
      throw const SubscriptionImportException('Import exceeds node limit');
    }
  }
}

SubscriptionImportSummary _clashSummary(Object? value) {
  if (value is! Map) return const SubscriptionImportSummary();
  final proxies = value['proxies'];
  final groups = value['proxy-groups'];
  final providers = value['proxy-providers'];
  final nodesCount = proxies is List ? proxies.length : 0;
  final groupsCount = groups is List ? groups.length : 0;
  final providersCount = providers is Map ? providers.length : 0;
  if (nodesCount > maxSubscriptionImportNodes ||
      groupsCount > maxSubscriptionImportNodes ||
      providersCount > maxSubscriptionImportNodes) {
    throw const SubscriptionImportException('Import exceeds node limit');
  }
  final tun = value['tun'];
  List<String> packages(String key) {
    final list = tun is Map ? tun[key] : null;
    if (list is! List) return const [];
    return list
        .whereType<String>()
        .where(isAndroidPackageName)
        .toSet()
        .toList();
  }

  return SubscriptionImportSummary(
    nodes: nodesCount,
    groups: groupsCount,
    remoteProviders: providersCount,
    excludedPackages: packages('exclude-package'),
    includedPackages: packages('include-package'),
  );
}

SubscriptionImportSummary _lossSummary(
  List<SkippedNode> skipped,
  List<String> ignored, {
  int nodes = 0,
  int groups = 0,
  int remoteProviders = 0,
  bool hasOtherLosses = false,
}) => SubscriptionImportSummary(
  nodes: nodes,
  groups: groups,
  remoteProviders: remoteProviders,
  skippedNodes: List.unmodifiable(skipped),
  skipped: [for (final node in skipped) '${node.kind}: ${node.name}'],
  undialable: [
    for (final node in skipped)
      if (node.reason == SkippedNodeReason.bandwidth)
        '${node.kind}: ${node.name}',
  ],
  ignoredSections: List.unmodifiable(ignored),
  hasLosses: skipped.isNotEmpty || ignored.isNotEmpty || hasOtherLosses,
  hasOtherLosses: hasOtherLosses,
);

List<String> _ignoredSections(SubscriptionFormat format, Object? json) {
  if (format == SubscriptionFormat.wireguard ||
      format == SubscriptionFormat.amnezia) {
    return const [];
  }
  if (json is! Map) return const [];
  if (format == SubscriptionFormat.xray) {
    return [
      for (final key in ['inbounds', 'dns', 'stats', 'policy', 'api', 'log'])
        if (json.containsKey(key)) key,
      if (json.containsKey('routing')) 'routing (partial conversion)',
    ];
  }
  if (format == SubscriptionFormat.singbox) {
    return [
      for (final key in json.keys)
        if (key != 'outbounds') key.toString(),
    ];
  }
  return const [];
}
