import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:drift/native.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reclash/core/controller.dart';
import 'package:reclash/core/interface.dart';
import 'package:reclash/database/database.dart' as db;
import 'package:reclash/common/common.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/subscriptions/identity/device_identity.dart';
import 'package:reclash/subscriptions/compatibility/client_picker.dart';
import 'package:reclash/subscriptions/compatibility/clients.dart';
import 'package:reclash/subscriptions/compatibility/editor_section.dart';
import 'package:reclash/subscriptions/compatibility/import_policy.dart';
import 'package:reclash/subscriptions/compatibility/import_review.dart';
import 'package:reclash/subscriptions/imports/import.dart';
import 'package:reclash/subscriptions/protocol/codec.dart';
import 'package:reclash/subscriptions/transport/transport.dart';
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
import '../helpers/test_profiles.dart';

class _MockCoreHandler extends Mock implements CoreHandlerInterface {}

final class _ReplacementFile extends PlatformFile {
  _ReplacementFile(this.file);

  final File file;

  @override
  String get name => file.uri.pathSegments.last;

  @override
  Uri get uri => file.uri;

  @override
  XFile get xFile => XFile(file.path);

  @override
  int lengthSync() => file.lengthSync();

  @override
  Future<int> length() => file.length();

  @override
  Future<Uint8List> readAsBytes() => file.readAsBytes();

  @override
  Stream<Uint8List> readAsByteStream() =>
      file.openRead().map(Uint8List.fromList);
}

class _ReplacementPicker extends FilePickerPlatform {
  _ReplacementPicker(this.file);

  final PlatformFile file;

  @override
  Future<PlatformFile?> pickFile({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    int compressionQuality = 0,
    AndroidOptions androidOptions = const AndroidOptions(),
    DarwinOptions darwinOptions = const DarwinOptions(),
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) async => file;
}

class _CompatibilityProfilesAction extends ProfilesAction {
  int updates = 0;
  SubscriptionImportPolicy? acceptedPolicy;

  @override
  Future<SubscriptionClientPreset?> lastSuccessfulProfileClient(
    Profile candidate,
  ) async => null;

  @override
  Future<PreparedSubscriptionUpdate> prepareProfileCompatibility(
    Profile candidate, {
    SubscriptionCancellation? cancellation,
  }) async => PreparedSubscriptionUpdate(
    profileId: candidate.id,
    sourceUrl: candidate.url,
    sourceAgeSecretKey: candidate.ageSecretKey,
    sourcePreferences: candidate.subscriptionPreferences,
    payload: SubscriptionImportResult(
      bytes: Uint8List(0),
      format: SubscriptionFormat.singbox,
      summary: const SubscriptionImportSummary(
        nodes: 2,
        ignoredSections: ['route'],
        hasLosses: true,
      ),
    ),
    metadata: const SubscriptionMetadataResult(
      metadata: SubscriptionMetadata(),
      source: SubscriptionDataSource.http,
    ),
    subscriptionInfo: null,
    snapshot: SubscriptionSnapshot(
      metadata: const SubscriptionMetadata(),
      receivedAt: DateTime.utc(2026),
    ),
    label: candidate.label,
    client: SubscriptionClientPreset.clashMeta,
  );

