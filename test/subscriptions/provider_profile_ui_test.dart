import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/subscriptions/identity/device_identity.dart';
import 'package:reclash/subscriptions/compatibility/client_picker.dart';
import 'package:reclash/subscriptions/compatibility/clients.dart';
import 'package:reclash/subscriptions/compatibility/editor_section.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/subscriptions/metadata/metadata.dart';
import 'package:reclash/views/dashboard/widgets/profile_detail.dart';
import 'package:reclash/views/config/general.dart';
import 'package:reclash/views/profiles/edit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../helpers/app_paths.dart';
import '../helpers/test_app.dart';

class _NoopSetupAction extends SetupAction {
  @override
  void autoApplyProfile() {}
}

class _IdentityPolicyHarness extends StatefulWidget {
  const _IdentityPolicyHarness();

  @override
  State<_IdentityPolicyHarness> createState() => _IdentityPolicyHarnessState();
}

class _IdentityPolicyHarnessState extends State<_IdentityPolicyHarness> {
  bool? _override;

  @override
  Widget build(BuildContext context) {
    final l10n = context.appLocalizations;
    return Scaffold(
      body: ListItem<bool?>.options(
        title: Text(l10n.subscriptionIdentityTitle),
        options: const [null, true, false],
        value: _override,
        textBuilder: (value) => switch (value) {
          null => l10n.subscriptionIdentityUseGlobal,
          true => l10n.enabled,
          false => l10n.disabled,
        },
        onChanged: (value) => setState(() => _override = value),
      ),
    );
  }
}

Profile _profile({
  String url = 'https://subs.example.test/feed',
  int id = 12,
  SubscriptionSnapshot? snapshot,
}) => Profile.normal(
  label: 'Test profile',
  url: url,
).copyWith(id: id, subscriptionSnapshot: snapshot);

