// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../panel_meta.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PanelMeta {

 bool get hwidMaxDevicesReached; bool get hwidNotSupported; String? get announce; String? get supportUrl; int? get updateIntervalMinutes; String? get serviceName; String? get serviceLogo; String? get serverInfoGroup; String? get buyPlanUrl; String? get buyTrafficUrl; List<String>? get widgets; PanelWidgetsApplyMode get widgetsApplyMode; List<String>? get settings;
/// Create a copy of PanelMeta
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PanelMetaCopyWith<PanelMeta> get copyWith => _$PanelMetaCopyWithImpl<PanelMeta>(this as PanelMeta, _$identity);

  /// Serializes this PanelMeta to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PanelMeta;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PanelMeta&&(identical(other.hwidMaxDevicesReached, _this.hwidMaxDevicesReached) || other.hwidMaxDevicesReached == _this.hwidMaxDevicesReached)&&(identical(other.hwidNotSupported, _this.hwidNotSupported) || other.hwidNotSupported == _this.hwidNotSupported)&&(identical(other.announce, _this.announce) || other.announce == _this.announce)&&(identical(other.supportUrl, _this.supportUrl) || other.supportUrl == _this.supportUrl)&&(identical(other.updateIntervalMinutes, _this.updateIntervalMinutes) || other.updateIntervalMinutes == _this.updateIntervalMinutes)&&(identical(other.serviceName, _this.serviceName) || other.serviceName == _this.serviceName)&&(identical(other.serviceLogo, _this.serviceLogo) || other.serviceLogo == _this.serviceLogo)&&(identical(other.serverInfoGroup, _this.serverInfoGroup) || other.serverInfoGroup == _this.serverInfoGroup)&&(identical(other.buyPlanUrl, _this.buyPlanUrl) || other.buyPlanUrl == _this.buyPlanUrl)&&(identical(other.buyTrafficUrl, _this.buyTrafficUrl) || other.buyTrafficUrl == _this.buyTrafficUrl)&&const DeepCollectionEquality().equals(other.widgets, _this.widgets)&&(identical(other.widgetsApplyMode, _this.widgetsApplyMode) || other.widgetsApplyMode == _this.widgetsApplyMode)&&const DeepCollectionEquality().equals(other.settings, _this.settings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PanelMeta;
  return Object.hash(runtimeType,_this.hwidMaxDevicesReached,_this.hwidNotSupported,_this.announce,_this.supportUrl,_this.updateIntervalMinutes,_this.serviceName,_this.serviceLogo,_this.serverInfoGroup,_this.buyPlanUrl,_this.buyTrafficUrl,const DeepCollectionEquality().hash(_this.widgets),_this.widgetsApplyMode,const DeepCollectionEquality().hash(_this.settings));
}

@override
String toString() {
  final _this = this as PanelMeta;
  return 'PanelMeta(hwidMaxDevicesReached: ${_this.hwidMaxDevicesReached}, hwidNotSupported: ${_this.hwidNotSupported}, announce: ${_this.announce}, supportUrl: ${_this.supportUrl}, updateIntervalMinutes: ${_this.updateIntervalMinutes}, serviceName: ${_this.serviceName}, serviceLogo: ${_this.serviceLogo}, serverInfoGroup: ${_this.serverInfoGroup}, buyPlanUrl: ${_this.buyPlanUrl}, buyTrafficUrl: ${_this.buyTrafficUrl}, widgets: ${_this.widgets}, widgetsApplyMode: ${_this.widgetsApplyMode}, settings: ${_this.settings})';
}


}

