import 'dart:convert';
import 'dart:io';

import 'package:reclash/common/common.dart';
import 'package:reclash/common/update.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/providers/action.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/state.dart';
import 'package:reclash/widgets/update_sheet.dart';
import 'package:reclash/common/app_update_state.dart';
import 'package:reclash/providers/app_update.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../helpers/test_app.dart';
import '../helpers/test_update_runtime.dart';

const _runningVersion = '0.8.95';

const _payload =
    '{"schemaVersion":2,"versions":[{"version":"0.8.96","tag":"v0.8.96",'
    '"date":"2026-08-16","prerelease":false,"groups":['
    '{"type":"breaking","entries":[{"id":"af20769","text":'
    '"Re-import backups"}]},'
    '{"type":"feat","entries":[{"id":"1a2b3c4","text":'
    '"Override scripts"}]}]}]}';

const _bulletsOnly =
    '<!-- reclash:changelog:begin -->\n'
    '- Override scripts\n'
    '<!-- reclash:changelog:end -->\n';

String _bodyWith(String payload) =>
    '$_bulletsOnly\n<!-- reclash:changelog:json\n$payload\n-->\n';

class _UpdateSource implements AppUpdateSource {
  const _UpdateSource();

  @override
  String get id => 'test';

  @override
  Future<List<Map<String, dynamic>>> fetchReleases({
    required UpdateChannel channel,
  }) async {
    return const [];
  }

  @override
  Uri releasePage(String tag) => Uri.https('updates.example', '/$tag');

  @override
  Uri assetUri(String url) => Uri.parse(url);
}

AppUpdateRelease release(String? body) => AppUpdateRelease(
  data: <String, dynamic>{'tag_name': 'v0.8.96', 'body': body},
  source: const _UpdateSource(),
);

Future<ProviderContainer> pumpApp(WidgetTester tester, {Locale? locale}) async {
  final runtime = TestUpdateRuntime(Directory.systemTemp)..enabled = false;
  addTearDown(runtime.dispose);
  final container = ProviderContainer(
    overrides: [appUpdateRuntimeProvider.overrideWithValue(runtime)],
  );
  addTearDown(container.dispose);
  globalState.container = container;
  // appSettingProvider is autoDispose; in the app `configProvider` keeps it
  // alive, so the test has to hold a listener or edits are dropped.
  container.listen(appSettingProvider, (_, _) {}, fireImmediately: true);
  container
      .read(viewSizeProvider.notifier)
      .update((_) => tester.view.physicalSize / tester.view.devicePixelRatio);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: TestApp(
        locale: locale,
        child: const Scaffold(body: SizedBox.shrink()),
      ),
    ),
  );
  await tester.pump();
  return container;
}

Future<void> tapCancel(WidgetTester tester) async {
  await tester.tap(find.byTooltip(currentAppLocalizations.close));
  await tester.pumpAndSettle();
}

Future<void> _showOffer(
  BuildContext context, {
  required AppUpdateRelease release,
}) async {
  final container = ProviderScope.containerOf(context);
  await container.read(appUpdateActionProvider.notifier).offer(release);
  if (context.mounted) await UpdateSheet.show(context);
}

