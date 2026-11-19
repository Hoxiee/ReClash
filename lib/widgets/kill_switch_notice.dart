import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/chains/issues.dart';

/// Shown while the Helper's kill switch blocks traffic and the Core runs
/// without TUN, which would otherwise look like a dead connection.
class KillSwitchNotice extends ConsumerWidget {
  const KillSwitchNotice({super.key});

  Future<void> _start(WidgetRef ref) async {
    if (!ref.read(patchClashConfigProvider).tun.enable) {
      await ref.read(setupActionProvider.notifier).setTunEnabled(true);
    }
    if (!ref.read(isStartProvider)) {
      await ref.read(commonActionProvider.notifier).setRunning(true);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(killSwitchBlockingProvider)) return const SizedBox.shrink();
    final l = context.appLocalizations;
    final standard =
        ref.watch(networkSettingProvider.select((state) => state.killSwitch)) ==
        KillSwitchMode.standard;
    return IssueCard(
      key: const ValueKey('kill-switch-notice'),
      tone: IssueTone.error,
      title: l.killSwitchBlockingTitle,
      body: l.killSwitchBlockingBody,
      action: l.start,
      onAction: () => unawaited(_start(ref)),
      secondaryAction: standard ? l.killSwitchUnblock : null,
      onSecondaryAction: standard
          ? () => unawaited(
              globalState.safeRun(
                () => ref.read(killSwitchHostStateProvider.notifier).unblock(),
              ),
            )
          : null,
    );
  }
}