/// @nodoc
abstract mixin class $PanelMetaCopyWith<$Res>  {
  factory $PanelMetaCopyWith(PanelMeta value, $Res Function(PanelMeta) _then) = _$PanelMetaCopyWithImpl;
@useResult
$Res call({
 bool hwidMaxDevicesReached, bool hwidNotSupported, String? announce, String? supportUrl, int? updateIntervalMinutes, String? serviceName, String? serviceLogo, String? serverInfoGroup, String? buyPlanUrl, String? buyTrafficUrl, List<String>? widgets, PanelWidgetsApplyMode widgetsApplyMode, List<String>? settings
});




}
/// @nodoc
class _$PanelMetaCopyWithImpl<$Res>
    implements $PanelMetaCopyWith<$Res> {
  _$PanelMetaCopyWithImpl(this._self, this._then);

  final PanelMeta _self;
  final $Res Function(PanelMeta) _then;

/// Create a copy of PanelMeta
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? hwidMaxDevicesReached = null,Object? hwidNotSupported = null,Object? announce = freezed,Object? supportUrl = freezed,Object? updateIntervalMinutes = freezed,Object? serviceName = freezed,Object? serviceLogo = freezed,Object? serverInfoGroup = freezed,Object? buyPlanUrl = freezed,Object? buyTrafficUrl = freezed,Object? widgets = freezed,Object? widgetsApplyMode = null,Object? settings = freezed,}) {
  return _then(PanelMeta(
hwidMaxDevicesReached: null == hwidMaxDevicesReached ? _self.hwidMaxDevicesReached : hwidMaxDevicesReached // ignore: cast_nullable_to_non_nullable
as bool,hwidNotSupported: null == hwidNotSupported ? _self.hwidNotSupported : hwidNotSupported // ignore: cast_nullable_to_non_nullable
as bool,announce: freezed == announce ? _self.announce : announce // ignore: cast_nullable_to_non_nullable
as String?,supportUrl: freezed == supportUrl ? _self.supportUrl : supportUrl // ignore: cast_nullable_to_non_nullable
as String?,updateIntervalMinutes: freezed == updateIntervalMinutes ? _self.updateIntervalMinutes : updateIntervalMinutes // ignore: cast_nullable_to_non_nullable
as int?,serviceName: freezed == serviceName ? _self.serviceName : serviceName // ignore: cast_nullable_to_non_nullable
as String?,serviceLogo: freezed == serviceLogo ? _self.serviceLogo : serviceLogo // ignore: cast_nullable_to_non_nullable
as String?,serverInfoGroup: freezed == serverInfoGroup ? _self.serverInfoGroup : serverInfoGroup // ignore: cast_nullable_to_non_nullable
as String?,buyPlanUrl: freezed == buyPlanUrl ? _self.buyPlanUrl : buyPlanUrl // ignore: cast_nullable_to_non_nullable
as String?,buyTrafficUrl: freezed == buyTrafficUrl ? _self.buyTrafficUrl : buyTrafficUrl // ignore: cast_nullable_to_non_nullable
as String?,widgets: freezed == widgets ? _self.widgets : widgets // ignore: cast_nullable_to_non_nullable
as List<String>?,widgetsApplyMode: null == widgetsApplyMode ? _self.widgetsApplyMode : widgetsApplyMode // ignore: cast_nullable_to_non_nullable
as PanelWidgetsApplyMode,settings: freezed == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [PanelMeta].
extension PanelMetaPatterns on PanelMeta {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PanelMeta value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PanelMeta() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PanelMeta value)  $default,){
final _that = this;
switch (_that) {
case _PanelMeta():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PanelMeta value)?  $default,){
final _that = this;
switch (_that) {
case _PanelMeta() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool hwidMaxDevicesReached,  bool hwidNotSupported,  String? announce,  String? supportUrl,  int? updateIntervalMinutes,  String? serviceName,  String? serviceLogo,  String? serverInfoGroup,  String? buyPlanUrl,  String? buyTrafficUrl,  List<String>? widgets,  PanelWidgetsApplyMode widgetsApplyMode,  List<String>? settings)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PanelMeta() when $default != null:
return $default(_that.hwidMaxDevicesReached,_that.hwidNotSupported,_that.announce,_that.supportUrl,_that.updateIntervalMinutes,_that.serviceName,_that.serviceLogo,_that.serverInfoGroup,_that.buyPlanUrl,_that.buyTrafficUrl,_that.widgets,_that.widgetsApplyMode,_that.settings);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool hwidMaxDevicesReached,  bool hwidNotSupported,  String? announce,  String? supportUrl,  int? updateIntervalMinutes,  String? serviceName,  String? serviceLogo,  String? serverInfoGroup,  String? buyPlanUrl,  String? buyTrafficUrl,  List<String>? widgets,  PanelWidgetsApplyMode widgetsApplyMode,  List<String>? settings)  $default,) {final _that = this;
switch (_that) {
case _PanelMeta():
return $default(_that.hwidMaxDevicesReached,_that.hwidNotSupported,_that.announce,_that.supportUrl,_that.updateIntervalMinutes,_that.serviceName,_that.serviceLogo,_that.serverInfoGroup,_that.buyPlanUrl,_that.buyTrafficUrl,_that.widgets,_that.widgetsApplyMode,_that.settings);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool hwidMaxDevicesReached,  bool hwidNotSupported,  String? announce,  String? supportUrl,  int? updateIntervalMinutes,  String? serviceName,  String? serviceLogo,  String? serverInfoGroup,  String? buyPlanUrl,  String? buyTrafficUrl,  List<String>? widgets,  PanelWidgetsApplyMode widgetsApplyMode,  List<String>? settings)?  $default,) {final _that = this;
switch (_that) {
case _PanelMeta() when $default != null:
return $default(_that.hwidMaxDevicesReached,_that.hwidNotSupported,_that.announce,_that.supportUrl,_that.updateIntervalMinutes,_that.serviceName,_that.serviceLogo,_that.serverInfoGroup,_that.buyPlanUrl,_that.buyTrafficUrl,_that.widgets,_that.widgetsApplyMode,_that.settings);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PanelMeta implements PanelMeta {
  const _PanelMeta({this.hwidMaxDevicesReached = false, this.hwidNotSupported = false, this.announce, this.supportUrl, this.updateIntervalMinutes, this.serviceName, this.serviceLogo, this.serverInfoGroup, this.buyPlanUrl, this.buyTrafficUrl,  List<String>? widgets, this.widgetsApplyMode = PanelWidgetsApplyMode.add,  List<String>? settings}): _widgets = widgets,_settings = settings;
  factory _PanelMeta.fromJson(Map<String, dynamic> json) => _$PanelMetaFromJson(json);

@override@JsonKey() final  bool hwidMaxDevicesReached;
@override@JsonKey() final  bool hwidNotSupported;
@override final  String? announce;
@override final  String? supportUrl;
@override final  int? updateIntervalMinutes;
@override final  String? serviceName;
@override final  String? serviceLogo;
@override final  String? serverInfoGroup;
@override final  String? buyPlanUrl;
@override final  String? buyTrafficUrl;
 final  List<String>? _widgets;
@override List<String>? get widgets {
  final value = _widgets;
  if (value == null) return null;
  if (_widgets is EqualUnmodifiableListView) return _widgets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey() final  PanelWidgetsApplyMode widgetsApplyMode;
 final  List<String>? _settings;
@override List<String>? get settings {
  final value = _settings;
  if (value == null) return null;
  if (_settings is EqualUnmodifiableListView) return _settings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of PanelMeta
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PanelMetaCopyWith<_PanelMeta> get copyWith => __$PanelMetaCopyWithImpl<_PanelMeta>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PanelMetaToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PanelMeta&&(identical(other.hwidMaxDevicesReached, hwidMaxDevicesReached) || other.hwidMaxDevicesReached == hwidMaxDevicesReached)&&(identical(other.hwidNotSupported, hwidNotSupported) || other.hwidNotSupported == hwidNotSupported)&&(identical(other.announce, announce) || other.announce == announce)&&(identical(other.supportUrl, supportUrl) || other.supportUrl == supportUrl)&&(identical(other.updateIntervalMinutes, updateIntervalMinutes) || other.updateIntervalMinutes == updateIntervalMinutes)&&(identical(other.serviceName, serviceName) || other.serviceName == serviceName)&&(identical(other.serviceLogo, serviceLogo) || other.serviceLogo == serviceLogo)&&(identical(other.serverInfoGroup, serverInfoGroup) || other.serverInfoGroup == serverInfoGroup)&&(identical(other.buyPlanUrl, buyPlanUrl) || other.buyPlanUrl == buyPlanUrl)&&(identical(other.buyTrafficUrl, buyTrafficUrl) || other.buyTrafficUrl == buyTrafficUrl)&&const DeepCollectionEquality().equals(other.widgets, _widgets)&&(identical(other.widgetsApplyMode, widgetsApplyMode) || other.widgetsApplyMode == widgetsApplyMode)&&const DeepCollectionEquality().equals(other.settings, _settings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,hwidMaxDevicesReached,hwidNotSupported,announce,supportUrl,updateIntervalMinutes,serviceName,serviceLogo,serverInfoGroup,buyPlanUrl,buyTrafficUrl,const DeepCollectionEquality().hash(_widgets),widgetsApplyMode,const DeepCollectionEquality().hash(_settings));
}

@override
String toString() {
    return 'PanelMeta(hwidMaxDevicesReached: $hwidMaxDevicesReached, hwidNotSupported: $hwidNotSupported, announce: $announce, supportUrl: $supportUrl, updateIntervalMinutes: $updateIntervalMinutes, serviceName: $serviceName, serviceLogo: $serviceLogo, serverInfoGroup: $serverInfoGroup, buyPlanUrl: $buyPlanUrl, buyTrafficUrl: $buyTrafficUrl, widgets: $widgets, widgetsApplyMode: $widgetsApplyMode, settings: $settings)';
}


}

/// @nodoc
abstract mixin class _$PanelMetaCopyWith<$Res> implements $PanelMetaCopyWith<$Res> {
  factory _$PanelMetaCopyWith(_PanelMeta value, $Res Function(_PanelMeta) _then) = __$PanelMetaCopyWithImpl;
@override @useResult
$Res call({
 bool hwidMaxDevicesReached, bool hwidNotSupported, String? announce, String? supportUrl, int? updateIntervalMinutes, String? serviceName, String? serviceLogo, String? serverInfoGroup, String? buyPlanUrl, String? buyTrafficUrl, List<String>? widgets, PanelWidgetsApplyMode widgetsApplyMode, List<String>? settings
});




}
/// @nodoc
class __$PanelMetaCopyWithImpl<$Res>
    implements _$PanelMetaCopyWith<$Res> {
  __$PanelMetaCopyWithImpl(this._self, this._then);

  final _PanelMeta _self;
  final $Res Function(_PanelMeta) _then;

/// Create a copy of PanelMeta
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? hwidMaxDevicesReached = null,Object? hwidNotSupported = null,Object? announce = freezed,Object? supportUrl = freezed,Object? updateIntervalMinutes = freezed,Object? serviceName = freezed,Object? serviceLogo = freezed,Object? serverInfoGroup = freezed,Object? buyPlanUrl = freezed,Object? buyTrafficUrl = freezed,Object? widgets = freezed,Object? widgetsApplyMode = null,Object? settings = freezed,}) {
  return _then(_PanelMeta(
hwidMaxDevicesReached: null == hwidMaxDevicesReached ? _self.hwidMaxDevicesReached : hwidMaxDevicesReached // ignore: cast_nullable_to_non_nullable
as bool,hwidNotSupported: null == hwidNotSupported ? _self.hwidNotSupported : hwidNotSupported // ignore: cast_nullable_to_non_nullable
as bool,announce: freezed == announce ? _self.announce : announce // ignore: cast_nullable_to_non_nullable
as String?,supportUrl: freezed == supportUrl ? _self.supportUrl : supportUrl // ignore: cast_nullable_to_non_nullable
as String?,updateIntervalMinutes: freezed == updateIntervalMinutes ? _self.updateIntervalMinutes : updateIntervalMinutes // ignore: cast_nullable_to_non_nullable
as int?,serviceName: freezed == serviceName ? _self.serviceName : serviceName // ignore: cast_nullable_to_non_nullable
as String?,serviceLogo: freezed == serviceLogo ? _self.serviceLogo : serviceLogo // ignore: cast_nullable_to_non_nullable
as String?,serverInfoGroup: freezed == serverInfoGroup ? _self.serverInfoGroup : serverInfoGroup // ignore: cast_nullable_to_non_nullable
as String?,buyPlanUrl: freezed == buyPlanUrl ? _self.buyPlanUrl : buyPlanUrl // ignore: cast_nullable_to_non_nullable
as String?,buyTrafficUrl: freezed == buyTrafficUrl ? _self.buyTrafficUrl : buyTrafficUrl // ignore: cast_nullable_to_non_nullable
as String?,widgets: freezed == widgets ? _self._widgets : widgets // ignore: cast_nullable_to_non_nullable
as List<String>?,widgetsApplyMode: null == widgetsApplyMode ? _self.widgetsApplyMode : widgetsApplyMode // ignore: cast_nullable_to_non_nullable
as PanelWidgetsApplyMode,settings: freezed == settings ? _self._settings : settings // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}

// dart format on
