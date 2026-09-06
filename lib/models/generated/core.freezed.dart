// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../core.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SetupParams {

@JsonKey(name: 'selected-map') Map<String, String> get selectedMap;@JsonKey(name: 'test-url') String get testUrl;
/// Create a copy of SetupParams
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SetupParamsCopyWith<SetupParams> get copyWith => _$SetupParamsCopyWithImpl<SetupParams>(this as SetupParams, _$identity);

  /// Serializes this SetupParams to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SetupParams;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SetupParams&&const DeepCollectionEquality().equals(other.selectedMap, _this.selectedMap)&&(identical(other.testUrl, _this.testUrl) || other.testUrl == _this.testUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SetupParams;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.selectedMap),_this.testUrl);
}

@override
String toString() {
  final _this = this as SetupParams;
  return 'SetupParams(selectedMap: ${_this.selectedMap}, testUrl: ${_this.testUrl})';
}


}

/// @nodoc
abstract mixin class $SetupParamsCopyWith<$Res>  {
  factory $SetupParamsCopyWith(SetupParams value, $Res Function(SetupParams) _then) = _$SetupParamsCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'selected-map') Map<String, String> selectedMap,@JsonKey(name: 'test-url') String testUrl
});




}
/// @nodoc
class _$SetupParamsCopyWithImpl<$Res>
    implements $SetupParamsCopyWith<$Res> {
  _$SetupParamsCopyWithImpl(this._self, this._then);

  final SetupParams _self;
  final $Res Function(SetupParams) _then;

/// Create a copy of SetupParams
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? selectedMap = null,Object? testUrl = null,}) {
  return _then(SetupParams(
selectedMap: null == selectedMap ? _self.selectedMap : selectedMap // ignore: cast_nullable_to_non_nullable
as Map<String, String>,testUrl: null == testUrl ? _self.testUrl : testUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SetupParams].
extension SetupParamsPatterns on SetupParams {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SetupParams value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SetupParams() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SetupParams value)  $default,){
final _that = this;
switch (_that) {
case _SetupParams():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SetupParams value)?  $default,){
final _that = this;
switch (_that) {
case _SetupParams() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'selected-map')  Map<String, String> selectedMap, @JsonKey(name: 'test-url')  String testUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SetupParams() when $default != null:
return $default(_that.selectedMap,_that.testUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'selected-map')  Map<String, String> selectedMap, @JsonKey(name: 'test-url')  String testUrl)  $default,) {final _that = this;
switch (_that) {
case _SetupParams():
return $default(_that.selectedMap,_that.testUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'selected-map')  Map<String, String> selectedMap, @JsonKey(name: 'test-url')  String testUrl)?  $default,) {final _that = this;
switch (_that) {
case _SetupParams() when $default != null:
return $default(_that.selectedMap,_that.testUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SetupParams implements SetupParams {
  const _SetupParams({@JsonKey(name: 'selected-map') required  Map<String, String> selectedMap, @JsonKey(name: 'test-url') required this.testUrl}): _selectedMap = selectedMap;
  factory _SetupParams.fromJson(Map<String, dynamic> json) => _$SetupParamsFromJson(json);

 final  Map<String, String> _selectedMap;
@override@JsonKey(name: 'selected-map') Map<String, String> get selectedMap {
  if (_selectedMap is EqualUnmodifiableMapView) return _selectedMap;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_selectedMap);
}

@override@JsonKey(name: 'test-url') final  String testUrl;

/// Create a copy of SetupParams
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SetupParamsCopyWith<_SetupParams> get copyWith => __$SetupParamsCopyWithImpl<_SetupParams>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SetupParamsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SetupParams&&const DeepCollectionEquality().equals(other.selectedMap, _selectedMap)&&(identical(other.testUrl, testUrl) || other.testUrl == testUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_selectedMap),testUrl);
}

@override
String toString() {
    return 'SetupParams(selectedMap: $selectedMap, testUrl: $testUrl)';
}


}

/// @nodoc
abstract mixin class _$SetupParamsCopyWith<$Res> implements $SetupParamsCopyWith<$Res> {
  factory _$SetupParamsCopyWith(_SetupParams value, $Res Function(_SetupParams) _then) = __$SetupParamsCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'selected-map') Map<String, String> selectedMap,@JsonKey(name: 'test-url') String testUrl
});




}
/// @nodoc
class __$SetupParamsCopyWithImpl<$Res>
    implements _$SetupParamsCopyWith<$Res> {
  __$SetupParamsCopyWithImpl(this._self, this._then);

  final _SetupParams _self;
  final $Res Function(_SetupParams) _then;

/// Create a copy of SetupParams
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? selectedMap = null,Object? testUrl = null,}) {
  return _then(_SetupParams(
selectedMap: null == selectedMap ? _self._selectedMap : selectedMap // ignore: cast_nullable_to_non_nullable
as Map<String, String>,testUrl: null == testUrl ? _self.testUrl : testUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$UpdateParams {

 Tun get tun;@JsonKey(name: 'mixed-port') int get mixedPort;@JsonKey(name: 'allow-lan') bool get allowLan;@JsonKey(name: 'find-process-mode') FindProcessMode get findProcessMode; Mode get mode;@JsonKey(name: 'log-level') LogLevel get logLevel; bool get ipv6;@JsonKey(name: 'tcp-concurrent') bool get tcpConcurrent;@JsonKey(name: 'external-controller') ExternalControllerStatus get externalController;@JsonKey(name: 'unified-delay') bool get unifiedDelay; List<String> get authentication;@JsonKey(name: 'geo-auto-update') bool get geoAutoUpdate;@JsonKey(name: 'geo-update-interval') int get geoUpdateInterval;
/// Create a copy of UpdateParams
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateParamsCopyWith<UpdateParams> get copyWith => _$UpdateParamsCopyWithImpl<UpdateParams>(this as UpdateParams, _$identity);

  /// Serializes this UpdateParams to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UpdateParams;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateParams&&(identical(other.tun, _this.tun) || other.tun == _this.tun)&&(identical(other.mixedPort, _this.mixedPort) || other.mixedPort == _this.mixedPort)&&(identical(other.allowLan, _this.allowLan) || other.allowLan == _this.allowLan)&&(identical(other.findProcessMode, _this.findProcessMode) || other.findProcessMode == _this.findProcessMode)&&(identical(other.mode, _this.mode) || other.mode == _this.mode)&&(identical(other.logLevel, _this.logLevel) || other.logLevel == _this.logLevel)&&(identical(other.ipv6, _this.ipv6) || other.ipv6 == _this.ipv6)&&(identical(other.tcpConcurrent, _this.tcpConcurrent) || other.tcpConcurrent == _this.tcpConcurrent)&&(identical(other.externalController, _this.externalController) || other.externalController == _this.externalController)&&(identical(other.unifiedDelay, _this.unifiedDelay) || other.unifiedDelay == _this.unifiedDelay)&&const DeepCollectionEquality().equals(other.authentication, _this.authentication)&&(identical(other.geoAutoUpdate, _this.geoAutoUpdate) || other.geoAutoUpdate == _this.geoAutoUpdate)&&(identical(other.geoUpdateInterval, _this.geoUpdateInterval) || other.geoUpdateInterval == _this.geoUpdateInterval));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UpdateParams;
  return Object.hash(runtimeType,_this.tun,_this.mixedPort,_this.allowLan,_this.findProcessMode,_this.mode,_this.logLevel,_this.ipv6,_this.tcpConcurrent,_this.externalController,_this.unifiedDelay,const DeepCollectionEquality().hash(_this.authentication),_this.geoAutoUpdate,_this.geoUpdateInterval);
}

@override
String toString() {
  final _this = this as UpdateParams;
  return 'UpdateParams(tun: ${_this.tun}, mixedPort: ${_this.mixedPort}, allowLan: ${_this.allowLan}, findProcessMode: ${_this.findProcessMode}, mode: ${_this.mode}, logLevel: ${_this.logLevel}, ipv6: ${_this.ipv6}, tcpConcurrent: ${_this.tcpConcurrent}, externalController: ${_this.externalController}, unifiedDelay: ${_this.unifiedDelay}, authentication: ${_this.authentication}, geoAutoUpdate: ${_this.geoAutoUpdate}, geoUpdateInterval: ${_this.geoUpdateInterval})';
}


}

/// @nodoc
abstract mixin class $UpdateParamsCopyWith<$Res>  {
  factory $UpdateParamsCopyWith(UpdateParams value, $Res Function(UpdateParams) _then) = _$UpdateParamsCopyWithImpl;
@useResult
$Res call({
 Tun tun,@JsonKey(name: 'mixed-port') int mixedPort,@JsonKey(name: 'allow-lan') bool allowLan,@JsonKey(name: 'find-process-mode') FindProcessMode findProcessMode, Mode mode,@JsonKey(name: 'log-level') LogLevel logLevel, bool ipv6,@JsonKey(name: 'tcp-concurrent') bool tcpConcurrent,@JsonKey(name: 'external-controller') ExternalControllerStatus externalController,@JsonKey(name: 'unified-delay') bool unifiedDelay, List<String> authentication,@JsonKey(name: 'geo-auto-update') bool geoAutoUpdate,@JsonKey(name: 'geo-update-interval') int geoUpdateInterval
});


$TunCopyWith<$Res> get tun;

}
/// @nodoc
class _$UpdateParamsCopyWithImpl<$Res>
    implements $UpdateParamsCopyWith<$Res> {
  _$UpdateParamsCopyWithImpl(this._self, this._then);

  final UpdateParams _self;
  final $Res Function(UpdateParams) _then;

/// Create a copy of UpdateParams
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tun = null,Object? mixedPort = null,Object? allowLan = null,Object? findProcessMode = null,Object? mode = null,Object? logLevel = null,Object? ipv6 = null,Object? tcpConcurrent = null,Object? externalController = null,Object? unifiedDelay = null,Object? authentication = null,Object? geoAutoUpdate = null,Object? geoUpdateInterval = null,}) {
  return _then(UpdateParams(
tun: null == tun ? _self.tun : tun // ignore: cast_nullable_to_non_nullable
as Tun,mixedPort: null == mixedPort ? _self.mixedPort : mixedPort // ignore: cast_nullable_to_non_nullable
as int,allowLan: null == allowLan ? _self.allowLan : allowLan // ignore: cast_nullable_to_non_nullable
as bool,findProcessMode: null == findProcessMode ? _self.findProcessMode : findProcessMode // ignore: cast_nullable_to_non_nullable
as FindProcessMode,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as Mode,logLevel: null == logLevel ? _self.logLevel : logLevel // ignore: cast_nullable_to_non_nullable
as LogLevel,ipv6: null == ipv6 ? _self.ipv6 : ipv6 // ignore: cast_nullable_to_non_nullable
as bool,tcpConcurrent: null == tcpConcurrent ? _self.tcpConcurrent : tcpConcurrent // ignore: cast_nullable_to_non_nullable
as bool,externalController: null == externalController ? _self.externalController : externalController // ignore: cast_nullable_to_non_nullable
as ExternalControllerStatus,unifiedDelay: null == unifiedDelay ? _self.unifiedDelay : unifiedDelay // ignore: cast_nullable_to_non_nullable
as bool,authentication: null == authentication ? _self.authentication : authentication // ignore: cast_nullable_to_non_nullable
as List<String>,geoAutoUpdate: null == geoAutoUpdate ? _self.geoAutoUpdate : geoAutoUpdate // ignore: cast_nullable_to_non_nullable
as bool,geoUpdateInterval: null == geoUpdateInterval ? _self.geoUpdateInterval : geoUpdateInterval // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of UpdateParams
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TunCopyWith<$Res> get tun {
  
  return $TunCopyWith<$Res>(_self.tun, (value) {
    return _then(_self.copyWith(tun: value));
  });
}
}


/// Adds pattern-matching-related methods to [UpdateParams].
extension UpdateParamsPatterns on UpdateParams {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateParams value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateParams() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateParams value)  $default,){
final _that = this;
switch (_that) {
case _UpdateParams():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateParams value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateParams() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Tun tun, @JsonKey(name: 'mixed-port')  int mixedPort, @JsonKey(name: 'allow-lan')  bool allowLan, @JsonKey(name: 'find-process-mode')  FindProcessMode findProcessMode,  Mode mode, @JsonKey(name: 'log-level')  LogLevel logLevel,  bool ipv6, @JsonKey(name: 'tcp-concurrent')  bool tcpConcurrent, @JsonKey(name: 'external-controller')  ExternalControllerStatus externalController, @JsonKey(name: 'unified-delay')  bool unifiedDelay,  List<String> authentication, @JsonKey(name: 'geo-auto-update')  bool geoAutoUpdate, @JsonKey(name: 'geo-update-interval')  int geoUpdateInterval)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateParams() when $default != null:
return $default(_that.tun,_that.mixedPort,_that.allowLan,_that.findProcessMode,_that.mode,_that.logLevel,_that.ipv6,_that.tcpConcurrent,_that.externalController,_that.unifiedDelay,_that.authentication,_that.geoAutoUpdate,_that.geoUpdateInterval);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Tun tun, @JsonKey(name: 'mixed-port')  int mixedPort, @JsonKey(name: 'allow-lan')  bool allowLan, @JsonKey(name: 'find-process-mode')  FindProcessMode findProcessMode,  Mode mode, @JsonKey(name: 'log-level')  LogLevel logLevel,  bool ipv6, @JsonKey(name: 'tcp-concurrent')  bool tcpConcurrent, @JsonKey(name: 'external-controller')  ExternalControllerStatus externalController, @JsonKey(name: 'unified-delay')  bool unifiedDelay,  List<String> authentication, @JsonKey(name: 'geo-auto-update')  bool geoAutoUpdate, @JsonKey(name: 'geo-update-interval')  int geoUpdateInterval)  $default,) {final _that = this;
switch (_that) {
case _UpdateParams():
return $default(_that.tun,_that.mixedPort,_that.allowLan,_that.findProcessMode,_that.mode,_that.logLevel,_that.ipv6,_that.tcpConcurrent,_that.externalController,_that.unifiedDelay,_that.authentication,_that.geoAutoUpdate,_that.geoUpdateInterval);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Tun tun, @JsonKey(name: 'mixed-port')  int mixedPort, @JsonKey(name: 'allow-lan')  bool allowLan, @JsonKey(name: 'find-process-mode')  FindProcessMode findProcessMode,  Mode mode, @JsonKey(name: 'log-level')  LogLevel logLevel,  bool ipv6, @JsonKey(name: 'tcp-concurrent')  bool tcpConcurrent, @JsonKey(name: 'external-controller')  ExternalControllerStatus externalController, @JsonKey(name: 'unified-delay')  bool unifiedDelay,  List<String> authentication, @JsonKey(name: 'geo-auto-update')  bool geoAutoUpdate, @JsonKey(name: 'geo-update-interval')  int geoUpdateInterval)?  $default,) {final _that = this;
switch (_that) {
case _UpdateParams() when $default != null:
return $default(_that.tun,_that.mixedPort,_that.allowLan,_that.findProcessMode,_that.mode,_that.logLevel,_that.ipv6,_that.tcpConcurrent,_that.externalController,_that.unifiedDelay,_that.authentication,_that.geoAutoUpdate,_that.geoUpdateInterval);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateParams implements UpdateParams {
  const _UpdateParams({required this.tun, @JsonKey(name: 'mixed-port') required this.mixedPort, @JsonKey(name: 'allow-lan') required this.allowLan, @JsonKey(name: 'find-process-mode') required this.findProcessMode, required this.mode, @JsonKey(name: 'log-level') required this.logLevel, required this.ipv6, @JsonKey(name: 'tcp-concurrent') required this.tcpConcurrent, @JsonKey(name: 'external-controller') required this.externalController, @JsonKey(name: 'unified-delay') required this.unifiedDelay,  List<String> authentication = const [], @JsonKey(name: 'geo-auto-update') this.geoAutoUpdate = false, @JsonKey(name: 'geo-update-interval') this.geoUpdateInterval = 24}): _authentication = authentication;
  factory _UpdateParams.fromJson(Map<String, dynamic> json) => _$UpdateParamsFromJson(json);

@override final  Tun tun;
@override@JsonKey(name: 'mixed-port') final  int mixedPort;
@override@JsonKey(name: 'allow-lan') final  bool allowLan;
@override@JsonKey(name: 'find-process-mode') final  FindProcessMode findProcessMode;
@override final  Mode mode;
@override@JsonKey(name: 'log-level') final  LogLevel logLevel;
@override final  bool ipv6;
@override@JsonKey(name: 'tcp-concurrent') final  bool tcpConcurrent;
@override@JsonKey(name: 'external-controller') final  ExternalControllerStatus externalController;
@override@JsonKey(name: 'unified-delay') final  bool unifiedDelay;
 final  List<String> _authentication;
@override@JsonKey() List<String> get authentication {
  if (_authentication is EqualUnmodifiableListView) return _authentication;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_authentication);
}

@override@JsonKey(name: 'geo-auto-update') final  bool geoAutoUpdate;
@override@JsonKey(name: 'geo-update-interval') final  int geoUpdateInterval;

/// Create a copy of UpdateParams
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateParamsCopyWith<_UpdateParams> get copyWith => __$UpdateParamsCopyWithImpl<_UpdateParams>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateParamsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateParams&&(identical(other.tun, tun) || other.tun == tun)&&(identical(other.mixedPort, mixedPort) || other.mixedPort == mixedPort)&&(identical(other.allowLan, allowLan) || other.allowLan == allowLan)&&(identical(other.findProcessMode, findProcessMode) || other.findProcessMode == findProcessMode)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.logLevel, logLevel) || other.logLevel == logLevel)&&(identical(other.ipv6, ipv6) || other.ipv6 == ipv6)&&(identical(other.tcpConcurrent, tcpConcurrent) || other.tcpConcurrent == tcpConcurrent)&&(identical(other.externalController, externalController) || other.externalController == externalController)&&(identical(other.unifiedDelay, unifiedDelay) || other.unifiedDelay == unifiedDelay)&&const DeepCollectionEquality().equals(other.authentication, _authentication)&&(identical(other.geoAutoUpdate, geoAutoUpdate) || other.geoAutoUpdate == geoAutoUpdate)&&(identical(other.geoUpdateInterval, geoUpdateInterval) || other.geoUpdateInterval == geoUpdateInterval));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,tun,mixedPort,allowLan,findProcessMode,mode,logLevel,ipv6,tcpConcurrent,externalController,unifiedDelay,const DeepCollectionEquality().hash(_authentication),geoAutoUpdate,geoUpdateInterval);
}

@override
String toString() {
    return 'UpdateParams(tun: $tun, mixedPort: $mixedPort, allowLan: $allowLan, findProcessMode: $findProcessMode, mode: $mode, logLevel: $logLevel, ipv6: $ipv6, tcpConcurrent: $tcpConcurrent, externalController: $externalController, unifiedDelay: $unifiedDelay, authentication: $authentication, geoAutoUpdate: $geoAutoUpdate, geoUpdateInterval: $geoUpdateInterval)';
}


}

