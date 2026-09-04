// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../desync.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DesyncProps {

 bool get enabled; int get port; List<DesyncCategory> get categories; bool get forceTcp;
/// Create a copy of DesyncProps
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DesyncPropsCopyWith<DesyncProps> get copyWith => _$DesyncPropsCopyWithImpl<DesyncProps>(this as DesyncProps, _$identity);

  /// Serializes this DesyncProps to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DesyncProps;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DesyncProps&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled)&&(identical(other.port, _this.port) || other.port == _this.port)&&const DeepCollectionEquality().equals(other.categories, _this.categories)&&(identical(other.forceTcp, _this.forceTcp) || other.forceTcp == _this.forceTcp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DesyncProps;
  return Object.hash(runtimeType,_this.enabled,_this.port,const DeepCollectionEquality().hash(_this.categories),_this.forceTcp);
}

@override
String toString() {
  final _this = this as DesyncProps;
  return 'DesyncProps(enabled: ${_this.enabled}, port: ${_this.port}, categories: ${_this.categories}, forceTcp: ${_this.forceTcp})';
}


}

/// @nodoc
abstract mixin class $DesyncPropsCopyWith<$Res>  {
  factory $DesyncPropsCopyWith(DesyncProps value, $Res Function(DesyncProps) _then) = _$DesyncPropsCopyWithImpl;
@useResult
$Res call({
 bool enabled, int port, List<DesyncCategory> categories, bool forceTcp
});




}
/// @nodoc
class _$DesyncPropsCopyWithImpl<$Res>
    implements $DesyncPropsCopyWith<$Res> {
  _$DesyncPropsCopyWithImpl(this._self, this._then);

  final DesyncProps _self;
  final $Res Function(DesyncProps) _then;

/// Create a copy of DesyncProps
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enabled = null,Object? port = null,Object? categories = null,Object? forceTcp = null,}) {
  return _then(DesyncProps(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<DesyncCategory>,forceTcp: null == forceTcp ? _self.forceTcp : forceTcp // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [DesyncProps].
extension DesyncPropsPatterns on DesyncProps {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DesyncProps value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DesyncProps() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DesyncProps value)  $default,){
final _that = this;
switch (_that) {
case _DesyncProps():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DesyncProps value)?  $default,){
final _that = this;
switch (_that) {
case _DesyncProps() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enabled,  int port,  List<DesyncCategory> categories,  bool forceTcp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DesyncProps() when $default != null:
return $default(_that.enabled,_that.port,_that.categories,_that.forceTcp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enabled,  int port,  List<DesyncCategory> categories,  bool forceTcp)  $default,) {final _that = this;
switch (_that) {
case _DesyncProps():
return $default(_that.enabled,_that.port,_that.categories,_that.forceTcp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enabled,  int port,  List<DesyncCategory> categories,  bool forceTcp)?  $default,) {final _that = this;
switch (_that) {
case _DesyncProps() when $default != null:
return $default(_that.enabled,_that.port,_that.categories,_that.forceTcp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DesyncProps implements DesyncProps {
  const _DesyncProps({this.enabled = false, this.port = defaultDesyncPort,  List<DesyncCategory> categories = const [DesyncCategory.youtube, DesyncCategory.discord], this.forceTcp = true}): _categories = categories;
  factory _DesyncProps.fromJson(Map<String, dynamic> json) => _$DesyncPropsFromJson(json);

@override@JsonKey() final  bool enabled;
@override@JsonKey() final  int port;
 final  List<DesyncCategory> _categories;
@override@JsonKey() List<DesyncCategory> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

@override@JsonKey() final  bool forceTcp;

/// Create a copy of DesyncProps
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DesyncPropsCopyWith<_DesyncProps> get copyWith => __$DesyncPropsCopyWithImpl<_DesyncProps>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DesyncPropsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DesyncProps&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.port, port) || other.port == port)&&const DeepCollectionEquality().equals(other.categories, _categories)&&(identical(other.forceTcp, forceTcp) || other.forceTcp == forceTcp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,enabled,port,const DeepCollectionEquality().hash(_categories),forceTcp);
}

@override
String toString() {
    return 'DesyncProps(enabled: $enabled, port: $port, categories: $categories, forceTcp: $forceTcp)';
}


}

/// @nodoc
abstract mixin class _$DesyncPropsCopyWith<$Res> implements $DesyncPropsCopyWith<$Res> {
  factory _$DesyncPropsCopyWith(_DesyncProps value, $Res Function(_DesyncProps) _then) = __$DesyncPropsCopyWithImpl;
@override @useResult
$Res call({
 bool enabled, int port, List<DesyncCategory> categories, bool forceTcp
});




}
/// @nodoc
class __$DesyncPropsCopyWithImpl<$Res>
    implements _$DesyncPropsCopyWith<$Res> {
  __$DesyncPropsCopyWithImpl(this._self, this._then);

  final _DesyncProps _self;
  final $Res Function(_DesyncProps) _then;

/// Create a copy of DesyncProps
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enabled = null,Object? port = null,Object? categories = null,Object? forceTcp = null,}) {
  return _then(_DesyncProps(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<DesyncCategory>,forceTcp: null == forceTcp ? _self.forceTcp : forceTcp // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
