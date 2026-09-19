// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotificationComponent {

 NotificationComponentType get type; DoctorNotificationPriority? get doctorPriority; bool? get hideWhenIdle; String? get group;
/// Create a copy of NotificationComponent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationComponentCopyWith<NotificationComponent> get copyWith => _$NotificationComponentCopyWithImpl<NotificationComponent>(this as NotificationComponent, _$identity);

  /// Serializes this NotificationComponent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as NotificationComponent;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationComponent&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.doctorPriority, _this.doctorPriority) || other.doctorPriority == _this.doctorPriority)&&(identical(other.hideWhenIdle, _this.hideWhenIdle) || other.hideWhenIdle == _this.hideWhenIdle)&&(identical(other.group, _this.group) || other.group == _this.group));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as NotificationComponent;
  return Object.hash(runtimeType,_this.type,_this.doctorPriority,_this.hideWhenIdle,_this.group);
}

@override
String toString() {
  final _this = this as NotificationComponent;
  return 'NotificationComponent(type: ${_this.type}, doctorPriority: ${_this.doctorPriority}, hideWhenIdle: ${_this.hideWhenIdle}, group: ${_this.group})';
}


}

/// @nodoc
abstract mixin class $NotificationComponentCopyWith<$Res>  {
  factory $NotificationComponentCopyWith(NotificationComponent value, $Res Function(NotificationComponent) _then) = _$NotificationComponentCopyWithImpl;
@useResult
$Res call({
 NotificationComponentType type, DoctorNotificationPriority? doctorPriority, bool? hideWhenIdle, String? group
});




}
/// @nodoc
class _$NotificationComponentCopyWithImpl<$Res>
    implements $NotificationComponentCopyWith<$Res> {
  _$NotificationComponentCopyWithImpl(this._self, this._then);

  final NotificationComponent _self;
  final $Res Function(NotificationComponent) _then;

/// Create a copy of NotificationComponent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? doctorPriority = freezed,Object? hideWhenIdle = freezed,Object? group = freezed,}) {
  return _then(NotificationComponent(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as NotificationComponentType,doctorPriority: freezed == doctorPriority ? _self.doctorPriority : doctorPriority // ignore: cast_nullable_to_non_nullable
as DoctorNotificationPriority?,hideWhenIdle: freezed == hideWhenIdle ? _self.hideWhenIdle : hideWhenIdle // ignore: cast_nullable_to_non_nullable
as bool?,group: freezed == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationComponent].
extension NotificationComponentPatterns on NotificationComponent {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationComponent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationComponent() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationComponent value)  $default,){
final _that = this;
switch (_that) {
case _NotificationComponent():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationComponent value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationComponent() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( NotificationComponentType type,  DoctorNotificationPriority? doctorPriority,  bool? hideWhenIdle,  String? group)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationComponent() when $default != null:
return $default(_that.type,_that.doctorPriority,_that.hideWhenIdle,_that.group);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( NotificationComponentType type,  DoctorNotificationPriority? doctorPriority,  bool? hideWhenIdle,  String? group)  $default,) {final _that = this;
switch (_that) {
case _NotificationComponent():
return $default(_that.type,_that.doctorPriority,_that.hideWhenIdle,_that.group);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( NotificationComponentType type,  DoctorNotificationPriority? doctorPriority,  bool? hideWhenIdle,  String? group)?  $default,) {final _that = this;
switch (_that) {
case _NotificationComponent() when $default != null:
return $default(_that.type,_that.doctorPriority,_that.hideWhenIdle,_that.group);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationComponent implements NotificationComponent {
  const _NotificationComponent({required this.type, this.doctorPriority, this.hideWhenIdle, this.group});
  factory _NotificationComponent.fromJson(Map<String, dynamic> json) => _$NotificationComponentFromJson(json);

@override final  NotificationComponentType type;
@override final  DoctorNotificationPriority? doctorPriority;
@override final  bool? hideWhenIdle;
@override final  String? group;

/// Create a copy of NotificationComponent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationComponentCopyWith<_NotificationComponent> get copyWith => __$NotificationComponentCopyWithImpl<_NotificationComponent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationComponentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationComponent&&(identical(other.type, type) || other.type == type)&&(identical(other.doctorPriority, doctorPriority) || other.doctorPriority == doctorPriority)&&(identical(other.hideWhenIdle, hideWhenIdle) || other.hideWhenIdle == hideWhenIdle)&&(identical(other.group, group) || other.group == group));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,type,doctorPriority,hideWhenIdle,group);
}

@override
String toString() {
    return 'NotificationComponent(type: $type, doctorPriority: $doctorPriority, hideWhenIdle: $hideWhenIdle, group: $group)';
}


}

/// @nodoc
abstract mixin class _$NotificationComponentCopyWith<$Res> implements $NotificationComponentCopyWith<$Res> {
  factory _$NotificationComponentCopyWith(_NotificationComponent value, $Res Function(_NotificationComponent) _then) = __$NotificationComponentCopyWithImpl;
@override @useResult
$Res call({
 NotificationComponentType type, DoctorNotificationPriority? doctorPriority, bool? hideWhenIdle, String? group
});




}
/// @nodoc
class __$NotificationComponentCopyWithImpl<$Res>
    implements _$NotificationComponentCopyWith<$Res> {
  __$NotificationComponentCopyWithImpl(this._self, this._then);

  final _NotificationComponent _self;
  final $Res Function(_NotificationComponent) _then;

/// Create a copy of NotificationComponent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? doctorPriority = freezed,Object? hideWhenIdle = freezed,Object? group = freezed,}) {
  return _then(_NotificationComponent(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as NotificationComponentType,doctorPriority: freezed == doctorPriority ? _self.doctorPriority : doctorPriority // ignore: cast_nullable_to_non_nullable
as DoctorNotificationPriority?,hideWhenIdle: freezed == hideWhenIdle ? _self.hideWhenIdle : hideWhenIdle // ignore: cast_nullable_to_non_nullable
as bool?,group: freezed == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$NotificationSettings {

@JsonKey(fromJson: notificationComponentsSafeFromJson) List<NotificationComponent> get components; NotificationVisibility get visibility; bool get showPauseAction; bool get showStopAction; bool get hideSensitiveOnLockScreen; bool get subscriptionReminders;
/// Create a copy of NotificationSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationSettingsCopyWith<NotificationSettings> get copyWith => _$NotificationSettingsCopyWithImpl<NotificationSettings>(this as NotificationSettings, _$identity);

  /// Serializes this NotificationSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as NotificationSettings;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationSettings&&const DeepCollectionEquality().equals(other.components, _this.components)&&(identical(other.visibility, _this.visibility) || other.visibility == _this.visibility)&&(identical(other.showPauseAction, _this.showPauseAction) || other.showPauseAction == _this.showPauseAction)&&(identical(other.showStopAction, _this.showStopAction) || other.showStopAction == _this.showStopAction)&&(identical(other.hideSensitiveOnLockScreen, _this.hideSensitiveOnLockScreen) || other.hideSensitiveOnLockScreen == _this.hideSensitiveOnLockScreen)&&(identical(other.subscriptionReminders, _this.subscriptionReminders) || other.subscriptionReminders == _this.subscriptionReminders));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as NotificationSettings;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.components),_this.visibility,_this.showPauseAction,_this.showStopAction,_this.hideSensitiveOnLockScreen,_this.subscriptionReminders);
}

@override
String toString() {
  final _this = this as NotificationSettings;
  return 'NotificationSettings(components: ${_this.components}, visibility: ${_this.visibility}, showPauseAction: ${_this.showPauseAction}, showStopAction: ${_this.showStopAction}, hideSensitiveOnLockScreen: ${_this.hideSensitiveOnLockScreen}, subscriptionReminders: ${_this.subscriptionReminders})';
}


}

/// @nodoc
abstract mixin class $NotificationSettingsCopyWith<$Res>  {
  factory $NotificationSettingsCopyWith(NotificationSettings value, $Res Function(NotificationSettings) _then) = _$NotificationSettingsCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: notificationComponentsSafeFromJson) List<NotificationComponent> components, NotificationVisibility visibility, bool showPauseAction, bool showStopAction, bool hideSensitiveOnLockScreen, bool subscriptionReminders
});




}
/// @nodoc
class _$NotificationSettingsCopyWithImpl<$Res>
    implements $NotificationSettingsCopyWith<$Res> {
  _$NotificationSettingsCopyWithImpl(this._self, this._then);

  final NotificationSettings _self;
  final $Res Function(NotificationSettings) _then;

/// Create a copy of NotificationSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? components = null,Object? visibility = null,Object? showPauseAction = null,Object? showStopAction = null,Object? hideSensitiveOnLockScreen = null,Object? subscriptionReminders = null,}) {
  return _then(NotificationSettings(
components: null == components ? _self.components : components // ignore: cast_nullable_to_non_nullable
as List<NotificationComponent>,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as NotificationVisibility,showPauseAction: null == showPauseAction ? _self.showPauseAction : showPauseAction // ignore: cast_nullable_to_non_nullable
as bool,showStopAction: null == showStopAction ? _self.showStopAction : showStopAction // ignore: cast_nullable_to_non_nullable
as bool,hideSensitiveOnLockScreen: null == hideSensitiveOnLockScreen ? _self.hideSensitiveOnLockScreen : hideSensitiveOnLockScreen // ignore: cast_nullable_to_non_nullable
as bool,subscriptionReminders: null == subscriptionReminders ? _self.subscriptionReminders : subscriptionReminders // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationSettings].
extension NotificationSettingsPatterns on NotificationSettings {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationSettings() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationSettings value)  $default,){
final _that = this;
switch (_that) {
case _NotificationSettings():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationSettings value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationSettings() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: notificationComponentsSafeFromJson)  List<NotificationComponent> components,  NotificationVisibility visibility,  bool showPauseAction,  bool showStopAction,  bool hideSensitiveOnLockScreen,  bool subscriptionReminders)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationSettings() when $default != null:
return $default(_that.components,_that.visibility,_that.showPauseAction,_that.showStopAction,_that.hideSensitiveOnLockScreen,_that.subscriptionReminders);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: notificationComponentsSafeFromJson)  List<NotificationComponent> components,  NotificationVisibility visibility,  bool showPauseAction,  bool showStopAction,  bool hideSensitiveOnLockScreen,  bool subscriptionReminders)  $default,) {final _that = this;
switch (_that) {
case _NotificationSettings():
return $default(_that.components,_that.visibility,_that.showPauseAction,_that.showStopAction,_that.hideSensitiveOnLockScreen,_that.subscriptionReminders);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: notificationComponentsSafeFromJson)  List<NotificationComponent> components,  NotificationVisibility visibility,  bool showPauseAction,  bool showStopAction,  bool hideSensitiveOnLockScreen,  bool subscriptionReminders)?  $default,) {final _that = this;
switch (_that) {
case _NotificationSettings() when $default != null:
return $default(_that.components,_that.visibility,_that.showPauseAction,_that.showStopAction,_that.hideSensitiveOnLockScreen,_that.subscriptionReminders);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationSettings implements NotificationSettings {
  const _NotificationSettings({@JsonKey(fromJson: notificationComponentsSafeFromJson)  List<NotificationComponent> components = defaultNotificationComponents, this.visibility = NotificationVisibility.detailed, this.showPauseAction = true, this.showStopAction = true, this.hideSensitiveOnLockScreen = true, this.subscriptionReminders = true}): _components = components;
  factory _NotificationSettings.fromJson(Map<String, dynamic> json) => _$NotificationSettingsFromJson(json);

 final  List<NotificationComponent> _components;
@override@JsonKey(fromJson: notificationComponentsSafeFromJson) List<NotificationComponent> get components {
  if (_components is EqualUnmodifiableListView) return _components;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_components);
}

@override@JsonKey() final  NotificationVisibility visibility;
@override@JsonKey() final  bool showPauseAction;
@override@JsonKey() final  bool showStopAction;
@override@JsonKey() final  bool hideSensitiveOnLockScreen;
@override@JsonKey() final  bool subscriptionReminders;

/// Create a copy of NotificationSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationSettingsCopyWith<_NotificationSettings> get copyWith => __$NotificationSettingsCopyWithImpl<_NotificationSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationSettings&&const DeepCollectionEquality().equals(other.components, _components)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.showPauseAction, showPauseAction) || other.showPauseAction == showPauseAction)&&(identical(other.showStopAction, showStopAction) || other.showStopAction == showStopAction)&&(identical(other.hideSensitiveOnLockScreen, hideSensitiveOnLockScreen) || other.hideSensitiveOnLockScreen == hideSensitiveOnLockScreen)&&(identical(other.subscriptionReminders, subscriptionReminders) || other.subscriptionReminders == subscriptionReminders));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_components),visibility,showPauseAction,showStopAction,hideSensitiveOnLockScreen,subscriptionReminders);
}

@override
String toString() {
    return 'NotificationSettings(components: $components, visibility: $visibility, showPauseAction: $showPauseAction, showStopAction: $showStopAction, hideSensitiveOnLockScreen: $hideSensitiveOnLockScreen, subscriptionReminders: $subscriptionReminders)';
}


}

/// @nodoc
abstract mixin class _$NotificationSettingsCopyWith<$Res> implements $NotificationSettingsCopyWith<$Res> {
  factory _$NotificationSettingsCopyWith(_NotificationSettings value, $Res Function(_NotificationSettings) _then) = __$NotificationSettingsCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: notificationComponentsSafeFromJson) List<NotificationComponent> components, NotificationVisibility visibility, bool showPauseAction, bool showStopAction, bool hideSensitiveOnLockScreen, bool subscriptionReminders
});




}
/// @nodoc
class __$NotificationSettingsCopyWithImpl<$Res>
    implements _$NotificationSettingsCopyWith<$Res> {
  __$NotificationSettingsCopyWithImpl(this._self, this._then);

  final _NotificationSettings _self;
  final $Res Function(_NotificationSettings) _then;

/// Create a copy of NotificationSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? components = null,Object? visibility = null,Object? showPauseAction = null,Object? showStopAction = null,Object? hideSensitiveOnLockScreen = null,Object? subscriptionReminders = null,}) {
  return _then(_NotificationSettings(
components: null == components ? _self._components : components // ignore: cast_nullable_to_non_nullable
as List<NotificationComponent>,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as NotificationVisibility,showPauseAction: null == showPauseAction ? _self.showPauseAction : showPauseAction // ignore: cast_nullable_to_non_nullable
as bool,showStopAction: null == showStopAction ? _self.showStopAction : showStopAction // ignore: cast_nullable_to_non_nullable
as bool,hideSensitiveOnLockScreen: null == hideSensitiveOnLockScreen ? _self.hideSensitiveOnLockScreen : hideSensitiveOnLockScreen // ignore: cast_nullable_to_non_nullable
as bool,subscriptionReminders: null == subscriptionReminders ? _self.subscriptionReminders : subscriptionReminders // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$AppSettingProps {

 String? get locale;@JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue) AppRegion? get region;@JsonKey(fromJson: dashboardWidgetsSafeFormJson) List<DashboardWidget> get dashboardWidgets; bool get onlyStatisticsProxy; NotificationSettings get notificationSettings; bool get autoLaunch; bool get silentLaunch; bool get highPriorityAutoLaunch; bool get autoRun; bool get openLogs; bool get closeConnections; bool get newDashboard; String get testUrl; bool get isAnimateToPage; bool get autoCheckUpdate; bool get showLabel; bool get disclaimerAccepted; bool get setupCompleted; int get setupStep; bool get crashlyticsTip; bool get crashlytics; bool get minimizeOnExit; bool get hidden; bool get developerMode; RestoreStrategy get restoreStrategy; bool get showTrayTitle; bool get checkCertificate; String get customUserAgent; bool get sendDeviceIdentity; String get iconVariant; bool get reduceMotion;
/// Create a copy of AppSettingProps
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppSettingPropsCopyWith<AppSettingProps> get copyWith => _$AppSettingPropsCopyWithImpl<AppSettingProps>(this as AppSettingProps, _$identity);

  /// Serializes this AppSettingProps to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AppSettingProps;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppSettingProps&&(identical(other.locale, _this.locale) || other.locale == _this.locale)&&(identical(other.region, _this.region) || other.region == _this.region)&&const DeepCollectionEquality().equals(other.dashboardWidgets, _this.dashboardWidgets)&&(identical(other.onlyStatisticsProxy, _this.onlyStatisticsProxy) || other.onlyStatisticsProxy == _this.onlyStatisticsProxy)&&(identical(other.notificationSettings, _this.notificationSettings) || other.notificationSettings == _this.notificationSettings)&&(identical(other.autoLaunch, _this.autoLaunch) || other.autoLaunch == _this.autoLaunch)&&(identical(other.silentLaunch, _this.silentLaunch) || other.silentLaunch == _this.silentLaunch)&&(identical(other.highPriorityAutoLaunch, _this.highPriorityAutoLaunch) || other.highPriorityAutoLaunch == _this.highPriorityAutoLaunch)&&(identical(other.autoRun, _this.autoRun) || other.autoRun == _this.autoRun)&&(identical(other.openLogs, _this.openLogs) || other.openLogs == _this.openLogs)&&(identical(other.closeConnections, _this.closeConnections) || other.closeConnections == _this.closeConnections)&&(identical(other.newDashboard, _this.newDashboard) || other.newDashboard == _this.newDashboard)&&(identical(other.testUrl, _this.testUrl) || other.testUrl == _this.testUrl)&&(identical(other.isAnimateToPage, _this.isAnimateToPage) || other.isAnimateToPage == _this.isAnimateToPage)&&(identical(other.autoCheckUpdate, _this.autoCheckUpdate) || other.autoCheckUpdate == _this.autoCheckUpdate)&&(identical(other.showLabel, _this.showLabel) || other.showLabel == _this.showLabel)&&(identical(other.disclaimerAccepted, _this.disclaimerAccepted) || other.disclaimerAccepted == _this.disclaimerAccepted)&&(identical(other.setupCompleted, _this.setupCompleted) || other.setupCompleted == _this.setupCompleted)&&(identical(other.setupStep, _this.setupStep) || other.setupStep == _this.setupStep)&&(identical(other.crashlyticsTip, _this.crashlyticsTip) || other.crashlyticsTip == _this.crashlyticsTip)&&(identical(other.crashlytics, _this.crashlytics) || other.crashlytics == _this.crashlytics)&&(identical(other.minimizeOnExit, _this.minimizeOnExit) || other.minimizeOnExit == _this.minimizeOnExit)&&(identical(other.hidden, _this.hidden) || other.hidden == _this.hidden)&&(identical(other.developerMode, _this.developerMode) || other.developerMode == _this.developerMode)&&(identical(other.restoreStrategy, _this.restoreStrategy) || other.restoreStrategy == _this.restoreStrategy)&&(identical(other.showTrayTitle, _this.showTrayTitle) || other.showTrayTitle == _this.showTrayTitle)&&(identical(other.checkCertificate, _this.checkCertificate) || other.checkCertificate == _this.checkCertificate)&&(identical(other.customUserAgent, _this.customUserAgent) || other.customUserAgent == _this.customUserAgent)&&(identical(other.sendDeviceIdentity, _this.sendDeviceIdentity) || other.sendDeviceIdentity == _this.sendDeviceIdentity)&&(identical(other.iconVariant, _this.iconVariant) || other.iconVariant == _this.iconVariant)&&(identical(other.reduceMotion, _this.reduceMotion) || other.reduceMotion == _this.reduceMotion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AppSettingProps;
  return Object.hashAll([runtimeType,_this.locale,_this.region,const DeepCollectionEquality().hash(_this.dashboardWidgets),_this.onlyStatisticsProxy,_this.notificationSettings,_this.autoLaunch,_this.silentLaunch,_this.highPriorityAutoLaunch,_this.autoRun,_this.openLogs,_this.closeConnections,_this.newDashboard,_this.testUrl,_this.isAnimateToPage,_this.autoCheckUpdate,_this.showLabel,_this.disclaimerAccepted,_this.setupCompleted,_this.setupStep,_this.crashlyticsTip,_this.crashlytics,_this.minimizeOnExit,_this.hidden,_this.developerMode,_this.restoreStrategy,_this.showTrayTitle,_this.checkCertificate,_this.customUserAgent,_this.sendDeviceIdentity,_this.iconVariant,_this.reduceMotion]);
}

@override
String toString() {
  final _this = this as AppSettingProps;
  return 'AppSettingProps(locale: ${_this.locale}, region: ${_this.region}, dashboardWidgets: ${_this.dashboardWidgets}, onlyStatisticsProxy: ${_this.onlyStatisticsProxy}, notificationSettings: ${_this.notificationSettings}, autoLaunch: ${_this.autoLaunch}, silentLaunch: ${_this.silentLaunch}, highPriorityAutoLaunch: ${_this.highPriorityAutoLaunch}, autoRun: ${_this.autoRun}, openLogs: ${_this.openLogs}, closeConnections: ${_this.closeConnections}, newDashboard: ${_this.newDashboard}, testUrl: ${_this.testUrl}, isAnimateToPage: ${_this.isAnimateToPage}, autoCheckUpdate: ${_this.autoCheckUpdate}, showLabel: ${_this.showLabel}, disclaimerAccepted: ${_this.disclaimerAccepted}, setupCompleted: ${_this.setupCompleted}, setupStep: ${_this.setupStep}, crashlyticsTip: ${_this.crashlyticsTip}, crashlytics: ${_this.crashlytics}, minimizeOnExit: ${_this.minimizeOnExit}, hidden: ${_this.hidden}, developerMode: ${_this.developerMode}, restoreStrategy: ${_this.restoreStrategy}, showTrayTitle: ${_this.showTrayTitle}, checkCertificate: ${_this.checkCertificate}, customUserAgent: ${_this.customUserAgent}, sendDeviceIdentity: ${_this.sendDeviceIdentity}, iconVariant: ${_this.iconVariant}, reduceMotion: ${_this.reduceMotion})';
}


}