/// @nodoc
abstract mixin class _$UpdateParamsCopyWith<$Res> implements $UpdateParamsCopyWith<$Res> {
  factory _$UpdateParamsCopyWith(_UpdateParams value, $Res Function(_UpdateParams) _then) = __$UpdateParamsCopyWithImpl;
@override @useResult
$Res call({
 Tun tun,@JsonKey(name: 'mixed-port') int mixedPort,@JsonKey(name: 'allow-lan') bool allowLan,@JsonKey(name: 'find-process-mode') FindProcessMode findProcessMode, Mode mode,@JsonKey(name: 'log-level') LogLevel logLevel, bool ipv6,@JsonKey(name: 'tcp-concurrent') bool tcpConcurrent,@JsonKey(name: 'external-controller') ExternalControllerStatus externalController,@JsonKey(name: 'unified-delay') bool unifiedDelay, List<String> authentication,@JsonKey(name: 'geo-auto-update') bool geoAutoUpdate,@JsonKey(name: 'geo-update-interval') int geoUpdateInterval
});


@override $TunCopyWith<$Res> get tun;

}
/// @nodoc
class __$UpdateParamsCopyWithImpl<$Res>
    implements _$UpdateParamsCopyWith<$Res> {
  __$UpdateParamsCopyWithImpl(this._self, this._then);

  final _UpdateParams _self;
  final $Res Function(_UpdateParams) _then;

/// Create a copy of UpdateParams
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tun = null,Object? mixedPort = null,Object? allowLan = null,Object? findProcessMode = null,Object? mode = null,Object? logLevel = null,Object? ipv6 = null,Object? tcpConcurrent = null,Object? externalController = null,Object? unifiedDelay = null,Object? authentication = null,Object? geoAutoUpdate = null,Object? geoUpdateInterval = null,}) {
  return _then(_UpdateParams(
tun: null == tun ? _self.tun : tun // ignore: cast_nullable_to_non_nullable
as Tun,mixedPort: null == mixedPort ? _self.mixedPort : mixedPort // ignore: cast_nullable_to_non_nullable
as int,allowLan: null == allowLan ? _self.allowLan : allowLan // ignore: cast_nullable_to_non_nullable
as bool,findProcessMode: null == findProcessMode ? _self.findProcessMode : findProcessMode // ignore: cast_nullable_to_non_nullable
as FindProcessMode,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as Mode,logLevel: null == logLevel ? _self.logLevel : logLevel // ignore: cast_nullable_to_non_nullable
as LogLevel,ipv6: null == ipv6 ? _self.ipv6 : ipv6 // ignore: cast_nullable_to_non_nullable
as bool,tcpConcurrent: null == tcpConcurrent ? _self.tcpConcurrent : tcpConcurrent // ignore: cast_nullable_to_non_nullable
as bool,externalController: null == externalController ? _self.externalController : externalController // ignore: cast_nullable_to_non_nullable
as ExternalControllerStatus,unifiedDelay: null == unifiedDelay ? _self.unifiedDelay : unifiedDelay // ignore: cast_nullable_to_non_nullable
as bool,authentication: null == authentication ? _self._authentication : authentication // ignore: cast_nullable_to_non_nullable
as List<String>,geoAutoUpdate: null == geoAutoUpdate ? _self.geoAutoUpdate : geoAutoUpdate // ignore: cast_nullable_to_non_nullable
as bool,geoUpdateInterval: null == geoUpdateInterval ? _self.geoUpdateInterval : geoUpdateInterval // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of UpdateParams
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TunCopyWith<$Res> get tun {
  
  return $TunCopyWith<$Res>(_self.tun, (value) {
    return _then(_self.copyWith(tun: value));
  });
}
}


/// @nodoc
mixin _$VpnOptions {

 bool get enable; int get port; bool get ipv6; bool get dnsHijacking; AccessControlProps get accessControlProps; bool get allowBypass; bool get systemProxy; List<String> get bypassDomain; String get stack; List<String> get routeAddress; bool get smartPauseEnabled; List<String> get smartPauseNetworks; bool get smartPauseCloseConnections; bool get desyncEnabled; int get desyncPort; List<String> get desyncStrategy; int get desyncCacheTtl; bool get desyncCacheEnabled; bool get desyncTesting;
/// Create a copy of VpnOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VpnOptionsCopyWith<VpnOptions> get copyWith => _$VpnOptionsCopyWithImpl<VpnOptions>(this as VpnOptions, _$identity);

  /// Serializes this VpnOptions to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as VpnOptions;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VpnOptions&&(identical(other.enable, _this.enable) || other.enable == _this.enable)&&(identical(other.port, _this.port) || other.port == _this.port)&&(identical(other.ipv6, _this.ipv6) || other.ipv6 == _this.ipv6)&&(identical(other.dnsHijacking, _this.dnsHijacking) || other.dnsHijacking == _this.dnsHijacking)&&(identical(other.accessControlProps, _this.accessControlProps) || other.accessControlProps == _this.accessControlProps)&&(identical(other.allowBypass, _this.allowBypass) || other.allowBypass == _this.allowBypass)&&(identical(other.systemProxy, _this.systemProxy) || other.systemProxy == _this.systemProxy)&&const DeepCollectionEquality().equals(other.bypassDomain, _this.bypassDomain)&&(identical(other.stack, _this.stack) || other.stack == _this.stack)&&const DeepCollectionEquality().equals(other.routeAddress, _this.routeAddress)&&(identical(other.smartPauseEnabled, _this.smartPauseEnabled) || other.smartPauseEnabled == _this.smartPauseEnabled)&&const DeepCollectionEquality().equals(other.smartPauseNetworks, _this.smartPauseNetworks)&&(identical(other.smartPauseCloseConnections, _this.smartPauseCloseConnections) || other.smartPauseCloseConnections == _this.smartPauseCloseConnections)&&(identical(other.desyncEnabled, _this.desyncEnabled) || other.desyncEnabled == _this.desyncEnabled)&&(identical(other.desyncPort, _this.desyncPort) || other.desyncPort == _this.desyncPort)&&const DeepCollectionEquality().equals(other.desyncStrategy, _this.desyncStrategy)&&(identical(other.desyncCacheTtl, _this.desyncCacheTtl) || other.desyncCacheTtl == _this.desyncCacheTtl)&&(identical(other.desyncCacheEnabled, _this.desyncCacheEnabled) || other.desyncCacheEnabled == _this.desyncCacheEnabled)&&(identical(other.desyncTesting, _this.desyncTesting) || other.desyncTesting == _this.desyncTesting));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as VpnOptions;
  return Object.hashAll([runtimeType,_this.enable,_this.port,_this.ipv6,_this.dnsHijacking,_this.accessControlProps,_this.allowBypass,_this.systemProxy,const DeepCollectionEquality().hash(_this.bypassDomain),_this.stack,const DeepCollectionEquality().hash(_this.routeAddress),_this.smartPauseEnabled,const DeepCollectionEquality().hash(_this.smartPauseNetworks),_this.smartPauseCloseConnections,_this.desyncEnabled,_this.desyncPort,const DeepCollectionEquality().hash(_this.desyncStrategy),_this.desyncCacheTtl,_this.desyncCacheEnabled,_this.desyncTesting]);
}

@override
String toString() {
  final _this = this as VpnOptions;
  return 'VpnOptions(enable: ${_this.enable}, port: ${_this.port}, ipv6: ${_this.ipv6}, dnsHijacking: ${_this.dnsHijacking}, accessControlProps: ${_this.accessControlProps}, allowBypass: ${_this.allowBypass}, systemProxy: ${_this.systemProxy}, bypassDomain: ${_this.bypassDomain}, stack: ${_this.stack}, routeAddress: ${_this.routeAddress}, smartPauseEnabled: ${_this.smartPauseEnabled}, smartPauseNetworks: ${_this.smartPauseNetworks}, smartPauseCloseConnections: ${_this.smartPauseCloseConnections}, desyncEnabled: ${_this.desyncEnabled}, desyncPort: ${_this.desyncPort}, desyncStrategy: ${_this.desyncStrategy}, desyncCacheTtl: ${_this.desyncCacheTtl}, desyncCacheEnabled: ${_this.desyncCacheEnabled}, desyncTesting: ${_this.desyncTesting})';
}


}

/// @nodoc
abstract mixin class $VpnOptionsCopyWith<$Res>  {
  factory $VpnOptionsCopyWith(VpnOptions value, $Res Function(VpnOptions) _then) = _$VpnOptionsCopyWithImpl;
@useResult
$Res call({
 bool enable, int port, bool ipv6, bool dnsHijacking, AccessControlProps accessControlProps, bool allowBypass, bool systemProxy, List<String> bypassDomain, String stack, List<String> routeAddress, bool smartPauseEnabled, List<String> smartPauseNetworks, bool smartPauseCloseConnections, bool desyncEnabled, int desyncPort, List<String> desyncStrategy, int desyncCacheTtl, bool desyncCacheEnabled, bool desyncTesting
});


$AccessControlPropsCopyWith<$Res> get accessControlProps;

}
/// @nodoc
class _$VpnOptionsCopyWithImpl<$Res>
    implements $VpnOptionsCopyWith<$Res> {
  _$VpnOptionsCopyWithImpl(this._self, this._then);

  final VpnOptions _self;
  final $Res Function(VpnOptions) _then;

/// Create a copy of VpnOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enable = null,Object? port = null,Object? ipv6 = null,Object? dnsHijacking = null,Object? accessControlProps = null,Object? allowBypass = null,Object? systemProxy = null,Object? bypassDomain = null,Object? stack = null,Object? routeAddress = null,Object? smartPauseEnabled = null,Object? smartPauseNetworks = null,Object? smartPauseCloseConnections = null,Object? desyncEnabled = null,Object? desyncPort = null,Object? desyncStrategy = null,Object? desyncCacheTtl = null,Object? desyncCacheEnabled = null,Object? desyncTesting = null,}) {
  return _then(VpnOptions(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int,ipv6: null == ipv6 ? _self.ipv6 : ipv6 // ignore: cast_nullable_to_non_nullable
as bool,dnsHijacking: null == dnsHijacking ? _self.dnsHijacking : dnsHijacking // ignore: cast_nullable_to_non_nullable
as bool,accessControlProps: null == accessControlProps ? _self.accessControlProps : accessControlProps // ignore: cast_nullable_to_non_nullable
as AccessControlProps,allowBypass: null == allowBypass ? _self.allowBypass : allowBypass // ignore: cast_nullable_to_non_nullable
as bool,systemProxy: null == systemProxy ? _self.systemProxy : systemProxy // ignore: cast_nullable_to_non_nullable
as bool,bypassDomain: null == bypassDomain ? _self.bypassDomain : bypassDomain // ignore: cast_nullable_to_non_nullable
as List<String>,stack: null == stack ? _self.stack : stack // ignore: cast_nullable_to_non_nullable
as String,routeAddress: null == routeAddress ? _self.routeAddress : routeAddress // ignore: cast_nullable_to_non_nullable
as List<String>,smartPauseEnabled: null == smartPauseEnabled ? _self.smartPauseEnabled : smartPauseEnabled // ignore: cast_nullable_to_non_nullable
as bool,smartPauseNetworks: null == smartPauseNetworks ? _self.smartPauseNetworks : smartPauseNetworks // ignore: cast_nullable_to_non_nullable
as List<String>,smartPauseCloseConnections: null == smartPauseCloseConnections ? _self.smartPauseCloseConnections : smartPauseCloseConnections // ignore: cast_nullable_to_non_nullable
as bool,desyncEnabled: null == desyncEnabled ? _self.desyncEnabled : desyncEnabled // ignore: cast_nullable_to_non_nullable
as bool,desyncPort: null == desyncPort ? _self.desyncPort : desyncPort // ignore: cast_nullable_to_non_nullable
as int,desyncStrategy: null == desyncStrategy ? _self.desyncStrategy : desyncStrategy // ignore: cast_nullable_to_non_nullable
as List<String>,desyncCacheTtl: null == desyncCacheTtl ? _self.desyncCacheTtl : desyncCacheTtl // ignore: cast_nullable_to_non_nullable
as int,desyncCacheEnabled: null == desyncCacheEnabled ? _self.desyncCacheEnabled : desyncCacheEnabled // ignore: cast_nullable_to_non_nullable
as bool,desyncTesting: null == desyncTesting ? _self.desyncTesting : desyncTesting // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of VpnOptions
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AccessControlPropsCopyWith<$Res> get accessControlProps {
  
  return $AccessControlPropsCopyWith<$Res>(_self.accessControlProps, (value) {
    return _then(_self.copyWith(accessControlProps: value));
  });
}
}


/// Adds pattern-matching-related methods to [VpnOptions].
extension VpnOptionsPatterns on VpnOptions {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VpnOptions value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VpnOptions() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VpnOptions value)  $default,){
final _that = this;
switch (_that) {
case _VpnOptions():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VpnOptions value)?  $default,){
final _that = this;
switch (_that) {
case _VpnOptions() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enable,  int port,  bool ipv6,  bool dnsHijacking,  AccessControlProps accessControlProps,  bool allowBypass,  bool systemProxy,  List<String> bypassDomain,  String stack,  List<String> routeAddress,  bool smartPauseEnabled,  List<String> smartPauseNetworks,  bool smartPauseCloseConnections,  bool desyncEnabled,  int desyncPort,  List<String> desyncStrategy,  int desyncCacheTtl,  bool desyncCacheEnabled,  bool desyncTesting)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VpnOptions() when $default != null:
return $default(_that.enable,_that.port,_that.ipv6,_that.dnsHijacking,_that.accessControlProps,_that.allowBypass,_that.systemProxy,_that.bypassDomain,_that.stack,_that.routeAddress,_that.smartPauseEnabled,_that.smartPauseNetworks,_that.smartPauseCloseConnections,_that.desyncEnabled,_that.desyncPort,_that.desyncStrategy,_that.desyncCacheTtl,_that.desyncCacheEnabled,_that.desyncTesting);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enable,  int port,  bool ipv6,  bool dnsHijacking,  AccessControlProps accessControlProps,  bool allowBypass,  bool systemProxy,  List<String> bypassDomain,  String stack,  List<String> routeAddress,  bool smartPauseEnabled,  List<String> smartPauseNetworks,  bool smartPauseCloseConnections,  bool desyncEnabled,  int desyncPort,  List<String> desyncStrategy,  int desyncCacheTtl,  bool desyncCacheEnabled,  bool desyncTesting)  $default,) {final _that = this;
switch (_that) {
case _VpnOptions():
return $default(_that.enable,_that.port,_that.ipv6,_that.dnsHijacking,_that.accessControlProps,_that.allowBypass,_that.systemProxy,_that.bypassDomain,_that.stack,_that.routeAddress,_that.smartPauseEnabled,_that.smartPauseNetworks,_that.smartPauseCloseConnections,_that.desyncEnabled,_that.desyncPort,_that.desyncStrategy,_that.desyncCacheTtl,_that.desyncCacheEnabled,_that.desyncTesting);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enable,  int port,  bool ipv6,  bool dnsHijacking,  AccessControlProps accessControlProps,  bool allowBypass,  bool systemProxy,  List<String> bypassDomain,  String stack,  List<String> routeAddress,  bool smartPauseEnabled,  List<String> smartPauseNetworks,  bool smartPauseCloseConnections,  bool desyncEnabled,  int desyncPort,  List<String> desyncStrategy,  int desyncCacheTtl,  bool desyncCacheEnabled,  bool desyncTesting)?  $default,) {final _that = this;
switch (_that) {
case _VpnOptions() when $default != null:
return $default(_that.enable,_that.port,_that.ipv6,_that.dnsHijacking,_that.accessControlProps,_that.allowBypass,_that.systemProxy,_that.bypassDomain,_that.stack,_that.routeAddress,_that.smartPauseEnabled,_that.smartPauseNetworks,_that.smartPauseCloseConnections,_that.desyncEnabled,_that.desyncPort,_that.desyncStrategy,_that.desyncCacheTtl,_that.desyncCacheEnabled,_that.desyncTesting);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VpnOptions implements VpnOptions {
  const _VpnOptions({required this.enable, required this.port, required this.ipv6, required this.dnsHijacking, required this.accessControlProps, required this.allowBypass, required this.systemProxy, required  List<String> bypassDomain, required this.stack,  List<String> routeAddress = const [], this.smartPauseEnabled = false,  List<String> smartPauseNetworks = const [], this.smartPauseCloseConnections = false, this.desyncEnabled = false, this.desyncPort = defaultDesyncPort,  List<String> desyncStrategy = const [], this.desyncCacheTtl = defaultDesyncCacheTtl, this.desyncCacheEnabled = true, this.desyncTesting = false}): _bypassDomain = bypassDomain,_routeAddress = routeAddress,_smartPauseNetworks = smartPauseNetworks,_desyncStrategy = desyncStrategy;
  factory _VpnOptions.fromJson(Map<String, dynamic> json) => _$VpnOptionsFromJson(json);

@override final  bool enable;
@override final  int port;
@override final  bool ipv6;
@override final  bool dnsHijacking;
@override final  AccessControlProps accessControlProps;
@override final  bool allowBypass;
@override final  bool systemProxy;
 final  List<String> _bypassDomain;
@override List<String> get bypassDomain {
  if (_bypassDomain is EqualUnmodifiableListView) return _bypassDomain;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bypassDomain);
}

@override final  String stack;
 final  List<String> _routeAddress;
@override@JsonKey() List<String> get routeAddress {
  if (_routeAddress is EqualUnmodifiableListView) return _routeAddress;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_routeAddress);
}

@override@JsonKey() final  bool smartPauseEnabled;
 final  List<String> _smartPauseNetworks;
@override@JsonKey() List<String> get smartPauseNetworks {
  if (_smartPauseNetworks is EqualUnmodifiableListView) return _smartPauseNetworks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_smartPauseNetworks);
}

@override@JsonKey() final  bool smartPauseCloseConnections;
@override@JsonKey() final  bool desyncEnabled;
@override@JsonKey() final  int desyncPort;
 final  List<String> _desyncStrategy;
@override@JsonKey() List<String> get desyncStrategy {
  if (_desyncStrategy is EqualUnmodifiableListView) return _desyncStrategy;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_desyncStrategy);
}

@override@JsonKey() final  int desyncCacheTtl;
@override@JsonKey() final  bool desyncCacheEnabled;
@override@JsonKey() final  bool desyncTesting;

/// Create a copy of VpnOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VpnOptionsCopyWith<_VpnOptions> get copyWith => __$VpnOptionsCopyWithImpl<_VpnOptions>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VpnOptionsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VpnOptions&&(identical(other.enable, enable) || other.enable == enable)&&(identical(other.port, port) || other.port == port)&&(identical(other.ipv6, ipv6) || other.ipv6 == ipv6)&&(identical(other.dnsHijacking, dnsHijacking) || other.dnsHijacking == dnsHijacking)&&(identical(other.accessControlProps, accessControlProps) || other.accessControlProps == accessControlProps)&&(identical(other.allowBypass, allowBypass) || other.allowBypass == allowBypass)&&(identical(other.systemProxy, systemProxy) || other.systemProxy == systemProxy)&&const DeepCollectionEquality().equals(other.bypassDomain, _bypassDomain)&&(identical(other.stack, stack) || other.stack == stack)&&const DeepCollectionEquality().equals(other.routeAddress, _routeAddress)&&(identical(other.smartPauseEnabled, smartPauseEnabled) || other.smartPauseEnabled == smartPauseEnabled)&&const DeepCollectionEquality().equals(other.smartPauseNetworks, _smartPauseNetworks)&&(identical(other.smartPauseCloseConnections, smartPauseCloseConnections) || other.smartPauseCloseConnections == smartPauseCloseConnections)&&(identical(other.desyncEnabled, desyncEnabled) || other.desyncEnabled == desyncEnabled)&&(identical(other.desyncPort, desyncPort) || other.desyncPort == desyncPort)&&const DeepCollectionEquality().equals(other.desyncStrategy, _desyncStrategy)&&(identical(other.desyncCacheTtl, desyncCacheTtl) || other.desyncCacheTtl == desyncCacheTtl)&&(identical(other.desyncCacheEnabled, desyncCacheEnabled) || other.desyncCacheEnabled == desyncCacheEnabled)&&(identical(other.desyncTesting, desyncTesting) || other.desyncTesting == desyncTesting));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,enable,port,ipv6,dnsHijacking,accessControlProps,allowBypass,systemProxy,const DeepCollectionEquality().hash(_bypassDomain),stack,const DeepCollectionEquality().hash(_routeAddress),smartPauseEnabled,const DeepCollectionEquality().hash(_smartPauseNetworks),smartPauseCloseConnections,desyncEnabled,desyncPort,const DeepCollectionEquality().hash(_desyncStrategy),desyncCacheTtl,desyncCacheEnabled,desyncTesting]);
}

@override
String toString() {
    return 'VpnOptions(enable: $enable, port: $port, ipv6: $ipv6, dnsHijacking: $dnsHijacking, accessControlProps: $accessControlProps, allowBypass: $allowBypass, systemProxy: $systemProxy, bypassDomain: $bypassDomain, stack: $stack, routeAddress: $routeAddress, smartPauseEnabled: $smartPauseEnabled, smartPauseNetworks: $smartPauseNetworks, smartPauseCloseConnections: $smartPauseCloseConnections, desyncEnabled: $desyncEnabled, desyncPort: $desyncPort, desyncStrategy: $desyncStrategy, desyncCacheTtl: $desyncCacheTtl, desyncCacheEnabled: $desyncCacheEnabled, desyncTesting: $desyncTesting)';
}


}

