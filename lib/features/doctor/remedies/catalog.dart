import 'package:reclash/enum/enum.dart';

import 'remedy.dart';

class RuleModeRemedy implements Remedy {
  const RuleModeRemedy(this._changeMode);

  final void Function(Mode mode) _changeMode;

  @override
  String get id => 'config.ruleMode';

  @override
  FixKind get kind => FixKind.auto;

  @override
  bool get undoable => true;

  @override
  Duration get settle => Duration.zero;

  @override
  Future<void> apply(RemedyRequest request) async => _changeMode(Mode.rule);
}

class BatteryExemptionRemedy implements Remedy {
  const BatteryExemptionRemedy(this._request);

  final Future<void> Function() _request;

  @override
  String get id => 'device.ignoreBatteryOptimization';

  @override
  FixKind get kind => FixKind.system;

  @override
  bool get undoable => false;

  /// The plugin answers through its event channel after the settings page
  /// closes, not through the request's future.
  @override
  Duration get settle => const Duration(seconds: 3);

  @override
  Future<void> apply(RemedyRequest request) => _request();
}

class UpdateSubscriptionRemedy implements Remedy {
  const UpdateSubscriptionRemedy(this._update);

  /// Throws or returns false when the update did not land.
  final Future<bool> Function(int profileId) _update;

  @override
  String get id => 'profile.update';

  @override
  FixKind get kind => FixKind.auto;

  @override
  bool get undoable => false;

  @override
  Duration get settle => const Duration(seconds: 1);

  @override
  Future<void> apply(RemedyRequest request) async {
    final profileId = request.finding?.args['profileId'];
    if (profileId is! int) {
      throw StateError('no profile to update');
    }
    if (!await _update(profileId)) {
      throw StateError('profile $profileId was not updated');
    }
  }
}

/// Opens a system screen; the device sensor reports the result when the user
/// comes back, so verification waits a moment for it.
class SystemScreenRemedy implements Remedy {
  const SystemScreenRemedy(this.id, this._open);

  @override
  final String id;

  /// False when no screen could be opened.
  final Future<bool> Function() _open;

  @override
  FixKind get kind => FixKind.system;

  @override
  bool get undoable => false;

  @override
  Duration get settle => const Duration(seconds: 3);

  @override
  Future<void> apply(RemedyRequest request) async {
    if (!await _open()) throw StateError('$id: no screen to open');
  }
}

class VpnPermissionRemedy implements Remedy {
  const VpnPermissionRemedy(this._request);

  final Future<bool> Function() _request;

  @override
  String get id => 'device.requestVpnPermission';

  @override
  FixKind get kind => FixKind.system;

  @override
  bool get undoable => false;

  @override
  Duration get settle => const Duration(seconds: 3);

  @override
  Future<void> apply(RemedyRequest request) async {
    if (!await _request()) throw StateError('VPN permission refused');
  }
}
