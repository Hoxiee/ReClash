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

 bool get enabled; bool get providerPriority; String? get fileName; List<String> get library; WallpaperFit get fit; double get scale; double get positionX; double get positionY; double get opacity; double get dimming; double get blur; double get cardOpacity; double get heroOpacity; double get orbOpacity;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WallpaperProps&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled)&&(identical(other.providerPriority, _this.providerPriority) || other.providerPriority == _this.providerPriority)&&(identical(other.fileName, _this.fileName) || other.fileName == _this.fileName)&&const DeepCollectionEquality().equals(other.library, _this.library)&&(identical(other.fit, _this.fit) || other.fit == _this.fit)&&(identical(other.scale, _this.scale) || other.scale == _this.scale)&&(identical(other.positionX, _this.positionX) || other.positionX == _this.positionX)&&(identical(other.positionY, _this.positionY) || other.positionY == _this.positionY)&&(identical(other.opacity, _this.opacity) || other.opacity == _this.opacity)&&(identical(other.dimming, _this.dimming) || other.dimming == _this.dimming)&&(identical(other.blur, _this.blur) || other.blur == _this.blur)&&(identical(other.cardOpacity, _this.cardOpacity) || other.cardOpacity == _this.cardOpacity)&&(identical(other.heroOpacity, _this.heroOpacity) || other.heroOpacity == _this.heroOpacity)&&(identical(other.orbOpacity, _this.orbOpacity) || other.orbOpacity == _this.orbOpacity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as WallpaperProps;
  return Object.hash(runtimeType,_this.enabled,_this.providerPriority,_this.fileName,const DeepCollectionEquality().hash(_this.library),_this.fit,_this.scale,_this.positionX,_this.positionY,_this.opacity,_this.dimming,_this.blur,_this.cardOpacity,_this.heroOpacity,_this.orbOpacity);
}

@override
String toString() {
  final _this = this as WallpaperProps;
  return 'WallpaperProps(enabled: ${_this.enabled}, providerPriority: ${_this.providerPriority}, fileName: ${_this.fileName}, library: ${_this.library}, fit: ${_this.fit}, scale: ${_this.scale}, positionX: ${_this.positionX}, positionY: ${_this.positionY}, opacity: ${_this.opacity}, dimming: ${_this.dimming}, blur: ${_this.blur}, cardOpacity: ${_this.cardOpacity}, heroOpacity: ${_this.heroOpacity}, orbOpacity: ${_this.orbOpacity})';
}


}

