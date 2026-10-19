// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../wallpaper.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WallpaperProps {

 bool get enabled; String? get fileName; List<String> get library; WallpaperFit get fit; double get scale; double get positionX; double get positionY; double get opacity; double get dimming; double get blur; double get cardOpacity;
/// Create a copy of WallpaperProps
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WallpaperPropsCopyWith<WallpaperProps> get copyWith => _$WallpaperPropsCopyWithImpl<WallpaperProps>(this as WallpaperProps, _$identity);

  /// Serializes this WallpaperProps to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as WallpaperProps;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WallpaperProps&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled)&&(identical(other.fileName, _this.fileName) || other.fileName == _this.fileName)&&const DeepCollectionEquality().equals(other.library, _this.library)&&(identical(other.fit, _this.fit) || other.fit == _this.fit)&&(identical(other.scale, _this.scale) || other.scale == _this.scale)&&(identical(other.positionX, _this.positionX) || other.positionX == _this.positionX)&&(identical(other.positionY, _this.positionY) || other.positionY == _this.positionY)&&(identical(other.opacity, _this.opacity) || other.opacity == _this.opacity)&&(identical(other.dimming, _this.dimming) || other.dimming == _this.dimming)&&(identical(other.blur, _this.blur) || other.blur == _this.blur)&&(identical(other.cardOpacity, _this.cardOpacity) || other.cardOpacity == _this.cardOpacity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as WallpaperProps;
  return Object.hash(runtimeType,_this.enabled,_this.fileName,const DeepCollectionEquality().hash(_this.library),_this.fit,_this.scale,_this.positionX,_this.positionY,_this.opacity,_this.dimming,_this.blur,_this.cardOpacity);
}

@override
String toString() {
  final _this = this as WallpaperProps;
  return 'WallpaperProps(enabled: ${_this.enabled}, fileName: ${_this.fileName}, library: ${_this.library}, fit: ${_this.fit}, scale: ${_this.scale}, positionX: ${_this.positionX}, positionY: ${_this.positionY}, opacity: ${_this.opacity}, dimming: ${_this.dimming}, blur: ${_this.blur}, cardOpacity: ${_this.cardOpacity})';
}


}