/// @nodoc
abstract mixin class _$VpnOptionsCopyWith<$Res> implements $VpnOptionsCopyWith<$Res> {
  factory _$VpnOptionsCopyWith(_VpnOptions value, $Res Function(_VpnOptions) _then) = __$VpnOptionsCopyWithImpl;
@override @useResult
$Res call({
 bool enable, int port, bool ipv6, bool dnsHijacking, AccessControlProps accessControlProps, bool allowBypass, bool systemProxy, List<String> bypassDomain, String stack, List<String> routeAddress, bool smartPauseEnabled, List<String> smartPauseNetworks, bool smartPauseCloseConnections, bool desyncEnabled, int desyncPort, List<String> desyncStrategy, int desyncCacheTtl, bool desyncCacheEnabled, bool desyncTesting
});


@override $AccessControlPropsCopyWith<$Res> get accessControlProps;

}
/// @nodoc
class __$VpnOptionsCopyWithImpl<$Res>
    implements _$VpnOptionsCopyWith<$Res> {
  __$VpnOptionsCopyWithImpl(this._self, this._then);

  final _VpnOptions _self;
  final $Res Function(_VpnOptions) _then;

/// Create a copy of VpnOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enable = null,Object? port = null,Object? ipv6 = null,Object? dnsHijacking = null,Object? accessControlProps = null,Object? allowBypass = null,Object? systemProxy = null,Object? bypassDomain = null,Object? stack = null,Object? routeAddress = null,Object? smartPauseEnabled = null,Object? smartPauseNetworks = null,Object? smartPauseCloseConnections = null,Object? desyncEnabled = null,Object? desyncPort = null,Object? desyncStrategy = null,Object? desyncCacheTtl = null,Object? desyncCacheEnabled = null,Object? desyncTesting = null,}) {
  return _then(_VpnOptions(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int,ipv6: null == ipv6 ? _self.ipv6 : ipv6 // ignore: cast_nullable_to_non_nullable
as bool,dnsHijacking: null == dnsHijacking ? _self.dnsHijacking : dnsHijacking // ignore: cast_nullable_to_non_nullable
as bool,accessControlProps: null == accessControlProps ? _self.accessControlProps : accessControlProps // ignore: cast_nullable_to_non_nullable
as AccessControlProps,allowBypass: null == allowBypass ? _self.allowBypass : allowBypass // ignore: cast_nullable_to_non_nullable
as bool,systemProxy: null == systemProxy ? _self.systemProxy : systemProxy // ignore: cast_nullable_to_non_nullable
as bool,bypassDomain: null == bypassDomain ? _self._bypassDomain : bypassDomain // ignore: cast_nullable_to_non_nullable
as List<String>,stack: null == stack ? _self.stack : stack // ignore: cast_nullable_to_non_nullable
as String,routeAddress: null == routeAddress ? _self._routeAddress : routeAddress // ignore: cast_nullable_to_non_nullable
as List<String>,smartPauseEnabled: null == smartPauseEnabled ? _self.smartPauseEnabled : smartPauseEnabled // ignore: cast_nullable_to_non_nullable
as bool,smartPauseNetworks: null == smartPauseNetworks ? _self._smartPauseNetworks : smartPauseNetworks // ignore: cast_nullable_to_non_nullable
as List<String>,smartPauseCloseConnections: null == smartPauseCloseConnections ? _self.smartPauseCloseConnections : smartPauseCloseConnections // ignore: cast_nullable_to_non_nullable
as bool,desyncEnabled: null == desyncEnabled ? _self.desyncEnabled : desyncEnabled // ignore: cast_nullable_to_non_nullable
as bool,desyncPort: null == desyncPort ? _self.desyncPort : desyncPort // ignore: cast_nullable_to_non_nullable
as int,desyncStrategy: null == desyncStrategy ? _self._desyncStrategy : desyncStrategy // ignore: cast_nullable_to_non_nullable
as List<String>,desyncCacheTtl: null == desyncCacheTtl ? _self.desyncCacheTtl : desyncCacheTtl // ignore: cast_nullable_to_non_nullable
as int,desyncCacheEnabled: null == desyncCacheEnabled ? _self.desyncCacheEnabled : desyncCacheEnabled // ignore: cast_nullable_to_non_nullable
as bool,desyncTesting: null == desyncTesting ? _self.desyncTesting : desyncTesting // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of VpnOptions
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
mixin _$InitParams {

@JsonKey(name: 'home-dir') String get homeDir; int get version;
/// Create a copy of InitParams
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InitParamsCopyWith<InitParams> get copyWith => _$InitParamsCopyWithImpl<InitParams>(this as InitParams, _$identity);

  /// Serializes this InitParams to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as InitParams;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InitParams&&(identical(other.homeDir, _this.homeDir) || other.homeDir == _this.homeDir)&&(identical(other.version, _this.version) || other.version == _this.version));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as InitParams;
  return Object.hash(runtimeType,_this.homeDir,_this.version);
}

@override
String toString() {
  final _this = this as InitParams;
  return 'InitParams(homeDir: ${_this.homeDir}, version: ${_this.version})';
}


}

/// @nodoc
abstract mixin class $InitParamsCopyWith<$Res>  {
  factory $InitParamsCopyWith(InitParams value, $Res Function(InitParams) _then) = _$InitParamsCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'home-dir') String homeDir, int version
});




}
/// @nodoc
class _$InitParamsCopyWithImpl<$Res>
    implements $InitParamsCopyWith<$Res> {
  _$InitParamsCopyWithImpl(this._self, this._then);

  final InitParams _self;
  final $Res Function(InitParams) _then;

/// Create a copy of InitParams
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? homeDir = null,Object? version = null,}) {
  return _then(InitParams(
homeDir: null == homeDir ? _self.homeDir : homeDir // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [InitParams].
extension InitParamsPatterns on InitParams {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InitParams value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InitParams() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InitParams value)  $default,){
final _that = this;
switch (_that) {
case _InitParams():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InitParams value)?  $default,){
final _that = this;
switch (_that) {
case _InitParams() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'home-dir')  String homeDir,  int version)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InitParams() when $default != null:
return $default(_that.homeDir,_that.version);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'home-dir')  String homeDir,  int version)  $default,) {final _that = this;
switch (_that) {
case _InitParams():
return $default(_that.homeDir,_that.version);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'home-dir')  String homeDir,  int version)?  $default,) {final _that = this;
switch (_that) {
case _InitParams() when $default != null:
return $default(_that.homeDir,_that.version);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InitParams implements InitParams {
  const _InitParams({@JsonKey(name: 'home-dir') required this.homeDir, required this.version});
  factory _InitParams.fromJson(Map<String, dynamic> json) => _$InitParamsFromJson(json);

@override@JsonKey(name: 'home-dir') final  String homeDir;
@override final  int version;

/// Create a copy of InitParams
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InitParamsCopyWith<_InitParams> get copyWith => __$InitParamsCopyWithImpl<_InitParams>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InitParamsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _InitParams&&(identical(other.homeDir, homeDir) || other.homeDir == homeDir)&&(identical(other.version, version) || other.version == version));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,homeDir,version);
}

@override
String toString() {
    return 'InitParams(homeDir: $homeDir, version: $version)';
}


}

