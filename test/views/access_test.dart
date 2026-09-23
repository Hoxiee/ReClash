import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/action.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/database.dart';
import 'package:reclash/providers/state.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/settings/access.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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
    container.read(packagesProvider.notifier).value = _packages;
  });

  tearDown(() => container.dispose());

  void seedAccessControl(AccessControlProps props) {
    container.read(vpnSettingProvider.notifier).value = const VpnProps()
        .copyWith(accessControlProps: props);
  }

  Future<void> pumpAccessView(
    WidgetTester tester, {
    Size size = const Size(1400, 1400),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    container.read(viewSizeProvider.notifier).update((_) => size);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: AccessView()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 301));
  }

  Future<void> teardownView(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
  }

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

  group('top controls', () {
    testWidgets('switches between include and exclude lists', (tester) async {
      seedAccessControl(
        const AccessControlProps(
          enable: true,
          rejectList: ['com.example.browser'],
        ),
      );
      await pumpAccessView(tester);

      await tester.tap(find.text('Include in VPN'));
      await tester.pumpAndSettle();
      expect(
        container.read(accessControlStateProvider).mode,
        AccessControlMode.acceptSelected,
      );
      expect(
        tester
            .widget<PackageListItem>(
              find.widgetWithText(PackageListItem, 'Browser'),
            )
            .value,
        isFalse,
      );

      await tester.tap(find.text('Chat'));
      await tester.pump();
      expect(container.read(accessControlStateProvider).acceptList, [
        'com.example.chat',
      ]);
      expect(container.read(accessControlStateProvider).rejectList, [
        'com.example.browser',
      ]);

      await tester.tap(find.text('Exclude from VPN'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<PackageListItem>(
              find.widgetWithText(PackageListItem, 'Browser'),
            )
            .value,
        isTrue,
      );

      await teardownView(tester);
    });

    testWidgets('filters from the inline search field and clears it', (
      tester,
    ) async {
      seedAccessControl(const AccessControlProps(enable: true));
      await pumpAccessView(tester);

      final searchField = find.byKey(const ValueKey('access-search-field'));
      await tester.enterText(searchField, 'CHAT');
      await tester.pump();
      expect(find.text('Chat'), findsOneWidget);
      expect(find.text('Browser'), findsNothing);

      await tester.tap(find.byTooltip('Clear search'));
      await tester.pump();
      expect(find.text('Browser'), findsOneWidget);
      expect(find.text('Chat'), findsOneWidget);
      expect(container.read(queryProvider(QueryTag.access)), isEmpty);

      await teardownView(tester);
    });

    testWidgets('keeps compact filters on one row', (tester) async {
      seedAccessControl(const AccessControlProps(enable: true));
      await pumpAccessView(tester, size: const Size(420, 900));

      final sortButton = find.byKey(const ValueKey('access-sort-chip'));
      final offlineFilter = find.byKey(
        const ValueKey('access-offline-apps-filter'),
      );
      expect(
        tester.getTopLeft(offlineFilter).dy,
        tester.getTopLeft(sortButton).dy,
      );
      expect(find.text('Sort'), findsNothing);
      expect(find.text('System apps'), findsNothing);
      expect(find.text('No network access'), findsNothing);
      expect(tester.takeException(), isNull);

      await teardownView(tester);
    });

    testWidgets('keeps controls fixed while the app list scrolls', (
      tester,
    ) async {
      container.read(packagesProvider.notifier).value = [
        for (var index = 0; index < 24; index++)
          _package('com.example.app$index', label: 'App $index'),
      ];
      seedAccessControl(const AccessControlProps(enable: true));
      await pumpAccessView(tester, size: const Size(700, 900));

      final panel = find.byKey(const ValueKey('access-control-panel'));
      final initialPanelTop = tester.getTopLeft(panel).dy;
      final initialFirstItemTop = tester.getTopLeft(find.text('App 0')).dy;

      await tester.drag(find.byType(ListView), const Offset(0, -240));
      await tester.pumpAndSettle();

      expect(tester.getTopLeft(panel).dy, initialPanelTop);
      expect(find.text('App 0'), findsNothing);
      expect(
        tester.getTopLeft(find.byType(PackageListItem).first).dy,
        lessThan(initialFirstItemTop),
      );

      await teardownView(tester);
    });

    testWidgets('toggles app sources and selects a sort order', (tester) async {
      seedAccessControl(const AccessControlProps(enable: true));
      await pumpAccessView(tester);

      await tester.tap(find.byKey(const ValueKey('access-system-apps-filter')));
      await tester.pump();
      expect(find.text('Settings'), findsOneWidget);
      expect(
        container.read(accessControlStateProvider).isFilterSystemApp,
        isFalse,
      );

      await tester.tap(find.byKey(const ValueKey('access-sort-chip')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Name').last);
      await tester.pumpAndSettle();
      expect(
        container.read(accessControlStateProvider).sort,
        AccessSortType.name,
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

    testWidgets('the action button selects then clears every visible app', (
      tester,
    ) async {
      seedAccessControl(const AccessControlProps(enable: true));
      await pumpAccessView(tester);

      await tester.tap(find.byType(FloatingActionButton).first);
      await tester.pump();
      expect(
        [...container.read(accessControlStateProvider).currentList]..sort(),
        ['com.example.browser', 'com.example.chat'],
      );

      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.byType(FloatingActionButton).first);
      await tester.pump();
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
      expect(find.byType(FloatingActionButton), findsNothing);

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

      expect(find.widgetWithText(FilledButton, 'Save'), findsNothing);

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

      final saveButton = find.widgetWithText(FilledButton, 'Save');
      expect(saveButton, findsOneWidget);
      await tester.tap(saveButton);
      await tester.pump();

      final saved = container
          .read(vpnSettingProvider)
          .accessControlProps
          .rejectList;
      expect(saved, ['com.example.browser', 'com.example.chat']);

      await teardownView(tester);
    });
  });
}