/// @nodoc
abstract mixin class $WallpaperPropsCopyWith<$Res>  {
  factory $WallpaperPropsCopyWith(WallpaperProps value, $Res Function(WallpaperProps) _then) = _$WallpaperPropsCopyWithImpl;
@useResult
$Res call({
 bool enabled, String? fileName, List<String> library, WallpaperFit fit, double scale, double positionX, double positionY, double opacity, double dimming, double blur, double cardOpacity
});




}
/// @nodoc
class _$WallpaperPropsCopyWithImpl<$Res>
    implements $WallpaperPropsCopyWith<$Res> {
  _$WallpaperPropsCopyWithImpl(this._self, this._then);

  final WallpaperProps _self;
  final $Res Function(WallpaperProps) _then;

/// Create a copy of WallpaperProps
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enabled = null,Object? fileName = freezed,Object? library = null,Object? fit = null,Object? scale = null,Object? positionX = null,Object? positionY = null,Object? opacity = null,Object? dimming = null,Object? blur = null,Object? cardOpacity = null,}) {
  return _then(WallpaperProps(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,fileName: freezed == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String?,library: null == library ? _self.library : library // ignore: cast_nullable_to_non_nullable
as List<String>,fit: null == fit ? _self.fit : fit // ignore: cast_nullable_to_non_nullable
as WallpaperFit,scale: null == scale ? _self.scale : scale // ignore: cast_nullable_to_non_nullable
as double,positionX: null == positionX ? _self.positionX : positionX // ignore: cast_nullable_to_non_nullable
as double,positionY: null == positionY ? _self.positionY : positionY // ignore: cast_nullable_to_non_nullable
as double,opacity: null == opacity ? _self.opacity : opacity // ignore: cast_nullable_to_non_nullable
as double,dimming: null == dimming ? _self.dimming : dimming // ignore: cast_nullable_to_non_nullable
as double,blur: null == blur ? _self.blur : blur // ignore: cast_nullable_to_non_nullable
as double,cardOpacity: null == cardOpacity ? _self.cardOpacity : cardOpacity // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [WallpaperProps].
extension WallpaperPropsPatterns on WallpaperProps {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WallpaperProps value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WallpaperProps() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WallpaperProps value)  $default,){
final _that = this;
switch (_that) {
case _WallpaperProps():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WallpaperProps value)?  $default,){
final _that = this;
switch (_that) {
case _WallpaperProps() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enabled,  String? fileName,  List<String> library,  WallpaperFit fit,  double scale,  double positionX,  double positionY,  double opacity,  double dimming,  double blur,  double cardOpacity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WallpaperProps() when $default != null:
return $default(_that.enabled,_that.fileName,_that.library,_that.fit,_that.scale,_that.positionX,_that.positionY,_that.opacity,_that.dimming,_that.blur,_that.cardOpacity);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enabled,  String? fileName,  List<String> library,  WallpaperFit fit,  double scale,  double positionX,  double positionY,  double opacity,  double dimming,  double blur,  double cardOpacity)  $default,) {final _that = this;
switch (_that) {
case _WallpaperProps():
return $default(_that.enabled,_that.fileName,_that.library,_that.fit,_that.scale,_that.positionX,_that.positionY,_that.opacity,_that.dimming,_that.blur,_that.cardOpacity);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enabled,  String? fileName,  List<String> library,  WallpaperFit fit,  double scale,  double positionX,  double positionY,  double opacity,  double dimming,  double blur,  double cardOpacity)?  $default,) {final _that = this;
switch (_that) {
case _WallpaperProps() when $default != null:
return $default(_that.enabled,_that.fileName,_that.library,_that.fit,_that.scale,_that.positionX,_that.positionY,_that.opacity,_that.dimming,_that.blur,_that.cardOpacity);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WallpaperProps implements WallpaperProps {
  const _WallpaperProps({this.enabled = false, this.fileName,  List<String> library = const <String>[], this.fit = WallpaperFit.cover, this.scale = 1.0, this.positionX = 0.0, this.positionY = 0.0, this.opacity = 0.35, this.dimming = 0.0, this.blur = 0.0, this.cardOpacity = 0.9}): _library = library;
  factory _WallpaperProps.fromJson(Map<String, dynamic> json) => _$WallpaperPropsFromJson(json);

@override@JsonKey() final  bool enabled;
@override final  String? fileName;
 final  List<String> _library;
@override@JsonKey() List<String> get library {
  if (_library is EqualUnmodifiableListView) return _library;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_library);
}

@override@JsonKey() final  WallpaperFit fit;
@override@JsonKey() final  double scale;
@override@JsonKey() final  double positionX;
@override@JsonKey() final  double positionY;
@override@JsonKey() final  double opacity;
@override@JsonKey() final  double dimming;
@override@JsonKey() final  double blur;
@override@JsonKey() final  double cardOpacity;

/// Create a copy of WallpaperProps
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WallpaperPropsCopyWith<_WallpaperProps> get copyWith => __$WallpaperPropsCopyWithImpl<_WallpaperProps>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WallpaperPropsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WallpaperProps&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&const DeepCollectionEquality().equals(other.library, _library)&&(identical(other.fit, fit) || other.fit == fit)&&(identical(other.scale, scale) || other.scale == scale)&&(identical(other.positionX, positionX) || other.positionX == positionX)&&(identical(other.positionY, positionY) || other.positionY == positionY)&&(identical(other.opacity, opacity) || other.opacity == opacity)&&(identical(other.dimming, dimming) || other.dimming == dimming)&&(identical(other.blur, blur) || other.blur == blur)&&(identical(other.cardOpacity, cardOpacity) || other.cardOpacity == cardOpacity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,enabled,fileName,const DeepCollectionEquality().hash(_library),fit,scale,positionX,positionY,opacity,dimming,blur,cardOpacity);
}

@override
String toString() {
    return 'WallpaperProps(enabled: $enabled, fileName: $fileName, library: $library, fit: $fit, scale: $scale, positionX: $positionX, positionY: $positionY, opacity: $opacity, dimming: $dimming, blur: $blur, cardOpacity: $cardOpacity)';
}


}

/// @nodoc
abstract mixin class _$WallpaperPropsCopyWith<$Res> implements $WallpaperPropsCopyWith<$Res> {
  factory _$WallpaperPropsCopyWith(_WallpaperProps value, $Res Function(_WallpaperProps) _then) = __$WallpaperPropsCopyWithImpl;
@override @useResult
$Res call({
 bool enabled, String? fileName, List<String> library, WallpaperFit fit, double scale, double positionX, double positionY, double opacity, double dimming, double blur, double cardOpacity
});




}
/// @nodoc
class __$WallpaperPropsCopyWithImpl<$Res>
    implements _$WallpaperPropsCopyWith<$Res> {
  __$WallpaperPropsCopyWithImpl(this._self, this._then);

  final _WallpaperProps _self;
  final $Res Function(_WallpaperProps) _then;

/// Create a copy of WallpaperProps
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enabled = null,Object? fileName = freezed,Object? library = null,Object? fit = null,Object? scale = null,Object? positionX = null,Object? positionY = null,Object? opacity = null,Object? dimming = null,Object? blur = null,Object? cardOpacity = null,}) {
  return _then(_WallpaperProps(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,fileName: freezed == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String?,library: null == library ? _self._library : library // ignore: cast_nullable_to_non_nullable
as List<String>,fit: null == fit ? _self.fit : fit // ignore: cast_nullable_to_non_nullable
as WallpaperFit,scale: null == scale ? _self.scale : scale // ignore: cast_nullable_to_non_nullable
as double,positionX: null == positionX ? _self.positionX : positionX // ignore: cast_nullable_to_non_nullable
as double,positionY: null == positionY ? _self.positionY : positionY // ignore: cast_nullable_to_non_nullable
as double,opacity: null == opacity ? _self.opacity : opacity // ignore: cast_nullable_to_non_nullable
as double,dimming: null == dimming ? _self.dimming : dimming // ignore: cast_nullable_to_non_nullable
as double,blur: null == blur ? _self.blur : blur // ignore: cast_nullable_to_non_nullable
as double,cardOpacity: null == cardOpacity ? _self.cardOpacity : cardOpacity // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
