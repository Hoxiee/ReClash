import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:riverpod/riverpod.dart';

import '../cause.dart';
import '../kernel.dart';
import '../path.dart';
import 'path.dart';
import 'scheduler.dart';

const _verifyTimeout = Duration(seconds: 8);

/// The group whose selection carries the user's traffic: none in direct mode,
/// `GLOBAL` in global mode, and in rule mode the provider's server group, the
/// group the user last opened, or the first shown group, in that order.
String? resolveMainGroup({
  required Mode mode,
  required List<Group> groups,
  String? serverGroup,
  String? currentGroup,
}) {
  switch (mode) {
    case Mode.direct:
      return null;
    case Mode.global:
      return 'GLOBAL';
    case Mode.rule:
      if (serverGroup != null) {
        final wanted = serverGroup.toLowerCase();
        final hinted = groups
            .where((group) => group.name.toLowerCase() == wanted)
            .firstOrNull;
        if (hinted != null) return hinted.name;
      }
      if (currentGroup != null && groups.any((g) => g.name == currentGroup)) {
        return currentGroup;
      }
      return groups.where((group) => group.hidden != true).firstOrNull?.name ??
          groups.firstOrNull?.name;
  }
}

String? mainGroup(Ref ref) => resolveMainGroup(
  mode: ref.read(effectiveModeProvider),
  groups: ref.read(groupsProvider),
  serverGroup: ref.read(providerHintsProvider)?.serverGroup,
  currentGroup: ref.read(currentProfileProvider)?.currentGroupName,
);

FailureCause _causeOf(String? wire) =>
    FailureCause.fromWire(wire) ?? FailureCause.unknown;

/// The [PathScope.verify] checks: the tunnel as the full path sees it, then
/// reach and `generate_204` dialled through [mainGroup], which the Core
/// resolves to the group's current node.
PathCheck? verifyCheck(Ref ref, DiagnosticKernel kernel, PathStep step) {
  final group = mainGroup(ref) ?? '';
  final intent = (pathIntent(ref), group);
  final timeout = _verifyTimeout.inMilliseconds;
  String url() => ref.read(patchClashConfigProvider).testUrl;
  return switch (step) {
    PathStep.tunnel => pathCheck(ref, kernel, step),
    PathStep.server => PathCheck(
      key: 'verify.server',
      cost: CheckCost.network,
      intent: intent,
      run: (_) async {
        final ReachResult? reach;
        try {
          reach = await ref
              .read(coreHandlerProvider)
              .reach(
                ReachParams(url: url(), proxyName: group, timeout: timeout),
              );
        } on Exception {
          return const StepCheck.unknown();
        }
        if (reach == null) return const StepCheck.unknown();
        if (reach.direct) return const StepCheck.unknown(detail: 'DIRECT');
        return reach.cause != null
            ? StepCheck.fail(_causeOf(reach.cause), detail: reach.proxy)
            : StepCheck.pass(detail: reach.proxy);
      },
    ),
    PathStep.internet => PathCheck(
      key: 'verify.internet',
      cost: CheckCost.network,
      intent: intent,
      run: (_) async {
        final ProbeResult? probe;
        try {
          probe = await ref
              .read(coreHandlerProvider)
              .probe(
                ProbeParams(url: url(), proxyName: group, timeout: timeout),
              );
        } on Exception {
          return const StepCheck.unknown();
        }
        if (probe == null) return const StepCheck.unknown();
        if (probe.error != null) {
          return StepCheck.fail(_causeOf(probe.cause), detail: probe.message);
        }
        if (probe.statusCode < 200 || probe.statusCode >= 400) {
          return StepCheck.fail(
            FailureCause.noUpstream,
            detail: 'HTTP ${probe.statusCode}',
          );
        }
        return StepCheck.pass(detail: probe.chains.firstOrNull);
      },
    ),
    _ => null,
  };
}