/// @nodoc
abstract mixin class _$InitParamsCopyWith<$Res> implements $InitParamsCopyWith<$Res> {
  factory _$InitParamsCopyWith(_InitParams value, $Res Function(_InitParams) _then) = __$InitParamsCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'home-dir') String homeDir, int version
});




}
/// @nodoc
class __$InitParamsCopyWithImpl<$Res>
    implements _$InitParamsCopyWith<$Res> {
  __$InitParamsCopyWithImpl(this._self, this._then);

  final _InitParams _self;
  final $Res Function(_InitParams) _then;

/// Create a copy of InitParams
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? homeDir = null,Object? version = null,}) {
  return _then(_InitParams(
homeDir: null == homeDir ? _self.homeDir : homeDir // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ChangeProxyParams {

@JsonKey(name: 'group-name') String get groupName;@JsonKey(name: 'proxy-name') String get proxyName;
/// Create a copy of ChangeProxyParams
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChangeProxyParamsCopyWith<ChangeProxyParams> get copyWith => _$ChangeProxyParamsCopyWithImpl<ChangeProxyParams>(this as ChangeProxyParams, _$identity);

  /// Serializes this ChangeProxyParams to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ChangeProxyParams;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChangeProxyParams&&(identical(other.groupName, _this.groupName) || other.groupName == _this.groupName)&&(identical(other.proxyName, _this.proxyName) || other.proxyName == _this.proxyName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ChangeProxyParams;
  return Object.hash(runtimeType,_this.groupName,_this.proxyName);
}

@override
String toString() {
  final _this = this as ChangeProxyParams;
  return 'ChangeProxyParams(groupName: ${_this.groupName}, proxyName: ${_this.proxyName})';
}


}

/// @nodoc
abstract mixin class $ChangeProxyParamsCopyWith<$Res>  {
  factory $ChangeProxyParamsCopyWith(ChangeProxyParams value, $Res Function(ChangeProxyParams) _then) = _$ChangeProxyParamsCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'group-name') String groupName,@JsonKey(name: 'proxy-name') String proxyName
});




}
/// @nodoc
class _$ChangeProxyParamsCopyWithImpl<$Res>
    implements $ChangeProxyParamsCopyWith<$Res> {
  _$ChangeProxyParamsCopyWithImpl(this._self, this._then);

  final ChangeProxyParams _self;
  final $Res Function(ChangeProxyParams) _then;

/// Create a copy of ChangeProxyParams
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? groupName = null,Object? proxyName = null,}) {
  return _then(ChangeProxyParams(
groupName: null == groupName ? _self.groupName : groupName // ignore: cast_nullable_to_non_nullable
as String,proxyName: null == proxyName ? _self.proxyName : proxyName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ChangeProxyParams].
extension ChangeProxyParamsPatterns on ChangeProxyParams {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChangeProxyParams value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChangeProxyParams() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChangeProxyParams value)  $default,){
final _that = this;
switch (_that) {
case _ChangeProxyParams():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChangeProxyParams value)?  $default,){
final _that = this;
switch (_that) {
case _ChangeProxyParams() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'group-name')  String groupName, @JsonKey(name: 'proxy-name')  String proxyName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChangeProxyParams() when $default != null:
return $default(_that.groupName,_that.proxyName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'group-name')  String groupName, @JsonKey(name: 'proxy-name')  String proxyName)  $default,) {final _that = this;
switch (_that) {
case _ChangeProxyParams():
return $default(_that.groupName,_that.proxyName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'group-name')  String groupName, @JsonKey(name: 'proxy-name')  String proxyName)?  $default,) {final _that = this;
switch (_that) {
case _ChangeProxyParams() when $default != null:
return $default(_that.groupName,_that.proxyName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChangeProxyParams implements ChangeProxyParams {
  const _ChangeProxyParams({@JsonKey(name: 'group-name') required this.groupName, @JsonKey(name: 'proxy-name') required this.proxyName});
  factory _ChangeProxyParams.fromJson(Map<String, dynamic> json) => _$ChangeProxyParamsFromJson(json);

@override@JsonKey(name: 'group-name') final  String groupName;
@override@JsonKey(name: 'proxy-name') final  String proxyName;

/// Create a copy of ChangeProxyParams
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChangeProxyParamsCopyWith<_ChangeProxyParams> get copyWith => __$ChangeProxyParamsCopyWithImpl<_ChangeProxyParams>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChangeProxyParamsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChangeProxyParams&&(identical(other.groupName, groupName) || other.groupName == groupName)&&(identical(other.proxyName, proxyName) || other.proxyName == proxyName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,groupName,proxyName);
}

@override
String toString() {
    return 'ChangeProxyParams(groupName: $groupName, proxyName: $proxyName)';
}


}

/// @nodoc
abstract mixin class _$ChangeProxyParamsCopyWith<$Res> implements $ChangeProxyParamsCopyWith<$Res> {
  factory _$ChangeProxyParamsCopyWith(_ChangeProxyParams value, $Res Function(_ChangeProxyParams) _then) = __$ChangeProxyParamsCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'group-name') String groupName,@JsonKey(name: 'proxy-name') String proxyName
});




}
/// @nodoc
class __$ChangeProxyParamsCopyWithImpl<$Res>
    implements _$ChangeProxyParamsCopyWith<$Res> {
  __$ChangeProxyParamsCopyWithImpl(this._self, this._then);

  final _ChangeProxyParams _self;
  final $Res Function(_ChangeProxyParams) _then;

/// Create a copy of ChangeProxyParams
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? groupName = null,Object? proxyName = null,}) {
  return _then(_ChangeProxyParams(
groupName: null == groupName ? _self.groupName : groupName // ignore: cast_nullable_to_non_nullable
as String,proxyName: null == proxyName ? _self.proxyName : proxyName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$UpdateGeoDataParams {

@JsonKey(name: 'geo-type') String get geoType;@JsonKey(name: 'geo-name') String get geoName;
/// Create a copy of UpdateGeoDataParams
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateGeoDataParamsCopyWith<UpdateGeoDataParams> get copyWith => _$UpdateGeoDataParamsCopyWithImpl<UpdateGeoDataParams>(this as UpdateGeoDataParams, _$identity);

  /// Serializes this UpdateGeoDataParams to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UpdateGeoDataParams;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateGeoDataParams&&(identical(other.geoType, _this.geoType) || other.geoType == _this.geoType)&&(identical(other.geoName, _this.geoName) || other.geoName == _this.geoName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UpdateGeoDataParams;
  return Object.hash(runtimeType,_this.geoType,_this.geoName);
}

@override
String toString() {
  final _this = this as UpdateGeoDataParams;
  return 'UpdateGeoDataParams(geoType: ${_this.geoType}, geoName: ${_this.geoName})';
}


}

/// @nodoc
abstract mixin class $UpdateGeoDataParamsCopyWith<$Res>  {
  factory $UpdateGeoDataParamsCopyWith(UpdateGeoDataParams value, $Res Function(UpdateGeoDataParams) _then) = _$UpdateGeoDataParamsCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'geo-type') String geoType,@JsonKey(name: 'geo-name') String geoName
});




}
/// @nodoc
class _$UpdateGeoDataParamsCopyWithImpl<$Res>
    implements $UpdateGeoDataParamsCopyWith<$Res> {
  _$UpdateGeoDataParamsCopyWithImpl(this._self, this._then);

  final UpdateGeoDataParams _self;
  final $Res Function(UpdateGeoDataParams) _then;

/// Create a copy of UpdateGeoDataParams
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? geoType = null,Object? geoName = null,}) {
  return _then(UpdateGeoDataParams(
geoType: null == geoType ? _self.geoType : geoType // ignore: cast_nullable_to_non_nullable
as String,geoName: null == geoName ? _self.geoName : geoName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateGeoDataParams].
extension UpdateGeoDataParamsPatterns on UpdateGeoDataParams {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateGeoDataParams value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateGeoDataParams() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateGeoDataParams value)  $default,){
final _that = this;
switch (_that) {
case _UpdateGeoDataParams():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateGeoDataParams value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateGeoDataParams() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'geo-type')  String geoType, @JsonKey(name: 'geo-name')  String geoName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateGeoDataParams() when $default != null:
return $default(_that.geoType,_that.geoName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'geo-type')  String geoType, @JsonKey(name: 'geo-name')  String geoName)  $default,) {final _that = this;
switch (_that) {
case _UpdateGeoDataParams():
return $default(_that.geoType,_that.geoName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'geo-type')  String geoType, @JsonKey(name: 'geo-name')  String geoName)?  $default,) {final _that = this;
switch (_that) {
case _UpdateGeoDataParams() when $default != null:
return $default(_that.geoType,_that.geoName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateGeoDataParams implements UpdateGeoDataParams {
  const _UpdateGeoDataParams({@JsonKey(name: 'geo-type') required this.geoType, @JsonKey(name: 'geo-name') required this.geoName});
  factory _UpdateGeoDataParams.fromJson(Map<String, dynamic> json) => _$UpdateGeoDataParamsFromJson(json);

@override@JsonKey(name: 'geo-type') final  String geoType;
@override@JsonKey(name: 'geo-name') final  String geoName;

/// Create a copy of UpdateGeoDataParams
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateGeoDataParamsCopyWith<_UpdateGeoDataParams> get copyWith => __$UpdateGeoDataParamsCopyWithImpl<_UpdateGeoDataParams>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateGeoDataParamsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateGeoDataParams&&(identical(other.geoType, geoType) || other.geoType == geoType)&&(identical(other.geoName, geoName) || other.geoName == geoName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,geoType,geoName);
}

@override
String toString() {
    return 'UpdateGeoDataParams(geoType: $geoType, geoName: $geoName)';
}


}

/// @nodoc
abstract mixin class _$UpdateGeoDataParamsCopyWith<$Res> implements $UpdateGeoDataParamsCopyWith<$Res> {
  factory _$UpdateGeoDataParamsCopyWith(_UpdateGeoDataParams value, $Res Function(_UpdateGeoDataParams) _then) = __$UpdateGeoDataParamsCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'geo-type') String geoType,@JsonKey(name: 'geo-name') String geoName
});




}
/// @nodoc
class __$UpdateGeoDataParamsCopyWithImpl<$Res>
    implements _$UpdateGeoDataParamsCopyWith<$Res> {
  __$UpdateGeoDataParamsCopyWithImpl(this._self, this._then);

  final _UpdateGeoDataParams _self;
  final $Res Function(_UpdateGeoDataParams) _then;

/// Create a copy of UpdateGeoDataParams
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? geoType = null,Object? geoName = null,}) {
  return _then(_UpdateGeoDataParams(
geoType: null == geoType ? _self.geoType : geoType // ignore: cast_nullable_to_non_nullable
as String,geoName: null == geoName ? _self.geoName : geoName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$CoreEvent {

 CoreEventType get type; dynamic get data;
/// Create a copy of CoreEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoreEventCopyWith<CoreEvent> get copyWith => _$CoreEventCopyWithImpl<CoreEvent>(this as CoreEvent, _$identity);

  /// Serializes this CoreEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CoreEvent;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoreEvent&&(identical(other.type, _this.type) || other.type == _this.type)&&const DeepCollectionEquality().equals(other.data, _this.data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CoreEvent;
  return Object.hash(runtimeType,_this.type,const DeepCollectionEquality().hash(_this.data));
}

@override
String toString() {
  final _this = this as CoreEvent;
  return 'CoreEvent(type: ${_this.type}, data: ${_this.data})';
}


}

/// @nodoc
abstract mixin class $CoreEventCopyWith<$Res>  {
  factory $CoreEventCopyWith(CoreEvent value, $Res Function(CoreEvent) _then) = _$CoreEventCopyWithImpl;
@useResult
$Res call({
 CoreEventType type, dynamic data
});




}
/// @nodoc
class _$CoreEventCopyWithImpl<$Res>
    implements $CoreEventCopyWith<$Res> {
  _$CoreEventCopyWithImpl(this._self, this._then);

  final CoreEvent _self;
  final $Res Function(CoreEvent) _then;

/// Create a copy of CoreEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? data = freezed,}) {
  return _then(CoreEvent(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CoreEventType,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}

}


/// Adds pattern-matching-related methods to [CoreEvent].
extension CoreEventPatterns on CoreEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoreEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoreEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoreEvent value)  $default,){
final _that = this;
switch (_that) {
case _CoreEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoreEvent value)?  $default,){
final _that = this;
switch (_that) {
case _CoreEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CoreEventType type,  dynamic data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoreEvent() when $default != null:
return $default(_that.type,_that.data);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CoreEventType type,  dynamic data)  $default,) {final _that = this;
switch (_that) {
case _CoreEvent():
return $default(_that.type,_that.data);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CoreEventType type,  dynamic data)?  $default,) {final _that = this;
switch (_that) {
case _CoreEvent() when $default != null:
return $default(_that.type,_that.data);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CoreEvent implements CoreEvent {
  const _CoreEvent({required this.type, this.data});
  factory _CoreEvent.fromJson(Map<String, dynamic> json) => _$CoreEventFromJson(json);

@override final  CoreEventType type;
@override final  dynamic data;

/// Create a copy of CoreEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoreEventCopyWith<_CoreEvent> get copyWith => __$CoreEventCopyWithImpl<_CoreEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CoreEventToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoreEvent&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.data, data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,type,const DeepCollectionEquality().hash(data));
}

@override
String toString() {
    return 'CoreEvent(type: $type, data: $data)';
}


}

/// @nodoc
abstract mixin class _$CoreEventCopyWith<$Res> implements $CoreEventCopyWith<$Res> {
  factory _$CoreEventCopyWith(_CoreEvent value, $Res Function(_CoreEvent) _then) = __$CoreEventCopyWithImpl;
@override @useResult
$Res call({
 CoreEventType type, dynamic data
});




}
/// @nodoc
class __$CoreEventCopyWithImpl<$Res>
    implements _$CoreEventCopyWith<$Res> {
  __$CoreEventCopyWithImpl(this._self, this._then);

  final _CoreEvent _self;
  final $Res Function(_CoreEvent) _then;

/// Create a copy of CoreEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? data = freezed,}) {
  return _then(_CoreEvent(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CoreEventType,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}


}


/// @nodoc
mixin _$InvokeMessage {

 InvokeMessageType get type; dynamic get data;
/// Create a copy of InvokeMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvokeMessageCopyWith<InvokeMessage> get copyWith => _$InvokeMessageCopyWithImpl<InvokeMessage>(this as InvokeMessage, _$identity);

  /// Serializes this InvokeMessage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as InvokeMessage;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InvokeMessage&&(identical(other.type, _this.type) || other.type == _this.type)&&const DeepCollectionEquality().equals(other.data, _this.data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as InvokeMessage;
  return Object.hash(runtimeType,_this.type,const DeepCollectionEquality().hash(_this.data));
}

@override
String toString() {
  final _this = this as InvokeMessage;
  return 'InvokeMessage(type: ${_this.type}, data: ${_this.data})';
}


}

/// @nodoc
abstract mixin class $InvokeMessageCopyWith<$Res>  {
  factory $InvokeMessageCopyWith(InvokeMessage value, $Res Function(InvokeMessage) _then) = _$InvokeMessageCopyWithImpl;
@useResult
$Res call({
 InvokeMessageType type, dynamic data
});




}
/// @nodoc
class _$InvokeMessageCopyWithImpl<$Res>
    implements $InvokeMessageCopyWith<$Res> {
  _$InvokeMessageCopyWithImpl(this._self, this._then);

  final InvokeMessage _self;
  final $Res Function(InvokeMessage) _then;

/// Create a copy of InvokeMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? data = freezed,}) {
  return _then(InvokeMessage(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as InvokeMessageType,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}

}


/// Adds pattern-matching-related methods to [InvokeMessage].
extension InvokeMessagePatterns on InvokeMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InvokeMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InvokeMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InvokeMessage value)  $default,){
final _that = this;
switch (_that) {
case _InvokeMessage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InvokeMessage value)?  $default,){
final _that = this;
switch (_that) {
case _InvokeMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( InvokeMessageType type,  dynamic data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InvokeMessage() when $default != null:
return $default(_that.type,_that.data);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( InvokeMessageType type,  dynamic data)  $default,) {final _that = this;
switch (_that) {
case _InvokeMessage():
return $default(_that.type,_that.data);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( InvokeMessageType type,  dynamic data)?  $default,) {final _that = this;
switch (_that) {
case _InvokeMessage() when $default != null:
return $default(_that.type,_that.data);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InvokeMessage implements InvokeMessage {
  const _InvokeMessage({required this.type, this.data});
  factory _InvokeMessage.fromJson(Map<String, dynamic> json) => _$InvokeMessageFromJson(json);

@override final  InvokeMessageType type;
@override final  dynamic data;

/// Create a copy of InvokeMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvokeMessageCopyWith<_InvokeMessage> get copyWith => __$InvokeMessageCopyWithImpl<_InvokeMessage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InvokeMessageToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _InvokeMessage&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.data, data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,type,const DeepCollectionEquality().hash(data));
}

@override
String toString() {
    return 'InvokeMessage(type: $type, data: $data)';
}


}

/// @nodoc
abstract mixin class _$InvokeMessageCopyWith<$Res> implements $InvokeMessageCopyWith<$Res> {
  factory _$InvokeMessageCopyWith(_InvokeMessage value, $Res Function(_InvokeMessage) _then) = __$InvokeMessageCopyWithImpl;
@override @useResult
$Res call({
 InvokeMessageType type, dynamic data
});




}
/// @nodoc
class __$InvokeMessageCopyWithImpl<$Res>
    implements _$InvokeMessageCopyWith<$Res> {
  __$InvokeMessageCopyWithImpl(this._self, this._then);

  final _InvokeMessage _self;
  final $Res Function(_InvokeMessage) _then;

/// Create a copy of InvokeMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? data = freezed,}) {
  return _then(_InvokeMessage(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as InvokeMessageType,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}


}


/// @nodoc
mixin _$Delay {

 String get name; String get url; int? get value;
/// Create a copy of Delay
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DelayCopyWith<Delay> get copyWith => _$DelayCopyWithImpl<Delay>(this as Delay, _$identity);

  /// Serializes this Delay to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Delay;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Delay&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.value, _this.value) || other.value == _this.value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Delay;
  return Object.hash(runtimeType,_this.name,_this.url,_this.value);
}

@override
String toString() {
  final _this = this as Delay;
  return 'Delay(name: ${_this.name}, url: ${_this.url}, value: ${_this.value})';
}


}

/// @nodoc
abstract mixin class $DelayCopyWith<$Res>  {
  factory $DelayCopyWith(Delay value, $Res Function(Delay) _then) = _$DelayCopyWithImpl;
@useResult
$Res call({
 String name, String url, int? value
});




}
/// @nodoc
class _$DelayCopyWithImpl<$Res>
    implements $DelayCopyWith<$Res> {
  _$DelayCopyWithImpl(this._self, this._then);

  final Delay _self;
  final $Res Function(Delay) _then;

/// Create a copy of Delay
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? url = null,Object? value = freezed,}) {
  return _then(Delay(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [Delay].
extension DelayPatterns on Delay {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Delay value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Delay() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Delay value)  $default,){
final _that = this;
switch (_that) {
case _Delay():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Delay value)?  $default,){
final _that = this;
switch (_that) {
case _Delay() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String url,  int? value)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Delay() when $default != null:
return $default(_that.name,_that.url,_that.value);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String url,  int? value)  $default,) {final _that = this;
switch (_that) {
case _Delay():
return $default(_that.name,_that.url,_that.value);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String url,  int? value)?  $default,) {final _that = this;
switch (_that) {
case _Delay() when $default != null:
return $default(_that.name,_that.url,_that.value);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Delay implements Delay {
  const _Delay({required this.name, required this.url, this.value});
  factory _Delay.fromJson(Map<String, dynamic> json) => _$DelayFromJson(json);

@override final  String name;
@override final  String url;
@override final  int? value;

/// Create a copy of Delay
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DelayCopyWith<_Delay> get copyWith => __$DelayCopyWithImpl<_Delay>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DelayToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Delay&&(identical(other.name, name) || other.name == name)&&(identical(other.url, url) || other.url == url)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,url,value);
}

@override
String toString() {
    return 'Delay(name: $name, url: $url, value: $value)';
}


}

/// @nodoc
abstract mixin class _$DelayCopyWith<$Res> implements $DelayCopyWith<$Res> {
  factory _$DelayCopyWith(_Delay value, $Res Function(_Delay) _then) = __$DelayCopyWithImpl;
@override @useResult
$Res call({
 String name, String url, int? value
});




}
/// @nodoc
class __$DelayCopyWithImpl<$Res>
    implements _$DelayCopyWith<$Res> {
  __$DelayCopyWithImpl(this._self, this._then);

  final _Delay _self;
  final $Res Function(_Delay) _then;

/// Create a copy of Delay
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? url = null,Object? value = freezed,}) {
  return _then(_Delay(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$Now {

 String get name; String get value;
/// Create a copy of Now
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NowCopyWith<Now> get copyWith => _$NowCopyWithImpl<Now>(this as Now, _$identity);

  /// Serializes this Now to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Now;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Now&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.value, _this.value) || other.value == _this.value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Now;
  return Object.hash(runtimeType,_this.name,_this.value);
}

@override
String toString() {
  final _this = this as Now;
  return 'Now(name: ${_this.name}, value: ${_this.value})';
}


}

/// @nodoc
abstract mixin class $NowCopyWith<$Res>  {
  factory $NowCopyWith(Now value, $Res Function(Now) _then) = _$NowCopyWithImpl;
@useResult
$Res call({
 String name, String value
});




}
/// @nodoc
class _$NowCopyWithImpl<$Res>
    implements $NowCopyWith<$Res> {
  _$NowCopyWithImpl(this._self, this._then);

  final Now _self;
  final $Res Function(Now) _then;

/// Create a copy of Now
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? value = null,}) {
  return _then(Now(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Now].
extension NowPatterns on Now {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Now value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Now() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Now value)  $default,){
final _that = this;
switch (_that) {
case _Now():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Now value)?  $default,){
final _that = this;
switch (_that) {
case _Now() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String value)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Now() when $default != null:
return $default(_that.name,_that.value);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String value)  $default,) {final _that = this;
switch (_that) {
case _Now():
return $default(_that.name,_that.value);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String value)?  $default,) {final _that = this;
switch (_that) {
case _Now() when $default != null:
return $default(_that.name,_that.value);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Now implements Now {
  const _Now({required this.name, required this.value});
  factory _Now.fromJson(Map<String, dynamic> json) => _$NowFromJson(json);

@override final  String name;
@override final  String value;

/// Create a copy of Now
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NowCopyWith<_Now> get copyWith => __$NowCopyWithImpl<_Now>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NowToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Now&&(identical(other.name, name) || other.name == name)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,value);
}

@override
String toString() {
    return 'Now(name: $name, value: $value)';
}


}

/// @nodoc
abstract mixin class _$NowCopyWith<$Res> implements $NowCopyWith<$Res> {
  factory _$NowCopyWith(_Now value, $Res Function(_Now) _then) = __$NowCopyWithImpl;
@override @useResult
$Res call({
 String name, String value
});




}
/// @nodoc
class __$NowCopyWithImpl<$Res>
    implements _$NowCopyWith<$Res> {
  __$NowCopyWithImpl(this._self, this._then);

  final _Now _self;
  final $Res Function(_Now) _then;

/// Create a copy of Now
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? value = null,}) {
  return _then(_Now(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ProviderSubscriptionInfo {

@JsonKey(name: 'UPLOAD') int get upload;@JsonKey(name: 'DOWNLOAD') int get download;@JsonKey(name: 'TOTAL') int get total;@JsonKey(name: 'EXPIRE') int get expire;
/// Create a copy of ProviderSubscriptionInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProviderSubscriptionInfoCopyWith<ProviderSubscriptionInfo> get copyWith => _$ProviderSubscriptionInfoCopyWithImpl<ProviderSubscriptionInfo>(this as ProviderSubscriptionInfo, _$identity);

  /// Serializes this ProviderSubscriptionInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ProviderSubscriptionInfo;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProviderSubscriptionInfo&&(identical(other.upload, _this.upload) || other.upload == _this.upload)&&(identical(other.download, _this.download) || other.download == _this.download)&&(identical(other.total, _this.total) || other.total == _this.total)&&(identical(other.expire, _this.expire) || other.expire == _this.expire));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ProviderSubscriptionInfo;
  return Object.hash(runtimeType,_this.upload,_this.download,_this.total,_this.expire);
}

@override
String toString() {
  final _this = this as ProviderSubscriptionInfo;
  return 'ProviderSubscriptionInfo(upload: ${_this.upload}, download: ${_this.download}, total: ${_this.total}, expire: ${_this.expire})';
}


}

/// @nodoc
abstract mixin class $ProviderSubscriptionInfoCopyWith<$Res>  {
  factory $ProviderSubscriptionInfoCopyWith(ProviderSubscriptionInfo value, $Res Function(ProviderSubscriptionInfo) _then) = _$ProviderSubscriptionInfoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'UPLOAD') int upload,@JsonKey(name: 'DOWNLOAD') int download,@JsonKey(name: 'TOTAL') int total,@JsonKey(name: 'EXPIRE') int expire
});




}
/// @nodoc
class _$ProviderSubscriptionInfoCopyWithImpl<$Res>
    implements $ProviderSubscriptionInfoCopyWith<$Res> {
  _$ProviderSubscriptionInfoCopyWithImpl(this._self, this._then);

  final ProviderSubscriptionInfo _self;
  final $Res Function(ProviderSubscriptionInfo) _then;

/// Create a copy of ProviderSubscriptionInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? upload = null,Object? download = null,Object? total = null,Object? expire = null,}) {
  return _then(ProviderSubscriptionInfo(
upload: null == upload ? _self.upload : upload // ignore: cast_nullable_to_non_nullable
as int,download: null == download ? _self.download : download // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,expire: null == expire ? _self.expire : expire // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ProviderSubscriptionInfo].
extension ProviderSubscriptionInfoPatterns on ProviderSubscriptionInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProviderSubscriptionInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProviderSubscriptionInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProviderSubscriptionInfo value)  $default,){
final _that = this;
switch (_that) {
case _ProviderSubscriptionInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProviderSubscriptionInfo value)?  $default,){
final _that = this;
switch (_that) {
case _ProviderSubscriptionInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'UPLOAD')  int upload, @JsonKey(name: 'DOWNLOAD')  int download, @JsonKey(name: 'TOTAL')  int total, @JsonKey(name: 'EXPIRE')  int expire)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProviderSubscriptionInfo() when $default != null:
return $default(_that.upload,_that.download,_that.total,_that.expire);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'UPLOAD')  int upload, @JsonKey(name: 'DOWNLOAD')  int download, @JsonKey(name: 'TOTAL')  int total, @JsonKey(name: 'EXPIRE')  int expire)  $default,) {final _that = this;
switch (_that) {
case _ProviderSubscriptionInfo():
return $default(_that.upload,_that.download,_that.total,_that.expire);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'UPLOAD')  int upload, @JsonKey(name: 'DOWNLOAD')  int download, @JsonKey(name: 'TOTAL')  int total, @JsonKey(name: 'EXPIRE')  int expire)?  $default,) {final _that = this;
switch (_that) {
case _ProviderSubscriptionInfo() when $default != null:
return $default(_that.upload,_that.download,_that.total,_that.expire);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProviderSubscriptionInfo implements ProviderSubscriptionInfo {
  const _ProviderSubscriptionInfo({@JsonKey(name: 'UPLOAD') this.upload = 0, @JsonKey(name: 'DOWNLOAD') this.download = 0, @JsonKey(name: 'TOTAL') this.total = 0, @JsonKey(name: 'EXPIRE') this.expire = 0});
  factory _ProviderSubscriptionInfo.fromJson(Map<String, dynamic> json) => _$ProviderSubscriptionInfoFromJson(json);

@override@JsonKey(name: 'UPLOAD') final  int upload;
@override@JsonKey(name: 'DOWNLOAD') final  int download;
@override@JsonKey(name: 'TOTAL') final  int total;
@override@JsonKey(name: 'EXPIRE') final  int expire;

/// Create a copy of ProviderSubscriptionInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProviderSubscriptionInfoCopyWith<_ProviderSubscriptionInfo> get copyWith => __$ProviderSubscriptionInfoCopyWithImpl<_ProviderSubscriptionInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProviderSubscriptionInfoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProviderSubscriptionInfo&&(identical(other.upload, upload) || other.upload == upload)&&(identical(other.download, download) || other.download == download)&&(identical(other.total, total) || other.total == total)&&(identical(other.expire, expire) || other.expire == expire));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,upload,download,total,expire);
}

@override
String toString() {
    return 'ProviderSubscriptionInfo(upload: $upload, download: $download, total: $total, expire: $expire)';
}


}

/// @nodoc
abstract mixin class _$ProviderSubscriptionInfoCopyWith<$Res> implements $ProviderSubscriptionInfoCopyWith<$Res> {
  factory _$ProviderSubscriptionInfoCopyWith(_ProviderSubscriptionInfo value, $Res Function(_ProviderSubscriptionInfo) _then) = __$ProviderSubscriptionInfoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'UPLOAD') int upload,@JsonKey(name: 'DOWNLOAD') int download,@JsonKey(name: 'TOTAL') int total,@JsonKey(name: 'EXPIRE') int expire
});




}
/// @nodoc
class __$ProviderSubscriptionInfoCopyWithImpl<$Res>
    implements _$ProviderSubscriptionInfoCopyWith<$Res> {
  __$ProviderSubscriptionInfoCopyWithImpl(this._self, this._then);

  final _ProviderSubscriptionInfo _self;
  final $Res Function(_ProviderSubscriptionInfo) _then;

/// Create a copy of ProviderSubscriptionInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? upload = null,Object? download = null,Object? total = null,Object? expire = null,}) {
  return _then(_ProviderSubscriptionInfo(
upload: null == upload ? _self.upload : upload // ignore: cast_nullable_to_non_nullable
as int,download: null == download ? _self.download : download // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,expire: null == expire ? _self.expire : expire // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ExternalProvider {

 String get name; String get type; String? get path; int get count;@JsonKey(name: 'subscription-info', fromJson: subscriptionInfoFormCore) SubscriptionInfo? get subscriptionInfo;@JsonKey(name: 'vehicle-type') String get vehicleType;@JsonKey(name: 'update-at') DateTime get updateAt;
/// Create a copy of ExternalProvider
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExternalProviderCopyWith<ExternalProvider> get copyWith => _$ExternalProviderCopyWithImpl<ExternalProvider>(this as ExternalProvider, _$identity);

  /// Serializes this ExternalProvider to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ExternalProvider;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExternalProvider&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.path, _this.path) || other.path == _this.path)&&(identical(other.count, _this.count) || other.count == _this.count)&&(identical(other.subscriptionInfo, _this.subscriptionInfo) || other.subscriptionInfo == _this.subscriptionInfo)&&(identical(other.vehicleType, _this.vehicleType) || other.vehicleType == _this.vehicleType)&&(identical(other.updateAt, _this.updateAt) || other.updateAt == _this.updateAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ExternalProvider;
  return Object.hash(runtimeType,_this.name,_this.type,_this.path,_this.count,_this.subscriptionInfo,_this.vehicleType,_this.updateAt);
}

@override
String toString() {
  final _this = this as ExternalProvider;
  return 'ExternalProvider(name: ${_this.name}, type: ${_this.type}, path: ${_this.path}, count: ${_this.count}, subscriptionInfo: ${_this.subscriptionInfo}, vehicleType: ${_this.vehicleType}, updateAt: ${_this.updateAt})';
}


}

/// @nodoc
abstract mixin class $ExternalProviderCopyWith<$Res>  {
  factory $ExternalProviderCopyWith(ExternalProvider value, $Res Function(ExternalProvider) _then) = _$ExternalProviderCopyWithImpl;
@useResult
$Res call({
 String name, String type, String? path, int count,@JsonKey(name: 'subscription-info', fromJson: subscriptionInfoFormCore) SubscriptionInfo? subscriptionInfo,@JsonKey(name: 'vehicle-type') String vehicleType,@JsonKey(name: 'update-at') DateTime updateAt
});


$SubscriptionInfoCopyWith<$Res>? get subscriptionInfo;

}
/// @nodoc
class _$ExternalProviderCopyWithImpl<$Res>
    implements $ExternalProviderCopyWith<$Res> {
  _$ExternalProviderCopyWithImpl(this._self, this._then);

  final ExternalProvider _self;
  final $Res Function(ExternalProvider) _then;

/// Create a copy of ExternalProvider
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? type = null,Object? path = freezed,Object? count = null,Object? subscriptionInfo = freezed,Object? vehicleType = null,Object? updateAt = null,}) {
  return _then(ExternalProvider(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,path: freezed == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String?,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,subscriptionInfo: freezed == subscriptionInfo ? _self.subscriptionInfo : subscriptionInfo // ignore: cast_nullable_to_non_nullable
as SubscriptionInfo?,vehicleType: null == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as String,updateAt: null == updateAt ? _self.updateAt : updateAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of ExternalProvider
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SubscriptionInfoCopyWith<$Res>? get subscriptionInfo {
    if (_self.subscriptionInfo == null) {
    return null;
  }

  return $SubscriptionInfoCopyWith<$Res>(_self.subscriptionInfo!, (value) {
    return _then(_self.copyWith(subscriptionInfo: value));
  });
}
}


/// Adds pattern-matching-related methods to [ExternalProvider].
extension ExternalProviderPatterns on ExternalProvider {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExternalProvider value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExternalProvider() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExternalProvider value)  $default,){
final _that = this;
switch (_that) {
case _ExternalProvider():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExternalProvider value)?  $default,){
final _that = this;
switch (_that) {
case _ExternalProvider() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String type,  String? path,  int count, @JsonKey(name: 'subscription-info', fromJson: subscriptionInfoFormCore)  SubscriptionInfo? subscriptionInfo, @JsonKey(name: 'vehicle-type')  String vehicleType, @JsonKey(name: 'update-at')  DateTime updateAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExternalProvider() when $default != null:
return $default(_that.name,_that.type,_that.path,_that.count,_that.subscriptionInfo,_that.vehicleType,_that.updateAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String type,  String? path,  int count, @JsonKey(name: 'subscription-info', fromJson: subscriptionInfoFormCore)  SubscriptionInfo? subscriptionInfo, @JsonKey(name: 'vehicle-type')  String vehicleType, @JsonKey(name: 'update-at')  DateTime updateAt)  $default,) {final _that = this;
switch (_that) {
case _ExternalProvider():
return $default(_that.name,_that.type,_that.path,_that.count,_that.subscriptionInfo,_that.vehicleType,_that.updateAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String type,  String? path,  int count, @JsonKey(name: 'subscription-info', fromJson: subscriptionInfoFormCore)  SubscriptionInfo? subscriptionInfo, @JsonKey(name: 'vehicle-type')  String vehicleType, @JsonKey(name: 'update-at')  DateTime updateAt)?  $default,) {final _that = this;
switch (_that) {
case _ExternalProvider() when $default != null:
return $default(_that.name,_that.type,_that.path,_that.count,_that.subscriptionInfo,_that.vehicleType,_that.updateAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExternalProvider implements ExternalProvider {
  const _ExternalProvider({required this.name, required this.type, this.path, required this.count, @JsonKey(name: 'subscription-info', fromJson: subscriptionInfoFormCore) this.subscriptionInfo, @JsonKey(name: 'vehicle-type') required this.vehicleType, @JsonKey(name: 'update-at') required this.updateAt});
  factory _ExternalProvider.fromJson(Map<String, dynamic> json) => _$ExternalProviderFromJson(json);

@override final  String name;
@override final  String type;
@override final  String? path;
@override final  int count;
@override@JsonKey(name: 'subscription-info', fromJson: subscriptionInfoFormCore) final  SubscriptionInfo? subscriptionInfo;
@override@JsonKey(name: 'vehicle-type') final  String vehicleType;
@override@JsonKey(name: 'update-at') final  DateTime updateAt;

/// Create a copy of ExternalProvider
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExternalProviderCopyWith<_ExternalProvider> get copyWith => __$ExternalProviderCopyWithImpl<_ExternalProvider>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExternalProviderToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExternalProvider&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.path, path) || other.path == path)&&(identical(other.count, count) || other.count == count)&&(identical(other.subscriptionInfo, subscriptionInfo) || other.subscriptionInfo == subscriptionInfo)&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType)&&(identical(other.updateAt, updateAt) || other.updateAt == updateAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,type,path,count,subscriptionInfo,vehicleType,updateAt);
}

@override
String toString() {
    return 'ExternalProvider(name: $name, type: $type, path: $path, count: $count, subscriptionInfo: $subscriptionInfo, vehicleType: $vehicleType, updateAt: $updateAt)';
}


}

/// @nodoc
abstract mixin class _$ExternalProviderCopyWith<$Res> implements $ExternalProviderCopyWith<$Res> {
  factory _$ExternalProviderCopyWith(_ExternalProvider value, $Res Function(_ExternalProvider) _then) = __$ExternalProviderCopyWithImpl;
@override @useResult
$Res call({
 String name, String type, String? path, int count,@JsonKey(name: 'subscription-info', fromJson: subscriptionInfoFormCore) SubscriptionInfo? subscriptionInfo,@JsonKey(name: 'vehicle-type') String vehicleType,@JsonKey(name: 'update-at') DateTime updateAt
});


@override $SubscriptionInfoCopyWith<$Res>? get subscriptionInfo;

}
/// @nodoc
class __$ExternalProviderCopyWithImpl<$Res>
    implements _$ExternalProviderCopyWith<$Res> {
  __$ExternalProviderCopyWithImpl(this._self, this._then);

  final _ExternalProvider _self;
  final $Res Function(_ExternalProvider) _then;

/// Create a copy of ExternalProvider
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? type = null,Object? path = freezed,Object? count = null,Object? subscriptionInfo = freezed,Object? vehicleType = null,Object? updateAt = null,}) {
  return _then(_ExternalProvider(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,path: freezed == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String?,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,subscriptionInfo: freezed == subscriptionInfo ? _self.subscriptionInfo : subscriptionInfo // ignore: cast_nullable_to_non_nullable
as SubscriptionInfo?,vehicleType: null == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as String,updateAt: null == updateAt ? _self.updateAt : updateAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of ExternalProvider
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SubscriptionInfoCopyWith<$Res>? get subscriptionInfo {
    if (_self.subscriptionInfo == null) {
    return null;
  }

  return $SubscriptionInfoCopyWith<$Res>(_self.subscriptionInfo!, (value) {
    return _then(_self.copyWith(subscriptionInfo: value));
  });
}
}


/// @nodoc
mixin _$ProxiesData {

 Map<String, dynamic> get proxies; List<String> get all;
/// Create a copy of ProxiesData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProxiesDataCopyWith<ProxiesData> get copyWith => _$ProxiesDataCopyWithImpl<ProxiesData>(this as ProxiesData, _$identity);

  /// Serializes this ProxiesData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ProxiesData;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProxiesData&&const DeepCollectionEquality().equals(other.proxies, _this.proxies)&&const DeepCollectionEquality().equals(other.all, _this.all));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ProxiesData;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.proxies),const DeepCollectionEquality().hash(_this.all));
}

@override
String toString() {
  final _this = this as ProxiesData;
  return 'ProxiesData(proxies: ${_this.proxies}, all: ${_this.all})';
}


}

/// @nodoc
abstract mixin class $ProxiesDataCopyWith<$Res>  {
  factory $ProxiesDataCopyWith(ProxiesData value, $Res Function(ProxiesData) _then) = _$ProxiesDataCopyWithImpl;
@useResult
$Res call({
 Map<String, dynamic> proxies, List<String> all
});




}
/// @nodoc
class _$ProxiesDataCopyWithImpl<$Res>
    implements $ProxiesDataCopyWith<$Res> {
  _$ProxiesDataCopyWithImpl(this._self, this._then);

  final ProxiesData _self;
  final $Res Function(ProxiesData) _then;

/// Create a copy of ProxiesData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? proxies = null,Object? all = null,}) {
  return _then(ProxiesData(
proxies: null == proxies ? _self.proxies : proxies // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,all: null == all ? _self.all : all // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [ProxiesData].
extension ProxiesDataPatterns on ProxiesData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProxiesData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProxiesData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProxiesData value)  $default,){
final _that = this;
switch (_that) {
case _ProxiesData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProxiesData value)?  $default,){
final _that = this;
switch (_that) {
case _ProxiesData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, dynamic> proxies,  List<String> all)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProxiesData() when $default != null:
return $default(_that.proxies,_that.all);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, dynamic> proxies,  List<String> all)  $default,) {final _that = this;
switch (_that) {
case _ProxiesData():
return $default(_that.proxies,_that.all);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, dynamic> proxies,  List<String> all)?  $default,) {final _that = this;
switch (_that) {
case _ProxiesData() when $default != null:
return $default(_that.proxies,_that.all);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProxiesData implements ProxiesData {
  const _ProxiesData({required  Map<String, dynamic> proxies, required  List<String> all}): _proxies = proxies,_all = all;
  factory _ProxiesData.fromJson(Map<String, dynamic> json) => _$ProxiesDataFromJson(json);

 final  Map<String, dynamic> _proxies;
@override Map<String, dynamic> get proxies {
  if (_proxies is EqualUnmodifiableMapView) return _proxies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_proxies);
}

 final  List<String> _all;
@override List<String> get all {
  if (_all is EqualUnmodifiableListView) return _all;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_all);
}


/// Create a copy of ProxiesData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProxiesDataCopyWith<_ProxiesData> get copyWith => __$ProxiesDataCopyWithImpl<_ProxiesData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProxiesDataToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProxiesData&&const DeepCollectionEquality().equals(other.proxies, _proxies)&&const DeepCollectionEquality().equals(other.all, _all));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_proxies),const DeepCollectionEquality().hash(_all));
}

@override
String toString() {
    return 'ProxiesData(proxies: $proxies, all: $all)';
}


}

/// @nodoc
abstract mixin class _$ProxiesDataCopyWith<$Res> implements $ProxiesDataCopyWith<$Res> {
  factory _$ProxiesDataCopyWith(_ProxiesData value, $Res Function(_ProxiesData) _then) = __$ProxiesDataCopyWithImpl;
@override @useResult
$Res call({
 Map<String, dynamic> proxies, List<String> all
});




}
/// @nodoc
class __$ProxiesDataCopyWithImpl<$Res>
    implements _$ProxiesDataCopyWith<$Res> {
  __$ProxiesDataCopyWithImpl(this._self, this._then);

  final _ProxiesData _self;
  final $Res Function(_ProxiesData) _then;

/// Create a copy of ProxiesData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? proxies = null,Object? all = null,}) {
  return _then(_ProxiesData(
proxies: null == proxies ? _self._proxies : proxies // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,all: null == all ? _self._all : all // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$ConfigInspection {

 List<String> get servers; bool get providers; String? get error;
/// Create a copy of ConfigInspection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConfigInspectionCopyWith<ConfigInspection> get copyWith => _$ConfigInspectionCopyWithImpl<ConfigInspection>(this as ConfigInspection, _$identity);

  /// Serializes this ConfigInspection to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ConfigInspection;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConfigInspection&&const DeepCollectionEquality().equals(other.servers, _this.servers)&&(identical(other.providers, _this.providers) || other.providers == _this.providers)&&(identical(other.error, _this.error) || other.error == _this.error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ConfigInspection;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.servers),_this.providers,_this.error);
}

@override
String toString() {
  final _this = this as ConfigInspection;
  return 'ConfigInspection(servers: ${_this.servers}, providers: ${_this.providers}, error: ${_this.error})';
}


}

/// @nodoc
abstract mixin class $ConfigInspectionCopyWith<$Res>  {
  factory $ConfigInspectionCopyWith(ConfigInspection value, $Res Function(ConfigInspection) _then) = _$ConfigInspectionCopyWithImpl;
@useResult
$Res call({
 List<String> servers, bool providers, String? error
});




}
/// @nodoc
class _$ConfigInspectionCopyWithImpl<$Res>
    implements $ConfigInspectionCopyWith<$Res> {
  _$ConfigInspectionCopyWithImpl(this._self, this._then);

  final ConfigInspection _self;
  final $Res Function(ConfigInspection) _then;

/// Create a copy of ConfigInspection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? servers = null,Object? providers = null,Object? error = freezed,}) {
  return _then(ConfigInspection(
servers: null == servers ? _self.servers : servers // ignore: cast_nullable_to_non_nullable
as List<String>,providers: null == providers ? _self.providers : providers // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ConfigInspection].
extension ConfigInspectionPatterns on ConfigInspection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConfigInspection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConfigInspection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConfigInspection value)  $default,){
final _that = this;
switch (_that) {
case _ConfigInspection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConfigInspection value)?  $default,){
final _that = this;
switch (_that) {
case _ConfigInspection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> servers,  bool providers,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConfigInspection() when $default != null:
return $default(_that.servers,_that.providers,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> servers,  bool providers,  String? error)  $default,) {final _that = this;
switch (_that) {
case _ConfigInspection():
return $default(_that.servers,_that.providers,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> servers,  bool providers,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _ConfigInspection() when $default != null:
return $default(_that.servers,_that.providers,_that.error);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ConfigInspection implements ConfigInspection {
  const _ConfigInspection({ List<String> servers = const [], this.providers = false, this.error}): _servers = servers;
  factory _ConfigInspection.fromJson(Map<String, dynamic> json) => _$ConfigInspectionFromJson(json);

 final  List<String> _servers;
@override@JsonKey() List<String> get servers {
  if (_servers is EqualUnmodifiableListView) return _servers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_servers);
}

@override@JsonKey() final  bool providers;
@override final  String? error;

/// Create a copy of ConfigInspection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConfigInspectionCopyWith<_ConfigInspection> get copyWith => __$ConfigInspectionCopyWithImpl<_ConfigInspection>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConfigInspectionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConfigInspection&&const DeepCollectionEquality().equals(other.servers, _servers)&&(identical(other.providers, providers) || other.providers == providers)&&(identical(other.error, error) || other.error == error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_servers),providers,error);
}

@override
String toString() {
    return 'ConfigInspection(servers: $servers, providers: $providers, error: $error)';
}


}

/// @nodoc
abstract mixin class _$ConfigInspectionCopyWith<$Res> implements $ConfigInspectionCopyWith<$Res> {
  factory _$ConfigInspectionCopyWith(_ConfigInspection value, $Res Function(_ConfigInspection) _then) = __$ConfigInspectionCopyWithImpl;
@override @useResult
$Res call({
 List<String> servers, bool providers, String? error
});




}
/// @nodoc
class __$ConfigInspectionCopyWithImpl<$Res>
    implements _$ConfigInspectionCopyWith<$Res> {
  __$ConfigInspectionCopyWithImpl(this._self, this._then);

  final _ConfigInspection _self;
  final $Res Function(_ConfigInspection) _then;

/// Create a copy of ConfigInspection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? servers = null,Object? providers = null,Object? error = freezed,}) {
  return _then(_ConfigInspection(
servers: null == servers ? _self._servers : servers // ignore: cast_nullable_to_non_nullable
as List<String>,providers: null == providers ? _self.providers : providers // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$RcxMarker {

@JsonKey(name: 'url') String get url;@JsonKey(name: 'statuses') List<int> get statuses;
/// Create a copy of RcxMarker
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RcxMarkerCopyWith<RcxMarker> get copyWith => _$RcxMarkerCopyWithImpl<RcxMarker>(this as RcxMarker, _$identity);

  /// Serializes this RcxMarker to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RcxMarker;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RcxMarker&&(identical(other.url, _this.url) || other.url == _this.url)&&const DeepCollectionEquality().equals(other.statuses, _this.statuses));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RcxMarker;
  return Object.hash(runtimeType,_this.url,const DeepCollectionEquality().hash(_this.statuses));
}

@override
String toString() {
  final _this = this as RcxMarker;
  return 'RcxMarker(url: ${_this.url}, statuses: ${_this.statuses})';
}


}

/// @nodoc
abstract mixin class $RcxMarkerCopyWith<$Res>  {
  factory $RcxMarkerCopyWith(RcxMarker value, $Res Function(RcxMarker) _then) = _$RcxMarkerCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'url') String url,@JsonKey(name: 'statuses') List<int> statuses
});




}
/// @nodoc
class _$RcxMarkerCopyWithImpl<$Res>
    implements $RcxMarkerCopyWith<$Res> {
  _$RcxMarkerCopyWithImpl(this._self, this._then);

  final RcxMarker _self;
  final $Res Function(RcxMarker) _then;

/// Create a copy of RcxMarker
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,Object? statuses = null,}) {
  return _then(RcxMarker(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,statuses: null == statuses ? _self.statuses : statuses // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}

}


/// Adds pattern-matching-related methods to [RcxMarker].
extension RcxMarkerPatterns on RcxMarker {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RcxMarker value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RcxMarker() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RcxMarker value)  $default,){
final _that = this;
switch (_that) {
case _RcxMarker():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RcxMarker value)?  $default,){
final _that = this;
switch (_that) {
case _RcxMarker() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'url')  String url, @JsonKey(name: 'statuses')  List<int> statuses)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RcxMarker() when $default != null:
return $default(_that.url,_that.statuses);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'url')  String url, @JsonKey(name: 'statuses')  List<int> statuses)  $default,) {final _that = this;
switch (_that) {
case _RcxMarker():
return $default(_that.url,_that.statuses);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'url')  String url, @JsonKey(name: 'statuses')  List<int> statuses)?  $default,) {final _that = this;
switch (_that) {
case _RcxMarker() when $default != null:
return $default(_that.url,_that.statuses);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RcxMarker implements RcxMarker {
  const _RcxMarker({@JsonKey(name: 'url') required this.url, @JsonKey(name: 'statuses') required  List<int> statuses}): _statuses = statuses;
  factory _RcxMarker.fromJson(Map<String, dynamic> json) => _$RcxMarkerFromJson(json);

@override@JsonKey(name: 'url') final  String url;
 final  List<int> _statuses;
@override@JsonKey(name: 'statuses') List<int> get statuses {
  if (_statuses is EqualUnmodifiableListView) return _statuses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_statuses);
}


/// Create a copy of RcxMarker
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RcxMarkerCopyWith<_RcxMarker> get copyWith => __$RcxMarkerCopyWithImpl<_RcxMarker>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RcxMarkerToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RcxMarker&&(identical(other.url, url) || other.url == url)&&const DeepCollectionEquality().equals(other.statuses, _statuses));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,url,const DeepCollectionEquality().hash(_statuses));
}

