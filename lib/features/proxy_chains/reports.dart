import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/core/method.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/core.dart';

/// The Core's chain reports of the last apply by chain id; null until the
/// first fetch. `SetupAction` refreshes it after every apply.
final chainReportsProvider =
    NotifierProvider<ChainReports, Map<int, ChainReport>?>(ChainReports.new);

final chainGeneratedNamesProvider = Provider<ChainGeneratedNames>(
  (ref) => ChainGeneratedNames.of(
    ref.watch(chainReportsProvider)?.values ?? const [],
  ),
);

class ChainReports extends Notifier<Map<int, ChainReport>?> {
  int _revision = 0;

  @override
  Map<int, ChainReport>? build() => null;

  Future<void> refresh() async {
    final revision = ++_revision;
    List<ChainReport> reports;
    try {
      reports = await ref.read(coreHandlerProvider).getChainReport();
    } catch (error) {
      commonPrint.log(
        'Chain report failed: ${compactError(error)}',
        logLevel: coreFailureLogLevel(error),
      );
      reports = const [];
    }
    if (!ref.mounted || revision != _revision) return;
    state = {for (final report in reports) report.id: report};
  }
}
