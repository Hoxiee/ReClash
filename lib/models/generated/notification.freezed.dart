// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../notification.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotificationComponent {

 NotificationComponentType get type; bool get hideWhenIdle; String? get group;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationComponent&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.hideWhenIdle, _this.hideWhenIdle) || other.hideWhenIdle == _this.hideWhenIdle)&&(identical(other.group, _this.group) || other.group == _this.group));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as NotificationComponent;
  return Object.hash(runtimeType,_this.type,_this.hideWhenIdle,_this.group);
}

@override
String toString() {
  final _this = this as NotificationComponent;
  return 'NotificationComponent(type: ${_this.type}, hideWhenIdle: ${_this.hideWhenIdle}, group: ${_this.group})';
}


}

/// @nodoc
abstract mixin class $NotificationComponentCopyWith<$Res>  {
  factory $NotificationComponentCopyWith(NotificationComponent value, $Res Function(NotificationComponent) _then) = _$NotificationComponentCopyWithImpl;
@useResult
$Res call({
 NotificationComponentType type, bool hideWhenIdle, String? group
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
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? hideWhenIdle = null,Object? group = freezed,}) {
  return _then(NotificationComponent(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as NotificationComponentType,hideWhenIdle: null == hideWhenIdle ? _self.hideWhenIdle : hideWhenIdle // ignore: cast_nullable_to_non_nullable
as bool,group: freezed == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( NotificationComponentType type,  bool hideWhenIdle,  String? group)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationComponent() when $default != null:
return $default(_that.type,_that.hideWhenIdle,_that.group);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( NotificationComponentType type,  bool hideWhenIdle,  String? group)  $default,) {final _that = this;
switch (_that) {
case _NotificationComponent():
return $default(_that.type,_that.hideWhenIdle,_that.group);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( NotificationComponentType type,  bool hideWhenIdle,  String? group)?  $default,) {final _that = this;
switch (_that) {
case _NotificationComponent() when $default != null:
return $default(_that.type,_that.hideWhenIdle,_that.group);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationComponent implements NotificationComponent {
  const _NotificationComponent({required this.type, this.hideWhenIdle = true, this.group});
  factory _NotificationComponent.fromJson(Map<String, dynamic> json) => _$NotificationComponentFromJson(json);

@override final  NotificationComponentType type;
@override@JsonKey() final  bool hideWhenIdle;
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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationComponent&&(identical(other.type, type) || other.type == type)&&(identical(other.hideWhenIdle, hideWhenIdle) || other.hideWhenIdle == hideWhenIdle)&&(identical(other.group, group) || other.group == group));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,type,hideWhenIdle,group);
}

@override
String toString() {
    return 'NotificationComponent(type: $type, hideWhenIdle: $hideWhenIdle, group: $group)';
}


}

/// @nodoc
abstract mixin class _$NotificationComponentCopyWith<$Res> implements $NotificationComponentCopyWith<$Res> {
  factory _$NotificationComponentCopyWith(_NotificationComponent value, $Res Function(_NotificationComponent) _then) = __$NotificationComponentCopyWithImpl;
@override @useResult
$Res call({
 NotificationComponentType type, bool hideWhenIdle, String? group
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
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? hideWhenIdle = null,Object? group = freezed,}) {
  return _then(_NotificationComponent(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as NotificationComponentType,hideWhenIdle: null == hideWhenIdle ? _self.hideWhenIdle : hideWhenIdle // ignore: cast_nullable_to_non_nullable
as bool,group: freezed == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$NotificationSettings {

 NotificationVisibility get visibility; List<NotificationComponent> get components; bool get showStopAction; bool get hideSensitiveOnLockScreen; bool get subscriptionReminders;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationSettings&&(identical(other.visibility, _this.visibility) || other.visibility == _this.visibility)&&const DeepCollectionEquality().equals(other.components, _this.components)&&(identical(other.showStopAction, _this.showStopAction) || other.showStopAction == _this.showStopAction)&&(identical(other.hideSensitiveOnLockScreen, _this.hideSensitiveOnLockScreen) || other.hideSensitiveOnLockScreen == _this.hideSensitiveOnLockScreen)&&(identical(other.subscriptionReminders, _this.subscriptionReminders) || other.subscriptionReminders == _this.subscriptionReminders));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as NotificationSettings;
  return Object.hash(runtimeType,_this.visibility,const DeepCollectionEquality().hash(_this.components),_this.showStopAction,_this.hideSensitiveOnLockScreen,_this.subscriptionReminders);
}

@override
String toString() {
  final _this = this as NotificationSettings;
  return 'NotificationSettings(visibility: ${_this.visibility}, components: ${_this.components}, showStopAction: ${_this.showStopAction}, hideSensitiveOnLockScreen: ${_this.hideSensitiveOnLockScreen}, subscriptionReminders: ${_this.subscriptionReminders})';
}


}

/// @nodoc
abstract mixin class $NotificationSettingsCopyWith<$Res>  {
  factory $NotificationSettingsCopyWith(NotificationSettings value, $Res Function(NotificationSettings) _then) = _$NotificationSettingsCopyWithImpl;
@useResult
$Res call({
 NotificationVisibility visibility, List<NotificationComponent> components, bool showStopAction, bool hideSensitiveOnLockScreen, bool subscriptionReminders
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
@pragma('vm:prefer-inline') @override $Res call({Object? visibility = null,Object? components = null,Object? showStopAction = null,Object? hideSensitiveOnLockScreen = null,Object? subscriptionReminders = null,}) {
  return _then(NotificationSettings(
visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as NotificationVisibility,components: null == components ? _self.components : components // ignore: cast_nullable_to_non_nullable
as List<NotificationComponent>,showStopAction: null == showStopAction ? _self.showStopAction : showStopAction // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( NotificationVisibility visibility,  List<NotificationComponent> components,  bool showStopAction,  bool hideSensitiveOnLockScreen,  bool subscriptionReminders)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationSettings() when $default != null:
return $default(_that.visibility,_that.components,_that.showStopAction,_that.hideSensitiveOnLockScreen,_that.subscriptionReminders);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( NotificationVisibility visibility,  List<NotificationComponent> components,  bool showStopAction,  bool hideSensitiveOnLockScreen,  bool subscriptionReminders)  $default,) {final _that = this;
switch (_that) {
case _NotificationSettings():
return $default(_that.visibility,_that.components,_that.showStopAction,_that.hideSensitiveOnLockScreen,_that.subscriptionReminders);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( NotificationVisibility visibility,  List<NotificationComponent> components,  bool showStopAction,  bool hideSensitiveOnLockScreen,  bool subscriptionReminders)?  $default,) {final _that = this;
switch (_that) {
case _NotificationSettings() when $default != null:
return $default(_that.visibility,_that.components,_that.showStopAction,_that.hideSensitiveOnLockScreen,_that.subscriptionReminders);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationSettings implements NotificationSettings {
  const _NotificationSettings({this.visibility = NotificationVisibility.detailed,  List<NotificationComponent> components = defaultNotificationComponents, this.showStopAction = true, this.hideSensitiveOnLockScreen = true, this.subscriptionReminders = true}): _components = components;
  factory _NotificationSettings.fromJson(Map<String, dynamic> json) => _$NotificationSettingsFromJson(json);

@override@JsonKey() final  NotificationVisibility visibility;
 final  List<NotificationComponent> _components;
@override@JsonKey() List<NotificationComponent> get components {
  if (_components is EqualUnmodifiableListView) return _components;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_components);
}

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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationSettings&&(identical(other.visibility, visibility) || other.visibility == visibility)&&const DeepCollectionEquality().equals(other.components, _components)&&(identical(other.showStopAction, showStopAction) || other.showStopAction == showStopAction)&&(identical(other.hideSensitiveOnLockScreen, hideSensitiveOnLockScreen) || other.hideSensitiveOnLockScreen == hideSensitiveOnLockScreen)&&(identical(other.subscriptionReminders, subscriptionReminders) || other.subscriptionReminders == subscriptionReminders));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,visibility,const DeepCollectionEquality().hash(_components),showStopAction,hideSensitiveOnLockScreen,subscriptionReminders);
}

@override
String toString() {
    return 'NotificationSettings(visibility: $visibility, components: $components, showStopAction: $showStopAction, hideSensitiveOnLockScreen: $hideSensitiveOnLockScreen, subscriptionReminders: $subscriptionReminders)';
}


}

/// @nodoc
abstract mixin class _$NotificationSettingsCopyWith<$Res> implements $NotificationSettingsCopyWith<$Res> {
  factory _$NotificationSettingsCopyWith(_NotificationSettings value, $Res Function(_NotificationSettings) _then) = __$NotificationSettingsCopyWithImpl;
@override @useResult
$Res call({
 NotificationVisibility visibility, List<NotificationComponent> components, bool showStopAction, bool hideSensitiveOnLockScreen, bool subscriptionReminders
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
@override @pragma('vm:prefer-inline') $Res call({Object? visibility = null,Object? components = null,Object? showStopAction = null,Object? hideSensitiveOnLockScreen = null,Object? subscriptionReminders = null,}) {
  return _then(_NotificationSettings(
visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as NotificationVisibility,components: null == components ? _self._components : components // ignore: cast_nullable_to_non_nullable
as List<NotificationComponent>,showStopAction: null == showStopAction ? _self.showStopAction : showStopAction // ignore: cast_nullable_to_non_nullable
as bool,hideSensitiveOnLockScreen: null == hideSensitiveOnLockScreen ? _self.hideSensitiveOnLockScreen : hideSensitiveOnLockScreen // ignore: cast_nullable_to_non_nullable
as bool,subscriptionReminders: null == subscriptionReminders ? _self.subscriptionReminders : subscriptionReminders // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
