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

@freezed
abstract class SiteLockExit with _$SiteLockExit {
  const factory SiteLockExit({
    required String type,
    required String server,
    required int port,
  }) = _SiteLockExit;

  factory SiteLockExit.fromJson(Map<String, Object?> json) =>
      _$SiteLockExitFromJson(json);
}

/// A server of the running config that a lock can name as an exit, with
/// every proxy name that points at it.
@freezed
abstract class SiteLockExitCandidate with _$SiteLockExitCandidate {
  const factory SiteLockExitCandidate({
    required String type,
    required String server,
    required int port,
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

/// What the host firewall keeps off every path but the TUN (empty when TUN is
/// off): locked addresses and names. `unchanged` answers a query whose known
/// revision is still current.
@freezed
abstract class SiteLockPolicy with _$SiteLockPolicy {
  const factory SiteLockPolicy({
    @Default('') String revision,
    @Default(false) bool unchanged,
    @Default('') String tun,
    @Default([]) List<String> addresses,
    @Default(SiteLockNames()) SiteLockNames names,
  }) = _SiteLockPolicy;

  factory SiteLockPolicy.fromJson(Map<String, Object?> json) =>
      _$SiteLockPolicyFromJson(json);
}