@override
String toString() {
    return 'RcxMarker(url: $url, statuses: $statuses)';
}


}

/// @nodoc
abstract mixin class _$RcxMarkerCopyWith<$Res> implements $RcxMarkerCopyWith<$Res> {
  factory _$RcxMarkerCopyWith(_RcxMarker value, $Res Function(_RcxMarker) _then) = __$RcxMarkerCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'url') String url,@JsonKey(name: 'statuses') List<int> statuses
});




}
/// @nodoc
class __$RcxMarkerCopyWithImpl<$Res>
    implements _$RcxMarkerCopyWith<$Res> {
  __$RcxMarkerCopyWithImpl(this._self, this._then);

  final _RcxMarker _self;
  final $Res Function(_RcxMarker) _then;

/// Create a copy of RcxMarker
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? statuses = null,}) {
  return _then(_RcxMarker(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,statuses: null == statuses ? _self._statuses : statuses // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}


}


/// @nodoc
mixin _$RcxConfigParams {

@JsonKey(name: 'on') bool get enabled;@JsonKey(name: 'preset') String get preset;@JsonKey(name: 'st') String get strategy;@JsonKey(name: 'dv') int get defaultsVersion;@JsonKey(name: 'cc') List<String> get censorCountries;@JsonKey(name: 'cf') List<String> get canaryForeign;@JsonKey(name: 'cd') List<String> get canaryDomestic;@JsonKey(name: 'om') List<RcxMarker> get openMarkers;@JsonKey(name: 'dm') List<RcxMarker> get domesticMarkers;@JsonKey(name: 'bp') List<String> get breakerPatterns;@JsonKey(name: 'dlr') bool get allowDomesticLastResort;@JsonKey(name: 'udp') bool get requireUdp;@JsonKey(name: 'rpk') bool get respectPick;@JsonKey(name: 'dwl') int get dwellSeconds;@JsonKey(name: 'ww') int get waveWidth;
/// Create a copy of RcxConfigParams
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RcxConfigParamsCopyWith<RcxConfigParams> get copyWith => _$RcxConfigParamsCopyWithImpl<RcxConfigParams>(this as RcxConfigParams, _$identity);

  /// Serializes this RcxConfigParams to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RcxConfigParams;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RcxConfigParams&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled)&&(identical(other.preset, _this.preset) || other.preset == _this.preset)&&(identical(other.strategy, _this.strategy) || other.strategy == _this.strategy)&&(identical(other.defaultsVersion, _this.defaultsVersion) || other.defaultsVersion == _this.defaultsVersion)&&const DeepCollectionEquality().equals(other.censorCountries, _this.censorCountries)&&const DeepCollectionEquality().equals(other.canaryForeign, _this.canaryForeign)&&const DeepCollectionEquality().equals(other.canaryDomestic, _this.canaryDomestic)&&const DeepCollectionEquality().equals(other.openMarkers, _this.openMarkers)&&const DeepCollectionEquality().equals(other.domesticMarkers, _this.domesticMarkers)&&const DeepCollectionEquality().equals(other.breakerPatterns, _this.breakerPatterns)&&(identical(other.allowDomesticLastResort, _this.allowDomesticLastResort) || other.allowDomesticLastResort == _this.allowDomesticLastResort)&&(identical(other.requireUdp, _this.requireUdp) || other.requireUdp == _this.requireUdp)&&(identical(other.respectPick, _this.respectPick) || other.respectPick == _this.respectPick)&&(identical(other.dwellSeconds, _this.dwellSeconds) || other.dwellSeconds == _this.dwellSeconds)&&(identical(other.waveWidth, _this.waveWidth) || other.waveWidth == _this.waveWidth));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RcxConfigParams;
  return Object.hash(runtimeType,_this.enabled,_this.preset,_this.strategy,_this.defaultsVersion,const DeepCollectionEquality().hash(_this.censorCountries),const DeepCollectionEquality().hash(_this.canaryForeign),const DeepCollectionEquality().hash(_this.canaryDomestic),const DeepCollectionEquality().hash(_this.openMarkers),const DeepCollectionEquality().hash(_this.domesticMarkers),const DeepCollectionEquality().hash(_this.breakerPatterns),_this.allowDomesticLastResort,_this.requireUdp,_this.respectPick,_this.dwellSeconds,_this.waveWidth);
}

@override
String toString() {
  final _this = this as RcxConfigParams;
  return 'RcxConfigParams(enabled: ${_this.enabled}, preset: ${_this.preset}, strategy: ${_this.strategy}, defaultsVersion: ${_this.defaultsVersion}, censorCountries: ${_this.censorCountries}, canaryForeign: ${_this.canaryForeign}, canaryDomestic: ${_this.canaryDomestic}, openMarkers: ${_this.openMarkers}, domesticMarkers: ${_this.domesticMarkers}, breakerPatterns: ${_this.breakerPatterns}, allowDomesticLastResort: ${_this.allowDomesticLastResort}, requireUdp: ${_this.requireUdp}, respectPick: ${_this.respectPick}, dwellSeconds: ${_this.dwellSeconds}, waveWidth: ${_this.waveWidth})';
}


}

/// @nodoc
abstract mixin class $RcxConfigParamsCopyWith<$Res>  {
  factory $RcxConfigParamsCopyWith(RcxConfigParams value, $Res Function(RcxConfigParams) _then) = _$RcxConfigParamsCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'on') bool enabled,@JsonKey(name: 'preset') String preset,@JsonKey(name: 'st') String strategy,@JsonKey(name: 'dv') int defaultsVersion,@JsonKey(name: 'cc') List<String> censorCountries,@JsonKey(name: 'cf') List<String> canaryForeign,@JsonKey(name: 'cd') List<String> canaryDomestic,@JsonKey(name: 'om') List<RcxMarker> openMarkers,@JsonKey(name: 'dm') List<RcxMarker> domesticMarkers,@JsonKey(name: 'bp') List<String> breakerPatterns,@JsonKey(name: 'dlr') bool allowDomesticLastResort,@JsonKey(name: 'udp') bool requireUdp,@JsonKey(name: 'rpk') bool respectPick,@JsonKey(name: 'dwl') int dwellSeconds,@JsonKey(name: 'ww') int waveWidth
});




}
/// @nodoc
class _$RcxConfigParamsCopyWithImpl<$Res>
    implements $RcxConfigParamsCopyWith<$Res> {
  _$RcxConfigParamsCopyWithImpl(this._self, this._then);

  final RcxConfigParams _self;
  final $Res Function(RcxConfigParams) _then;

/// Create a copy of RcxConfigParams
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enabled = null,Object? preset = null,Object? strategy = null,Object? defaultsVersion = null,Object? censorCountries = null,Object? canaryForeign = null,Object? canaryDomestic = null,Object? openMarkers = null,Object? domesticMarkers = null,Object? breakerPatterns = null,Object? allowDomesticLastResort = null,Object? requireUdp = null,Object? respectPick = null,Object? dwellSeconds = null,Object? waveWidth = null,}) {
  return _then(RcxConfigParams(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,preset: null == preset ? _self.preset : preset // ignore: cast_nullable_to_non_nullable
as String,strategy: null == strategy ? _self.strategy : strategy // ignore: cast_nullable_to_non_nullable
as String,defaultsVersion: null == defaultsVersion ? _self.defaultsVersion : defaultsVersion // ignore: cast_nullable_to_non_nullable
as int,censorCountries: null == censorCountries ? _self.censorCountries : censorCountries // ignore: cast_nullable_to_non_nullable
as List<String>,canaryForeign: null == canaryForeign ? _self.canaryForeign : canaryForeign // ignore: cast_nullable_to_non_nullable
as List<String>,canaryDomestic: null == canaryDomestic ? _self.canaryDomestic : canaryDomestic // ignore: cast_nullable_to_non_nullable
as List<String>,openMarkers: null == openMarkers ? _self.openMarkers : openMarkers // ignore: cast_nullable_to_non_nullable
as List<RcxMarker>,domesticMarkers: null == domesticMarkers ? _self.domesticMarkers : domesticMarkers // ignore: cast_nullable_to_non_nullable
as List<RcxMarker>,breakerPatterns: null == breakerPatterns ? _self.breakerPatterns : breakerPatterns // ignore: cast_nullable_to_non_nullable
as List<String>,allowDomesticLastResort: null == allowDomesticLastResort ? _self.allowDomesticLastResort : allowDomesticLastResort // ignore: cast_nullable_to_non_nullable
as bool,requireUdp: null == requireUdp ? _self.requireUdp : requireUdp // ignore: cast_nullable_to_non_nullable
as bool,respectPick: null == respectPick ? _self.respectPick : respectPick // ignore: cast_nullable_to_non_nullable
as bool,dwellSeconds: null == dwellSeconds ? _self.dwellSeconds : dwellSeconds // ignore: cast_nullable_to_non_nullable
as int,waveWidth: null == waveWidth ? _self.waveWidth : waveWidth // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RcxConfigParams].
extension RcxConfigParamsPatterns on RcxConfigParams {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RcxConfigParams value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RcxConfigParams() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RcxConfigParams value)  $default,){
final _that = this;
switch (_that) {
case _RcxConfigParams():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RcxConfigParams value)?  $default,){
final _that = this;
switch (_that) {
case _RcxConfigParams() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'on')  bool enabled, @JsonKey(name: 'preset')  String preset, @JsonKey(name: 'st')  String strategy, @JsonKey(name: 'dv')  int defaultsVersion, @JsonKey(name: 'cc')  List<String> censorCountries, @JsonKey(name: 'cf')  List<String> canaryForeign, @JsonKey(name: 'cd')  List<String> canaryDomestic, @JsonKey(name: 'om')  List<RcxMarker> openMarkers, @JsonKey(name: 'dm')  List<RcxMarker> domesticMarkers, @JsonKey(name: 'bp')  List<String> breakerPatterns, @JsonKey(name: 'dlr')  bool allowDomesticLastResort, @JsonKey(name: 'udp')  bool requireUdp, @JsonKey(name: 'rpk')  bool respectPick, @JsonKey(name: 'dwl')  int dwellSeconds, @JsonKey(name: 'ww')  int waveWidth)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RcxConfigParams() when $default != null:
return $default(_that.enabled,_that.preset,_that.strategy,_that.defaultsVersion,_that.censorCountries,_that.canaryForeign,_that.canaryDomestic,_that.openMarkers,_that.domesticMarkers,_that.breakerPatterns,_that.allowDomesticLastResort,_that.requireUdp,_that.respectPick,_that.dwellSeconds,_that.waveWidth);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'on')  bool enabled, @JsonKey(name: 'preset')  String preset, @JsonKey(name: 'st')  String strategy, @JsonKey(name: 'dv')  int defaultsVersion, @JsonKey(name: 'cc')  List<String> censorCountries, @JsonKey(name: 'cf')  List<String> canaryForeign, @JsonKey(name: 'cd')  List<String> canaryDomestic, @JsonKey(name: 'om')  List<RcxMarker> openMarkers, @JsonKey(name: 'dm')  List<RcxMarker> domesticMarkers, @JsonKey(name: 'bp')  List<String> breakerPatterns, @JsonKey(name: 'dlr')  bool allowDomesticLastResort, @JsonKey(name: 'udp')  bool requireUdp, @JsonKey(name: 'rpk')  bool respectPick, @JsonKey(name: 'dwl')  int dwellSeconds, @JsonKey(name: 'ww')  int waveWidth)  $default,) {final _that = this;
switch (_that) {
case _RcxConfigParams():
return $default(_that.enabled,_that.preset,_that.strategy,_that.defaultsVersion,_that.censorCountries,_that.canaryForeign,_that.canaryDomestic,_that.openMarkers,_that.domesticMarkers,_that.breakerPatterns,_that.allowDomesticLastResort,_that.requireUdp,_that.respectPick,_that.dwellSeconds,_that.waveWidth);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'on')  bool enabled, @JsonKey(name: 'preset')  String preset, @JsonKey(name: 'st')  String strategy, @JsonKey(name: 'dv')  int defaultsVersion, @JsonKey(name: 'cc')  List<String> censorCountries, @JsonKey(name: 'cf')  List<String> canaryForeign, @JsonKey(name: 'cd')  List<String> canaryDomestic, @JsonKey(name: 'om')  List<RcxMarker> openMarkers, @JsonKey(name: 'dm')  List<RcxMarker> domesticMarkers, @JsonKey(name: 'bp')  List<String> breakerPatterns, @JsonKey(name: 'dlr')  bool allowDomesticLastResort, @JsonKey(name: 'udp')  bool requireUdp, @JsonKey(name: 'rpk')  bool respectPick, @JsonKey(name: 'dwl')  int dwellSeconds, @JsonKey(name: 'ww')  int waveWidth)?  $default,) {final _that = this;
switch (_that) {
case _RcxConfigParams() when $default != null:
return $default(_that.enabled,_that.preset,_that.strategy,_that.defaultsVersion,_that.censorCountries,_that.canaryForeign,_that.canaryDomestic,_that.openMarkers,_that.domesticMarkers,_that.breakerPatterns,_that.allowDomesticLastResort,_that.requireUdp,_that.respectPick,_that.dwellSeconds,_that.waveWidth);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RcxConfigParams implements RcxConfigParams {
  const _RcxConfigParams({@JsonKey(name: 'on') required this.enabled, @JsonKey(name: 'preset') required this.preset, @JsonKey(name: 'st') required this.strategy, @JsonKey(name: 'dv') required this.defaultsVersion, @JsonKey(name: 'cc') required  List<String> censorCountries, @JsonKey(name: 'cf') required  List<String> canaryForeign, @JsonKey(name: 'cd') required  List<String> canaryDomestic, @JsonKey(name: 'om') required  List<RcxMarker> openMarkers, @JsonKey(name: 'dm') required  List<RcxMarker> domesticMarkers, @JsonKey(name: 'bp') required  List<String> breakerPatterns, @JsonKey(name: 'dlr') required this.allowDomesticLastResort, @JsonKey(name: 'udp') required this.requireUdp, @JsonKey(name: 'rpk') required this.respectPick, @JsonKey(name: 'dwl') required this.dwellSeconds, @JsonKey(name: 'ww') required this.waveWidth}): _censorCountries = censorCountries,_canaryForeign = canaryForeign,_canaryDomestic = canaryDomestic,_openMarkers = openMarkers,_domesticMarkers = domesticMarkers,_breakerPatterns = breakerPatterns;
  factory _RcxConfigParams.fromJson(Map<String, dynamic> json) => _$RcxConfigParamsFromJson(json);

@override@JsonKey(name: 'on') final  bool enabled;
@override@JsonKey(name: 'preset') final  String preset;
@override@JsonKey(name: 'st') final  String strategy;
@override@JsonKey(name: 'dv') final  int defaultsVersion;
 final  List<String> _censorCountries;
@override@JsonKey(name: 'cc') List<String> get censorCountries {
  if (_censorCountries is EqualUnmodifiableListView) return _censorCountries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_censorCountries);
}

 final  List<String> _canaryForeign;
@override@JsonKey(name: 'cf') List<String> get canaryForeign {
  if (_canaryForeign is EqualUnmodifiableListView) return _canaryForeign;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_canaryForeign);
}

 final  List<String> _canaryDomestic;
@override@JsonKey(name: 'cd') List<String> get canaryDomestic {
  if (_canaryDomestic is EqualUnmodifiableListView) return _canaryDomestic;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_canaryDomestic);
}

 final  List<RcxMarker> _openMarkers;
