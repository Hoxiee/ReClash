import 'app_update.dart';
import 'update.dart';

enum UpdatePhase {
  idle,
  checking,
  offered,
  downloading,
  paused,
  verifying,
  ready,
  vpnActive,
  permission,
  confirmation,
  installing,
  installed,
  upToDate,
  checkFailed,
  downloadFailed,
  verifyFailed,
  installFailed,
}

class AppUpdateState {
  const AppUpdateState({
    this.phase = UpdatePhase.idle,
    this.release,
    this.asset,
    this.received = 0,
    this.total = 0,
    this.bytesPerSecond = 0,
    this.verified = false,
    this.automaticDownload = false,
  });

  final UpdatePhase phase;
  final AppUpdateRelease? release;
  final AndroidUpdateAsset? asset;
  final int received;
  final int total;
  final double bytesPerSecond;
  final bool verified;
  final bool automaticDownload;

  double? get progress => total > 0 ? (received / total).clamp(0, 1) : null;
  int? get remainingSeconds => bytesPerSecond > 0 && total > received
      ? ((total - received) / bytesPerSecond).ceil()
      : null;
  bool get busy => const {
    UpdatePhase.checking,
    UpdatePhase.downloading,
    UpdatePhase.verifying,
    UpdatePhase.installing,
  }.contains(phase);
  bool get hasUpdate =>
      release != null &&
      !const {
        UpdatePhase.idle,
        UpdatePhase.installed,
        UpdatePhase.upToDate,
      }.contains(phase);

  AppUpdateState copyWith({
    UpdatePhase? phase,
    AppUpdateRelease? release,
    AndroidUpdateAsset? asset,
    int? received,
    int? total,
    double? bytesPerSecond,
    bool? verified,
    bool? automaticDownload,
  }) => AppUpdateState(
    phase: phase ?? this.phase,
    release: release ?? this.release,
    asset: asset ?? this.asset,
    received: received ?? this.received,
    total: total ?? this.total,
    bytesPerSecond: bytesPerSecond ?? this.bytesPerSecond,
    verified: verified ?? this.verified,
    automaticDownload: automaticDownload ?? this.automaticDownload,
  );
}
