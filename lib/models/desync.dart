import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/desync.freezed.dart';
part 'generated/desync.g.dart';

const defaultDesyncPort = 7898;

const desyncOutboundName = 'DESYNC';

const defaultDesyncProps = DesyncProps();

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
abstract class DesyncProps with _$DesyncProps {
  const factory DesyncProps({
    @Default(false) bool enabled,
    @Default(defaultDesyncPort) int port,
    @Default([DesyncCategory.youtube, DesyncCategory.discord])
    List<DesyncCategory> categories,
    @Default(true) bool forceTcp,
  }) = _DesyncProps;

  factory DesyncProps.fromJson(Map<String, Object?>? json) => json == null
      ? defaultDesyncProps
      : _$DesyncPropsFromJson(json);
}