@override@JsonKey(name: 'om') List<RcxMarker> get openMarkers {
  if (_openMarkers is EqualUnmodifiableListView) return _openMarkers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_openMarkers);
}

 final  List<RcxMarker> _domesticMarkers;
@override@JsonKey(name: 'dm') List<RcxMarker> get domesticMarkers {
  if (_domesticMarkers is EqualUnmodifiableListView) return _domesticMarkers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_domesticMarkers);
}

 final  List<String> _breakerPatterns;
@override@JsonKey(name: 'bp') List<String> get breakerPatterns {
  if (_breakerPatterns is EqualUnmodifiableListView) return _breakerPatterns;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_breakerPatterns);
}

@override@JsonKey(name: 'dlr') final  bool allowDomesticLastResort;
@override@JsonKey(name: 'udp') final  bool requireUdp;
@override@JsonKey(name: 'rpk') final  bool respectPick;
@override@JsonKey(name: 'dwl') final  int dwellSeconds;
@override@JsonKey(name: 'ww') final  int waveWidth;

/// Create a copy of RcxConfigParams
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RcxConfigParamsCopyWith<_RcxConfigParams> get copyWith => __$RcxConfigParamsCopyWithImpl<_RcxConfigParams>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RcxConfigParamsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RcxConfigParams&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.preset, preset) || other.preset == preset)&&(identical(other.strategy, strategy) || other.strategy == strategy)&&(identical(other.defaultsVersion, defaultsVersion) || other.defaultsVersion == defaultsVersion)&&const DeepCollectionEquality().equals(other.censorCountries, _censorCountries)&&const DeepCollectionEquality().equals(other.canaryForeign, _canaryForeign)&&const DeepCollectionEquality().equals(other.canaryDomestic, _canaryDomestic)&&const DeepCollectionEquality().equals(other.openMarkers, _openMarkers)&&const DeepCollectionEquality().equals(other.domesticMarkers, _domesticMarkers)&&const DeepCollectionEquality().equals(other.breakerPatterns, _breakerPatterns)&&(identical(other.allowDomesticLastResort, allowDomesticLastResort) || other.allowDomesticLastResort == allowDomesticLastResort)&&(identical(other.requireUdp, requireUdp) || other.requireUdp == requireUdp)&&(identical(other.respectPick, respectPick) || other.respectPick == respectPick)&&(identical(other.dwellSeconds, dwellSeconds) || other.dwellSeconds == dwellSeconds)&&(identical(other.waveWidth, waveWidth) || other.waveWidth == waveWidth));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,enabled,preset,strategy,defaultsVersion,const DeepCollectionEquality().hash(_censorCountries),const DeepCollectionEquality().hash(_canaryForeign),const DeepCollectionEquality().hash(_canaryDomestic),const DeepCollectionEquality().hash(_openMarkers),const DeepCollectionEquality().hash(_domesticMarkers),const DeepCollectionEquality().hash(_breakerPatterns),allowDomesticLastResort,requireUdp,respectPick,dwellSeconds,waveWidth);
}

@override
String toString() {
    return 'RcxConfigParams(enabled: $enabled, preset: $preset, strategy: $strategy, defaultsVersion: $defaultsVersion, censorCountries: $censorCountries, canaryForeign: $canaryForeign, canaryDomestic: $canaryDomestic, openMarkers: $openMarkers, domesticMarkers: $domesticMarkers, breakerPatterns: $breakerPatterns, allowDomesticLastResort: $allowDomesticLastResort, requireUdp: $requireUdp, respectPick: $respectPick, dwellSeconds: $dwellSeconds, waveWidth: $waveWidth)';
}


}

