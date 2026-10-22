import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/rcx.freezed.dart';
part 'generated/rcx.g.dart';

/// Profile ids the Core ships; the chooser falls back to these when a group
/// names none.
const rcxDefaultProfile = 'builtin/simple';
const rcxFromListProfile = 'builtin/from-list';

@freezed
abstract class RcxPool with _$RcxPool {
  const factory RcxPool({
    @JsonKey(includeIfNull: false) String? include,
    @JsonKey(includeIfNull: false) String? exclude,
  }) = _RcxPool;

  factory RcxPool.fromJson(Map<String, Object?> json) =>
      _$RcxPoolFromJson(json);
}

/// A pool the group switches to in one tap from "Change to".
@freezed
abstract class RcxChip with _$RcxChip {
  const factory RcxChip({required String label, required String include}) =
      _RcxChip;

  factory RcxChip.fromJson(Map<String, Object?> json) =>
      _$RcxChipFromJson(json);
}

/// One group's routing choice. The subscription fills [profiles] and
/// [defaultProfile]; the user sets the rest.
@freezed
abstract class RcxBinding with _$RcxBinding {
  const factory RcxBinding({
    @Default([]) List<String> profiles,
    @JsonKey(name: 'default', includeIfNull: false) String? defaultProfile,
    @JsonKey(includeIfNull: false) String? profile,
    @Default(RcxPool()) RcxPool pool,
    @JsonKey(includeIfNull: false) String? feel,
    @JsonKey(includeIfNull: false) String? energy,
    @Default([]) List<RcxChip> chips,

    /// Honoured from the user's layer only; a provider cannot turn it on.
    @Default(false) bool directSplit,
  }) = _RcxBinding;

  factory RcxBinding.fromJson(Map<String, Object?> json) =>
      _$RcxBindingFromJson(json);
}

/// The host-owned routing layer of one profile: per-group choices, the auto
/// control scenario, and the third-party hosts the user allowed its provider
/// profiles to contact. The user's own profiles and scenarios and the
/// provider's hosts are added on the way to the Core.
@freezed
abstract class RcxUserLayer with _$RcxUserLayer {
  const factory RcxUserLayer({
    @Default({}) Map<String, RcxBinding> groups,
    @Default({}) Map<String, String> profiles,
    @Default({}) Map<String, String> scenarios,
    @JsonKey(includeIfNull: false) String? scenario,
    @Default(false) bool scenarioOff,

    /// The user chose the tunnel mode, so the scenario no longer sets it.
    @Default(false) bool manualMode,
    @Default([]) List<String> providerHosts,
    @Default([]) List<String> trusted,
  }) = _RcxUserLayer;

  factory RcxUserLayer.fromJson(Map<String, Object?> json) =>
      _$RcxUserLayerFromJson(json);

  static RcxUserLayer safeFromJson(Object? json) {
    if (json is! Map) return const RcxUserLayer();
    try {
      return RcxUserLayer.fromJson(Map<String, Object?>.from(json));
    } catch (_) {
      return const RcxUserLayer();
    }
  }
}

@freezed
abstract class RcxReason with _$RcxReason {
  const factory RcxReason({
    required String code,
    @Default({}) Map<String, Object?> args,
  }) = _RcxReason;

  factory RcxReason.fromJson(Map<String, Object?> json) =>
      _$RcxReasonFromJson(json);
}

@freezed
abstract class RcxRanked with _$RcxRanked {
  const factory RcxRanked({
    required String name,
    @Default(0) int tier,
    @Default('') String tierLabel,
    @Default('unknown') String health,
    @Default(0) int latencyMs,
    @Default(0) int spreadMs,
    @Default(0) int episodes,
    DateTime? checkedAt,
    @Default(false) bool current,
    RcxReason? excluded,
    @Default('') String exit,

    /// Check id to pass, fail or soft; unknown checks are absent.
    @Default({}) Map<String, String> checks,

    /// The better tier the node may reach once checked.
    @Default('') String pending,
  }) = _RcxRanked;