/// @nodoc
abstract mixin class $AppSettingPropsCopyWith<$Res>  {
  factory $AppSettingPropsCopyWith(AppSettingProps value, $Res Function(AppSettingProps) _then) = _$AppSettingPropsCopyWithImpl;
@useResult
$Res call({
 String? locale,@JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue) AppRegion? region,@JsonKey(fromJson: dashboardWidgetsSafeFormJson) List<DashboardWidget> dashboardWidgets, bool onlyStatisticsProxy, NotificationSettings notificationSettings, bool autoLaunch, bool silentLaunch, bool highPriorityAutoLaunch, bool autoRun, bool openLogs, bool closeConnections, bool newDashboard, String testUrl, bool isAnimateToPage, bool autoCheckUpdate, bool showLabel, bool disclaimerAccepted, bool setupCompleted, int setupStep, bool crashlyticsTip, bool crashlytics, bool minimizeOnExit, bool hidden, bool developerMode, RestoreStrategy restoreStrategy, bool showTrayTitle, bool checkCertificate, String customUserAgent, bool sendDeviceIdentity, String iconVariant, bool reduceMotion
});


$NotificationSettingsCopyWith<$Res> get notificationSettings;

}
/// @nodoc
class _$AppSettingPropsCopyWithImpl<$Res>
    implements $AppSettingPropsCopyWith<$Res> {
  _$AppSettingPropsCopyWithImpl(this._self, this._then);

  final AppSettingProps _self;
  final $Res Function(AppSettingProps) _then;

/// Create a copy of AppSettingProps
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? locale = freezed,Object? region = freezed,Object? dashboardWidgets = null,Object? onlyStatisticsProxy = null,Object? notificationSettings = null,Object? autoLaunch = null,Object? silentLaunch = null,Object? highPriorityAutoLaunch = null,Object? autoRun = null,Object? openLogs = null,Object? closeConnections = null,Object? newDashboard = null,Object? testUrl = null,Object? isAnimateToPage = null,Object? autoCheckUpdate = null,Object? showLabel = null,Object? disclaimerAccepted = null,Object? setupCompleted = null,Object? setupStep = null,Object? crashlyticsTip = null,Object? crashlytics = null,Object? minimizeOnExit = null,Object? hidden = null,Object? developerMode = null,Object? restoreStrategy = null,Object? showTrayTitle = null,Object? checkCertificate = null,Object? customUserAgent = null,Object? sendDeviceIdentity = null,Object? iconVariant = null,Object? reduceMotion = null,}) {
  return _then(AppSettingProps(
locale: freezed == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String?,region: freezed == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as AppRegion?,dashboardWidgets: null == dashboardWidgets ? _self.dashboardWidgets : dashboardWidgets // ignore: cast_nullable_to_non_nullable
as List<DashboardWidget>,onlyStatisticsProxy: null == onlyStatisticsProxy ? _self.onlyStatisticsProxy : onlyStatisticsProxy // ignore: cast_nullable_to_non_nullable
as bool,notificationSettings: null == notificationSettings ? _self.notificationSettings : notificationSettings // ignore: cast_nullable_to_non_nullable
as NotificationSettings,autoLaunch: null == autoLaunch ? _self.autoLaunch : autoLaunch // ignore: cast_nullable_to_non_nullable
as bool,silentLaunch: null == silentLaunch ? _self.silentLaunch : silentLaunch // ignore: cast_nullable_to_non_nullable
as bool,highPriorityAutoLaunch: null == highPriorityAutoLaunch ? _self.highPriorityAutoLaunch : highPriorityAutoLaunch // ignore: cast_nullable_to_non_nullable
as bool,autoRun: null == autoRun ? _self.autoRun : autoRun // ignore: cast_nullable_to_non_nullable
as bool,openLogs: null == openLogs ? _self.openLogs : openLogs // ignore: cast_nullable_to_non_nullable
as bool,closeConnections: null == closeConnections ? _self.closeConnections : closeConnections // ignore: cast_nullable_to_non_nullable
as bool,newDashboard: null == newDashboard ? _self.newDashboard : newDashboard // ignore: cast_nullable_to_non_nullable
as bool,testUrl: null == testUrl ? _self.testUrl : testUrl // ignore: cast_nullable_to_non_nullable
as String,isAnimateToPage: null == isAnimateToPage ? _self.isAnimateToPage : isAnimateToPage // ignore: cast_nullable_to_non_nullable
as bool,autoCheckUpdate: null == autoCheckUpdate ? _self.autoCheckUpdate : autoCheckUpdate // ignore: cast_nullable_to_non_nullable
as bool,showLabel: null == showLabel ? _self.showLabel : showLabel // ignore: cast_nullable_to_non_nullable
as bool,disclaimerAccepted: null == disclaimerAccepted ? _self.disclaimerAccepted : disclaimerAccepted // ignore: cast_nullable_to_non_nullable
as bool,setupCompleted: null == setupCompleted ? _self.setupCompleted : setupCompleted // ignore: cast_nullable_to_non_nullable
as bool,setupStep: null == setupStep ? _self.setupStep : setupStep // ignore: cast_nullable_to_non_nullable
as int,crashlyticsTip: null == crashlyticsTip ? _self.crashlyticsTip : crashlyticsTip // ignore: cast_nullable_to_non_nullable
as bool,crashlytics: null == crashlytics ? _self.crashlytics : crashlytics // ignore: cast_nullable_to_non_nullable
as bool,minimizeOnExit: null == minimizeOnExit ? _self.minimizeOnExit : minimizeOnExit // ignore: cast_nullable_to_non_nullable
as bool,hidden: null == hidden ? _self.hidden : hidden // ignore: cast_nullable_to_non_nullable
as bool,developerMode: null == developerMode ? _self.developerMode : developerMode // ignore: cast_nullable_to_non_nullable
as bool,restoreStrategy: null == restoreStrategy ? _self.restoreStrategy : restoreStrategy // ignore: cast_nullable_to_non_nullable
as RestoreStrategy,showTrayTitle: null == showTrayTitle ? _self.showTrayTitle : showTrayTitle // ignore: cast_nullable_to_non_nullable
as bool,checkCertificate: null == checkCertificate ? _self.checkCertificate : checkCertificate // ignore: cast_nullable_to_non_nullable
as bool,customUserAgent: null == customUserAgent ? _self.customUserAgent : customUserAgent // ignore: cast_nullable_to_non_nullable
as String,sendDeviceIdentity: null == sendDeviceIdentity ? _self.sendDeviceIdentity : sendDeviceIdentity // ignore: cast_nullable_to_non_nullable
as bool,iconVariant: null == iconVariant ? _self.iconVariant : iconVariant // ignore: cast_nullable_to_non_nullable
as String,reduceMotion: null == reduceMotion ? _self.reduceMotion : reduceMotion // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of AppSettingProps
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NotificationSettingsCopyWith<$Res> get notificationSettings {
  
  return $NotificationSettingsCopyWith<$Res>(_self.notificationSettings, (value) {
    return _then(_self.copyWith(notificationSettings: value));
  });
}
}


/// Adds pattern-matching-related methods to [AppSettingProps].
extension AppSettingPropsPatterns on AppSettingProps {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppSettingProps value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppSettingProps() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppSettingProps value)  $default,){
final _that = this;
switch (_that) {
case _AppSettingProps():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppSettingProps value)?  $default,){
final _that = this;
switch (_that) {
case _AppSettingProps() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? locale, @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)  AppRegion? region, @JsonKey(fromJson: dashboardWidgetsSafeFormJson)  List<DashboardWidget> dashboardWidgets,  bool onlyStatisticsProxy,  NotificationSettings notificationSettings,  bool autoLaunch,  bool silentLaunch,  bool highPriorityAutoLaunch,  bool autoRun,  bool openLogs,  bool closeConnections,  bool newDashboard,  String testUrl,  bool isAnimateToPage,  bool autoCheckUpdate,  bool showLabel,  bool disclaimerAccepted,  bool setupCompleted,  int setupStep,  bool crashlyticsTip,  bool crashlytics,  bool minimizeOnExit,  bool hidden,  bool developerMode,  RestoreStrategy restoreStrategy,  bool showTrayTitle,  bool checkCertificate,  String customUserAgent,  bool sendDeviceIdentity,  String iconVariant,  bool reduceMotion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppSettingProps() when $default != null:
return $default(_that.locale,_that.region,_that.dashboardWidgets,_that.onlyStatisticsProxy,_that.notificationSettings,_that.autoLaunch,_that.silentLaunch,_that.highPriorityAutoLaunch,_that.autoRun,_that.openLogs,_that.closeConnections,_that.newDashboard,_that.testUrl,_that.isAnimateToPage,_that.autoCheckUpdate,_that.showLabel,_that.disclaimerAccepted,_that.setupCompleted,_that.setupStep,_that.crashlyticsTip,_that.crashlytics,_that.minimizeOnExit,_that.hidden,_that.developerMode,_that.restoreStrategy,_that.showTrayTitle,_that.checkCertificate,_that.customUserAgent,_that.sendDeviceIdentity,_that.iconVariant,_that.reduceMotion);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? locale, @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)  AppRegion? region, @JsonKey(fromJson: dashboardWidgetsSafeFormJson)  List<DashboardWidget> dashboardWidgets,  bool onlyStatisticsProxy,  NotificationSettings notificationSettings,  bool autoLaunch,  bool silentLaunch,  bool highPriorityAutoLaunch,  bool autoRun,  bool openLogs,  bool closeConnections,  bool newDashboard,  String testUrl,  bool isAnimateToPage,  bool autoCheckUpdate,  bool showLabel,  bool disclaimerAccepted,  bool setupCompleted,  int setupStep,  bool crashlyticsTip,  bool crashlytics,  bool minimizeOnExit,  bool hidden,  bool developerMode,  RestoreStrategy restoreStrategy,  bool showTrayTitle,  bool checkCertificate,  String customUserAgent,  bool sendDeviceIdentity,  String iconVariant,  bool reduceMotion)  $default,) {final _that = this;
switch (_that) {
case _AppSettingProps():
return $default(_that.locale,_that.region,_that.dashboardWidgets,_that.onlyStatisticsProxy,_that.notificationSettings,_that.autoLaunch,_that.silentLaunch,_that.highPriorityAutoLaunch,_that.autoRun,_that.openLogs,_that.closeConnections,_that.newDashboard,_that.testUrl,_that.isAnimateToPage,_that.autoCheckUpdate,_that.showLabel,_that.disclaimerAccepted,_that.setupCompleted,_that.setupStep,_that.crashlyticsTip,_that.crashlytics,_that.minimizeOnExit,_that.hidden,_that.developerMode,_that.restoreStrategy,_that.showTrayTitle,_that.checkCertificate,_that.customUserAgent,_that.sendDeviceIdentity,_that.iconVariant,_that.reduceMotion);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? locale, @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)  AppRegion? region, @JsonKey(fromJson: dashboardWidgetsSafeFormJson)  List<DashboardWidget> dashboardWidgets,  bool onlyStatisticsProxy,  NotificationSettings notificationSettings,  bool autoLaunch,  bool silentLaunch,  bool highPriorityAutoLaunch,  bool autoRun,  bool openLogs,  bool closeConnections,  bool newDashboard,  String testUrl,  bool isAnimateToPage,  bool autoCheckUpdate,  bool showLabel,  bool disclaimerAccepted,  bool setupCompleted,  int setupStep,  bool crashlyticsTip,  bool crashlytics,  bool minimizeOnExit,  bool hidden,  bool developerMode,  RestoreStrategy restoreStrategy,  bool showTrayTitle,  bool checkCertificate,  String customUserAgent,  bool sendDeviceIdentity,  String iconVariant,  bool reduceMotion)?  $default,) {final _that = this;
switch (_that) {
case _AppSettingProps() when $default != null:
return $default(_that.locale,_that.region,_that.dashboardWidgets,_that.onlyStatisticsProxy,_that.notificationSettings,_that.autoLaunch,_that.silentLaunch,_that.highPriorityAutoLaunch,_that.autoRun,_that.openLogs,_that.closeConnections,_that.newDashboard,_that.testUrl,_that.isAnimateToPage,_that.autoCheckUpdate,_that.showLabel,_that.disclaimerAccepted,_that.setupCompleted,_that.setupStep,_that.crashlyticsTip,_that.crashlytics,_that.minimizeOnExit,_that.hidden,_that.developerMode,_that.restoreStrategy,_that.showTrayTitle,_that.checkCertificate,_that.customUserAgent,_that.sendDeviceIdentity,_that.iconVariant,_that.reduceMotion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppSettingProps implements AppSettingProps {
  const _AppSettingProps({this.locale, @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue) this.region, @JsonKey(fromJson: dashboardWidgetsSafeFormJson)  List<DashboardWidget> dashboardWidgets = defaultDashboardWidgets, this.onlyStatisticsProxy = false, this.notificationSettings = defaultNotificationSettings, this.autoLaunch = false, this.silentLaunch = false, this.highPriorityAutoLaunch = false, this.autoRun = false, this.openLogs = false, this.closeConnections = true, this.newDashboard = true, this.testUrl = defaultTestUrl, this.isAnimateToPage = true, this.autoCheckUpdate = false, this.showLabel = false, this.disclaimerAccepted = false, this.setupCompleted = false, this.setupStep = 0, this.crashlyticsTip = false, this.crashlytics = false, this.minimizeOnExit = true, this.hidden = false, this.developerMode = false, this.restoreStrategy = RestoreStrategy.compatible, this.showTrayTitle = true, this.checkCertificate = true, this.customUserAgent = '', this.sendDeviceIdentity = false, this.iconVariant = 'default', this.reduceMotion = false}): _dashboardWidgets = dashboardWidgets;
  factory _AppSettingProps.fromJson(Map<String, dynamic> json) => _$AppSettingPropsFromJson(json);

@override final  String? locale;
@override@JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue) final  AppRegion? region;
 final  List<DashboardWidget> _dashboardWidgets;
@override@JsonKey(fromJson: dashboardWidgetsSafeFormJson) List<DashboardWidget> get dashboardWidgets {
  if (_dashboardWidgets is EqualUnmodifiableListView) return _dashboardWidgets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dashboardWidgets);
}

@override@JsonKey() final  bool onlyStatisticsProxy;
@override@JsonKey() final  NotificationSettings notificationSettings;
@override@JsonKey() final  bool autoLaunch;
@override@JsonKey() final  bool silentLaunch;
@override@JsonKey() final  bool highPriorityAutoLaunch;
@override@JsonKey() final  bool autoRun;
@override@JsonKey() final  bool openLogs;
@override@JsonKey() final  bool closeConnections;
@override@JsonKey() final  bool newDashboard;
@override@JsonKey() final  String testUrl;
@override@JsonKey() final  bool isAnimateToPage;
@override@JsonKey() final  bool autoCheckUpdate;
@override@JsonKey() final  bool showLabel;
@override@JsonKey() final  bool disclaimerAccepted;
@override@JsonKey() final  bool setupCompleted;
@override@JsonKey() final  int setupStep;
@override@JsonKey() final  bool crashlyticsTip;
@override@JsonKey() final  bool crashlytics;
@override@JsonKey() final  bool minimizeOnExit;
@override@JsonKey() final  bool hidden;
@override@JsonKey() final  bool developerMode;
@override@JsonKey() final  RestoreStrategy restoreStrategy;
@override@JsonKey() final  bool showTrayTitle;
@override@JsonKey() final  bool checkCertificate;
@override@JsonKey() final  String customUserAgent;
@override@JsonKey() final  bool sendDeviceIdentity;
@override@JsonKey() final  String iconVariant;
@override@JsonKey() final  bool reduceMotion;

/// Create a copy of AppSettingProps
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppSettingPropsCopyWith<_AppSettingProps> get copyWith => __$AppSettingPropsCopyWithImpl<_AppSettingProps>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppSettingPropsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppSettingProps&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.region, region) || other.region == region)&&const DeepCollectionEquality().equals(other.dashboardWidgets, _dashboardWidgets)&&(identical(other.onlyStatisticsProxy, onlyStatisticsProxy) || other.onlyStatisticsProxy == onlyStatisticsProxy)&&(identical(other.notificationSettings, notificationSettings) || other.notificationSettings == notificationSettings)&&(identical(other.autoLaunch, autoLaunch) || other.autoLaunch == autoLaunch)&&(identical(other.silentLaunch, silentLaunch) || other.silentLaunch == silentLaunch)&&(identical(other.highPriorityAutoLaunch, highPriorityAutoLaunch) || other.highPriorityAutoLaunch == highPriorityAutoLaunch)&&(identical(other.autoRun, autoRun) || other.autoRun == autoRun)&&(identical(other.openLogs, openLogs) || other.openLogs == openLogs)&&(identical(other.closeConnections, closeConnections) || other.closeConnections == closeConnections)&&(identical(other.newDashboard, newDashboard) || other.newDashboard == newDashboard)&&(identical(other.testUrl, testUrl) || other.testUrl == testUrl)&&(identical(other.isAnimateToPage, isAnimateToPage) || other.isAnimateToPage == isAnimateToPage)&&(identical(other.autoCheckUpdate, autoCheckUpdate) || other.autoCheckUpdate == autoCheckUpdate)&&(identical(other.showLabel, showLabel) || other.showLabel == showLabel)&&(identical(other.disclaimerAccepted, disclaimerAccepted) || other.disclaimerAccepted == disclaimerAccepted)&&(identical(other.setupCompleted, setupCompleted) || other.setupCompleted == setupCompleted)&&(identical(other.setupStep, setupStep) || other.setupStep == setupStep)&&(identical(other.crashlyticsTip, crashlyticsTip) || other.crashlyticsTip == crashlyticsTip)&&(identical(other.crashlytics, crashlytics) || other.crashlytics == crashlytics)&&(identical(other.minimizeOnExit, minimizeOnExit) || other.minimizeOnExit == minimizeOnExit)&&(identical(other.hidden, hidden) || other.hidden == hidden)&&(identical(other.developerMode, developerMode) || other.developerMode == developerMode)&&(identical(other.restoreStrategy, restoreStrategy) || other.restoreStrategy == restoreStrategy)&&(identical(other.showTrayTitle, showTrayTitle) || other.showTrayTitle == showTrayTitle)&&(identical(other.checkCertificate, checkCertificate) || other.checkCertificate == checkCertificate)&&(identical(other.customUserAgent, customUserAgent) || other.customUserAgent == customUserAgent)&&(identical(other.sendDeviceIdentity, sendDeviceIdentity) || other.sendDeviceIdentity == sendDeviceIdentity)&&(identical(other.iconVariant, iconVariant) || other.iconVariant == iconVariant)&&(identical(other.reduceMotion, reduceMotion) || other.reduceMotion == reduceMotion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,locale,region,const DeepCollectionEquality().hash(_dashboardWidgets),onlyStatisticsProxy,notificationSettings,autoLaunch,silentLaunch,highPriorityAutoLaunch,autoRun,openLogs,closeConnections,newDashboard,testUrl,isAnimateToPage,autoCheckUpdate,showLabel,disclaimerAccepted,setupCompleted,setupStep,crashlyticsTip,crashlytics,minimizeOnExit,hidden,developerMode,restoreStrategy,showTrayTitle,checkCertificate,customUserAgent,sendDeviceIdentity,iconVariant,reduceMotion]);
}

@override
String toString() {
    return 'AppSettingProps(locale: $locale, region: $region, dashboardWidgets: $dashboardWidgets, onlyStatisticsProxy: $onlyStatisticsProxy, notificationSettings: $notificationSettings, autoLaunch: $autoLaunch, silentLaunch: $silentLaunch, highPriorityAutoLaunch: $highPriorityAutoLaunch, autoRun: $autoRun, openLogs: $openLogs, closeConnections: $closeConnections, newDashboard: $newDashboard, testUrl: $testUrl, isAnimateToPage: $isAnimateToPage, autoCheckUpdate: $autoCheckUpdate, showLabel: $showLabel, disclaimerAccepted: $disclaimerAccepted, setupCompleted: $setupCompleted, setupStep: $setupStep, crashlyticsTip: $crashlyticsTip, crashlytics: $crashlytics, minimizeOnExit: $minimizeOnExit, hidden: $hidden, developerMode: $developerMode, restoreStrategy: $restoreStrategy, showTrayTitle: $showTrayTitle, checkCertificate: $checkCertificate, customUserAgent: $customUserAgent, sendDeviceIdentity: $sendDeviceIdentity, iconVariant: $iconVariant, reduceMotion: $reduceMotion)';
}


}