void main() {
  late String previousAppEnv;

  setUp(() {
    previousAppEnv = globalState.appEnv;
    globalState.appEnv = 'stable';
  });

  tearDown(() {
    globalState.appEnv = previousAppEnv;
  });

  setUpAll(() {
    globalState.packageInfo = PackageInfo(
      appName: 'ReClash',
      packageName: 'com.reclash',
      version: _runningVersion,
      buildNumber: '1',
    );
  });

  testWidgets('renders the grouped notes carried by the release', (
    tester,
  ) async {
    final container = await pumpApp(tester);

    final shown = container
        .read(commonActionProvider.notifier)
        .checkUpdateResultHandle(
          data: release(_bodyWith(_payload)),
          isUser: true,
        );
    await tester.pumpAndSettle();

    expect(find.textContaining('v0.8.96'), findsOneWidget);
    expect(find.textContaining('Re-import backups'), findsOneWidget);
    expect(find.textContaining('Override scripts'), findsOneWidget);
    expect(find.textContaining('Breaking changes'), findsOneWidget);

    await tapCancel(tester);
    await shown;
  });

  testWidgets('localizes the group titles but not the entries', (tester) async {
    final container = await pumpApp(tester, locale: const Locale('zh', 'CN'));

    final shown = container
        .read(commonActionProvider.notifier)
        .checkUpdateResultHandle(
          data: release(_bodyWith(_payload)),
          isUser: true,
        );
    await tester.pumpAndSettle();

    // Entry copy comes from the release payload and is English only; the group
    // headings still follow the app locale.
    expect(find.textContaining('新功能'), findsOneWidget);
    expect(find.textContaining('Override scripts'), findsOneWidget);

    await tapCancel(tester);
    await shown;
  });

  testWidgets('falls back to the bullets of a release without a payload', (
    tester,
  ) async {
    final container = await pumpApp(tester);

    final shown = container
        .read(commonActionProvider.notifier)
        .checkUpdateResultHandle(data: release(_bulletsOnly), isUser: true);
    await tester.pumpAndSettle();

    expect(find.textContaining('Override scripts'), findsOneWidget);

    await tapCancel(tester);
    await shown;
  });

  testWidgets('automatic checks publish an offer without opening a sheet', (
    tester,
  ) async {
    final container = await pumpApp(tester);
    await container
        .read(commonActionProvider.notifier)
        .checkUpdateResultHandle(data: release(_bodyWith(_payload)));
    await tester.pumpAndSettle();
    expect(find.byType(UpdateSheet), findsNothing);
    expect(container.read(appUpdateActionProvider).phase, UpdatePhase.offered);
    expect(container.read(appSettingProvider).autoCheckUpdate, isTrue);
  });

  testWidgets('dismissal does not disable future update checks', (
    tester,
  ) async {
    final container = await pumpApp(tester);
    final shown = container
        .read(commonActionProvider.notifier)
        .checkUpdateResultHandle(
          data: release(_bodyWith(_payload)),
          isUser: true,
        );
    await tester.pumpAndSettle();
    await tapCancel(tester);
    await shown;
    expect(container.read(appSettingProvider).autoCheckUpdate, isTrue);
    expect(container.read(appUpdateActionProvider).hasUpdate, isTrue);
  });

  testWidgets('a failed manual request is not reported as up to date', (
    tester,
  ) async {
    final container = await pumpApp(tester);
    final runtime =
        container.read(appUpdateRuntimeProvider) as TestUpdateRuntime;
    runtime.checkFailure = const FormatException('offline');

    final checking = container
        .read(commonActionProvider.notifier)
        .checkForUpdates();
    await tester.pumpAndSettle();

    expect(
      find.textContaining(currentAppLocalizations.updateCheckFailed),
      findsOneWidget,
    );
    expect(
      find.textContaining(currentAppLocalizations.updateNoUpdates),
      findsNothing,
    );

    await tapCancel(tester);
    await checking;
  });

  testWidgets('a manual check keeps the setting and reports no update', (
    tester,
  ) async {
    final container = await pumpApp(tester);

    final shown = container
        .read(commonActionProvider.notifier)
        .checkUpdateResultHandle(isUser: true);
    await tester.pumpAndSettle();

    expect(
      find.text(currentAppLocalizations.updateCurrentTitle),
      findsOneWidget,
    );
    expect(find.textContaining('latest version'), findsOneWidget);

    await tapCancel(tester);
    await shown;
    expect(container.read(appSettingProvider).autoCheckUpdate, isTrue);
  });

  testWidgets('fits the update offer on a phone-width surface', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final container = await pumpApp(tester);
    final shown = container
        .read(commonActionProvider.notifier)
        .checkUpdateResultHandle(
          data: release(
            '## Changes\n\n'
            '- A long release note that wraps without pushing the actions offscreen\n'
            '- A second useful fix\n'
            '- A third useful fix\n'
            '- A fourth useful fix',
          ),
          isUser: true,
        );
    await tester.pumpAndSettle();

    expect(find.text(currentAppLocalizations.goDownload), findsOneWidget);
    expect(find.text('Changes'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tapCancel(tester);
    await shown;
  });

  testWidgets('filters download boilerplate from release notes', (
    tester,
  ) async {
    final container = await pumpApp(tester);
    final shown = container
        .read(commonActionProvider.notifier)
        .checkUpdateResultHandle(
          data: release(
            '## Changes\n\n- Fixed *routing*\n\n'
            '## Downloads\n\n- Android APK\n'
            '<table><tr><td>mirror</td></tr></table>',
          ),
          isUser: true,
        );
    await tester.pumpAndSettle();

    expect(find.textContaining('Fixed'), findsOneWidget);
    expect(find.textContaining('Android APK'), findsNothing);
    expect(find.textContaining('mirror'), findsNothing);

    await tapCancel(tester);
    await shown;
  });

  testWidgets('renders basic Markdown release notes', (tester) async {
    final container = await pumpApp(tester);
    final shown = container
        .read(commonActionProvider.notifier)
        .checkUpdateResultHandle(
          data: release(
            '## Highlights\n\n- **Fast** routing\n\nUse `safe mode`.',
          ),
          isUser: true,
        );
    await tester.pumpAndSettle();

    expect(find.text('Highlights'), findsOneWidget);
    expect(find.textContaining('Fast'), findsOneWidget);
    expect(find.textContaining('safe mode'), findsOneWidget);

    await tapCancel(tester);
    await shown;
  });

  testWidgets('presents alpha warnings without GitHub download chrome', (
    tester,
  ) async {
    await pumpApp(tester);
    final shown = _showOffer(
      tester.element(find.byType(Scaffold)),
      release: release(
        '> [!WARNING]\n'
        '> **Pre-release — for personal testing only.** Stability is still poor.\n\n'
        'Third ReClash pre-release.\n\n'
        "## What's new since pre.2\n\n"
        '- In-app updates: the client finds new builds.\n\n'
        '## Fixes since pre.2\n\n'
        '- Layout: resizing keeps dialogs open.\n\n'
        '## Notice\n\n'
        'Subscription compatibility is unchanged.\n\n'
        '<div align="center">\n\n'
        '[![Downloads](https://img.shields.io/badge/downloads)](https://example.com)\n\n'
        '**Grab the build for your operating system.**\n\n'
        '</div>\n\n'
        '| OS | Packages |\n| Linux | AppImage |\n',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('for personal testing only'), findsOneWidget);
    expect(find.textContaining('[!WARNING]'), findsNothing);
    expect(find.textContaining('In-app updates:'), findsOneWidget);
    expect(find.textContaining('Grab the build'), findsNothing);
    expect(find.textContaining('AppImage'), findsNothing);
    final expand = find.byKey(const ValueKey('update-notes-expand'));
    await tester.ensureVisible(expand);
    await tester.tap(expand);
    await tester.pumpAndSettle();
    expect(find.textContaining('Subscription compatibility'), findsOneWidget);
    expect(
      find.text(currentAppLocalizations.updateSeeFullReleaseNotes),
      findsOneWidget,
    );
    await tapCancel(tester);
    await shown;
  });

  testWidgets(
    'a late mandatory Markdown warning stays outside collapsed notes',
    (tester) async {
      await pumpApp(tester);
      final shown = _showOffer(
        tester.element(find.byType(Scaffold)),
        release: release(
          '${List.generate(12, (index) => '- Change $index').join('\n')}\n\n'
          '> [!WARNING]\n> Keep this complete warning visible.\n',
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Keep this complete warning visible.'),
        findsOneWidget,
      );
      expect(find.textContaining('Change 11'), findsNothing);
      await tapCancel(tester);
      await shown;
    },
  );

  testWidgets('expands complete Markdown blocks without destroying code', (
    tester,
  ) async {
    await pumpApp(tester);
    final shown = _showOffer(
      tester.element(find.byType(Scaffold)),
      release: release(
        '## Changes\n\n'
        '${List.generate(5, (index) => '- Change $index').join('\n')}\n\n'
        '~~~yaml\n# Keep this heading\n  <value>\n| keep this line |\n~~~\n\n'
        '- Last change\n',
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Keep this heading'), findsNothing);
    final expand = find.byKey(const ValueKey('update-notes-expand'));
    await tester.ensureVisible(expand);
    await tester.tap(expand);
    await tester.pumpAndSettle();
    expect(
      find.text('# Keep this heading\n  <value>\n| keep this line |'),
      findsOneWidget,
    );
    expect(find.textContaining('Last change'), findsOneWidget);
    expect(expand, findsNothing);
    await tapCancel(tester);
    await shown;
  });

  testWidgets(
    'keeps all breaking changes first and expands other groups in place',
    (tester) async {
      await pumpApp(tester);
      final payload = jsonEncode({
        'schemaVersion': 2,
        'versions': [
          {
            'version': '0.8.96',
            'tag': 'v0.8.96',
            'groups': [
              {
                'type': 'feat',
                'entries': [
                  {'id': 'f', 'text': 'New feature'},
                ],
              },
              {
                'type': 'fix',
                'entries': [
                  {'id': 'x', 'text': 'Last fix'},
                ],
              },
              {
                'type': 'breaking',
                'entries': List.generate(
                  7,
                  (index) => {'id': '$index', 'text': 'Migration $index'},
                ),
              },
            ],
          },
        ],
      });
      final shown = _showOffer(
        tester.element(find.byType(Scaffold)),
        release: release(_bodyWith(payload)),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Migration 6'), findsOneWidget);
      expect(find.textContaining('Last fix'), findsNothing);
      final expand = find.byKey(const ValueKey('update-notes-expand'));
      await tester.ensureVisible(expand);
      await tester.tap(expand);
      await tester.pumpAndSettle();
      expect(find.text('New feature'), findsOneWidget);
      expect(find.textContaining('Last fix'), findsOneWidget);
      final headings = tester
          .widgetList<Text>(find.byType(Text))
          .map((text) => text.data)
          .toList();
      expect(
        headings.indexOf(currentAppLocalizations.changelogFeatures),
        lessThan(headings.indexOf(currentAppLocalizations.changelogFixes)),
      );
      await tapCancel(tester);
      await shown;
    },
  );

  testWidgets(
    'keeps actions visible while scrolling in a short landscape window',
    (tester) async {
      tester.view.physicalSize = const Size(740, 320);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await pumpApp(tester);
      final shown = _showOffer(
        tester.element(find.byType(Scaffold)),
        release: release(
          List.generate(20, (index) => '- Change $index').join('\n'),
        ),
      );
      await tester.pumpAndSettle();
      final accept = find.byKey(const ValueKey('update-offer-accept'));
      final dismiss = find.byKey(const ValueKey('update-offer-dismiss'));
      expect(accept.hitTestable(), findsOneWidget);
      expect(dismiss.hitTestable(), findsOneWidget);
      await tester.drag(
        find.byKey(const ValueKey('update-offer-scroll')),
        const Offset(0, -400),
      );
      await tester.pumpAndSettle();
      expect(accept.hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tapCancel(tester);
      await shown;
    },
  );

  testWidgets('fits large text and long versions on a phone', (tester) async {
    tester.view.physicalSize = const Size(390, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpApp(tester, locale: const Locale('ru'));
    final shown = _showOffer(
      tester.element(find.byType(Scaffold)),
      release: const AppUpdateRelease(
        data: {
          'tag_name': 'v0.1.0-pre.123+very-long-build-identifier',
          'body': '## Changes\n\n- Improved routing',
        },
        source: _UpdateSource(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(_runningVersion), findsOneWidget);
    expect(
      find.byKey(const ValueKey('update-offer-accept')).hitTestable(),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('update-offer-dismiss')).hitTestable(),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
    await tapCancel(tester);
    await shown;
  });

  testWidgets(
    'opens formatted release links only through external-link confirmation',
    (tester) async {
      await pumpApp(tester);
      final shown = _showOffer(
        tester.element(find.byType(Scaffold)),
        release: release('[**Read `docs`**](https://example.com/notes)'),
      );
      await tester.pumpAndSettle();
      expect(find.text('Read docs'), findsOneWidget);
      await tester.tap(find.text('Read docs'));
      await tester.pumpAndSettle();
      expect(find.text(currentAppLocalizations.externalLink), findsOneWidget);
      expect(find.text('https://example.com/notes'), findsOneWidget);
      await tester.tap(find.text(currentAppLocalizations.cancel).last);
      await tester.pumpAndSettle();
      expect(find.text(currentAppLocalizations.externalLink), findsNothing);
      await tapCancel(tester);
      await shown;
    },
  );

  for (final locale in [
    'en',
    'ru',
    'ja',
    'zh_CN',
    'kk',
    'tk',
    'uz',
    'ko',
    'es',
    'fr',
  ]) {
    testWidgets(
      'renders publication metadata and an empty release in $locale',
      (tester) async {
        final parts = locale.split('_');
        await pumpApp(
          tester,
          locale: Locale(parts.first, parts.length > 1 ? parts.last : null),
        );
        final shown = _showOffer(
          tester.element(find.byType(Scaffold)),
          release: const AppUpdateRelease(
            data: {
              'tag_name': 'v0.8.96',
              'published_at': '2026-10-18T10:00:00Z',
            },
            source: _UpdateSource(),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.textContaining('2026'), findsOneWidget);
        expect(
          find.text(currentAppLocalizations.updateNotesUnavailable),
          findsOneWidget,
        );
        expect(
          find.text(currentAppLocalizations.updateSeeFullReleaseNotes),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
        await tapCancel(tester);
        await shown;
      },
    );
  }
}
