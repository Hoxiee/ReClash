import 'package:reclash/models/models.dart';

/// Mutable collector threaded through `Profile.prepareUpdate` to witness the
/// update path in the live isolate. Hosts are pseudonymized `host-NN` in order
/// of first sight; the real URL, query and device headers never reach it.
class SubscriptionUpdateProbe {
  final Map<String, _HostStat> _hosts = {};
  final Map<String, _StageStat> _stages = {};
  bool _succeeded = false;
  bool _hwidRejected = false;
  bool _emptyResponse = false;
  bool _undialable = false;

  static const stageFetch = 'fetch';
  static const stageParse = 'parse';
  static const stagePanel = 'panel';

  String _alias(String host) {
    return _hosts.putIfAbsent(host, () {
      final alias = 'host-${(_hosts.length + 1).toString().padLeft(2, '0')}';
      return _HostStat(alias);
    }).alias;
  }

  void recordAttempt(String host) {
    final stat = _hosts.putIfAbsent(host, () {
      final alias = 'host-${(_hosts.length + 1).toString().padLeft(2, '0')}';
      return _HostStat(alias);
    });
    stat.attempts++;
  }

  void recordFailure(String host, String stage, String error) {
    _alias(host);
    final stat = _hosts[host]!;
    stat.failures++;
    stat.lastError = error;
    final byStage = _stages.putIfAbsent(stage, () => _StageStat());
    byStage.attempts++;
    byStage.failures++;
    if (error.isNotEmpty) {
      byStage.errors[error] = (byStage.errors[error] ?? 0) + 1;
    }
  }

  void recordHwidRejected(String host) {
    _hwidRejected = true;
    recordFailure(host, stagePanel, 'hwidRejected');
  }

  void recordEmptyResponse(String host) {
    _emptyResponse = true;
    recordFailure(host, stageParse, 'emptyResponse');
  }

  void recordUndialable(String host) {
    _undialable = true;
    recordFailure(host, stageParse, 'undialable');
  }

  void recordSuccess(String host) {
    _alias(host);
    _hosts[host]!.succeeded = true;
    _succeeded = true;
    final byStage = _stages.putIfAbsent(stageFetch, () => _StageStat());
    byStage.attempts++;
  }

  SubscriptionUpdateReport build() {
    var attempts = 0;
    var failures = 0;
    final hosts = <SubscriptionUpdateHost>[];
    for (final stat in _hosts.values) {
      attempts += stat.attempts;
      failures += stat.failures;
      hosts.add(
        SubscriptionUpdateHost(
          host: stat.alias,
          attempts: stat.attempts,
          failures: stat.failures,
          succeeded: stat.succeeded,
          lastError: stat.lastError,
        ),
      );
    }
    final byStage = <SubscriptionUpdateStage>[];
    var dominantError = '';
    var dominantCount = 0;
    for (final entry in _stages.entries) {
      final stat = entry.value;
      final dominant = _dominant(stat.errors);
      if (stat.errors[dominant] != null &&
          stat.errors[dominant]! > dominantCount) {
        dominantCount = stat.errors[dominant]!;
        dominantError = dominant;
      }
      byStage.add(
        SubscriptionUpdateStage(
          stage: entry.key,
          attempts: stat.attempts,
          failures: stat.failures,
          dominantError: dominant,
        ),
      );
    }
    return SubscriptionUpdateReport(
      attempted: _hosts.isNotEmpty,
      succeeded: _succeeded,
      generatedAt: DateTime.now().millisecondsSinceEpoch,
      hostCount: _hosts.length,
      attempts: attempts,
      failures: failures,
      hwidRejected: _hwidRejected,
      emptyResponse: _emptyResponse,
      undialable: _undialable,
      dominantError: dominantError,
      byStage: byStage,
      hosts: hosts,
    );
  }

  static String _dominant(Map<String, int> counts) {
    var best = '';
    var bestN = 0;
    for (final entry in counts.entries) {
      if (entry.value > bestN) {
        bestN = entry.value;
        best = entry.key;
      }
    }
    return best;
  }
}

class _HostStat {
  _HostStat(this.alias);

  final String alias;
  int attempts = 0;
  int failures = 0;
  bool succeeded = false;
  String lastError = '';
}

class _StageStat {
  int attempts = 0;
  int failures = 0;
  final Map<String, int> errors = {};
}
