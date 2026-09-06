import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:reclash/common/common.dart';

part 'generated/desync.freezed.dart';
part 'generated/desync.g.dart';

const defaultDesyncPort = 7898;

const desyncOutboundName = 'DESYNC';

const defaultDesyncCacheTtl = 100800;

// The ByeByeDPI tester's top scorer on a live TSPU network: 30/32 youtube
// hosts, fake- and oob-free so it cannot trip the fake-packet detectors.
const desyncDefaultStrategy = <String>[
  '-d1',
  '-s1+s',
  '-s3+s',
  '-s6+s',
  '-s9+s',
  '-s12+s',
  '-s15+s',
  '-s20+s',
  '-s30+s',
  '-a1',
];

// Saved by earlier installs with no editor to change them by hand.
const desyncLegacyLadder = <String>[
  '-A',
  'torst,redirect,ssl_err,conn',
  '-L',
  's,o',
  '--split',
  '1',
  '-A',
  'torst,redirect,ssl_err,conn',
  '-L',
  's,o',
  '--disorder',
  '1',
  '-A',
  'torst,redirect,ssl_err,conn',
  '-L',
  's,o',
  '--fake',
  '-1',
  '--ttl',
  '8',
  '-A',
  'torst,redirect,ssl_err,conn',
  '-L',
  's,o',
  '--oob',
  '1',
  '-A',
  'torst,redirect,ssl_err,conn',
  '-L',
  's,o',
  '--tlsrec',
  '1+s',
];

const desyncLegacyByedpi = <String>['-o1', '-a1', '-r-5+se'];

const desyncLegacyTlsrec = <String>['-r-5+se'];

enum DesyncCategory {
  @JsonValue('youtube')
  youtube,
  @JsonValue('discord')
  discord,
  @JsonValue('twitter')
  twitter,
  @JsonValue('meta')
  meta,
  @JsonValue('signal')
  signal;

  String get geosite => switch (this) {
    DesyncCategory.youtube => 'youtube',
    DesyncCategory.discord => 'discord',
    DesyncCategory.twitter => 'twitter',
    DesyncCategory.meta => 'meta',
    DesyncCategory.signal => 'signal',
  };

  List<String> get cidrs => const [];
}

/// Test domain groups carried over from ByeByeDPI's proxy test, verbatim.
class DesyncTestSiteList {
  const DesyncTestSiteList({
    required this.id,
    required this.name,
    required this.domains,
  });

  final String id;
  final String name;
  final List<String> domains;
}

const desyncTestSiteLists = <DesyncTestSiteList>[
  DesyncTestSiteList(
    id: 'youtube',
    name: 'YouTube',
    domains: [
      'youtu.be',
      'youtube.com',
      'i.ytimg.com',
      'i9.ytimg.com',
      'yt3.ggpht.com',
      'yt4.ggpht.com',
      'googleapis.com',
      'jnn-pa.googleapis.com',
      'googleusercontent.com',
      'signaler-pa.youtube.com',
      'youtubei.googleapis.com',
      'manifest.googlevideo.com',
      'yt3.googleusercontent.com',
    ],
  ),
  DesyncTestSiteList(
    id: 'googlevideo',
    name: 'Google Video',
    domains: [
      'rr1---sn-4axm-n8vs.googlevideo.com',
      'rr1---sn-gvnuxaxjvh-o8ge.googlevideo.com',
      'rr1---sn-ug5onuxaxjvh-p3ul.googlevideo.com',
      'rr1---sn-ug5onuxaxjvh-n8v6.googlevideo.com',
      'rr4---sn-q4flrnsl.googlevideo.com',
      'rr10---sn-gvnuxaxjvh-304z.googlevideo.com',
      'rr14---sn-n8v7kn7r.googlevideo.com',
      'rr16---sn-axq7sn76.googlevideo.com',
      'rr1---sn-8ph2xajvh-5xge.googlevideo.com',
      'rr1---sn-gvnuxaxjvh-5gie.googlevideo.com',
      'rr12---sn-gvnuxaxjvh-bvwz.googlevideo.com',
      'rr5---sn-n8v7knez.googlevideo.com',
      'rr1---sn-u5uuxaxjvhg0-ocje.googlevideo.com',
      'rr2---sn-q4fl6ndl.googlevideo.com',
      'rr5---sn-gvnuxaxjvh-n8vk.googlevideo.com',
      'rr4---sn-jvhnu5g-c35d.googlevideo.com',
      'rr1---sn-q4fl6n6y.googlevideo.com',
      'rr2---sn-hgn7ynek.googlevideo.com',
      'rr1---sn-xguxaxjvh-gufl.googlevideo.com',
    ],
  ),
  DesyncTestSiteList(
    id: 'discord',
    name: 'Discord',
    domains: [
      'dis.gd',
      'discord.co',
      'discord.gg',
      'discord.app',
      'discord.com',
      'discord.dev',
      'discord.new',
      'discord.gift',
      'discord.gifts',
      'discord.media',
      'discord.store',
      'discord.design',
      'discordapp.com',
      'discordcdn.com',
      'discordsez.com',
      'discordsays.com',
      'discordmerch.com',
      'discordpartygames.com',
      'discordactivities.com',
      'stable.dl2.discordapp.net',
      'discord-attachments-uploads-prd.storage.googleapis.com',
    ],
  ),
  DesyncTestSiteList(
    id: 'social',
    name: 'Social',
    domains: [
      'snapchat.com',
      'snap.com',
      'linkedin.com',
      'facebook.com',
      'fb.com',
      'fb.me',
      'fbcdn.net',
      'messenger.com',
      'meta.com',
      'instagram.com',
      'static.cdninstagram.com',
      'proton.me',
      'medium.com',
      'x.com',
      'twitter.com',
      'soundcloud.com',
    ],
  ),
  DesyncTestSiteList(
    id: 'general',
    name: 'General',
    domains: [
      'rutracker.org',
      'nyaa.si',
      'rutor.org',
      'nnmclub.to',
      'speedtest.net',
      'ookla.com',
    ],
  ),
  DesyncTestSiteList(
    id: 'cloudflare',
    name: 'Cloudflare',
    domains: [
      'cloudflare.net',
      'cloudflare.com',
      'cloudflarecn.net',
      'cloudflare-ech.com',
    ],
  ),
  DesyncTestSiteList(
    id: 'turkiye',
    name: 'Türkiye',
    domains: [
      'roblox.com',
      'wattpad.com',
      'pastebin.com',
      '4shared.com',
      'wikileaks.org',
      'bitly.com',
      'cutt.ly',
      't2m.io',
    ],
  ),
];

