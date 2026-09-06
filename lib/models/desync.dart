import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/desync.freezed.dart';
part 'generated/desync.g.dart';

const defaultDesyncPort = 7898;

const desyncOutboundName = 'DESYNC';

const defaultDesyncCacheTtl = 100800;

// The group before the first -A stays empty, so working sites pass untouched.
const desyncDefaultStrategy = <String>[
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

/// Only blocks a desync can actually lift: a service that needs a foreign address
/// belongs behind a node, not here.
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
}

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
    @Default([DesyncCategory.youtube, DesyncCategory.discord])
    List<DesyncCategory> categories,
    @Default(true) bool forceTcp,
    @Default(desyncDefaultStrategy) List<String> strategyArgs,
    @Default(true) bool cacheEnabled,
    @Default(defaultDesyncCacheTtl) int cacheTtl,
    @Default([]) List<DesyncStrategy> savedStrategies,
  }) = _DesyncProps;

  factory DesyncProps.fromJson(Map<String, Object?>? json) =>
      json == null ? defaultDesyncProps : _$DesyncPropsFromJson(json);
}

const defaultDesyncProps = DesyncProps();
