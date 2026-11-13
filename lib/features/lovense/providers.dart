import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/plugins/app.dart';
import 'package:reclash/providers/providers.dart';

import 'controller.dart';
import 'engine.dart';
import 'reactions.dart';

/// App-wide so reactions keep the connection after the page closes; nothing
/// connects until the user does so on the page.
final lovenseControllerProvider = Provider<LovenseController>((ref) {
  final controller = LovenseController(
    requestPermission: () async =>
        await app?.requestLocalNetworkPermission() ?? true,
  );
  ref.onDispose(controller.dispose);
  return controller;
});

final lovenseReactionsProvider = Provider<LovenseReactions>((ref) {
  final reactions = LovenseReactions(
    ref.watch(lovenseControllerProvider),
    _RefReactionSource(ref),
  );
  ref.onDispose(reactions.dispose);
  return reactions;
});

class _RefReactionSource implements LovenseReactionSource {
  _RefReactionSource(this._ref);

  final Ref _ref;

  @override
  LovenseLink get link => LovenseLink(
    running: _ref.read(isStartProvider),
    coreConnected: _ref.read(coreStatusProvider) == CoreStatus.connected,
  );

  @override
  bool get visible => _ref.read(appVisibleProvider);

  @override
  VoidCallback listenLink(ValueChanged<LovenseLink> listener) {
    final running = _ref.listen(isStartProvider, (_, _) => listener(link));
    final core = _ref.listen(coreStatusProvider, (_, _) => listener(link));
    return () {
      running.close();
      core.close();
    };
  }

  @override
  VoidCallback listenSpeed(ValueChanged<num> listener) =>
      _ref.listen(trafficsProvider, (_, next) {
        final latest = next.list.lastOrNull;
        if (latest != null) listener(latest.speed);
      }).close;

  @override
  VoidCallback listenVisible(ValueChanged<bool> listener) =>
      _ref.listen(appVisibleProvider, (_, next) => listener(next)).close;
}
