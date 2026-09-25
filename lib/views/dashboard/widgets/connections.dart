import 'package:reclash/common/common.dart';
import 'package:reclash/core/controller.dart';
import 'package:reclash/core/method.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/core.dart';
import 'package:reclash/views/connection/connections.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'feed_card.dart';

class ConnectionsCard extends ConsumerStatefulWidget {
  final Future<int> Function()? countReader;

  const ConnectionsCard({super.key, @visibleForTesting this.countReader});

  @override
  ConsumerState<ConnectionsCard> createState() => _ConnectionsCardState();
}

class _ConnectionsCardState extends ConsumerState<ConnectionsCard>
    with WidgetsBindingObserver, ActivePollingMixin<ConnectionsCard> {
  final _countNotifier = ValueNotifier(0);

  CoreController get _core => ref.read(coreHandlerProvider);

  @override
  Duration get pollInterval => const Duration(seconds: 2);

  @override
  void dispose() {
    _countNotifier.dispose();
    super.dispose();
  }

  @override
  Future<void> poll(PollGuard isCurrent) async {
    final count = await _readCount();
    if (count == null || !isCurrent()) {
      return;
    }
    _countNotifier.value = count;
  }

  Future<int?> _readCount() async {
    final countReader = widget.countReader;
    if (countReader == null &&
        ref.read(coreStatusProvider) != CoreStatus.connected) {
      return 0;
    }
    try {
      if (countReader != null) {
        return await countReader();
      }
      return (await _core.getConnections()).length;
    } catch (error) {
      commonPrint.log(
        'updateConnectionCount error: $error',
        logLevel: coreFailureLogLevel(error),
      );
      return null;
    }
  }

  void _openConnections(BuildContext context) {
    showSnapSheet(context, builder: (_, _) => const ConnectionsView());
  }

  @override
  Widget build(BuildContext context) {
    return FeedCard(
      label: PageLabel.connections.label,
      glyph: AppGlyphs.connections,
      onPressed: () => _openConnections(context),
      child: ValueListenableBuilder(
        valueListenable: _countNotifier,
        builder: (_, count, _) => FeedCount(count: count),
      ),
    );
  }
}
