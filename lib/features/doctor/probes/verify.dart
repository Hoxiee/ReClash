import 'package:reclash/core/core.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:riverpod/riverpod.dart';

import '../cause.dart';
import '../kernel.dart';
import '../path.dart';
import 'path.dart';
import 'scheduler.dart';

/// A working node behind a slow link can take several round trips past 5 s
/// to answer through a fresh TLS handshake; a dead one fails fast or hits
/// this.
const _verifyTimeout = Duration(seconds: 10);

/// The group whose selection carries the user's traffic: none in direct mode,
/// `GLOBAL` in global mode, and in rule mode the group the simple dashboard
/// selects in ([pickMainGroup]).
String? resolveMainGroup({
  required Mode mode,
  required List<Group> groups,
  String? serverGroup,
}) {
  switch (mode) {
    case Mode.direct:
      return null;
    case Mode.global:
      return 'GLOBAL';
    case Mode.rule:
      return pickMainGroup(shownGroups(mode, groups), serverGroup)?.name;
  }
}

final mainGroupProvider = Provider<String?>(
  (ref) => resolveMainGroup(
    mode: ref.watch(effectiveModeProvider),
    groups: ref.watch(groupsProvider),
    serverGroup: ref.watch(
      providerHintsProvider.select((hints) => hints?.serverGroup),
    ),
  ),
);

String? mainGroup(Ref ref) => ref.read(mainGroupProvider);

FailureCause _causeOf(String? wire) =>
    FailureCause.fromWire(wire) ?? FailureCause.unknown;

/// The [PathScope.verify] checks: the tunnel as the full path sees it, then
/// the delay test the proxy list runs, dialled through [mainGroup], which the
/// Core resolves to the group's current node. Without a group the dial would
/// follow the rules and could pass DIRECT, so the step stays inconclusive.
PathCheck? verifyCheck(Ref ref, DiagnosticKernel kernel, PathStep step) {
  final main = mainGroup(ref);
  final intent = (pathIntent(ref), main ?? '');
  return switch (step) {
    PathStep.tunnel => pathCheck(ref, kernel, step),
    PathStep.internet => PathCheck(
      key: 'verify.internet',
      cost: CheckCost.network,
      intent: intent,
      run: (_) async {
        if (main == null) return const StepCheck.unknown();
        final url = ref.read(patchClashConfigProvider).testUrl;
        final core = ref.read(coreHandlerProvider);
        final Delay? delay;
        try {
          delay = await core.getDelay(url, main, _verifyTimeout);
        } on Exception {
          return const StepCheck.unknown();
        }
        final value = delay?.value;
        if (value == null) return const StepCheck.unknown();
        if (value > 0) return StepCheck.pass(detail: '$value ms');
        if (value == -1) return const StepCheck.fail(FailureCause.timeout);
        return _failureOf(core, url, main);
      },
    ),
    _ => null,
  };
}

/// A delay test that failed fast says nothing about why; one reach through
/// the same group names the cause for the face and the account guard.
Future<StepCheck> _failureOf(
  CoreController core,
  String url,
  String group,
) async {
  ReachResult? reach;
  try {
    reach = await core.reach(
      ReachParams(
        url: url,
        proxyName: group,
        timeout: _verifyTimeout.inMilliseconds,
      ),
    );
  } on Exception {
    reach = null;
  }
  return switch (reach) {
    ReachResult(:final cause?) => StepCheck.fail(
      _causeOf(cause),
      detail: reach.proxy,
    ),
    ReachResult(direct: false) => StepCheck.fail(
      FailureCause.noUpstream,
      detail: reach.proxy,
    ),
    _ => const StepCheck.fail(FailureCause.unknown),
  };
}
