import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/site_lock.freezed.dart';
part 'generated/site_lock.g.dart';

enum SiteLockStatus {
  @JsonValue('ready')
  ready,
  @JsonValue('disabled')
  disabled,
  @JsonValue('no-exit')
  noExit,
  @JsonValue('exits-down')
  exitsDown,
  @JsonValue('unknown')
  unknown,
}

/// [route] fingerprints the server's whole definition but its name; [name]
/// finds it at the same address once a subscription rotates its credentials.
@freezed
abstract class SiteLockExit with _$SiteLockExit {
  const factory SiteLockExit({
    required String type,
    required String server,
    required int port,
    @Default('') String route,
    @Default('') String name,
  }) = _SiteLockExit;

  factory SiteLockExit.fromJson(Map<String, Object?> json) =>
      _$SiteLockExitFromJson(json);
}

/// A server of the running config that a lock can name as an exit, with
/// every proxy name that shares its definition.
@freezed
abstract class SiteLockExitCandidate with _$SiteLockExitCandidate {
  const factory SiteLockExitCandidate({
    required String type,
    required String server,
    required int port,
    @Default('') String route,
    @Default([]) List<String> names,
  }) = _SiteLockExitCandidate;

  factory SiteLockExitCandidate.fromJson(Map<String, Object?> json) =>
      _$SiteLockExitCandidateFromJson(json);
}

@freezed
abstract class SiteLock with _$SiteLock {
  const factory SiteLock({
    required String id,
    @Default('') String name,
    @Default(true) bool enabled,
    @Default([]) List<String> match,
    @Default([]) List<String> except,
    @Default([]) List<SiteLockExit> exits,
    @Default('') String preset,
  }) = _SiteLock;

  factory SiteLock.fromJson(Map<String, Object?> json) =>
      _$SiteLockFromJson(json);
}

@freezed
abstract class SiteLockProblem with _$SiteLockProblem {
  const factory SiteLockProblem({
    @Default('') String id,
    @Default('') String field,
    @Default('') String message,
  }) = _SiteLockProblem;

  factory SiteLockProblem.fromJson(Map<String, Object?> json) =>
      _$SiteLockProblemFromJson(json);
}

@freezed
abstract class SiteLockState with _$SiteLockState {
  const factory SiteLockState({
    required String id,
    @JsonKey(unknownEnumValue: SiteLockStatus.unknown)
    required SiteLockStatus status,
    String? exit,
  }) = _SiteLockState;

  factory SiteLockState.fromJson(Map<String, Object?> json) =>
      _$SiteLockStateFromJson(json);
}

@freezed
abstract class SiteLockWarning with _$SiteLockWarning {
  const factory SiteLockWarning({
    @Default('') String code,
    @Default([]) List<String> locks,
  }) = _SiteLockWarning;

  factory SiteLockWarning.fromJson(Map<String, Object?> json) =>
      _$SiteLockWarningFromJson(json);
}

/// The Core's answer to a lock push or status query; `applied` false means
/// the previous locks stay in force.
@freezed
abstract class SiteLockReport with _$SiteLockReport {
  const factory SiteLockReport({
    @Default(false) bool applied,
    @Default([]) List<SiteLockProblem> problems,
    @Default([]) List<SiteLockState> locks,
    @Default([]) List<SiteLockWarning> warnings,
  }) = _SiteLockReport;

  factory SiteLockReport.fromJson(Map<String, Object?> json) =>
      _$SiteLockReportFromJson(json);
}

@freezed
abstract class SiteLockNames with _$SiteLockNames {
  const factory SiteLockNames({
    @Default([]) List<String> full,
    @Default([]) List<String> suffix,
    @Default([]) List<String> keyword,
    @Default([]) List<String> regex,
  }) = _SiteLockNames;

  factory SiteLockNames.fromJson(Map<String, Object?> json) =>
      _$SiteLockNamesFromJson(json);
}

@freezed
abstract class SiteLockGuardedNames with _$SiteLockGuardedNames {
  const factory SiteLockGuardedNames({
    @Default(SiteLockNames()) SiteLockNames names,
    @Default(SiteLockNames()) SiteLockNames except,
  }) = _SiteLockGuardedNames;

