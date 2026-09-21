import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/plugins/app.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/application_notification.dart';
import 'package:reclash/views/application_setting.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late ProviderSubscription<AppSettingProps> settingsSubscription;

  setUp(() {
    container = ProviderContainer();
    globalState.container = container;
    // appSettingProvider is auto-dispose: without a subscription it resets the
    // moment a sheet closes, before the test can read what the sheet wrote.
    settingsSubscription = container.listen(appSettingProvider, (_, _) {});
  });

  tearDown(() {
    settingsSubscription.close();
    container.dispose();
  });

  void useViewport(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    // CommonDialog sizes itself from the provider the real app fills in from
    // the layout, so option dialogs collapse without it.
    container.read(viewSizeProvider.notifier).value = size;
  }

  Finder inert(Finder of) {
    return find.ancestor(
      of: of,
      matching: find.byWidgetPredicate(
        (widget) => widget is SliverIgnorePointer && widget.ignoring,
      ),
    );
  }

  Future<void> pumpTab(
    WidgetTester tester, {
    bool isAndroid = true,
    NotificationStatusLoader? loadStatus,
    NotificationSettingsOpener? openSettings,
    NotificationPermissionRequester? requestPermission,
  }) async {
    useViewport(tester, const Size(480, 1200));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: Scaffold(
            body: NotificationSettingsTab(
              isAndroid: isAndroid,
              loadStatus: loadStatus,
              openSettings: openSettings,
              requestPermission: requestPermission,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> pumpPreview(
    WidgetTester tester,
    NotificationSettings settings,
  ) async {
    useViewport(tester, const Size(480, 1000));
    await tester.pumpWidget(
      TestApp(
        child: Scaffold(
          body: SingleChildScrollView(
            child: NotificationPreview(settings: settings),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> pumpEditor(WidgetTester tester) async {
    useViewport(tester, const Size(480, 1200));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(
          child: Scaffold(body: NotificationComponentsEditor()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> pumpComponentSettings(
    WidgetTester tester,
    NotificationComponentType type,
  ) async {
    useViewport(tester, const Size(480, 900));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: Scaffold(body: NotificationComponentSettings(type: type)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> pushComponentSettings(
    WidgetTester tester,
    NotificationComponentType type,
  ) async {
    useViewport(tester, const Size(480, 900));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => Scaffold(
                      body: NotificationComponentSettings(type: type),
                    ),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Future<void> openEditor(WidgetTester tester) async {
    await pumpEditor(tester);
  }

  testWidgets('application keeps General and Notification tabs', (
    tester,
  ) async {
    useViewport(tester, const Size(480, 900));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: ApplicationSettingView()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('General'), findsWidgets);
    expect(find.text('Notification'), findsWidgets);
    await tester.tap(find.text('Notification').first);
    await tester.pumpAndSettle();

    expect(find.text('Available on Android'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('notification controls update the nested settings', (
    tester,
  ) async {
    await pumpTab(tester);
    await tester.scrollUntilVisible(find.text('Pause or resume'), 500);
    await tester.ensureVisible(find.text('Pause or resume'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pause or resume'));
    await tester.pumpAndSettle();

    expect(
      container.read(appSettingProvider).notificationSettings.showPauseAction,
      false,
    );

    await tester.scrollUntilVisible(find.text('Subscription reminders'), 500);
    await tester.ensureVisible(find.text('Subscription reminders'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Subscription reminders'));
    await tester.pumpAndSettle();

    expect(
      container
          .read(appSettingProvider)
          .notificationSettings
          .subscriptionReminders,
      false,
    );
  });

  testWidgets('level option strips the notification down to the status', (
    tester,
  ) async {
    await pumpTab(tester);
    expect(
      container.read(appSettingProvider).notificationSettings.visibility,
      NotificationVisibility.detailed,
    );

    await tester.tap(find.text('Notification level'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Minimal').last);
    await tester.pumpAndSettle();
    final settings = container.read(appSettingProvider).notificationSettings;
    expect(settings.visibility, NotificationVisibility.minimal);
    expect(settings.projected.components, isEmpty);
    expect(settings.projected.showPauseAction, false);
    expect(settings.projected.showStopAction, false);
    expect(find.text('You are protected'), findsOneWidget);
    expect(inert(find.text('Pause or resume')), findsOneWidget);
  });

  testWidgets('a disabled service channel reads as the off state', (
    tester,
  ) async {
    await pumpTab(
      tester,
      loadStatus: () async => const AndroidNotificationStatus(
        permissionGranted: true,
        serviceChannelEnabled: false,
        subscriptionChannelEnabled: true,
      ),
    );

    expect(
      find.text('The notification is turned off in system settings'),
      findsOneWidget,
    );
    expect(find.text('Off'), findsNothing);
  });

  testWidgets('turn-off row deep-links to the single service channel', (
    tester,
  ) async {
    final opened = <String?>[];
    await pumpTab(
      tester,
      openSettings: ({String? channelId}) async {
        opened.add(channelId);
        return true;
      },
    );

    await tester.tap(find.text('Turn off notification'));
    await tester.pumpAndSettle();

    expect(opened, ['ReClash']);
  });

  List<NotificationComponentType> readTypes() => container
      .read(appSettingProvider)
      .notificationSettings
      .components
      .map((item) => item.type)
      .toList();

  testWidgets('editor splits active components from the ones left to add', (
    tester,
  ) async {
    await openEditor(tester);

    expect(find.text('In the notification'), findsOneWidget);
    expect(find.text('Connection Doctor'), findsOneWidget);
    expect(find.byTooltip('Reorder'), findsNWidgets(4));

    expect(find.text('Add component'), findsOneWidget);
    expect(find.text('Network state'), findsOneWidget);
    expect(find.text('Current server'), findsOneWidget);
    expect(find.byIcon(Icons.add_rounded), findsNWidgets(2));

    await tester.tap(find.text('Network state'));
    await tester.pumpAndSettle();
    expect(readTypes().last, NotificationComponentType.networkState);
    expect(find.byTooltip('Reorder'), findsNWidgets(5));

    await tester.tap(find.text('Current server'));
    await tester.pumpAndSettle();
    expect(find.text('Add component'), findsNothing);
    expect(find.byIcon(Icons.add_rounded), findsNothing);
  });

  testWidgets('editor offers every component once nothing is active', (
    tester,
  ) async {
    container
        .read(appSettingProvider.notifier)
        .update(
          (state) => state.copyWith(
            notificationSettings: state.notificationSettings.copyWith(
              components: const [],
            ),
          ),
        );
    await openEditor(tester);

    expect(find.text('No components added'), findsOneWidget);
    expect(find.byType(SliverReorderableList), findsNothing);
    expect(
      find.byIcon(Icons.add_rounded),
      findsNWidgets(NotificationComponentType.values.length),
    );
  });

  testWidgets('editor reports the components the service cannot print', (
    tester,
  ) async {
    await openEditor(tester);

    expect(
      find.text('Smart routing is off, so this line is hidden'),
      findsOneWidget,
    );
    expect(find.text('Hidden while no traffic is flowing'), findsOneWidget);

    await tester.tap(find.text('Current server'));
    await tester.pumpAndSettle();
    expect(
      find.text('No server group is resolved, so this line is hidden'),
      findsOneWidget,
    );
  });

  testWidgets('editor separates a silent line from a broken one', (
    tester,
  ) async {
    container.read(groupsProvider.notifier).value = const [
      Group(type: GroupType.Selector, name: 'Visible', hidden: false),
    ];
    container
        .read(appSettingProvider.notifier)
        .update(
          (state) => state.copyWith(
            notificationSettings: state.notificationSettings.copyWith(
              components: const [
                NotificationComponent(
                  type: NotificationComponentType.smartRouting,
                ),
                NotificationComponent(
                  type: NotificationComponentType.currentServer,
                  group: 'Gone',
                ),
              ],
            ),
          ),
        );
    await openEditor(tester);

    expect(
      find.text('The chosen group is missing from the profile'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
  });

  testWidgets('editor reorder callback and semantics preserve exact order', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await openEditor(tester);

    final list = tester.widget<SliverReorderableList>(
      find.byType(SliverReorderableList),
    );
    list.onReorderItem!(0, 2);
    await tester.pumpAndSettle();
    expect(readTypes(), [
      NotificationComponentType.smartRouting,
      NotificationComponentType.speed,
      NotificationComponentType.connectionDoctor,
      NotificationComponentType.sessionTraffic,
    ]);

    final node = tester.getSemantics(
      find.byKey(const ValueKey(NotificationComponentType.speed)),
    );
    final labels = node
        .getSemanticsData()
        .customSemanticsActionIds!
        .map((id) => CustomSemanticsAction.getAction(id)!.label)
        .toSet();
    expect(labels, containsAll(['Move up', 'Move down']));
    semantics.dispose();
  });

  testWidgets('component sheet states the line, its timing and the exit', (
    tester,
  ) async {
    await pushComponentSettings(tester, NotificationComponentType.speed);

    expect(find.text('↓ 12.4 MB/s  ↑ 1.8 MB/s'), findsOneWidget);
    expect(find.text('Hidden while no traffic is flowing'), findsOneWidget);
    expect(find.text('Behaviour'), findsOneWidget);

    await tester.tap(find.text('Remove from notification'));
    await tester.pumpAndSettle();
    expect(find.text('Remove from notification'), findsNothing);
    expect(readTypes().contains(NotificationComponentType.speed), false);
  });

  testWidgets('component sheet marks the collapsed line', (tester) async {
    await pumpComponentSettings(
      tester,
      NotificationComponentType.connectionDoctor,
    );
    expect(
      find.text('Shown while the notification is collapsed'),
      findsOneWidget,
    );

    await pumpComponentSettings(
      tester,
      NotificationComponentType.sessionTraffic,
    );
    expect(
      find.text('Shown while the notification is collapsed'),
      findsNothing,
    );
  });

  testWidgets('doctor and speed component settings write provider', (
    tester,
  ) async {
    await pumpComponentSettings(
      tester,
      NotificationComponentType.connectionDoctor,
    );
    await tester.tap(find.text('Problems only'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Always'));
    await tester.pumpAndSettle();
    expect(
      container
          .read(appSettingProvider)
          .notificationSettings
          .components
          .first
          .doctorPriority,
      DoctorNotificationPriority.always,
    );

    await pumpComponentSettings(tester, NotificationComponentType.speed);
    await tester.tap(find.text('Hide idle speed'));
    await tester.pumpAndSettle();
    expect(
      container
          .read(appSettingProvider)
          .notificationSettings
          .components
          .firstWhere((item) => item.type == NotificationComponentType.speed)
          .hideWhenIdle,
      false,
    );
  });
  testWidgets('current server offers mode-filtered display groups', (
    tester,
  ) async {
    container.read(groupsProvider.notifier).value = const [
      Group(type: GroupType.Selector, name: 'Visible', hidden: false),
      Group(type: GroupType.Selector, name: 'Hidden', hidden: true),
      Group(type: GroupType.Selector, name: 'GLOBAL', hidden: false),
    ];
    container
        .read(appSettingProvider.notifier)
        .update(
          (state) => state.copyWith(
            notificationSettings: state.notificationSettings.copyWith(
              components: const [
                NotificationComponent(
                  type: NotificationComponentType.currentServer,
                ),
              ],
            ),
          ),
        );
    await pumpComponentSettings(
      tester,
      NotificationComponentType.currentServer,
    );
    await tester.tap(find.text('Automatic group'));
    await tester.pumpAndSettle();

    expect(find.text('Visible'), findsOneWidget);
    expect(find.text('Hidden'), findsNothing);
    expect(find.text('GLOBAL'), findsNothing);
    await tester.tap(find.text('Visible'));
    await tester.pumpAndSettle();
    expect(
      container
          .read(appSettingProvider)
          .notificationSettings
          .components
          .single
          .group,
      'Visible',
    );
  });

  testWidgets('preview follows exact component order and empty fallback', (
    tester,
  ) async {
    await pumpPreview(
      tester,
      const NotificationSettings(
        components: [
          NotificationComponent(type: NotificationComponentType.currentServer),
          NotificationComponent(
            type: NotificationComponentType.speed,
            hideWhenIdle: false,
          ),
          NotificationComponent(type: NotificationComponentType.sessionTraffic),
        ],
      ),
    );
    final server = tester.getTopLeft(find.text('Server · Tokyo 01')).dy;
    final speed = tester.getTopLeft(find.text('↓ 12.4 MB/s  ↑ 1.8 MB/s')).dy;
    final session = tester
        .getTopLeft(find.text('Session · ↓ 1.2 GB  ↑ 184 MB'))
        .dy;
    expect(server, lessThan(speed));
    expect(speed, lessThan(session));

    await pumpPreview(tester, const NotificationSettings(components: []));
    expect(find.text('You are protected'), findsOneWidget);
  });

  testWidgets('preview applies active, paused and privacy availability', (
    tester,
  ) async {
    await pumpPreview(
      tester,
      const NotificationSettings(
        components: [
          NotificationComponent(
            type: NotificationComponentType.connectionDoctor,
            doctorPriority: DoctorNotificationPriority.problems,
          ),
          NotificationComponent(type: NotificationComponentType.networkState),
          NotificationComponent(type: NotificationComponentType.smartRouting),
          NotificationComponent(
            type: NotificationComponentType.speed,
            hideWhenIdle: true,
          ),
        ],
      ),
    );
    expect(find.text('↓ 12.4 MB/s  ↑ 1.8 MB/s'), findsNothing);
    await tester.tap(find.text('Routing'));
    await tester.pumpAndSettle();
    expect(find.text('Network · Normal'), findsOneWidget);
    expect(find.text('Smart Routing · Automatic route'), findsOneWidget);
    expect(find.text('↓ 12.4 MB/s  ↑ 1.8 MB/s'), findsOneWidget);

    await tester.tap(find.text('Problem'));
    await tester.pumpAndSettle();
    expect(find.text('Connection Doctor: problem detected'), findsOneWidget);
    await tester.tap(find.text('Paused'));
    await tester.pumpAndSettle();
    expect(find.text('ReClash · Protection paused'), findsOneWidget);
    expect(find.text('Pause'), findsNothing);
    expect(find.text('Stop'), findsNothing);

    await tester.tap(find.text('Lock screen'));
    await tester.pumpAndSettle();
    expect(find.text('ReClash · Protected details hidden'), findsOneWidget);
    expect(find.text('Pause'), findsNothing);
    expect(find.text('Stop'), findsNothing);
  });

  testWidgets(
    'does not duplicate onlyStatisticsProxy in notification settings',
    (tester) async {
      await pumpTab(tester);

      expect(find.text('Only count proxy traffic'), findsNothing);
    },
  );

  testWidgets('blocked permission asks the system, then the settings screen', (
    tester,
  ) async {
    var granted = false;
    var requests = 0;
    final opened = <String?>[];
    await pumpTab(
      tester,
      loadStatus: () async => AndroidNotificationStatus(
        permissionGranted: granted,
        serviceChannelEnabled: true,
        subscriptionChannelEnabled: true,
      ),
      openSettings: ({String? channelId}) async {
        opened.add(channelId);
        return true;
      },
      requestPermission: () async {
        requests++;
        return granted;
      },
    );

    expect(find.text('Fix'), findsOneWidget);
    await tester.tap(find.text('Notifications are blocked for ReClash'));
    await tester.pumpAndSettle();
    expect(requests, 1);
    expect(opened, [null]);

    granted = true;
    await tester.tap(find.text('Notifications are blocked for ReClash'));
    await tester.pumpAndSettle();
    expect(requests, 2);
    expect(opened, [null]);
    expect(find.text('Notifications can be delivered'), findsOneWidget);
    expect(find.text('Fix'), findsNothing);
  });
}
