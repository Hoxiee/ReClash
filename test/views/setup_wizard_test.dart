import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/setup/setup.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

class _ExitingSystemAction extends SystemAction {
  static final List<String> calls = [];

  @override
  Future<void> handleExit([bool needSave = true]) async => calls.add('exit');

  @override
  Future<void> handleClose([bool exit = true]) async => calls.add('close');
}

class _RecordingProfilesAction extends ProfilesAction {
  static final List<bool> urlKeepCurrentPage = [];

  @override
  Future<void> addProfileFormURL(
    String url, {
    SubscriptionClient client = SubscriptionClient.auto,
    String? name,
    String customUserAgent = '',
    bool keepCurrentPage = false,
  }) async => urlKeepCurrentPage.add(keepCurrentPage);
}

Future<ProviderContainer> _pump(
  WidgetTester tester, {
  List<Profile> profiles = const [],
  List<Override> overrides = const [],
}) async {
  tester.view.physicalSize = const Size(1000, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final container = ProviderContainer(
    overrides: [
      profilesProvider.overrideWith(() => TestProfiles(profiles)),
      systemActionProvider.overrideWith(_ExitingSystemAction.new),
      ...overrides,
    ],
  );
  globalState.container = container;
  container.read(viewSizeProvider.notifier).value = const Size(1000, 1600);
  addTearDown(container.dispose);
  // Both settings providers are autoDispose; in the app `configProvider` holds
  // them, so the test has to hold them too or a step's write is thrown away.
  container.listen(appSettingProvider, (_, _) {});
  container.listen(smartRoutingSettingProvider, (_, _) {});
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const TestApp(child: SetupWizard()),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

Future<void> _toLegal(WidgetTester tester) async {
  await tester.tap(find.text('Next'));
  await tester.pumpAndSettle();
}

Future<void> _toSubscription(WidgetTester tester) async {
  await _toLegal(tester);
  await tester.tap(find.text('Agree'));
  await tester.pumpAndSettle();
}

Future<void> _toFinish(WidgetTester tester) async {
  await _toSubscription(tester);
  await tester.tap(find.text('Skip'));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    _ExitingSystemAction.calls.clear();
    _RecordingProfilesAction.urlKeepCurrentPage.clear();
  });

  testWidgets('the first step picks a language and applies it at once', (
    tester,
  ) async {
    final container = await _pump(tester);

    expect(find.text('Choose a language'), findsOne);
    await tester.tap(find.text('Russian'));
    await tester.pumpAndSettle();

    expect(container.read(appSettingProvider).locale, 'ru');
  });

  testWidgets('refusing the disclaimer exits without recording consent', (
    tester,
  ) async {
    final container = await _pump(tester);
    await _toLegal(tester);

    await tester.tap(find.text('Exit'));
    await tester.pumpAndSettle();

    expect(_ExitingSystemAction.calls, ['exit']);
    expect(container.read(appSettingProvider).disclaimerAccepted, isFalse);
  });

  testWidgets('agreeing records consent and dismisses the crashlytics tip', (
    tester,
  ) async {
    final container = await _pump(tester);
    await _toSubscription(tester);

    final settings = container.read(appSettingProvider);
    expect(settings.disclaimerAccepted, isTrue);
    expect(settings.crashlyticsTip, isTrue);
    expect(find.text('Add a subscription'), findsOne);
  });

  testWidgets('an empty profile list offers the three ways to add one', (
    tester,
  ) async {
    await _pump(tester);
    await _toSubscription(tester);

    expect(find.text('QR code'), findsOne);
    expect(find.text('File'), findsOne);
    expect(find.text('URL'), findsOne);
    expect(find.text('Skip'), findsOne);
  });

  testWidgets('importing a subscription keeps the wizard on screen', (
    tester,
  ) async {
    await _pump(
      tester,
      overrides: [
        profilesActionProvider.overrideWith(_RecordingProfilesAction.new),
      ],
    );
    await _toSubscription(tester);

    await tester.tap(find.text('URL'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'https://example.com/sub');
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(_RecordingProfilesAction.urlKeepCurrentPage, [true]);
    expect(find.byType(SetupWizard), findsOne);
  });

  testWidgets('the empty step offers restoring from a backup', (tester) async {
    await _pump(tester);
    await _toSubscription(tester);

    expect(find.text('Restore from a backup'), findsOne);
  });

  testWidgets('declining a file after restore leaves the wizard intact', (
    tester,
  ) async {
    await _pump(tester);
    await _toSubscription(tester);

    await tester.tap(find.text('Restore from a backup'));
    await tester.pumpAndSettle();
    expect(find.text('Restore all data'), findsOne);

    await tester.tap(find.text('Restore all data'));
    // The loading overlay's minimum display time is a one-second timer.
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.byType(SetupWizard), findsOne);
    expect(find.text('Restore all data'), findsNothing);
  });

  testWidgets('an added profile replaces the pickers and unlocks Next', (
    tester,
  ) async {
    await _pump(
      tester,
      profiles: const [
        Profile(
          id: 1,
          label: 'Provider',
          autoUpdateDuration: defaultUpdateDuration,
        ),
      ],
    );
    await _toSubscription(tester);

    expect(find.text('QR code'), findsNothing);
    expect(find.text('Provider'), findsOne);
    expect(find.text('Next'), findsOne);
  });

  testWidgets('picking a region writes the preset and turns the engine on', (
    tester,
  ) async {
    final container = await _pump(tester);
    await _toFinish(tester);

    await tester.tap(find.text('Iran'));
    await tester.pumpAndSettle();

    final props = container.read(smartRoutingSettingProvider);
    expect(props.preset, SmartRoutingPreset.iran);
    expect(props.enabled, isTrue);
  });

  testWidgets('leaving the region unpicked leaves the engine off', (
    tester,
  ) async {
    final container = await _pump(tester);
    await _toFinish(tester);

    await tester.tap(find.text('Do not pick'));
    await tester.pumpAndSettle();

    final props = container.read(smartRoutingSettingProvider);
    expect(props.preset, SmartRoutingPreset.off);
    expect(props.enabled, isFalse);
  });

  testWidgets('Done records completion and removes the route', (tester) async {
    final container = await _pump(tester);
    await _toFinish(tester);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(container.read(appSettingProvider).setupCompleted, isTrue);
    expect(find.byType(SetupWizard), findsNothing);
  });

  testWidgets('back on the first step closes the app, not the wizard', (
    tester,
  ) async {
    await _pump(tester);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(_ExitingSystemAction.calls, ['close']);
    expect(find.byType(SetupWizard), findsOne);
  });

  testWidgets('back on a later step goes to the previous one', (tester) async {
    await _pump(tester);
    await _toLegal(tester);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Choose a language'), findsOne);
    expect(_ExitingSystemAction.calls, isEmpty);
  });
}