/// @nodoc
abstract mixin class _$AppSettingPropsCopyWith<$Res> implements $AppSettingPropsCopyWith<$Res> {
  factory _$AppSettingPropsCopyWith(_AppSettingProps value, $Res Function(_AppSettingProps) _then) = __$AppSettingPropsCopyWithImpl;
@override @useResult
$Res call({
 String? locale,@JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue) AppRegion? region,@JsonKey(fromJson: dashboardWidgetsSafeFormJson) List<DashboardWidget> dashboardWidgets, bool onlyStatisticsProxy, NotificationSettings notificationSettings, bool autoLaunch, bool silentLaunch, bool highPriorityAutoLaunch, bool autoRun, bool openLogs, bool closeConnections, bool newDashboard, String testUrl, bool isAnimateToPage, bool autoCheckUpdate, bool showLabel, bool disclaimerAccepted, bool setupCompleted, int setupStep, bool crashlyticsTip, bool crashlytics, bool minimizeOnExit, bool hidden, bool developerMode, RestoreStrategy restoreStrategy, bool showTrayTitle, bool checkCertificate, String customUserAgent, bool sendDeviceIdentity, String iconVariant, bool reduceMotion
});


@override $NotificationSettingsCopyWith<$Res> get notificationSettings;

}
/// @nodoc
class __$AppSettingPropsCopyWithImpl<$Res>
    implements _$AppSettingPropsCopyWith<$Res> {
  __$AppSettingPropsCopyWithImpl(this._self, this._then);

  final _AppSettingProps _self;
  final $Res Function(_AppSettingProps) _then;

/// Create a copy of AppSettingProps
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? locale = freezed,Object? region = freezed,Object? dashboardWidgets = null,Object? onlyStatisticsProxy = null,Object? notificationSettings = null,Object? autoLaunch = null,Object? silentLaunch = null,Object? highPriorityAutoLaunch = null,Object? autoRun = null,Object? openLogs = null,Object? closeConnections = null,Object? newDashboard = null,Object? testUrl = null,Object? isAnimateToPage = null,Object? autoCheckUpdate = null,Object? showLabel = null,Object? disclaimerAccepted = null,Object? setupCompleted = null,Object? setupStep = null,Object? crashlyticsTip = null,Object? crashlytics = null,Object? minimizeOnExit = null,Object? hidden = null,Object? developerMode = null,Object? restoreStrategy = null,Object? showTrayTitle = null,Object? checkCertificate = null,Object? customUserAgent = null,Object? sendDeviceIdentity = null,Object? iconVariant = null,Object? reduceMotion = null,}) {
  return _then(_AppSettingProps(
locale: freezed == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String?,region: freezed == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as AppRegion?,dashboardWidgets: null == dashboardWidgets ? _self._dashboardWidgets : dashboardWidgets // ignore: cast_nullable_to_non_nullable
as List<DashboardWidget>,onlyStatisticsProxy: null == onlyStatisticsProxy ? _self.onlyStatisticsProxy : onlyStatisticsProxy // ignore: cast_nullable_to_non_nullable
as bool,notificationSettings: null == notificationSettings ? _self.notificationSettings : notificationSettings // ignore: cast_nullable_to_non_nullable
as NotificationSettings,autoLaunch: null == autoLaunch ? _self.autoLaunch : autoLaunch // ignore: cast_nullable_to_non_nullable
as bool,silentLaunch: null == silentLaunch ? _self.silentLaunch : silentLaunch // ignore: cast_nullable_to_non_nullable
as bool,highPriorityAutoLaunch: null == highPriorityAutoLaunch ? _self.highPriorityAutoLaunch : highPriorityAutoLaunch // ignore: cast_nullable_to_non_nullable
as bool,autoRun: null == autoRun ? _self.autoRun : autoRun // ignore: cast_nullable_to_non_nullable
as bool,openLogs: null == openLogs ? _self.openLogs : openLogs // ignore: cast_nullable_to_non_nullable
as bool,closeConnections: null == closeConnections ? _self.closeConnections : closeConnections // ignore: cast_nullable_to_non_nullable
as bool,newDashboard: null == newDashboard ? _self.newDashboard : newDashboard // ignore: cast_nullable_to_non_nullable
as bool,testUrl: null == testUrl ? _self.testUrl : testUrl // ignore: cast_nullable_to_non_nullable
as String,isAnimateToPage: null == isAnimateToPage ? _self.isAnimateToPage : isAnimateToPage // ignore: cast_nullable_to_non_nullable
as bool,autoCheckUpdate: null == autoCheckUpdate ? _self.autoCheckUpdate : autoCheckUpdate // ignore: cast_nullable_to_non_nullable
as bool,showLabel: null == showLabel ? _self.showLabel : showLabel // ignore: cast_nullable_to_non_nullable
as bool,disclaimerAccepted: null == disclaimerAccepted ? _self.disclaimerAccepted : disclaimerAccepted // ignore: cast_nullable_to_non_nullable
as bool,setupCompleted: null == setupCompleted ? _self.setupCompleted : setupCompleted // ignore: cast_nullable_to_non_nullable
as bool,setupStep: null == setupStep ? _self.setupStep : setupStep // ignore: cast_nullable_to_non_nullable
as int,crashlyticsTip: null == crashlyticsTip ? _self.crashlyticsTip : crashlyticsTip // ignore: cast_nullable_to_non_nullable
as bool,crashlytics: null == crashlytics ? _self.crashlytics : crashlytics // ignore: cast_nullable_to_non_nullable
as bool,minimizeOnExit: null == minimizeOnExit ? _self.minimizeOnExit : minimizeOnExit // ignore: cast_nullable_to_non_nullable
as bool,hidden: null == hidden ? _self.hidden : hidden // ignore: cast_nullable_to_non_nullable
as bool,developerMode: null == developerMode ? _self.developerMode : developerMode // ignore: cast_nullable_to_non_nullable
as bool,restoreStrategy: null == restoreStrategy ? _self.restoreStrategy : restoreStrategy // ignore: cast_nullable_to_non_nullable
as RestoreStrategy,showTrayTitle: null == showTrayTitle ? _self.showTrayTitle : showTrayTitle // ignore: cast_nullable_to_non_nullable
as bool,checkCertificate: null == checkCertificate ? _self.checkCertificate : checkCertificate // ignore: cast_nullable_to_non_nullable
as bool,customUserAgent: null == customUserAgent ? _self.customUserAgent : customUserAgent // ignore: cast_nullable_to_non_nullable
as String,sendDeviceIdentity: null == sendDeviceIdentity ? _self.sendDeviceIdentity : sendDeviceIdentity // ignore: cast_nullable_to_non_nullable
as bool,iconVariant: null == iconVariant ? _self.iconVariant : iconVariant // ignore: cast_nullable_to_non_nullable
as String,reduceMotion: null == reduceMotion ? _self.reduceMotion : reduceMotion // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of AppSettingProps
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NotificationSettingsCopyWith<$Res> get notificationSettings {
  
  return $NotificationSettingsCopyWith<$Res>(_self.notificationSettings, (value) {
    return _then(_self.copyWith(notificationSettings: value));
  });
}
}


/// @nodoc
mixin _$AccessControlProps {

 bool get enable; AccessControlMode get mode; List<String> get acceptList; List<String> get rejectList; AccessSortType get sort; bool get isFilterSystemApp; bool get isFilterNonInternetApp;
/// Create a copy of AccessControlProps
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccessControlPropsCopyWith<AccessControlProps> get copyWith => _$AccessControlPropsCopyWithImpl<AccessControlProps>(this as AccessControlProps, _$identity);

  /// Serializes this AccessControlProps to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AccessControlProps;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccessControlProps&&(identical(other.enable, _this.enable) || other.enable == _this.enable)&&(identical(other.mode, _this.mode) || other.mode == _this.mode)&&const DeepCollectionEquality().equals(other.acceptList, _this.acceptList)&&const DeepCollectionEquality().equals(other.rejectList, _this.rejectList)&&(identical(other.sort, _this.sort) || other.sort == _this.sort)&&(identical(other.isFilterSystemApp, _this.isFilterSystemApp) || other.isFilterSystemApp == _this.isFilterSystemApp)&&(identical(other.isFilterNonInternetApp, _this.isFilterNonInternetApp) || other.isFilterNonInternetApp == _this.isFilterNonInternetApp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AccessControlProps;
  return Object.hash(runtimeType,_this.enable,_this.mode,const DeepCollectionEquality().hash(_this.acceptList),const DeepCollectionEquality().hash(_this.rejectList),_this.sort,_this.isFilterSystemApp,_this.isFilterNonInternetApp);
}

@override
String toString() {
  final _this = this as AccessControlProps;
  return 'AccessControlProps(enable: ${_this.enable}, mode: ${_this.mode}, acceptList: ${_this.acceptList}, rejectList: ${_this.rejectList}, sort: ${_this.sort}, isFilterSystemApp: ${_this.isFilterSystemApp}, isFilterNonInternetApp: ${_this.isFilterNonInternetApp})';
}


}

/// @nodoc
abstract mixin class $AccessControlPropsCopyWith<$Res>  {
  factory $AccessControlPropsCopyWith(AccessControlProps value, $Res Function(AccessControlProps) _then) = _$AccessControlPropsCopyWithImpl;
@useResult
$Res call({
 bool enable, AccessControlMode mode, List<String> acceptList, List<String> rejectList, AccessSortType sort, bool isFilterSystemApp, bool isFilterNonInternetApp
});




}
/// @nodoc
class _$AccessControlPropsCopyWithImpl<$Res>
    implements $AccessControlPropsCopyWith<$Res> {
  _$AccessControlPropsCopyWithImpl(this._self, this._then);

  final AccessControlProps _self;
  final $Res Function(AccessControlProps) _then;

/// Create a copy of AccessControlProps
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enable = null,Object? mode = null,Object? acceptList = null,Object? rejectList = null,Object? sort = null,Object? isFilterSystemApp = null,Object? isFilterNonInternetApp = null,}) {
  return _then(AccessControlProps(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as AccessControlMode,acceptList: null == acceptList ? _self.acceptList : acceptList // ignore: cast_nullable_to_non_nullable
as List<String>,rejectList: null == rejectList ? _self.rejectList : rejectList // ignore: cast_nullable_to_non_nullable
as List<String>,sort: null == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as AccessSortType,isFilterSystemApp: null == isFilterSystemApp ? _self.isFilterSystemApp : isFilterSystemApp // ignore: cast_nullable_to_non_nullable
as bool,isFilterNonInternetApp: null == isFilterNonInternetApp ? _self.isFilterNonInternetApp : isFilterNonInternetApp // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AccessControlProps].
extension AccessControlPropsPatterns on AccessControlProps {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AccessControlProps value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AccessControlProps() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AccessControlProps value)  $default,){
final _that = this;
switch (_that) {
case _AccessControlProps():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AccessControlProps value)?  $default,){
final _that = this;
switch (_that) {
case _AccessControlProps() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enable,  AccessControlMode mode,  List<String> acceptList,  List<String> rejectList,  AccessSortType sort,  bool isFilterSystemApp,  bool isFilterNonInternetApp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AccessControlProps() when $default != null:
return $default(_that.enable,_that.mode,_that.acceptList,_that.rejectList,_that.sort,_that.isFilterSystemApp,_that.isFilterNonInternetApp);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enable,  AccessControlMode mode,  List<String> acceptList,  List<String> rejectList,  AccessSortType sort,  bool isFilterSystemApp,  bool isFilterNonInternetApp)  $default,) {final _that = this;
switch (_that) {
case _AccessControlProps():
return $default(_that.enable,_that.mode,_that.acceptList,_that.rejectList,_that.sort,_that.isFilterSystemApp,_that.isFilterNonInternetApp);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enable,  AccessControlMode mode,  List<String> acceptList,  List<String> rejectList,  AccessSortType sort,  bool isFilterSystemApp,  bool isFilterNonInternetApp)?  $default,) {final _that = this;
switch (_that) {
case _AccessControlProps() when $default != null:
return $default(_that.enable,_that.mode,_that.acceptList,_that.rejectList,_that.sort,_that.isFilterSystemApp,_that.isFilterNonInternetApp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AccessControlProps implements AccessControlProps {
  const _AccessControlProps({this.enable = false, this.mode = AccessControlMode.rejectSelected,  List<String> acceptList = const [],  List<String> rejectList = const [], this.sort = AccessSortType.none, this.isFilterSystemApp = true, this.isFilterNonInternetApp = true}): _acceptList = acceptList,_rejectList = rejectList;
  factory _AccessControlProps.fromJson(Map<String, dynamic> json) => _$AccessControlPropsFromJson(json);

@override@JsonKey() final  bool enable;
@override@JsonKey() final  AccessControlMode mode;
 final  List<String> _acceptList;
@override@JsonKey() List<String> get acceptList {
  if (_acceptList is EqualUnmodifiableListView) return _acceptList;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_acceptList);
}

 final  List<String> _rejectList;
@override@JsonKey() List<String> get rejectList {
  if (_rejectList is EqualUnmodifiableListView) return _rejectList;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rejectList);
}

@override@JsonKey() final  AccessSortType sort;
@override@JsonKey() final  bool isFilterSystemApp;
@override@JsonKey() final  bool isFilterNonInternetApp;

/// Create a copy of AccessControlProps
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccessControlPropsCopyWith<_AccessControlProps> get copyWith => __$AccessControlPropsCopyWithImpl<_AccessControlProps>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AccessControlPropsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccessControlProps&&(identical(other.enable, enable) || other.enable == enable)&&(identical(other.mode, mode) || other.mode == mode)&&const DeepCollectionEquality().equals(other.acceptList, _acceptList)&&const DeepCollectionEquality().equals(other.rejectList, _rejectList)&&(identical(other.sort, sort) || other.sort == sort)&&(identical(other.isFilterSystemApp, isFilterSystemApp) || other.isFilterSystemApp == isFilterSystemApp)&&(identical(other.isFilterNonInternetApp, isFilterNonInternetApp) || other.isFilterNonInternetApp == isFilterNonInternetApp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,enable,mode,const DeepCollectionEquality().hash(_acceptList),const DeepCollectionEquality().hash(_rejectList),sort,isFilterSystemApp,isFilterNonInternetApp);
}

@override
String toString() {
    return 'AccessControlProps(enable: $enable, mode: $mode, acceptList: $acceptList, rejectList: $rejectList, sort: $sort, isFilterSystemApp: $isFilterSystemApp, isFilterNonInternetApp: $isFilterNonInternetApp)';
}


}

/// @nodoc
abstract mixin class _$AccessControlPropsCopyWith<$Res> implements $AccessControlPropsCopyWith<$Res> {
  factory _$AccessControlPropsCopyWith(_AccessControlProps value, $Res Function(_AccessControlProps) _then) = __$AccessControlPropsCopyWithImpl;
@override @useResult
$Res call({
 bool enable, AccessControlMode mode, List<String> acceptList, List<String> rejectList, AccessSortType sort, bool isFilterSystemApp, bool isFilterNonInternetApp
});




}
/// @nodoc
class __$AccessControlPropsCopyWithImpl<$Res>
    implements _$AccessControlPropsCopyWith<$Res> {
  __$AccessControlPropsCopyWithImpl(this._self, this._then);

  final _AccessControlProps _self;
  final $Res Function(_AccessControlProps) _then;

/// Create a copy of AccessControlProps
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enable = null,Object? mode = null,Object? acceptList = null,Object? rejectList = null,Object? sort = null,Object? isFilterSystemApp = null,Object? isFilterNonInternetApp = null,}) {
  return _then(_AccessControlProps(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as AccessControlMode,acceptList: null == acceptList ? _self._acceptList : acceptList // ignore: cast_nullable_to_non_nullable
as List<String>,rejectList: null == rejectList ? _self._rejectList : rejectList // ignore: cast_nullable_to_non_nullable
as List<String>,sort: null == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as AccessSortType,isFilterSystemApp: null == isFilterSystemApp ? _self.isFilterSystemApp : isFilterSystemApp // ignore: cast_nullable_to_non_nullable
as bool,isFilterNonInternetApp: null == isFilterNonInternetApp ? _self.isFilterNonInternetApp : isFilterNonInternetApp // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$WindowProps {

 double get width; double get height; double? get top; double? get left;
/// Create a copy of WindowProps
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WindowPropsCopyWith<WindowProps> get copyWith => _$WindowPropsCopyWithImpl<WindowProps>(this as WindowProps, _$identity);

  /// Serializes this WindowProps to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as WindowProps;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WindowProps&&(identical(other.width, _this.width) || other.width == _this.width)&&(identical(other.height, _this.height) || other.height == _this.height)&&(identical(other.top, _this.top) || other.top == _this.top)&&(identical(other.left, _this.left) || other.left == _this.left));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as WindowProps;
  return Object.hash(runtimeType,_this.width,_this.height,_this.top,_this.left);
}

@override
String toString() {
  final _this = this as WindowProps;
  return 'WindowProps(width: ${_this.width}, height: ${_this.height}, top: ${_this.top}, left: ${_this.left})';
}


}

/// @nodoc
abstract mixin class $WindowPropsCopyWith<$Res>  {
  factory $WindowPropsCopyWith(WindowProps value, $Res Function(WindowProps) _then) = _$WindowPropsCopyWithImpl;
@useResult
$Res call({
 double width, double height, double? top, double? left
});




}
/// @nodoc
class _$WindowPropsCopyWithImpl<$Res>
    implements $WindowPropsCopyWith<$Res> {
  _$WindowPropsCopyWithImpl(this._self, this._then);

  final WindowProps _self;
  final $Res Function(WindowProps) _then;

/// Create a copy of WindowProps
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? width = null,Object? height = null,Object? top = freezed,Object? left = freezed,}) {
  return _then(WindowProps(
width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,top: freezed == top ? _self.top : top // ignore: cast_nullable_to_non_nullable
as double?,left: freezed == left ? _self.left : left // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [WindowProps].
extension WindowPropsPatterns on WindowProps {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WindowProps value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WindowProps() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WindowProps value)  $default,){
final _that = this;
switch (_that) {
case _WindowProps():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WindowProps value)?  $default,){
final _that = this;
switch (_that) {
case _WindowProps() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double width,  double height,  double? top,  double? left)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WindowProps() when $default != null:
return $default(_that.width,_that.height,_that.top,_that.left);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double width,  double height,  double? top,  double? left)  $default,) {final _that = this;
switch (_that) {
case _WindowProps():
return $default(_that.width,_that.height,_that.top,_that.left);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double width,  double height,  double? top,  double? left)?  $default,) {final _that = this;
switch (_that) {
case _WindowProps() when $default != null:
return $default(_that.width,_that.height,_that.top,_that.left);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WindowProps implements WindowProps {
  const _WindowProps({this.width = 0, this.height = 0, this.top, this.left});
  factory _WindowProps.fromJson(Map<String, dynamic> json) => _$WindowPropsFromJson(json);

@override@JsonKey() final  double width;
@override@JsonKey() final  double height;
@override final  double? top;
@override final  double? left;

/// Create a copy of WindowProps
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WindowPropsCopyWith<_WindowProps> get copyWith => __$WindowPropsCopyWithImpl<_WindowProps>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WindowPropsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WindowProps&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.top, top) || other.top == top)&&(identical(other.left, left) || other.left == left));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,width,height,top,left);
}

@override
String toString() {
    return 'WindowProps(width: $width, height: $height, top: $top, left: $left)';
}


}

