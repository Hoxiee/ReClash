import 'dart:async';

import 'package:reclash/widgets/settings/setting_target.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/action.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/database.dart';
import 'package:reclash/providers/state.dart';
import 'package:reclash/state.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/views/access.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

Package _package(
  String name, {
  String? label,
  bool system = false,
  bool internet = true,
  int lastUpdateTime = 0,
}) {
  return Package(
    packageName: name,
    label: label ?? name.split('.').last,
    system: system,
    internet: internet,
    lastUpdateTime: lastUpdateTime,
  );
}

final _packages = [
  _package('com.example.browser', label: 'Browser'),
  _package('com.example.chat', label: 'Chat'),
  _package('com.android.settings', label: 'Settings', system: true),
  _package('com.example.offline', label: 'Offline', internet: false),
];

class _TestSystemAction extends SystemAction {
  bool installedAppsPermissionGranted = true;
  bool grantOnRequest = true;
  int requestCount = 0;
  int loadCount = 0;
  List<Package> grantedPackages = const [];
  Future<List<String>> Function(String region) match = (_) async => [];
  int matchCount = 0;

  @override
  Future<List<String>> getDomesticPackageNames(String regionCode) {
    matchCount++;
    return match(regionCode);
  }

  @override
  Future<List<Package>> getPackages() async {
    loadCount++;
    if (installedAppsPermissionGranted && grantedPackages.isNotEmpty) {
      ref.read(packagesProvider.notifier).value = grantedPackages;
    }
    return ref.read(packagesProvider);
  }

  @override
  Future<bool> isInstalledAppsPermissionGranted() async =>
      installedAppsPermissionGranted;

  @override
  Future<bool> requestInstalledAppsPermission() async {
    requestCount++;
    installedAppsPermissionGranted = grantOnRequest;
    return grantOnRequest;
  }
}

