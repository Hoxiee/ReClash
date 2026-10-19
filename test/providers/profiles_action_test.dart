import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

import 'package:reclash/common/common.dart';
import 'package:reclash/core/controller.dart';
import 'package:reclash/core/interface.dart';
import 'package:reclash/subscriptions/compatibility/clients.dart';
import 'package:reclash/subscriptions/compatibility/import_review.dart';
import 'package:reclash/subscriptions/transport/transport.dart';
import 'package:reclash/subscriptions/external_link.dart';
import 'package:reclash/database/database.dart' as db;
import 'package:drift/native.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/action.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/core.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/database.dart';
import 'package:reclash/state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaml/yaml.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../helpers/app_paths.dart';
import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

class _MockCoreHandlerInterface extends Mock implements CoreHandlerInterface {}

class _ImportReviewObserver extends NavigatorObserver {
  final opened = Completer<void>();

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null && !opened.isCompleted) opened.complete();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory home;
  late _MockCoreHandlerInterface core;
  late ProviderContainer container;

  setUpAll(() async {
    await AppLocalizations.load(const Locale('en'));
    globalState.packageInfo = PackageInfo(
      appName: 'ReClash',
      packageName: 'com.reclash',
      version: '1.0.0',
      buildNumber: '1',
    );
    home = Directory.systemTemp.createTempSync('reclash-profiles-action-');
    await useAppPaths(home);
  });

  tearDownAll(() {
    if (home.existsSync()) home.deleteSync(recursive: true);
  });

  setUp(() {
    core = _MockCoreHandlerInterface();
    when(() => core.validateConfig(any())).thenAnswer((_) async => '');
    container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(TestProfiles.new),
        coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
  });

  void decodesTo(String link, List<Map<String, dynamic>> proxies) {
    when(
      () => core.decodeShareLinks([link]),
    ).thenAnswer((_) async => [proxies]);
  }

  Set<String> storedFiles() => {
    for (final entity in home.listSync(recursive: true, followLinks: false))
      if (entity is File) entity.path,
  };

  Future<void> pumpHost(
    WidgetTester tester, {
    Widget child = const SizedBox(),
  }) async {
    const size = Size(1200, 1000);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    container.read(viewSizeProvider.notifier).value = size;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(withStatusManager: true, child: child),
      ),
    );
  }

  Future<List<Map>> savedProxies(Profile profile) async {
    final config = loadYaml(await (await profile.file).readAsString()) as Map;
    return [for (final proxy in config['proxies'] as List) proxy as Map];
  }

  group('addProfileFromLink with a share link', () {
    test('saves a file profile named after the proxy it holds', () async {
      const link = 'vless://id@hk.example.com:443#HK';
      decodesTo(link, [
        {'name': 'HK', 'type': 'vless', 'server': 'hk.example.com'},
      ]);

      await container
          .read(profilesActionProvider.notifier)
          .addProfileFromLink(link);

      final profile = container.read(profilesProvider).single;
      expect(profile.type, ProfileType.file);
      expect(profile.url, isEmpty);
      expect(profile.label, 'HK');
      expect(await savedProxies(profile), [
        {'name': 'HK', 'type': 'vless', 'server': 'hk.example.com'},
      ]);
      verify(() => core.validateConfig(any())).called(1);
    });

    test('names an unnamed proxy after its server', () async {
      const link = 'ss://YWVzLTEyOC1nY206cGFzcw@ss.example.com:8388';
      decodesTo(link, [
        {'name': '', 'type': 'ss', 'server': 'ss.example.com'},
      ]);

      await container
          .read(profilesActionProvider.notifier)
          .addProfileFromLink(link, label: 'Mine');

      final profile = container.read(profilesProvider).single;
      expect(profile.label, 'Mine');
      expect((await savedProxies(profile)).single['name'], 'ss.example.com');
    });

    test('moves a proxy off a name mihomo reserves', () async {
      const link = 'trojan://pass@t.example.com:443#DIRECT';
      decodesTo(link, [
        {'name': 'DIRECT', 'type': 'trojan', 'server': 't.example.com'},
      ]);

      await container
          .read(profilesActionProvider.notifier)
          .addProfileFromLink(link);

      final profile = container.read(profilesProvider).single;
      expect((await savedProxies(profile)).single['name'], 'DIRECT-01');
    });

    testWidgets('reports a link no proxy can be read from and adds nothing', (
      tester,
    ) async {
      const link = 'vmess://not-base64';
      decodesTo(link, const []);
      await pumpHost(tester);

      await container
          .read(profilesActionProvider.notifier)
          .addProfileFromLink(link);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(find.text(currentAppLocalizations.shareLinksInvalid), findsOne);
      expect(container.read(profilesProvider), isEmpty);
      verifyNever(() => core.validateConfig(any()));
    });
  });

  group('addProfileFromLink with a subscription link', () {
    testWidgets('refuses an existing URL with surrounding stored whitespace', (
      tester,
    ) async {
      const url = 'https://sub.example.com/clash.yaml';
      container
          .read(profilesProvider.notifier)
          .put(Profile.normal(label: 'Existing', url: '  $url  '));
      await pumpHost(tester);
      await container
          .read(profilesActionProvider.notifier)
          .addProfileFromLink(url);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(
        find.text(currentAppLocalizations.profileImportDuplicate),
        findsOne,
      );
      expect(container.read(profilesProvider), hasLength(1));
      verifyNever(() => core.validateConfig(any()));
    });

    testWidgets('disabled prevention permits another import of the same URL', (
      tester,
    ) async {
      await pumpHost(tester);
      await tester.runAsync(() async {
        final overrides = HttpOverrides.current;
        HttpOverrides.global = null;
        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
        var downloads = 0;
        server.listen((request) async {
          downloads++;
          request.response.write(
            'proxies:\n  - name: test\n    type: ss\n    server: example.test\n    port: 443\n    cipher: aes-128-gcm\n    password: token\n',
          );
          await request.response.close();
        });
        try {
          final url = 'http://127.0.0.1:${server.port}/profile.yaml';
          container
              .read(profilesProvider.notifier)
              .put(Profile.normal(label: 'Existing', url: url));
          container
              .read(appSettingProvider.notifier)
              .update(
                (value) => value.copyWith(preventDuplicateProfiles: false),
              );
          await container
              .read(profilesActionProvider.notifier)
              .addProfileFromLink(url);
          expect(downloads, 1);
          expect(container.read(profilesProvider), hasLength(2));
          verify(() => core.validateConfig(any())).called(2);
        } finally {
          await server.close(force: true);
          HttpOverrides.global = overrides;
        }
      });
      await tester.pumpAndSettle();
    });

    testWidgets('fixed client preset reaches subscription request headers', (
      tester,
    ) async {
      await pumpHost(tester);
      await tester.runAsync(() async {
        final previousOverrides = HttpOverrides.current;
        HttpOverrides.global = null;
        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
        String? userAgent;
        server.listen((request) async {
          userAgent = request.headers.value(HttpHeaders.userAgentHeader);
          request.response.write(
            'proxies:\n  - name: test\n    type: ss\n    server: example.test\n    port: 443\n    cipher: aes-128-gcm\n    password: token\n',
          );
          await request.response.close();
        });
        try {
          final selected = Profile.normal(label: 'Selected').copyWith(id: 991);
          container.read(profilesProvider.notifier).put(selected);
          final selection = container.listen<int?>(
            currentProfileIdProvider,
            (_, _) {},
          );
          addTearDown(selection.close);
          container.read(currentProfileIdProvider.notifier).value = selected.id;
          await container
              .read(profilesActionProvider.notifier)
              .importProfileFromLink(
                'http://127.0.0.1:${server.port}/profile.yaml',
                ageSecretKey: '',
                select: false,
                clientSettings: const SubscriptionClientSettings(
                  preset: SubscriptionClientPreset.clash,
                ),
              );
          expect(userAgent, 'ClashForAndroid/2.5.12');
          expect(container.read(profilesProvider), hasLength(2));
          expect(container.read(currentProfileIdProvider), selected.id);
        } finally {
          await server.close(force: true);
          HttpOverrides.global = previousOverrides;
        }
      });
    });

    testWidgets('refuses a URL an existing profile already tracks', (
      tester,
    ) async {
      const url = 'https://sub.example.com/clash.yaml';
      container
          .read(profilesProvider.notifier)
          .put(Profile.normal(label: 'Existing', url: url));
      await pumpHost(tester);

      await container
          .read(profilesActionProvider.notifier)
          .addProfileFromLink(url);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(
        find.text(currentAppLocalizations.profileImportDuplicate),
        findsOne,
      );
      expect(container.read(profilesProvider), hasLength(1));
    });
  });

  group('addProfilesFromLinks with share links', () {
    const links = [
      'vless://id@hk.example.com:443#HK',
      'trojan://pass@hk2.example.com:443#HK',
      'ss://YWVzLTEyOC1nY206cGFzcw@ss.example.com:8388',
    ];

    test('makes one profile of all their proxies', () async {
      when(() => core.decodeShareLinks(links)).thenAnswer(
        (_) async => [
          [
            {'name': 'HK', 'type': 'vless', 'server': 'hk.example.com'},
          ],
          [
            {'name': 'HK', 'type': 'trojan', 'server': 'hk2.example.com'},
          ],
          [
            {'name': '', 'type': 'ss', 'server': 'ss.example.com'},
          ],
        ],
      );

      await container
          .read(profilesActionProvider.notifier)
          .addProfilesFromLinks(links);

      final profile = container.read(profilesProvider).single;
      expect(profile.type, ProfileType.file);
      expect(
        profile.label,
        currentAppLocalizations.proxiesProfileLabel('HK', 3),
      );
      expect(
        [for (final proxy in await savedProxies(profile)) proxy['name']],
        ['HK', 'HK-01', 'ss.example.com'],
      );
      verify(() => core.decodeShareLinks(links)).called(1);
    });

    testWidgets('names the link no proxy can be read from and adds nothing', (
      tester,
    ) async {
      when(() => core.decodeShareLinks(links)).thenAnswer(
        (_) async => [
          [
            {'name': 'HK', 'type': 'vless', 'server': 'hk.example.com'},
          ],
          const [],
          [
            {'name': '', 'type': 'ss', 'server': 'ss.example.com'},
          ],
        ],
      );
      await pumpHost(tester);

      await container
          .read(profilesActionProvider.notifier)
          .addProfilesFromLinks(links);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      final l10n = currentAppLocalizations;
      expect(
        find.text(
          l10n.failedItem(
            profileLinkDisplaySource(links.first),
            l10n.shareLinkUnreadable(profileLinkDisplaySource(links[1])),
          ),
        ),
        findsOne,
      );
      expect(container.read(profilesProvider), isEmpty);
      verifyNever(() => core.validateConfig(any()));
    });
  });

  group('external profile link imports', () {
    for (final scheme in ['happ', 'incy']) {
      for (final explicitClient in [false, true]) {
        testWidgets(
          '$scheme retains request metadata with override=$explicitClient',
          (tester) async {
            await pumpHost(tester);
            await tester.runAsync(() async {
              final previousOverrides = HttpOverrides.current;
              HttpOverrides.global = null;
              final server = await HttpServer.bind(
                InternetAddress.loopbackIPv4,
                0,
              );
              final agents = <String?>[];
              server.listen((request) async {
                agents.add(request.headers.value(HttpHeaders.userAgentHeader));
                request.response.write(
                  'proxies:\n  - name: test\n    type: ss\n    server: example.test\n    port: 443\n    cipher: aes-128-gcm\n    password: token\nrules: [MATCH,DIRECT]',
                );
                await request.response.close();
              });
              try {
                final selected = Profile.normal(
                  label: 'Selected',
                ).copyWith(id: 994);
                container.read(profilesProvider.notifier).put(selected);
                final selection = container.listen<int?>(
                  currentProfileIdProvider,
                  (_, _) {},
                );
                addTearDown(selection.close);
                container.read(currentProfileIdProvider.notifier).value =
                    selected.id;
                final url =
                    'http://127.0.0.1:${server.port}/private?token=secret';
                final source = await resolveProfileLink(
                  '$scheme://add/${Uri.encodeComponent(url)}?name=Home',
                );
                final chosen = explicitClient
                    ? SubscriptionClientPreset.clash
                    : scheme == 'happ'
                    ? SubscriptionClientPreset.happ
                    : SubscriptionClientPreset.incy;
                final profile = await container
                    .read(profilesActionProvider.notifier)
                    .importProfileLinkSource(
                      source,
                      select: false,
                      clientSettings: explicitClient
                          ? const SubscriptionClientSettings(
                              preset: SubscriptionClientPreset.clash,
                            )
                          : const SubscriptionClientSettings.forNewProfile(),
                    );
                expect(agents, [
                  subscriptionClientRequestHeaders(
                    chosen,
                    defaultUserAgent: 'ReClash',
                  )['User-Agent'],
                ]);
                expect(profile.label, 'Home');
                expect(profile.url, url);
                expect(profile.subscriptionPreferences.client.preset, chosen);
                expect((await profile.file).existsSync(), isTrue);
                expect(container.read(profilesProvider), hasLength(2));
                expect(container.read(currentProfileIdProvider), selected.id);
              } finally {
                await server.close(force: true);
                HttpOverrides.global = previousOverrides;
              }
            });
          },
        );
      }
    }

    for (final explicitLabel in [false, true]) {
      test(
        'embedded imports preserve names with override=$explicitLabel',
        () async {
          const content = 'proxies: []\nrules: [MATCH,DIRECT]';
          final link = await buildUrlSchemeLink(
            ReClashCommand.importProfile,
            payload: content,
            name: 'Дом 🦊',
          );
          final profile = await container
              .read(profilesActionProvider.notifier)
              .importProfileFromLink(
                link,
                label: explicitLabel ? 'Mine' : null,
                ageSecretKey: '',
                select: false,
              );
          expect(profile.label, explicitLabel ? 'Mine' : 'Дом 🦊');
          expect(profile.type, ProfileType.file);
          expect(await (await profile.file).readAsString(), content);
          expect(container.read(profilesProvider).single, profile);
          verify(() => core.validateConfig(any())).called(1);
          verifyNever(() => core.decodeShareLinks(any()));
        },
      );
    }

    test('prepared opaque share payload reaches the Core unchanged', () async {
      const link = 'vmess://AbCdEFGh+/==';
      decodesTo(link, [
        {'name': 'Decoded', 'type': 'vmess', 'server': 'node.test'},
      ]);
      final source = await resolveProfileLink(link);
      final profile = await container
          .read(profilesActionProvider.notifier)
          .importProfileLinkSource(source, label: 'Mine', select: false);
      expect(profile.label, 'Mine');
      expect((await savedProxies(profile)).single['name'], 'Decoded');
      verify(() => core.decodeShareLinks([link])).called(1);
    });

    test('wrapped subscriptions reuse duplicate prevention', () async {
      const url = 'https://example.com/private?token=secret';
      container
          .read(profilesProvider.notifier)
          .put(Profile.normal(label: 'Existing', url: url));
      final source = await resolveProfileLink(
        'happ://add/${Uri.encodeComponent(url)}?name=Home',
      );
      await expectLater(
        container
            .read(profilesActionProvider.notifier)
            .importProfileLinkSource(source, select: false),
        throwsA(
          isA<MessageException>().having(
            (error) => error.message,
            'message',
            currentAppLocalizations.profileImportDuplicate,
          ),
        ),
      );
      expect(container.read(profilesProvider), hasLength(1));
      verifyNever(() => core.validateConfig(any()));
    });

    test('a cancelled prepared share source never reaches the Core', () async {
      final cancellation = SubscriptionCancellation()..cancel();
      await expectLater(
        container
            .read(profilesActionProvider.notifier)
            .importProfileLinkSource(
              const ProfileLinkSource(shareLink: 'vless://id@node.test:443'),
              cancellation: cancellation,
            ),
        throwsA(isA<SubscriptionUpdateCancelled>()),
      );
      expect(container.read(profilesProvider), isEmpty);
      verifyNever(() => core.decodeShareLinks(any()));
      verifyNever(() => core.validateConfig(any()));
    });
  });

  group('silent profile imports', () {
    test('imports data without selecting the profile', () async {
      final selected = Profile.normal(label: 'Selected').copyWith(id: 987);
      container.read(profilesProvider.notifier).put(selected);
      final selection = container.listen<int?>(
        currentProfileIdProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(selection.close);
      container.read(currentProfileIdProvider.notifier).value = selected.id;

      final profile = await container
          .read(profilesActionProvider.notifier)
          .importProfileData(
            'proxies: []'.codeUnits,
            name: 'Wizard import',
            select: false,
          );

      expect(profile, isNotNull);
      expect(container.read(profilesProvider).getProfile(profile!.id), profile);
      expect(container.read(currentProfileIdProvider), selected.id);
      verify(() => core.validateConfig(any())).called(1);
    });

    for (final accept in [false, true]) {
      testWidgets(
        accept
            ? 'accepted conversion saves on the wizard navigator without selecting'
            : 'rejected conversion preserves the wizard and stored files',
        (tester) async {
          const content =
              '{"inbounds":[{"port":1080}],"dns":{"servers":["1.1.1.1"]},'
              '"outbounds":[{"tag":"edge","protocol":"vless",'
              '"settings":{"vnext":[{"address":"edge.example","port":443,'
              '"users":[{"id":"11111111-1111-4111-8111-111111111111",'
              '"encryption":"none"}]}]},"streamSettings":{"network":"tcp"}}]}';
          final selected = Profile.normal(label: 'Selected').copyWith(id: 988);
          container.read(profilesProvider.notifier).put(selected);
          final selection = container.listen<int?>(
            currentProfileIdProvider,
            (_, _) {},
          );
          addTearDown(selection.close);
          container.read(currentProfileIdProvider.notifier).value = selected.id;
          final navigatorKey = GlobalKey<NavigatorState>();
          final observer = _ImportReviewObserver();
          late BuildContext reviewContext;
          await pumpHost(
            tester,
            child: Navigator(
              key: navigatorKey,
              observers: [observer],
              onGenerateRoute: (_) => MaterialPageRoute<void>(
                builder: (context) {
                  reviewContext = context;
                  return const Scaffold(body: Text('Wizard import route'));
                },
              ),
            ),
          );
          final filesBefore = storedFiles();
          late Future<Profile?> pending;
          await tester.runAsync(() async {
            pending = container
                .read(profilesActionProvider.notifier)
                .importProfileLinkSource(
                  ProfileLinkSource(
                    bytes: Uint8List.fromList(utf8.encode(content)),
                    name: 'Converted import',
                  ),
                  select: false,
                  reviewContext: reviewContext,
                );
          });
          for (
            var attempt = 0;
            attempt < 100 && !observer.opened.isCompleted;
            attempt++
          ) {
            await tester.runAsync(
              () => Future<void>.delayed(const Duration(milliseconds: 10)),
            );
            await tester.pump();
          }
          expect(observer.opened.isCompleted, isTrue);
          await tester.pumpAndSettle();

          expect(find.byType(SubscriptionImportReviewPage), findsOneWidget);
          expect(navigatorKey.currentState!.canPop(), isTrue);
          expect(globalState.navigatorKey.currentState!.canPop(), isFalse);
          expect(container.read(profilesProvider), [selected]);
          expect(storedFiles(), filesBefore);
          final l10n = currentAppLocalizations;
          if (accept) {
            final confirmation = find.widgetWithText(
              TextButton,
              l10n.subscriptionImportAccept,
            );
            expect(tester.widget<TextButton>(confirmation).onPressed, isNull);
            await tester.tap(find.text(l10n.subscriptionImportAcceptSections));
            await tester.pumpAndSettle();
            await tester.tap(confirmation);
          } else {
            await tester.tap(find.widgetWithText(TextButton, l10n.cancel));
          }
          await tester.pumpAndSettle();
          await tester.runAsync(() async {
            if (accept) {
              final profile = await pending;
              expect(profile, isNotNull);
              expect(
                container.read(profilesProvider).getProfile(profile!.id),
                profile,
              );
              expect((await savedProxies(profile)).single['name'], 'edge');
              expect((await profile.file).existsSync(), isTrue);
              verify(() => core.validateConfig(any())).called(1);
            } else {
              await expectLater(
                pending,
                throwsA(isA<SubscriptionUpdateCancelled>()),
              );
              expect(container.read(profilesProvider), [selected]);
              expect(storedFiles(), filesBefore);
              verifyNever(() => core.validateConfig(any()));
            }
          });
          expect(container.read(currentProfileIdProvider), selected.id);
          expect(navigatorKey.currentState!.canPop(), isFalse);
          expect(find.text('Wizard import route'), findsOneWidget);
          expect(find.byType(SubscriptionImportReviewPage), findsNothing);
        },
      );
    }

    testWidgets('database write failure rolls back without a notifier', (
      tester,
    ) async {
      final previousDatabase = db.database;
      final brokenDatabase = db.Database(NativeDatabase.memory());
      db.database = brokenDatabase;
      await tester.runAsync(
        () => brokenDatabase.customStatement(
          'CREATE TRIGGER reject_profile_insert BEFORE INSERT ON profiles '
          "BEGIN SELECT RAISE(FAIL, 'profile table write rejected'); END",
        ),
      );
      container = ProviderContainer(
        overrides: [
          coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
        ],
      );
      addTearDown(() async {
        container.dispose();
        db.database = previousDatabase;
        await tester.runAsync(() => brokenDatabase.close());
      });
      globalState.container = container;
      final selection = container.listen<int?>(
        currentProfileIdProvider,
        (_, _) {},
      );
      container.read(currentProfileIdProvider.notifier).value = 987;
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const TestApp(withStatusManager: true, child: SizedBox()),
        ),
      );
      await tester.pump();
      final filesBefore = storedFiles();
      await tester.runAsync(
        () => expectLater(
          container
              .read(profilesActionProvider.notifier)
              .importProfileLinkSource(
                ProfileLinkSource(
                  bytes: Uint8List.fromList(utf8.encode('proxies: []')),
                  name: 'Wizard import',
                ),
                select: false,
              ),
          throwsA(anything),
        ),
      );
      await tester.pump();
      expect(container.read(profilesProvider), isEmpty);
      expect(storedFiles(), filesBefore);
      expect(container.read(currentProfileIdProvider), 987);
      expect(
        find.text(currentAppLocalizations.databaseWriteFailedTip),
        findsNothing,
      );
      await tester.pumpWidget(const SizedBox.shrink());
      selection.close();
      await tester.pump();
    });

    test('cancellation during validation prevents profile commit', () async {
      final validation = Completer<String>();
      final validationStarted = Completer<void>();
      when(() => core.validateConfig(any())).thenAnswer((_) {
        validationStarted.complete();
        return validation.future;
      });
      final filesBefore = storedFiles();
      final cancellation = SubscriptionCancellation();
      final pending = container
          .read(profilesActionProvider.notifier)
          .importProfileLinkSource(
            ProfileLinkSource(
              bytes: Uint8List.fromList(utf8.encode('proxies: []')),
              name: 'Cancelled import',
            ),
            select: false,
            cancellation: cancellation,
          );
      await validationStarted.future;
      cancellation.cancel();
      validation.complete('');
      await expectLater(pending, throwsA(isA<SubscriptionUpdateSuperseded>()));
      expect(container.read(profilesProvider), isEmpty);
      expect(storedFiles(), filesBefore);
      verify(() => core.validateConfig(any())).called(1);
    });

    test('propagates encrypted-file age-key requests', () async {
      await expectLater(
        container
            .read(profilesActionProvider.notifier)
            .importProfileLinkSource(
              ProfileLinkSource(
                bytes: Uint8List.fromList(
                  utf8.encode('-----BEGIN AGE ENCRYPTED FILE-----'),
                ),
                name: 'Encrypted import',
              ),
              select: false,
            ),
        throwsA(isA<AgeSecretKeyRequiredException>()),
      );
      expect(container.read(profilesProvider), isEmpty);
      verifyNever(() => core.validateConfig(any()));
    });

    test('returns and selects an imported share-link profile', () async {
      const link = 'vless://id@hk.example.com:443#HK';
      decodesTo(link, [
        {'name': 'HK', 'type': 'vless', 'server': 'hk.example.com'},
      ]);

      final profile = await container
          .read(profilesActionProvider.notifier)
          .importProfileFromLink(link, ageSecretKey: '');

      expect(profile.label, 'HK');
      expect(container.read(profilesProvider).single, profile);
      expect(container.read(currentProfileIdProvider), profile.id);
      verify(() => core.validateConfig(any())).called(1);
    });

    test(
      'propagates duplicate subscription errors without adding a profile',
      () async {
        const url = 'https://sub.example.com/clash.yaml';
        container
            .read(profilesProvider.notifier)
            .put(Profile.normal(label: 'Existing', url: url));

        await expectLater(
          container
              .read(profilesActionProvider.notifier)
              .importProfileFromLink(url, ageSecretKey: ''),
          throwsA(
            isA<MessageException>().having(
              (error) => error.message,
              'message',
              currentAppLocalizations.profileImportDuplicate,
            ),
          ),
        );
        expect(container.read(profilesProvider), hasLength(1));
        verifyNever(() => core.validateConfig(any()));
      },
    );
  });
}
