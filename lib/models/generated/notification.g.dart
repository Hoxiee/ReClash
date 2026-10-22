// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationComponent _$NotificationComponentFromJson(
  Map<String, dynamic> json,
) => _NotificationComponent(
  type: $enumDecode(_$NotificationComponentTypeEnumMap, json['type']),
  hideWhenIdle: json['hideWhenIdle'] as bool? ?? true,
  group: json['group'] as String?,
);

Map<String, dynamic> _$NotificationComponentToJson(
  _NotificationComponent instance,
) => <String, dynamic>{
  'type': _$NotificationComponentTypeEnumMap[instance.type]!,
  'hideWhenIdle': instance.hideWhenIdle,
  'group': instance.group,
};

const _$NotificationComponentTypeEnumMap = {
  NotificationComponentType.currentServer: 'currentServer',
  NotificationComponentType.speed: 'speed',
  NotificationComponentType.sessionTraffic: 'sessionTraffic',
};

_NotificationSettings _$NotificationSettingsFromJson(
  Map<String, dynamic> json,
) => _NotificationSettings(
  visibility:
      $enumDecodeNullable(
        _$NotificationVisibilityEnumMap,
        json['visibility'],
      ) ??
      NotificationVisibility.detailed,
  components:
      (json['components'] as List<dynamic>?)
          ?.map(
            (e) => NotificationComponent.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      defaultNotificationComponents,
  showStopAction: json['showStopAction'] as bool? ?? true,
  hideSensitiveOnLockScreen: json['hideSensitiveOnLockScreen'] as bool? ?? true,
  subscriptionReminders: json['subscriptionReminders'] as bool? ?? true,
);

Map<String, dynamic> _$NotificationSettingsToJson(
  _NotificationSettings instance,
) => <String, dynamic>{
  'visibility': _$NotificationVisibilityEnumMap[instance.visibility]!,
  'components': instance.components,
  'showStopAction': instance.showStopAction,
  'hideSensitiveOnLockScreen': instance.hideSensitiveOnLockScreen,
  'subscriptionReminders': instance.subscriptionReminders,
};

const _$NotificationVisibilityEnumMap = {
  NotificationVisibility.detailed: 'detailed',
  NotificationVisibility.minimal: 'minimal',
};