  factory RcxRanked.fromJson(Map<String, Object?> json) =>
      _$RcxRankedFromJson(json);
}

@freezed
abstract class RcxDecision with _$RcxDecision {
  const factory RcxDecision({
    @Default('hold') String action,
    @Default('') String target,
    @Default(RcxReason(code: '')) RcxReason reason,
    @Default('') String tier,
    RcxReason? until,
    @Default([]) List<RcxRanked> ranking,
  }) = _RcxDecision;

  factory RcxDecision.fromJson(Map<String, Object?> json) =>
      _$RcxDecisionFromJson(json);
}

@freezed
abstract class RcxControl with _$RcxControl {
  const factory RcxControl({
    @Default('auto') String mode,
    @Default('') String pinName,
    @Default('') String pinEnv,
  }) = _RcxControl;

  factory RcxControl.fromJson(Map<String, Object?> json) =>
      _$RcxControlFromJson(json);
}

extension RcxControlExt on RcxControl {
  bool get isManual => mode == 'manual';

  bool get isPinned => mode == 'pinned';
}

@freezed
abstract class RcxCurrentNode with _$RcxCurrentNode {
  const factory RcxCurrentNode({
    required String name,
    @Default(0) int latencyMs,
    @Default('unknown') String health,
    DateTime? since,
    @Default('') String exit,
  }) = _RcxCurrentNode;

  factory RcxCurrentNode.fromJson(Map<String, Object?> json) =>
      _$RcxCurrentNodeFromJson(json);
}

@freezed
abstract class RcxExcludedNode with _$RcxExcludedNode {
  const factory RcxExcludedNode({
    required String name,
    required DateTime until,
  }) = _RcxExcludedNode;

  factory RcxExcludedNode.fromJson(Map<String, Object?> json) =>
      _$RcxExcludedNodeFromJson(json);
}

/// What the group's profile sees the network as. [kind] is empty until the
/// diagnostics decide; [next] waits for confirmation.
@freezed
abstract class RcxGroupNetwork with _$RcxGroupNetwork {
  const factory RcxGroupNetwork({
    @Default('') String kind,
    @Default('') String next,
    @Default(false) bool paused,
    @Default([]) List<String> kinds,
  }) = _RcxGroupNetwork;

  factory RcxGroupNetwork.fromJson(Map<String, Object?> json) =>
      _$RcxGroupNetworkFromJson(json);
}

@freezed
abstract class RcxGroupStatus with _$RcxGroupStatus {
  const factory RcxGroupStatus({
    required String name,
    @Default('') String source,
    @Default('') String profile,
    @Default('') String profileTitle,
    @Default('simple') String level,
    @Default([]) List<String> offered,
    @Default(RcxBinding()) RcxBinding binding,

    /// The scenario key naming the group now ($main, * or its name), and
    /// the member the scenario holds it on.
    @Default('') String program,
    @Default('') String fixed,

    /// The tunnel mode routes nothing through the group.
    @Default(false) bool idle,
    @Default(RcxControl()) RcxControl control,
    @Default('') String now,

    /// Nested selectors the group reaches [now] through, outermost first.
    @Default([]) List<String> via,
    @Default(RcxDecision()) RcxDecision decision,
    RcxReason? problem,
    @Default(0) int members,
    @Default(0) int candidates,
    @Default([]) List<RcxExcludedNode> excluded,
    @Default(0) int switchesHour,
    @Default(0) int maxPerHour,
    @Default(false) bool improve,
    RcxCurrentNode? current,
    RcxGroupNetwork? network,

    /// Empty when the profile cannot split, else off, standby or active.
    @Default('') String directSplit,
  }) = _RcxGroupStatus;

  factory RcxGroupStatus.fromJson(Map<String, Object?> json) =>
      _$RcxGroupStatusFromJson(json);
}

@freezed
abstract class RcxEnergy with _$RcxEnergy {
  const factory RcxEnergy({
    @Default('balanced') String level,
    @Default('') String day,
    @Default(0) int requests,
    @Default(0) int bytes,
    @Default(0) int capBytes,
    @Default({}) Map<String, int> hourlyLimits,
  }) = _RcxEnergy;