/// @nodoc
abstract mixin class $WallpaperPropsCopyWith<$Res>  {
  factory $WallpaperPropsCopyWith(WallpaperProps value, $Res Function(WallpaperProps) _then) = _$WallpaperPropsCopyWithImpl;
@useResult
$Res call({
 bool enabled, bool providerPriority, String? fileName, List<String> library, WallpaperFit fit, double scale, double positionX, double positionY, double opacity, double dimming, double blur, double cardOpacity, double heroOpacity, double orbOpacity
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
@pragma('vm:prefer-inline') @override $Res call({Object? enabled = null,Object? providerPriority = null,Object? fileName = freezed,Object? library = null,Object? fit = null,Object? scale = null,Object? positionX = null,Object? positionY = null,Object? opacity = null,Object? dimming = null,Object? blur = null,Object? cardOpacity = null,Object? heroOpacity = null,Object? orbOpacity = null,}) {
  return _then(WallpaperProps(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,providerPriority: null == providerPriority ? _self.providerPriority : providerPriority // ignore: cast_nullable_to_non_nullable
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
as double,heroOpacity: null == heroOpacity ? _self.heroOpacity : heroOpacity // ignore: cast_nullable_to_non_nullable
as double,orbOpacity: null == orbOpacity ? _self.orbOpacity : orbOpacity // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enabled,  bool providerPriority,  String? fileName,  List<String> library,  WallpaperFit fit,  double scale,  double positionX,  double positionY,  double opacity,  double dimming,  double blur,  double cardOpacity,  double heroOpacity,  double orbOpacity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WallpaperProps() when $default != null:
return $default(_that.enabled,_that.providerPriority,_that.fileName,_that.library,_that.fit,_that.scale,_that.positionX,_that.positionY,_that.opacity,_that.dimming,_that.blur,_that.cardOpacity,_that.heroOpacity,_that.orbOpacity);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enabled,  bool providerPriority,  String? fileName,  List<String> library,  WallpaperFit fit,  double scale,  double positionX,  double positionY,  double opacity,  double dimming,  double blur,  double cardOpacity,  double heroOpacity,  double orbOpacity)  $default,) {final _that = this;
switch (_that) {
case _WallpaperProps():
return $default(_that.enabled,_that.providerPriority,_that.fileName,_that.library,_that.fit,_that.scale,_that.positionX,_that.positionY,_that.opacity,_that.dimming,_that.blur,_that.cardOpacity,_that.heroOpacity,_that.orbOpacity);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enabled,  bool providerPriority,  String? fileName,  List<String> library,  WallpaperFit fit,  double scale,  double positionX,  double positionY,  double opacity,  double dimming,  double blur,  double cardOpacity,  double heroOpacity,  double orbOpacity)?  $default,) {final _that = this;
switch (_that) {
case _WallpaperProps() when $default != null:
return $default(_that.enabled,_that.providerPriority,_that.fileName,_that.library,_that.fit,_that.scale,_that.positionX,_that.positionY,_that.opacity,_that.dimming,_that.blur,_that.cardOpacity,_that.heroOpacity,_that.orbOpacity);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WallpaperProps implements WallpaperProps {
  const _WallpaperProps({this.enabled = false, this.providerPriority = false, this.fileName,  List<String> library = const <String>[], this.fit = WallpaperFit.cover, this.scale = 1.0, this.positionX = 0.0, this.positionY = 0.0, this.opacity = 0.35, this.dimming = 0.0, this.blur = 0.0, this.cardOpacity = 0.9, this.heroOpacity = 0.85, this.orbOpacity = 1.0}): _library = library;
  factory _WallpaperProps.fromJson(Map<String, dynamic> json) => _$WallpaperPropsFromJson(json);

@override@JsonKey() final  bool enabled;
@override@JsonKey() final  bool providerPriority;
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
@override@JsonKey() final  double heroOpacity;
@override@JsonKey() final  double orbOpacity;

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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WallpaperProps&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.providerPriority, providerPriority) || other.providerPriority == providerPriority)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&const DeepCollectionEquality().equals(other.library, _library)&&(identical(other.fit, fit) || other.fit == fit)&&(identical(other.scale, scale) || other.scale == scale)&&(identical(other.positionX, positionX) || other.positionX == positionX)&&(identical(other.positionY, positionY) || other.positionY == positionY)&&(identical(other.opacity, opacity) || other.opacity == opacity)&&(identical(other.dimming, dimming) || other.dimming == dimming)&&(identical(other.blur, blur) || other.blur == blur)&&(identical(other.cardOpacity, cardOpacity) || other.cardOpacity == cardOpacity)&&(identical(other.heroOpacity, heroOpacity) || other.heroOpacity == heroOpacity)&&(identical(other.orbOpacity, orbOpacity) || other.orbOpacity == orbOpacity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,enabled,providerPriority,fileName,const DeepCollectionEquality().hash(_library),fit,scale,positionX,positionY,opacity,dimming,blur,cardOpacity,heroOpacity,orbOpacity);
}

@override
String toString() {
    return 'WallpaperProps(enabled: $enabled, providerPriority: $providerPriority, fileName: $fileName, library: $library, fit: $fit, scale: $scale, positionX: $positionX, positionY: $positionY, opacity: $opacity, dimming: $dimming, blur: $blur, cardOpacity: $cardOpacity, heroOpacity: $heroOpacity, orbOpacity: $orbOpacity)';
}


}

/// @nodoc
abstract mixin class _$WallpaperPropsCopyWith<$Res> implements $WallpaperPropsCopyWith<$Res> {
  factory _$WallpaperPropsCopyWith(_WallpaperProps value, $Res Function(_WallpaperProps) _then) = __$WallpaperPropsCopyWithImpl;
@override @useResult
$Res call({
 bool enabled, bool providerPriority, String? fileName, List<String> library, WallpaperFit fit, double scale, double positionX, double positionY, double opacity, double dimming, double blur, double cardOpacity, double heroOpacity, double orbOpacity
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
@override @pragma('vm:prefer-inline') $Res call({Object? enabled = null,Object? providerPriority = null,Object? fileName = freezed,Object? library = null,Object? fit = null,Object? scale = null,Object? positionX = null,Object? positionY = null,Object? opacity = null,Object? dimming = null,Object? blur = null,Object? cardOpacity = null,Object? heroOpacity = null,Object? orbOpacity = null,}) {
  return _then(_WallpaperProps(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,providerPriority: null == providerPriority ? _self.providerPriority : providerPriority // ignore: cast_nullable_to_non_nullable
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
as double,heroOpacity: null == heroOpacity ? _self.heroOpacity : heroOpacity // ignore: cast_nullable_to_non_nullable
as double,orbOpacity: null == orbOpacity ? _self.orbOpacity : orbOpacity // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