/// @nodoc
abstract mixin class _$WindowPropsCopyWith<$Res> implements $WindowPropsCopyWith<$Res> {
  factory _$WindowPropsCopyWith(_WindowProps value, $Res Function(_WindowProps) _then) = __$WindowPropsCopyWithImpl;
@override @useResult
$Res call({
 double width, double height, double? top, double? left
});




}
/// @nodoc
class __$WindowPropsCopyWithImpl<$Res>
    implements _$WindowPropsCopyWith<$Res> {
  __$WindowPropsCopyWithImpl(this._self, this._then);

  final _WindowProps _self;
  final $Res Function(_WindowProps) _then;

/// Create a copy of WindowProps
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? width = null,Object? height = null,Object? top = freezed,Object? left = freezed,}) {
  return _then(_WindowProps(
width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,top: freezed == top ? _self.top : top // ignore: cast_nullable_to_non_nullable
as double?,left: freezed == left ? _self.left : left // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$VpnProps {

 bool get enable; bool get systemProxy; bool get ipv6; bool get allowBypass; bool get dnsHijacking; bool get smartPauseEnabled; List<String> get smartPauseNetworks; bool get smartPauseCloseConnections; AccessControlProps get accessControlProps;
/// Create a copy of VpnProps
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VpnPropsCopyWith<VpnProps> get copyWith => _$VpnPropsCopyWithImpl<VpnProps>(this as VpnProps, _$identity);

  /// Serializes this VpnProps to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as VpnProps;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VpnProps&&(identical(other.enable, _this.enable) || other.enable == _this.enable)&&(identical(other.systemProxy, _this.systemProxy) || other.systemProxy == _this.systemProxy)&&(identical(other.ipv6, _this.ipv6) || other.ipv6 == _this.ipv6)&&(identical(other.allowBypass, _this.allowBypass) || other.allowBypass == _this.allowBypass)&&(identical(other.dnsHijacking, _this.dnsHijacking) || other.dnsHijacking == _this.dnsHijacking)&&(identical(other.smartPauseEnabled, _this.smartPauseEnabled) || other.smartPauseEnabled == _this.smartPauseEnabled)&&const DeepCollectionEquality().equals(other.smartPauseNetworks, _this.smartPauseNetworks)&&(identical(other.smartPauseCloseConnections, _this.smartPauseCloseConnections) || other.smartPauseCloseConnections == _this.smartPauseCloseConnections)&&(identical(other.accessControlProps, _this.accessControlProps) || other.accessControlProps == _this.accessControlProps));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as VpnProps;
  return Object.hash(runtimeType,_this.enable,_this.systemProxy,_this.ipv6,_this.allowBypass,_this.dnsHijacking,_this.smartPauseEnabled,const DeepCollectionEquality().hash(_this.smartPauseNetworks),_this.smartPauseCloseConnections,_this.accessControlProps);
}

@override
String toString() {
  final _this = this as VpnProps;
  return 'VpnProps(enable: ${_this.enable}, systemProxy: ${_this.systemProxy}, ipv6: ${_this.ipv6}, allowBypass: ${_this.allowBypass}, dnsHijacking: ${_this.dnsHijacking}, smartPauseEnabled: ${_this.smartPauseEnabled}, smartPauseNetworks: ${_this.smartPauseNetworks}, smartPauseCloseConnections: ${_this.smartPauseCloseConnections}, accessControlProps: ${_this.accessControlProps})';
}


}

/// @nodoc
abstract mixin class $VpnPropsCopyWith<$Res>  {
  factory $VpnPropsCopyWith(VpnProps value, $Res Function(VpnProps) _then) = _$VpnPropsCopyWithImpl;
@useResult
$Res call({
 bool enable, bool systemProxy, bool ipv6, bool allowBypass, bool dnsHijacking, bool smartPauseEnabled, List<String> smartPauseNetworks, bool smartPauseCloseConnections, AccessControlProps accessControlProps
});


$AccessControlPropsCopyWith<$Res> get accessControlProps;

}
/// @nodoc
class _$VpnPropsCopyWithImpl<$Res>
    implements $VpnPropsCopyWith<$Res> {
  _$VpnPropsCopyWithImpl(this._self, this._then);

  final VpnProps _self;
  final $Res Function(VpnProps) _then;

/// Create a copy of VpnProps
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enable = null,Object? systemProxy = null,Object? ipv6 = null,Object? allowBypass = null,Object? dnsHijacking = null,Object? smartPauseEnabled = null,Object? smartPauseNetworks = null,Object? smartPauseCloseConnections = null,Object? accessControlProps = null,}) {
  return _then(VpnProps(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,systemProxy: null == systemProxy ? _self.systemProxy : systemProxy // ignore: cast_nullable_to_non_nullable
as bool,ipv6: null == ipv6 ? _self.ipv6 : ipv6 // ignore: cast_nullable_to_non_nullable
as bool,allowBypass: null == allowBypass ? _self.allowBypass : allowBypass // ignore: cast_nullable_to_non_nullable
as bool,dnsHijacking: null == dnsHijacking ? _self.dnsHijacking : dnsHijacking // ignore: cast_nullable_to_non_nullable
as bool,smartPauseEnabled: null == smartPauseEnabled ? _self.smartPauseEnabled : smartPauseEnabled // ignore: cast_nullable_to_non_nullable
as bool,smartPauseNetworks: null == smartPauseNetworks ? _self.smartPauseNetworks : smartPauseNetworks // ignore: cast_nullable_to_non_nullable
as List<String>,smartPauseCloseConnections: null == smartPauseCloseConnections ? _self.smartPauseCloseConnections : smartPauseCloseConnections // ignore: cast_nullable_to_non_nullable
as bool,accessControlProps: null == accessControlProps ? _self.accessControlProps : accessControlProps // ignore: cast_nullable_to_non_nullable
as AccessControlProps,
  ));
}
/// Create a copy of VpnProps
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AccessControlPropsCopyWith<$Res> get accessControlProps {
  
  return $AccessControlPropsCopyWith<$Res>(_self.accessControlProps, (value) {
    return _then(_self.copyWith(accessControlProps: value));
  });
}
}


/// Adds pattern-matching-related methods to [VpnProps].
extension VpnPropsPatterns on VpnProps {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VpnProps value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VpnProps() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VpnProps value)  $default,){
final _that = this;
switch (_that) {
case _VpnProps():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VpnProps value)?  $default,){
final _that = this;
switch (_that) {
case _VpnProps() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enable,  bool systemProxy,  bool ipv6,  bool allowBypass,  bool dnsHijacking,  bool smartPauseEnabled,  List<String> smartPauseNetworks,  bool smartPauseCloseConnections,  AccessControlProps accessControlProps)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VpnProps() when $default != null:
return $default(_that.enable,_that.systemProxy,_that.ipv6,_that.allowBypass,_that.dnsHijacking,_that.smartPauseEnabled,_that.smartPauseNetworks,_that.smartPauseCloseConnections,_that.accessControlProps);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enable,  bool systemProxy,  bool ipv6,  bool allowBypass,  bool dnsHijacking,  bool smartPauseEnabled,  List<String> smartPauseNetworks,  bool smartPauseCloseConnections,  AccessControlProps accessControlProps)  $default,) {final _that = this;
switch (_that) {
case _VpnProps():
return $default(_that.enable,_that.systemProxy,_that.ipv6,_that.allowBypass,_that.dnsHijacking,_that.smartPauseEnabled,_that.smartPauseNetworks,_that.smartPauseCloseConnections,_that.accessControlProps);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enable,  bool systemProxy,  bool ipv6,  bool allowBypass,  bool dnsHijacking,  bool smartPauseEnabled,  List<String> smartPauseNetworks,  bool smartPauseCloseConnections,  AccessControlProps accessControlProps)?  $default,) {final _that = this;
switch (_that) {
case _VpnProps() when $default != null:
return $default(_that.enable,_that.systemProxy,_that.ipv6,_that.allowBypass,_that.dnsHijacking,_that.smartPauseEnabled,_that.smartPauseNetworks,_that.smartPauseCloseConnections,_that.accessControlProps);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VpnProps implements VpnProps {
  const _VpnProps({this.enable = true, this.systemProxy = true, this.ipv6 = false, this.allowBypass = true, this.dnsHijacking = false, this.smartPauseEnabled = false,  List<String> smartPauseNetworks = const [], this.smartPauseCloseConnections = false, this.accessControlProps = defaultAccessControlProps}): _smartPauseNetworks = smartPauseNetworks;
  factory _VpnProps.fromJson(Map<String, dynamic> json) => _$VpnPropsFromJson(json);

@override@JsonKey() final  bool enable;
@override@JsonKey() final  bool systemProxy;
@override@JsonKey() final  bool ipv6;
@override@JsonKey() final  bool allowBypass;
@override@JsonKey() final  bool dnsHijacking;
@override@JsonKey() final  bool smartPauseEnabled;
 final  List<String> _smartPauseNetworks;
@override@JsonKey() List<String> get smartPauseNetworks {
  if (_smartPauseNetworks is EqualUnmodifiableListView) return _smartPauseNetworks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_smartPauseNetworks);
}

@override@JsonKey() final  bool smartPauseCloseConnections;
@override@JsonKey() final  AccessControlProps accessControlProps;

/// Create a copy of VpnProps
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VpnPropsCopyWith<_VpnProps> get copyWith => __$VpnPropsCopyWithImpl<_VpnProps>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VpnPropsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VpnProps&&(identical(other.enable, enable) || other.enable == enable)&&(identical(other.systemProxy, systemProxy) || other.systemProxy == systemProxy)&&(identical(other.ipv6, ipv6) || other.ipv6 == ipv6)&&(identical(other.allowBypass, allowBypass) || other.allowBypass == allowBypass)&&(identical(other.dnsHijacking, dnsHijacking) || other.dnsHijacking == dnsHijacking)&&(identical(other.smartPauseEnabled, smartPauseEnabled) || other.smartPauseEnabled == smartPauseEnabled)&&const DeepCollectionEquality().equals(other.smartPauseNetworks, _smartPauseNetworks)&&(identical(other.smartPauseCloseConnections, smartPauseCloseConnections) || other.smartPauseCloseConnections == smartPauseCloseConnections)&&(identical(other.accessControlProps, accessControlProps) || other.accessControlProps == accessControlProps));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,enable,systemProxy,ipv6,allowBypass,dnsHijacking,smartPauseEnabled,const DeepCollectionEquality().hash(_smartPauseNetworks),smartPauseCloseConnections,accessControlProps);
}

@override
String toString() {
    return 'VpnProps(enable: $enable, systemProxy: $systemProxy, ipv6: $ipv6, allowBypass: $allowBypass, dnsHijacking: $dnsHijacking, smartPauseEnabled: $smartPauseEnabled, smartPauseNetworks: $smartPauseNetworks, smartPauseCloseConnections: $smartPauseCloseConnections, accessControlProps: $accessControlProps)';
}


}

/// @nodoc
abstract mixin class _$VpnPropsCopyWith<$Res> implements $VpnPropsCopyWith<$Res> {
  factory _$VpnPropsCopyWith(_VpnProps value, $Res Function(_VpnProps) _then) = __$VpnPropsCopyWithImpl;
@override @useResult
$Res call({
 bool enable, bool systemProxy, bool ipv6, bool allowBypass, bool dnsHijacking, bool smartPauseEnabled, List<String> smartPauseNetworks, bool smartPauseCloseConnections, AccessControlProps accessControlProps
});


@override $AccessControlPropsCopyWith<$Res> get accessControlProps;

}
/// @nodoc
class __$VpnPropsCopyWithImpl<$Res>
    implements _$VpnPropsCopyWith<$Res> {
  __$VpnPropsCopyWithImpl(this._self, this._then);

  final _VpnProps _self;
  final $Res Function(_VpnProps) _then;

/// Create a copy of VpnProps
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enable = null,Object? systemProxy = null,Object? ipv6 = null,Object? allowBypass = null,Object? dnsHijacking = null,Object? smartPauseEnabled = null,Object? smartPauseNetworks = null,Object? smartPauseCloseConnections = null,Object? accessControlProps = null,}) {
  return _then(_VpnProps(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,systemProxy: null == systemProxy ? _self.systemProxy : systemProxy // ignore: cast_nullable_to_non_nullable
as bool,ipv6: null == ipv6 ? _self.ipv6 : ipv6 // ignore: cast_nullable_to_non_nullable
as bool,allowBypass: null == allowBypass ? _self.allowBypass : allowBypass // ignore: cast_nullable_to_non_nullable
as bool,dnsHijacking: null == dnsHijacking ? _self.dnsHijacking : dnsHijacking // ignore: cast_nullable_to_non_nullable
as bool,smartPauseEnabled: null == smartPauseEnabled ? _self.smartPauseEnabled : smartPauseEnabled // ignore: cast_nullable_to_non_nullable
as bool,smartPauseNetworks: null == smartPauseNetworks ? _self._smartPauseNetworks : smartPauseNetworks // ignore: cast_nullable_to_non_nullable
as List<String>,smartPauseCloseConnections: null == smartPauseCloseConnections ? _self.smartPauseCloseConnections : smartPauseCloseConnections // ignore: cast_nullable_to_non_nullable
as bool,accessControlProps: null == accessControlProps ? _self.accessControlProps : accessControlProps // ignore: cast_nullable_to_non_nullable
as AccessControlProps,
  ));
}

/// Create a copy of VpnProps
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AccessControlPropsCopyWith<$Res> get accessControlProps {
  
  return $AccessControlPropsCopyWith<$Res>(_self.accessControlProps, (value) {
    return _then(_self.copyWith(accessControlProps: value));
  });
}
}


/// @nodoc
mixin _$SmartRoutingProps {

 bool get enabled; SmartRoutingPreset get preset; SmartRoutingStrategy get strategy; List<String> get censorCountries; List<String> get canaryForeign; List<String> get canaryDomestic; List<RcxMarker> get openMarkers; List<RcxMarker> get domesticMarkers; List<String> get egressEchoes; List<String> get breakerPatterns; bool get allowDomesticLastResort; bool get requireUdp; bool get respectPick; int get dwellSeconds; int get waveWidth;
/// Create a copy of SmartRoutingProps
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SmartRoutingPropsCopyWith<SmartRoutingProps> get copyWith => _$SmartRoutingPropsCopyWithImpl<SmartRoutingProps>(this as SmartRoutingProps, _$identity);

  /// Serializes this SmartRoutingProps to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SmartRoutingProps;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SmartRoutingProps&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled)&&(identical(other.preset, _this.preset) || other.preset == _this.preset)&&(identical(other.strategy, _this.strategy) || other.strategy == _this.strategy)&&const DeepCollectionEquality().equals(other.censorCountries, _this.censorCountries)&&const DeepCollectionEquality().equals(other.canaryForeign, _this.canaryForeign)&&const DeepCollectionEquality().equals(other.canaryDomestic, _this.canaryDomestic)&&const DeepCollectionEquality().equals(other.openMarkers, _this.openMarkers)&&const DeepCollectionEquality().equals(other.domesticMarkers, _this.domesticMarkers)&&const DeepCollectionEquality().equals(other.egressEchoes, _this.egressEchoes)&&const DeepCollectionEquality().equals(other.breakerPatterns, _this.breakerPatterns)&&(identical(other.allowDomesticLastResort, _this.allowDomesticLastResort) || other.allowDomesticLastResort == _this.allowDomesticLastResort)&&(identical(other.requireUdp, _this.requireUdp) || other.requireUdp == _this.requireUdp)&&(identical(other.respectPick, _this.respectPick) || other.respectPick == _this.respectPick)&&(identical(other.dwellSeconds, _this.dwellSeconds) || other.dwellSeconds == _this.dwellSeconds)&&(identical(other.waveWidth, _this.waveWidth) || other.waveWidth == _this.waveWidth));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SmartRoutingProps;
  return Object.hash(runtimeType,_this.enabled,_this.preset,_this.strategy,const DeepCollectionEquality().hash(_this.censorCountries),const DeepCollectionEquality().hash(_this.canaryForeign),const DeepCollectionEquality().hash(_this.canaryDomestic),const DeepCollectionEquality().hash(_this.openMarkers),const DeepCollectionEquality().hash(_this.domesticMarkers),const DeepCollectionEquality().hash(_this.egressEchoes),const DeepCollectionEquality().hash(_this.breakerPatterns),_this.allowDomesticLastResort,_this.requireUdp,_this.respectPick,_this.dwellSeconds,_this.waveWidth);
}

@override
String toString() {
  final _this = this as SmartRoutingProps;
  return 'SmartRoutingProps(enabled: ${_this.enabled}, preset: ${_this.preset}, strategy: ${_this.strategy}, censorCountries: ${_this.censorCountries}, canaryForeign: ${_this.canaryForeign}, canaryDomestic: ${_this.canaryDomestic}, openMarkers: ${_this.openMarkers}, domesticMarkers: ${_this.domesticMarkers}, egressEchoes: ${_this.egressEchoes}, breakerPatterns: ${_this.breakerPatterns}, allowDomesticLastResort: ${_this.allowDomesticLastResort}, requireUdp: ${_this.requireUdp}, respectPick: ${_this.respectPick}, dwellSeconds: ${_this.dwellSeconds}, waveWidth: ${_this.waveWidth})';
}


}

/// @nodoc
abstract mixin class $SmartRoutingPropsCopyWith<$Res>  {
  factory $SmartRoutingPropsCopyWith(SmartRoutingProps value, $Res Function(SmartRoutingProps) _then) = _$SmartRoutingPropsCopyWithImpl;
@useResult
$Res call({
 bool enabled, SmartRoutingPreset preset, SmartRoutingStrategy strategy, List<String> censorCountries, List<String> canaryForeign, List<String> canaryDomestic, List<RcxMarker> openMarkers, List<RcxMarker> domesticMarkers, List<String> egressEchoes, List<String> breakerPatterns, bool allowDomesticLastResort, bool requireUdp, bool respectPick, int dwellSeconds, int waveWidth
});




}
/// @nodoc
class _$SmartRoutingPropsCopyWithImpl<$Res>
    implements $SmartRoutingPropsCopyWith<$Res> {
  _$SmartRoutingPropsCopyWithImpl(this._self, this._then);

  final SmartRoutingProps _self;
  final $Res Function(SmartRoutingProps) _then;

/// Create a copy of SmartRoutingProps
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enabled = null,Object? preset = null,Object? strategy = null,Object? censorCountries = null,Object? canaryForeign = null,Object? canaryDomestic = null,Object? openMarkers = null,Object? domesticMarkers = null,Object? egressEchoes = null,Object? breakerPatterns = null,Object? allowDomesticLastResort = null,Object? requireUdp = null,Object? respectPick = null,Object? dwellSeconds = null,Object? waveWidth = null,}) {
  return _then(SmartRoutingProps(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,preset: null == preset ? _self.preset : preset // ignore: cast_nullable_to_non_nullable
as SmartRoutingPreset,strategy: null == strategy ? _self.strategy : strategy // ignore: cast_nullable_to_non_nullable
as SmartRoutingStrategy,censorCountries: null == censorCountries ? _self.censorCountries : censorCountries // ignore: cast_nullable_to_non_nullable
as List<String>,canaryForeign: null == canaryForeign ? _self.canaryForeign : canaryForeign // ignore: cast_nullable_to_non_nullable
as List<String>,canaryDomestic: null == canaryDomestic ? _self.canaryDomestic : canaryDomestic // ignore: cast_nullable_to_non_nullable
as List<String>,openMarkers: null == openMarkers ? _self.openMarkers : openMarkers // ignore: cast_nullable_to_non_nullable
as List<RcxMarker>,domesticMarkers: null == domesticMarkers ? _self.domesticMarkers : domesticMarkers // ignore: cast_nullable_to_non_nullable
as List<RcxMarker>,egressEchoes: null == egressEchoes ? _self.egressEchoes : egressEchoes // ignore: cast_nullable_to_non_nullable
as List<String>,breakerPatterns: null == breakerPatterns ? _self.breakerPatterns : breakerPatterns // ignore: cast_nullable_to_non_nullable
as List<String>,allowDomesticLastResort: null == allowDomesticLastResort ? _self.allowDomesticLastResort : allowDomesticLastResort // ignore: cast_nullable_to_non_nullable
as bool,requireUdp: null == requireUdp ? _self.requireUdp : requireUdp // ignore: cast_nullable_to_non_nullable
as bool,respectPick: null == respectPick ? _self.respectPick : respectPick // ignore: cast_nullable_to_non_nullable
as bool,dwellSeconds: null == dwellSeconds ? _self.dwellSeconds : dwellSeconds // ignore: cast_nullable_to_non_nullable
as int,waveWidth: null == waveWidth ? _self.waveWidth : waveWidth // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SmartRoutingProps].
extension SmartRoutingPropsPatterns on SmartRoutingProps {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SmartRoutingProps value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SmartRoutingProps() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SmartRoutingProps value)  $default,){
final _that = this;
switch (_that) {
case _SmartRoutingProps():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SmartRoutingProps value)?  $default,){
final _that = this;
switch (_that) {
case _SmartRoutingProps() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enabled,  SmartRoutingPreset preset,  SmartRoutingStrategy strategy,  List<String> censorCountries,  List<String> canaryForeign,  List<String> canaryDomestic,  List<RcxMarker> openMarkers,  List<RcxMarker> domesticMarkers,  List<String> egressEchoes,  List<String> breakerPatterns,  bool allowDomesticLastResort,  bool requireUdp,  bool respectPick,  int dwellSeconds,  int waveWidth)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SmartRoutingProps() when $default != null:
return $default(_that.enabled,_that.preset,_that.strategy,_that.censorCountries,_that.canaryForeign,_that.canaryDomestic,_that.openMarkers,_that.domesticMarkers,_that.egressEchoes,_that.breakerPatterns,_that.allowDomesticLastResort,_that.requireUdp,_that.respectPick,_that.dwellSeconds,_that.waveWidth);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enabled,  SmartRoutingPreset preset,  SmartRoutingStrategy strategy,  List<String> censorCountries,  List<String> canaryForeign,  List<String> canaryDomestic,  List<RcxMarker> openMarkers,  List<RcxMarker> domesticMarkers,  List<String> egressEchoes,  List<String> breakerPatterns,  bool allowDomesticLastResort,  bool requireUdp,  bool respectPick,  int dwellSeconds,  int waveWidth)  $default,) {final _that = this;
switch (_that) {
case _SmartRoutingProps():
return $default(_that.enabled,_that.preset,_that.strategy,_that.censorCountries,_that.canaryForeign,_that.canaryDomestic,_that.openMarkers,_that.domesticMarkers,_that.egressEchoes,_that.breakerPatterns,_that.allowDomesticLastResort,_that.requireUdp,_that.respectPick,_that.dwellSeconds,_that.waveWidth);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enabled,  SmartRoutingPreset preset,  SmartRoutingStrategy strategy,  List<String> censorCountries,  List<String> canaryForeign,  List<String> canaryDomestic,  List<RcxMarker> openMarkers,  List<RcxMarker> domesticMarkers,  List<String> egressEchoes,  List<String> breakerPatterns,  bool allowDomesticLastResort,  bool requireUdp,  bool respectPick,  int dwellSeconds,  int waveWidth)?  $default,) {final _that = this;
switch (_that) {
case _SmartRoutingProps() when $default != null:
return $default(_that.enabled,_that.preset,_that.strategy,_that.censorCountries,_that.canaryForeign,_that.canaryDomestic,_that.openMarkers,_that.domesticMarkers,_that.egressEchoes,_that.breakerPatterns,_that.allowDomesticLastResort,_that.requireUdp,_that.respectPick,_that.dwellSeconds,_that.waveWidth);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _SmartRoutingProps implements SmartRoutingProps {
  const _SmartRoutingProps({this.enabled = false, this.preset = SmartRoutingPreset.off, this.strategy = SmartRoutingStrategy.balanced,  List<String> censorCountries = const [],  List<String> canaryForeign = const [],  List<String> canaryDomestic = const [],  List<RcxMarker> openMarkers = const [],  List<RcxMarker> domesticMarkers = const [],  List<String> egressEchoes = const [],  List<String> breakerPatterns = const [], this.allowDomesticLastResort = true, this.requireUdp = false, this.respectPick = true, this.dwellSeconds = 90, this.waveWidth = 12}): _censorCountries = censorCountries,_canaryForeign = canaryForeign,_canaryDomestic = canaryDomestic,_openMarkers = openMarkers,_domesticMarkers = domesticMarkers,_egressEchoes = egressEchoes,_breakerPatterns = breakerPatterns;
  factory _SmartRoutingProps.fromJson(Map<String, dynamic> json) => _$SmartRoutingPropsFromJson(json);

@override@JsonKey() final  bool enabled;
@override@JsonKey() final  SmartRoutingPreset preset;
@override@JsonKey() final  SmartRoutingStrategy strategy;
 final  List<String> _censorCountries;
@override@JsonKey() List<String> get censorCountries {
  if (_censorCountries is EqualUnmodifiableListView) return _censorCountries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_censorCountries);
}

 final  List<String> _canaryForeign;
@override@JsonKey() List<String> get canaryForeign {
  if (_canaryForeign is EqualUnmodifiableListView) return _canaryForeign;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_canaryForeign);
}

 final  List<String> _canaryDomestic;
@override@JsonKey() List<String> get canaryDomestic {
  if (_canaryDomestic is EqualUnmodifiableListView) return _canaryDomestic;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_canaryDomestic);
}

 final  List<RcxMarker> _openMarkers;
@override@JsonKey() List<RcxMarker> get openMarkers {
  if (_openMarkers is EqualUnmodifiableListView) return _openMarkers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_openMarkers);
}

 final  List<RcxMarker> _domesticMarkers;
