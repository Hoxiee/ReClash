// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../provider_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProviderSettingsState {

 Map<String, Object?> get applied; Map<String, Object?> get userBaseline; Set<String> get userOwned;
/// Create a copy of ProviderSettingsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProviderSettingsStateCopyWith<ProviderSettingsState> get copyWith => _$ProviderSettingsStateCopyWithImpl<ProviderSettingsState>(this as ProviderSettingsState, _$identity);

  /// Serializes this ProviderSettingsState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ProviderSettingsState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProviderSettingsState&&const DeepCollectionEquality().equals(other.applied, _this.applied)&&const DeepCollectionEquality().equals(other.userBaseline, _this.userBaseline)&&const DeepCollectionEquality().equals(other.userOwned, _this.userOwned));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ProviderSettingsState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.applied),const DeepCollectionEquality().hash(_this.userBaseline),const DeepCollectionEquality().hash(_this.userOwned));
}

@override
String toString() {
  final _this = this as ProviderSettingsState;
  return 'ProviderSettingsState(applied: ${_this.applied}, userBaseline: ${_this.userBaseline}, userOwned: ${_this.userOwned})';
}


}

/// @nodoc
abstract mixin class $ProviderSettingsStateCopyWith<$Res>  {
  factory $ProviderSettingsStateCopyWith(ProviderSettingsState value, $Res Function(ProviderSettingsState) _then) = _$ProviderSettingsStateCopyWithImpl;
@useResult
$Res call({
 Map<String, Object?> applied, Map<String, Object?> userBaseline, Set<String> userOwned
});




}
/// @nodoc
class _$ProviderSettingsStateCopyWithImpl<$Res>
    implements $ProviderSettingsStateCopyWith<$Res> {
  _$ProviderSettingsStateCopyWithImpl(this._self, this._then);

  final ProviderSettingsState _self;
  final $Res Function(ProviderSettingsState) _then;

/// Create a copy of ProviderSettingsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? applied = null,Object? userBaseline = null,Object? userOwned = null,}) {
  return _then(ProviderSettingsState(
applied: null == applied ? _self.applied : applied // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,userBaseline: null == userBaseline ? _self.userBaseline : userBaseline // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,userOwned: null == userOwned ? _self.userOwned : userOwned // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [ProviderSettingsState].
extension ProviderSettingsStatePatterns on ProviderSettingsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProviderSettingsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProviderSettingsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProviderSettingsState value)  $default,){
final _that = this;
switch (_that) {
case _ProviderSettingsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProviderSettingsState value)?  $default,){
final _that = this;
switch (_that) {
case _ProviderSettingsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, Object?> applied,  Map<String, Object?> userBaseline,  Set<String> userOwned)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProviderSettingsState() when $default != null:
return $default(_that.applied,_that.userBaseline,_that.userOwned);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, Object?> applied,  Map<String, Object?> userBaseline,  Set<String> userOwned)  $default,) {final _that = this;
switch (_that) {
case _ProviderSettingsState():
return $default(_that.applied,_that.userBaseline,_that.userOwned);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, Object?> applied,  Map<String, Object?> userBaseline,  Set<String> userOwned)?  $default,) {final _that = this;
switch (_that) {
case _ProviderSettingsState() when $default != null:
return $default(_that.applied,_that.userBaseline,_that.userOwned);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProviderSettingsState implements ProviderSettingsState {
  const _ProviderSettingsState({ Map<String, Object?> applied = const {},  Map<String, Object?> userBaseline = const {},  Set<String> userOwned = const {}}): _applied = applied,_userBaseline = userBaseline,_userOwned = userOwned;
  factory _ProviderSettingsState.fromJson(Map<String, dynamic> json) => _$ProviderSettingsStateFromJson(json);

 final  Map<String, Object?> _applied;
@override@JsonKey() Map<String, Object?> get applied {
  if (_applied is EqualUnmodifiableMapView) return _applied;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_applied);
}

 final  Map<String, Object?> _userBaseline;
@override@JsonKey() Map<String, Object?> get userBaseline {
  if (_userBaseline is EqualUnmodifiableMapView) return _userBaseline;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_userBaseline);
}

 final  Set<String> _userOwned;
@override@JsonKey() Set<String> get userOwned {
  if (_userOwned is EqualUnmodifiableSetView) return _userOwned;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_userOwned);
}


/// Create a copy of ProviderSettingsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProviderSettingsStateCopyWith<_ProviderSettingsState> get copyWith => __$ProviderSettingsStateCopyWithImpl<_ProviderSettingsState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProviderSettingsStateToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProviderSettingsState&&const DeepCollectionEquality().equals(other.applied, _applied)&&const DeepCollectionEquality().equals(other.userBaseline, _userBaseline)&&const DeepCollectionEquality().equals(other.userOwned, _userOwned));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_applied),const DeepCollectionEquality().hash(_userBaseline),const DeepCollectionEquality().hash(_userOwned));
}

@override
String toString() {
    return 'ProviderSettingsState(applied: $applied, userBaseline: $userBaseline, userOwned: $userOwned)';
}


}

/// @nodoc
abstract mixin class _$ProviderSettingsStateCopyWith<$Res> implements $ProviderSettingsStateCopyWith<$Res> {
  factory _$ProviderSettingsStateCopyWith(_ProviderSettingsState value, $Res Function(_ProviderSettingsState) _then) = __$ProviderSettingsStateCopyWithImpl;
@override @useResult
$Res call({
 Map<String, Object?> applied, Map<String, Object?> userBaseline, Set<String> userOwned
});




}
/// @nodoc
class __$ProviderSettingsStateCopyWithImpl<$Res>
    implements _$ProviderSettingsStateCopyWith<$Res> {
  __$ProviderSettingsStateCopyWithImpl(this._self, this._then);

  final _ProviderSettingsState _self;
  final $Res Function(_ProviderSettingsState) _then;

/// Create a copy of ProviderSettingsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? applied = null,Object? userBaseline = null,Object? userOwned = null,}) {
  return _then(_ProviderSettingsState(
applied: null == applied ? _self._applied : applied // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,userBaseline: null == userBaseline ? _self._userBaseline : userBaseline // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,userOwned: null == userOwned ? _self._userOwned : userOwned // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}


}

// dart format on
