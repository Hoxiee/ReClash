import 'package:reclash/common/common.dart';
import 'package:reclash/core/controller.dart';
import 'package:reclash/core/method.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/core.dart';
import 'package:reclash/views/dashboard/widgets/dashboard_info_card.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GoroutineInfo extends ConsumerStatefulWidget {
  final Future<int> Function()? countReader;

  const GoroutineInfo({super.key, @visibleForTesting this.countReader});

  @override
  ConsumerState<GoroutineInfo> createState() => _GoroutineInfoState();
}

class _GoroutineInfoState extends ConsumerState<GoroutineInfo>
    with WidgetsBindingObserver, ActivePollingMixin<GoroutineInfo> {
  final _countNotifier = ValueNotifier<int>(0);

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
    try {
      final countReader = widget.countReader;
      if (countReader != null) {
        return await countReader();
      }
      final coreConnected =
          ref.read(coreStatusProvider) == CoreStatus.connected;
      return coreConnected ? await _core.getGoroutineCount() : null;
    } catch (error) {
      commonPrint.log(
        'updateGoroutineCount error: $error',
        logLevel: coreFailureLogLevel(error),
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DashboardInfoCard(
      height: getWidgetHeight(1),
      icon: Icons.account_tree_rounded,
      label: context.appLocalizations.goroutineInfo,
      child: ValueListenableBuilder(
        valueListenable: _countNotifier,
        builder: (_, count, _) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '$count',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
      ),
    );
  }
}