@override@JsonKey() List<RcxMarker> get domesticMarkers {
  if (_domesticMarkers is EqualUnmodifiableListView) return _domesticMarkers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_domesticMarkers);
}

 final  List<String> _egressEchoes;
@override@JsonKey() List<String> get egressEchoes {
  if (_egressEchoes is EqualUnmodifiableListView) return _egressEchoes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_egressEchoes);
}

 final  List<String> _breakerPatterns;
@override@JsonKey() List<String> get breakerPatterns {
  if (_breakerPatterns is EqualUnmodifiableListView) return _breakerPatterns;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_breakerPatterns);
}

@override@JsonKey() final  bool allowDomesticLastResort;
@override@JsonKey() final  bool requireUdp;
@override@JsonKey() final  bool respectPick;
@override@JsonKey() final  int dwellSeconds;
@override@JsonKey() final  int waveWidth;

/// Create a copy of SmartRoutingProps
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SmartRoutingPropsCopyWith<_SmartRoutingProps> get copyWith => __$SmartRoutingPropsCopyWithImpl<_SmartRoutingProps>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SmartRoutingPropsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SmartRoutingProps&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.preset, preset) || other.preset == preset)&&(identical(other.strategy, strategy) || other.strategy == strategy)&&const DeepCollectionEquality().equals(other.censorCountries, _censorCountries)&&const DeepCollectionEquality().equals(other.canaryForeign, _canaryForeign)&&const DeepCollectionEquality().equals(other.canaryDomestic, _canaryDomestic)&&const DeepCollectionEquality().equals(other.openMarkers, _openMarkers)&&const DeepCollectionEquality().equals(other.domesticMarkers, _domesticMarkers)&&const DeepCollectionEquality().equals(other.egressEchoes, _egressEchoes)&&const DeepCollectionEquality().equals(other.breakerPatterns, _breakerPatterns)&&(identical(other.allowDomesticLastResort, allowDomesticLastResort) || other.allowDomesticLastResort == allowDomesticLastResort)&&(identical(other.requireUdp, requireUdp) || other.requireUdp == requireUdp)&&(identical(other.respectPick, respectPick) || other.respectPick == respectPick)&&(identical(other.dwellSeconds, dwellSeconds) || other.dwellSeconds == dwellSeconds)&&(identical(other.waveWidth, waveWidth) || other.waveWidth == waveWidth));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,enabled,preset,strategy,const DeepCollectionEquality().hash(_censorCountries),const DeepCollectionEquality().hash(_canaryForeign),const DeepCollectionEquality().hash(_canaryDomestic),const DeepCollectionEquality().hash(_openMarkers),const DeepCollectionEquality().hash(_domesticMarkers),const DeepCollectionEquality().hash(_egressEchoes),const DeepCollectionEquality().hash(_breakerPatterns),allowDomesticLastResort,requireUdp,respectPick,dwellSeconds,waveWidth);
}

@override
String toString() {
    return 'SmartRoutingProps(enabled: $enabled, preset: $preset, strategy: $strategy, censorCountries: $censorCountries, canaryForeign: $canaryForeign, canaryDomestic: $canaryDomestic, openMarkers: $openMarkers, domesticMarkers: $domesticMarkers, egressEchoes: $egressEchoes, breakerPatterns: $breakerPatterns, allowDomesticLastResort: $allowDomesticLastResort, requireUdp: $requireUdp, respectPick: $respectPick, dwellSeconds: $dwellSeconds, waveWidth: $waveWidth)';
}


}

/// @nodoc
abstract mixin class _$SmartRoutingPropsCopyWith<$Res> implements $SmartRoutingPropsCopyWith<$Res> {
  factory _$SmartRoutingPropsCopyWith(_SmartRoutingProps value, $Res Function(_SmartRoutingProps) _then) = __$SmartRoutingPropsCopyWithImpl;
@override @useResult
$Res call({
 bool enabled, SmartRoutingPreset preset, SmartRoutingStrategy strategy, List<String> censorCountries, List<String> canaryForeign, List<String> canaryDomestic, List<RcxMarker> openMarkers, List<RcxMarker> domesticMarkers, List<String> egressEchoes, List<String> breakerPatterns, bool allowDomesticLastResort, bool requireUdp, bool respectPick, int dwellSeconds, int waveWidth
});




}
/// @nodoc
class __$SmartRoutingPropsCopyWithImpl<$Res>
    implements _$SmartRoutingPropsCopyWith<$Res> {
  __$SmartRoutingPropsCopyWithImpl(this._self, this._then);

  final _SmartRoutingProps _self;
  final $Res Function(_SmartRoutingProps) _then;

/// Create a copy of SmartRoutingProps
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enabled = null,Object? preset = null,Object? strategy = null,Object? censorCountries = null,Object? canaryForeign = null,Object? canaryDomestic = null,Object? openMarkers = null,Object? domesticMarkers = null,Object? egressEchoes = null,Object? breakerPatterns = null,Object? allowDomesticLastResort = null,Object? requireUdp = null,Object? respectPick = null,Object? dwellSeconds = null,Object? waveWidth = null,}) {
  return _then(_SmartRoutingProps(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,preset: null == preset ? _self.preset : preset // ignore: cast_nullable_to_non_nullable
as SmartRoutingPreset,strategy: null == strategy ? _self.strategy : strategy // ignore: cast_nullable_to_non_nullable
as SmartRoutingStrategy,censorCountries: null == censorCountries ? _self._censorCountries : censorCountries // ignore: cast_nullable_to_non_nullable
as List<String>,canaryForeign: null == canaryForeign ? _self._canaryForeign : canaryForeign // ignore: cast_nullable_to_non_nullable
as List<String>,canaryDomestic: null == canaryDomestic ? _self._canaryDomestic : canaryDomestic // ignore: cast_nullable_to_non_nullable
as List<String>,openMarkers: null == openMarkers ? _self._openMarkers : openMarkers // ignore: cast_nullable_to_non_nullable
as List<RcxMarker>,domesticMarkers: null == domesticMarkers ? _self._domesticMarkers : domesticMarkers // ignore: cast_nullable_to_non_nullable
as List<RcxMarker>,egressEchoes: null == egressEchoes ? _self._egressEchoes : egressEchoes // ignore: cast_nullable_to_non_nullable
as List<String>,breakerPatterns: null == breakerPatterns ? _self._breakerPatterns : breakerPatterns // ignore: cast_nullable_to_non_nullable
as List<String>,allowDomesticLastResort: null == allowDomesticLastResort ? _self.allowDomesticLastResort : allowDomesticLastResort // ignore: cast_nullable_to_non_nullable
as bool,requireUdp: null == requireUdp ? _self.requireUdp : requireUdp // ignore: cast_nullable_to_non_nullable
as bool,respectPick: null == respectPick ? _self.respectPick : respectPick // ignore: cast_nullable_to_non_nullable
as bool,dwellSeconds: null == dwellSeconds ? _self.dwellSeconds : dwellSeconds // ignore: cast_nullable_to_non_nullable
as int,waveWidth: null == waveWidth ? _self.waveWidth : waveWidth // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$AuthenticationProps {

 bool get enable; String get username; String get password;
/// Create a copy of AuthenticationProps
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthenticationPropsCopyWith<AuthenticationProps> get copyWith => _$AuthenticationPropsCopyWithImpl<AuthenticationProps>(this as AuthenticationProps, _$identity);

  /// Serializes this AuthenticationProps to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AuthenticationProps;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthenticationProps&&(identical(other.enable, _this.enable) || other.enable == _this.enable)&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.password, _this.password) || other.password == _this.password));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AuthenticationProps;
  return Object.hash(runtimeType,_this.enable,_this.username,_this.password);
}

@override
String toString() {
  final _this = this as AuthenticationProps;
  return 'AuthenticationProps(enable: ${_this.enable}, username: ${_this.username}, password: ${_this.password})';
}


}

/// @nodoc
abstract mixin class $AuthenticationPropsCopyWith<$Res>  {
  factory $AuthenticationPropsCopyWith(AuthenticationProps value, $Res Function(AuthenticationProps) _then) = _$AuthenticationPropsCopyWithImpl;
@useResult
$Res call({
 bool enable, String username, String password
});




}
/// @nodoc
class _$AuthenticationPropsCopyWithImpl<$Res>
    implements $AuthenticationPropsCopyWith<$Res> {
  _$AuthenticationPropsCopyWithImpl(this._self, this._then);

  final AuthenticationProps _self;
  final $Res Function(AuthenticationProps) _then;

/// Create a copy of AuthenticationProps
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enable = null,Object? username = null,Object? password = null,}) {
  return _then(AuthenticationProps(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AuthenticationProps].
extension AuthenticationPropsPatterns on AuthenticationProps {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthenticationProps value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthenticationProps() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthenticationProps value)  $default,){
final _that = this;
switch (_that) {
case _AuthenticationProps():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthenticationProps value)?  $default,){
final _that = this;
switch (_that) {
case _AuthenticationProps() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enable,  String username,  String password)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthenticationProps() when $default != null:
return $default(_that.enable,_that.username,_that.password);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enable,  String username,  String password)  $default,) {final _that = this;
switch (_that) {
case _AuthenticationProps():
return $default(_that.enable,_that.username,_that.password);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enable,  String username,  String password)?  $default,) {final _that = this;
switch (_that) {
case _AuthenticationProps() when $default != null:
return $default(_that.enable,_that.username,_that.password);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuthenticationProps implements AuthenticationProps {
  const _AuthenticationProps({this.enable = false, this.username = '', this.password = ''});
  factory _AuthenticationProps.fromJson(Map<String, dynamic> json) => _$AuthenticationPropsFromJson(json);

@override@JsonKey() final  bool enable;
@override@JsonKey() final  String username;
@override@JsonKey() final  String password;

/// Create a copy of AuthenticationProps
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthenticationPropsCopyWith<_AuthenticationProps> get copyWith => __$AuthenticationPropsCopyWithImpl<_AuthenticationProps>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuthenticationPropsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthenticationProps&&(identical(other.enable, enable) || other.enable == enable)&&(identical(other.username, username) || other.username == username)&&(identical(other.password, password) || other.password == password));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,enable,username,password);
}

@override
String toString() {
    return 'AuthenticationProps(enable: $enable, username: $username, password: $password)';
}


}

/// @nodoc
abstract mixin class _$AuthenticationPropsCopyWith<$Res> implements $AuthenticationPropsCopyWith<$Res> {
  factory _$AuthenticationPropsCopyWith(_AuthenticationProps value, $Res Function(_AuthenticationProps) _then) = __$AuthenticationPropsCopyWithImpl;
@override @useResult
$Res call({
 bool enable, String username, String password
});




}
/// @nodoc
class __$AuthenticationPropsCopyWithImpl<$Res>
    implements _$AuthenticationPropsCopyWith<$Res> {
  __$AuthenticationPropsCopyWithImpl(this._self, this._then);

  final _AuthenticationProps _self;
  final $Res Function(_AuthenticationProps) _then;

/// Create a copy of AuthenticationProps
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enable = null,Object? username = null,Object? password = null,}) {
  return _then(_AuthenticationProps(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$NetworkProps {

 bool get systemProxy; List<String> get bypassDomain; RouteMode get routeMode; bool get autoSetSystemDns; bool get appendSystemDns; bool get overrideSubscriptionNetwork; AuthenticationProps get authentication;
/// Create a copy of NetworkProps
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NetworkPropsCopyWith<NetworkProps> get copyWith => _$NetworkPropsCopyWithImpl<NetworkProps>(this as NetworkProps, _$identity);

  /// Serializes this NetworkProps to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as NetworkProps;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NetworkProps&&(identical(other.systemProxy, _this.systemProxy) || other.systemProxy == _this.systemProxy)&&const DeepCollectionEquality().equals(other.bypassDomain, _this.bypassDomain)&&(identical(other.routeMode, _this.routeMode) || other.routeMode == _this.routeMode)&&(identical(other.autoSetSystemDns, _this.autoSetSystemDns) || other.autoSetSystemDns == _this.autoSetSystemDns)&&(identical(other.appendSystemDns, _this.appendSystemDns) || other.appendSystemDns == _this.appendSystemDns)&&(identical(other.overrideSubscriptionNetwork, _this.overrideSubscriptionNetwork) || other.overrideSubscriptionNetwork == _this.overrideSubscriptionNetwork)&&(identical(other.authentication, _this.authentication) || other.authentication == _this.authentication));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as NetworkProps;
  return Object.hash(runtimeType,_this.systemProxy,const DeepCollectionEquality().hash(_this.bypassDomain),_this.routeMode,_this.autoSetSystemDns,_this.appendSystemDns,_this.overrideSubscriptionNetwork,_this.authentication);
}

@override
String toString() {
  final _this = this as NetworkProps;
  return 'NetworkProps(systemProxy: ${_this.systemProxy}, bypassDomain: ${_this.bypassDomain}, routeMode: ${_this.routeMode}, autoSetSystemDns: ${_this.autoSetSystemDns}, appendSystemDns: ${_this.appendSystemDns}, overrideSubscriptionNetwork: ${_this.overrideSubscriptionNetwork}, authentication: ${_this.authentication})';
}


}

/// @nodoc
abstract mixin class $NetworkPropsCopyWith<$Res>  {
  factory $NetworkPropsCopyWith(NetworkProps value, $Res Function(NetworkProps) _then) = _$NetworkPropsCopyWithImpl;
@useResult
$Res call({
 bool systemProxy, List<String> bypassDomain, RouteMode routeMode, bool autoSetSystemDns, bool appendSystemDns, bool overrideSubscriptionNetwork, AuthenticationProps authentication
});


$AuthenticationPropsCopyWith<$Res> get authentication;

}
/// @nodoc
class _$NetworkPropsCopyWithImpl<$Res>
    implements $NetworkPropsCopyWith<$Res> {
  _$NetworkPropsCopyWithImpl(this._self, this._then);

  final NetworkProps _self;
  final $Res Function(NetworkProps) _then;

/// Create a copy of NetworkProps
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? systemProxy = null,Object? bypassDomain = null,Object? routeMode = null,Object? autoSetSystemDns = null,Object? appendSystemDns = null,Object? overrideSubscriptionNetwork = null,Object? authentication = null,}) {
  return _then(NetworkProps(
systemProxy: null == systemProxy ? _self.systemProxy : systemProxy // ignore: cast_nullable_to_non_nullable
as bool,bypassDomain: null == bypassDomain ? _self.bypassDomain : bypassDomain // ignore: cast_nullable_to_non_nullable
as List<String>,routeMode: null == routeMode ? _self.routeMode : routeMode // ignore: cast_nullable_to_non_nullable
as RouteMode,autoSetSystemDns: null == autoSetSystemDns ? _self.autoSetSystemDns : autoSetSystemDns // ignore: cast_nullable_to_non_nullable
as bool,appendSystemDns: null == appendSystemDns ? _self.appendSystemDns : appendSystemDns // ignore: cast_nullable_to_non_nullable
as bool,overrideSubscriptionNetwork: null == overrideSubscriptionNetwork ? _self.overrideSubscriptionNetwork : overrideSubscriptionNetwork // ignore: cast_nullable_to_non_nullable
as bool,authentication: null == authentication ? _self.authentication : authentication // ignore: cast_nullable_to_non_nullable
as AuthenticationProps,
  ));
}
/// Create a copy of NetworkProps
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthenticationPropsCopyWith<$Res> get authentication {
  
  return $AuthenticationPropsCopyWith<$Res>(_self.authentication, (value) {
    return _then(_self.copyWith(authentication: value));
  });
}
}


/// Adds pattern-matching-related methods to [NetworkProps].
extension NetworkPropsPatterns on NetworkProps {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NetworkProps value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NetworkProps() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NetworkProps value)  $default,){
final _that = this;
switch (_that) {
case _NetworkProps():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NetworkProps value)?  $default,){
final _that = this;
switch (_that) {
case _NetworkProps() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool systemProxy,  List<String> bypassDomain,  RouteMode routeMode,  bool autoSetSystemDns,  bool appendSystemDns,  bool overrideSubscriptionNetwork,  AuthenticationProps authentication)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NetworkProps() when $default != null:
return $default(_that.systemProxy,_that.bypassDomain,_that.routeMode,_that.autoSetSystemDns,_that.appendSystemDns,_that.overrideSubscriptionNetwork,_that.authentication);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool systemProxy,  List<String> bypassDomain,  RouteMode routeMode,  bool autoSetSystemDns,  bool appendSystemDns,  bool overrideSubscriptionNetwork,  AuthenticationProps authentication)  $default,) {final _that = this;
switch (_that) {
case _NetworkProps():
return $default(_that.systemProxy,_that.bypassDomain,_that.routeMode,_that.autoSetSystemDns,_that.appendSystemDns,_that.overrideSubscriptionNetwork,_that.authentication);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool systemProxy,  List<String> bypassDomain,  RouteMode routeMode,  bool autoSetSystemDns,  bool appendSystemDns,  bool overrideSubscriptionNetwork,  AuthenticationProps authentication)?  $default,) {final _that = this;
switch (_that) {
case _NetworkProps() when $default != null:
return $default(_that.systemProxy,_that.bypassDomain,_that.routeMode,_that.autoSetSystemDns,_that.appendSystemDns,_that.overrideSubscriptionNetwork,_that.authentication);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NetworkProps implements NetworkProps {
  const _NetworkProps({this.systemProxy = true,  List<String> bypassDomain = defaultBypassDomain, this.routeMode = RouteMode.config, this.autoSetSystemDns = true, this.appendSystemDns = false, this.overrideSubscriptionNetwork = false, this.authentication = defaultAuthenticationProps}): _bypassDomain = bypassDomain;
  factory _NetworkProps.fromJson(Map<String, dynamic> json) => _$NetworkPropsFromJson(json);

@override@JsonKey() final  bool systemProxy;
 final  List<String> _bypassDomain;
@override@JsonKey() List<String> get bypassDomain {
  if (_bypassDomain is EqualUnmodifiableListView) return _bypassDomain;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bypassDomain);
}

@override@JsonKey() final  RouteMode routeMode;
@override@JsonKey() final  bool autoSetSystemDns;
@override@JsonKey() final  bool appendSystemDns;
@override@JsonKey() final  bool overrideSubscriptionNetwork;
@override@JsonKey() final  AuthenticationProps authentication;

/// Create a copy of NetworkProps
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NetworkPropsCopyWith<_NetworkProps> get copyWith => __$NetworkPropsCopyWithImpl<_NetworkProps>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NetworkPropsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NetworkProps&&(identical(other.systemProxy, systemProxy) || other.systemProxy == systemProxy)&&const DeepCollectionEquality().equals(other.bypassDomain, _bypassDomain)&&(identical(other.routeMode, routeMode) || other.routeMode == routeMode)&&(identical(other.autoSetSystemDns, autoSetSystemDns) || other.autoSetSystemDns == autoSetSystemDns)&&(identical(other.appendSystemDns, appendSystemDns) || other.appendSystemDns == appendSystemDns)&&(identical(other.overrideSubscriptionNetwork, overrideSubscriptionNetwork) || other.overrideSubscriptionNetwork == overrideSubscriptionNetwork)&&(identical(other.authentication, authentication) || other.authentication == authentication));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,systemProxy,const DeepCollectionEquality().hash(_bypassDomain),routeMode,autoSetSystemDns,appendSystemDns,overrideSubscriptionNetwork,authentication);
}

@override
String toString() {
    return 'NetworkProps(systemProxy: $systemProxy, bypassDomain: $bypassDomain, routeMode: $routeMode, autoSetSystemDns: $autoSetSystemDns, appendSystemDns: $appendSystemDns, overrideSubscriptionNetwork: $overrideSubscriptionNetwork, authentication: $authentication)';
}


}

