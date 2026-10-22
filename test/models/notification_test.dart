import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/models/models.dart';

void main() {
  test('legacy stop preference migrates without changing other settings', () {
    final settings = AppSettingProps.fromJson({
      'showNotificationStopAction': false,
    });
    expect(settings.notificationSettings.showStopAction, isFalse);
    expect(
      settings.notificationSettings.components,
      defaultNotificationComponents,
    );
    expect(
      AppSettingProps.fromJson({}).notificationSettings.showStopAction,
      isTrue,
    );
    expect(
      AppSettingProps.fromJson({
        'showNotificationStopAction': false,
        'notificationSettings': {'showStopAction': true},
      }).notificationSettings.showStopAction,
      isTrue,
    );
  });

  test('malformed components salvage known values in stored order', () {
    final settings = NotificationSettings.safeFromJson({
      'visibility': 'future',
      'components': [
        {'type': 'speed', 'hideWhenIdle': false},
        null,
        {'type': 'future'},
        {'type': 'speed'},
        {'type': 'currentServer', 'group': '  Auto  '},
      ],
      'showStopAction': false,
    });
    expect(settings.components, [
      const NotificationComponent(
        type: NotificationComponentType.speed,
        hideWhenIdle: false,
      ),
      const NotificationComponent(
        type: NotificationComponentType.currentServer,
        group: 'Auto',
      ),
    ]);
    expect(settings.detailed, isTrue);
    expect(settings.showStopAction, isFalse);
    expect(NotificationSettings.safeFromJson(7), const NotificationSettings());
  });

  test('explicit empty content survives config serialization', () {
    const settings = AppSettingProps(
      notificationSettings: NotificationSettings(components: []),
    );
    final restored = AppSettingProps.fromJson(
      jsonDecode(jsonEncode(settings.toJson())) as Map<String, Object?>,
    );
    expect(restored, settings);
    expect(
      NotificationSettings.safeFromJson({'components': 'bad'}).components,
      defaultNotificationComponents,
    );
  });

  test('minimal projection preserves the stored detailed configuration', () {
    const settings = NotificationSettings(
      visibility: NotificationVisibility.minimal,
      components: [
        NotificationComponent(
          type: NotificationComponentType.currentServer,
          group: 'Auto',
        ),
      ],
      hideSensitiveOnLockScreen: false,
    );
    expect(settings.projected.components, isEmpty);
    expect(settings.projected.showStopAction, isFalse);
    expect(settings.projected.hideSensitiveOnLockScreen, isFalse);
    expect(settings.components.single.group, 'Auto');
    expect(
      settings
          .copyWith(visibility: NotificationVisibility.detailed)
          .projected
          .components,
      settings.components,
    );
  });
}
