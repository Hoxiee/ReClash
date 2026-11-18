import 'dart:convert';

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/action.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/state.dart';
import 'package:reclash/providers/setup.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VpnManager extends ConsumerStatefulWidget {
  final Widget child;

  const VpnManager({super.key, required this.child});

  @override
  ConsumerState<VpnManager> createState() => _VpnContainerState();
}

class _VpnContainerState extends ConsumerState<VpnManager> {
  @override
  void initState() {
    super.initState();
    ref.listenManual(
      vpnOptionsProvider.select((state) => state.value?.effective),
      (prev, next) {
        final running = ref.read(runningVpnOptionsProvider)?.effective;
        if (next != null &&
            prev != next &&
            running != null &&
            running != next &&
            !ref.read(setupSessionProvider).active) {
          commonPrint.log('VPN restart tip: ${_changedFields(running, next)}');
          _showRestartTip();
        }
      },
    );
  }

  String _changedFields(VpnOptions running, VpnOptions next) {
    final before = jsonDecode(jsonEncode(running)) as Map<String, dynamic>;
    final after = jsonDecode(jsonEncode(next)) as Map<String, dynamic>;
    return [
      for (final key in after.keys)
        if (jsonEncode(before[key]) != jsonEncode(after[key]))
          '$key: ${jsonEncode(before[key])} -> ${jsonEncode(after[key])}',
    ].join('; ');
  }

  void _showRestartTip() {
    dialogs.showNotifier(
      currentAppLocalizations.vpnConfigChangeDetected,
      level: MessageLevel.warning,
      actionState: MessageActionState(
        actionText: currentAppLocalizations.restart,
        action: () async {
          await ref.read(setupActionProvider.notifier).restartVpn();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