/// @nodoc
abstract mixin class _$NetworkPropsCopyWith<$Res> implements $NetworkPropsCopyWith<$Res> {
  factory _$NetworkPropsCopyWith(_NetworkProps value, $Res Function(_NetworkProps) _then) = __$NetworkPropsCopyWithImpl;
@override @useResult
$Res call({
 bool systemProxy, List<String> bypassDomain, RouteMode routeMode, bool autoSetSystemDns, bool appendSystemDns, bool overrideSubscriptionNetwork, AuthenticationProps authentication
});


@override $AuthenticationPropsCopyWith<$Res> get authentication;

}
/// @nodoc
class __$NetworkPropsCopyWithImpl<$Res>
    implements _$NetworkPropsCopyWith<$Res> {
  __$NetworkPropsCopyWithImpl(this._self, this._then);

  final _NetworkProps _self;
  final $Res Function(_NetworkProps) _then;

/// Create a copy of NetworkProps
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? systemProxy = null,Object? bypassDomain = null,Object? routeMode = null,Object? autoSetSystemDns = null,Object? appendSystemDns = null,Object? overrideSubscriptionNetwork = null,Object? authentication = null,}) {
  return _then(_NetworkProps(
systemProxy: null == systemProxy ? _self.systemProxy : systemProxy // ignore: cast_nullable_to_non_nullable
as bool,bypassDomain: null == bypassDomain ? _self._bypassDomain : bypassDomain // ignore: cast_nullable_to_non_nullable
as List<String>,routeMode: null == routeMode ? _self.routeMode : routeMode // ignore: cast_nullable_to_non_nullable
as RouteMode,autoSetSystemDns: null == autoSetSystemDns ? _self.autoSetSystemDns : autoSetSystemDns // ignore: cast_nullable_to_non_nullable
as bool,appendSystemDns: null == appendSystemDns ? _self.appendSystemDns : appendSystemDns // ignore: cast_nullable_to_non_nullable
as bool,overrideSubscriptionNetwork: null == overrideSubscriptionNetwork ? _self.overrideSubscriptionNetwork : overrideSubscriptionNetwork // ignore: cast_nullable_to_non_nullable
as bool,authentication: null == authentication ? _self.authentication : authentication // ignore: cast_nullable_to_non_nullable
as AuthenticationProps,
  ));
}

/// Create a copy of NetworkProps
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthenticationPropsCopyWith<$Res> get authentication {
  
  return $AuthenticationPropsCopyWith<$Res>(_self.authentication, (value) {
    return _then(_self.copyWith(authentication: value));
  });
}
}


/// @nodoc
mixin _$ProxiesStyleProps {

 ProxiesType get type; ProxiesSortType get sortType; ProxiesLayout get layout; ProxiesIconStyle get iconStyle; ProxyCardType get cardType; bool get followPanel; Set<ProxiesStyleField> get userOwned;
/// Create a copy of ProxiesStyleProps
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProxiesStylePropsCopyWith<ProxiesStyleProps> get copyWith => _$ProxiesStylePropsCopyWithImpl<ProxiesStyleProps>(this as ProxiesStyleProps, _$identity);

  /// Serializes this ProxiesStyleProps to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ProxiesStyleProps;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProxiesStyleProps&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.sortType, _this.sortType) || other.sortType == _this.sortType)&&(identical(other.layout, _this.layout) || other.layout == _this.layout)&&(identical(other.iconStyle, _this.iconStyle) || other.iconStyle == _this.iconStyle)&&(identical(other.cardType, _this.cardType) || other.cardType == _this.cardType)&&(identical(other.followPanel, _this.followPanel) || other.followPanel == _this.followPanel)&&const DeepCollectionEquality().equals(other.userOwned, _this.userOwned));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ProxiesStyleProps;
  return Object.hash(runtimeType,_this.type,_this.sortType,_this.layout,_this.iconStyle,_this.cardType,_this.followPanel,const DeepCollectionEquality().hash(_this.userOwned));
}

@override
String toString() {
  final _this = this as ProxiesStyleProps;
  return 'ProxiesStyleProps(type: ${_this.type}, sortType: ${_this.sortType}, layout: ${_this.layout}, iconStyle: ${_this.iconStyle}, cardType: ${_this.cardType}, followPanel: ${_this.followPanel}, userOwned: ${_this.userOwned})';
}


}

/// @nodoc
abstract mixin class $ProxiesStylePropsCopyWith<$Res>  {
  factory $ProxiesStylePropsCopyWith(ProxiesStyleProps value, $Res Function(ProxiesStyleProps) _then) = _$ProxiesStylePropsCopyWithImpl;
@useResult
$Res call({
 ProxiesType type, ProxiesSortType sortType, ProxiesLayout layout, ProxiesIconStyle iconStyle, ProxyCardType cardType, bool followPanel, Set<ProxiesStyleField> userOwned
});




}
/// @nodoc
class _$ProxiesStylePropsCopyWithImpl<$Res>
    implements $ProxiesStylePropsCopyWith<$Res> {
  _$ProxiesStylePropsCopyWithImpl(this._self, this._then);

  final ProxiesStyleProps _self;
  final $Res Function(ProxiesStyleProps) _then;

/// Create a copy of ProxiesStyleProps
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? sortType = null,Object? layout = null,Object? iconStyle = null,Object? cardType = null,Object? followPanel = null,Object? userOwned = null,}) {
  return _then(ProxiesStyleProps(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ProxiesType,sortType: null == sortType ? _self.sortType : sortType // ignore: cast_nullable_to_non_nullable
as ProxiesSortType,layout: null == layout ? _self.layout : layout // ignore: cast_nullable_to_non_nullable
as ProxiesLayout,iconStyle: null == iconStyle ? _self.iconStyle : iconStyle // ignore: cast_nullable_to_non_nullable
as ProxiesIconStyle,cardType: null == cardType ? _self.cardType : cardType // ignore: cast_nullable_to_non_nullable
as ProxyCardType,followPanel: null == followPanel ? _self.followPanel : followPanel // ignore: cast_nullable_to_non_nullable
as bool,userOwned: null == userOwned ? _self.userOwned : userOwned // ignore: cast_nullable_to_non_nullable
as Set<ProxiesStyleField>,
  ));
}

}


/// Adds pattern-matching-related methods to [ProxiesStyleProps].
extension ProxiesStylePropsPatterns on ProxiesStyleProps {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProxiesStyleProps value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProxiesStyleProps() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProxiesStyleProps value)  $default,){
final _that = this;
switch (_that) {
case _ProxiesStyleProps():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProxiesStyleProps value)?  $default,){
final _that = this;
switch (_that) {
case _ProxiesStyleProps() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ProxiesType type,  ProxiesSortType sortType,  ProxiesLayout layout,  ProxiesIconStyle iconStyle,  ProxyCardType cardType,  bool followPanel,  Set<ProxiesStyleField> userOwned)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProxiesStyleProps() when $default != null:
return $default(_that.type,_that.sortType,_that.layout,_that.iconStyle,_that.cardType,_that.followPanel,_that.userOwned);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ProxiesType type,  ProxiesSortType sortType,  ProxiesLayout layout,  ProxiesIconStyle iconStyle,  ProxyCardType cardType,  bool followPanel,  Set<ProxiesStyleField> userOwned)  $default,) {final _that = this;
switch (_that) {
case _ProxiesStyleProps():
return $default(_that.type,_that.sortType,_that.layout,_that.iconStyle,_that.cardType,_that.followPanel,_that.userOwned);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ProxiesType type,  ProxiesSortType sortType,  ProxiesLayout layout,  ProxiesIconStyle iconStyle,  ProxyCardType cardType,  bool followPanel,  Set<ProxiesStyleField> userOwned)?  $default,) {final _that = this;
switch (_that) {
case _ProxiesStyleProps() when $default != null:
return $default(_that.type,_that.sortType,_that.layout,_that.iconStyle,_that.cardType,_that.followPanel,_that.userOwned);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProxiesStyleProps implements ProxiesStyleProps {
  const _ProxiesStyleProps({this.type = ProxiesType.tab, this.sortType = ProxiesSortType.none, this.layout = ProxiesLayout.standard, this.iconStyle = ProxiesIconStyle.standard, this.cardType = ProxyCardType.expand, this.followPanel = true,  Set<ProxiesStyleField> userOwned = const <ProxiesStyleField>{}}): _userOwned = userOwned;
  factory _ProxiesStyleProps.fromJson(Map<String, dynamic> json) => _$ProxiesStylePropsFromJson(json);

@override@JsonKey() final  ProxiesType type;
@override@JsonKey() final  ProxiesSortType sortType;
@override@JsonKey() final  ProxiesLayout layout;
@override@JsonKey() final  ProxiesIconStyle iconStyle;
@override@JsonKey() final  ProxyCardType cardType;
@override@JsonKey() final  bool followPanel;
 final  Set<ProxiesStyleField> _userOwned;
@override@JsonKey() Set<ProxiesStyleField> get userOwned {
  if (_userOwned is EqualUnmodifiableSetView) return _userOwned;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_userOwned);
}


/// Create a copy of ProxiesStyleProps
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProxiesStylePropsCopyWith<_ProxiesStyleProps> get copyWith => __$ProxiesStylePropsCopyWithImpl<_ProxiesStyleProps>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProxiesStylePropsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProxiesStyleProps&&(identical(other.type, type) || other.type == type)&&(identical(other.sortType, sortType) || other.sortType == sortType)&&(identical(other.layout, layout) || other.layout == layout)&&(identical(other.iconStyle, iconStyle) || other.iconStyle == iconStyle)&&(identical(other.cardType, cardType) || other.cardType == cardType)&&(identical(other.followPanel, followPanel) || other.followPanel == followPanel)&&const DeepCollectionEquality().equals(other.userOwned, _userOwned));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,type,sortType,layout,iconStyle,cardType,followPanel,const DeepCollectionEquality().hash(_userOwned));
}

@override
String toString() {
    return 'ProxiesStyleProps(type: $type, sortType: $sortType, layout: $layout, iconStyle: $iconStyle, cardType: $cardType, followPanel: $followPanel, userOwned: $userOwned)';
}


}

/// @nodoc
abstract mixin class _$ProxiesStylePropsCopyWith<$Res> implements $ProxiesStylePropsCopyWith<$Res> {
  factory _$ProxiesStylePropsCopyWith(_ProxiesStyleProps value, $Res Function(_ProxiesStyleProps) _then) = __$ProxiesStylePropsCopyWithImpl;
@override @useResult
$Res call({
 ProxiesType type, ProxiesSortType sortType, ProxiesLayout layout, ProxiesIconStyle iconStyle, ProxyCardType cardType, bool followPanel, Set<ProxiesStyleField> userOwned
});




}
/// @nodoc
class __$ProxiesStylePropsCopyWithImpl<$Res>
    implements _$ProxiesStylePropsCopyWith<$Res> {
  __$ProxiesStylePropsCopyWithImpl(this._self, this._then);

  final _ProxiesStyleProps _self;
  final $Res Function(_ProxiesStyleProps) _then;

/// Create a copy of ProxiesStyleProps
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? sortType = null,Object? layout = null,Object? iconStyle = null,Object? cardType = null,Object? followPanel = null,Object? userOwned = null,}) {
  return _then(_ProxiesStyleProps(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ProxiesType,sortType: null == sortType ? _self.sortType : sortType // ignore: cast_nullable_to_non_nullable
as ProxiesSortType,layout: null == layout ? _self.layout : layout // ignore: cast_nullable_to_non_nullable
as ProxiesLayout,iconStyle: null == iconStyle ? _self.iconStyle : iconStyle // ignore: cast_nullable_to_non_nullable
as ProxiesIconStyle,cardType: null == cardType ? _self.cardType : cardType // ignore: cast_nullable_to_non_nullable
as ProxyCardType,followPanel: null == followPanel ? _self.followPanel : followPanel // ignore: cast_nullable_to_non_nullable
as bool,userOwned: null == userOwned ? _self._userOwned : userOwned // ignore: cast_nullable_to_non_nullable
as Set<ProxiesStyleField>,
  ));
}


}


/// @nodoc
mixin _$TextScale {

 bool get enable; double get scale;
/// Create a copy of TextScale
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TextScaleCopyWith<TextScale> get copyWith => _$TextScaleCopyWithImpl<TextScale>(this as TextScale, _$identity);

  /// Serializes this TextScale to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TextScale;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TextScale&&(identical(other.enable, _this.enable) || other.enable == _this.enable)&&(identical(other.scale, _this.scale) || other.scale == _this.scale));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TextScale;
  return Object.hash(runtimeType,_this.enable,_this.scale);
}

@override
String toString() {
  final _this = this as TextScale;
  return 'TextScale(enable: ${_this.enable}, scale: ${_this.scale})';
}


}

/// @nodoc
abstract mixin class $TextScaleCopyWith<$Res>  {
  factory $TextScaleCopyWith(TextScale value, $Res Function(TextScale) _then) = _$TextScaleCopyWithImpl;
@useResult
$Res call({
 bool enable, double scale
});




}
/// @nodoc
class _$TextScaleCopyWithImpl<$Res>
    implements $TextScaleCopyWith<$Res> {
  _$TextScaleCopyWithImpl(this._self, this._then);

  final TextScale _self;
  final $Res Function(TextScale) _then;

/// Create a copy of TextScale
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enable = null,Object? scale = null,}) {
  return _then(TextScale(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,scale: null == scale ? _self.scale : scale // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [TextScale].
extension TextScalePatterns on TextScale {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TextScale value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TextScale() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TextScale value)  $default,){
final _that = this;
switch (_that) {
case _TextScale():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TextScale value)?  $default,){
final _that = this;
switch (_that) {
case _TextScale() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enable,  double scale)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TextScale() when $default != null:
return $default(_that.enable,_that.scale);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enable,  double scale)  $default,) {final _that = this;
switch (_that) {
case _TextScale():
return $default(_that.enable,_that.scale);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enable,  double scale)?  $default,) {final _that = this;
switch (_that) {
case _TextScale() when $default != null:
return $default(_that.enable,_that.scale);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TextScale implements TextScale {
  const _TextScale({this.enable = false, this.scale = 1.0});
  factory _TextScale.fromJson(Map<String, dynamic> json) => _$TextScaleFromJson(json);

@override@JsonKey() final  bool enable;
@override@JsonKey() final  double scale;

/// Create a copy of TextScale
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TextScaleCopyWith<_TextScale> get copyWith => __$TextScaleCopyWithImpl<_TextScale>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TextScaleToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TextScale&&(identical(other.enable, enable) || other.enable == enable)&&(identical(other.scale, scale) || other.scale == scale));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,enable,scale);
}

@override
String toString() {
    return 'TextScale(enable: $enable, scale: $scale)';
}


}

/// @nodoc
abstract mixin class _$TextScaleCopyWith<$Res> implements $TextScaleCopyWith<$Res> {
  factory _$TextScaleCopyWith(_TextScale value, $Res Function(_TextScale) _then) = __$TextScaleCopyWithImpl;
@override @useResult
$Res call({
 bool enable, double scale
});




}
/// @nodoc
class __$TextScaleCopyWithImpl<$Res>
    implements _$TextScaleCopyWith<$Res> {
  __$TextScaleCopyWithImpl(this._self, this._then);

  final _TextScale _self;
  final $Res Function(_TextScale) _then;

/// Create a copy of TextScale
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enable = null,Object? scale = null,}) {
  return _then(_TextScale(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,scale: null == scale ? _self.scale : scale // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$ThemeProps {

 int? get primaryColor; List<int> get primaryColors; ThemeMode get themeMode; bool get scheduledTheme; String? get darkAt; String? get lightAt; DynamicSchemeVariant get schemeVariant; bool get pureBlack; bool get predictiveBack; double get contrastLevel; TextScale get textScale;@JsonKey(fromJson: WallpaperProps.safeFromJson) WallpaperProps get wallpaper;
/// Create a copy of ThemeProps
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ThemePropsCopyWith<ThemeProps> get copyWith => _$ThemePropsCopyWithImpl<ThemeProps>(this as ThemeProps, _$identity);

  /// Serializes this ThemeProps to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ThemeProps;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ThemeProps&&(identical(other.primaryColor, _this.primaryColor) || other.primaryColor == _this.primaryColor)&&const DeepCollectionEquality().equals(other.primaryColors, _this.primaryColors)&&(identical(other.themeMode, _this.themeMode) || other.themeMode == _this.themeMode)&&(identical(other.scheduledTheme, _this.scheduledTheme) || other.scheduledTheme == _this.scheduledTheme)&&(identical(other.darkAt, _this.darkAt) || other.darkAt == _this.darkAt)&&(identical(other.lightAt, _this.lightAt) || other.lightAt == _this.lightAt)&&(identical(other.schemeVariant, _this.schemeVariant) || other.schemeVariant == _this.schemeVariant)&&(identical(other.pureBlack, _this.pureBlack) || other.pureBlack == _this.pureBlack)&&(identical(other.predictiveBack, _this.predictiveBack) || other.predictiveBack == _this.predictiveBack)&&(identical(other.contrastLevel, _this.contrastLevel) || other.contrastLevel == _this.contrastLevel)&&(identical(other.textScale, _this.textScale) || other.textScale == _this.textScale)&&(identical(other.wallpaper, _this.wallpaper) || other.wallpaper == _this.wallpaper));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ThemeProps;
  return Object.hash(runtimeType,_this.primaryColor,const DeepCollectionEquality().hash(_this.primaryColors),_this.themeMode,_this.scheduledTheme,_this.darkAt,_this.lightAt,_this.schemeVariant,_this.pureBlack,_this.predictiveBack,_this.contrastLevel,_this.textScale,_this.wallpaper);
}

@override
String toString() {
  final _this = this as ThemeProps;
  return 'ThemeProps(primaryColor: ${_this.primaryColor}, primaryColors: ${_this.primaryColors}, themeMode: ${_this.themeMode}, scheduledTheme: ${_this.scheduledTheme}, darkAt: ${_this.darkAt}, lightAt: ${_this.lightAt}, schemeVariant: ${_this.schemeVariant}, pureBlack: ${_this.pureBlack}, predictiveBack: ${_this.predictiveBack}, contrastLevel: ${_this.contrastLevel}, textScale: ${_this.textScale}, wallpaper: ${_this.wallpaper})';
}


}

/// @nodoc
abstract mixin class $ThemePropsCopyWith<$Res>  {
  factory $ThemePropsCopyWith(ThemeProps value, $Res Function(ThemeProps) _then) = _$ThemePropsCopyWithImpl;
@useResult
$Res call({
 int? primaryColor, List<int> primaryColors, ThemeMode themeMode, bool scheduledTheme, String? darkAt, String? lightAt, DynamicSchemeVariant schemeVariant, bool pureBlack, bool predictiveBack, double contrastLevel, TextScale textScale,@JsonKey(fromJson: WallpaperProps.safeFromJson) WallpaperProps wallpaper
});


$TextScaleCopyWith<$Res> get textScale;$WallpaperPropsCopyWith<$Res> get wallpaper;

}
/// @nodoc
class _$ThemePropsCopyWithImpl<$Res>
    implements $ThemePropsCopyWith<$Res> {
  _$ThemePropsCopyWithImpl(this._self, this._then);

  final ThemeProps _self;
  final $Res Function(ThemeProps) _then;

/// Create a copy of ThemeProps
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? primaryColor = freezed,Object? primaryColors = null,Object? themeMode = null,Object? scheduledTheme = null,Object? darkAt = freezed,Object? lightAt = freezed,Object? schemeVariant = null,Object? pureBlack = null,Object? predictiveBack = null,Object? contrastLevel = null,Object? textScale = null,Object? wallpaper = null,}) {
  return _then(ThemeProps(
primaryColor: freezed == primaryColor ? _self.primaryColor : primaryColor // ignore: cast_nullable_to_non_nullable
as int?,primaryColors: null == primaryColors ? _self.primaryColors : primaryColors // ignore: cast_nullable_to_non_nullable
as List<int>,themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as ThemeMode,scheduledTheme: null == scheduledTheme ? _self.scheduledTheme : scheduledTheme // ignore: cast_nullable_to_non_nullable
as bool,darkAt: freezed == darkAt ? _self.darkAt : darkAt // ignore: cast_nullable_to_non_nullable
as String?,lightAt: freezed == lightAt ? _self.lightAt : lightAt // ignore: cast_nullable_to_non_nullable
as String?,schemeVariant: null == schemeVariant ? _self.schemeVariant : schemeVariant // ignore: cast_nullable_to_non_nullable
as DynamicSchemeVariant,pureBlack: null == pureBlack ? _self.pureBlack : pureBlack // ignore: cast_nullable_to_non_nullable
as bool,predictiveBack: null == predictiveBack ? _self.predictiveBack : predictiveBack // ignore: cast_nullable_to_non_nullable
as bool,contrastLevel: null == contrastLevel ? _self.contrastLevel : contrastLevel // ignore: cast_nullable_to_non_nullable
as double,textScale: null == textScale ? _self.textScale : textScale // ignore: cast_nullable_to_non_nullable
as TextScale,wallpaper: null == wallpaper ? _self.wallpaper : wallpaper // ignore: cast_nullable_to_non_nullable
as WallpaperProps,
  ));
}
/// Create a copy of ThemeProps
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TextScaleCopyWith<$Res> get textScale {
  
  return $TextScaleCopyWith<$Res>(_self.textScale, (value) {
    return _then(_self.copyWith(textScale: value));
  });
}/// Create a copy of ThemeProps
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WallpaperPropsCopyWith<$Res> get wallpaper {
  
  return $WallpaperPropsCopyWith<$Res>(_self.wallpaper, (value) {
    return _then(_self.copyWith(wallpaper: value));
  });
}
}


