import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:reclash/common/app_localizations.dart';
import 'package:reclash/common/app_update.dart';
import 'package:reclash/common/app_update_state.dart';
import 'package:reclash/common/update.dart';
import 'package:reclash/common/update_summary.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/views/dashboard/widgets/update_card.dart';
import 'package:reclash/widgets/update_content.dart';
import 'package:reclash/widgets/update_preferences.dart';
import 'package:reclash/widgets/update_sheet.dart';

import '../helpers/test_app.dart';
import '../helpers/test_update_runtime.dart';

class _DisplayUpdateAction extends AppUpdateAction {
  _DisplayUpdateAction(this.initial);
  final AppUpdateState initial;
  @override
  AppUpdateState build() => initial;
}

void main() {
  late Directory directory;
  late TestUpdateRuntime runtime;
  late ProviderContainer container;
  late String previousEnv;

  setUp(() async {
    previousEnv = globalState.appEnv;
    globalState.appEnv = 'stable';
    globalState.packageInfo = PackageInfo(
      appName: 'ReClash',
      packageName: 'com.reclash',
      version: '0.8.95',
      buildNumber: '1',
    );
    directory = await Directory.systemTemp.createTemp('reclash-update-sheet-');
    runtime = TestUpdateRuntime(directory);
    container = ProviderContainer(
      overrides: [appUpdateRuntimeProvider.overrideWithValue(runtime)],
    );
    globalState.container = container;
    container.listen(appSettingProvider, (_, _) {}, fireImmediately: true);
  });

  tearDown(() async {
    container.dispose();
    await runtime.dispose();
    await directory.delete(recursive: true);
    globalState.appEnv = previousEnv;
  });

  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    Size size = const Size(390, 844),
    ThemeMode mode = ThemeMode.light,
    Locale locale = const Locale('en'),
    bool includeNavigatorKey = false,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    container.read(viewSizeProvider.notifier).update((_) => size);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          includeNavigatorKey: includeNavigatorKey,
          locale: locale,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF5068A0),
            ),
          ).withAppShapes,
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF5068A0),
              brightness: Brightness.dark,
            ),
          ).withAppShapes,
          themeMode: mode,
          child: ViewScope(
            size: size,
            isMobile: size.width <= 600,
            child: Scaffold(body: child),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> close(WidgetTester tester) async {
    await tester.tap(find.byTooltip(currentAppLocalizations.close).last);
    await tester.pumpAndSettle();
  }

  testWidgets('authored overview leads with complete visible warnings', (
    tester,
  ) async {
    final release = testUpdateRelease(warning: true, breaking: true);
    await pump(
      tester,
      SingleChildScrollView(
        child: UpdateReleaseContent(
          release: release,
          currentVersion: '0.8.95',
          platform: SupportPlatform.Android,
          asset: selectAndroidUpdateAsset(
            release.assets,
            supportedAbis: const ['arm64-v8a'],
          ),
        ),
      ),
    );
    expect(find.text('Updates without interruption'), findsOneWidget);
    expect(find.text('Your background'), findsOneWidget);
    expect(find.text('Make an explicit choice.'), findsOneWidget);
    expect(find.text('Review this change.'), findsOneWidget);
    expect(
      find.text(currentAppLocalizations.updatePackageDevice),
      findsNothing,
    );
    final disclosure = find.byKey(const ValueKey('update-release-details'));
    await tester.ensureVisible(disclosure);
    await tester.tap(disclosure);
    await tester.pump();
    expect(
      find.text(currentAppLocalizations.updatePackageDevice),
      findsOneWidget,
    );
  });

  for (final changelogPayload in [
    null,
    'invalid JSON',
    jsonEncode({
      'schemaVersion': 2,
      'versions': [
        {
          'version': '0.1.0',
          'tag': 'v0.1.0',
          'groups': [
            {
              'type': 'feat',
              'entries': [
                {'id': 'example', 'text': 'Notes from another version.'},
              ],
            },
          ],
        },
      ],
    }),
  ]) {
    final scenario = changelogPayload == null
        ? 'missing'
        : changelogPayload == 'invalid JSON'
        ? 'invalid'
        : 'mismatched';
    testWidgets(
      'authored overview keeps $scenario changelog in release details',
      (tester) async {
        final base = testUpdateRelease(tag: 'v0.1.0-pre.2', warning: true);
        final release = AppUpdateRelease(
          source: base.source,
          data: {
            ...base.data,
            'body':
                '<!-- reclash:changelog:begin -->\n'
                '- Markdown release details.\n'
                '<!-- reclash:changelog:end -->\n'
                '${renderReleaseSummary(base.summary!)}'
                '${changelogPayload == null ? '' : '<!-- reclash:changelog:json\n$changelogPayload\n-->\n'}'
                '## Downloads\n- Download boilerplate.\n',
          },
        );
        await pump(
          tester,
          SingleChildScrollView(
            child: UpdateReleaseContent(
              release: release,
              currentVersion: '0.1.0-pre.1',
              platform: SupportPlatform.Android,
            ),
          ),
        );
        expect(find.text('Updates without interruption'), findsOneWidget);
        expect(find.text('Your background'), findsOneWidget);
        expect(find.text('Make an explicit choice.'), findsOneWidget);
        expect(find.text('Markdown release details.'), findsNothing);
        expect(find.text('Notes from another version.'), findsNothing);
        final disclosure = find.byKey(const ValueKey('update-release-details'));
        await tester.ensureVisible(disclosure);
        await tester.tap(disclosure);
        await tester.pump();
        expect(find.text('Markdown release details.'), findsOneWidget);
        expect(find.text('Notes from another version.'), findsNothing);
        expect(find.text('Download boilerplate.'), findsNothing);
        await tester.tap(disclosure);
        await tester.pump();
        expect(find.text('Markdown release details.'), findsNothing);
        expect(find.text('Make an explicit choice.'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('authored prerelease keeps structured notes in release details', (
    tester,
  ) async {
    final release = testUpdateRelease(tag: 'v0.1.0-pre.2');
    await pump(
      tester,
      SingleChildScrollView(
        child: UpdateReleaseContent(
          release: release,
          currentVersion: '0.1.0-pre.1',
          platform: SupportPlatform.Android,
        ),
      ),
    );
    expect(find.text('Your background'), findsOneWidget);
    expect(find.text('Improved updates.'), findsNothing);
    final disclosure = find.byKey(const ValueKey('update-release-details'));
    await tester.ensureVisible(disclosure);
    await tester.tap(disclosure);
    await tester.pump();
    expect(find.text('Improved updates.'), findsOneWidget);
    await tester.tap(disclosure);
    await tester.pump();
    expect(find.text('Improved updates.'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('automatic checking shows a card but no modal', (tester) async {
    await pump(tester, const UpdateCard());
    final release = testUpdateRelease();
    await container
        .read(commonActionProvider.notifier)
        .checkUpdateResultHandle(data: release);
    await tester.pump();
    expect(find.byKey(const ValueKey('app-update-card')), findsOneWidget);
    expect(find.byType(UpdateSheet), findsNothing);
    await tester.tap(find.byKey(const ValueKey('app-update-card')));
    await tester.pumpAndSettle();
    expect(find.byType(UpdateSheet), findsOneWidget);
    await close(tester);
    expect(container.read(appSettingProvider).autoCheckUpdate, isTrue);
  });

  AppUpdateState current() => container.read(appUpdateActionProvider);

  Future<void> settleIo(WidgetTester tester, bool Function() done) async {
    for (var i = 0; i < 100 && !done(); i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump();
    }
    expect(done(), isTrue);
  }

  testWidgets('the card installs a ready package without the sheet', (
    tester,
  ) async {
    final action = container.read(appUpdateActionProvider.notifier);
    await action.offer(testUpdateRelease());
    unawaited(action.download());
    await settleIo(tester, () => current().phase == UpdatePhase.ready);
    await pump(tester, const UpdateCard());
    await tester.tap(find.byKey(const ValueKey('app-update-card-step')));
    await settleIo(tester, () => runtime.installations == 1);
    expect(find.byType(UpdateSheet), findsNothing);
  });

  testWidgets('returning from Android settings brings the sheet back', (
    tester,
  ) async {
    final action = container.read(appUpdateActionProvider.notifier);
    runtime.permission = false;
    await action.offer(testUpdateRelease());
    Future<void> run(Future<void> Function() step) async {
      var done = false;
      unawaited(step().whenComplete(() => done = true));
      await settleIo(tester, () => done);
    }

    await run(action.download);
    await run(action.installNow);
    expect(current().phase, UpdatePhase.permission);
    await run(action.openPermission);
    expect(runtime.permissionRequests, 1);
    await pump(tester, const SizedBox.shrink(), includeNavigatorKey: true);
    expect(find.byType(UpdateSheet), findsNothing);
    runtime.permission = true;
    container.read(initProvider.notifier).value = true;
    action.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await settleIo(tester, () => runtime.installations == 1);
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.byType(UpdateSheet), findsOneWidget);
    await tester.tap(find.byTooltip(currentAppLocalizations.close).last);
    await tester.pump(const Duration(milliseconds: 700));
    container.dispose();
  });

  testWidgets('closing the sheet leaves its provider-owned transfer visible', (
    tester,
  ) async {
    final release = testUpdateRelease();
    final asset = selectAndroidUpdateAsset(
      release.assets,
      supportedAbis: const ['arm64-v8a'],
    );
    container.dispose();
    container = ProviderContainer(
      overrides: [
        appUpdateRuntimeProvider.overrideWithValue(runtime),
        appUpdateActionProvider.overrideWith(
          () => _DisplayUpdateAction(
            AppUpdateState(
              phase: UpdatePhase.downloading,
              release: release,
              asset: asset,
              received: 8,
              total: updateTestBytes.length,
            ),
          ),
        ),
      ],
    );
    globalState.container = container;
    container.listen(appSettingProvider, (_, _) {}, fireImmediately: true);
    await pump(tester, const UpdateCard());
    final shown = UpdateSheet.show(tester.element(find.byType(Scaffold)));
    await tester.pumpAndSettle();
    expect(
      find.text(currentAppLocalizations.updateContinueBackground),
      findsOneWidget,
    );
    await close(tester);
    await shown;
    await tester.pump();
    expect(
      container.read(appUpdateActionProvider).phase,
      UpdatePhase.downloading,
    );
    expect(find.byKey(const ValueKey('app-update-card')), findsOneWidget);
  });

  testWidgets('the footer button closes the whole sheet', (tester) async {
    container.read(appUpdateActionProvider.notifier).noUpdates();
    await pump(tester, const SizedBox.shrink());
    final shown = UpdateSheet.show(tester.element(find.byType(Scaffold)));
    await tester.pumpAndSettle();
    await tester.tap(find.text(currentAppLocalizations.updateGotIt));
    await tester.pumpAndSettle();
    await shown;
    expect(find.byType(UpdateSheet), findsNothing);
    expect(find.byType(NestedPagedSheet), findsNothing);
  });

  Future<void> openAutoInstallConsent(WidgetTester tester) async {
    final toggle = find.text(currentAppLocalizations.updateAutoInstall);
    await tester.ensureVisible(toggle);
    await tester.pumpAndSettle();
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(
      find.text(currentAppLocalizations.updateAutoConsentTitle),
      findsOneWidget,
    );
  }

  bool autoInstallSwitch(WidgetTester tester) => tester
      .widget<CommonSwitch>(
        find.descendant(
          of: find.ancestor(
            of: find.text(currentAppLocalizations.updateAutoInstall),
            matching: find.byType(ListItem),
          ),
          matching: find.byType(CommonSwitch),
        ),
      )
      .value;

  testWidgets(
    'automatic installation needs confirmed consent and a successful save',
    (tester) async {
      runtime.saved = false;
      await pump(tester, const SizedBox.shrink());
      final shown = UpdateSheet.show(
        tester.element(find.byType(Scaffold)),
        preferences: true,
      );
      await tester.pumpAndSettle();
      await openAutoInstallConsent(tester);
      expect(container.read(appSettingProvider).autoInstallUpdate, isFalse);
      await tester.tap(find.text(currentAppLocalizations.updateAllowAutomatic));
      await tester.pumpAndSettle();
      expect(autoInstallSwitch(tester), isTrue);
      final save = find.byTooltip(currentAppLocalizations.save);
      await tester.tap(save);
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 40));
      });
      await tester.pumpAndSettle();
      expect(
        find.text(currentAppLocalizations.updatePreferencesSaveFailed),
        findsOneWidget,
      );
      expect(container.read(appSettingProvider).autoInstallUpdate, isFalse);
      runtime.saved = true;
      await tester.tap(save);
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 40));
      });
      await tester.pumpAndSettle();
      await shown;
      expect(container.read(appSettingProvider).autoInstallUpdate, isTrue);
    },
  );

  testWidgets('declining the consent keeps installation manual', (
    tester,
  ) async {
    await pump(tester, const SizedBox.shrink());
    final shown = UpdateSheet.show(
      tester.element(find.byType(Scaffold)),
      preferences: true,
    );
    await tester.pumpAndSettle();
    await openAutoInstallConsent(tester);
    await tester.tap(find.text(currentAppLocalizations.updateDoNotEnable));
    await tester.pumpAndSettle();
    expect(autoInstallSwitch(tester), isFalse);
    await close(tester);
    await shown;
    expect(runtime.savedConfig, isNull);
  });

  testWidgets('a repeated request lands on the sheet already open', (
    tester,
  ) async {
    await container
        .read(appUpdateActionProvider.notifier)
        .offer(testUpdateRelease());
    await pump(tester, const SizedBox.shrink());
    final context = tester.element(find.byType(Scaffold));
    final shown = UpdateSheet.show(context);
    unawaited(UpdateSheet.show(context));
    await tester.pumpAndSettle();
    unawaited(UpdateSheet.show(context));
    await tester.pumpAndSettle();
    expect(find.byType(UpdateSheet), findsOneWidget);

    final settings = find.byTooltip(
      currentAppLocalizations.updatePreferencesTitle,
    );
    await tester.tap(settings);
    await tester.tap(settings, warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.byType(UpdatePreferences), findsOneWidget);
    await tester.tap(find.byTooltip(UiLocalizations.of(context).back).last);
    await tester.pumpAndSettle();
    expect(find.byType(UpdatePreferences), findsNothing);
    await close(tester);
    await shown;

    final reopened = UpdateSheet.show(context);
    await tester.pumpAndSettle();
    expect(find.byType(UpdateSheet), findsOneWidget);
    await close(tester);
    await reopened;
  });

  testWidgets('preferences stack over the offer and channel selection works', (
    tester,
  ) async {
    final release = testUpdateRelease();
    await container.read(appUpdateActionProvider.notifier).offer(release);
    await pump(tester, const SizedBox.shrink());
    final context = tester.element(find.byType(Scaffold));
    final shown = UpdateSheet.show(context);
    await tester.pumpAndSettle();
    final l = currentAppLocalizations;
    await tester.tap(find.byTooltip(l.updatePreferencesTitle));
    await tester.pumpAndSettle();
    expect(find.byType(UpdateSheet, skipOffstage: false), findsOneWidget);
    expect(find.byType(UpdatePreferences), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text(l.updateChannel),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.ensureVisible(find.text(l.updateChannel));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l.updateChannel));
    await tester.pumpAndSettle();
    final menu = find.byType(CommonPopupMenu);
    expect(menu, findsOneWidget);
    await tester.tap(
      find.descendant(of: menu, matching: find.text(l.updateChannelPre)),
    );
    await tester.pumpAndSettle();
    expect(find.text(l.updateChannelPre), findsOneWidget);
    expect(container.read(appSettingProvider).updateChannel, isNull);

    await tester.tap(find.byTooltip(l.save));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 40));
    });
    await tester.pumpAndSettle();
    expect(find.byType(UpdatePreferences), findsNothing);
    expect(container.read(appSettingProvider).updateChannel, UpdateChannel.pre);
    expect(find.text(release.summary!.locales['en']!.headline), findsOneWidget);
    await close(tester);
    await shown;
  });

  testWidgets('closing preferences discards an unsaved installation consent', (
    tester,
  ) async {
    await pump(tester, const SizedBox.shrink());
    final shown = UpdateSheet.show(
      tester.element(find.byType(Scaffold)),
      preferences: true,
    );
    await tester.pumpAndSettle();
    await openAutoInstallConsent(tester);
    await tester.tap(find.text(currentAppLocalizations.updateAllowAutomatic));
    await tester.pumpAndSettle();
    await close(tester);
    await shown;
    expect(container.read(appSettingProvider).autoInstallUpdate, isFalse);
    expect(runtime.savedConfig, isNull);
  });

  testWidgets('desktop preferences do not advertise a package installer', (
    tester,
  ) async {
    runtime.enabled = false;
    await pump(tester, const SizedBox.shrink(), size: const Size(1200, 800));
    final shown = UpdateSheet.show(
      tester.element(find.byType(Scaffold)),
      preferences: true,
    );
    await tester.pumpAndSettle();
    expect(
      find.text(currentAppLocalizations.updateDesktopDescription),
      findsOneWidget,
    );
    expect(find.text(currentAppLocalizations.updateAutoInstall), findsNothing);
    expect(find.byType(CommonSwitch), findsOneWidget);
    await tester.tap(
      find.widgetWithText(TextButton, currentAppLocalizations.cancel),
    );
    await tester.pumpAndSettle();
    await shown;
  });

  for (final phase in [
    UpdatePhase.downloading,
    UpdatePhase.paused,
    UpdatePhase.verifying,
    UpdatePhase.ready,
    UpdatePhase.vpnActive,
    UpdatePhase.permission,
    UpdatePhase.confirmation,
    UpdatePhase.installing,
    UpdatePhase.installed,
    UpdatePhase.upToDate,
    UpdatePhase.checkFailed,
    UpdatePhase.downloadFailed,
    UpdatePhase.verifyFailed,
    UpdatePhase.installFailed,
  ]) {
    testWidgets('$phase renders without layout exceptions at large text', (
      tester,
    ) async {
      container.dispose();
      final release = testUpdateRelease();
      final state = AppUpdateState(
        phase: phase,
        release: release,
        received: 12,
        total: 40,
        bytesPerSecond: 3,
        verified: const {
          UpdatePhase.ready,
          UpdatePhase.vpnActive,
          UpdatePhase.permission,
          UpdatePhase.confirmation,
          UpdatePhase.installing,
        }.contains(phase),
      );
      container = ProviderContainer(
        overrides: [
          appUpdateRuntimeProvider.overrideWithValue(runtime),
          isMobileViewProvider.overrideWithValue(true),
          appUpdateActionProvider.overrideWith(
            () => _DisplayUpdateAction(state),
          ),
        ],
      );
      globalState.container = container;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pump(
        tester,
        const SizedBox.shrink(),
        size: const Size(390, 640),
        mode: ThemeMode.dark,
        locale: const Locale('ru'),
      );
      final shown = UpdateSheet.show(tester.element(find.byType(Scaffold)));
      await tester.pump(const Duration(milliseconds: 700));
      expect(find.byKey(const ValueKey('update-offer-accept')), findsOneWidget);
      expect(find.byTooltip(currentAppLocalizations.close), findsOneWidget);
      expect(tester.takeException(), isNull);
      Navigator.of(tester.element(find.byType(Scaffold))).pop();
      await tester.pump(const Duration(milliseconds: 700));
      await shown;
    });
  }
}
