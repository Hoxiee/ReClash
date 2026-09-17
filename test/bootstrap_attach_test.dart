import 'package:reclash/bootstrap.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/test_profiles.dart';

class _NoopCoreAction extends CoreAction {
  @override
  void build() {}

  @override
  Future<void> startCore() async {}
}

class _NoopSetupAction extends SetupAction {
  @override
  Future<void> initStatus() async {}
}

class _NoopSystemAction extends SystemAction {
  @override
  Future<void> updateTray() async {}
}

class _NoopProfilesAction extends ProfilesAction {
  @override
  Future<void> autoUpdateProfiles() async {}
}

class _NoopCommonAction extends CommonAction {
  @override
  Future<bool> autoCheckUpdate() async => false;
}

void main() {
  test('bootstrap attach completes without setup, tips or dialogs', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer(
      overrides: [
        appSettingProvider.overrideWithBuild(
          (_, _) => const AppSettingProps(
            setupCompleted: true,
            disclaimerAccepted: true,
          ),
        ),
        coreActionProvider.overrideWith(_NoopCoreAction.new),
        setupActionProvider.overrideWith(_NoopSetupAction.new),
        systemActionProvider.overrideWith(_NoopSystemAction.new),
        profilesActionProvider.overrideWith(_NoopProfilesAction.new),
        commonActionProvider.overrideWith(_NoopCommonAction.new),
        profilesProvider.overrideWith(() => TestProfiles(const [])),
      ],
    );
    addTearDown(container.dispose);
    container.listen(appSettingProvider, (_, _) {});
    globalState.container = container;

    await bootstrap.attach();

    expect(globalState.isAttach, isTrue);
  });
}