/// Adds pattern-matching-related methods to [ThemeProps].
extension ThemePropsPatterns on ThemeProps {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ThemeProps value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ThemeProps() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ThemeProps value)  $default,){
final _that = this;
switch (_that) {
case _ThemeProps():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ThemeProps value)?  $default,){
final _that = this;
switch (_that) {
case _ThemeProps() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? primaryColor,  List<int> primaryColors,  ThemeMode themeMode,  bool scheduledTheme,  String? darkAt,  String? lightAt,  DynamicSchemeVariant schemeVariant,  bool pureBlack,  bool predictiveBack,  double contrastLevel,  TextScale textScale, @JsonKey(fromJson: WallpaperProps.safeFromJson)  WallpaperProps wallpaper)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ThemeProps() when $default != null:
return $default(_that.primaryColor,_that.primaryColors,_that.themeMode,_that.scheduledTheme,_that.darkAt,_that.lightAt,_that.schemeVariant,_that.pureBlack,_that.predictiveBack,_that.contrastLevel,_that.textScale,_that.wallpaper);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? primaryColor,  List<int> primaryColors,  ThemeMode themeMode,  bool scheduledTheme,  String? darkAt,  String? lightAt,  DynamicSchemeVariant schemeVariant,  bool pureBlack,  bool predictiveBack,  double contrastLevel,  TextScale textScale, @JsonKey(fromJson: WallpaperProps.safeFromJson)  WallpaperProps wallpaper)  $default,) {final _that = this;
switch (_that) {
case _ThemeProps():
return $default(_that.primaryColor,_that.primaryColors,_that.themeMode,_that.scheduledTheme,_that.darkAt,_that.lightAt,_that.schemeVariant,_that.pureBlack,_that.predictiveBack,_that.contrastLevel,_that.textScale,_that.wallpaper);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? primaryColor,  List<int> primaryColors,  ThemeMode themeMode,  bool scheduledTheme,  String? darkAt,  String? lightAt,  DynamicSchemeVariant schemeVariant,  bool pureBlack,  bool predictiveBack,  double contrastLevel,  TextScale textScale, @JsonKey(fromJson: WallpaperProps.safeFromJson)  WallpaperProps wallpaper)?  $default,) {final _that = this;
switch (_that) {
case _ThemeProps() when $default != null:
return $default(_that.primaryColor,_that.primaryColors,_that.themeMode,_that.scheduledTheme,_that.darkAt,_that.lightAt,_that.schemeVariant,_that.pureBlack,_that.predictiveBack,_that.contrastLevel,_that.textScale,_that.wallpaper);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ThemeProps implements ThemeProps {
  const _ThemeProps({this.primaryColor,  List<int> primaryColors = defaultPrimaryColors, this.themeMode = ThemeMode.dark, this.scheduledTheme = false, this.darkAt, this.lightAt, this.schemeVariant = DynamicSchemeVariant.content, this.pureBlack = false, this.predictiveBack = true, this.contrastLevel = 0, this.textScale = const TextScale(), @JsonKey(fromJson: WallpaperProps.safeFromJson) this.wallpaper = const WallpaperProps()}): _primaryColors = primaryColors;
  factory _ThemeProps.fromJson(Map<String, dynamic> json) => _$ThemePropsFromJson(json);

@override final  int? primaryColor;
 final  List<int> _primaryColors;
@override@JsonKey() List<int> get primaryColors {
  if (_primaryColors is EqualUnmodifiableListView) return _primaryColors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_primaryColors);
}

@override@JsonKey() final  ThemeMode themeMode;
@override@JsonKey() final  bool scheduledTheme;
@override final  String? darkAt;
@override final  String? lightAt;
@override@JsonKey() final  DynamicSchemeVariant schemeVariant;
@override@JsonKey() final  bool pureBlack;
@override@JsonKey() final  bool predictiveBack;
@override@JsonKey() final  double contrastLevel;
@override@JsonKey() final  TextScale textScale;
@override@JsonKey(fromJson: WallpaperProps.safeFromJson) final  WallpaperProps wallpaper;

/// Create a copy of ThemeProps
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ThemePropsCopyWith<_ThemeProps> get copyWith => __$ThemePropsCopyWithImpl<_ThemeProps>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ThemePropsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ThemeProps&&(identical(other.primaryColor, primaryColor) || other.primaryColor == primaryColor)&&const DeepCollectionEquality().equals(other.primaryColors, _primaryColors)&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.scheduledTheme, scheduledTheme) || other.scheduledTheme == scheduledTheme)&&(identical(other.darkAt, darkAt) || other.darkAt == darkAt)&&(identical(other.lightAt, lightAt) || other.lightAt == lightAt)&&(identical(other.schemeVariant, schemeVariant) || other.schemeVariant == schemeVariant)&&(identical(other.pureBlack, pureBlack) || other.pureBlack == pureBlack)&&(identical(other.predictiveBack, predictiveBack) || other.predictiveBack == predictiveBack)&&(identical(other.contrastLevel, contrastLevel) || other.contrastLevel == contrastLevel)&&(identical(other.textScale, textScale) || other.textScale == textScale)&&(identical(other.wallpaper, wallpaper) || other.wallpaper == wallpaper));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,primaryColor,const DeepCollectionEquality().hash(_primaryColors),themeMode,scheduledTheme,darkAt,lightAt,schemeVariant,pureBlack,predictiveBack,contrastLevel,textScale,wallpaper);
}

@override
String toString() {
    return 'ThemeProps(primaryColor: $primaryColor, primaryColors: $primaryColors, themeMode: $themeMode, scheduledTheme: $scheduledTheme, darkAt: $darkAt, lightAt: $lightAt, schemeVariant: $schemeVariant, pureBlack: $pureBlack, predictiveBack: $predictiveBack, contrastLevel: $contrastLevel, textScale: $textScale, wallpaper: $wallpaper)';
}


}

/// @nodoc
abstract mixin class _$ThemePropsCopyWith<$Res> implements $ThemePropsCopyWith<$Res> {
  factory _$ThemePropsCopyWith(_ThemeProps value, $Res Function(_ThemeProps) _then) = __$ThemePropsCopyWithImpl;
@override @useResult
$Res call({
 int? primaryColor, List<int> primaryColors, ThemeMode themeMode, bool scheduledTheme, String? darkAt, String? lightAt, DynamicSchemeVariant schemeVariant, bool pureBlack, bool predictiveBack, double contrastLevel, TextScale textScale,@JsonKey(fromJson: WallpaperProps.safeFromJson) WallpaperProps wallpaper
});


@override $TextScaleCopyWith<$Res> get textScale;@override $WallpaperPropsCopyWith<$Res> get wallpaper;

}
/// @nodoc
class __$ThemePropsCopyWithImpl<$Res>
    implements _$ThemePropsCopyWith<$Res> {
  __$ThemePropsCopyWithImpl(this._self, this._then);

  final _ThemeProps _self;
  final $Res Function(_ThemeProps) _then;

/// Create a copy of ThemeProps
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? primaryColor = freezed,Object? primaryColors = null,Object? themeMode = null,Object? scheduledTheme = null,Object? darkAt = freezed,Object? lightAt = freezed,Object? schemeVariant = null,Object? pureBlack = null,Object? predictiveBack = null,Object? contrastLevel = null,Object? textScale = null,Object? wallpaper = null,}) {
  return _then(_ThemeProps(
primaryColor: freezed == primaryColor ? _self.primaryColor : primaryColor // ignore: cast_nullable_to_non_nullable
as int?,primaryColors: null == primaryColors ? _self._primaryColors : primaryColors // ignore: cast_nullable_to_non_nullable
as List<int>,themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as ThemeMode,scheduledTheme: null == scheduledTheme ? _self.scheduledTheme : scheduledTheme // ignore: cast_nullable_to_non_nullable
as bool,darkAt: freezed == darkAt ? _self.darkAt : darkAt // ignore: cast_nullable_to_non_nullable
as String?,lightAt: freezed == lightAt ? _self.lightAt : lightAt // ignore: cast_nullable_to_non_nullable
as String?,schemeVariant: null == schemeVariant ? _self.schemeVariant : schemeVariant // ignore: cast_nullable_to_non_nullable
as DynamicSchemeVariant,pureBlack: null == pureBlack ? _self.pureBlack : pureBlack // ignore: cast_nullable_to_non_nullable
as bool,predictiveBack: null == predictiveBack ? _self.predictiveBack : predictiveBack // ignore: cast_nullable_to_non_nullable
as bool,contrastLevel: null == contrastLevel ? _self.contrastLevel : contrastLevel // ignore: cast_nullable_to_non_nullable
as double,textScale: null == textScale ? _self.textScale : textScale // ignore: cast_nullable_to_non_nullable
as TextScale,wallpaper: null == wallpaper ? _self.wallpaper : wallpaper // ignore: cast_nullable_to_non_nullable
as WallpaperProps,
  ));
}

/// Create a copy of ThemeProps
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TextScaleCopyWith<$Res> get textScale {
  
  return $TextScaleCopyWith<$Res>(_self.textScale, (value) {
    return _then(_self.copyWith(textScale: value));
  });
}/// Create a copy of ThemeProps
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WallpaperPropsCopyWith<$Res> get wallpaper {
  
  return $WallpaperPropsCopyWith<$Res>(_self.wallpaper, (value) {
    return _then(_self.copyWith(wallpaper: value));
  });
}
}


/// @nodoc
mixin _$MilestoneProps {

 Set<String> get unlocked; Map<String, int> get revealedAt; List<String> get revealQueue; bool get findingsEnabled; bool get seasonalEnabled;
/// Create a copy of MilestoneProps
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MilestonePropsCopyWith<MilestoneProps> get copyWith => _$MilestonePropsCopyWithImpl<MilestoneProps>(this as MilestoneProps, _$identity);

  /// Serializes this MilestoneProps to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MilestoneProps;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MilestoneProps&&const DeepCollectionEquality().equals(other.unlocked, _this.unlocked)&&const DeepCollectionEquality().equals(other.revealedAt, _this.revealedAt)&&const DeepCollectionEquality().equals(other.revealQueue, _this.revealQueue)&&(identical(other.findingsEnabled, _this.findingsEnabled) || other.findingsEnabled == _this.findingsEnabled)&&(identical(other.seasonalEnabled, _this.seasonalEnabled) || other.seasonalEnabled == _this.seasonalEnabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MilestoneProps;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.unlocked),const DeepCollectionEquality().hash(_this.revealedAt),const DeepCollectionEquality().hash(_this.revealQueue),_this.findingsEnabled,_this.seasonalEnabled);
}

@override
String toString() {
  final _this = this as MilestoneProps;
  return 'MilestoneProps(unlocked: ${_this.unlocked}, revealedAt: ${_this.revealedAt}, revealQueue: ${_this.revealQueue}, findingsEnabled: ${_this.findingsEnabled}, seasonalEnabled: ${_this.seasonalEnabled})';
}


}

/// @nodoc
abstract mixin class $MilestonePropsCopyWith<$Res>  {
  factory $MilestonePropsCopyWith(MilestoneProps value, $Res Function(MilestoneProps) _then) = _$MilestonePropsCopyWithImpl;
@useResult
$Res call({
 Set<String> unlocked, Map<String, int> revealedAt, List<String> revealQueue, bool findingsEnabled, bool seasonalEnabled
});




}
/// @nodoc
class _$MilestonePropsCopyWithImpl<$Res>
    implements $MilestonePropsCopyWith<$Res> {
  _$MilestonePropsCopyWithImpl(this._self, this._then);

  final MilestoneProps _self;
  final $Res Function(MilestoneProps) _then;

/// Create a copy of MilestoneProps
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? unlocked = null,Object? revealedAt = null,Object? revealQueue = null,Object? findingsEnabled = null,Object? seasonalEnabled = null,}) {
  return _then(MilestoneProps(
unlocked: null == unlocked ? _self.unlocked : unlocked // ignore: cast_nullable_to_non_nullable
as Set<String>,revealedAt: null == revealedAt ? _self.revealedAt : revealedAt // ignore: cast_nullable_to_non_nullable
as Map<String, int>,revealQueue: null == revealQueue ? _self.revealQueue : revealQueue // ignore: cast_nullable_to_non_nullable
as List<String>,findingsEnabled: null == findingsEnabled ? _self.findingsEnabled : findingsEnabled // ignore: cast_nullable_to_non_nullable
as bool,seasonalEnabled: null == seasonalEnabled ? _self.seasonalEnabled : seasonalEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MilestoneProps].
extension MilestonePropsPatterns on MilestoneProps {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MilestoneProps value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MilestoneProps() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MilestoneProps value)  $default,){
final _that = this;
switch (_that) {
case _MilestoneProps():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MilestoneProps value)?  $default,){
final _that = this;
switch (_that) {
case _MilestoneProps() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Set<String> unlocked,  Map<String, int> revealedAt,  List<String> revealQueue,  bool findingsEnabled,  bool seasonalEnabled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MilestoneProps() when $default != null:
return $default(_that.unlocked,_that.revealedAt,_that.revealQueue,_that.findingsEnabled,_that.seasonalEnabled);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Set<String> unlocked,  Map<String, int> revealedAt,  List<String> revealQueue,  bool findingsEnabled,  bool seasonalEnabled)  $default,) {final _that = this;
switch (_that) {
case _MilestoneProps():
return $default(_that.unlocked,_that.revealedAt,_that.revealQueue,_that.findingsEnabled,_that.seasonalEnabled);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Set<String> unlocked,  Map<String, int> revealedAt,  List<String> revealQueue,  bool findingsEnabled,  bool seasonalEnabled)?  $default,) {final _that = this;
switch (_that) {
case _MilestoneProps() when $default != null:
return $default(_that.unlocked,_that.revealedAt,_that.revealQueue,_that.findingsEnabled,_that.seasonalEnabled);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MilestoneProps implements MilestoneProps {
  const _MilestoneProps({ Set<String> unlocked = const <String>{},  Map<String, int> revealedAt = const <String, int>{},  List<String> revealQueue = const <String>[], this.findingsEnabled = true, this.seasonalEnabled = true}): _unlocked = unlocked,_revealedAt = revealedAt,_revealQueue = revealQueue;
  factory _MilestoneProps.fromJson(Map<String, dynamic> json) => _$MilestonePropsFromJson(json);

 final  Set<String> _unlocked;
@override@JsonKey() Set<String> get unlocked {
  if (_unlocked is EqualUnmodifiableSetView) return _unlocked;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_unlocked);
}

 final  Map<String, int> _revealedAt;
@override@JsonKey() Map<String, int> get revealedAt {
  if (_revealedAt is EqualUnmodifiableMapView) return _revealedAt;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_revealedAt);
}

 final  List<String> _revealQueue;
@override@JsonKey() List<String> get revealQueue {
  if (_revealQueue is EqualUnmodifiableListView) return _revealQueue;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_revealQueue);
}

@override@JsonKey() final  bool findingsEnabled;
@override@JsonKey() final  bool seasonalEnabled;

/// Create a copy of MilestoneProps
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MilestonePropsCopyWith<_MilestoneProps> get copyWith => __$MilestonePropsCopyWithImpl<_MilestoneProps>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MilestonePropsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MilestoneProps&&const DeepCollectionEquality().equals(other.unlocked, _unlocked)&&const DeepCollectionEquality().equals(other.revealedAt, _revealedAt)&&const DeepCollectionEquality().equals(other.revealQueue, _revealQueue)&&(identical(other.findingsEnabled, findingsEnabled) || other.findingsEnabled == findingsEnabled)&&(identical(other.seasonalEnabled, seasonalEnabled) || other.seasonalEnabled == seasonalEnabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_unlocked),const DeepCollectionEquality().hash(_revealedAt),const DeepCollectionEquality().hash(_revealQueue),findingsEnabled,seasonalEnabled);
}

@override
String toString() {
    return 'MilestoneProps(unlocked: $unlocked, revealedAt: $revealedAt, revealQueue: $revealQueue, findingsEnabled: $findingsEnabled, seasonalEnabled: $seasonalEnabled)';
}


}

