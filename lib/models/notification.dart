import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/notification.freezed.dart';
part 'generated/notification.g.dart';

enum NotificationVisibility { detailed, minimal }

enum NotificationComponentType { currentServer, speed, sessionTraffic }

const defaultNotificationComponents = [
  NotificationComponent(type: NotificationComponentType.currentServer),
  NotificationComponent(
    type: NotificationComponentType.speed,
    hideWhenIdle: true,
  ),
  NotificationComponent(type: NotificationComponentType.sessionTraffic),
];

@freezed
abstract class NotificationComponent with _$NotificationComponent {
  const factory NotificationComponent({
    required NotificationComponentType type,
    @Default(true) bool hideWhenIdle,
    String? group,
  }) = _NotificationComponent;

  factory NotificationComponent.fromJson(Map<String, Object?> json) =>
      _$NotificationComponentFromJson(json);
}

@freezed
abstract class NotificationSettings with _$NotificationSettings {
  const factory NotificationSettings({
    @Default(NotificationVisibility.minimal) NotificationVisibility visibility,
    @Default(defaultNotificationComponents)
    List<NotificationComponent> components,
    @Default(true) bool showStopAction,
    @Default(true) bool hideSensitiveOnLockScreen,
    @Default(true) bool subscriptionReminders,
  }) = _NotificationSettings;

  factory NotificationSettings.fromJson(Map<String, Object?> json) =>
      _$NotificationSettingsFromJson(json);

  static NotificationSettings safeFromJson(Object? value) {
    if (value is! Map) return const NotificationSettings();
    final rawComponents = value['components'];
    final components = <NotificationComponent>[];
    final seen = <NotificationComponentType>{};
    if (rawComponents is List) {
      for (final raw in rawComponents) {
        if (raw is! Map) continue;
        final type = NotificationComponentType.values
            .where((type) => type.name == raw['type'])
            .firstOrNull;
        if (type == null || !seen.add(type)) continue;
        final group = raw['group'];
        components.add(
          NotificationComponent(
            type: type,
            hideWhenIdle: raw['hideWhenIdle'] != false,
            group:
                type == NotificationComponentType.currentServer &&
                    group is String &&
                    group.trim().isNotEmpty
                ? group.trim()
                : null,
          ),
        );
      }
    }
    return NotificationSettings(
      visibility: value['visibility'] == 'detailed'
          ? NotificationVisibility.detailed
          : NotificationVisibility.minimal,
      components: rawComponents is List
          ? components
          : defaultNotificationComponents,
      showStopAction: value['showStopAction'] != false,
      hideSensitiveOnLockScreen: value['hideSensitiveOnLockScreen'] != false,
      subscriptionReminders: value['subscriptionReminders'] != false,
    );
  }
}

Object? readNotificationSettings(Map<dynamic, dynamic> json, String key) =>
    json[key] ??
    {'showStopAction': json['showNotificationStopAction'] != false};

extension NotificationSettingsProjection on NotificationSettings {
  bool get detailed => visibility == NotificationVisibility.detailed;
  NotificationSettings get projected =>
      detailed ? this : copyWith(components: const [], showStopAction: false);
}