  factory SiteLockGuardedNames.fromJson(Map<String, Object?> json) =>
      _$SiteLockGuardedNamesFromJson(json);
}

/// What the host firewall keeps off every path but the TUN (empty when TUN is
/// off): locked addresses and names. `fakeRanges` are the profile's fake-ip
/// ranges, kept off physical interfaces only. `unchanged` answers a query whose known
/// revision is still current.
@freezed
abstract class SiteLockPolicy with _$SiteLockPolicy {
  const factory SiteLockPolicy({
    @Default('') String revision,
    @Default(false) bool unchanged,
    @Default('') String tun,
    @Default([]) List<String> addresses,
    @Default([]) List<String> fakeRanges,
    @Default(SiteLockNames()) SiteLockNames names,
    @Default([]) List<SiteLockGuardedNames> guarded,
  }) = _SiteLockPolicy;

  factory SiteLockPolicy.fromJson(Map<String, Object?> json) =>
      _$SiteLockPolicyFromJson(json);
}

/// A service whose account checks tie it to one IP; [name] is a proper noun.
/// A lock keeps its [id], so entries added here in a release reach the lock.
class SiteLockPreset {
  const SiteLockPreset(this.id, this.name, this.match);

  final String id;
  final String name;
  final List<String> match;
}

const siteLockPresets = [
  SiteLockPreset('claude', 'Claude', [
    'GEOSITE,anthropic',
    'DOMAIN-SUFFIX,anthropic.com',
    'DOMAIN-SUFFIX,claude.ai',
    'DOMAIN-SUFFIX,claude.com',
    'DOMAIN-SUFFIX,claudeusercontent.com',
    'DOMAIN-SUFFIX,claudemcpclient.com',
    'DOMAIN-SUFFIX,claudemcpcontent.com',
    'DOMAIN-SUFFIX,clau.de',
    // Telemetry and error reports of Claude Code, sent from the same IP.
    'DOMAIN,http-intake.logs.us5.datadoghq.com',
    'DOMAIN,browser-intake-us5-datadoghq.com',
    'DOMAIN,o1158394.ingest.us.sentry.io',
    // Anthropic's published ranges catch connections made without a name.
    'IP-CIDR,160.79.104.0/21,no-resolve',
    'IP-CIDR,153.61.208.0/20,no-resolve',
    'IP-CIDR,153.61.224.0/22,no-resolve',
    'IP-CIDR6,2607:6bc0::/48,no-resolve',
  ]),
  SiteLockPreset('chatgpt', 'ChatGPT', [
    'GEOSITE,openai',
    'DOMAIN-SUFFIX,chatgpt.com',
    'DOMAIN-SUFFIX,oaistatic.com',
    'DOMAIN-SUFFIX,oaiusercontent.com',
    'DOMAIN-SUFFIX,openai.com',
  ]),
  SiteLockPreset('gemini', 'Gemini', ['GEOSITE,google-gemini']),
  SiteLockPreset('grok', 'Grok', [
    'DOMAIN-SUFFIX,x.ai',
    'DOMAIN-SUFFIX,grok.com',
  ]),
  SiteLockPreset('perplexity', 'Perplexity', ['GEOSITE,perplexity']),
  SiteLockPreset('deepseek', 'DeepSeek', ['GEOSITE,deepseek']),
  SiteLockPreset('cursor', 'Cursor', ['GEOSITE,cursor']),
];

SiteLockPreset? siteLockPresetOf(String id) {
  for (final preset in siteLockPresets) {
    if (preset.id == id) return preset;
  }
  return null;
}

extension SiteLockEntries on SiteLock {
  /// The lock's own entries, then its preset's: the list the core checks and
  /// indexes its problems by.
  List<String> get entries {
    final found = siteLockPresetOf(preset);
    return found == null ? match : {...match, ...found.match}.toList();
  }

  SiteLock get forCore =>
      preset.isEmpty ? this : copyWith(match: entries, preset: '');
}

List<Map<String, Object?>>? siteLocksToCore(List<SiteLock>? locks) =>
    locks?.map((lock) => lock.forCore.toJson()).toList();