/// @nodoc
abstract mixin class _$MilestonePropsCopyWith<$Res> implements $MilestonePropsCopyWith<$Res> {
  factory _$MilestonePropsCopyWith(_MilestoneProps value, $Res Function(_MilestoneProps) _then) = __$MilestonePropsCopyWithImpl;
@override @useResult
$Res call({
 Set<String> unlocked, Map<String, int> revealedAt, List<String> revealQueue, bool findingsEnabled, bool seasonalEnabled
});




}
/// @nodoc
class __$MilestonePropsCopyWithImpl<$Res>
    implements _$MilestonePropsCopyWith<$Res> {
  __$MilestonePropsCopyWithImpl(this._self, this._then);

  final _MilestoneProps _self;
  final $Res Function(_MilestoneProps) _then;

/// Create a copy of MilestoneProps
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? unlocked = null,Object? revealedAt = null,Object? revealQueue = null,Object? findingsEnabled = null,Object? seasonalEnabled = null,}) {
  return _then(_MilestoneProps(
unlocked: null == unlocked ? _self._unlocked : unlocked // ignore: cast_nullable_to_non_nullable
as Set<String>,revealedAt: null == revealedAt ? _self._revealedAt : revealedAt // ignore: cast_nullable_to_non_nullable
as Map<String, int>,revealQueue: null == revealQueue ? _self._revealQueue : revealQueue // ignore: cast_nullable_to_non_nullable
as List<String>,findingsEnabled: null == findingsEnabled ? _self.findingsEnabled : findingsEnabled // ignore: cast_nullable_to_non_nullable
as bool,seasonalEnabled: null == seasonalEnabled ? _self.seasonalEnabled : seasonalEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$Config {

 int? get currentProfileId; bool get overrideDns;@JsonKey(fromJson: MilestoneProps.safeFromJson) MilestoneProps get milestoneProps; List<HotKeyAction> get hotKeyActions;@JsonKey(fromJson: AppSettingProps.safeFromJson) AppSettingProps get appSettingProps; DAVProps? get davProps; NetworkProps get networkProps; VpnProps get vpnProps; SmartRoutingProps get smartRoutingProps;@JsonKey(fromJson: DesyncProps.safeFromJson) DesyncProps get desyncProps;@JsonKey(fromJson: ThemeProps.safeFromJson) ThemeProps get themeProps; ProxiesStyleProps get proxiesStyleProps; WindowProps get windowProps; PatchClashConfig get patchClashConfig;
/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConfigCopyWith<Config> get copyWith => _$ConfigCopyWithImpl<Config>(this as Config, _$identity);

  /// Serializes this Config to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Config;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Config&&(identical(other.currentProfileId, _this.currentProfileId) || other.currentProfileId == _this.currentProfileId)&&(identical(other.overrideDns, _this.overrideDns) || other.overrideDns == _this.overrideDns)&&(identical(other.milestoneProps, _this.milestoneProps) || other.milestoneProps == _this.milestoneProps)&&const DeepCollectionEquality().equals(other.hotKeyActions, _this.hotKeyActions)&&(identical(other.appSettingProps, _this.appSettingProps) || other.appSettingProps == _this.appSettingProps)&&(identical(other.davProps, _this.davProps) || other.davProps == _this.davProps)&&(identical(other.networkProps, _this.networkProps) || other.networkProps == _this.networkProps)&&(identical(other.vpnProps, _this.vpnProps) || other.vpnProps == _this.vpnProps)&&(identical(other.smartRoutingProps, _this.smartRoutingProps) || other.smartRoutingProps == _this.smartRoutingProps)&&(identical(other.desyncProps, _this.desyncProps) || other.desyncProps == _this.desyncProps)&&(identical(other.themeProps, _this.themeProps) || other.themeProps == _this.themeProps)&&(identical(other.proxiesStyleProps, _this.proxiesStyleProps) || other.proxiesStyleProps == _this.proxiesStyleProps)&&(identical(other.windowProps, _this.windowProps) || other.windowProps == _this.windowProps)&&(identical(other.patchClashConfig, _this.patchClashConfig) || other.patchClashConfig == _this.patchClashConfig));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Config;
  return Object.hash(runtimeType,_this.currentProfileId,_this.overrideDns,_this.milestoneProps,const DeepCollectionEquality().hash(_this.hotKeyActions),_this.appSettingProps,_this.davProps,_this.networkProps,_this.vpnProps,_this.smartRoutingProps,_this.desyncProps,_this.themeProps,_this.proxiesStyleProps,_this.windowProps,_this.patchClashConfig);
}

@override
String toString() {
  final _this = this as Config;
  return 'Config(currentProfileId: ${_this.currentProfileId}, overrideDns: ${_this.overrideDns}, milestoneProps: ${_this.milestoneProps}, hotKeyActions: ${_this.hotKeyActions}, appSettingProps: ${_this.appSettingProps}, davProps: ${_this.davProps}, networkProps: ${_this.networkProps}, vpnProps: ${_this.vpnProps}, smartRoutingProps: ${_this.smartRoutingProps}, desyncProps: ${_this.desyncProps}, themeProps: ${_this.themeProps}, proxiesStyleProps: ${_this.proxiesStyleProps}, windowProps: ${_this.windowProps}, patchClashConfig: ${_this.patchClashConfig})';
}


}

/// @nodoc
abstract mixin class $ConfigCopyWith<$Res>  {
  factory $ConfigCopyWith(Config value, $Res Function(Config) _then) = _$ConfigCopyWithImpl;
@useResult
$Res call({
 int? currentProfileId, bool overrideDns,@JsonKey(fromJson: MilestoneProps.safeFromJson) MilestoneProps milestoneProps, List<HotKeyAction> hotKeyActions,@JsonKey(fromJson: AppSettingProps.safeFromJson) AppSettingProps appSettingProps, DAVProps? davProps, NetworkProps networkProps, VpnProps vpnProps, SmartRoutingProps smartRoutingProps,@JsonKey(fromJson: DesyncProps.safeFromJson) DesyncProps desyncProps,@JsonKey(fromJson: ThemeProps.safeFromJson) ThemeProps themeProps, ProxiesStyleProps proxiesStyleProps, WindowProps windowProps, PatchClashConfig patchClashConfig
});


$MilestonePropsCopyWith<$Res> get milestoneProps;$AppSettingPropsCopyWith<$Res> get appSettingProps;$DAVPropsCopyWith<$Res>? get davProps;$NetworkPropsCopyWith<$Res> get networkProps;$VpnPropsCopyWith<$Res> get vpnProps;$SmartRoutingPropsCopyWith<$Res> get smartRoutingProps;$DesyncPropsCopyWith<$Res> get desyncProps;$ThemePropsCopyWith<$Res> get themeProps;$ProxiesStylePropsCopyWith<$Res> get proxiesStyleProps;$WindowPropsCopyWith<$Res> get windowProps;$PatchClashConfigCopyWith<$Res> get patchClashConfig;

}
/// @nodoc
class _$ConfigCopyWithImpl<$Res>
    implements $ConfigCopyWith<$Res> {
  _$ConfigCopyWithImpl(this._self, this._then);

  final Config _self;
  final $Res Function(Config) _then;

/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentProfileId = freezed,Object? overrideDns = null,Object? milestoneProps = null,Object? hotKeyActions = null,Object? appSettingProps = null,Object? davProps = freezed,Object? networkProps = null,Object? vpnProps = null,Object? smartRoutingProps = null,Object? desyncProps = null,Object? themeProps = null,Object? proxiesStyleProps = null,Object? windowProps = null,Object? patchClashConfig = null,}) {
  return _then(Config(
currentProfileId: freezed == currentProfileId ? _self.currentProfileId : currentProfileId // ignore: cast_nullable_to_non_nullable
as int?,overrideDns: null == overrideDns ? _self.overrideDns : overrideDns // ignore: cast_nullable_to_non_nullable
as bool,milestoneProps: null == milestoneProps ? _self.milestoneProps : milestoneProps // ignore: cast_nullable_to_non_nullable
as MilestoneProps,hotKeyActions: null == hotKeyActions ? _self.hotKeyActions : hotKeyActions // ignore: cast_nullable_to_non_nullable
as List<HotKeyAction>,appSettingProps: null == appSettingProps ? _self.appSettingProps : appSettingProps // ignore: cast_nullable_to_non_nullable
as AppSettingProps,davProps: freezed == davProps ? _self.davProps : davProps // ignore: cast_nullable_to_non_nullable
as DAVProps?,networkProps: null == networkProps ? _self.networkProps : networkProps // ignore: cast_nullable_to_non_nullable
as NetworkProps,vpnProps: null == vpnProps ? _self.vpnProps : vpnProps // ignore: cast_nullable_to_non_nullable
as VpnProps,smartRoutingProps: null == smartRoutingProps ? _self.smartRoutingProps : smartRoutingProps // ignore: cast_nullable_to_non_nullable
as SmartRoutingProps,desyncProps: null == desyncProps ? _self.desyncProps : desyncProps // ignore: cast_nullable_to_non_nullable
as DesyncProps,themeProps: null == themeProps ? _self.themeProps : themeProps // ignore: cast_nullable_to_non_nullable
as ThemeProps,proxiesStyleProps: null == proxiesStyleProps ? _self.proxiesStyleProps : proxiesStyleProps // ignore: cast_nullable_to_non_nullable
as ProxiesStyleProps,windowProps: null == windowProps ? _self.windowProps : windowProps // ignore: cast_nullable_to_non_nullable
as WindowProps,patchClashConfig: null == patchClashConfig ? _self.patchClashConfig : patchClashConfig // ignore: cast_nullable_to_non_nullable
as PatchClashConfig,
  ));
}
/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MilestonePropsCopyWith<$Res> get milestoneProps {
  
  return $MilestonePropsCopyWith<$Res>(_self.milestoneProps, (value) {
    return _then(_self.copyWith(milestoneProps: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppSettingPropsCopyWith<$Res> get appSettingProps {
  
  return $AppSettingPropsCopyWith<$Res>(_self.appSettingProps, (value) {
    return _then(_self.copyWith(appSettingProps: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DAVPropsCopyWith<$Res>? get davProps {
    if (_self.davProps == null) {
    return null;
  }

  return $DAVPropsCopyWith<$Res>(_self.davProps!, (value) {
    return _then(_self.copyWith(davProps: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NetworkPropsCopyWith<$Res> get networkProps {
  
  return $NetworkPropsCopyWith<$Res>(_self.networkProps, (value) {
    return _then(_self.copyWith(networkProps: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VpnPropsCopyWith<$Res> get vpnProps {
  
  return $VpnPropsCopyWith<$Res>(_self.vpnProps, (value) {
    return _then(_self.copyWith(vpnProps: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SmartRoutingPropsCopyWith<$Res> get smartRoutingProps {
  
  return $SmartRoutingPropsCopyWith<$Res>(_self.smartRoutingProps, (value) {
    return _then(_self.copyWith(smartRoutingProps: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DesyncPropsCopyWith<$Res> get desyncProps {
  
  return $DesyncPropsCopyWith<$Res>(_self.desyncProps, (value) {
    return _then(_self.copyWith(desyncProps: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ThemePropsCopyWith<$Res> get themeProps {
  
  return $ThemePropsCopyWith<$Res>(_self.themeProps, (value) {
    return _then(_self.copyWith(themeProps: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProxiesStylePropsCopyWith<$Res> get proxiesStyleProps {
  
  return $ProxiesStylePropsCopyWith<$Res>(_self.proxiesStyleProps, (value) {
    return _then(_self.copyWith(proxiesStyleProps: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WindowPropsCopyWith<$Res> get windowProps {
  
  return $WindowPropsCopyWith<$Res>(_self.windowProps, (value) {
    return _then(_self.copyWith(windowProps: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PatchClashConfigCopyWith<$Res> get patchClashConfig {
  
  return $PatchClashConfigCopyWith<$Res>(_self.patchClashConfig, (value) {
    return _then(_self.copyWith(patchClashConfig: value));
  });
}
}


/// Adds pattern-matching-related methods to [Config].
extension ConfigPatterns on Config {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Config value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Config() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Config value)  $default,){
final _that = this;
switch (_that) {
case _Config():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Config value)?  $default,){
final _that = this;
switch (_that) {
case _Config() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? currentProfileId,  bool overrideDns, @JsonKey(fromJson: MilestoneProps.safeFromJson)  MilestoneProps milestoneProps,  List<HotKeyAction> hotKeyActions, @JsonKey(fromJson: AppSettingProps.safeFromJson)  AppSettingProps appSettingProps,  DAVProps? davProps,  NetworkProps networkProps,  VpnProps vpnProps,  SmartRoutingProps smartRoutingProps, @JsonKey(fromJson: DesyncProps.safeFromJson)  DesyncProps desyncProps, @JsonKey(fromJson: ThemeProps.safeFromJson)  ThemeProps themeProps,  ProxiesStyleProps proxiesStyleProps,  WindowProps windowProps,  PatchClashConfig patchClashConfig)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Config() when $default != null:
return $default(_that.currentProfileId,_that.overrideDns,_that.milestoneProps,_that.hotKeyActions,_that.appSettingProps,_that.davProps,_that.networkProps,_that.vpnProps,_that.smartRoutingProps,_that.desyncProps,_that.themeProps,_that.proxiesStyleProps,_that.windowProps,_that.patchClashConfig);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? currentProfileId,  bool overrideDns, @JsonKey(fromJson: MilestoneProps.safeFromJson)  MilestoneProps milestoneProps,  List<HotKeyAction> hotKeyActions, @JsonKey(fromJson: AppSettingProps.safeFromJson)  AppSettingProps appSettingProps,  DAVProps? davProps,  NetworkProps networkProps,  VpnProps vpnProps,  SmartRoutingProps smartRoutingProps, @JsonKey(fromJson: DesyncProps.safeFromJson)  DesyncProps desyncProps, @JsonKey(fromJson: ThemeProps.safeFromJson)  ThemeProps themeProps,  ProxiesStyleProps proxiesStyleProps,  WindowProps windowProps,  PatchClashConfig patchClashConfig)  $default,) {final _that = this;
switch (_that) {
case _Config():
return $default(_that.currentProfileId,_that.overrideDns,_that.milestoneProps,_that.hotKeyActions,_that.appSettingProps,_that.davProps,_that.networkProps,_that.vpnProps,_that.smartRoutingProps,_that.desyncProps,_that.themeProps,_that.proxiesStyleProps,_that.windowProps,_that.patchClashConfig);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? currentProfileId,  bool overrideDns, @JsonKey(fromJson: MilestoneProps.safeFromJson)  MilestoneProps milestoneProps,  List<HotKeyAction> hotKeyActions, @JsonKey(fromJson: AppSettingProps.safeFromJson)  AppSettingProps appSettingProps,  DAVProps? davProps,  NetworkProps networkProps,  VpnProps vpnProps,  SmartRoutingProps smartRoutingProps, @JsonKey(fromJson: DesyncProps.safeFromJson)  DesyncProps desyncProps, @JsonKey(fromJson: ThemeProps.safeFromJson)  ThemeProps themeProps,  ProxiesStyleProps proxiesStyleProps,  WindowProps windowProps,  PatchClashConfig patchClashConfig)?  $default,) {final _that = this;
switch (_that) {
case _Config() when $default != null:
return $default(_that.currentProfileId,_that.overrideDns,_that.milestoneProps,_that.hotKeyActions,_that.appSettingProps,_that.davProps,_that.networkProps,_that.vpnProps,_that.smartRoutingProps,_that.desyncProps,_that.themeProps,_that.proxiesStyleProps,_that.windowProps,_that.patchClashConfig);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Config implements Config {
  const _Config({this.currentProfileId, this.overrideDns = false, @JsonKey(fromJson: MilestoneProps.safeFromJson) this.milestoneProps = const MilestoneProps(),  List<HotKeyAction> hotKeyActions = const [], @JsonKey(fromJson: AppSettingProps.safeFromJson) this.appSettingProps = defaultAppSettingProps, this.davProps, this.networkProps = defaultNetworkProps, this.vpnProps = defaultVpnProps, this.smartRoutingProps = defaultSmartRoutingProps, @JsonKey(fromJson: DesyncProps.safeFromJson) this.desyncProps = defaultDesyncProps, @JsonKey(fromJson: ThemeProps.safeFromJson) required this.themeProps, this.proxiesStyleProps = defaultProxiesStyleProps, this.windowProps = defaultWindowProps, this.patchClashConfig = defaultClashConfig}): _hotKeyActions = hotKeyActions;
  factory _Config.fromJson(Map<String, dynamic> json) => _$ConfigFromJson(json);

@override final  int? currentProfileId;
@override@JsonKey() final  bool overrideDns;
@override@JsonKey(fromJson: MilestoneProps.safeFromJson) final  MilestoneProps milestoneProps;
 final  List<HotKeyAction> _hotKeyActions;
@override@JsonKey() List<HotKeyAction> get hotKeyActions {
  if (_hotKeyActions is EqualUnmodifiableListView) return _hotKeyActions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_hotKeyActions);
}

@override@JsonKey(fromJson: AppSettingProps.safeFromJson) final  AppSettingProps appSettingProps;
@override final  DAVProps? davProps;
@override@JsonKey() final  NetworkProps networkProps;
@override@JsonKey() final  VpnProps vpnProps;
@override@JsonKey() final  SmartRoutingProps smartRoutingProps;
@override@JsonKey(fromJson: DesyncProps.safeFromJson) final  DesyncProps desyncProps;
@override@JsonKey(fromJson: ThemeProps.safeFromJson) final  ThemeProps themeProps;
@override@JsonKey() final  ProxiesStyleProps proxiesStyleProps;
@override@JsonKey() final  WindowProps windowProps;
@override@JsonKey() final  PatchClashConfig patchClashConfig;

/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConfigCopyWith<_Config> get copyWith => __$ConfigCopyWithImpl<_Config>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConfigToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Config&&(identical(other.currentProfileId, currentProfileId) || other.currentProfileId == currentProfileId)&&(identical(other.overrideDns, overrideDns) || other.overrideDns == overrideDns)&&(identical(other.milestoneProps, milestoneProps) || other.milestoneProps == milestoneProps)&&const DeepCollectionEquality().equals(other.hotKeyActions, _hotKeyActions)&&(identical(other.appSettingProps, appSettingProps) || other.appSettingProps == appSettingProps)&&(identical(other.davProps, davProps) || other.davProps == davProps)&&(identical(other.networkProps, networkProps) || other.networkProps == networkProps)&&(identical(other.vpnProps, vpnProps) || other.vpnProps == vpnProps)&&(identical(other.smartRoutingProps, smartRoutingProps) || other.smartRoutingProps == smartRoutingProps)&&(identical(other.desyncProps, desyncProps) || other.desyncProps == desyncProps)&&(identical(other.themeProps, themeProps) || other.themeProps == themeProps)&&(identical(other.proxiesStyleProps, proxiesStyleProps) || other.proxiesStyleProps == proxiesStyleProps)&&(identical(other.windowProps, windowProps) || other.windowProps == windowProps)&&(identical(other.patchClashConfig, patchClashConfig) || other.patchClashConfig == patchClashConfig));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,currentProfileId,overrideDns,milestoneProps,const DeepCollectionEquality().hash(_hotKeyActions),appSettingProps,davProps,networkProps,vpnProps,smartRoutingProps,desyncProps,themeProps,proxiesStyleProps,windowProps,patchClashConfig);
}

@override
String toString() {
    return 'Config(currentProfileId: $currentProfileId, overrideDns: $overrideDns, milestoneProps: $milestoneProps, hotKeyActions: $hotKeyActions, appSettingProps: $appSettingProps, davProps: $davProps, networkProps: $networkProps, vpnProps: $vpnProps, smartRoutingProps: $smartRoutingProps, desyncProps: $desyncProps, themeProps: $themeProps, proxiesStyleProps: $proxiesStyleProps, windowProps: $windowProps, patchClashConfig: $patchClashConfig)';
}


}

/// @nodoc
abstract mixin class _$ConfigCopyWith<$Res> implements $ConfigCopyWith<$Res> {
  factory _$ConfigCopyWith(_Config value, $Res Function(_Config) _then) = __$ConfigCopyWithImpl;
@override @useResult
$Res call({
 int? currentProfileId, bool overrideDns,@JsonKey(fromJson: MilestoneProps.safeFromJson) MilestoneProps milestoneProps, List<HotKeyAction> hotKeyActions,@JsonKey(fromJson: AppSettingProps.safeFromJson) AppSettingProps appSettingProps, DAVProps? davProps, NetworkProps networkProps, VpnProps vpnProps, SmartRoutingProps smartRoutingProps,@JsonKey(fromJson: DesyncProps.safeFromJson) DesyncProps desyncProps,@JsonKey(fromJson: ThemeProps.safeFromJson) ThemeProps themeProps, ProxiesStyleProps proxiesStyleProps, WindowProps windowProps, PatchClashConfig patchClashConfig
});


@override $MilestonePropsCopyWith<$Res> get milestoneProps;@override $AppSettingPropsCopyWith<$Res> get appSettingProps;@override $DAVPropsCopyWith<$Res>? get davProps;@override $NetworkPropsCopyWith<$Res> get networkProps;@override $VpnPropsCopyWith<$Res> get vpnProps;@override $SmartRoutingPropsCopyWith<$Res> get smartRoutingProps;@override $DesyncPropsCopyWith<$Res> get desyncProps;@override $ThemePropsCopyWith<$Res> get themeProps;@override $ProxiesStylePropsCopyWith<$Res> get proxiesStyleProps;@override $WindowPropsCopyWith<$Res> get windowProps;@override $PatchClashConfigCopyWith<$Res> get patchClashConfig;

}
/// @nodoc
class __$ConfigCopyWithImpl<$Res>
    implements _$ConfigCopyWith<$Res> {
  __$ConfigCopyWithImpl(this._self, this._then);

  final _Config _self;
  final $Res Function(_Config) _then;

/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentProfileId = freezed,Object? overrideDns = null,Object? milestoneProps = null,Object? hotKeyActions = null,Object? appSettingProps = null,Object? davProps = freezed,Object? networkProps = null,Object? vpnProps = null,Object? smartRoutingProps = null,Object? desyncProps = null,Object? themeProps = null,Object? proxiesStyleProps = null,Object? windowProps = null,Object? patchClashConfig = null,}) {
  return _then(_Config(
currentProfileId: freezed == currentProfileId ? _self.currentProfileId : currentProfileId // ignore: cast_nullable_to_non_nullable
as int?,overrideDns: null == overrideDns ? _self.overrideDns : overrideDns // ignore: cast_nullable_to_non_nullable
as bool,milestoneProps: null == milestoneProps ? _self.milestoneProps : milestoneProps // ignore: cast_nullable_to_non_nullable
as MilestoneProps,hotKeyActions: null == hotKeyActions ? _self._hotKeyActions : hotKeyActions // ignore: cast_nullable_to_non_nullable
as List<HotKeyAction>,appSettingProps: null == appSettingProps ? _self.appSettingProps : appSettingProps // ignore: cast_nullable_to_non_nullable
as AppSettingProps,davProps: freezed == davProps ? _self.davProps : davProps // ignore: cast_nullable_to_non_nullable
as DAVProps?,networkProps: null == networkProps ? _self.networkProps : networkProps // ignore: cast_nullable_to_non_nullable
as NetworkProps,vpnProps: null == vpnProps ? _self.vpnProps : vpnProps // ignore: cast_nullable_to_non_nullable
as VpnProps,smartRoutingProps: null == smartRoutingProps ? _self.smartRoutingProps : smartRoutingProps // ignore: cast_nullable_to_non_nullable
as SmartRoutingProps,desyncProps: null == desyncProps ? _self.desyncProps : desyncProps // ignore: cast_nullable_to_non_nullable
as DesyncProps,themeProps: null == themeProps ? _self.themeProps : themeProps // ignore: cast_nullable_to_non_nullable
as ThemeProps,proxiesStyleProps: null == proxiesStyleProps ? _self.proxiesStyleProps : proxiesStyleProps // ignore: cast_nullable_to_non_nullable
as ProxiesStyleProps,windowProps: null == windowProps ? _self.windowProps : windowProps // ignore: cast_nullable_to_non_nullable
as WindowProps,patchClashConfig: null == patchClashConfig ? _self.patchClashConfig : patchClashConfig // ignore: cast_nullable_to_non_nullable
as PatchClashConfig,
  ));
}

/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MilestonePropsCopyWith<$Res> get milestoneProps {
  
  return $MilestonePropsCopyWith<$Res>(_self.milestoneProps, (value) {
    return _then(_self.copyWith(milestoneProps: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppSettingPropsCopyWith<$Res> get appSettingProps {
  
  return $AppSettingPropsCopyWith<$Res>(_self.appSettingProps, (value) {
    return _then(_self.copyWith(appSettingProps: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DAVPropsCopyWith<$Res>? get davProps {
    if (_self.davProps == null) {
    return null;
  }

  return $DAVPropsCopyWith<$Res>(_self.davProps!, (value) {
    return _then(_self.copyWith(davProps: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NetworkPropsCopyWith<$Res> get networkProps {
  
  return $NetworkPropsCopyWith<$Res>(_self.networkProps, (value) {
    return _then(_self.copyWith(networkProps: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VpnPropsCopyWith<$Res> get vpnProps {
  
  return $VpnPropsCopyWith<$Res>(_self.vpnProps, (value) {
    return _then(_self.copyWith(vpnProps: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SmartRoutingPropsCopyWith<$Res> get smartRoutingProps {
  
  return $SmartRoutingPropsCopyWith<$Res>(_self.smartRoutingProps, (value) {
    return _then(_self.copyWith(smartRoutingProps: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DesyncPropsCopyWith<$Res> get desyncProps {
  
  return $DesyncPropsCopyWith<$Res>(_self.desyncProps, (value) {
    return _then(_self.copyWith(desyncProps: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ThemePropsCopyWith<$Res> get themeProps {
  
  return $ThemePropsCopyWith<$Res>(_self.themeProps, (value) {
    return _then(_self.copyWith(themeProps: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProxiesStylePropsCopyWith<$Res> get proxiesStyleProps {
  
  return $ProxiesStylePropsCopyWith<$Res>(_self.proxiesStyleProps, (value) {
    return _then(_self.copyWith(proxiesStyleProps: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WindowPropsCopyWith<$Res> get windowProps {
  
  return $WindowPropsCopyWith<$Res>(_self.windowProps, (value) {
    return _then(_self.copyWith(windowProps: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PatchClashConfigCopyWith<$Res> get patchClashConfig {
  
  return $PatchClashConfigCopyWith<$Res>(_self.patchClashConfig, (value) {
    return _then(_self.copyWith(patchClashConfig: value));
  });
}
}

// dart format on