// Telegram stays reachable when a VPN subscription lapses, so it rides along
// the YouTube default instead of ByeByeDPI's youtube+googlevideo pair.
const defaultDesyncTestSiteLists = <String>[
  'youtube',
  'googlevideo',
];

@freezed
abstract class DesyncStrategy with _$DesyncStrategy {
  const factory DesyncStrategy({
    required String name,
    @Default([]) List<String> args,
  }) = _DesyncStrategy;

  factory DesyncStrategy.fromJson(Map<String, Object?> json) =>
      _$DesyncStrategyFromJson(json);
}

@freezed
abstract class DesyncProps with _$DesyncProps {
  const factory DesyncProps({
    @Default(false) bool enabled,
    @Default(false) bool onlyDpi,
    @Default(defaultDesyncPort) int port,
    @Default([
      DesyncCategory.youtube,
      DesyncCategory.discord,
    ])
    List<DesyncCategory> categories,
    @Default(true) bool forceTcp,
    @Default(desyncDefaultStrategy) List<String> strategyArgs,
    @Default(true) bool cacheEnabled,
    @Default(defaultDesyncCacheTtl) int cacheTtl,
    @Default([]) List<DesyncStrategy> savedStrategies,
    @Default(defaultDesyncTestSiteLists) List<String> testSiteLists,
    @Default(false) bool testRunning,
    // Set before the tester takes over the engine and cleared when it
    // finishes; a value found at startup is a crash to recover from.
    @Default(null) List<String>? testRestoreArgs,
  }) = _DesyncProps;

  factory DesyncProps.fromJson(Map<String, Object?>? json) => json == null
      ? defaultDesyncProps
      : migrateDesyncProps(_$DesyncPropsFromJson(json));

  static DesyncProps safeFromJson(Map<String, Object?>? json) {
    if (json == null) {
      return defaultDesyncProps;
    }
    final cleaned = stripSavedTelegram(json);
    return decodeOrRestoreDefault(
      'desync settings',
      () => DesyncProps.fromJson(cleaned),
      () => defaultDesyncProps,
    );
  }
}

DesyncProps migrateDesyncProps(DesyncProps props) {
  final legacy = props.strategyArgs;
  if (listEquals(legacy, desyncLegacyLadder) ||
      listEquals(legacy, desyncLegacyByedpi) ||
      listEquals(legacy, desyncLegacyTlsrec)) {
    return props.copyWith(strategyArgs: desyncDefaultStrategy);
  }
  return props;
}

Map<String, Object?> stripSavedTelegram(Map<String, Object?> json) {
  var changed = false;
  final copy = <String, Object?>{...json};
  for (final key in ['categories', 'testSiteLists']) {
    final value = copy[key];
    if (value is! List) continue;
    final filtered = [
      for (final item in value)
        if (item != 'telegram') item,
    ];
    if (filtered.length != value.length) {
      copy[key] = filtered;
      changed = true;
    }
  }
  return changed ? copy : json;
}

const defaultDesyncProps = DesyncProps();
