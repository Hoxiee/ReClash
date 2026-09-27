import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/core.dart';

/// Single pull of the routing engine's report. The overview view refreshes it
/// on its own lifecycle-gated cadence; milestones derive their history from the
/// same fetch, so the two pull consumers cannot read different report
/// snapshots. The push `smartRoutingStatusProvider` stays the low-latency live
/// layer and is intentionally kept separate.
final rcxReportProvider = FutureProvider.autoDispose<RcxReport?>(
  (ref) => ref.read(coreHandlerProvider).smartRoutingReport(),
);
