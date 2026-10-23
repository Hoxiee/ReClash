import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/plugins/notification.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/providers/notification.dart';
import 'package:reclash/views/application_notification.dart';
import 'package:reclash/views/notification_components.dart';
import 'package:reclash/features/form/list_editor_page.dart';
import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

void main() {
  late ProviderContainer container;
  const ready = AndroidNotificationStatus(
    permissionGranted: true,
    serviceChannelEnabled: true,
    subscriptionChannelEnabled: true,
  );
  const blocked = AndroidNotificationStatus(
    permissionGranted: false,
    serviceChannelEnabled: false,
    subscriptionChannelEnabled: true,
  );
  setUp(() {
    container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(TestProfiles.new),
        detectedRegionProvider.overrideWith((ref) async => null),
        notificationServerGroupProvider.overrideWith((ref) => 'Auto'),
      ],
    );
    container.listen(appSettingProvider, (_, _) {}, fireImmediately: true);
    container.read(viewSizeProvider.notifier).value = const Size(1200, 1800);
  });
  tearDown(() => container.dispose());
  Future<void> mount(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = const Size(1200, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(child: child),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('channel status is independent and opens the matching settings', (
    tester,
  ) async {
    final opened = <String?>[];
    await mount(
      tester,
      NotificationSettingsView(
        loadStatus: () async => blocked,
        openSettings: ({channelId}) async {
          opened.add(channelId);
          return true;
        },
        requestPermission: () async => false,
      ),
    );
    expect(find.text('Notifications are blocked for ReClash'), findsOneWidget);
    expect(
      find.text('The ReClash service channel is disabled'),
      findsOneWidget,
    );
    await tester.tap(find.text('Service channel'));
    await tester.pumpAndSettle();
    expect(opened, [serviceNotificationChannel]);
    await tester.tap(find.text('Subscription reminders channel'));
    await tester.pumpAndSettle();
    expect(opened.last, subscriptionNotificationChannel);
    await tester.tap(find.text('Notifications are blocked for ReClash'));
    await tester.pumpAndSettle();
    expect(opened.last, isNull);
  });

  testWidgets('minimal hides detailed controls and preserves their settings', (
    tester,
  ) async {
    container
        .read(appSettingProvider.notifier)
        .update(
          (state) => state.copyWith(
            notificationSettings: state.notificationSettings.copyWith(
              visibility: NotificationVisibility.detailed,
            ),
          ),
        );
    await mount(
      tester,
      NotificationSettingsView(loadStatus: () async => ready),
    );
    expect(find.text('Notification components'), findsOneWidget);
    await tester.tap(find.text('Notification level'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Minimal').last);
    await tester.pumpAndSettle();
    expect(find.text('Notification components'), findsNothing);
    expect(find.text('Subscription reminders'), findsWidgets);
    final settings = container.read(appSettingProvider).notificationSettings;
    expect(settings.visibility, NotificationVisibility.minimal);
    expect(settings.components, defaultNotificationComponents);
  });

  testWidgets('older status replies cannot overwrite a resumed refresh', (
    tester,
  ) async {
    final initial = Completer<AndroidNotificationStatus>();
    var calls = 0;
    await mount(
      tester,
      NotificationSettingsView(
        loadStatus: () => calls++ == 0 ? initial.future : Future.value(blocked),
      ),
    );
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    initial.complete(ready);
    await tester.pumpAndSettle();
    expect(find.text('Notifications are blocked for ReClash'), findsOneWidget);
  });

  testWidgets('failed settings actions release the busy guard', (tester) async {
    var calls = 0;
    await mount(
      tester,
      NotificationSettingsView(
        loadStatus: () async => ready,
        openSettings: ({channelId}) async {
          calls++;
          throw StateError('unavailable');
        },
      ),
    );
    await tester.tap(find.text('Service channel'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Service channel'));
    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('component editor persists ordering, deletion and adding', (
    tester,
  ) async {
    await mount(tester, const NotificationComponentsEditor());
    final editor = tester
        .widget<
          ListEditorPage<NotificationComponent, NotificationComponentType>
        >(
          find.byType(
            ListEditorPage<NotificationComponent, NotificationComponentType>,
          ),
        );
    editor.onReorder(0, 2);
    await tester.pumpAndSettle();
    expect(
      container
          .read(appSettingProvider)
          .notificationSettings
          .components
          .last
          .type,
      NotificationComponentType.currentServer,
    );
    final current = tester
        .widget<
          ListEditorPage<NotificationComponent, NotificationComponentType>
        >(
          find.byType(
            ListEditorPage<NotificationComponent, NotificationComponentType>,
          ),
        );
    current
        .menuItemsOf!(
          container
              .read(appSettingProvider)
              .notificationSettings
              .components
              .last,
        )
        .single
        .onPressed!();
    await tester.pumpAndSettle();
    expect(find.text('Current server'), findsNothing);
    final latest = tester
        .widget<
          ListEditorPage<NotificationComponent, NotificationComponentType>
        >(
          find.byType(
            ListEditorPage<NotificationComponent, NotificationComponentType>,
          ),
        );
    latest.onAdd();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Current server').last);
    await tester.pumpAndSettle();
    expect(
      container
          .read(appSettingProvider)
          .notificationSettings
          .components
          .last
          .type,
      NotificationComponentType.currentServer,
    );
    expect(tester.takeException(), isNull);
  });
}
