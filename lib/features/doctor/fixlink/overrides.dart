import 'package:reclash/models/models.dart';

import '../remedies/environment.dart';
import '../remedies/remedy.dart';

/// Puts the app-wide overrides (DNS, TUN, general keys and ports) back to
/// their defaults, so the profile's own values apply again.
class ResetOverridesRemedy implements Remedy {
  const ResetOverridesRemedy(this._config);

  final PatchConfigAccess _config;

  @override
  String get id => 'overrides.reset';

  @override
  FixKind get kind => FixKind.auto;

  @override
  RemedyReach get reach => RemedyReach.app;

  @override
  bool get undoable => true;

  @override
  Duration get settle => Duration.zero;

  @override
  Future<void> apply(RemedyRequest request) async {
    const defaults = PatchClashConfig();
    _config.write(
      (config) => config.copyWith(
        dns: defaults.dns,
        dnsOverrideKeys: defaults.dnsOverrideKeys,
        tunOverride: defaults.tunOverride,
        tunOverrideKeys: defaults.tunOverrideKeys,
        generalOverrideKeys: defaults.generalOverrideKeys,
        mixedPort: defaults.mixedPort,
        socksPort: defaults.socksPort,
        port: defaults.port,
        redirPort: defaults.redirPort,
        tproxyPort: defaults.tproxyPort,
      ),
    );
  }
}