  factory RcxEnergy.fromJson(Map<String, Object?> json) =>
      _$RcxEnergyFromJson(json);
}

@freezed
abstract class RcxStatus with _$RcxStatus {
  const factory RcxStatus({
    @Default(false) bool running,
    @Default('stopped') String mode,
    @Default('') String network,
    @Default([]) List<RcxGroupStatus> groups,
    @Default(RcxEnergy()) RcxEnergy energy,
    @Default([]) List<RcxReason> problems,
    @Default('') String split,
    @Default(0) int library,
    RcxScenarioStatus? scenario,
    @Default('') String tunnelMode,
  }) = _RcxStatus;

  factory RcxStatus.fromJson(Map<String, Object?> json) =>
      _$RcxStatusFromJson(json);
}

@freezed
abstract class RcxScenarioStatus with _$RcxScenarioStatus {
  const factory RcxScenarioStatus({
    required String id,
    @Default('') String title,
    @Default('') String source,
    RcxReason? problem,
    RcxGroupNetwork? network,

    /// The mode it holds on this network; empty leaves it to the user.
    @Default('') String mode,
    @Default(false) bool manual,
    @Default(false) bool holdsMode,
    @Default({}) Map<String, String> groups,
  }) = _RcxScenarioStatus;

  factory RcxScenarioStatus.fromJson(Map<String, Object?> json) =>
      _$RcxScenarioStatusFromJson(json);
}

extension RcxStatusExt on RcxStatus {
  /// The scenario sets the tunnel mode now, unless the user took it over.
  bool get autoMode {
    final scenario = this.scenario;
    return scenario != null && scenario.holdsMode && !scenario.manual;
  }

  RcxGroupStatus? group(String name) {
    for (final group in groups) {
      if (group.name == name) return group;
    }
    return null;
  }
}

@freezed
abstract class RcxExplanation with _$RcxExplanation {
  const factory RcxExplanation({
    required String group,
    @Default('') String profile,
    @Default(RcxDecision()) RcxDecision decision,
    @Default(0) int freshnessSeconds,
    DateTime? at,
  }) = _RcxExplanation;

  factory RcxExplanation.fromJson(Map<String, Object?> json) =>
      _$RcxExplanationFromJson(json);
}

@freezed
abstract class RcxJournalEntry with _$RcxJournalEntry {
  const factory RcxJournalEntry({
    required int seq,
    required DateTime at,
    @Default('') String group,
    required String kind,
    @Default('') String from,
    @Default('') String to,
    @Default(RcxReason(code: '')) RcxReason reason,
  }) = _RcxJournalEntry;

  factory RcxJournalEntry.fromJson(Map<String, Object?> json) =>
      _$RcxJournalEntryFromJson(json);
}

@freezed
abstract class RcxProfileInfo with _$RcxProfileInfo {
  const factory RcxProfileInfo({
    required String id,

    /// `scenario` for an auto control, empty for a group profile.
    @Default('') String kind,
    @Default('') String title,
    @Default('') String level,
    @Default('') String source,
    @JsonKey(name: 'extends') @Default('') String extendsId,
    @Default('') String error,
    @Default({}) Map<String, Map<String, String>> l10n,
    @Default([]) List<String> consent,
  }) = _RcxProfileInfo;

  factory RcxProfileInfo.fromJson(Map<String, Object?> json) =>
      _$RcxProfileInfoFromJson(json);
}

extension RcxProfileInfoExt on RcxProfileInfo {
  /// The profile's own translation of [source] for [locale]: the full tag,
  /// then its language, then the source text.
  String localize(String source, String locale) {
    final tag = locale.replaceAll('_', '-');
    return l10n[tag]?[source] ?? l10n[tag.split('-').first]?[source] ?? source;
  }

  String displayTitle(String locale) =>
      title.isEmpty ? id : localize(title, locale);

