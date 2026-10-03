import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/plugins/app.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/settings/application_notification.dart';
import 'package:reclash/views/settings/application_setting.dart';
import 'package:reclash/widgets/widgets.dart';

import '../helpers/glyph_finders.dart';
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

  Future<void> pumpView(
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
            body: NotificationSettingsView(
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

  Future<void> openEditor(WidgetTester tester) async {
    await pumpEditor(tester);
  }

  // Add and Reset live in the scaffold overflow menu, mirroring the DNS/NTP
  // override editors; a new component is chosen from the selection sheet Add
  // opens.
  Future<void> addComponent(WidgetTester tester, String label) async {
    await tester.tap(find.byGlyph(AppGlyphs.more));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(label, findRichText: true));
    await tester.pumpAndSettle();
  }

  Finder removeButtonFor(String title) => find.descendant(
    of: find.ancestor(
      of: find.text(title),
      matching: find.byType(DecorationListItem),
    ),
    matching: find.byTooltip('Remove'),
  );

  testWidgets('the notification row is hidden off Android', (tester) async {
    useViewport(tester, const Size(480, 900));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: ApplicationSettingView()),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(
        'The persistent notification shows whether your protection is active.',
      ),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('action buttons and reminders toggle the nested settings', (
    tester,
  ) async {
    await pumpView(tester);
    await tester.tap(find.text('Notification level'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Detailed').last);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Action buttons'), 500);
    await tester.ensureVisible(find.text('Action buttons'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Action buttons'));
    await tester.pumpAndSettle();

    final settings = container.read(appSettingProvider).notificationSettings;
    expect(settings.showPauseAction, false);
    expect(settings.showStopAction, false);

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

  testWidgets('level option defaults to minimal and expands on demand', (
    tester,
  ) async {
    await pumpView(tester);
    expect(
      container.read(appSettingProvider).notificationSettings.visibility,
      NotificationVisibility.minimal,
    );

    await tester.tap(find.text('Notification level'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Detailed').last);
    await tester.pumpAndSettle();
    final settings = container.read(appSettingProvider).notificationSettings;
    expect(settings.visibility, NotificationVisibility.detailed);
    expect(settings.projected.components, isNotEmpty);
    expect(settings.projected.showPauseAction, true);
    expect(settings.projected.showStopAction, true);
  });

  testWidgets('a disabled service channel reads as the off state', (
    tester,
  ) async {
    await pumpView(
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
    await pumpView(
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

  testWidgets(
    'privacy changes apply at minimal level and link to Android settings',
    (tester) async {
      final opened = <String?>[];
      await pumpView(
        tester,
        openSettings: ({String? channelId}) async {
          opened.add(channelId);
          return true;
        },
      );
      final privacy = find.text('Hide sensitive details on lock screen');
      await tester.scrollUntilVisible(privacy, 400);
      await tester.tap(privacy);
      await tester.pumpAndSettle();
      expect(
        container
            .read(appSettingProvider)
            .notificationSettings
            .hideSensitiveOnLockScreen,
        isFalse,
      );

      await tester.scrollUntilVisible(find.text('Open settings'), 400);
      await tester.tap(find.text('Open settings'));
      await tester.pumpAndSettle();
      expect(opened, [null]);
    },
  );

  List<NotificationComponentType> readTypes() => container
      .read(appSettingProvider)
      .notificationSettings
      .components
      .map((item) => item.type)
      .toList();

  testWidgets('editor shows active rows and adds the rest from the menu', (
    tester,
  ) async {
    await openEditor(tester);

    expect(find.text('Connection Doctor'), findsOneWidget);
    expect(find.byTooltip('Remove'), findsNWidgets(4));
    expect(find.text('Network state'), findsNothing);
    expect(find.text('Current server'), findsNothing);

    await addComponent(tester, 'Network state');
    expect(readTypes().last, NotificationComponentType.networkState);
    expect(find.byTooltip('Remove'), findsNWidgets(5));

    await addComponent(tester, 'Current server');
    expect(readTypes().length, NotificationComponentType.values.length);
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

    expect(
      find.text(
        'Without components the notification shows only the protection status.',
      ),
      findsOneWidget,
    );
    expect(find.byTooltip('Remove'), findsNothing);

    await addComponent(tester, 'Connection Doctor');
    expect(readTypes(), [NotificationComponentType.connectionDoctor]);
    expect(find.byTooltip('Remove'), findsOneWidget);
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

    await addComponent(tester, 'Current server');
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
    expect(find.byGlyph(AppGlyphs.error), findsOneWidget);
    expect(find.byGlyph(AppGlyphs.eyeOff), findsOneWidget);
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

  testWidgets('inline remove drops the component from the notification', (
    tester,
  ) async {
    await openEditor(tester);

    expect(find.text('Network speed'), findsOneWidget);
    await tester.tap(removeButtonFor('Network speed'));
    await tester.pumpAndSettle();

    expect(find.text('Network speed'), findsNothing);
    expect(readTypes().contains(NotificationComponentType.speed), false);
  });

  testWidgets('doctor and speed rows edit their option in place', (
    tester,
  ) async {
    await openEditor(tester);

    await tester.tap(find.text('Connection Doctor'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Always').last);
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

    await tester.tap(find.text('Network speed'));
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

  testWidgets('current server row offers mode-filtered display groups', (
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
    await openEditor(tester);

    await tester.tap(find.text('Current server'));
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

  testWidgets(
    'does not duplicate onlyStatisticsProxy in notification settings',
    (tester) async {
      await pumpView(tester);

      expect(find.text('Only count proxy traffic'), findsNothing);
    },
  );

  testWidgets('blocked permission asks the system, then the settings screen', (
    tester,
  ) async {
    var granted = false;
    var requests = 0;
    final opened = <String?>[];
    await pumpView(
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
