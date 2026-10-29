import 'package:reclash/enum/enum.dart';

import '../finding.dart';
import '../snapshot.dart';

Finding? directModeRule(DiagnosticSnapshot snapshot) {
  if (snapshot.valueOf(Facts.mode) != Mode.direct) return null;
  return Finding(
    id: 'config.directMode',
    severity: CheckSeverity.warning,
    evidence: [Facts.mode.id],
    titleKey: 'doctorDirectModeTitle',
    detailKey: 'doctorDirectModeDetail',
    remedyIds: const ['config.ruleMode'],
  );
}
