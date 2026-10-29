import '../cause.dart';
import '../finding.dart';
import '../snapshot.dart';

const clockSkewWarning = Duration(seconds: 30);
const clockSkewCritical = Duration(seconds: 90);

Finding? clockSkewRule(DiagnosticSnapshot snapshot) {
  final skew = snapshot.valueOf(Facts.clockSkew);
  if (skew == null || skew.abs() < clockSkewWarning) return null;
  return Finding(
    id: 'device.clockSkew',
    severity: skew.abs() >= clockSkewCritical
        ? CheckSeverity.critical
        : CheckSeverity.warning,
    cause: FailureCause.clockSkew,
    evidence: [Facts.clockSkew.id],
    titleKey: 'doctorClockSkewTitle',
    detailKey: skew.isNegative
        ? 'doctorClockSkewBehind'
        : 'doctorClockSkewAhead',
    args: {'seconds': skew.inSeconds.abs()},
  );
}

Finding? batteryOptimizationRule(DiagnosticSnapshot snapshot) {
  if (snapshot.valueOf(Facts.batteryOptimizationIgnored) != false) return null;
  return Finding(
    id: 'device.batteryOptimization',
    severity: CheckSeverity.warning,
    evidence: [Facts.batteryOptimizationIgnored.id],
    titleKey: 'doctorBatteryOptimizationTitle',
    detailKey: 'doctorBatteryOptimizationDetail',
    remedyIds: const ['device.ignoreBatteryOptimization'],
  );
}