/// @nodoc
abstract mixin class _$RcxConfigParamsCopyWith<$Res> implements $RcxConfigParamsCopyWith<$Res> {
  factory _$RcxConfigParamsCopyWith(_RcxConfigParams value, $Res Function(_RcxConfigParams) _then) = __$RcxConfigParamsCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'on') bool enabled,@JsonKey(name: 'preset') String preset,@JsonKey(name: 'st') String strategy,@JsonKey(name: 'dv') int defaultsVersion,@JsonKey(name: 'cc') List<String> censorCountries,@JsonKey(name: 'cf') List<String> canaryForeign,@JsonKey(name: 'cd') List<String> canaryDomestic,@JsonKey(name: 'om') List<RcxMarker> openMarkers,@JsonKey(name: 'dm') List<RcxMarker> domesticMarkers,@JsonKey(name: 'bp') List<String> breakerPatterns,@JsonKey(name: 'dlr') bool allowDomesticLastResort,@JsonKey(name: 'udp') bool requireUdp,@JsonKey(name: 'rpk') bool respectPick,@JsonKey(name: 'dwl') int dwellSeconds,@JsonKey(name: 'ww') int waveWidth
});




}
/// @nodoc
class __$RcxConfigParamsCopyWithImpl<$Res>
    implements _$RcxConfigParamsCopyWith<$Res> {
  __$RcxConfigParamsCopyWithImpl(this._self, this._then);

  final _RcxConfigParams _self;
  final $Res Function(_RcxConfigParams) _then;

/// Create a copy of RcxConfigParams
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enabled = null,Object? preset = null,Object? strategy = null,Object? defaultsVersion = null,Object? censorCountries = null,Object? canaryForeign = null,Object? canaryDomestic = null,Object? openMarkers = null,Object? domesticMarkers = null,Object? breakerPatterns = null,Object? allowDomesticLastResort = null,Object? requireUdp = null,Object? respectPick = null,Object? dwellSeconds = null,Object? waveWidth = null,}) {
  return _then(_RcxConfigParams(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,preset: null == preset ? _self.preset : preset // ignore: cast_nullable_to_non_nullable
as String,strategy: null == strategy ? _self.strategy : strategy // ignore: cast_nullable_to_non_nullable
as String,defaultsVersion: null == defaultsVersion ? _self.defaultsVersion : defaultsVersion // ignore: cast_nullable_to_non_nullable
as int,censorCountries: null == censorCountries ? _self._censorCountries : censorCountries // ignore: cast_nullable_to_non_nullable
as List<String>,canaryForeign: null == canaryForeign ? _self._canaryForeign : canaryForeign // ignore: cast_nullable_to_non_nullable
as List<String>,canaryDomestic: null == canaryDomestic ? _self._canaryDomestic : canaryDomestic // ignore: cast_nullable_to_non_nullable
as List<String>,openMarkers: null == openMarkers ? _self._openMarkers : openMarkers // ignore: cast_nullable_to_non_nullable
as List<RcxMarker>,domesticMarkers: null == domesticMarkers ? _self._domesticMarkers : domesticMarkers // ignore: cast_nullable_to_non_nullable
as List<RcxMarker>,breakerPatterns: null == breakerPatterns ? _self._breakerPatterns : breakerPatterns // ignore: cast_nullable_to_non_nullable
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
mixin _$RcxStatus {

 bool get enabled; String get preset; String get mode; String get terrain; String get env; String get node; int get delay; String get reason; bool get searching; bool get deep; bool get pinned; String get pinNode; String get direct; int get candidates; int get eligible; int get switchedAt;
/// Create a copy of RcxStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RcxStatusCopyWith<RcxStatus> get copyWith => _$RcxStatusCopyWithImpl<RcxStatus>(this as RcxStatus, _$identity);

  /// Serializes this RcxStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RcxStatus;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RcxStatus&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled)&&(identical(other.preset, _this.preset) || other.preset == _this.preset)&&(identical(other.mode, _this.mode) || other.mode == _this.mode)&&(identical(other.terrain, _this.terrain) || other.terrain == _this.terrain)&&(identical(other.env, _this.env) || other.env == _this.env)&&(identical(other.node, _this.node) || other.node == _this.node)&&(identical(other.delay, _this.delay) || other.delay == _this.delay)&&(identical(other.reason, _this.reason) || other.reason == _this.reason)&&(identical(other.searching, _this.searching) || other.searching == _this.searching)&&(identical(other.deep, _this.deep) || other.deep == _this.deep)&&(identical(other.pinned, _this.pinned) || other.pinned == _this.pinned)&&(identical(other.pinNode, _this.pinNode) || other.pinNode == _this.pinNode)&&(identical(other.direct, _this.direct) || other.direct == _this.direct)&&(identical(other.candidates, _this.candidates) || other.candidates == _this.candidates)&&(identical(other.eligible, _this.eligible) || other.eligible == _this.eligible)&&(identical(other.switchedAt, _this.switchedAt) || other.switchedAt == _this.switchedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RcxStatus;
  return Object.hash(runtimeType,_this.enabled,_this.preset,_this.mode,_this.terrain,_this.env,_this.node,_this.delay,_this.reason,_this.searching,_this.deep,_this.pinned,_this.pinNode,_this.direct,_this.candidates,_this.eligible,_this.switchedAt);
}

@override
String toString() {
  final _this = this as RcxStatus;
  return 'RcxStatus(enabled: ${_this.enabled}, preset: ${_this.preset}, mode: ${_this.mode}, terrain: ${_this.terrain}, env: ${_this.env}, node: ${_this.node}, delay: ${_this.delay}, reason: ${_this.reason}, searching: ${_this.searching}, deep: ${_this.deep}, pinned: ${_this.pinned}, pinNode: ${_this.pinNode}, direct: ${_this.direct}, candidates: ${_this.candidates}, eligible: ${_this.eligible}, switchedAt: ${_this.switchedAt})';
}


}

/// @nodoc
abstract mixin class $RcxStatusCopyWith<$Res>  {
  factory $RcxStatusCopyWith(RcxStatus value, $Res Function(RcxStatus) _then) = _$RcxStatusCopyWithImpl;
@useResult
$Res call({
 bool enabled, String preset, String mode, String terrain, String env, String node, int delay, String reason, bool searching, bool deep, bool pinned, String pinNode, String direct, int candidates, int eligible, int switchedAt
});




}
/// @nodoc
class _$RcxStatusCopyWithImpl<$Res>
    implements $RcxStatusCopyWith<$Res> {
  _$RcxStatusCopyWithImpl(this._self, this._then);

  final RcxStatus _self;
  final $Res Function(RcxStatus) _then;

/// Create a copy of RcxStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enabled = null,Object? preset = null,Object? mode = null,Object? terrain = null,Object? env = null,Object? node = null,Object? delay = null,Object? reason = null,Object? searching = null,Object? deep = null,Object? pinned = null,Object? pinNode = null,Object? direct = null,Object? candidates = null,Object? eligible = null,Object? switchedAt = null,}) {
  return _then(RcxStatus(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,preset: null == preset ? _self.preset : preset // ignore: cast_nullable_to_non_nullable
as String,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as String,terrain: null == terrain ? _self.terrain : terrain // ignore: cast_nullable_to_non_nullable
as String,env: null == env ? _self.env : env // ignore: cast_nullable_to_non_nullable
as String,node: null == node ? _self.node : node // ignore: cast_nullable_to_non_nullable
as String,delay: null == delay ? _self.delay : delay // ignore: cast_nullable_to_non_nullable
as int,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,searching: null == searching ? _self.searching : searching // ignore: cast_nullable_to_non_nullable
as bool,deep: null == deep ? _self.deep : deep // ignore: cast_nullable_to_non_nullable
as bool,pinned: null == pinned ? _self.pinned : pinned // ignore: cast_nullable_to_non_nullable
as bool,pinNode: null == pinNode ? _self.pinNode : pinNode // ignore: cast_nullable_to_non_nullable
as String,direct: null == direct ? _self.direct : direct // ignore: cast_nullable_to_non_nullable
as String,candidates: null == candidates ? _self.candidates : candidates // ignore: cast_nullable_to_non_nullable
as int,eligible: null == eligible ? _self.eligible : eligible // ignore: cast_nullable_to_non_nullable
as int,switchedAt: null == switchedAt ? _self.switchedAt : switchedAt // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RcxStatus].
extension RcxStatusPatterns on RcxStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RcxStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RcxStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RcxStatus value)  $default,){
final _that = this;
switch (_that) {
case _RcxStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RcxStatus value)?  $default,){
final _that = this;
switch (_that) {
case _RcxStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enabled,  String preset,  String mode,  String terrain,  String env,  String node,  int delay,  String reason,  bool searching,  bool deep,  bool pinned,  String pinNode,  String direct,  int candidates,  int eligible,  int switchedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RcxStatus() when $default != null:
return $default(_that.enabled,_that.preset,_that.mode,_that.terrain,_that.env,_that.node,_that.delay,_that.reason,_that.searching,_that.deep,_that.pinned,_that.pinNode,_that.direct,_that.candidates,_that.eligible,_that.switchedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enabled,  String preset,  String mode,  String terrain,  String env,  String node,  int delay,  String reason,  bool searching,  bool deep,  bool pinned,  String pinNode,  String direct,  int candidates,  int eligible,  int switchedAt)  $default,) {final _that = this;
switch (_that) {
case _RcxStatus():
return $default(_that.enabled,_that.preset,_that.mode,_that.terrain,_that.env,_that.node,_that.delay,_that.reason,_that.searching,_that.deep,_that.pinned,_that.pinNode,_that.direct,_that.candidates,_that.eligible,_that.switchedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enabled,  String preset,  String mode,  String terrain,  String env,  String node,  int delay,  String reason,  bool searching,  bool deep,  bool pinned,  String pinNode,  String direct,  int candidates,  int eligible,  int switchedAt)?  $default,) {final _that = this;
switch (_that) {
case _RcxStatus() when $default != null:
return $default(_that.enabled,_that.preset,_that.mode,_that.terrain,_that.env,_that.node,_that.delay,_that.reason,_that.searching,_that.deep,_that.pinned,_that.pinNode,_that.direct,_that.candidates,_that.eligible,_that.switchedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RcxStatus implements RcxStatus {
  const _RcxStatus({this.enabled = false, this.preset = 'off', this.mode = '', this.terrain = 'unknown', this.env = '', this.node = '', this.delay = 0, this.reason = '', this.searching = false, this.deep = false, this.pinned = false, this.pinNode = '', this.direct = '', this.candidates = 0, this.eligible = 0, this.switchedAt = 0});
  factory _RcxStatus.fromJson(Map<String, dynamic> json) => _$RcxStatusFromJson(json);

@override@JsonKey() final  bool enabled;
@override@JsonKey() final  String preset;
@override@JsonKey() final  String mode;
@override@JsonKey() final  String terrain;
@override@JsonKey() final  String env;
@override@JsonKey() final  String node;
@override@JsonKey() final  int delay;
@override@JsonKey() final  String reason;
@override@JsonKey() final  bool searching;
@override@JsonKey() final  bool deep;
@override@JsonKey() final  bool pinned;
@override@JsonKey() final  String pinNode;
@override@JsonKey() final  String direct;
@override@JsonKey() final  int candidates;
@override@JsonKey() final  int eligible;
@override@JsonKey() final  int switchedAt;

/// Create a copy of RcxStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RcxStatusCopyWith<_RcxStatus> get copyWith => __$RcxStatusCopyWithImpl<_RcxStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RcxStatusToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RcxStatus&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.preset, preset) || other.preset == preset)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.terrain, terrain) || other.terrain == terrain)&&(identical(other.env, env) || other.env == env)&&(identical(other.node, node) || other.node == node)&&(identical(other.delay, delay) || other.delay == delay)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.searching, searching) || other.searching == searching)&&(identical(other.deep, deep) || other.deep == deep)&&(identical(other.pinned, pinned) || other.pinned == pinned)&&(identical(other.pinNode, pinNode) || other.pinNode == pinNode)&&(identical(other.direct, direct) || other.direct == direct)&&(identical(other.candidates, candidates) || other.candidates == candidates)&&(identical(other.eligible, eligible) || other.eligible == eligible)&&(identical(other.switchedAt, switchedAt) || other.switchedAt == switchedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,enabled,preset,mode,terrain,env,node,delay,reason,searching,deep,pinned,pinNode,direct,candidates,eligible,switchedAt);
}

@override
String toString() {
    return 'RcxStatus(enabled: $enabled, preset: $preset, mode: $mode, terrain: $terrain, env: $env, node: $node, delay: $delay, reason: $reason, searching: $searching, deep: $deep, pinned: $pinned, pinNode: $pinNode, direct: $direct, candidates: $candidates, eligible: $eligible, switchedAt: $switchedAt)';
}


}

/// @nodoc
abstract mixin class _$RcxStatusCopyWith<$Res> implements $RcxStatusCopyWith<$Res> {
  factory _$RcxStatusCopyWith(_RcxStatus value, $Res Function(_RcxStatus) _then) = __$RcxStatusCopyWithImpl;
@override @useResult
$Res call({
 bool enabled, String preset, String mode, String terrain, String env, String node, int delay, String reason, bool searching, bool deep, bool pinned, String pinNode, String direct, int candidates, int eligible, int switchedAt
});




}
/// @nodoc
class __$RcxStatusCopyWithImpl<$Res>
    implements _$RcxStatusCopyWith<$Res> {
  __$RcxStatusCopyWithImpl(this._self, this._then);

  final _RcxStatus _self;
  final $Res Function(_RcxStatus) _then;

/// Create a copy of RcxStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enabled = null,Object? preset = null,Object? mode = null,Object? terrain = null,Object? env = null,Object? node = null,Object? delay = null,Object? reason = null,Object? searching = null,Object? deep = null,Object? pinned = null,Object? pinNode = null,Object? direct = null,Object? candidates = null,Object? eligible = null,Object? switchedAt = null,}) {
  return _then(_RcxStatus(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,preset: null == preset ? _self.preset : preset // ignore: cast_nullable_to_non_nullable
as String,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as String,terrain: null == terrain ? _self.terrain : terrain // ignore: cast_nullable_to_non_nullable
as String,env: null == env ? _self.env : env // ignore: cast_nullable_to_non_nullable
as String,node: null == node ? _self.node : node // ignore: cast_nullable_to_non_nullable
as String,delay: null == delay ? _self.delay : delay // ignore: cast_nullable_to_non_nullable
as int,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,searching: null == searching ? _self.searching : searching // ignore: cast_nullable_to_non_nullable
as bool,deep: null == deep ? _self.deep : deep // ignore: cast_nullable_to_non_nullable
as bool,pinned: null == pinned ? _self.pinned : pinned // ignore: cast_nullable_to_non_nullable
as bool,pinNode: null == pinNode ? _self.pinNode : pinNode // ignore: cast_nullable_to_non_nullable
as String,direct: null == direct ? _self.direct : direct // ignore: cast_nullable_to_non_nullable
as String,candidates: null == candidates ? _self.candidates : candidates // ignore: cast_nullable_to_non_nullable
as int,eligible: null == eligible ? _self.eligible : eligible // ignore: cast_nullable_to_non_nullable
as int,switchedAt: null == switchedAt ? _self.switchedAt : switchedAt // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$RcxCandidateReport {

 String get node; String get country; String get origin; String get verdict; String get evidence; String get block; int get delay; int get hostDelay; int get band; bool get degraded; bool get breaker; bool get udp; int get fails; int get coolFor; bool get current;
/// Create a copy of RcxCandidateReport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RcxCandidateReportCopyWith<RcxCandidateReport> get copyWith => _$RcxCandidateReportCopyWithImpl<RcxCandidateReport>(this as RcxCandidateReport, _$identity);

  /// Serializes this RcxCandidateReport to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RcxCandidateReport;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RcxCandidateReport&&(identical(other.node, _this.node) || other.node == _this.node)&&(identical(other.country, _this.country) || other.country == _this.country)&&(identical(other.origin, _this.origin) || other.origin == _this.origin)&&(identical(other.verdict, _this.verdict) || other.verdict == _this.verdict)&&(identical(other.evidence, _this.evidence) || other.evidence == _this.evidence)&&(identical(other.block, _this.block) || other.block == _this.block)&&(identical(other.delay, _this.delay) || other.delay == _this.delay)&&(identical(other.hostDelay, _this.hostDelay) || other.hostDelay == _this.hostDelay)&&(identical(other.band, _this.band) || other.band == _this.band)&&(identical(other.degraded, _this.degraded) || other.degraded == _this.degraded)&&(identical(other.breaker, _this.breaker) || other.breaker == _this.breaker)&&(identical(other.udp, _this.udp) || other.udp == _this.udp)&&(identical(other.fails, _this.fails) || other.fails == _this.fails)&&(identical(other.coolFor, _this.coolFor) || other.coolFor == _this.coolFor)&&(identical(other.current, _this.current) || other.current == _this.current));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RcxCandidateReport;
  return Object.hash(runtimeType,_this.node,_this.country,_this.origin,_this.verdict,_this.evidence,_this.block,_this.delay,_this.hostDelay,_this.band,_this.degraded,_this.breaker,_this.udp,_this.fails,_this.coolFor,_this.current);
}

@override
String toString() {
  final _this = this as RcxCandidateReport;
  return 'RcxCandidateReport(node: ${_this.node}, country: ${_this.country}, origin: ${_this.origin}, verdict: ${_this.verdict}, evidence: ${_this.evidence}, block: ${_this.block}, delay: ${_this.delay}, hostDelay: ${_this.hostDelay}, band: ${_this.band}, degraded: ${_this.degraded}, breaker: ${_this.breaker}, udp: ${_this.udp}, fails: ${_this.fails}, coolFor: ${_this.coolFor}, current: ${_this.current})';
}


}

/// @nodoc
abstract mixin class $RcxCandidateReportCopyWith<$Res>  {
  factory $RcxCandidateReportCopyWith(RcxCandidateReport value, $Res Function(RcxCandidateReport) _then) = _$RcxCandidateReportCopyWithImpl;
@useResult
$Res call({
 String node, String country, String origin, String verdict, String evidence, String block, int delay, int hostDelay, int band, bool degraded, bool breaker, bool udp, int fails, int coolFor, bool current
});




}
/// @nodoc
class _$RcxCandidateReportCopyWithImpl<$Res>
    implements $RcxCandidateReportCopyWith<$Res> {
  _$RcxCandidateReportCopyWithImpl(this._self, this._then);

  final RcxCandidateReport _self;
  final $Res Function(RcxCandidateReport) _then;

/// Create a copy of RcxCandidateReport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? node = null,Object? country = null,Object? origin = null,Object? verdict = null,Object? evidence = null,Object? block = null,Object? delay = null,Object? hostDelay = null,Object? band = null,Object? degraded = null,Object? breaker = null,Object? udp = null,Object? fails = null,Object? coolFor = null,Object? current = null,}) {
  return _then(RcxCandidateReport(
node: null == node ? _self.node : node // ignore: cast_nullable_to_non_nullable
as String,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,origin: null == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as String,verdict: null == verdict ? _self.verdict : verdict // ignore: cast_nullable_to_non_nullable
as String,evidence: null == evidence ? _self.evidence : evidence // ignore: cast_nullable_to_non_nullable
as String,block: null == block ? _self.block : block // ignore: cast_nullable_to_non_nullable
as String,delay: null == delay ? _self.delay : delay // ignore: cast_nullable_to_non_nullable
as int,hostDelay: null == hostDelay ? _self.hostDelay : hostDelay // ignore: cast_nullable_to_non_nullable
as int,band: null == band ? _self.band : band // ignore: cast_nullable_to_non_nullable
as int,degraded: null == degraded ? _self.degraded : degraded // ignore: cast_nullable_to_non_nullable
as bool,breaker: null == breaker ? _self.breaker : breaker // ignore: cast_nullable_to_non_nullable
as bool,udp: null == udp ? _self.udp : udp // ignore: cast_nullable_to_non_nullable
as bool,fails: null == fails ? _self.fails : fails // ignore: cast_nullable_to_non_nullable
as int,coolFor: null == coolFor ? _self.coolFor : coolFor // ignore: cast_nullable_to_non_nullable
as int,current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [RcxCandidateReport].
extension RcxCandidateReportPatterns on RcxCandidateReport {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RcxCandidateReport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RcxCandidateReport() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RcxCandidateReport value)  $default,){
final _that = this;
switch (_that) {
case _RcxCandidateReport():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RcxCandidateReport value)?  $default,){
final _that = this;
switch (_that) {
case _RcxCandidateReport() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String node,  String country,  String origin,  String verdict,  String evidence,  String block,  int delay,  int hostDelay,  int band,  bool degraded,  bool breaker,  bool udp,  int fails,  int coolFor,  bool current)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RcxCandidateReport() when $default != null:
return $default(_that.node,_that.country,_that.origin,_that.verdict,_that.evidence,_that.block,_that.delay,_that.hostDelay,_that.band,_that.degraded,_that.breaker,_that.udp,_that.fails,_that.coolFor,_that.current);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String node,  String country,  String origin,  String verdict,  String evidence,  String block,  int delay,  int hostDelay,  int band,  bool degraded,  bool breaker,  bool udp,  int fails,  int coolFor,  bool current)  $default,) {final _that = this;
switch (_that) {
case _RcxCandidateReport():
return $default(_that.node,_that.country,_that.origin,_that.verdict,_that.evidence,_that.block,_that.delay,_that.hostDelay,_that.band,_that.degraded,_that.breaker,_that.udp,_that.fails,_that.coolFor,_that.current);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String node,  String country,  String origin,  String verdict,  String evidence,  String block,  int delay,  int hostDelay,  int band,  bool degraded,  bool breaker,  bool udp,  int fails,  int coolFor,  bool current)?  $default,) {final _that = this;
switch (_that) {
case _RcxCandidateReport() when $default != null:
return $default(_that.node,_that.country,_that.origin,_that.verdict,_that.evidence,_that.block,_that.delay,_that.hostDelay,_that.band,_that.degraded,_that.breaker,_that.udp,_that.fails,_that.coolFor,_that.current);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RcxCandidateReport implements RcxCandidateReport {
  const _RcxCandidateReport({this.node = '', this.country = '', this.origin = 'unknown', this.verdict = 'reject', this.evidence = 'none', this.block = '', this.delay = 0, this.hostDelay = 0, this.band = 0, this.degraded = false, this.breaker = false, this.udp = false, this.fails = 0, this.coolFor = 0, this.current = false});
  factory _RcxCandidateReport.fromJson(Map<String, dynamic> json) => _$RcxCandidateReportFromJson(json);

@override@JsonKey() final  String node;
@override@JsonKey() final  String country;
@override@JsonKey() final  String origin;
@override@JsonKey() final  String verdict;
@override@JsonKey() final  String evidence;
@override@JsonKey() final  String block;
@override@JsonKey() final  int delay;
@override@JsonKey() final  int hostDelay;
@override@JsonKey() final  int band;
@override@JsonKey() final  bool degraded;
@override@JsonKey() final  bool breaker;
@override@JsonKey() final  bool udp;
@override@JsonKey() final  int fails;
@override@JsonKey() final  int coolFor;
@override@JsonKey() final  bool current;

/// Create a copy of RcxCandidateReport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RcxCandidateReportCopyWith<_RcxCandidateReport> get copyWith => __$RcxCandidateReportCopyWithImpl<_RcxCandidateReport>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RcxCandidateReportToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RcxCandidateReport&&(identical(other.node, node) || other.node == node)&&(identical(other.country, country) || other.country == country)&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.verdict, verdict) || other.verdict == verdict)&&(identical(other.evidence, evidence) || other.evidence == evidence)&&(identical(other.block, block) || other.block == block)&&(identical(other.delay, delay) || other.delay == delay)&&(identical(other.hostDelay, hostDelay) || other.hostDelay == hostDelay)&&(identical(other.band, band) || other.band == band)&&(identical(other.degraded, degraded) || other.degraded == degraded)&&(identical(other.breaker, breaker) || other.breaker == breaker)&&(identical(other.udp, udp) || other.udp == udp)&&(identical(other.fails, fails) || other.fails == fails)&&(identical(other.coolFor, coolFor) || other.coolFor == coolFor)&&(identical(other.current, current) || other.current == current));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,node,country,origin,verdict,evidence,block,delay,hostDelay,band,degraded,breaker,udp,fails,coolFor,current);
}

@override
String toString() {
    return 'RcxCandidateReport(node: $node, country: $country, origin: $origin, verdict: $verdict, evidence: $evidence, block: $block, delay: $delay, hostDelay: $hostDelay, band: $band, degraded: $degraded, breaker: $breaker, udp: $udp, fails: $fails, coolFor: $coolFor, current: $current)';
}


}

/// @nodoc
abstract mixin class _$RcxCandidateReportCopyWith<$Res> implements $RcxCandidateReportCopyWith<$Res> {
  factory _$RcxCandidateReportCopyWith(_RcxCandidateReport value, $Res Function(_RcxCandidateReport) _then) = __$RcxCandidateReportCopyWithImpl;
@override @useResult
$Res call({
 String node, String country, String origin, String verdict, String evidence, String block, int delay, int hostDelay, int band, bool degraded, bool breaker, bool udp, int fails, int coolFor, bool current
});




}
/// @nodoc
class __$RcxCandidateReportCopyWithImpl<$Res>
    implements _$RcxCandidateReportCopyWith<$Res> {
  __$RcxCandidateReportCopyWithImpl(this._self, this._then);

  final _RcxCandidateReport _self;
  final $Res Function(_RcxCandidateReport) _then;

/// Create a copy of RcxCandidateReport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? node = null,Object? country = null,Object? origin = null,Object? verdict = null,Object? evidence = null,Object? block = null,Object? delay = null,Object? hostDelay = null,Object? band = null,Object? degraded = null,Object? breaker = null,Object? udp = null,Object? fails = null,Object? coolFor = null,Object? current = null,}) {
  return _then(_RcxCandidateReport(
node: null == node ? _self.node : node // ignore: cast_nullable_to_non_nullable
as String,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,origin: null == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as String,verdict: null == verdict ? _self.verdict : verdict // ignore: cast_nullable_to_non_nullable
as String,evidence: null == evidence ? _self.evidence : evidence // ignore: cast_nullable_to_non_nullable
as String,block: null == block ? _self.block : block // ignore: cast_nullable_to_non_nullable
as String,delay: null == delay ? _self.delay : delay // ignore: cast_nullable_to_non_nullable
as int,hostDelay: null == hostDelay ? _self.hostDelay : hostDelay // ignore: cast_nullable_to_non_nullable
as int,band: null == band ? _self.band : band // ignore: cast_nullable_to_non_nullable
as int,degraded: null == degraded ? _self.degraded : degraded // ignore: cast_nullable_to_non_nullable
as bool,breaker: null == breaker ? _self.breaker : breaker // ignore: cast_nullable_to_non_nullable
as bool,udp: null == udp ? _self.udp : udp // ignore: cast_nullable_to_non_nullable
as bool,fails: null == fails ? _self.fails : fails // ignore: cast_nullable_to_non_nullable
as int,coolFor: null == coolFor ? _self.coolFor : coolFor // ignore: cast_nullable_to_non_nullable
as int,current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$RcxSwitchReport {

 String get from; String get to; String get reason; int get at;
/// Create a copy of RcxSwitchReport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RcxSwitchReportCopyWith<RcxSwitchReport> get copyWith => _$RcxSwitchReportCopyWithImpl<RcxSwitchReport>(this as RcxSwitchReport, _$identity);

  /// Serializes this RcxSwitchReport to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RcxSwitchReport;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RcxSwitchReport&&(identical(other.from, _this.from) || other.from == _this.from)&&(identical(other.to, _this.to) || other.to == _this.to)&&(identical(other.reason, _this.reason) || other.reason == _this.reason)&&(identical(other.at, _this.at) || other.at == _this.at));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RcxSwitchReport;
  return Object.hash(runtimeType,_this.from,_this.to,_this.reason,_this.at);
}

@override
String toString() {
  final _this = this as RcxSwitchReport;
  return 'RcxSwitchReport(from: ${_this.from}, to: ${_this.to}, reason: ${_this.reason}, at: ${_this.at})';
}


}

/// @nodoc
abstract mixin class $RcxSwitchReportCopyWith<$Res>  {
  factory $RcxSwitchReportCopyWith(RcxSwitchReport value, $Res Function(RcxSwitchReport) _then) = _$RcxSwitchReportCopyWithImpl;
@useResult
$Res call({
 String from, String to, String reason, int at
});




}
/// @nodoc
class _$RcxSwitchReportCopyWithImpl<$Res>
    implements $RcxSwitchReportCopyWith<$Res> {
  _$RcxSwitchReportCopyWithImpl(this._self, this._then);

  final RcxSwitchReport _self;
  final $Res Function(RcxSwitchReport) _then;

/// Create a copy of RcxSwitchReport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? from = null,Object? to = null,Object? reason = null,Object? at = null,}) {
  return _then(RcxSwitchReport(
from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as String,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RcxSwitchReport].
extension RcxSwitchReportPatterns on RcxSwitchReport {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RcxSwitchReport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RcxSwitchReport() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RcxSwitchReport value)  $default,){
final _that = this;
switch (_that) {
case _RcxSwitchReport():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RcxSwitchReport value)?  $default,){
final _that = this;
switch (_that) {
case _RcxSwitchReport() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String from,  String to,  String reason,  int at)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RcxSwitchReport() when $default != null:
return $default(_that.from,_that.to,_that.reason,_that.at);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String from,  String to,  String reason,  int at)  $default,) {final _that = this;
switch (_that) {
case _RcxSwitchReport():
return $default(_that.from,_that.to,_that.reason,_that.at);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String from,  String to,  String reason,  int at)?  $default,) {final _that = this;
switch (_that) {
case _RcxSwitchReport() when $default != null:
return $default(_that.from,_that.to,_that.reason,_that.at);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RcxSwitchReport implements RcxSwitchReport {
  const _RcxSwitchReport({this.from = '', this.to = '', this.reason = '', this.at = 0});
  factory _RcxSwitchReport.fromJson(Map<String, dynamic> json) => _$RcxSwitchReportFromJson(json);

@override@JsonKey() final  String from;
@override@JsonKey() final  String to;
@override@JsonKey() final  String reason;
@override@JsonKey() final  int at;

/// Create a copy of RcxSwitchReport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RcxSwitchReportCopyWith<_RcxSwitchReport> get copyWith => __$RcxSwitchReportCopyWithImpl<_RcxSwitchReport>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RcxSwitchReportToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RcxSwitchReport&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.at, at) || other.at == at));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,from,to,reason,at);
}

@override
String toString() {
    return 'RcxSwitchReport(from: $from, to: $to, reason: $reason, at: $at)';
}


}

/// @nodoc
abstract mixin class _$RcxSwitchReportCopyWith<$Res> implements $RcxSwitchReportCopyWith<$Res> {
  factory _$RcxSwitchReportCopyWith(_RcxSwitchReport value, $Res Function(_RcxSwitchReport) _then) = __$RcxSwitchReportCopyWithImpl;
@override @useResult
$Res call({
 String from, String to, String reason, int at
});




}
/// @nodoc
class __$RcxSwitchReportCopyWithImpl<$Res>
    implements _$RcxSwitchReportCopyWith<$Res> {
  __$RcxSwitchReportCopyWithImpl(this._self, this._then);

  final _RcxSwitchReport _self;
  final $Res Function(_RcxSwitchReport) _then;

/// Create a copy of RcxSwitchReport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? from = null,Object? to = null,Object? reason = null,Object? at = null,}) {
  return _then(_RcxSwitchReport(
from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as String,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$RcxCanaryReport {

 String get addr; bool get domestic; String get outcome; int get delay;
/// Create a copy of RcxCanaryReport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RcxCanaryReportCopyWith<RcxCanaryReport> get copyWith => _$RcxCanaryReportCopyWithImpl<RcxCanaryReport>(this as RcxCanaryReport, _$identity);

  /// Serializes this RcxCanaryReport to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RcxCanaryReport;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RcxCanaryReport&&(identical(other.addr, _this.addr) || other.addr == _this.addr)&&(identical(other.domestic, _this.domestic) || other.domestic == _this.domestic)&&(identical(other.outcome, _this.outcome) || other.outcome == _this.outcome)&&(identical(other.delay, _this.delay) || other.delay == _this.delay));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RcxCanaryReport;
  return Object.hash(runtimeType,_this.addr,_this.domestic,_this.outcome,_this.delay);
}

@override
String toString() {
  final _this = this as RcxCanaryReport;
  return 'RcxCanaryReport(addr: ${_this.addr}, domestic: ${_this.domestic}, outcome: ${_this.outcome}, delay: ${_this.delay})';
}


}

/// @nodoc
abstract mixin class $RcxCanaryReportCopyWith<$Res>  {
  factory $RcxCanaryReportCopyWith(RcxCanaryReport value, $Res Function(RcxCanaryReport) _then) = _$RcxCanaryReportCopyWithImpl;
@useResult
$Res call({
 String addr, bool domestic, String outcome, int delay
});




}
/// @nodoc
class _$RcxCanaryReportCopyWithImpl<$Res>
    implements $RcxCanaryReportCopyWith<$Res> {
  _$RcxCanaryReportCopyWithImpl(this._self, this._then);

  final RcxCanaryReport _self;
  final $Res Function(RcxCanaryReport) _then;

/// Create a copy of RcxCanaryReport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? addr = null,Object? domestic = null,Object? outcome = null,Object? delay = null,}) {
  return _then(RcxCanaryReport(
addr: null == addr ? _self.addr : addr // ignore: cast_nullable_to_non_nullable
as String,domestic: null == domestic ? _self.domestic : domestic // ignore: cast_nullable_to_non_nullable
as bool,outcome: null == outcome ? _self.outcome : outcome // ignore: cast_nullable_to_non_nullable
as String,delay: null == delay ? _self.delay : delay // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RcxCanaryReport].
extension RcxCanaryReportPatterns on RcxCanaryReport {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RcxCanaryReport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RcxCanaryReport() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RcxCanaryReport value)  $default,){
final _that = this;
switch (_that) {
case _RcxCanaryReport():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RcxCanaryReport value)?  $default,){
final _that = this;
switch (_that) {
case _RcxCanaryReport() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String addr,  bool domestic,  String outcome,  int delay)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RcxCanaryReport() when $default != null:
return $default(_that.addr,_that.domestic,_that.outcome,_that.delay);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String addr,  bool domestic,  String outcome,  int delay)  $default,) {final _that = this;
switch (_that) {
case _RcxCanaryReport():
return $default(_that.addr,_that.domestic,_that.outcome,_that.delay);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String addr,  bool domestic,  String outcome,  int delay)?  $default,) {final _that = this;
switch (_that) {
case _RcxCanaryReport() when $default != null:
return $default(_that.addr,_that.domestic,_that.outcome,_that.delay);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RcxCanaryReport implements RcxCanaryReport {
  const _RcxCanaryReport({this.addr = '', this.domestic = false, this.outcome = 'unknown', this.delay = 0});
  factory _RcxCanaryReport.fromJson(Map<String, dynamic> json) => _$RcxCanaryReportFromJson(json);

@override@JsonKey() final  String addr;
@override@JsonKey() final  bool domestic;
@override@JsonKey() final  String outcome;
@override@JsonKey() final  int delay;

/// Create a copy of RcxCanaryReport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RcxCanaryReportCopyWith<_RcxCanaryReport> get copyWith => __$RcxCanaryReportCopyWithImpl<_RcxCanaryReport>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RcxCanaryReportToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RcxCanaryReport&&(identical(other.addr, addr) || other.addr == addr)&&(identical(other.domestic, domestic) || other.domestic == domestic)&&(identical(other.outcome, outcome) || other.outcome == outcome)&&(identical(other.delay, delay) || other.delay == delay));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,addr,domestic,outcome,delay);
}

@override
String toString() {
    return 'RcxCanaryReport(addr: $addr, domestic: $domestic, outcome: $outcome, delay: $delay)';
}


}

/// @nodoc
abstract mixin class _$RcxCanaryReportCopyWith<$Res> implements $RcxCanaryReportCopyWith<$Res> {
  factory _$RcxCanaryReportCopyWith(_RcxCanaryReport value, $Res Function(_RcxCanaryReport) _then) = __$RcxCanaryReportCopyWithImpl;
@override @useResult
$Res call({
 String addr, bool domestic, String outcome, int delay
});




}
/// @nodoc
class __$RcxCanaryReportCopyWithImpl<$Res>
    implements _$RcxCanaryReportCopyWith<$Res> {
  __$RcxCanaryReportCopyWithImpl(this._self, this._then);

  final _RcxCanaryReport _self;
  final $Res Function(_RcxCanaryReport) _then;

/// Create a copy of RcxCanaryReport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? addr = null,Object? domestic = null,Object? outcome = null,Object? delay = null,}) {
  return _then(_RcxCanaryReport(
addr: null == addr ? _self.addr : addr // ignore: cast_nullable_to_non_nullable
as String,domestic: null == domestic ? _self.domestic : domestic // ignore: cast_nullable_to_non_nullable
as bool,outcome: null == outcome ? _self.outcome : outcome // ignore: cast_nullable_to_non_nullable
as String,delay: null == delay ? _self.delay : delay // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$RcxLinkReport {

 String get transport; bool get validated; bool get portal; bool get metered; String get foreign; String get domestic; int get since;
/// Create a copy of RcxLinkReport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RcxLinkReportCopyWith<RcxLinkReport> get copyWith => _$RcxLinkReportCopyWithImpl<RcxLinkReport>(this as RcxLinkReport, _$identity);

  /// Serializes this RcxLinkReport to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RcxLinkReport;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RcxLinkReport&&(identical(other.transport, _this.transport) || other.transport == _this.transport)&&(identical(other.validated, _this.validated) || other.validated == _this.validated)&&(identical(other.portal, _this.portal) || other.portal == _this.portal)&&(identical(other.metered, _this.metered) || other.metered == _this.metered)&&(identical(other.foreign, _this.foreign) || other.foreign == _this.foreign)&&(identical(other.domestic, _this.domestic) || other.domestic == _this.domestic)&&(identical(other.since, _this.since) || other.since == _this.since));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RcxLinkReport;
  return Object.hash(runtimeType,_this.transport,_this.validated,_this.portal,_this.metered,_this.foreign,_this.domestic,_this.since);
}

@override
String toString() {
  final _this = this as RcxLinkReport;
  return 'RcxLinkReport(transport: ${_this.transport}, validated: ${_this.validated}, portal: ${_this.portal}, metered: ${_this.metered}, foreign: ${_this.foreign}, domestic: ${_this.domestic}, since: ${_this.since})';
}


}

/// @nodoc
abstract mixin class $RcxLinkReportCopyWith<$Res>  {
  factory $RcxLinkReportCopyWith(RcxLinkReport value, $Res Function(RcxLinkReport) _then) = _$RcxLinkReportCopyWithImpl;
@useResult
$Res call({
 String transport, bool validated, bool portal, bool metered, String foreign, String domestic, int since
});




}
/// @nodoc
class _$RcxLinkReportCopyWithImpl<$Res>
    implements $RcxLinkReportCopyWith<$Res> {
  _$RcxLinkReportCopyWithImpl(this._self, this._then);

  final RcxLinkReport _self;
  final $Res Function(RcxLinkReport) _then;

/// Create a copy of RcxLinkReport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? transport = null,Object? validated = null,Object? portal = null,Object? metered = null,Object? foreign = null,Object? domestic = null,Object? since = null,}) {
  return _then(RcxLinkReport(
transport: null == transport ? _self.transport : transport // ignore: cast_nullable_to_non_nullable
as String,validated: null == validated ? _self.validated : validated // ignore: cast_nullable_to_non_nullable
as bool,portal: null == portal ? _self.portal : portal // ignore: cast_nullable_to_non_nullable
as bool,metered: null == metered ? _self.metered : metered // ignore: cast_nullable_to_non_nullable
as bool,foreign: null == foreign ? _self.foreign : foreign // ignore: cast_nullable_to_non_nullable
as String,domestic: null == domestic ? _self.domestic : domestic // ignore: cast_nullable_to_non_nullable
as String,since: null == since ? _self.since : since // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RcxLinkReport].
extension RcxLinkReportPatterns on RcxLinkReport {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RcxLinkReport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RcxLinkReport() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RcxLinkReport value)  $default,){
final _that = this;
switch (_that) {
case _RcxLinkReport():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RcxLinkReport value)?  $default,){
final _that = this;
switch (_that) {
case _RcxLinkReport() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String transport,  bool validated,  bool portal,  bool metered,  String foreign,  String domestic,  int since)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RcxLinkReport() when $default != null:
return $default(_that.transport,_that.validated,_that.portal,_that.metered,_that.foreign,_that.domestic,_that.since);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String transport,  bool validated,  bool portal,  bool metered,  String foreign,  String domestic,  int since)  $default,) {final _that = this;
switch (_that) {
case _RcxLinkReport():
return $default(_that.transport,_that.validated,_that.portal,_that.metered,_that.foreign,_that.domestic,_that.since);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String transport,  bool validated,  bool portal,  bool metered,  String foreign,  String domestic,  int since)?  $default,) {final _that = this;
switch (_that) {
case _RcxLinkReport() when $default != null:
return $default(_that.transport,_that.validated,_that.portal,_that.metered,_that.foreign,_that.domestic,_that.since);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RcxLinkReport implements RcxLinkReport {
  const _RcxLinkReport({this.transport = '', this.validated = false, this.portal = false, this.metered = false, this.foreign = 'unknown', this.domestic = 'unknown', this.since = 0});
  factory _RcxLinkReport.fromJson(Map<String, dynamic> json) => _$RcxLinkReportFromJson(json);

@override@JsonKey() final  String transport;
@override@JsonKey() final  bool validated;
@override@JsonKey() final  bool portal;
@override@JsonKey() final  bool metered;
@override@JsonKey() final  String foreign;
@override@JsonKey() final  String domestic;
@override@JsonKey() final  int since;

/// Create a copy of RcxLinkReport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RcxLinkReportCopyWith<_RcxLinkReport> get copyWith => __$RcxLinkReportCopyWithImpl<_RcxLinkReport>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RcxLinkReportToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RcxLinkReport&&(identical(other.transport, transport) || other.transport == transport)&&(identical(other.validated, validated) || other.validated == validated)&&(identical(other.portal, portal) || other.portal == portal)&&(identical(other.metered, metered) || other.metered == metered)&&(identical(other.foreign, foreign) || other.foreign == foreign)&&(identical(other.domestic, domestic) || other.domestic == domestic)&&(identical(other.since, since) || other.since == since));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,transport,validated,portal,metered,foreign,domestic,since);
}

@override
String toString() {
    return 'RcxLinkReport(transport: $transport, validated: $validated, portal: $portal, metered: $metered, foreign: $foreign, domestic: $domestic, since: $since)';
}


}

/// @nodoc
abstract mixin class _$RcxLinkReportCopyWith<$Res> implements $RcxLinkReportCopyWith<$Res> {
  factory _$RcxLinkReportCopyWith(_RcxLinkReport value, $Res Function(_RcxLinkReport) _then) = __$RcxLinkReportCopyWithImpl;
@override @useResult
$Res call({
 String transport, bool validated, bool portal, bool metered, String foreign, String domestic, int since
});




}
/// @nodoc
class __$RcxLinkReportCopyWithImpl<$Res>
    implements _$RcxLinkReportCopyWith<$Res> {
  __$RcxLinkReportCopyWithImpl(this._self, this._then);

  final _RcxLinkReport _self;
  final $Res Function(_RcxLinkReport) _then;

/// Create a copy of RcxLinkReport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? transport = null,Object? validated = null,Object? portal = null,Object? metered = null,Object? foreign = null,Object? domestic = null,Object? since = null,}) {
  return _then(_RcxLinkReport(
transport: null == transport ? _self.transport : transport // ignore: cast_nullable_to_non_nullable
as String,validated: null == validated ? _self.validated : validated // ignore: cast_nullable_to_non_nullable
as bool,portal: null == portal ? _self.portal : portal // ignore: cast_nullable_to_non_nullable
as bool,metered: null == metered ? _self.metered : metered // ignore: cast_nullable_to_non_nullable
as bool,foreign: null == foreign ? _self.foreign : foreign // ignore: cast_nullable_to_non_nullable
as String,domestic: null == domestic ? _self.domestic : domestic // ignore: cast_nullable_to_non_nullable
as String,since: null == since ? _self.since : since // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$RcxReport {

 RcxStatus get status; RcxLinkReport get link; List<RcxCanaryReport> get canaries; List<RcxCandidateReport> get candidates; List<RcxSwitchReport> get history; List<int> get bands; int get probesLeft; int get probeCap; bool get manual; int get at;
/// Create a copy of RcxReport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RcxReportCopyWith<RcxReport> get copyWith => _$RcxReportCopyWithImpl<RcxReport>(this as RcxReport, _$identity);

  /// Serializes this RcxReport to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RcxReport;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RcxReport&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.link, _this.link) || other.link == _this.link)&&const DeepCollectionEquality().equals(other.canaries, _this.canaries)&&const DeepCollectionEquality().equals(other.candidates, _this.candidates)&&const DeepCollectionEquality().equals(other.history, _this.history)&&const DeepCollectionEquality().equals(other.bands, _this.bands)&&(identical(other.probesLeft, _this.probesLeft) || other.probesLeft == _this.probesLeft)&&(identical(other.probeCap, _this.probeCap) || other.probeCap == _this.probeCap)&&(identical(other.manual, _this.manual) || other.manual == _this.manual)&&(identical(other.at, _this.at) || other.at == _this.at));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RcxReport;
  return Object.hash(runtimeType,_this.status,_this.link,const DeepCollectionEquality().hash(_this.canaries),const DeepCollectionEquality().hash(_this.candidates),const DeepCollectionEquality().hash(_this.history),const DeepCollectionEquality().hash(_this.bands),_this.probesLeft,_this.probeCap,_this.manual,_this.at);
}

@override
String toString() {
  final _this = this as RcxReport;
  return 'RcxReport(status: ${_this.status}, link: ${_this.link}, canaries: ${_this.canaries}, candidates: ${_this.candidates}, history: ${_this.history}, bands: ${_this.bands}, probesLeft: ${_this.probesLeft}, probeCap: ${_this.probeCap}, manual: ${_this.manual}, at: ${_this.at})';
}


}

/// @nodoc
abstract mixin class $RcxReportCopyWith<$Res>  {
  factory $RcxReportCopyWith(RcxReport value, $Res Function(RcxReport) _then) = _$RcxReportCopyWithImpl;
@useResult
$Res call({
 RcxStatus status, RcxLinkReport link, List<RcxCanaryReport> canaries, List<RcxCandidateReport> candidates, List<RcxSwitchReport> history, List<int> bands, int probesLeft, int probeCap, bool manual, int at
});


$RcxStatusCopyWith<$Res> get status;$RcxLinkReportCopyWith<$Res> get link;

}
/// @nodoc
class _$RcxReportCopyWithImpl<$Res>
    implements $RcxReportCopyWith<$Res> {
  _$RcxReportCopyWithImpl(this._self, this._then);

  final RcxReport _self;
  final $Res Function(RcxReport) _then;

/// Create a copy of RcxReport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? link = null,Object? canaries = null,Object? candidates = null,Object? history = null,Object? bands = null,Object? probesLeft = null,Object? probeCap = null,Object? manual = null,Object? at = null,}) {
  return _then(RcxReport(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RcxStatus,link: null == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as RcxLinkReport,canaries: null == canaries ? _self.canaries : canaries // ignore: cast_nullable_to_non_nullable
as List<RcxCanaryReport>,candidates: null == candidates ? _self.candidates : candidates // ignore: cast_nullable_to_non_nullable
as List<RcxCandidateReport>,history: null == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as List<RcxSwitchReport>,bands: null == bands ? _self.bands : bands // ignore: cast_nullable_to_non_nullable
as List<int>,probesLeft: null == probesLeft ? _self.probesLeft : probesLeft // ignore: cast_nullable_to_non_nullable
as int,probeCap: null == probeCap ? _self.probeCap : probeCap // ignore: cast_nullable_to_non_nullable
as int,manual: null == manual ? _self.manual : manual // ignore: cast_nullable_to_non_nullable
as bool,at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of RcxReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RcxStatusCopyWith<$Res> get status {
  
  return $RcxStatusCopyWith<$Res>(_self.status, (value) {
    return _then(_self.copyWith(status: value));
  });
}/// Create a copy of RcxReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RcxLinkReportCopyWith<$Res> get link {
  
  return $RcxLinkReportCopyWith<$Res>(_self.link, (value) {
    return _then(_self.copyWith(link: value));
  });
}
}


/// Adds pattern-matching-related methods to [RcxReport].
extension RcxReportPatterns on RcxReport {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RcxReport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RcxReport() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RcxReport value)  $default,){
final _that = this;
switch (_that) {
case _RcxReport():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RcxReport value)?  $default,){
final _that = this;
switch (_that) {
case _RcxReport() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RcxStatus status,  RcxLinkReport link,  List<RcxCanaryReport> canaries,  List<RcxCandidateReport> candidates,  List<RcxSwitchReport> history,  List<int> bands,  int probesLeft,  int probeCap,  bool manual,  int at)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RcxReport() when $default != null:
return $default(_that.status,_that.link,_that.canaries,_that.candidates,_that.history,_that.bands,_that.probesLeft,_that.probeCap,_that.manual,_that.at);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RcxStatus status,  RcxLinkReport link,  List<RcxCanaryReport> canaries,  List<RcxCandidateReport> candidates,  List<RcxSwitchReport> history,  List<int> bands,  int probesLeft,  int probeCap,  bool manual,  int at)  $default,) {final _that = this;
switch (_that) {
case _RcxReport():
return $default(_that.status,_that.link,_that.canaries,_that.candidates,_that.history,_that.bands,_that.probesLeft,_that.probeCap,_that.manual,_that.at);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RcxStatus status,  RcxLinkReport link,  List<RcxCanaryReport> canaries,  List<RcxCandidateReport> candidates,  List<RcxSwitchReport> history,  List<int> bands,  int probesLeft,  int probeCap,  bool manual,  int at)?  $default,) {final _that = this;
switch (_that) {
case _RcxReport() when $default != null:
return $default(_that.status,_that.link,_that.canaries,_that.candidates,_that.history,_that.bands,_that.probesLeft,_that.probeCap,_that.manual,_that.at);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RcxReport implements RcxReport {
  const _RcxReport({this.status = const RcxStatus(), this.link = const RcxLinkReport(),  List<RcxCanaryReport> canaries = const [],  List<RcxCandidateReport> candidates = const [],  List<RcxSwitchReport> history = const [],  List<int> bands = const [], this.probesLeft = 0, this.probeCap = 0, this.manual = false, this.at = 0}): _canaries = canaries,_candidates = candidates,_history = history,_bands = bands;
  factory _RcxReport.fromJson(Map<String, dynamic> json) => _$RcxReportFromJson(json);

@override@JsonKey() final  RcxStatus status;
@override@JsonKey() final  RcxLinkReport link;
 final  List<RcxCanaryReport> _canaries;
@override@JsonKey() List<RcxCanaryReport> get canaries {
  if (_canaries is EqualUnmodifiableListView) return _canaries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_canaries);
}

 final  List<RcxCandidateReport> _candidates;
@override@JsonKey() List<RcxCandidateReport> get candidates {
  if (_candidates is EqualUnmodifiableListView) return _candidates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_candidates);
}

 final  List<RcxSwitchReport> _history;
@override@JsonKey() List<RcxSwitchReport> get history {
  if (_history is EqualUnmodifiableListView) return _history;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_history);
}

 final  List<int> _bands;
@override@JsonKey() List<int> get bands {
  if (_bands is EqualUnmodifiableListView) return _bands;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bands);
}

@override@JsonKey() final  int probesLeft;
@override@JsonKey() final  int probeCap;
@override@JsonKey() final  bool manual;
@override@JsonKey() final  int at;

/// Create a copy of RcxReport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RcxReportCopyWith<_RcxReport> get copyWith => __$RcxReportCopyWithImpl<_RcxReport>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RcxReportToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RcxReport&&(identical(other.status, status) || other.status == status)&&(identical(other.link, link) || other.link == link)&&const DeepCollectionEquality().equals(other.canaries, _canaries)&&const DeepCollectionEquality().equals(other.candidates, _candidates)&&const DeepCollectionEquality().equals(other.history, _history)&&const DeepCollectionEquality().equals(other.bands, _bands)&&(identical(other.probesLeft, probesLeft) || other.probesLeft == probesLeft)&&(identical(other.probeCap, probeCap) || other.probeCap == probeCap)&&(identical(other.manual, manual) || other.manual == manual)&&(identical(other.at, at) || other.at == at));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,status,link,const DeepCollectionEquality().hash(_canaries),const DeepCollectionEquality().hash(_candidates),const DeepCollectionEquality().hash(_history),const DeepCollectionEquality().hash(_bands),probesLeft,probeCap,manual,at);
}

@override
String toString() {
    return 'RcxReport(status: $status, link: $link, canaries: $canaries, candidates: $candidates, history: $history, bands: $bands, probesLeft: $probesLeft, probeCap: $probeCap, manual: $manual, at: $at)';
}


}

/// @nodoc
abstract mixin class _$RcxReportCopyWith<$Res> implements $RcxReportCopyWith<$Res> {
  factory _$RcxReportCopyWith(_RcxReport value, $Res Function(_RcxReport) _then) = __$RcxReportCopyWithImpl;
@override @useResult
$Res call({
 RcxStatus status, RcxLinkReport link, List<RcxCanaryReport> canaries, List<RcxCandidateReport> candidates, List<RcxSwitchReport> history, List<int> bands, int probesLeft, int probeCap, bool manual, int at
});


@override $RcxStatusCopyWith<$Res> get status;@override $RcxLinkReportCopyWith<$Res> get link;

}
/// @nodoc
class __$RcxReportCopyWithImpl<$Res>
    implements _$RcxReportCopyWith<$Res> {
  __$RcxReportCopyWithImpl(this._self, this._then);

  final _RcxReport _self;
  final $Res Function(_RcxReport) _then;

/// Create a copy of RcxReport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? link = null,Object? canaries = null,Object? candidates = null,Object? history = null,Object? bands = null,Object? probesLeft = null,Object? probeCap = null,Object? manual = null,Object? at = null,}) {
  return _then(_RcxReport(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RcxStatus,link: null == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as RcxLinkReport,canaries: null == canaries ? _self._canaries : canaries // ignore: cast_nullable_to_non_nullable
as List<RcxCanaryReport>,candidates: null == candidates ? _self._candidates : candidates // ignore: cast_nullable_to_non_nullable
as List<RcxCandidateReport>,history: null == history ? _self._history : history // ignore: cast_nullable_to_non_nullable
as List<RcxSwitchReport>,bands: null == bands ? _self._bands : bands // ignore: cast_nullable_to_non_nullable
as List<int>,probesLeft: null == probesLeft ? _self.probesLeft : probesLeft // ignore: cast_nullable_to_non_nullable
as int,probeCap: null == probeCap ? _self.probeCap : probeCap // ignore: cast_nullable_to_non_nullable
as int,manual: null == manual ? _self.manual : manual // ignore: cast_nullable_to_non_nullable
as bool,at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of RcxReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RcxStatusCopyWith<$Res> get status {
  
  return $RcxStatusCopyWith<$Res>(_self.status, (value) {
    return _then(_self.copyWith(status: value));
  });
}/// Create a copy of RcxReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RcxLinkReportCopyWith<$Res> get link {
  
  return $RcxLinkReportCopyWith<$Res>(_self.link, (value) {
    return _then(_self.copyWith(link: value));
  });
}
}

// dart format on