Future<void> openBarMenu(WidgetTester tester) async {
  await tester.tap(
    find.descendant(
      of: find.byType(AppBar),
      matching: find.byGlyph(AppGlyphs.more),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late _TestSystemAction systemAction;

  setUp(() {
    systemAction = _TestSystemAction();
    container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(TestProfiles.new),
        systemActionProvider.overrideWith(() => systemAction),
      ],
    );
    globalState.container = container;
    container.listen(appSettingProvider, (_, _) {}, fireImmediately: true);
    container.listen(vpnSettingProvider, (_, _) {}, fireImmediately: true);
    container.listen(
      accessControlStateProvider,
      (_, _) {},
      fireImmediately: true,
    );
    container.listen(packagesProvider, (_, _) {}, fireImmediately: true);
    container.read(packagesProvider.notifier).value = _packages;
  });

  tearDown(() => container.dispose());

  void seedAccessControl(AccessControlProps props) {
    container.read(vpnSettingProvider.notifier).value = const VpnProps()
        .copyWith(accessControlProps: props);
  }

  Future<void> pumpAccessView(WidgetTester tester, {String? settingId}) async {
    tester.view.physicalSize = const Size(1400, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    container
        .read(viewSizeProvider.notifier)
        .update((_) => const Size(1400, 1400));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: SettingsRevealScope(
            targetId: settingId,
            child: const AccessView(),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 301));
  }

  Future<void> teardownView(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
  }

  testWidgets(
    'a deep setting opens its existing panel without changing access',
    (tester) async {
      seedAccessControl(const AccessControlProps(enable: true));
      await pumpAccessView(tester, settingId: 'access.noNetworkApp');
      await tester.pumpAndSettle();
      expect(find.byType(AccessControlPanel), findsOneWidget);
      final anchor = find.byWidgetPredicate(
        (widget) =>
            widget is SettingTarget && widget.spec.id == 'access.noNetworkApp',
      );
      expect(anchor, findsOneWidget);
      expect(tester.getRect(anchor).bottom, lessThanOrEqualTo(1400));
      expect(
        container.read(accessControlStateProvider).isFilterNonInternetApp,
        isTrue,
      );
      expect(tester.takeException(), isNull);
    },
  );

  group('visible package list', () {
    testWidgets('hides system and offline apps by default', (tester) async {
      seedAccessControl(const AccessControlProps(enable: true));

      await pumpAccessView(tester);

      expect(find.text('Browser'), findsOneWidget);
      expect(find.text('Chat'), findsOneWidget);
      expect(find.text('Settings'), findsNothing);
      expect(find.text('Offline'), findsNothing);

      await teardownView(tester);
    });

    testWidgets('shows system apps once the filter is disabled', (
      tester,
    ) async {
      seedAccessControl(
        const AccessControlProps(enable: true, isFilterSystemApp: false),
      );

      await pumpAccessView(tester);

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Offline'), findsNothing);

      await teardownView(tester);
    });

    testWidgets('shows offline apps once the internet filter is disabled', (
      tester,
    ) async {
      seedAccessControl(
        const AccessControlProps(enable: true, isFilterNonInternetApp: false),
      );

      await pumpAccessView(tester);

      expect(find.text('Offline'), findsOneWidget);
      expect(find.text('Settings'), findsNothing);

      await teardownView(tester);
    });

    testWidgets('the settings sheet shows system apps from a toggle', (
      tester,
    ) async {
      seedAccessControl(const AccessControlProps(enable: true));
      await pumpAccessView(tester);
      final l10n = AppLocalizations.current;

      await openBarMenu(tester);
      await tester.tap(
        find
            .descendant(
              of: find.byType(CommonPopupMenu),
              matching: find.text(l10n.settings),
            )
            .last,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.systemApp));
      await tester.pumpAndSettle();

      final state = container.read(accessControlStateProvider);
      expect(state.isFilterSystemApp, isFalse);
      expect(state.isFilterNonInternetApp, isTrue);

      await teardownView(tester);
    });

    testWidgets('sorts by name when the name sort is selected', (tester) async {
      seedAccessControl(
        const AccessControlProps(enable: true, sort: AccessSortType.name),
      );

      await pumpAccessView(tester);

      final labels = tester
          .widgetList<PackageListItem>(find.byType(PackageListItem))
          .map((item) => item.package.label)
          .toList();
      expect(labels, ['Browser', 'Chat']);

      await teardownView(tester);
    });
  });

  group('search', () {
    testWidgets('filters by label and by package name', (tester) async {
      seedAccessControl(const AccessControlProps(enable: true));
      await pumpAccessView(tester);

      container.read(queryProvider(QueryTag.access).notifier).value = 'chat';
      await tester.pump();
      expect(find.text('Chat'), findsOneWidget);
      expect(find.text('Browser'), findsNothing);

      container.read(queryProvider(QueryTag.access).notifier).value =
          'com.example.browser';
      await tester.pump();
      expect(find.text('Browser'), findsOneWidget);
      expect(find.text('Chat'), findsNothing);

      await teardownView(tester);
    });

    testWidgets('ignores case and needs every term to match', (tester) async {
      seedAccessControl(const AccessControlProps(enable: true));
      await pumpAccessView(tester);

      container.read(queryProvider(QueryTag.access).notifier).value = 'CHAT';
      await tester.pump();
      expect(find.text('Chat'), findsOneWidget);
      expect(find.text('Browser'), findsNothing);

      container.read(queryProvider(QueryTag.access).notifier).value =
          'EXAMPLE browser';
      await tester.pump();
      expect(find.text('Browser'), findsOneWidget);
      expect(find.text('Chat'), findsNothing);

      await teardownView(tester);
    });

    testWidgets('the app bar search field filters the list', (tester) async {
      seedAccessControl(const AccessControlProps(enable: true));
      await pumpAccessView(tester);

      await tester.tap(find.byGlyph(AppGlyphs.search));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'nothing matches');
      await tester.pumpAndSettle();

      expect(find.text('Browser'), findsNothing);
      expect(
        find.text(AppLocalizations.current.noSearchResults),
        findsOneWidget,
      );

      await teardownView(tester);
    });
  });

  group('selection', () {
    testWidgets('tapping a package adds and removes it from the list', (
      tester,
    ) async {
      seedAccessControl(const AccessControlProps(enable: true));
      await pumpAccessView(tester);

      await tester.tap(find.text('Browser'));
      await tester.pump();
      expect(container.read(accessControlStateProvider).currentList, [
        'com.example.browser',
      ]);

      await tester.tap(find.text('Browser'));
      await tester.pump();
      expect(container.read(accessControlStateProvider).currentList, isEmpty);

      await teardownView(tester);
    });

    testWidgets('the bar menu selects then clears every visible app', (
      tester,
    ) async {
      seedAccessControl(const AccessControlProps(enable: true));
      await pumpAccessView(tester);

      await openBarMenu(tester);
      await tester.tap(find.text('Select all'));
      await tester.pumpAndSettle();
      expect(
        [...container.read(accessControlStateProvider).currentList]..sort(),
        ['com.example.browser', 'com.example.chat'],
      );

      await openBarMenu(tester);
      await tester.tap(find.text('Deselect all'));
      await tester.pumpAndSettle();
      expect(container.read(accessControlStateProvider).currentList, isEmpty);

      await teardownView(tester);
    });

    testWidgets('regional app suggestions require a selected country', (
      tester,
    ) async {
      const initial = AccessControlProps(
        enable: true,
        rejectList: ['com.example.chat'],
      );
      seedAccessControl(initial);
      await pumpAccessView(tester);

      await openBarMenu(tester);
      await tester.tap(find.text('Action'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppLocalizations.current.regionSelectApps));
      await tester.pumpAndSettle();

      expect(container.read(appSettingProvider).regionCode, isNull);
      expect(container.read(accessControlStateProvider).currentList, [
        'com.example.chat',
      ]);
      await teardownView(tester);
    });

    testWidgets('the bar menu turns access control off and on', (tester) async {
      seedAccessControl(const AccessControlProps(enable: true));
      await pumpAccessView(tester);

      Future<void> tapMenuPath(List<String> labels) async {
        await openBarMenu(tester);
        for (final label in labels) {
          await tester.tap(
            find
                .descendant(
                  of: find.byType(CommonPopupMenu),
                  matching: find.text(label),
                )
                .last,
          );
          await tester.pumpAndSettle();
        }
      }

      await tapMenuPath(['Access control', 'Turn off']);
      expect(container.read(accessControlStateProvider).enable, isFalse);

      await tapMenuPath(['Access control', 'Turn on']);
      expect(container.read(accessControlStateProvider).enable, isTrue);

      await teardownView(tester);
    });

    testWidgets('searching selects then clears only the matching apps', (
      tester,
    ) async {
      seedAccessControl(const AccessControlProps(enable: true));
      await pumpAccessView(tester);

      await tester.tap(find.byTooltip('Search'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'chat');
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Select all'));
      await tester.pumpAndSettle();
      expect(container.read(accessControlStateProvider).currentList, [
        'com.example.chat',
      ]);

      await tester.tap(find.byTooltip('Deselect all'));
      await tester.pumpAndSettle();
      expect(container.read(accessControlStateProvider).currentList, isEmpty);

      await teardownView(tester);
    });

    testWidgets('selection targets the accept list in accept mode', (
      tester,
    ) async {
      seedAccessControl(
        const AccessControlProps(
          enable: true,
          mode: AccessControlMode.acceptSelected,
        ),
      );
      await pumpAccessView(tester);

      await tester.tap(find.text('Chat'));
      await tester.pump();

      final state = container.read(accessControlStateProvider);
      expect(state.acceptList, ['com.example.chat']);
      expect(state.rejectList, isEmpty);

      await teardownView(tester);
    });
  });

  testWidgets('asks the platform for the app list on every entry', (
    tester,
  ) async {
    systemAction.grantedPackages = [
      ..._packages,
      _package('com.example.fresh', label: 'Fresh'),
    ];
    seedAccessControl(const AccessControlProps(enable: true));

    await pumpAccessView(tester);

    expect(systemAction.loadCount, 1);
    expect(find.text('Fresh'), findsOneWidget);

    await teardownView(tester);
  });

  group('regional app selection', () {
    const initial = AccessControlProps(
      enable: true,
      mode: AccessControlMode.acceptSelected,
      acceptList: ['com.example.chat'],
      rejectList: ['com.example.browser'],
    );

    Future<void> openSelection(WidgetTester tester) async {
      await openBarMenu(tester);
      await tester.tap(find.text('Action'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppLocalizations.current.regionSelectApps));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump();
    }

    Future<void> start(WidgetTester tester) async {
      seedAccessControl(initial);
      container
          .read(appSettingProvider.notifier)
          .update((state) => state.copyWith(regionCode: 'RU'));
      await pumpAccessView(tester);
      await openSelection(tester);
    }

    testWidgets('replaces both draft lists only after confirmation', (
      tester,
    ) async {
      systemAction.match = (region) async {
        expect(region, 'RU');
        return ['com.example.browser', 'not.installed', 'com.example.browser'];
      };
      await start(tester);
      await tester.pumpAndSettle();
      expect(find.text('App selection preview'), findsOneWidget);
      expect(container.read(accessControlStateProvider), initial);
      expect(container.read(vpnSettingProvider).accessControlProps, initial);
      await tester.tap(find.widgetWithText(TextButton, 'Apply region'));
      await tester.pumpAndSettle();
      final selected = container.read(accessControlStateProvider);
      expect(selected.rejectList, ['com.example.browser']);
      expect(selected.acceptList, [
        'com.example.chat',
        'com.android.settings',
        'com.example.offline',
      ]);
      expect(selected.mode, initial.mode);
      expect(selected.isFilterSystemApp, initial.isFilterSystemApp);
      expect(selected.isFilterNonInternetApp, initial.isFilterNonInternetApp);
      expect(container.read(vpnSettingProvider).accessControlProps, initial);
      expect(container.read(loadingProvider(LoadingTag.access)), isFalse);
      await teardownView(tester);
    });

    testWidgets('cancelling the preview preserves both lists', (tester) async {
      systemAction.match = (_) async => ['com.example.chat'];
      await start(tester);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();
      expect(container.read(accessControlStateProvider), initial);
      expect(container.read(vpnSettingProvider).accessControlProps, initial);
      await teardownView(tester);
    });

    for (final matches in <List<String>>[
      [],
      ['not.installed'],
    ]) {
      testWidgets('no installed matches preserve lists: $matches', (
        tester,
      ) async {
        systemAction.match = (_) async => matches;
        await start(tester);
        await tester.pumpAndSettle();
        expect(find.text('App selection preview'), findsNothing);
        expect(container.read(accessControlStateProvider), initial);
        expect(container.read(loadingProvider(LoadingTag.access)), isFalse);
        await teardownView(tester);
      });
    }

    testWidgets('a native error preserves lists and releases loading', (
      tester,
    ) async {
      systemAction.match = (_) async =>
          throw PlatformException(code: 'unavailable');
      await start(tester);
      await tester.pumpAndSettle();
      expect(find.text('App selection preview'), findsNothing);
      expect(container.read(accessControlStateProvider), initial);
      expect(container.read(loadingProvider(LoadingTag.access)), isFalse);
      await tester.tap(find.widgetWithText(TextButton, 'Confirm'));
      await tester.pumpAndSettle();
      await teardownView(tester);
    });

    testWidgets('changing region while scanning discards the old result', (
      tester,
    ) async {
      final gate = Completer<List<String>>();
      systemAction.match = (_) => gate.future;
      await start(tester);
      expect(container.read(loadingProvider(LoadingTag.access)), isTrue);
      container
          .read(appSettingProvider.notifier)
          .update((state) => state.copyWith(regionCode: 'IR'));
      gate.complete(['com.example.chat']);
      await tester.pumpAndSettle();
      expect(find.text('App selection preview'), findsNothing);
      expect(container.read(accessControlStateProvider), initial);
      expect(container.read(loadingProvider(LoadingTag.access)), isFalse);
      await teardownView(tester);
    });

    testWidgets('changed access settings win over the pending preview', (
      tester,
    ) async {
      systemAction.match = (_) async => ['com.example.chat'];
      await start(tester);
      await tester.pumpAndSettle();
      final updated = initial.copyWith(rejectList: ['manual.app']);
      container.read(accessControlStateProvider.notifier).value = updated;
      await tester.tap(find.widgetWithText(TextButton, 'Apply region'));
      await tester.pumpAndSettle();
      expect(container.read(accessControlStateProvider), updated);
      await teardownView(tester);
    });

    testWidgets('an installed-package change invalidates the preview', (
      tester,
    ) async {
      systemAction.match = (_) async => ['com.example.chat'];
      await start(tester);
      await tester.pumpAndSettle();
      container.read(packagesProvider.notifier).value = [
        ..._packages,
        _package('new.app'),
      ];
      await tester.tap(find.widgetWithText(TextButton, 'Apply region'));
      await tester.pumpAndSettle();
      expect(container.read(accessControlStateProvider), initial);
      await teardownView(tester);
    });

    testWidgets('a repeated action does not start a second scan', (
      tester,
    ) async {
      final gate = Completer<List<String>>();
      systemAction.match = (_) => gate.future;
      seedAccessControl(initial);
      container
          .read(appSettingProvider.notifier)
          .update((state) => state.copyWith(regionCode: 'RU'));
      await pumpAccessView(tester);
      CommonPopupMenuItem selection() => tester
          .widget<CommonScaffold>(find.byType(CommonScaffold))
          .menuItems
          .firstWhere((item) => item.label == 'Action')
          .subItems
          .firstWhere(
            (item) => item.label == AppLocalizations.current.regionSelectApps,
          );
      final picked = selection().onPressed;
      await openSelection(tester);
      expect(container.read(loadingProvider(LoadingTag.access)), isTrue);
      expect(selection().onPressed, isNull);
      picked!();
      expect(systemAction.matchCount, 1);
      gate.complete([]);
      await tester.pumpAndSettle();
      await teardownView(tester);
    });

    testWidgets(
      'leaving during a scan cannot mutate lists or reopen a dialog',
      (tester) async {
        final gate = Completer<List<String>>();
        systemAction.match = (_) => gate.future;
        await start(tester);
        await teardownView(tester);
        gate.complete(['com.example.chat']);
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();
        expect(container.read(accessControlStateProvider), initial);
        expect(container.read(loadingProvider(LoadingTag.access)), isFalse);
        expect(find.text('App selection preview'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('installed apps permission', () {
    testWidgets('prompts for the permission when the app list is empty', (
      tester,
    ) async {
      container.read(packagesProvider.notifier).value = [];
      systemAction.installedAppsPermissionGranted = false;
      seedAccessControl(const AccessControlProps(enable: true));

      await pumpAccessView(tester);

      expect(find.text('App list permission required'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Authorize'), findsOneWidget);
      expect(find.text('No data'), findsNothing);
      await openBarMenu(tester);
      expect(find.text('Select all'), findsNothing);

      await teardownView(tester);
    });

    testWidgets('keeps the plain empty status once the permission is held', (
      tester,
    ) async {
      container.read(packagesProvider.notifier).value = [];
      seedAccessControl(const AccessControlProps(enable: true));

      await pumpAccessView(tester);

      expect(find.text('No data'), findsOneWidget);
      expect(find.text('App list permission required'), findsNothing);

      await teardownView(tester);
    });

    testWidgets('reloads the app list once the permission is granted', (
      tester,
    ) async {
      container.read(packagesProvider.notifier).value = [];
      systemAction.installedAppsPermissionGranted = false;
      systemAction.grantedPackages = _packages;
      seedAccessControl(const AccessControlProps(enable: true));
      await pumpAccessView(tester);

      await tester.tap(find.widgetWithText(FilledButton, 'Authorize'));
      await tester.pumpAndSettle();

      expect(systemAction.requestCount, 1);
      expect(find.text('App list permission required'), findsNothing);
      expect(find.text('Browser'), findsOneWidget);
      expect(find.text('Chat'), findsOneWidget);

      await teardownView(tester);
    });

    testWidgets('offers system settings when the permission stays denied', (
      tester,
    ) async {
      container.read(packagesProvider.notifier).value = [];
      systemAction.installedAppsPermissionGranted = false;
      systemAction.grantOnRequest = false;
      seedAccessControl(const AccessControlProps(enable: true));
      await pumpAccessView(tester);

      await tester.tap(find.widgetWithText(FilledButton, 'Authorize'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextButton, 'Settings'), findsOneWidget);

      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      await teardownView(tester);
    });
  });

  group('save', () {
    testWidgets('offers no save action while nothing has changed', (
      tester,
    ) async {
      seedAccessControl(const AccessControlProps(enable: true));

      await pumpAccessView(tester);
      await openBarMenu(tester);

      expect(find.text('Save'), findsNothing);

      await teardownView(tester);
    });

    testWidgets('drops hidden packages and sorts what it persists', (
      tester,
    ) async {
      seedAccessControl(
        const AccessControlProps(
          enable: true,
          rejectList: ['com.android.settings'],
        ),
      );
      await pumpAccessView(tester);

      await tester.tap(find.text('Chat'));
      await tester.pump();
      await tester.tap(find.text('Browser'));
      await tester.pump();

      await tester.tap(find.byTooltip('Save'));
      await tester.pumpAndSettle();

      final saved = container
          .read(vpnSettingProvider)
          .accessControlProps
          .rejectList;
      expect(saved, ['com.example.browser', 'com.example.chat']);

      await teardownView(tester);
    });
  });
}
