import 'package:reclash/core/core.dart';

import '../snapshot.dart';
import 'scheduler.dart';

/// Sends a real MTProto handshake through the relay, since a listening relay
/// proves nothing about Telegram being reachable from this network. The fact
/// is the failure text, empty when the relay is off or works.
ProbeRequest<String> telegramProxyProbe(CoreController core) {
  return ProbeRequest(
    key: Facts.telegramProxyFailure.id,
    cost: CheckCost.network,
    ttl: const Duration(minutes: 10),
    intent: 'selfTest',
    fact: Facts.telegramProxyFailure,
    run: (_) async {
      final state = await core.getTelegramProxy();
      if (state == null) {
        return '';
      }
      if (state.error.isNotEmpty) {
        return state.error;
      }
      return state.running ? core.telegramProxySelfTest(2) : '';
    },
  );
}