  @override
  Future<Profile?> updateProfile(
    Profile profile, {
    bool showLoading = false,
    bool allowLossReview = false,
    bool persistProfileSettings = false,
    PreparedSubscriptionUpdate? preparedUpdate,
    SubscriptionImportPolicy? importPolicy,
    bool acceptLosses = false,
    BuildContext? reviewContext,
  }) async {
    expect(preparedUpdate, isNotNull);
    expect(acceptLosses, isTrue);
    expect(persistProfileSettings, isTrue);
    updates++;
    acceptedPolicy = importPolicy;
    return profile;
  }
}

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
    Size size = const Size(1000, 1000),
    ProfilesAction? profilesAction,
    Widget? child,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final container = ProviderContainer(
      overrides: [
        setupActionProvider.overrideWith(() => _NoopSetupAction()),
        if (profilesAction != null) ...[
          profilesProvider.overrideWith(() => TestProfiles([profile])),
          profilesActionProvider.overrideWith(() => profilesAction),
        ],
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
          child:
              child ??
              (details
                  ? const ProfileDetailSheet()
                  : Scaffold(body: EditProfileView(profile: profile))),
        ),
      ),
    );
    await tester.pump();
  }

  group('editor file replacement', () {
    const previousConfig = 'proxies: []\nmode: rule\n';
    const replacementConfig = 'proxies: []\nmode: direct\n';
    late db.Database testDatabase;
    late ProviderContainer container;
    late _MockCoreHandler core;
    late Profile profile;
    late File profileFile;
    late Completer<void> editorClosed;

    setUp(() async {
      final previousDatabase = db.database;
      final previousPicker = FilePickerPlatform.instance;
      testDatabase = db.Database(NativeDatabase.memory());
      db.database = testDatabase;
      profile = _profile(url: '', snapshot: _snapshot()).copyWith(
        lastUpdateDate: DateTime(2025),
        subscriptionInfo: const SubscriptionInfo(download: 10, total: 100),
      );
      await testDatabase.profilesDao.putAll([profile.toCompanion()]);
      profileFile = await profile.file;
      await profileFile.writeAsString(previousConfig);
      final replacement = File('${tempDir.path}/replacement.yaml');
      await replacement.writeAsString(replacementConfig);
      FilePickerPlatform.instance = _ReplacementPicker(
        _ReplacementFile(replacement),
      );
      core = _MockCoreHandler();
      when(() => core.validateConfig(any())).thenAnswer((_) async => '');
      container = ProviderContainer(
        overrides: [
          setupActionProvider.overrideWith(_NoopSetupAction.new),
          coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
        ],
      );
      globalState.container = container;
      editorClosed = Completer<void>();
      addTearDown(() async {
        container.dispose();
        db.database = previousDatabase;
        FilePickerPlatform.instance = previousPicker;
        await testDatabase.close();
      });
      container.listen(profilesProvider, (_, _) {});
      container.listen(currentProfileIdProvider, (_, _) {});
      await container.read(profilesStreamProvider.future);
      container.read(currentProfileIdProvider.notifier).value = profile.id;
    });

    Future<void> uploadReplacement(WidgetTester tester) async {
      const size = Size(1000, 1000);
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      addTearDown(() => tester.pumpWidget(const SizedBox()));
      container.read(viewSizeProvider.notifier).value = size;
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: TestApp(
            withStatusManager: true,
            child: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  await showFormSheet<void>(
                    context: context,
                    builder: (_) => EditProfileView(profile: profile),
                  );
                  editorClosed.complete();
                },
                child: const Text('open file editor'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open file editor'));
      await tester.pumpAndSettle();
      final l10n = currentAppLocalizations;
      final fileRow = find.text(l10n.profile);
      for (
        var attempt = 0;
        attempt < 100 && fileRow.evaluate().isEmpty;
        attempt++
      ) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 10)),
        );
        await tester.pump();
      }
      await tester.longPress(fileRow);
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        await tester.tap(find.text(l10n.upload));
        await pumpEventQueue();
      });
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byWidgetPredicate(
          (widget) =>
              widget is TextField && widget.controller?.text == profile.label,
        ),
        'Edited profile',
      );
      await tester.pump();
    }

    testWidgets('SQL failure preserves the previous file and profile row', (
      tester,
    ) async {
      await tester.runAsync(
        () => testDatabase.customStatement(
          'CREATE TRIGGER reject_profile_update BEFORE UPDATE ON profiles '
          "BEGIN SELECT RAISE(FAIL, 'editor profile write rejected'); END",
        ),
      );
      await uploadReplacement(tester);
      var failed = false;
      final previousPrint = debugPrint;
      debugPrint = (message, {wrapWidth}) {
        previousPrint(message, wrapWidth: wrapWidth);
        failed |= message?.contains('editor profile write rejected') == true;
      };
      try {
        await tester.runAsync(() async {
          await tester.tap(
            find.text(currentAppLocalizations.save).hitTestable(),
          );
          await pumpEventQueue();
        });
        for (var attempt = 0; attempt < 100 && !failed; attempt++) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 10)),
          );
          await tester.pump();
        }
        expect(failed, isTrue);
      } finally {
        debugPrint = previousPrint;
      }
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        expect(await profileFile.readAsString(), previousConfig);
        expect(await testDatabase.profilesDao.get(profile.id), profile);
        expect(container.read(profilesProvider), [profile]);
        expect(container.read(currentProfileIdProvider), profile.id);
        expect(await File('${profileFile.path}.previous').exists(), isFalse);
        expect(await File('${profileFile.path}.staged').exists(), isFalse);
      });
      expect(editorClosed.isCompleted, isFalse);
      expect(find.byType(EditProfileView), findsOneWidget);
      verify(() => core.validateConfig(any())).called(1);
    });

    testWidgets('keeps the editor open until replacement metadata is durable', (
      tester,
    ) async {
      container.read(currentProfileIdProvider.notifier).value = null;
      await uploadReplacement(tester);
      late Completer<void> release;
      late Future<void> blocked;
      await tester.runAsync(() async {
        final entered = Completer<void>();
        release = Completer<void>();
        blocked = testDatabase.transaction(() async {
          entered.complete();
          await release.future;
        });
        await entered.future;
        final published = Completer<void>();
        final subscription = container.listen(profilesProvider, (_, next) {
          if (next.any((item) => item.label == 'Edited profile') &&
              !published.isCompleted) {
            published.complete();
          }
        });
        try {
          await tester.tap(
            find.text(currentAppLocalizations.save).hitTestable(),
          );
          await published.future.timeout(const Duration(seconds: 5));
          await pumpEventQueue();
        } finally {
          subscription.close();
        }
      });
      try {
        await tester.pump();
        expect(editorClosed.isCompleted, isFalse);
        expect(container.read(currentProfileIdProvider), isNull);
      } finally {
        await tester.runAsync(() async {
          release.complete();
          await blocked;
          await pumpEventQueue();
        });
      }
      for (
        var attempt = 0;
        attempt < 100 && !editorClosed.isCompleted;
        attempt++
      ) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 10)),
        );
        await tester.pump();
      }
      expect(editorClosed.isCompleted, isTrue);
      await tester.runAsync(() async {
        final saved = await testDatabase.profilesDao.get(profile.id);
        expect(saved?.label, 'Edited profile');
        expect(saved?.lastUpdateDate, isNot(profile.lastUpdateDate));
        expect(saved?.subscriptionSnapshot, profile.subscriptionSnapshot);
        expect(await profileFile.readAsString(), replacementConfig);
        expect(container.read(currentProfileIdProvider), profile.id);
        expect(await File('${profileFile.path}.previous').exists(), isFalse);
        expect(await File('${profileFile.path}.staged').exists(), isFalse);
      });
      await tester.pumpAndSettle();
      expect(find.byType(EditProfileView), findsNothing);
      verify(() => core.validateConfig(any())).called(1);
    });
  });

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

  for (final size in [const Size(412, 915), const Size(1200, 1000)]) {
    testWidgets(
      'compatibility loss review stays in the sheet at width ${size.width}',
      (tester) async {
        final profile = _profile();
        final actions = _CompatibilityProfilesAction();
        await pumpProfile(
          tester,
          profile,
          size: size,
          profilesAction: actions,
          child: const SizedBox(),
        );
        final destination = GlobalKey<NavigatorState>();
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: globalState.container,
            child: TestApp(
              child: Navigator(
                key: destination,
                onGenerateInitialRoutes: (_, _) => [
                  MaterialPageRoute<void>(
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
                ],
              ),
            ),
          ),
        );
        await tester.runAsync(() async {
          await tester.tap(find.text('open'));
          await tester.pumpAndSettle();
          final store = await DeviceIdentityStore.create();
          await store.globalSendEnabled();
          await store.profileSendOverride(profile.id);
        });
        await tester.pumpAndSettle();
        final l10n = currentAppLocalizations;
        final compatibility = find.text(l10n.subscriptionCompatibilityTitle);
        await tester.ensureVisible(compatibility);
        await tester.pumpAndSettle();
        await tester.tap(compatibility);
        await tester.pumpAndSettle();
        final pageContext = tester.element(
          find.byType(SubscriptionCompatibilityPage),
        );
        final navigator = Navigator.of(pageContext);
        final back = UiLocalizations.of(pageContext).back;
        final check = find.text(l10n.subscriptionCompatibilityCheck);
        await tester.ensureVisible(check);
        await tester.pumpAndSettle();
        await tester.tap(check);
        await tester.pumpAndSettle();

        Future<void> openReview() async {
          final apply = find.text(l10n.subscriptionCompatibilityApplyPrepared);
          await tester.ensureVisible(apply);
          await tester.pumpAndSettle();
          await tester.tap(apply);
          await tester.pumpAndSettle();
          final review = tester.element(
            find.byType(SubscriptionImportReviewPage),
          );
          expect(Navigator.of(review), same(navigator));
          expect(sheetNavigatorOf(review), same(destination.currentState));
          expect(find.byTooltip(back).hitTestable(), findsOneWidget);
        }

        await openReview();
        await tester.tap(find.byTooltip(back).hitTestable());
        await tester.pumpAndSettle();
        expect(find.byType(SubscriptionImportReviewPage), findsNothing);
        expect(find.byType(SubscriptionCompatibilityPage), findsOneWidget);
        expect(actions.updates, 0);
        expect(globalState.container.read(profilesProvider), [profile]);

        await openReview();
        await tester.tap(find.text(l10n.cancel));
        await tester.pumpAndSettle();
        expect(find.byType(SubscriptionCompatibilityPage), findsOneWidget);
        expect(actions.updates, 0);

        await openReview();
        final remember = find.text(l10n.subscriptionImportRememberConsent);
        await tester.ensureVisible(remember);
        await tester.pumpAndSettle();
        await tester.tap(remember);
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10n.subscriptionImportAdd(2)));
        await tester.pumpAndSettle();
        expect(actions.updates, 1);
        expect(
          actions.acceptedPolicy?.scope,
          subscriptionImportScope(profile.url, ''),
        );
        expect(find.byType(SubscriptionImportReviewPage), findsNothing);
        expect(find.byType(NestedPagedSheet), findsNothing);
        expect(find.text('open').hitTestable(), findsOneWidget);
      },
    );
  }

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