  bool get isScenario => kind == 'scenario';
}

/// A routing profile the user owns. A copy remembers the profile it came
/// from and that profile's text when last synced, so a later change of the
/// source can be shown as a diff and brought over.
@freezed
abstract class RcxUserProfile with _$RcxUserProfile {
  const factory RcxUserProfile({
    required String text,

    /// `scenario` for an auto control, empty for a group profile; names are
    /// unique across both.
    @Default('') String kind,
    @Default('') String from,
    @Default('') String base,
    @Default([]) List<RcxProfileVersion> history,
  }) = _RcxUserProfile;

  factory RcxUserProfile.fromJson(Map<String, Object?> json) =>
      _$RcxUserProfileFromJson(json);
}

@freezed
abstract class RcxProfileVersion with _$RcxProfileVersion {
  const factory RcxProfileVersion({
    required DateTime at,
    required String text,
  }) = _RcxProfileVersion;

  factory RcxProfileVersion.fromJson(Map<String, Object?> json) =>
      _$RcxProfileVersionFromJson(json);
}

@freezed
abstract class RcxIssue with _$RcxIssue {
  const factory RcxIssue({
    @Default(0) int line,
    @Default('') String path,
    @Default('') String code,
    @Default({}) Map<String, Object?> args,
    @Default('') String message,
  }) = _RcxIssue;

  factory RcxIssue.fromJson(Map<String, Object?> json) =>
      _$RcxIssueFromJson(json);
}

@freezed
abstract class RcxEndpoint with _$RcxEndpoint {
  const factory RcxEndpoint({
    required String host,
    @Default('') String use,
    @Default('') String target,
    @Default(false) bool thirdParty,
  }) = _RcxEndpoint;

  factory RcxEndpoint.fromJson(Map<String, Object?> json) =>
      _$RcxEndpointFromJson(json);
}

@freezed
abstract class RcxClause with _$RcxClause {
  const factory RcxClause({
    @JsonKey(name: 'not') @Default(false) bool negated,
    required String field,
    @Default('') String op,
    @Default([]) List<String> values,
    @Default(false) bool ignoreCase,
  }) = _RcxClause;

  factory RcxClause.fromJson(Map<String, Object?> json) =>
      _$RcxClauseFromJson(json);
}

/// A condition as the builder shows it; [flat] is false when the text nests
/// deeper than one list of clauses.
@freezed
abstract class RcxCondForm with _$RcxCondForm {
  const factory RcxCondForm({
    @Default('and') String join,
    @Default([]) List<RcxClause> clauses,
    @Default(false) bool flat,
    @Default('') String error,
  }) = _RcxCondForm;

  factory RcxCondForm.fromJson(Map<String, Object?> json) =>
      _$RcxCondFormFromJson(json);
}

@freezed
abstract class RcxField with _$RcxField {
  const factory RcxField({
    required String name,
    required String kind,
    @Default(false) bool network,
    @Default([]) List<String> ops,
    @Default([]) List<String> values,
  }) = _RcxField;

  factory RcxField.fromJson(Map<String, Object?> json) =>
      _$RcxFieldFromJson(json);
}

/// The answer to one profile-editor operation; which fields are set depends
/// on the operation.
@freezed
abstract class RcxStudioResult with _$RcxStudioResult {
  const factory RcxStudioResult({
    @Default('') String text,
    Map<String, Object?>? profile,
    Map<String, Object?>? scenario,
    RcxProfileInfo? info,
    @Default([]) List<RcxIssue> errors,
    @Default([]) List<RcxIssue> warnings,
    @Default([]) List<RcxEndpoint> endpoints,
    RcxCondForm? form,
    @Default([]) List<RcxField> fields,
    @Default([]) List<String> conflicts,
    RcxDecision? current,
    RcxDecision? candidate,
  }) = _RcxStudioResult;

  factory RcxStudioResult.fromJson(Map<String, Object?> json) =>
      _$RcxStudioResultFromJson(json);
}

enum RcxAction { change, pin, auto, manual, check }
