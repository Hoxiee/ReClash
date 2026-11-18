import 'package:freezed_annotation/freezed_annotation.dart';

import 'common.dart';

part 'generated/proxy_chain.freezed.dart';
part 'generated/proxy_chain.g.dart';

/// Hop count bounds: entry and exit, plus one optional middle.
const minChainHops = 2;
const maxChainHops = 3;

@freezed
abstract class HopFingerprint with _$HopFingerprint {
  const factory HopFingerprint({
    required String type,
    required String server,
    required int port,
  }) = _HopFingerprint;

  factory HopFingerprint.fromJson(Map<String, Object?> json) =>
      _$HopFingerprintFromJson(json);
}

/// A saved route of a profile; [hops] are proxy or group names, entry first.
@freezed
abstract class ProxyChain with _$ProxyChain {
  const factory ProxyChain({
    required int id,
    required int profileId,
    required String name,
    required List<String> hops,
    @Default(true) bool nameAuto,
    @Default(true) bool enabled,
    @Default(true) bool offered,

    /// Null offers the chain in the profile's resolved main group.
    String? targetGroup,

    /// Per hop, null where the hop is a group or was not running when saved.
    @Default([]) List<HopFingerprint?> fingerprints,
    @Default(0) int sortIndex,

    /// The target group's pick the chain displaced when it joined, restored
    /// when the chain leaves the group while selected.
    String? restorePick,
  }) = _ProxyChain;

  factory ProxyChain.fromJson(Map<String, Object?> json) =>
      _$ProxyChainFromJson(json);
}

extension ProxyChainExt on ProxyChain {
  String get entry => hops.first;

  String get exit => hops.last;

  String? get middle => hops.length > 2 ? hops[1] : null;

  ChainSpec toSpec() => ChainSpec(
    id: id,
    name: name,
    hops: hops,
    offered: offered,
    targetGroup: targetGroup,
    fingerprints: fingerprints.length == hops.length ? fingerprints : null,
  );
}

String autoChainName(List<String> hops) => hops.join(' → ');

@freezed
abstract class ChainSpec with _$ChainSpec {
  const factory ChainSpec({
    required int id,
    required String name,
    required List<String> hops,
    required bool offered,
    @JsonKey(name: 'target-group') String? targetGroup,
    @JsonKey(includeIfNull: false) List<HopFingerprint?>? fingerprints,

    /// Lets a missing hop take the one node its fingerprint matches.
    @JsonKey(includeIfNull: false) bool? heal,
  }) = _ChainSpec;

  factory ChainSpec.fromJson(Map<String, Object?> json) =>
      _$ChainSpecFromJson(json);
}

enum ChainIssueCode {
  missingHop,
  unchainableHop,
  loop,
  emptyExit,
  providerPending,
  udpTransportMissing,
  nameClash,
  dialerReplaced,
  udpLost,
  mainGroupAutomatic,
  missingTarget,

  /// A code this build does not know; the UI shows a generic line.
  unknown;

  bool get isError => switch (this) {
    missingHop ||
    unchainableHop ||
    loop ||
    emptyExit ||
    udpTransportMissing ||
    nameClash => true,
    _ => false,
  };

  bool get isWarning => switch (this) {
    dialerReplaced ||
    udpLost ||
    mainGroupAutomatic ||
    missingTarget ||
    providerPending => true,
    _ => false,
  };
}

enum ChainStatus { ok, degraded, broken }

enum ChainUdp { carried, lost, none }

@freezed
abstract class ChainIssue with _$ChainIssue {
  const factory ChainIssue({
    /// Hop index, -1 for the chain itself.
    @Default(-1) int hop,
    @JsonKey(unknownEnumValue: ChainIssueCode.unknown)
    required ChainIssueCode code,
    HopFingerprint? fingerprint,
    @Default([]) List<String> suggest,
  }) = _ChainIssue;

  factory ChainIssue.fromJson(Map<String, Object?> json) =>
      _$ChainIssueFromJson(json);
}

@freezed
abstract class ChainMember with _$ChainMember {
  const factory ChainMember({
    required String leaf,
    @Default('') String server,
    @Default(0) int port,
  }) = _ChainMember;

  factory ChainMember.fromJson(Map<String, Object?> json) =>
      _$ChainMemberFromJson(json);
}

