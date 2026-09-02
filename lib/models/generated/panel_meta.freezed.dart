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

 bool get hwidMaxDevicesReached; bool get hwidNotSupported; String? get announce; String? get supportUrl; int? get updateIntervalMinutes;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PanelMeta&&(identical(other.hwidMaxDevicesReached, _this.hwidMaxDevicesReached) || other.hwidMaxDevicesReached == _this.hwidMaxDevicesReached)&&(identical(other.hwidNotSupported, _this.hwidNotSupported) || other.hwidNotSupported == _this.hwidNotSupported)&&(identical(other.announce, _this.announce) || other.announce == _this.announce)&&(identical(other.supportUrl, _this.supportUrl) || other.supportUrl == _this.supportUrl)&&(identical(other.updateIntervalMinutes, _this.updateIntervalMinutes) || other.updateIntervalMinutes == _this.updateIntervalMinutes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PanelMeta;
  return Object.hash(runtimeType,_this.hwidMaxDevicesReached,_this.hwidNotSupported,_this.announce,_this.supportUrl,_this.updateIntervalMinutes);
}

@override
String toString() {
  final _this = this as PanelMeta;
  return 'PanelMeta(hwidMaxDevicesReached: ${_this.hwidMaxDevicesReached}, hwidNotSupported: ${_this.hwidNotSupported}, announce: ${_this.announce}, supportUrl: ${_this.supportUrl}, updateIntervalMinutes: ${_this.updateIntervalMinutes})';
}


}

/// @nodoc
abstract mixin class $PanelMetaCopyWith<$Res>  {
  factory $PanelMetaCopyWith(PanelMeta value, $Res Function(PanelMeta) _then) = _$PanelMetaCopyWithImpl;
@useResult
$Res call({
 bool hwidMaxDevicesReached, bool hwidNotSupported, String? announce, String? supportUrl, int? updateIntervalMinutes
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
@pragma('vm:prefer-inline') @override $Res call({Object? hwidMaxDevicesReached = null,Object? hwidNotSupported = null,Object? announce = freezed,Object? supportUrl = freezed,Object? updateIntervalMinutes = freezed,}) {
  return _then(PanelMeta(
hwidMaxDevicesReached: null == hwidMaxDevicesReached ? _self.hwidMaxDevicesReached : hwidMaxDevicesReached // ignore: cast_nullable_to_non_nullable
as bool,hwidNotSupported: null == hwidNotSupported ? _self.hwidNotSupported : hwidNotSupported // ignore: cast_nullable_to_non_nullable
as bool,announce: freezed == announce ? _self.announce : announce // ignore: cast_nullable_to_non_nullable
as String?,supportUrl: freezed == supportUrl ? _self.supportUrl : supportUrl // ignore: cast_nullable_to_non_nullable
as String?,updateIntervalMinutes: freezed == updateIntervalMinutes ? _self.updateIntervalMinutes : updateIntervalMinutes // ignore: cast_nullable_to_non_nullable
as int?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool hwidMaxDevicesReached,  bool hwidNotSupported,  String? announce,  String? supportUrl,  int? updateIntervalMinutes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PanelMeta() when $default != null:
return $default(_that.hwidMaxDevicesReached,_that.hwidNotSupported,_that.announce,_that.supportUrl,_that.updateIntervalMinutes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool hwidMaxDevicesReached,  bool hwidNotSupported,  String? announce,  String? supportUrl,  int? updateIntervalMinutes)  $default,) {final _that = this;
switch (_that) {
case _PanelMeta():
return $default(_that.hwidMaxDevicesReached,_that.hwidNotSupported,_that.announce,_that.supportUrl,_that.updateIntervalMinutes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool hwidMaxDevicesReached,  bool hwidNotSupported,  String? announce,  String? supportUrl,  int? updateIntervalMinutes)?  $default,) {final _that = this;
switch (_that) {
case _PanelMeta() when $default != null:
return $default(_that.hwidMaxDevicesReached,_that.hwidNotSupported,_that.announce,_that.supportUrl,_that.updateIntervalMinutes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PanelMeta implements PanelMeta {
  const _PanelMeta({this.hwidMaxDevicesReached = false, this.hwidNotSupported = false, this.announce, this.supportUrl, this.updateIntervalMinutes});
  factory _PanelMeta.fromJson(Map<String, dynamic> json) => _$PanelMetaFromJson(json);

@override@JsonKey() final  bool hwidMaxDevicesReached;
@override@JsonKey() final  bool hwidNotSupported;
@override final  String? announce;
@override final  String? supportUrl;
@override final  int? updateIntervalMinutes;

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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PanelMeta&&(identical(other.hwidMaxDevicesReached, hwidMaxDevicesReached) || other.hwidMaxDevicesReached == hwidMaxDevicesReached)&&(identical(other.hwidNotSupported, hwidNotSupported) || other.hwidNotSupported == hwidNotSupported)&&(identical(other.announce, announce) || other.announce == announce)&&(identical(other.supportUrl, supportUrl) || other.supportUrl == supportUrl)&&(identical(other.updateIntervalMinutes, updateIntervalMinutes) || other.updateIntervalMinutes == updateIntervalMinutes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,hwidMaxDevicesReached,hwidNotSupported,announce,supportUrl,updateIntervalMinutes);
}

@override
String toString() {
    return 'PanelMeta(hwidMaxDevicesReached: $hwidMaxDevicesReached, hwidNotSupported: $hwidNotSupported, announce: $announce, supportUrl: $supportUrl, updateIntervalMinutes: $updateIntervalMinutes)';
}


}

/// @nodoc
abstract mixin class _$PanelMetaCopyWith<$Res> implements $PanelMetaCopyWith<$Res> {
  factory _$PanelMetaCopyWith(_PanelMeta value, $Res Function(_PanelMeta) _then) = __$PanelMetaCopyWithImpl;
@override @useResult
$Res call({
 bool hwidMaxDevicesReached, bool hwidNotSupported, String? announce, String? supportUrl, int? updateIntervalMinutes
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
@override @pragma('vm:prefer-inline') $Res call({Object? hwidMaxDevicesReached = null,Object? hwidNotSupported = null,Object? announce = freezed,Object? supportUrl = freezed,Object? updateIntervalMinutes = freezed,}) {
  return _then(_PanelMeta(
hwidMaxDevicesReached: null == hwidMaxDevicesReached ? _self.hwidMaxDevicesReached : hwidMaxDevicesReached // ignore: cast_nullable_to_non_nullable
as bool,hwidNotSupported: null == hwidNotSupported ? _self.hwidNotSupported : hwidNotSupported // ignore: cast_nullable_to_non_nullable
as bool,announce: freezed == announce ? _self.announce : announce // ignore: cast_nullable_to_non_nullable
as String?,supportUrl: freezed == supportUrl ? _self.supportUrl : supportUrl // ignore: cast_nullable_to_non_nullable
as String?,updateIntervalMinutes: freezed == updateIntervalMinutes ? _self.updateIntervalMinutes : updateIntervalMinutes // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