SubscriptionSnapshot _snapshot({bool hideUrl = false, bool stale = false}) =>
    SubscriptionSnapshot(
      metadata: SubscriptionMetadata({
        'provider.name': 'Example provider',
        'account.title': 'Premium account',
        'provider.webUrl': 'https://provider.example.test',
        'provider.supportUrl': 'https://support.example.test/help',
        'provider.buyPlanUrl': 'https://provider.example.test/plans',
        'provider.buyTrafficUrl': 'https://provider.example.test/traffic',
        'presentation.hideUrl': hideUrl,
      }),
      receivedAt: DateTime.utc(2025),
      stale: stale,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('provider_profile_ui');
    await useAppPaths(tempDir);
    globalState.packageInfo = PackageInfo(
      appName: 'ReClash',
      packageName: 'com.reclash',
      version: '1.0.0',
      buildNumber: '1',
    );
    await AppLocalizations.load(const Locale('en'));
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  Future<void> pumpProfile(
    WidgetTester tester,
    Profile profile, {
    bool details = false,
  }) async {
    const size = Size(1000, 1000);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final container = ProviderContainer(
      overrides: [
        setupActionProvider.overrideWith(() => _NoopSetupAction()),
        currentProfileProvider.overrideWithValue(profile),
        groupsProvider.overrideWithValue([]),
        providersProvider.overrideWithValue([]),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(() async => tester.pumpWidget(const SizedBox()));
    globalState.container = container;
    container.read(viewSizeProvider.notifier).value = size;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: details
              ? const ProfileDetailSheet()
              : Scaffold(body: EditProfileView(profile: profile)),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('stale metadata still shows provider, account, and links', (
    tester,
  ) async {
    final profile = _profile(snapshot: _snapshot(stale: true));
    await pumpProfile(tester, profile, details: true);

    expect(find.text('Example provider'), findsOneWidget);
    expect(find.text('Premium account'), findsOneWidget);
    expect(find.text('provider.example.test'), findsNWidgets(3));
    expect(find.text('support.example.test'), findsOneWidget);
    expect(
      find.text(currentAppLocalizations.subscriptionProviderWebsite),
      findsOneWidget,
    );
    expect(
      find.text(currentAppLocalizations.subscriptionProviderSupport),
      findsOneWidget,
    );
    expect(
      find.text(currentAppLocalizations.subscriptionProviderBuyPlan),
      findsOneWidget,
    );
    expect(
      find.text(currentAppLocalizations.subscriptionProviderBuyTraffic),
      findsOneWidget,
    );
  });

  testWidgets('hideUrl does not prevent editing the subscription URL', (
    tester,
  ) async {
    final profile = _profile(snapshot: _snapshot(hideUrl: true));
    await pumpProfile(tester, profile);
    await tester.pump();

    final urlField = find.byWidgetPredicate(
      (widget) => widget is TextField && widget.controller?.text == profile.url,
    );
    expect(urlField, findsOneWidget);
    final controller = tester.widget<TextField>(urlField).controller;
    final editableUrl = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && identical(widget.controller, controller),
    );
    expect(tester.widget<TextField>(editableUrl).obscureText, isTrue);
    await tester.enterText(editableUrl, 'https://new.example.test/feed');
    expect(controller!.text, 'https://new.example.test/feed');
    await tester.tap(
      find.byTooltip(currentAppLocalizations.subscriptionCompatibilityShowUrl),
    );
    await tester.pump();
    expect(tester.widget<TextField>(editableUrl).obscureText, isFalse);
    await tester.tap(
      find.byTooltip(currentAppLocalizations.subscriptionCompatibilityHideUrl),
    );
    await tester.pump();
    expect(tester.widget<TextField>(editableUrl).obscureText, isTrue);
  });

  testWidgets('compatibility opens inside the edit sheet and returns to it', (
    tester,
  ) async {
    final profile = _profile();
    await pumpProfile(tester, profile);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: globalState.container,
        child: TestApp(
          child: Builder(
            builder: (context) => TextButton(
              onPressed: () => showSheet<void>(
                context: context,
                props: nestedPagedSheetProps,
                builder: (_) => NestedPagedSheet(
                  builder: (_) => EditProfileView(profile: profile),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.text(currentAppLocalizations.subscriptionCompatibilityTitle),
    );
    await tester.pumpAndSettle();
    expect(find.byType(SubscriptionCompatibilityPage), findsOneWidget);
    expect(find.byType(NestedPagedSheet), findsOneWidget);

    await tester.tap(
      find
          .byTooltip(
            UiLocalizations.of(
              tester.element(find.byType(NestedPagedSheet)),
            ).back,
          )
          .last,
    );
    await tester.pumpAndSettle();
    expect(find.byType(SubscriptionCompatibilityPage), findsNothing);
    expect(find.byType(EditProfileView), findsOneWidget);
  });

  testWidgets('request-as uses the standard options row', (tester) async {
    await tester.pumpWidget(
      TestApp(
        child: Scaffold(
          body: generateSection(
            items: [
              SubscriptionClientPresetRow(
                value: SubscriptionClientPreset.auto,
                onChanged: (_) {},
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final row = find.byType(DecorationListItem);
    final popup = find.byType(CommonPopupBox);
    final rowBounds = tester.getRect(row);
    final popupBounds = tester.getRect(popup);
    expect(popupBounds.left, greaterThan(rowBounds.left + rowBounds.width / 2));
    expect(popupBounds.width, lessThan(rowBounds.width / 2));

    await tester.tap(
      find.text(currentAppLocalizations.subscriptionClientRequestAs),
    );
    await tester.pumpAndSettle();
    expect(
      find.text(currentAppLocalizations.subscriptionClientClashMeta),
      findsOneWidget,
    );
  });

  testWidgets('global identity setting persists device-local opt-in', (
    tester,
  ) async {
    const size = Size(1000, 1000);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final container = ProviderContainer();
    addTearDown(container.dispose);
    addTearDown(() async => tester.pumpWidget(const SizedBox()));
    globalState.container = container;
    container.read(viewSizeProvider.notifier).value = size;
    await tester.runAsync(() async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const TestApp(child: GeneralView()),
        ),
      );
      final store = await DeviceIdentityStore.create();
      await store.globalSendEnabled();
    });
    await tester.pumpAndSettle();

    final row = find.ancestor(
      of: find.text(currentAppLocalizations.subscriptionIdentityTitle),
      matching: find.byType(ListItem),
    );
    final toggle = find.descendant(
      of: row,
      matching: find.byType(CommonSwitch),
    );
    expect(tester.widget<CommonSwitch>(toggle).onChanged, isNotNull);
    expect(tester.widget<CommonSwitch>(toggle).value, isFalse);
    final title = find.text(currentAppLocalizations.subscriptionIdentityTitle);
    await tester.ensureVisible(title);
    await tester.pumpAndSettle();
    expect(title.hitTestable(), findsOneWidget);
    await tester.runAsync(() async {
      await tester.tap(title);
      final store = await DeviceIdentityStore.create();
      await store.globalSendEnabled();
    });
    final store = DeviceIdentityStore(
      storage: FileDeviceIdentityStorage(
        File('${tempDir.path}/${FileDeviceIdentityStorage.fileName}'),
      ),
      source: () async => null,
    );
    expect(await tester.runAsync(store.globalSendEnabled), isTrue);
    await tester.pumpAndSettle();
    expect(tester.widget<CommonSwitch>(toggle).value, isTrue);
  });

  testWidgets('profile identity policy offers global and local choices', (
    tester,
  ) async {
    await tester.pumpWidget(const TestApp(child: _IdentityPolicyHarness()));
    await tester.pumpAndSettle();

    expect(
      find.text(currentAppLocalizations.subscriptionIdentityUseGlobal),
      findsOneWidget,
    );
    await tester.tap(
      find.text(currentAppLocalizations.subscriptionIdentityTitle),
    );
    await tester.pumpAndSettle();
    expect(
      find.text(currentAppLocalizations.subscriptionIdentityUseGlobal),
      findsNWidgets(2),
    );
    expect(find.text(currentAppLocalizations.enabled), findsOneWidget);
    expect(find.text(currentAppLocalizations.disabled), findsOneWidget);

    await tester.tap(find.text(currentAppLocalizations.enabled));
    await tester.pumpAndSettle();
    expect(find.text(currentAppLocalizations.enabled), findsOneWidget);
  });
}