/// The Core's verdict on a chain after the last apply; the only source of a
/// chain's state, never derived in the app.
@freezed
abstract class ChainReport with _$ChainReport {
  const factory ChainReport({
    required int id,

    /// The chain's group name in the running config.
    required String group,

    /// A newer Core's unknown status reads as degraded: shown, never an outage.
    @JsonKey(unknownEnumValue: ChainStatus.degraded)
    required ChainStatus status,
    @Default([]) List<ChainIssue> issues,

    /// Keyed by clone name, which the UI never shows.
    @Default({}) Map<String, ChainMember> members,

    /// The chain's other generated groups, clones and providers.
    @Default([]) List<String> hidden,
    @JsonKey(unknownEnumValue: ChainUdp.none)
    @Default(ChainUdp.none)
    ChainUdp udp,

    /// The group the chain was offered in, null when it was not.
    String? target,
  }) = _ChainReport;

  factory ChainReport.fromJson(Map<String, Object?> json) =>
      _$ChainReportFromJson(json);
}

extension ChainReportExt on ChainReport {
  bool get isBroken => status == ChainStatus.broken;

  Iterable<ChainIssue> get errors => issues.where((i) => i.code.isError);

  Iterable<ChainIssue> get warnings => issues.where((i) => !i.code.isError);
}

@freezed
abstract class InspectChainParams with _$InspectChainParams {
  const factory InspectChainParams({
    required List<String> hops,
    @JsonKey(includeIfNull: false) int? slot,
    @JsonKey(name: 'target-group', includeIfNull: false) String? targetGroup,
    @JsonKey(name: 'main-group-hint', includeIfNull: false)
    String? mainGroupHint,
  }) = _InspectChainParams;

  factory InspectChainParams.fromJson(Map<String, Object?> json) =>
      _$InspectChainParamsFromJson(json);
}

@freezed
abstract class ChainInspection with _$ChainInspection {
  const factory ChainInspection({
    @Default([]) List<ChainIssue> issues,

    /// The exit's leaves.
    @Default([]) List<String> leaves,

    /// Per hop, whether it carries UDP.
    @Default([]) List<bool> udp,

    /// With a slot: candidates for it that would fail, and why.
    @JsonKey(fromJson: _blockedFromJson)
    @Default({})
    Map<String, ChainIssueCode> blocked,
  }) = _ChainInspection;

  factory ChainInspection.fromJson(Map<String, Object?> json) =>
      _$ChainInspectionFromJson(json);
}

extension ChainInspectionExt on ChainInspection {
  bool get blocksSave => issues.any((issue) => issue.code.isError);
}

Map<String, ChainIssueCode> _blockedFromJson(Object? json) => {
  for (final MapEntry(:key, :value) in (json as Map? ?? const {}).entries)
    key as String:
        ChainIssueCode.values.asNameMap()[value] ?? ChainIssueCode.unknown,
};

/// What the Core adds to the running config for chains besides each chain's
/// own group: clones and hidden hop groups, which mihomo lists in GLOBAL, and
/// sibling providers named `<chain group>/<provider>`. The app lists none.
class ChainGeneratedNames {
  const ChainGeneratedNames({this.clones = const {}, this.groups = const {}});

  factory ChainGeneratedNames.of(Iterable<ChainReport> reports) =>
      ChainGeneratedNames(
        clones: {
          for (final report in reports) ...[
            ...report.members.keys,
            ...report.hidden,
          ],
        },
        groups: {for (final report in reports) report.group},
      );

  final Set<String> clones;
  final Set<String> groups;

  bool get isEmpty => clones.isEmpty && groups.isEmpty;

  bool isProvider(String name) =>
      groups.any((group) => name.startsWith('$group/'));

  /// A chain group keeps its clones: they are its exit choices.
  List<Group> visibleGroups(List<Group> groups) {
    if (clones.isEmpty) return groups;
    return [
      for (final group in groups)
        if (this.groups.contains(group.name) ||
            !group.all.any((proxy) => clones.contains(proxy.name)))
          group
        else
          group.copyWith(
            all: [
              for (final proxy in group.all)
                if (!clones.contains(proxy.name)) proxy,
            ],
          ),
    ];
  }
}
