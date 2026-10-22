// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../rcx.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RcxPool {

@JsonKey(includeIfNull: false) String? get include;@JsonKey(includeIfNull: false) String? get exclude;
/// Create a copy of RcxPool
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RcxPoolCopyWith<RcxPool> get copyWith => _$RcxPoolCopyWithImpl<RcxPool>(this as RcxPool, _$identity);

  /// Serializes this RcxPool to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RcxPool;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RcxPool&&(identical(other.include, _this.include) || other.include == _this.include)&&(identical(other.exclude, _this.exclude) || other.exclude == _this.exclude));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RcxPool;
  return Object.hash(runtimeType,_this.include,_this.exclude);
}

@override
String toString() {
  final _this = this as RcxPool;
  return 'RcxPool(include: ${_this.include}, exclude: ${_this.exclude})';
}


}

/// @nodoc
abstract mixin class $RcxPoolCopyWith<$Res>  {
  factory $RcxPoolCopyWith(RcxPool value, $Res Function(RcxPool) _then) = _$RcxPoolCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeIfNull: false) String? include,@JsonKey(includeIfNull: false) String? exclude
});




}
/// @nodoc
class _$RcxPoolCopyWithImpl<$Res>
    implements $RcxPoolCopyWith<$Res> {
  _$RcxPoolCopyWithImpl(this._self, this._then);

  final RcxPool _self;
  final $Res Function(RcxPool) _then;

/// Create a copy of RcxPool
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? include = freezed,Object? exclude = freezed,}) {
  return _then(RcxPool(
include: freezed == include ? _self.include : include // ignore: cast_nullable_to_non_nullable
as String?,exclude: freezed == exclude ? _self.exclude : exclude // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RcxPool].
extension RcxPoolPatterns on RcxPool {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RcxPool value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RcxPool() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RcxPool value)  $default,){
final _that = this;
switch (_that) {
case _RcxPool():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RcxPool value)?  $default,){
final _that = this;
switch (_that) {
case _RcxPool() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  String? include, @JsonKey(includeIfNull: false)  String? exclude)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RcxPool() when $default != null:
return $default(_that.include,_that.exclude);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  String? include, @JsonKey(includeIfNull: false)  String? exclude)  $default,) {final _that = this;
switch (_that) {
case _RcxPool():
return $default(_that.include,_that.exclude);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeIfNull: false)  String? include, @JsonKey(includeIfNull: false)  String? exclude)?  $default,) {final _that = this;
switch (_that) {
case _RcxPool() when $default != null:
return $default(_that.include,_that.exclude);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RcxPool implements RcxPool {
  const _RcxPool({@JsonKey(includeIfNull: false) this.include, @JsonKey(includeIfNull: false) this.exclude});
  factory _RcxPool.fromJson(Map<String, dynamic> json) => _$RcxPoolFromJson(json);

@override@JsonKey(includeIfNull: false) final  String? include;
@override@JsonKey(includeIfNull: false) final  String? exclude;

/// Create a copy of RcxPool
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RcxPoolCopyWith<_RcxPool> get copyWith => __$RcxPoolCopyWithImpl<_RcxPool>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RcxPoolToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RcxPool&&(identical(other.include, include) || other.include == include)&&(identical(other.exclude, exclude) || other.exclude == exclude));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,include,exclude);
}

@override
String toString() {
    return 'RcxPool(include: $include, exclude: $exclude)';
}


}

/// @nodoc
abstract mixin class _$RcxPoolCopyWith<$Res> implements $RcxPoolCopyWith<$Res> {
  factory _$RcxPoolCopyWith(_RcxPool value, $Res Function(_RcxPool) _then) = __$RcxPoolCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeIfNull: false) String? include,@JsonKey(includeIfNull: false) String? exclude
});




}
/// @nodoc
class __$RcxPoolCopyWithImpl<$Res>
    implements _$RcxPoolCopyWith<$Res> {
  __$RcxPoolCopyWithImpl(this._self, this._then);

  final _RcxPool _self;
  final $Res Function(_RcxPool) _then;

/// Create a copy of RcxPool
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? include = freezed,Object? exclude = freezed,}) {
  return _then(_RcxPool(
include: freezed == include ? _self.include : include // ignore: cast_nullable_to_non_nullable
as String?,exclude: freezed == exclude ? _self.exclude : exclude // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$RcxChip {

 String get label; String get include;
/// Create a copy of RcxChip
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RcxChipCopyWith<RcxChip> get copyWith => _$RcxChipCopyWithImpl<RcxChip>(this as RcxChip, _$identity);

  /// Serializes this RcxChip to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RcxChip;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RcxChip&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.include, _this.include) || other.include == _this.include));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RcxChip;
  return Object.hash(runtimeType,_this.label,_this.include);
}

@override
String toString() {
  final _this = this as RcxChip;
  return 'RcxChip(label: ${_this.label}, include: ${_this.include})';
}


}

/// @nodoc
abstract mixin class $RcxChipCopyWith<$Res>  {
  factory $RcxChipCopyWith(RcxChip value, $Res Function(RcxChip) _then) = _$RcxChipCopyWithImpl;
@useResult
$Res call({
 String label, String include
});




}
/// @nodoc
class _$RcxChipCopyWithImpl<$Res>
    implements $RcxChipCopyWith<$Res> {
  _$RcxChipCopyWithImpl(this._self, this._then);

  final RcxChip _self;
  final $Res Function(RcxChip) _then;

/// Create a copy of RcxChip
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = null,Object? include = null,}) {
  return _then(RcxChip(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,include: null == include ? _self.include : include // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RcxChip].
extension RcxChipPatterns on RcxChip {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RcxChip value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RcxChip() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RcxChip value)  $default,){
final _that = this;
switch (_that) {
case _RcxChip():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RcxChip value)?  $default,){
final _that = this;
switch (_that) {
case _RcxChip() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String label,  String include)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RcxChip() when $default != null:
return $default(_that.label,_that.include);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String label,  String include)  $default,) {final _that = this;
switch (_that) {
case _RcxChip():
return $default(_that.label,_that.include);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String label,  String include)?  $default,) {final _that = this;
switch (_that) {
case _RcxChip() when $default != null:
return $default(_that.label,_that.include);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RcxChip implements RcxChip {
  const _RcxChip({required this.label, required this.include});
  factory _RcxChip.fromJson(Map<String, dynamic> json) => _$RcxChipFromJson(json);

@override final  String label;
@override final  String include;

/// Create a copy of RcxChip
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RcxChipCopyWith<_RcxChip> get copyWith => __$RcxChipCopyWithImpl<_RcxChip>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RcxChipToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RcxChip&&(identical(other.label, label) || other.label == label)&&(identical(other.include, include) || other.include == include));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,label,include);
}

@override
String toString() {
    return 'RcxChip(label: $label, include: $include)';
}


}

/// @nodoc
abstract mixin class _$RcxChipCopyWith<$Res> implements $RcxChipCopyWith<$Res> {
  factory _$RcxChipCopyWith(_RcxChip value, $Res Function(_RcxChip) _then) = __$RcxChipCopyWithImpl;
@override @useResult
$Res call({
 String label, String include
});




}
/// @nodoc
class __$RcxChipCopyWithImpl<$Res>
    implements _$RcxChipCopyWith<$Res> {
  __$RcxChipCopyWithImpl(this._self, this._then);

  final _RcxChip _self;
  final $Res Function(_RcxChip) _then;

/// Create a copy of RcxChip
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? include = null,}) {
  return _then(_RcxChip(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,include: null == include ? _self.include : include // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$RcxBinding {

 List<String> get profiles;@JsonKey(name: 'default', includeIfNull: false) String? get defaultProfile;@JsonKey(includeIfNull: false) String? get profile; RcxPool get pool;@JsonKey(includeIfNull: false) String? get feel;@JsonKey(includeIfNull: false) String? get energy; List<RcxChip> get chips;/// Honoured from the user's layer only; a provider cannot turn it on.
 bool get directSplit;
/// Create a copy of RcxBinding
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RcxBindingCopyWith<RcxBinding> get copyWith => _$RcxBindingCopyWithImpl<RcxBinding>(this as RcxBinding, _$identity);

  /// Serializes this RcxBinding to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RcxBinding;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RcxBinding&&const DeepCollectionEquality().equals(other.profiles, _this.profiles)&&(identical(other.defaultProfile, _this.defaultProfile) || other.defaultProfile == _this.defaultProfile)&&(identical(other.profile, _this.profile) || other.profile == _this.profile)&&(identical(other.pool, _this.pool) || other.pool == _this.pool)&&(identical(other.feel, _this.feel) || other.feel == _this.feel)&&(identical(other.energy, _this.energy) || other.energy == _this.energy)&&const DeepCollectionEquality().equals(other.chips, _this.chips)&&(identical(other.directSplit, _this.directSplit) || other.directSplit == _this.directSplit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RcxBinding;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.profiles),_this.defaultProfile,_this.profile,_this.pool,_this.feel,_this.energy,const DeepCollectionEquality().hash(_this.chips),_this.directSplit);
}

@override
String toString() {
  final _this = this as RcxBinding;
  return 'RcxBinding(profiles: ${_this.profiles}, defaultProfile: ${_this.defaultProfile}, profile: ${_this.profile}, pool: ${_this.pool}, feel: ${_this.feel}, energy: ${_this.energy}, chips: ${_this.chips}, directSplit: ${_this.directSplit})';
}


}

/// @nodoc
abstract mixin class $RcxBindingCopyWith<$Res>  {
  factory $RcxBindingCopyWith(RcxBinding value, $Res Function(RcxBinding) _then) = _$RcxBindingCopyWithImpl;
@useResult
$Res call({
 List<String> profiles,@JsonKey(name: 'default', includeIfNull: false) String? defaultProfile,@JsonKey(includeIfNull: false) String? profile, RcxPool pool,@JsonKey(includeIfNull: false) String? feel,@JsonKey(includeIfNull: false) String? energy, List<RcxChip> chips, bool directSplit
});


$RcxPoolCopyWith<$Res> get pool;

}
/// @nodoc
class _$RcxBindingCopyWithImpl<$Res>
    implements $RcxBindingCopyWith<$Res> {
  _$RcxBindingCopyWithImpl(this._self, this._then);

  final RcxBinding _self;
  final $Res Function(RcxBinding) _then;

/// Create a copy of RcxBinding
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? profiles = null,Object? defaultProfile = freezed,Object? profile = freezed,Object? pool = null,Object? feel = freezed,Object? energy = freezed,Object? chips = null,Object? directSplit = null,}) {
  return _then(RcxBinding(
profiles: null == profiles ? _self.profiles : profiles // ignore: cast_nullable_to_non_nullable
as List<String>,defaultProfile: freezed == defaultProfile ? _self.defaultProfile : defaultProfile // ignore: cast_nullable_to_non_nullable
as String?,profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as String?,pool: null == pool ? _self.pool : pool // ignore: cast_nullable_to_non_nullable
as RcxPool,feel: freezed == feel ? _self.feel : feel // ignore: cast_nullable_to_non_nullable
as String?,energy: freezed == energy ? _self.energy : energy // ignore: cast_nullable_to_non_nullable
as String?,chips: null == chips ? _self.chips : chips // ignore: cast_nullable_to_non_nullable
as List<RcxChip>,directSplit: null == directSplit ? _self.directSplit : directSplit // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of RcxBinding
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RcxPoolCopyWith<$Res> get pool {
  
  return $RcxPoolCopyWith<$Res>(_self.pool, (value) {
    return _then(_self.copyWith(pool: value));
  });
}
}


/// Adds pattern-matching-related methods to [RcxBinding].
extension RcxBindingPatterns on RcxBinding {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RcxBinding value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RcxBinding() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RcxBinding value)  $default,){
final _that = this;
switch (_that) {
case _RcxBinding():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RcxBinding value)?  $default,){
final _that = this;
switch (_that) {
case _RcxBinding() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> profiles, @JsonKey(name: 'default', includeIfNull: false)  String? defaultProfile, @JsonKey(includeIfNull: false)  String? profile,  RcxPool pool, @JsonKey(includeIfNull: false)  String? feel, @JsonKey(includeIfNull: false)  String? energy,  List<RcxChip> chips,  bool directSplit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RcxBinding() when $default != null:
return $default(_that.profiles,_that.defaultProfile,_that.profile,_that.pool,_that.feel,_that.energy,_that.chips,_that.directSplit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> profiles, @JsonKey(name: 'default', includeIfNull: false)  String? defaultProfile, @JsonKey(includeIfNull: false)  String? profile,  RcxPool pool, @JsonKey(includeIfNull: false)  String? feel, @JsonKey(includeIfNull: false)  String? energy,  List<RcxChip> chips,  bool directSplit)  $default,) {final _that = this;
switch (_that) {
case _RcxBinding():
return $default(_that.profiles,_that.defaultProfile,_that.profile,_that.pool,_that.feel,_that.energy,_that.chips,_that.directSplit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> profiles, @JsonKey(name: 'default', includeIfNull: false)  String? defaultProfile, @JsonKey(includeIfNull: false)  String? profile,  RcxPool pool, @JsonKey(includeIfNull: false)  String? feel, @JsonKey(includeIfNull: false)  String? energy,  List<RcxChip> chips,  bool directSplit)?  $default,) {final _that = this;
switch (_that) {
case _RcxBinding() when $default != null:
return $default(_that.profiles,_that.defaultProfile,_that.profile,_that.pool,_that.feel,_that.energy,_that.chips,_that.directSplit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RcxBinding implements RcxBinding {
  const _RcxBinding({ List<String> profiles = const [], @JsonKey(name: 'default', includeIfNull: false) this.defaultProfile, @JsonKey(includeIfNull: false) this.profile, this.pool = const RcxPool(), @JsonKey(includeIfNull: false) this.feel, @JsonKey(includeIfNull: false) this.energy,  List<RcxChip> chips = const [], this.directSplit = false}): _profiles = profiles,_chips = chips;
  factory _RcxBinding.fromJson(Map<String, dynamic> json) => _$RcxBindingFromJson(json);

 final  List<String> _profiles;
@override@JsonKey() List<String> get profiles {
  if (_profiles is EqualUnmodifiableListView) return _profiles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_profiles);
}

@override@JsonKey(name: 'default', includeIfNull: false) final  String? defaultProfile;
@override@JsonKey(includeIfNull: false) final  String? profile;
@override@JsonKey() final  RcxPool pool;
@override@JsonKey(includeIfNull: false) final  String? feel;
@override@JsonKey(includeIfNull: false) final  String? energy;
 final  List<RcxChip> _chips;
@override@JsonKey() List<RcxChip> get chips {
  if (_chips is EqualUnmodifiableListView) return _chips;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_chips);
}

/// Honoured from the user's layer only; a provider cannot turn it on.
@override@JsonKey() final  bool directSplit;

/// Create a copy of RcxBinding
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RcxBindingCopyWith<_RcxBinding> get copyWith => __$RcxBindingCopyWithImpl<_RcxBinding>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RcxBindingToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RcxBinding&&const DeepCollectionEquality().equals(other.profiles, _profiles)&&(identical(other.defaultProfile, defaultProfile) || other.defaultProfile == defaultProfile)&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.pool, pool) || other.pool == pool)&&(identical(other.feel, feel) || other.feel == feel)&&(identical(other.energy, energy) || other.energy == energy)&&const DeepCollectionEquality().equals(other.chips, _chips)&&(identical(other.directSplit, directSplit) || other.directSplit == directSplit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_profiles),defaultProfile,profile,pool,feel,energy,const DeepCollectionEquality().hash(_chips),directSplit);
}

@override
String toString() {
    return 'RcxBinding(profiles: $profiles, defaultProfile: $defaultProfile, profile: $profile, pool: $pool, feel: $feel, energy: $energy, chips: $chips, directSplit: $directSplit)';
}


}

/// @nodoc
abstract mixin class _$RcxBindingCopyWith<$Res> implements $RcxBindingCopyWith<$Res> {
  factory _$RcxBindingCopyWith(_RcxBinding value, $Res Function(_RcxBinding) _then) = __$RcxBindingCopyWithImpl;
@override @useResult
$Res call({
 List<String> profiles,@JsonKey(name: 'default', includeIfNull: false) String? defaultProfile,@JsonKey(includeIfNull: false) String? profile, RcxPool pool,@JsonKey(includeIfNull: false) String? feel,@JsonKey(includeIfNull: false) String? energy, List<RcxChip> chips, bool directSplit
});


@override $RcxPoolCopyWith<$Res> get pool;

}
/// @nodoc
class __$RcxBindingCopyWithImpl<$Res>
    implements _$RcxBindingCopyWith<$Res> {
  __$RcxBindingCopyWithImpl(this._self, this._then);

  final _RcxBinding _self;
  final $Res Function(_RcxBinding) _then;

/// Create a copy of RcxBinding
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? profiles = null,Object? defaultProfile = freezed,Object? profile = freezed,Object? pool = null,Object? feel = freezed,Object? energy = freezed,Object? chips = null,Object? directSplit = null,}) {
  return _then(_RcxBinding(
profiles: null == profiles ? _self._profiles : profiles // ignore: cast_nullable_to_non_nullable
as List<String>,defaultProfile: freezed == defaultProfile ? _self.defaultProfile : defaultProfile // ignore: cast_nullable_to_non_nullable
as String?,profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as String?,pool: null == pool ? _self.pool : pool // ignore: cast_nullable_to_non_nullable
as RcxPool,feel: freezed == feel ? _self.feel : feel // ignore: cast_nullable_to_non_nullable
as String?,energy: freezed == energy ? _self.energy : energy // ignore: cast_nullable_to_non_nullable
as String?,chips: null == chips ? _self._chips : chips // ignore: cast_nullable_to_non_nullable
as List<RcxChip>,directSplit: null == directSplit ? _self.directSplit : directSplit // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of RcxBinding
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RcxPoolCopyWith<$Res> get pool {
  
  return $RcxPoolCopyWith<$Res>(_self.pool, (value) {
    return _then(_self.copyWith(pool: value));
  });
}
}


/// @nodoc
mixin _$RcxUserLayer {

 Map<String, RcxBinding> get groups; Map<String, String> get profiles; Map<String, String> get scenarios;@JsonKey(includeIfNull: false) String? get scenario; bool get scenarioOff;/// The user chose the tunnel mode, so the scenario no longer sets it.
 bool get manualMode; List<String> get providerHosts; List<String> get trusted;
/// Create a copy of RcxUserLayer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RcxUserLayerCopyWith<RcxUserLayer> get copyWith => _$RcxUserLayerCopyWithImpl<RcxUserLayer>(this as RcxUserLayer, _$identity);

  /// Serializes this RcxUserLayer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RcxUserLayer;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RcxUserLayer&&const DeepCollectionEquality().equals(other.groups, _this.groups)&&const DeepCollectionEquality().equals(other.profiles, _this.profiles)&&const DeepCollectionEquality().equals(other.scenarios, _this.scenarios)&&(identical(other.scenario, _this.scenario) || other.scenario == _this.scenario)&&(identical(other.scenarioOff, _this.scenarioOff) || other.scenarioOff == _this.scenarioOff)&&(identical(other.manualMode, _this.manualMode) || other.manualMode == _this.manualMode)&&const DeepCollectionEquality().equals(other.providerHosts, _this.providerHosts)&&const DeepCollectionEquality().equals(other.trusted, _this.trusted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RcxUserLayer;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.groups),const DeepCollectionEquality().hash(_this.profiles),const DeepCollectionEquality().hash(_this.scenarios),_this.scenario,_this.scenarioOff,_this.manualMode,const DeepCollectionEquality().hash(_this.providerHosts),const DeepCollectionEquality().hash(_this.trusted));
}

@override
String toString() {
  final _this = this as RcxUserLayer;
  return 'RcxUserLayer(groups: ${_this.groups}, profiles: ${_this.profiles}, scenarios: ${_this.scenarios}, scenario: ${_this.scenario}, scenarioOff: ${_this.scenarioOff}, manualMode: ${_this.manualMode}, providerHosts: ${_this.providerHosts}, trusted: ${_this.trusted})';
}


}

/// @nodoc
abstract mixin class $RcxUserLayerCopyWith<$Res>  {
  factory $RcxUserLayerCopyWith(RcxUserLayer value, $Res Function(RcxUserLayer) _then) = _$RcxUserLayerCopyWithImpl;
@useResult
$Res call({
 Map<String, RcxBinding> groups, Map<String, String> profiles, Map<String, String> scenarios,@JsonKey(includeIfNull: false) String? scenario, bool scenarioOff, bool manualMode, List<String> providerHosts, List<String> trusted
});




}
/// @nodoc
class _$RcxUserLayerCopyWithImpl<$Res>
    implements $RcxUserLayerCopyWith<$Res> {
  _$RcxUserLayerCopyWithImpl(this._self, this._then);

  final RcxUserLayer _self;
  final $Res Function(RcxUserLayer) _then;

/// Create a copy of RcxUserLayer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? groups = null,Object? profiles = null,Object? scenarios = null,Object? scenario = freezed,Object? scenarioOff = null,Object? manualMode = null,Object? providerHosts = null,Object? trusted = null,}) {
  return _then(RcxUserLayer(
groups: null == groups ? _self.groups : groups // ignore: cast_nullable_to_non_nullable
as Map<String, RcxBinding>,profiles: null == profiles ? _self.profiles : profiles // ignore: cast_nullable_to_non_nullable
as Map<String, String>,scenarios: null == scenarios ? _self.scenarios : scenarios // ignore: cast_nullable_to_non_nullable
as Map<String, String>,scenario: freezed == scenario ? _self.scenario : scenario // ignore: cast_nullable_to_non_nullable
as String?,scenarioOff: null == scenarioOff ? _self.scenarioOff : scenarioOff // ignore: cast_nullable_to_non_nullable
as bool,manualMode: null == manualMode ? _self.manualMode : manualMode // ignore: cast_nullable_to_non_nullable
as bool,providerHosts: null == providerHosts ? _self.providerHosts : providerHosts // ignore: cast_nullable_to_non_nullable
as List<String>,trusted: null == trusted ? _self.trusted : trusted // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [RcxUserLayer].
extension RcxUserLayerPatterns on RcxUserLayer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RcxUserLayer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RcxUserLayer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RcxUserLayer value)  $default,){
final _that = this;
switch (_that) {
case _RcxUserLayer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RcxUserLayer value)?  $default,){
final _that = this;
switch (_that) {
case _RcxUserLayer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, RcxBinding> groups,  Map<String, String> profiles,  Map<String, String> scenarios, @JsonKey(includeIfNull: false)  String? scenario,  bool scenarioOff,  bool manualMode,  List<String> providerHosts,  List<String> trusted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RcxUserLayer() when $default != null:
return $default(_that.groups,_that.profiles,_that.scenarios,_that.scenario,_that.scenarioOff,_that.manualMode,_that.providerHosts,_that.trusted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, RcxBinding> groups,  Map<String, String> profiles,  Map<String, String> scenarios, @JsonKey(includeIfNull: false)  String? scenario,  bool scenarioOff,  bool manualMode,  List<String> providerHosts,  List<String> trusted)  $default,) {final _that = this;
switch (_that) {
case _RcxUserLayer():
return $default(_that.groups,_that.profiles,_that.scenarios,_that.scenario,_that.scenarioOff,_that.manualMode,_that.providerHosts,_that.trusted);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, RcxBinding> groups,  Map<String, String> profiles,  Map<String, String> scenarios, @JsonKey(includeIfNull: false)  String? scenario,  bool scenarioOff,  bool manualMode,  List<String> providerHosts,  List<String> trusted)?  $default,) {final _that = this;
switch (_that) {
case _RcxUserLayer() when $default != null:
return $default(_that.groups,_that.profiles,_that.scenarios,_that.scenario,_that.scenarioOff,_that.manualMode,_that.providerHosts,_that.trusted);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RcxUserLayer implements RcxUserLayer {
  const _RcxUserLayer({ Map<String, RcxBinding> groups = const {},  Map<String, String> profiles = const {},  Map<String, String> scenarios = const {}, @JsonKey(includeIfNull: false) this.scenario, this.scenarioOff = false, this.manualMode = false,  List<String> providerHosts = const [],  List<String> trusted = const []}): _groups = groups,_profiles = profiles,_scenarios = scenarios,_providerHosts = providerHosts,_trusted = trusted;
  factory _RcxUserLayer.fromJson(Map<String, dynamic> json) => _$RcxUserLayerFromJson(json);

 final  Map<String, RcxBinding> _groups;
@override@JsonKey() Map<String, RcxBinding> get groups {
  if (_groups is EqualUnmodifiableMapView) return _groups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_groups);
}

 final  Map<String, String> _profiles;
@override@JsonKey() Map<String, String> get profiles {
  if (_profiles is EqualUnmodifiableMapView) return _profiles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_profiles);
}

 final  Map<String, String> _scenarios;
@override@JsonKey() Map<String, String> get scenarios {
  if (_scenarios is EqualUnmodifiableMapView) return _scenarios;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_scenarios);
}

@override@JsonKey(includeIfNull: false) final  String? scenario;
@override@JsonKey() final  bool scenarioOff;
/// The user chose the tunnel mode, so the scenario no longer sets it.
@override@JsonKey() final  bool manualMode;
 final  List<String> _providerHosts;
@override@JsonKey() List<String> get providerHosts {
  if (_providerHosts is EqualUnmodifiableListView) return _providerHosts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_providerHosts);
}

 final  List<String> _trusted;
@override@JsonKey() List<String> get trusted {
  if (_trusted is EqualUnmodifiableListView) return _trusted;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_trusted);
}


/// Create a copy of RcxUserLayer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RcxUserLayerCopyWith<_RcxUserLayer> get copyWith => __$RcxUserLayerCopyWithImpl<_RcxUserLayer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RcxUserLayerToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RcxUserLayer&&const DeepCollectionEquality().equals(other.groups, _groups)&&const DeepCollectionEquality().equals(other.profiles, _profiles)&&const DeepCollectionEquality().equals(other.scenarios, _scenarios)&&(identical(other.scenario, scenario) || other.scenario == scenario)&&(identical(other.scenarioOff, scenarioOff) || other.scenarioOff == scenarioOff)&&(identical(other.manualMode, manualMode) || other.manualMode == manualMode)&&const DeepCollectionEquality().equals(other.providerHosts, _providerHosts)&&const DeepCollectionEquality().equals(other.trusted, _trusted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_groups),const DeepCollectionEquality().hash(_profiles),const DeepCollectionEquality().hash(_scenarios),scenario,scenarioOff,manualMode,const DeepCollectionEquality().hash(_providerHosts),const DeepCollectionEquality().hash(_trusted));
}

@override
String toString() {
    return 'RcxUserLayer(groups: $groups, profiles: $profiles, scenarios: $scenarios, scenario: $scenario, scenarioOff: $scenarioOff, manualMode: $manualMode, providerHosts: $providerHosts, trusted: $trusted)';
}


}

/// @nodoc
abstract mixin class _$RcxUserLayerCopyWith<$Res> implements $RcxUserLayerCopyWith<$Res> {
  factory _$RcxUserLayerCopyWith(_RcxUserLayer value, $Res Function(_RcxUserLayer) _then) = __$RcxUserLayerCopyWithImpl;
@override @useResult
$Res call({
 Map<String, RcxBinding> groups, Map<String, String> profiles, Map<String, String> scenarios,@JsonKey(includeIfNull: false) String? scenario, bool scenarioOff, bool manualMode, List<String> providerHosts, List<String> trusted
});




}
/// @nodoc
class __$RcxUserLayerCopyWithImpl<$Res>
    implements _$RcxUserLayerCopyWith<$Res> {
  __$RcxUserLayerCopyWithImpl(this._self, this._then);

  final _RcxUserLayer _self;
  final $Res Function(_RcxUserLayer) _then;

/// Create a copy of RcxUserLayer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? groups = null,Object? profiles = null,Object? scenarios = null,Object? scenario = freezed,Object? scenarioOff = null,Object? manualMode = null,Object? providerHosts = null,Object? trusted = null,}) {
  return _then(_RcxUserLayer(
groups: null == groups ? _self._groups : groups // ignore: cast_nullable_to_non_nullable
as Map<String, RcxBinding>,profiles: null == profiles ? _self._profiles : profiles // ignore: cast_nullable_to_non_nullable
as Map<String, String>,scenarios: null == scenarios ? _self._scenarios : scenarios // ignore: cast_nullable_to_non_nullable
as Map<String, String>,scenario: freezed == scenario ? _self.scenario : scenario // ignore: cast_nullable_to_non_nullable
as String?,scenarioOff: null == scenarioOff ? _self.scenarioOff : scenarioOff // ignore: cast_nullable_to_non_nullable
as bool,manualMode: null == manualMode ? _self.manualMode : manualMode // ignore: cast_nullable_to_non_nullable
as bool,providerHosts: null == providerHosts ? _self._providerHosts : providerHosts // ignore: cast_nullable_to_non_nullable
as List<String>,trusted: null == trusted ? _self._trusted : trusted // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$RcxReason {

 String get code; Map<String, Object?> get args;
/// Create a copy of RcxReason
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RcxReasonCopyWith<RcxReason> get copyWith => _$RcxReasonCopyWithImpl<RcxReason>(this as RcxReason, _$identity);

  /// Serializes this RcxReason to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RcxReason;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RcxReason&&(identical(other.code, _this.code) || other.code == _this.code)&&const DeepCollectionEquality().equals(other.args, _this.args));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RcxReason;
  return Object.hash(runtimeType,_this.code,const DeepCollectionEquality().hash(_this.args));
}

@override
String toString() {
  final _this = this as RcxReason;
  return 'RcxReason(code: ${_this.code}, args: ${_this.args})';
}


}

/// @nodoc
abstract mixin class $RcxReasonCopyWith<$Res>  {
  factory $RcxReasonCopyWith(RcxReason value, $Res Function(RcxReason) _then) = _$RcxReasonCopyWithImpl;
@useResult
$Res call({
 String code, Map<String, Object?> args
});




}
/// @nodoc
class _$RcxReasonCopyWithImpl<$Res>
    implements $RcxReasonCopyWith<$Res> {
  _$RcxReasonCopyWithImpl(this._self, this._then);

  final RcxReason _self;
  final $Res Function(RcxReason) _then;

/// Create a copy of RcxReason
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? args = null,}) {
  return _then(RcxReason(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,args: null == args ? _self.args : args // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [RcxReason].
extension RcxReasonPatterns on RcxReason {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RcxReason value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RcxReason() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RcxReason value)  $default,){
final _that = this;
switch (_that) {
case _RcxReason():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RcxReason value)?  $default,){
final _that = this;
switch (_that) {
case _RcxReason() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  Map<String, Object?> args)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RcxReason() when $default != null:
return $default(_that.code,_that.args);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  Map<String, Object?> args)  $default,) {final _that = this;
switch (_that) {
case _RcxReason():
return $default(_that.code,_that.args);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  Map<String, Object?> args)?  $default,) {final _that = this;
switch (_that) {
case _RcxReason() when $default != null:
return $default(_that.code,_that.args);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RcxReason implements RcxReason {
  const _RcxReason({required this.code,  Map<String, Object?> args = const {}}): _args = args;
  factory _RcxReason.fromJson(Map<String, dynamic> json) => _$RcxReasonFromJson(json);

@override final  String code;
 final  Map<String, Object?> _args;
@override@JsonKey() Map<String, Object?> get args {
  if (_args is EqualUnmodifiableMapView) return _args;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_args);
}


/// Create a copy of RcxReason
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RcxReasonCopyWith<_RcxReason> get copyWith => __$RcxReasonCopyWithImpl<_RcxReason>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RcxReasonToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RcxReason&&(identical(other.code, code) || other.code == code)&&const DeepCollectionEquality().equals(other.args, _args));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,code,const DeepCollectionEquality().hash(_args));
}

@override
String toString() {
    return 'RcxReason(code: $code, args: $args)';
}


}

/// @nodoc
abstract mixin class _$RcxReasonCopyWith<$Res> implements $RcxReasonCopyWith<$Res> {
  factory _$RcxReasonCopyWith(_RcxReason value, $Res Function(_RcxReason) _then) = __$RcxReasonCopyWithImpl;
@override @useResult
$Res call({
 String code, Map<String, Object?> args
});




}
/// @nodoc
class __$RcxReasonCopyWithImpl<$Res>
    implements _$RcxReasonCopyWith<$Res> {
  __$RcxReasonCopyWithImpl(this._self, this._then);

  final _RcxReason _self;
  final $Res Function(_RcxReason) _then;

/// Create a copy of RcxReason
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? args = null,}) {
  return _then(_RcxReason(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,args: null == args ? _self._args : args // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}


}


/// @nodoc
mixin _$RcxRanked {

 String get name; int get tier; String get tierLabel; String get health; int get latencyMs; int get spreadMs; int get episodes; DateTime? get checkedAt; bool get current; RcxReason? get excluded; String get exit;/// Check id to pass, fail or soft; unknown checks are absent.
 Map<String, String> get checks;/// The better tier the node may reach once checked.
 String get pending;
/// Create a copy of RcxRanked
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RcxRankedCopyWith<RcxRanked> get copyWith => _$RcxRankedCopyWithImpl<RcxRanked>(this as RcxRanked, _$identity);

  /// Serializes this RcxRanked to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RcxRanked;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RcxRanked&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.tier, _this.tier) || other.tier == _this.tier)&&(identical(other.tierLabel, _this.tierLabel) || other.tierLabel == _this.tierLabel)&&(identical(other.health, _this.health) || other.health == _this.health)&&(identical(other.latencyMs, _this.latencyMs) || other.latencyMs == _this.latencyMs)&&(identical(other.spreadMs, _this.spreadMs) || other.spreadMs == _this.spreadMs)&&(identical(other.episodes, _this.episodes) || other.episodes == _this.episodes)&&(identical(other.checkedAt, _this.checkedAt) || other.checkedAt == _this.checkedAt)&&(identical(other.current, _this.current) || other.current == _this.current)&&(identical(other.excluded, _this.excluded) || other.excluded == _this.excluded)&&(identical(other.exit, _this.exit) || other.exit == _this.exit)&&const DeepCollectionEquality().equals(other.checks, _this.checks)&&(identical(other.pending, _this.pending) || other.pending == _this.pending));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RcxRanked;
  return Object.hash(runtimeType,_this.name,_this.tier,_this.tierLabel,_this.health,_this.latencyMs,_this.spreadMs,_this.episodes,_this.checkedAt,_this.current,_this.excluded,_this.exit,const DeepCollectionEquality().hash(_this.checks),_this.pending);
}

@override
String toString() {
  final _this = this as RcxRanked;
  return 'RcxRanked(name: ${_this.name}, tier: ${_this.tier}, tierLabel: ${_this.tierLabel}, health: ${_this.health}, latencyMs: ${_this.latencyMs}, spreadMs: ${_this.spreadMs}, episodes: ${_this.episodes}, checkedAt: ${_this.checkedAt}, current: ${_this.current}, excluded: ${_this.excluded}, exit: ${_this.exit}, checks: ${_this.checks}, pending: ${_this.pending})';
}


}

/// @nodoc
abstract mixin class $RcxRankedCopyWith<$Res>  {
  factory $RcxRankedCopyWith(RcxRanked value, $Res Function(RcxRanked) _then) = _$RcxRankedCopyWithImpl;
@useResult
$Res call({
 String name, int tier, String tierLabel, String health, int latencyMs, int spreadMs, int episodes, DateTime? checkedAt, bool current, RcxReason? excluded, String exit, Map<String, String> checks, String pending
});


$RcxReasonCopyWith<$Res>? get excluded;

}
/// @nodoc
class _$RcxRankedCopyWithImpl<$Res>
    implements $RcxRankedCopyWith<$Res> {
  _$RcxRankedCopyWithImpl(this._self, this._then);

  final RcxRanked _self;
  final $Res Function(RcxRanked) _then;

/// Create a copy of RcxRanked
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? tier = null,Object? tierLabel = null,Object? health = null,Object? latencyMs = null,Object? spreadMs = null,Object? episodes = null,Object? checkedAt = freezed,Object? current = null,Object? excluded = freezed,Object? exit = null,Object? checks = null,Object? pending = null,}) {
  return _then(RcxRanked(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as int,tierLabel: null == tierLabel ? _self.tierLabel : tierLabel // ignore: cast_nullable_to_non_nullable
as String,health: null == health ? _self.health : health // ignore: cast_nullable_to_non_nullable
as String,latencyMs: null == latencyMs ? _self.latencyMs : latencyMs // ignore: cast_nullable_to_non_nullable
as int,spreadMs: null == spreadMs ? _self.spreadMs : spreadMs // ignore: cast_nullable_to_non_nullable
as int,episodes: null == episodes ? _self.episodes : episodes // ignore: cast_nullable_to_non_nullable
as int,checkedAt: freezed == checkedAt ? _self.checkedAt : checkedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as bool,excluded: freezed == excluded ? _self.excluded : excluded // ignore: cast_nullable_to_non_nullable
as RcxReason?,exit: null == exit ? _self.exit : exit // ignore: cast_nullable_to_non_nullable
as String,checks: null == checks ? _self.checks : checks // ignore: cast_nullable_to_non_nullable
as Map<String, String>,pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of RcxRanked
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RcxReasonCopyWith<$Res>? get excluded {
    if (_self.excluded == null) {
    return null;
  }

  return $RcxReasonCopyWith<$Res>(_self.excluded!, (value) {
    return _then(_self.copyWith(excluded: value));
  });
}
}


/// Adds pattern-matching-related methods to [RcxRanked].
extension RcxRankedPatterns on RcxRanked {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RcxRanked value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RcxRanked() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RcxRanked value)  $default,){
final _that = this;
switch (_that) {
case _RcxRanked():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RcxRanked value)?  $default,){
final _that = this;
switch (_that) {
case _RcxRanked() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  int tier,  String tierLabel,  String health,  int latencyMs,  int spreadMs,  int episodes,  DateTime? checkedAt,  bool current,  RcxReason? excluded,  String exit,  Map<String, String> checks,  String pending)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RcxRanked() when $default != null:
return $default(_that.name,_that.tier,_that.tierLabel,_that.health,_that.latencyMs,_that.spreadMs,_that.episodes,_that.checkedAt,_that.current,_that.excluded,_that.exit,_that.checks,_that.pending);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  int tier,  String tierLabel,  String health,  int latencyMs,  int spreadMs,  int episodes,  DateTime? checkedAt,  bool current,  RcxReason? excluded,  String exit,  Map<String, String> checks,  String pending)  $default,) {final _that = this;
switch (_that) {
case _RcxRanked():
return $default(_that.name,_that.tier,_that.tierLabel,_that.health,_that.latencyMs,_that.spreadMs,_that.episodes,_that.checkedAt,_that.current,_that.excluded,_that.exit,_that.checks,_that.pending);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  int tier,  String tierLabel,  String health,  int latencyMs,  int spreadMs,  int episodes,  DateTime? checkedAt,  bool current,  RcxReason? excluded,  String exit,  Map<String, String> checks,  String pending)?  $default,) {final _that = this;
switch (_that) {
case _RcxRanked() when $default != null:
return $default(_that.name,_that.tier,_that.tierLabel,_that.health,_that.latencyMs,_that.spreadMs,_that.episodes,_that.checkedAt,_that.current,_that.excluded,_that.exit,_that.checks,_that.pending);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RcxRanked implements RcxRanked {
  const _RcxRanked({required this.name, this.tier = 0, this.tierLabel = '', this.health = 'unknown', this.latencyMs = 0, this.spreadMs = 0, this.episodes = 0, this.checkedAt, this.current = false, this.excluded, this.exit = '',  Map<String, String> checks = const {}, this.pending = ''}): _checks = checks;
  factory _RcxRanked.fromJson(Map<String, dynamic> json) => _$RcxRankedFromJson(json);

@override final  String name;
@override@JsonKey() final  int tier;
@override@JsonKey() final  String tierLabel;
@override@JsonKey() final  String health;
@override@JsonKey() final  int latencyMs;
@override@JsonKey() final  int spreadMs;
@override@JsonKey() final  int episodes;
@override final  DateTime? checkedAt;
@override@JsonKey() final  bool current;
@override final  RcxReason? excluded;
@override@JsonKey() final  String exit;
/// Check id to pass, fail or soft; unknown checks are absent.
 final  Map<String, String> _checks;
/// Check id to pass, fail or soft; unknown checks are absent.
@override@JsonKey() Map<String, String> get checks {
  if (_checks is EqualUnmodifiableMapView) return _checks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_checks);
}

/// The better tier the node may reach once checked.
@override@JsonKey() final  String pending;

/// Create a copy of RcxRanked
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RcxRankedCopyWith<_RcxRanked> get copyWith => __$RcxRankedCopyWithImpl<_RcxRanked>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RcxRankedToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RcxRanked&&(identical(other.name, name) || other.name == name)&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.tierLabel, tierLabel) || other.tierLabel == tierLabel)&&(identical(other.health, health) || other.health == health)&&(identical(other.latencyMs, latencyMs) || other.latencyMs == latencyMs)&&(identical(other.spreadMs, spreadMs) || other.spreadMs == spreadMs)&&(identical(other.episodes, episodes) || other.episodes == episodes)&&(identical(other.checkedAt, checkedAt) || other.checkedAt == checkedAt)&&(identical(other.current, current) || other.current == current)&&(identical(other.excluded, excluded) || other.excluded == excluded)&&(identical(other.exit, exit) || other.exit == exit)&&const DeepCollectionEquality().equals(other.checks, _checks)&&(identical(other.pending, pending) || other.pending == pending));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,tier,tierLabel,health,latencyMs,spreadMs,episodes,checkedAt,current,excluded,exit,const DeepCollectionEquality().hash(_checks),pending);
}

@override
String toString() {
    return 'RcxRanked(name: $name, tier: $tier, tierLabel: $tierLabel, health: $health, latencyMs: $latencyMs, spreadMs: $spreadMs, episodes: $episodes, checkedAt: $checkedAt, current: $current, excluded: $excluded, exit: $exit, checks: $checks, pending: $pending)';
}


}

/// @nodoc
abstract mixin class _$RcxRankedCopyWith<$Res> implements $RcxRankedCopyWith<$Res> {
  factory _$RcxRankedCopyWith(_RcxRanked value, $Res Function(_RcxRanked) _then) = __$RcxRankedCopyWithImpl;
@override @useResult
$Res call({
 String name, int tier, String tierLabel, String health, int latencyMs, int spreadMs, int episodes, DateTime? checkedAt, bool current, RcxReason? excluded, String exit, Map<String, String> checks, String pending
});


@override $RcxReasonCopyWith<$Res>? get excluded;

}
/// @nodoc
class __$RcxRankedCopyWithImpl<$Res>
    implements _$RcxRankedCopyWith<$Res> {
  __$RcxRankedCopyWithImpl(this._self, this._then);

  final _RcxRanked _self;
  final $Res Function(_RcxRanked) _then;

/// Create a copy of RcxRanked
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? tier = null,Object? tierLabel = null,Object? health = null,Object? latencyMs = null,Object? spreadMs = null,Object? episodes = null,Object? checkedAt = freezed,Object? current = null,Object? excluded = freezed,Object? exit = null,Object? checks = null,Object? pending = null,}) {
  return _then(_RcxRanked(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as int,tierLabel: null == tierLabel ? _self.tierLabel : tierLabel // ignore: cast_nullable_to_non_nullable
as String,health: null == health ? _self.health : health // ignore: cast_nullable_to_non_nullable
as String,latencyMs: null == latencyMs ? _self.latencyMs : latencyMs // ignore: cast_nullable_to_non_nullable
as int,spreadMs: null == spreadMs ? _self.spreadMs : spreadMs // ignore: cast_nullable_to_non_nullable
as int,episodes: null == episodes ? _self.episodes : episodes // ignore: cast_nullable_to_non_nullable
as int,checkedAt: freezed == checkedAt ? _self.checkedAt : checkedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as bool,excluded: freezed == excluded ? _self.excluded : excluded // ignore: cast_nullable_to_non_nullable
as RcxReason?,exit: null == exit ? _self.exit : exit // ignore: cast_nullable_to_non_nullable
as String,checks: null == checks ? _self._checks : checks // ignore: cast_nullable_to_non_nullable
as Map<String, String>,pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of RcxRanked
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RcxReasonCopyWith<$Res>? get excluded {
    if (_self.excluded == null) {
    return null;
  }

  return $RcxReasonCopyWith<$Res>(_self.excluded!, (value) {
    return _then(_self.copyWith(excluded: value));
  });
}
}


/// @nodoc
mixin _$RcxDecision {

 String get action; String get target; RcxReason get reason; String get tier; RcxReason? get until; List<RcxRanked> get ranking;
/// Create a copy of RcxDecision
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RcxDecisionCopyWith<RcxDecision> get copyWith => _$RcxDecisionCopyWithImpl<RcxDecision>(this as RcxDecision, _$identity);

  /// Serializes this RcxDecision to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RcxDecision;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RcxDecision&&(identical(other.action, _this.action) || other.action == _this.action)&&(identical(other.target, _this.target) || other.target == _this.target)&&(identical(other.reason, _this.reason) || other.reason == _this.reason)&&(identical(other.tier, _this.tier) || other.tier == _this.tier)&&(identical(other.until, _this.until) || other.until == _this.until)&&const DeepCollectionEquality().equals(other.ranking, _this.ranking));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RcxDecision;
  return Object.hash(runtimeType,_this.action,_this.target,_this.reason,_this.tier,_this.until,const DeepCollectionEquality().hash(_this.ranking));
}

@override
String toString() {
  final _this = this as RcxDecision;
  return 'RcxDecision(action: ${_this.action}, target: ${_this.target}, reason: ${_this.reason}, tier: ${_this.tier}, until: ${_this.until}, ranking: ${_this.ranking})';
}


}

/// @nodoc
abstract mixin class $RcxDecisionCopyWith<$Res>  {
  factory $RcxDecisionCopyWith(RcxDecision value, $Res Function(RcxDecision) _then) = _$RcxDecisionCopyWithImpl;
@useResult
$Res call({
 String action, String target, RcxReason reason, String tier, RcxReason? until, List<RcxRanked> ranking
});


$RcxReasonCopyWith<$Res> get reason;$RcxReasonCopyWith<$Res>? get until;

}
/// @nodoc
class _$RcxDecisionCopyWithImpl<$Res>
    implements $RcxDecisionCopyWith<$Res> {
  _$RcxDecisionCopyWithImpl(this._self, this._then);

  final RcxDecision _self;
  final $Res Function(RcxDecision) _then;

/// Create a copy of RcxDecision
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? action = null,Object? target = null,Object? reason = null,Object? tier = null,Object? until = freezed,Object? ranking = null,}) {
  return _then(RcxDecision(
action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as RcxReason,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as String,until: freezed == until ? _self.until : until // ignore: cast_nullable_to_non_nullable
as RcxReason?,ranking: null == ranking ? _self.ranking : ranking // ignore: cast_nullable_to_non_nullable
as List<RcxRanked>,
  ));
}
/// Create a copy of RcxDecision
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RcxReasonCopyWith<$Res> get reason {
  
  return $RcxReasonCopyWith<$Res>(_self.reason, (value) {
    return _then(_self.copyWith(reason: value));
  });
}/// Create a copy of RcxDecision
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RcxReasonCopyWith<$Res>? get until {
    if (_self.until == null) {
    return null;
  }

  return $RcxReasonCopyWith<$Res>(_self.until!, (value) {
    return _then(_self.copyWith(until: value));
  });
}
}


/// Adds pattern-matching-related methods to [RcxDecision].
extension RcxDecisionPatterns on RcxDecision {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RcxDecision value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RcxDecision() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RcxDecision value)  $default,){
final _that = this;
switch (_that) {
case _RcxDecision():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RcxDecision value)?  $default,){
final _that = this;
switch (_that) {
case _RcxDecision() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String action,  String target,  RcxReason reason,  String tier,  RcxReason? until,  List<RcxRanked> ranking)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RcxDecision() when $default != null:
return $default(_that.action,_that.target,_that.reason,_that.tier,_that.until,_that.ranking);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String action,  String target,  RcxReason reason,  String tier,  RcxReason? until,  List<RcxRanked> ranking)  $default,) {final _that = this;
switch (_that) {
case _RcxDecision():
return $default(_that.action,_that.target,_that.reason,_that.tier,_that.until,_that.ranking);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String action,  String target,  RcxReason reason,  String tier,  RcxReason? until,  List<RcxRanked> ranking)?  $default,) {final _that = this;
switch (_that) {
case _RcxDecision() when $default != null:
return $default(_that.action,_that.target,_that.reason,_that.tier,_that.until,_that.ranking);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RcxDecision implements RcxDecision {
  const _RcxDecision({this.action = 'hold', this.target = '', this.reason = const RcxReason(code: ''), this.tier = '', this.until,  List<RcxRanked> ranking = const []}): _ranking = ranking;
  factory _RcxDecision.fromJson(Map<String, dynamic> json) => _$RcxDecisionFromJson(json);

@override@JsonKey() final  String action;
@override@JsonKey() final  String target;
@override@JsonKey() final  RcxReason reason;
@override@JsonKey() final  String tier;
@override final  RcxReason? until;
 final  List<RcxRanked> _ranking;
@override@JsonKey() List<RcxRanked> get ranking {
  if (_ranking is EqualUnmodifiableListView) return _ranking;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ranking);
}


/// Create a copy of RcxDecision
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RcxDecisionCopyWith<_RcxDecision> get copyWith => __$RcxDecisionCopyWithImpl<_RcxDecision>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RcxDecisionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RcxDecision&&(identical(other.action, action) || other.action == action)&&(identical(other.target, target) || other.target == target)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.until, until) || other.until == until)&&const DeepCollectionEquality().equals(other.ranking, _ranking));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,action,target,reason,tier,until,const DeepCollectionEquality().hash(_ranking));
}

@override
String toString() {
    return 'RcxDecision(action: $action, target: $target, reason: $reason, tier: $tier, until: $until, ranking: $ranking)';
}


}

/// @nodoc
abstract mixin class _$RcxDecisionCopyWith<$Res> implements $RcxDecisionCopyWith<$Res> {
  factory _$RcxDecisionCopyWith(_RcxDecision value, $Res Function(_RcxDecision) _then) = __$RcxDecisionCopyWithImpl;
@override @useResult
$Res call({
 String action, String target, RcxReason reason, String tier, RcxReason? until, List<RcxRanked> ranking
});


@override $RcxReasonCopyWith<$Res> get reason;@override $RcxReasonCopyWith<$Res>? get until;

}
/// @nodoc
class __$RcxDecisionCopyWithImpl<$Res>
    implements _$RcxDecisionCopyWith<$Res> {
  __$RcxDecisionCopyWithImpl(this._self, this._then);

  final _RcxDecision _self;
  final $Res Function(_RcxDecision) _then;

/// Create a copy of RcxDecision
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? action = null,Object? target = null,Object? reason = null,Object? tier = null,Object? until = freezed,Object? ranking = null,}) {
  return _then(_RcxDecision(
action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as RcxReason,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as String,until: freezed == until ? _self.until : until // ignore: cast_nullable_to_non_nullable
as RcxReason?,ranking: null == ranking ? _self._ranking : ranking // ignore: cast_nullable_to_non_nullable
as List<RcxRanked>,
  ));
}

/// Create a copy of RcxDecision
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RcxReasonCopyWith<$Res> get reason {
  
  return $RcxReasonCopyWith<$Res>(_self.reason, (value) {
    return _then(_self.copyWith(reason: value));
  });
}/// Create a copy of RcxDecision
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RcxReasonCopyWith<$Res>? get until {
    if (_self.until == null) {
    return null;
  }

  return $RcxReasonCopyWith<$Res>(_self.until!, (value) {
    return _then(_self.copyWith(until: value));
  });
}
}


/// @nodoc
mixin _$RcxControl {

 String get mode; String get pinName; String get pinEnv;
/// Create a copy of RcxControl
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RcxControlCopyWith<RcxControl> get copyWith => _$RcxControlCopyWithImpl<RcxControl>(this as RcxControl, _$identity);

  /// Serializes this RcxControl to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RcxControl;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RcxControl&&(identical(other.mode, _this.mode) || other.mode == _this.mode)&&(identical(other.pinName, _this.pinName) || other.pinName == _this.pinName)&&(identical(other.pinEnv, _this.pinEnv) || other.pinEnv == _this.pinEnv));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RcxControl;
  return Object.hash(runtimeType,_this.mode,_this.pinName,_this.pinEnv);
}

@override
String toString() {
  final _this = this as RcxControl;
  return 'RcxControl(mode: ${_this.mode}, pinName: ${_this.pinName}, pinEnv: ${_this.pinEnv})';
}


}

/// @nodoc
abstract mixin class $RcxControlCopyWith<$Res>  {
  factory $RcxControlCopyWith(RcxControl value, $Res Function(RcxControl) _then) = _$RcxControlCopyWithImpl;
@useResult
$Res call({
 String mode, String pinName, String pinEnv
});




}
/// @nodoc
class _$RcxControlCopyWithImpl<$Res>
    implements $RcxControlCopyWith<$Res> {
  _$RcxControlCopyWithImpl(this._self, this._then);

  final RcxControl _self;
  final $Res Function(RcxControl) _then;

/// Create a copy of RcxControl
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mode = null,Object? pinName = null,Object? pinEnv = null,}) {
  return _then(RcxControl(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as String,pinName: null == pinName ? _self.pinName : pinName // ignore: cast_nullable_to_non_nullable
as String,pinEnv: null == pinEnv ? _self.pinEnv : pinEnv // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RcxControl].
extension RcxControlPatterns on RcxControl {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RcxControl value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RcxControl() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RcxControl value)  $default,){
final _that = this;
switch (_that) {
case _RcxControl():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RcxControl value)?  $default,){
final _that = this;
switch (_that) {
case _RcxControl() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String mode,  String pinName,  String pinEnv)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RcxControl() when $default != null:
return $default(_that.mode,_that.pinName,_that.pinEnv);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String mode,  String pinName,  String pinEnv)  $default,) {final _that = this;
switch (_that) {
case _RcxControl():
return $default(_that.mode,_that.pinName,_that.pinEnv);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String mode,  String pinName,  String pinEnv)?  $default,) {final _that = this;
switch (_that) {
case _RcxControl() when $default != null:
return $default(_that.mode,_that.pinName,_that.pinEnv);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RcxControl implements RcxControl {
  const _RcxControl({this.mode = 'auto', this.pinName = '', this.pinEnv = ''});
  factory _RcxControl.fromJson(Map<String, dynamic> json) => _$RcxControlFromJson(json);

@override@JsonKey() final  String mode;
@override@JsonKey() final  String pinName;
@override@JsonKey() final  String pinEnv;

/// Create a copy of RcxControl
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RcxControlCopyWith<_RcxControl> get copyWith => __$RcxControlCopyWithImpl<_RcxControl>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RcxControlToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RcxControl&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.pinName, pinName) || other.pinName == pinName)&&(identical(other.pinEnv, pinEnv) || other.pinEnv == pinEnv));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,mode,pinName,pinEnv);
}

@override
String toString() {
    return 'RcxControl(mode: $mode, pinName: $pinName, pinEnv: $pinEnv)';
}


}

/// @nodoc
abstract mixin class _$RcxControlCopyWith<$Res> implements $RcxControlCopyWith<$Res> {
  factory _$RcxControlCopyWith(_RcxControl value, $Res Function(_RcxControl) _then) = __$RcxControlCopyWithImpl;
@override @useResult
$Res call({
 String mode, String pinName, String pinEnv
});




}
/// @nodoc
class __$RcxControlCopyWithImpl<$Res>
    implements _$RcxControlCopyWith<$Res> {
  __$RcxControlCopyWithImpl(this._self, this._then);

  final _RcxControl _self;
  final $Res Function(_RcxControl) _then;

/// Create a copy of RcxControl
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mode = null,Object? pinName = null,Object? pinEnv = null,}) {
  return _then(_RcxControl(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as String,pinName: null == pinName ? _self.pinName : pinName // ignore: cast_nullable_to_non_nullable
as String,pinEnv: null == pinEnv ? _self.pinEnv : pinEnv // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$RcxCurrentNode {

 String get name; int get latencyMs; String get health; DateTime? get since; String get exit;
/// Create a copy of RcxCurrentNode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RcxCurrentNodeCopyWith<RcxCurrentNode> get copyWith => _$RcxCurrentNodeCopyWithImpl<RcxCurrentNode>(this as RcxCurrentNode, _$identity);

  /// Serializes this RcxCurrentNode to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RcxCurrentNode;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RcxCurrentNode&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.latencyMs, _this.latencyMs) || other.latencyMs == _this.latencyMs)&&(identical(other.health, _this.health) || other.health == _this.health)&&(identical(other.since, _this.since) || other.since == _this.since)&&(identical(other.exit, _this.exit) || other.exit == _this.exit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RcxCurrentNode;
  return Object.hash(runtimeType,_this.name,_this.latencyMs,_this.health,_this.since,_this.exit);
}

@override
String toString() {
  final _this = this as RcxCurrentNode;
  return 'RcxCurrentNode(name: ${_this.name}, latencyMs: ${_this.latencyMs}, health: ${_this.health}, since: ${_this.since}, exit: ${_this.exit})';
}


}

/// @nodoc
abstract mixin class $RcxCurrentNodeCopyWith<$Res>  {
  factory $RcxCurrentNodeCopyWith(RcxCurrentNode value, $Res Function(RcxCurrentNode) _then) = _$RcxCurrentNodeCopyWithImpl;
@useResult
$Res call({
 String name, int latencyMs, String health, DateTime? since, String exit
});




}
/// @nodoc
class _$RcxCurrentNodeCopyWithImpl<$Res>
    implements $RcxCurrentNodeCopyWith<$Res> {
  _$RcxCurrentNodeCopyWithImpl(this._self, this._then);

  final RcxCurrentNode _self;
  final $Res Function(RcxCurrentNode) _then;

/// Create a copy of RcxCurrentNode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? latencyMs = null,Object? health = null,Object? since = freezed,Object? exit = null,}) {
  return _then(RcxCurrentNode(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,latencyMs: null == latencyMs ? _self.latencyMs : latencyMs // ignore: cast_nullable_to_non_nullable
as int,health: null == health ? _self.health : health // ignore: cast_nullable_to_non_nullable
as String,since: freezed == since ? _self.since : since // ignore: cast_nullable_to_non_nullable
as DateTime?,exit: null == exit ? _self.exit : exit // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RcxCurrentNode].
extension RcxCurrentNodePatterns on RcxCurrentNode {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RcxCurrentNode value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RcxCurrentNode() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RcxCurrentNode value)  $default,){
final _that = this;
switch (_that) {
case _RcxCurrentNode():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RcxCurrentNode value)?  $default,){
final _that = this;
switch (_that) {
case _RcxCurrentNode() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  int latencyMs,  String health,  DateTime? since,  String exit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RcxCurrentNode() when $default != null:
return $default(_that.name,_that.latencyMs,_that.health,_that.since,_that.exit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  int latencyMs,  String health,  DateTime? since,  String exit)  $default,) {final _that = this;
switch (_that) {
case _RcxCurrentNode():
return $default(_that.name,_that.latencyMs,_that.health,_that.since,_that.exit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  int latencyMs,  String health,  DateTime? since,  String exit)?  $default,) {final _that = this;
switch (_that) {
case _RcxCurrentNode() when $default != null:
return $default(_that.name,_that.latencyMs,_that.health,_that.since,_that.exit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RcxCurrentNode implements RcxCurrentNode {
  const _RcxCurrentNode({required this.name, this.latencyMs = 0, this.health = 'unknown', this.since, this.exit = ''});
  factory _RcxCurrentNode.fromJson(Map<String, dynamic> json) => _$RcxCurrentNodeFromJson(json);

@override final  String name;
@override@JsonKey() final  int latencyMs;
@override@JsonKey() final  String health;
@override final  DateTime? since;
@override@JsonKey() final  String exit;

/// Create a copy of RcxCurrentNode
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RcxCurrentNodeCopyWith<_RcxCurrentNode> get copyWith => __$RcxCurrentNodeCopyWithImpl<_RcxCurrentNode>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RcxCurrentNodeToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RcxCurrentNode&&(identical(other.name, name) || other.name == name)&&(identical(other.latencyMs, latencyMs) || other.latencyMs == latencyMs)&&(identical(other.health, health) || other.health == health)&&(identical(other.since, since) || other.since == since)&&(identical(other.exit, exit) || other.exit == exit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,latencyMs,health,since,exit);
}

@override
String toString() {
    return 'RcxCurrentNode(name: $name, latencyMs: $latencyMs, health: $health, since: $since, exit: $exit)';
}


}

/// @nodoc
abstract mixin class _$RcxCurrentNodeCopyWith<$Res> implements $RcxCurrentNodeCopyWith<$Res> {
  factory _$RcxCurrentNodeCopyWith(_RcxCurrentNode value, $Res Function(_RcxCurrentNode) _then) = __$RcxCurrentNodeCopyWithImpl;
@override @useResult
$Res call({
 String name, int latencyMs, String health, DateTime? since, String exit
});




}
/// @nodoc
class __$RcxCurrentNodeCopyWithImpl<$Res>
    implements _$RcxCurrentNodeCopyWith<$Res> {
  __$RcxCurrentNodeCopyWithImpl(this._self, this._then);

  final _RcxCurrentNode _self;
  final $Res Function(_RcxCurrentNode) _then;

/// Create a copy of RcxCurrentNode
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? latencyMs = null,Object? health = null,Object? since = freezed,Object? exit = null,}) {
  return _then(_RcxCurrentNode(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,latencyMs: null == latencyMs ? _self.latencyMs : latencyMs // ignore: cast_nullable_to_non_nullable
as int,health: null == health ? _self.health : health // ignore: cast_nullable_to_non_nullable
as String,since: freezed == since ? _self.since : since // ignore: cast_nullable_to_non_nullable
as DateTime?,exit: null == exit ? _self.exit : exit // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$RcxExcludedNode {

 String get name; DateTime get until;
/// Create a copy of RcxExcludedNode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RcxExcludedNodeCopyWith<RcxExcludedNode> get copyWith => _$RcxExcludedNodeCopyWithImpl<RcxExcludedNode>(this as RcxExcludedNode, _$identity);

  /// Serializes this RcxExcludedNode to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RcxExcludedNode;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RcxExcludedNode&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.until, _this.until) || other.until == _this.until));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RcxExcludedNode;
  return Object.hash(runtimeType,_this.name,_this.until);
}

@override
String toString() {
  final _this = this as RcxExcludedNode;
  return 'RcxExcludedNode(name: ${_this.name}, until: ${_this.until})';
}


}

/// @nodoc
abstract mixin class $RcxExcludedNodeCopyWith<$Res>  {
  factory $RcxExcludedNodeCopyWith(RcxExcludedNode value, $Res Function(RcxExcludedNode) _then) = _$RcxExcludedNodeCopyWithImpl;
@useResult
$Res call({
 String name, DateTime until
});




}
/// @nodoc
class _$RcxExcludedNodeCopyWithImpl<$Res>
    implements $RcxExcludedNodeCopyWith<$Res> {
  _$RcxExcludedNodeCopyWithImpl(this._self, this._then);

  final RcxExcludedNode _self;
  final $Res Function(RcxExcludedNode) _then;

/// Create a copy of RcxExcludedNode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? until = null,}) {
  return _then(RcxExcludedNode(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,until: null == until ? _self.until : until // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [RcxExcludedNode].
extension RcxExcludedNodePatterns on RcxExcludedNode {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RcxExcludedNode value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RcxExcludedNode() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RcxExcludedNode value)  $default,){
final _that = this;
switch (_that) {
case _RcxExcludedNode():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RcxExcludedNode value)?  $default,){
final _that = this;
switch (_that) {
case _RcxExcludedNode() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  DateTime until)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RcxExcludedNode() when $default != null:
return $default(_that.name,_that.until);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  DateTime until)  $default,) {final _that = this;
switch (_that) {
case _RcxExcludedNode():
return $default(_that.name,_that.until);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  DateTime until)?  $default,) {final _that = this;
switch (_that) {
case _RcxExcludedNode() when $default != null:
return $default(_that.name,_that.until);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RcxExcludedNode implements RcxExcludedNode {
  const _RcxExcludedNode({required this.name, required this.until});
  factory _RcxExcludedNode.fromJson(Map<String, dynamic> json) => _$RcxExcludedNodeFromJson(json);

@override final  String name;
@override final  DateTime until;

/// Create a copy of RcxExcludedNode
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RcxExcludedNodeCopyWith<_RcxExcludedNode> get copyWith => __$RcxExcludedNodeCopyWithImpl<_RcxExcludedNode>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RcxExcludedNodeToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RcxExcludedNode&&(identical(other.name, name) || other.name == name)&&(identical(other.until, until) || other.until == until));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,until);
}

@override
String toString() {
    return 'RcxExcludedNode(name: $name, until: $until)';
}


}

/// @nodoc
abstract mixin class _$RcxExcludedNodeCopyWith<$Res> implements $RcxExcludedNodeCopyWith<$Res> {
  factory _$RcxExcludedNodeCopyWith(_RcxExcludedNode value, $Res Function(_RcxExcludedNode) _then) = __$RcxExcludedNodeCopyWithImpl;
@override @useResult
$Res call({
 String name, DateTime until
});




}
/// @nodoc
class __$RcxExcludedNodeCopyWithImpl<$Res>
    implements _$RcxExcludedNodeCopyWith<$Res> {
  __$RcxExcludedNodeCopyWithImpl(this._self, this._then);

  final _RcxExcludedNode _self;
  final $Res Function(_RcxExcludedNode) _then;

/// Create a copy of RcxExcludedNode
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? until = null,}) {
  return _then(_RcxExcludedNode(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,until: null == until ? _self.until : until // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$RcxGroupNetwork {

 String get kind; String get next; bool get paused; List<String> get kinds;
/// Create a copy of RcxGroupNetwork
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RcxGroupNetworkCopyWith<RcxGroupNetwork> get copyWith => _$RcxGroupNetworkCopyWithImpl<RcxGroupNetwork>(this as RcxGroupNetwork, _$identity);

  /// Serializes this RcxGroupNetwork to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RcxGroupNetwork;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RcxGroupNetwork&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.next, _this.next) || other.next == _this.next)&&(identical(other.paused, _this.paused) || other.paused == _this.paused)&&const DeepCollectionEquality().equals(other.kinds, _this.kinds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RcxGroupNetwork;
  return Object.hash(runtimeType,_this.kind,_this.next,_this.paused,const DeepCollectionEquality().hash(_this.kinds));
}

@override
String toString() {
  final _this = this as RcxGroupNetwork;
  return 'RcxGroupNetwork(kind: ${_this.kind}, next: ${_this.next}, paused: ${_this.paused}, kinds: ${_this.kinds})';
}


}

/// @nodoc
abstract mixin class $RcxGroupNetworkCopyWith<$Res>  {
  factory $RcxGroupNetworkCopyWith(RcxGroupNetwork value, $Res Function(RcxGroupNetwork) _then) = _$RcxGroupNetworkCopyWithImpl;
@useResult
$Res call({
 String kind, String next, bool paused, List<String> kinds
});




}
/// @nodoc
class _$RcxGroupNetworkCopyWithImpl<$Res>
    implements $RcxGroupNetworkCopyWith<$Res> {
  _$RcxGroupNetworkCopyWithImpl(this._self, this._then);

  final RcxGroupNetwork _self;
  final $Res Function(RcxGroupNetwork) _then;

/// Create a copy of RcxGroupNetwork
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? next = null,Object? paused = null,Object? kinds = null,}) {
  return _then(RcxGroupNetwork(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,next: null == next ? _self.next : next // ignore: cast_nullable_to_non_nullable
as String,paused: null == paused ? _self.paused : paused // ignore: cast_nullable_to_non_nullable
as bool,kinds: null == kinds ? _self.kinds : kinds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [RcxGroupNetwork].
extension RcxGroupNetworkPatterns on RcxGroupNetwork {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RcxGroupNetwork value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RcxGroupNetwork() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RcxGroupNetwork value)  $default,){
final _that = this;
switch (_that) {
case _RcxGroupNetwork():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RcxGroupNetwork value)?  $default,){
final _that = this;
switch (_that) {
case _RcxGroupNetwork() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String kind,  String next,  bool paused,  List<String> kinds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RcxGroupNetwork() when $default != null:
return $default(_that.kind,_that.next,_that.paused,_that.kinds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String kind,  String next,  bool paused,  List<String> kinds)  $default,) {final _that = this;
switch (_that) {
case _RcxGroupNetwork():
return $default(_that.kind,_that.next,_that.paused,_that.kinds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String kind,  String next,  bool paused,  List<String> kinds)?  $default,) {final _that = this;
switch (_that) {
case _RcxGroupNetwork() when $default != null:
return $default(_that.kind,_that.next,_that.paused,_that.kinds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RcxGroupNetwork implements RcxGroupNetwork {
  const _RcxGroupNetwork({this.kind = '', this.next = '', this.paused = false,  List<String> kinds = const []}): _kinds = kinds;
  factory _RcxGroupNetwork.fromJson(Map<String, dynamic> json) => _$RcxGroupNetworkFromJson(json);

@override@JsonKey() final  String kind;
@override@JsonKey() final  String next;
@override@JsonKey() final  bool paused;
 final  List<String> _kinds;
@override@JsonKey() List<String> get kinds {
  if (_kinds is EqualUnmodifiableListView) return _kinds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_kinds);
}


/// Create a copy of RcxGroupNetwork
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RcxGroupNetworkCopyWith<_RcxGroupNetwork> get copyWith => __$RcxGroupNetworkCopyWithImpl<_RcxGroupNetwork>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RcxGroupNetworkToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RcxGroupNetwork&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.next, next) || other.next == next)&&(identical(other.paused, paused) || other.paused == paused)&&const DeepCollectionEquality().equals(other.kinds, _kinds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,kind,next,paused,const DeepCollectionEquality().hash(_kinds));
}

@override
String toString() {
    return 'RcxGroupNetwork(kind: $kind, next: $next, paused: $paused, kinds: $kinds)';
}


}

/// @nodoc
abstract mixin class _$RcxGroupNetworkCopyWith<$Res> implements $RcxGroupNetworkCopyWith<$Res> {
  factory _$RcxGroupNetworkCopyWith(_RcxGroupNetwork value, $Res Function(_RcxGroupNetwork) _then) = __$RcxGroupNetworkCopyWithImpl;
@override @useResult
$Res call({
 String kind, String next, bool paused, List<String> kinds
});




}
/// @nodoc
class __$RcxGroupNetworkCopyWithImpl<$Res>
    implements _$RcxGroupNetworkCopyWith<$Res> {
  __$RcxGroupNetworkCopyWithImpl(this._self, this._then);

  final _RcxGroupNetwork _self;
  final $Res Function(_RcxGroupNetwork) _then;

/// Create a copy of RcxGroupNetwork
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? next = null,Object? paused = null,Object? kinds = null,}) {
  return _then(_RcxGroupNetwork(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,next: null == next ? _self.next : next // ignore: cast_nullable_to_non_nullable
as String,paused: null == paused ? _self.paused : paused // ignore: cast_nullable_to_non_nullable
as bool,kinds: null == kinds ? _self._kinds : kinds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$RcxGroupStatus {

 String get name; String get source; String get profile; String get profileTitle; String get level; List<String> get offered; RcxBinding get binding;/// The scenario key naming the group now ($main, * or its name), and
/// the member the scenario holds it on.
 String get program; String get fixed;/// The tunnel mode routes nothing through the group.
 bool get idle; RcxControl get control; String get now;/// Nested selectors the group reaches [now] through, outermost first.
 List<String> get via; RcxDecision get decision; RcxReason? get problem; int get members; int get candidates; List<RcxExcludedNode> get excluded; int get switchesHour; int get maxPerHour; bool get improve; RcxCurrentNode? get current; RcxGroupNetwork? get network;/// Empty when the profile cannot split, else off, standby or active.
 String get directSplit;
/// Create a copy of RcxGroupStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RcxGroupStatusCopyWith<RcxGroupStatus> get copyWith => _$RcxGroupStatusCopyWithImpl<RcxGroupStatus>(this as RcxGroupStatus, _$identity);

  /// Serializes this RcxGroupStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RcxGroupStatus;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RcxGroupStatus&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.source, _this.source) || other.source == _this.source)&&(identical(other.profile, _this.profile) || other.profile == _this.profile)&&(identical(other.profileTitle, _this.profileTitle) || other.profileTitle == _this.profileTitle)&&(identical(other.level, _this.level) || other.level == _this.level)&&const DeepCollectionEquality().equals(other.offered, _this.offered)&&(identical(other.binding, _this.binding) || other.binding == _this.binding)&&(identical(other.program, _this.program) || other.program == _this.program)&&(identical(other.fixed, _this.fixed) || other.fixed == _this.fixed)&&(identical(other.idle, _this.idle) || other.idle == _this.idle)&&(identical(other.control, _this.control) || other.control == _this.control)&&(identical(other.now, _this.now) || other.now == _this.now)&&const DeepCollectionEquality().equals(other.via, _this.via)&&(identical(other.decision, _this.decision) || other.decision == _this.decision)&&(identical(other.problem, _this.problem) || other.problem == _this.problem)&&(identical(other.members, _this.members) || other.members == _this.members)&&(identical(other.candidates, _this.candidates) || other.candidates == _this.candidates)&&const DeepCollectionEquality().equals(other.excluded, _this.excluded)&&(identical(other.switchesHour, _this.switchesHour) || other.switchesHour == _this.switchesHour)&&(identical(other.maxPerHour, _this.maxPerHour) || other.maxPerHour == _this.maxPerHour)&&(identical(other.improve, _this.improve) || other.improve == _this.improve)&&(identical(other.current, _this.current) || other.current == _this.current)&&(identical(other.network, _this.network) || other.network == _this.network)&&(identical(other.directSplit, _this.directSplit) || other.directSplit == _this.directSplit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RcxGroupStatus;
  return Object.hashAll([runtimeType,_this.name,_this.source,_this.profile,_this.profileTitle,_this.level,const DeepCollectionEquality().hash(_this.offered),_this.binding,_this.program,_this.fixed,_this.idle,_this.control,_this.now,const DeepCollectionEquality().hash(_this.via),_this.decision,_this.problem,_this.members,_this.candidates,const DeepCollectionEquality().hash(_this.excluded),_this.switchesHour,_this.maxPerHour,_this.improve,_this.current,_this.network,_this.directSplit]);
}

@override
String toString() {
  final _this = this as RcxGroupStatus;
  return 'RcxGroupStatus(name: ${_this.name}, source: ${_this.source}, profile: ${_this.profile}, profileTitle: ${_this.profileTitle}, level: ${_this.level}, offered: ${_this.offered}, binding: ${_this.binding}, program: ${_this.program}, fixed: ${_this.fixed}, idle: ${_this.idle}, control: ${_this.control}, now: ${_this.now}, via: ${_this.via}, decision: ${_this.decision}, problem: ${_this.problem}, members: ${_this.members}, candidates: ${_this.candidates}, excluded: ${_this.excluded}, switchesHour: ${_this.switchesHour}, maxPerHour: ${_this.maxPerHour}, improve: ${_this.improve}, current: ${_this.current}, network: ${_this.network}, directSplit: ${_this.directSplit})';
}


}

/// @nodoc
abstract mixin class $RcxGroupStatusCopyWith<$Res>  {
  factory $RcxGroupStatusCopyWith(RcxGroupStatus value, $Res Function(RcxGroupStatus) _then) = _$RcxGroupStatusCopyWithImpl;
@useResult
$Res call({
 String name, String source, String profile, String profileTitle, String level, List<String> offered, RcxBinding binding, String program, String fixed, bool idle, RcxControl control, String now, List<String> via, RcxDecision decision, RcxReason? problem, int members, int candidates, List<RcxExcludedNode> excluded, int switchesHour, int maxPerHour, bool improve, RcxCurrentNode? current, RcxGroupNetwork? network, String directSplit
});


$RcxBindingCopyWith<$Res> get binding;$RcxControlCopyWith<$Res> get control;$RcxDecisionCopyWith<$Res> get decision;$RcxReasonCopyWith<$Res>? get problem;$RcxCurrentNodeCopyWith<$Res>? get current;$RcxGroupNetworkCopyWith<$Res>? get network;

}
/// @nodoc
class _$RcxGroupStatusCopyWithImpl<$Res>
    implements $RcxGroupStatusCopyWith<$Res> {
  _$RcxGroupStatusCopyWithImpl(this._self, this._then);

  final RcxGroupStatus _self;
  final $Res Function(RcxGroupStatus) _then;

/// Create a copy of RcxGroupStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? source = null,Object? profile = null,Object? profileTitle = null,Object? level = null,Object? offered = null,Object? binding = null,Object? program = null,Object? fixed = null,Object? idle = null,Object? control = null,Object? now = null,Object? via = null,Object? decision = null,Object? problem = freezed,Object? members = null,Object? candidates = null,Object? excluded = null,Object? switchesHour = null,Object? maxPerHour = null,Object? improve = null,Object? current = freezed,Object? network = freezed,Object? directSplit = null,}) {
  return _then(RcxGroupStatus(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as String,profileTitle: null == profileTitle ? _self.profileTitle : profileTitle // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as String,offered: null == offered ? _self.offered : offered // ignore: cast_nullable_to_non_nullable
as List<String>,binding: null == binding ? _self.binding : binding // ignore: cast_nullable_to_non_nullable
as RcxBinding,program: null == program ? _self.program : program // ignore: cast_nullable_to_non_nullable
as String,fixed: null == fixed ? _self.fixed : fixed // ignore: cast_nullable_to_non_nullable
as String,idle: null == idle ? _self.idle : idle // ignore: cast_nullable_to_non_nullable
as bool,control: null == control ? _self.control : control // ignore: cast_nullable_to_non_nullable
as RcxControl,now: null == now ? _self.now : now // ignore: cast_nullable_to_non_nullable
as String,via: null == via ? _self.via : via // ignore: cast_nullable_to_non_nullable
as List<String>,decision: null == decision ? _self.decision : decision // ignore: cast_nullable_to_non_nullable
as RcxDecision,problem: freezed == problem ? _self.problem : problem // ignore: cast_nullable_to_non_nullable
as RcxReason?,members: null == members ? _self.members : members // ignore: cast_nullable_to_non_nullable
as int,candidates: null == candidates ? _self.candidates : candidates // ignore: cast_nullable_to_non_nullable
as int,excluded: null == excluded ? _self.excluded : excluded // ignore: cast_nullable_to_non_nullable
as List<RcxExcludedNode>,switchesHour: null == switchesHour ? _self.switchesHour : switchesHour // ignore: cast_nullable_to_non_nullable
as int,maxPerHour: null == maxPerHour ? _self.maxPerHour : maxPerHour // ignore: cast_nullable_to_non_nullable
as int,improve: null == improve ? _self.improve : improve // ignore: cast_nullable_to_non_nullable
as bool,current: freezed == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as RcxCurrentNode?,network: freezed == network ? _self.network : network // ignore: cast_nullable_to_non_nullable
as RcxGroupNetwork?,directSplit: null == directSplit ? _self.directSplit : directSplit // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of RcxGroupStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RcxBindingCopyWith<$Res> get binding {
  
  return $RcxBindingCopyWith<$Res>(_self.binding, (value) {
    return _then(_self.copyWith(binding: value));
  });
}/// Create a copy of RcxGroupStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RcxControlCopyWith<$Res> get control {
  
  return $RcxControlCopyWith<$Res>(_self.control, (value) {
    return _then(_self.copyWith(control: value));
  });
}/// Create a copy of RcxGroupStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RcxDecisionCopyWith<$Res> get decision {
  
  return $RcxDecisionCopyWith<$Res>(_self.decision, (value) {
    return _then(_self.copyWith(decision: value));
  });
}/// Create a copy of RcxGroupStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RcxReasonCopyWith<$Res>? get problem {
    if (_self.problem == null) {
    return null;
  }

  return $RcxReasonCopyWith<$Res>(_self.problem!, (value) {
    return _then(_self.copyWith(problem: value));
  });
}/// Create a copy of RcxGroupStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RcxCurrentNodeCopyWith<$Res>? get current {
    if (_self.current == null) {
    return null;
  }

  return $RcxCurrentNodeCopyWith<$Res>(_self.current!, (value) {
    return _then(_self.copyWith(current: value));
  });
}/// Create a copy of RcxGroupStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RcxGroupNetworkCopyWith<$Res>? get network {
    if (_self.network == null) {
    return null;
  }

  return $RcxGroupNetworkCopyWith<$Res>(_self.network!, (value) {
    return _then(_self.copyWith(network: value));
  });
}
}


/// Adds pattern-matching-related methods to [RcxGroupStatus].
extension RcxGroupStatusPatterns on RcxGroupStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RcxGroupStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RcxGroupStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RcxGroupStatus value)  $default,){
final _that = this;
switch (_that) {
case _RcxGroupStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RcxGroupStatus value)?  $default,){
final _that = this;
switch (_that) {
case _RcxGroupStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String source,  String profile,  String profileTitle,  String level,  List<String> offered,  RcxBinding binding,  String program,  String fixed,  bool idle,  RcxControl control,  String now,  List<String> via,  RcxDecision decision,  RcxReason? problem,  int members,  int candidates,  List<RcxExcludedNode> excluded,  int switchesHour,  int maxPerHour,  bool improve,  RcxCurrentNode? current,  RcxGroupNetwork? network,  String directSplit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RcxGroupStatus() when $default != null:
return $default(_that.name,_that.source,_that.profile,_that.profileTitle,_that.level,_that.offered,_that.binding,_that.program,_that.fixed,_that.idle,_that.control,_that.now,_that.via,_that.decision,_that.problem,_that.members,_that.candidates,_that.excluded,_that.switchesHour,_that.maxPerHour,_that.improve,_that.current,_that.network,_that.directSplit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String source,  String profile,  String profileTitle,  String level,  List<String> offered,  RcxBinding binding,  String program,  String fixed,  bool idle,  RcxControl control,  String now,  List<String> via,  RcxDecision decision,  RcxReason? problem,  int members,  int candidates,  List<RcxExcludedNode> excluded,  int switchesHour,  int maxPerHour,  bool improve,  RcxCurrentNode? current,  RcxGroupNetwork? network,  String directSplit)  $default,) {final _that = this;
switch (_that) {
case _RcxGroupStatus():
return $default(_that.name,_that.source,_that.profile,_that.profileTitle,_that.level,_that.offered,_that.binding,_that.program,_that.fixed,_that.idle,_that.control,_that.now,_that.via,_that.decision,_that.problem,_that.members,_that.candidates,_that.excluded,_that.switchesHour,_that.maxPerHour,_that.improve,_that.current,_that.network,_that.directSplit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String source,  String profile,  String profileTitle,  String level,  List<String> offered,  RcxBinding binding,  String program,  String fixed,  bool idle,  RcxControl control,  String now,  List<String> via,  RcxDecision decision,  RcxReason? problem,  int members,  int candidates,  List<RcxExcludedNode> excluded,  int switchesHour,  int maxPerHour,  bool improve,  RcxCurrentNode? current,  RcxGroupNetwork? network,  String directSplit)?  $default,) {final _that = this;
switch (_that) {
case _RcxGroupStatus() when $default != null:
return $default(_that.name,_that.source,_that.profile,_that.profileTitle,_that.level,_that.offered,_that.binding,_that.program,_that.fixed,_that.idle,_that.control,_that.now,_that.via,_that.decision,_that.problem,_that.members,_that.candidates,_that.excluded,_that.switchesHour,_that.maxPerHour,_that.improve,_that.current,_that.network,_that.directSplit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RcxGroupStatus implements RcxGroupStatus {
  const _RcxGroupStatus({required this.name, this.source = '', this.profile = '', this.profileTitle = '', this.level = 'simple',  List<String> offered = const [], this.binding = const RcxBinding(), this.program = '', this.fixed = '', this.idle = false, this.control = const RcxControl(), this.now = '',  List<String> via = const [], this.decision = const RcxDecision(), this.problem, this.members = 0, this.candidates = 0,  List<RcxExcludedNode> excluded = const [], this.switchesHour = 0, this.maxPerHour = 0, this.improve = false, this.current, this.network, this.directSplit = ''}): _offered = offered,_via = via,_excluded = excluded;
  factory _RcxGroupStatus.fromJson(Map<String, dynamic> json) => _$RcxGroupStatusFromJson(json);

@override final  String name;
@override@JsonKey() final  String source;
@override@JsonKey() final  String profile;
@override@JsonKey() final  String profileTitle;
@override@JsonKey() final  String level;
 final  List<String> _offered;
@override@JsonKey() List<String> get offered {
  if (_offered is EqualUnmodifiableListView) return _offered;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_offered);
}

@override@JsonKey() final  RcxBinding binding;
/// The scenario key naming the group now ($main, * or its name), and
/// the member the scenario holds it on.
@override@JsonKey() final  String program;
@override@JsonKey() final  String fixed;
/// The tunnel mode routes nothing through the group.
@override@JsonKey() final  bool idle;
@override@JsonKey() final  RcxControl control;
@override@JsonKey() final  String now;
/// Nested selectors the group reaches [now] through, outermost first.
 final  List<String> _via;
/// Nested selectors the group reaches [now] through, outermost first.
@override@JsonKey() List<String> get via {
  if (_via is EqualUnmodifiableListView) return _via;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_via);
}

@override@JsonKey() final  RcxDecision decision;
@override final  RcxReason? problem;
@override@JsonKey() final  int members;
@override@JsonKey() final  int candidates;
 final  List<RcxExcludedNode> _excluded;
@override@JsonKey() List<RcxExcludedNode> get excluded {
  if (_excluded is EqualUnmodifiableListView) return _excluded;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_excluded);
}

@override@JsonKey() final  int switchesHour;
@override@JsonKey() final  int maxPerHour;
@override@JsonKey() final  bool improve;
@override final  RcxCurrentNode? current;
@override final  RcxGroupNetwork? network;
/// Empty when the profile cannot split, else off, standby or active.
@override@JsonKey() final  String directSplit;

/// Create a copy of RcxGroupStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RcxGroupStatusCopyWith<_RcxGroupStatus> get copyWith => __$RcxGroupStatusCopyWithImpl<_RcxGroupStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RcxGroupStatusToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RcxGroupStatus&&(identical(other.name, name) || other.name == name)&&(identical(other.source, source) || other.source == source)&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.profileTitle, profileTitle) || other.profileTitle == profileTitle)&&(identical(other.level, level) || other.level == level)&&const DeepCollectionEquality().equals(other.offered, _offered)&&(identical(other.binding, binding) || other.binding == binding)&&(identical(other.program, program) || other.program == program)&&(identical(other.fixed, fixed) || other.fixed == fixed)&&(identical(other.idle, idle) || other.idle == idle)&&(identical(other.control, control) || other.control == control)&&(identical(other.now, now) || other.now == now)&&const DeepCollectionEquality().equals(other.via, _via)&&(identical(other.decision, decision) || other.decision == decision)&&(identical(other.problem, problem) || other.problem == problem)&&(identical(other.members, members) || other.members == members)&&(identical(other.candidates, candidates) || other.candidates == candidates)&&const DeepCollectionEquality().equals(other.excluded, _excluded)&&(identical(other.switchesHour, switchesHour) || other.switchesHour == switchesHour)&&(identical(other.maxPerHour, maxPerHour) || other.maxPerHour == maxPerHour)&&(identical(other.improve, improve) || other.improve == improve)&&(identical(other.current, current) || other.current == current)&&(identical(other.network, network) || other.network == network)&&(identical(other.directSplit, directSplit) || other.directSplit == directSplit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,name,source,profile,profileTitle,level,const DeepCollectionEquality().hash(_offered),binding,program,fixed,idle,control,now,const DeepCollectionEquality().hash(_via),decision,problem,members,candidates,const DeepCollectionEquality().hash(_excluded),switchesHour,maxPerHour,improve,current,network,directSplit]);
}

@override
String toString() {
    return 'RcxGroupStatus(name: $name, source: $source, profile: $profile, profileTitle: $profileTitle, level: $level, offered: $offered, binding: $binding, program: $program, fixed: $fixed, idle: $idle, control: $control, now: $now, via: $via, decision: $decision, problem: $problem, members: $members, candidates: $candidates, excluded: $excluded, switchesHour: $switchesHour, maxPerHour: $maxPerHour, improve: $improve, current: $current, network: $network, directSplit: $directSplit)';
}


}

/// @nodoc
abstract mixin class _$RcxGroupStatusCopyWith<$Res> implements $RcxGroupStatusCopyWith<$Res> {
  factory _$RcxGroupStatusCopyWith(_RcxGroupStatus value, $Res Function(_RcxGroupStatus) _then) = __$RcxGroupStatusCopyWithImpl;
@override @useResult
$Res call({
 String name, String source, String profile, String profileTitle, String level, List<String> offered, RcxBinding binding, String program, String fixed, bool idle, RcxControl control, String now, List<String> via, RcxDecision decision, RcxReason? problem, int members, int candidates, List<RcxExcludedNode> excluded, int switchesHour, int maxPerHour, bool improve, RcxCurrentNode? current, RcxGroupNetwork? network, String directSplit
});


@override $RcxBindingCopyWith<$Res> get binding;@override $RcxControlCopyWith<$Res> get control;@override $RcxDecisionCopyWith<$Res> get decision;@override $RcxReasonCopyWith<$Res>? get problem;@override $RcxCurrentNodeCopyWith<$Res>? get current;@override $RcxGroupNetworkCopyWith<$Res>? get network;

}
/// @nodoc
class __$RcxGroupStatusCopyWithImpl<$Res>
    implements _$RcxGroupStatusCopyWith<$Res> {
  __$RcxGroupStatusCopyWithImpl(this._self, this._then);

  final _RcxGroupStatus _self;
  final $Res Function(_RcxGroupStatus) _then;

/// Create a copy of RcxGroupStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? source = null,Object? profile = null,Object? profileTitle = null,Object? level = null,Object? offered = null,Object? binding = null,Object? program = null,Object? fixed = null,Object? idle = null,Object? control = null,Object? now = null,Object? via = null,Object? decision = null,Object? problem = freezed,Object? members = null,Object? candidates = null,Object? excluded = null,Object? switchesHour = null,Object? maxPerHour = null,Object? improve = null,Object? current = freezed,Object? network = freezed,Object? directSplit = null,}) {
  return _then(_RcxGroupStatus(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as String,profileTitle: null == profileTitle ? _self.profileTitle : profileTitle // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as String,offered: null == offered ? _self._offered : offered // ignore: cast_nullable_to_non_nullable
as List<String>,binding: null == binding ? _self.binding : binding // ignore: cast_nullable_to_non_nullable
as RcxBinding,program: null == program ? _self.program : program // ignore: cast_nullable_to_non_nullable
as String,fixed: null == fixed ? _self.fixed : fixed // ignore: cast_nullable_to_non_nullable
as String,idle: null == idle ? _self.idle : idle // ignore: cast_nullable_to_non_nullable
as bool,control: null == control ? _self.control : control // ignore: cast_nullable_to_non_nullable
as RcxControl,now: null == now ? _self.now : now // ignore: cast_nullable_to_non_nullable
as String,via: null == via ? _self._via : via // ignore: cast_nullable_to_non_nullable
as List<String>,decision: null == decision ? _self.decision : decision // ignore: cast_nullable_to_non_nullable
as RcxDecision,problem: freezed == problem ? _self.problem : problem // ignore: cast_nullable_to_non_nullable
as RcxReason?,members: null == members ? _self.members : members // ignore: cast_nullable_to_non_nullable
as int,candidates: null == candidates ? _self.candidates : candidates // ignore: cast_nullable_to_non_nullable
as int,excluded: null == excluded ? _self._excluded : excluded // ignore: cast_nullable_to_non_nullable
as List<RcxExcludedNode>,switchesHour: null == switchesHour ? _self.switchesHour : switchesHour // ignore: cast_nullable_to_non_nullable
as int,maxPerHour: null == maxPerHour ? _self.maxPerHour : maxPerHour // ignore: cast_nullable_to_non_nullable
as int,improve: null == improve ? _self.improve : improve // ignore: cast_nullable_to_non_nullable
as bool,current: freezed == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as RcxCurrentNode?,network: freezed == network ? _self.network : network // ignore: cast_nullable_to_non_nullable
as RcxGroupNetwork?,directSplit: null == directSplit ? _self.directSplit : directSplit // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of RcxGroupStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RcxBindingCopyWith<$Res> get binding {
  
  return $RcxBindingCopyWith<$Res>(_self.binding, (value) {
    return _then(_self.copyWith(binding: value));
  });
}/// Create a copy of RcxGroupStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RcxControlCopyWith<$Res> get control {
  
  return $RcxControlCopyWith<$Res>(_self.control, (value) {
    return _then(_self.copyWith(control: value));
  });
}/// Create a copy of RcxGroupStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RcxDecisionCopyWith<$Res> get decision {
  
  return $RcxDecisionCopyWith<$Res>(_self.decision, (value) {
    return _then(_self.copyWith(decision: value));
  });
}/// Create a copy of RcxGroupStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RcxReasonCopyWith<$Res>? get problem {
    if (_self.problem == null) {
    return null;
  }

  return $RcxReasonCopyWith<$Res>(_self.problem!, (value) {
    return _then(_self.copyWith(problem: value));
  });
}/// Create a copy of RcxGroupStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RcxCurrentNodeCopyWith<$Res>? get current {
    if (_self.current == null) {
    return null;
  }

  return $RcxCurrentNodeCopyWith<$Res>(_self.current!, (value) {
    return _then(_self.copyWith(current: value));
  });
}/// Create a copy of RcxGroupStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RcxGroupNetworkCopyWith<$Res>? get network {
    if (_self.network == null) {
    return null;
  }

  return $RcxGroupNetworkCopyWith<$Res>(_self.network!, (value) {
    return _then(_self.copyWith(network: value));
  });
}
}


/// @nodoc
mixin _$RcxEnergy {

 String get level; String get day; int get requests; int get bytes; int get capBytes; Map<String, int> get hourlyLimits;
/// Create a copy of RcxEnergy
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RcxEnergyCopyWith<RcxEnergy> get copyWith => _$RcxEnergyCopyWithImpl<RcxEnergy>(this as RcxEnergy, _$identity);

  /// Serializes this RcxEnergy to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RcxEnergy;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RcxEnergy&&(identical(other.level, _this.level) || other.level == _this.level)&&(identical(other.day, _this.day) || other.day == _this.day)&&(identical(other.requests, _this.requests) || other.requests == _this.requests)&&(identical(other.bytes, _this.bytes) || other.bytes == _this.bytes)&&(identical(other.capBytes, _this.capBytes) || other.capBytes == _this.capBytes)&&const DeepCollectionEquality().equals(other.hourlyLimits, _this.hourlyLimits));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RcxEnergy;
  return Object.hash(runtimeType,_this.level,_this.day,_this.requests,_this.bytes,_this.capBytes,const DeepCollectionEquality().hash(_this.hourlyLimits));
}

@override
String toString() {
  final _this = this as RcxEnergy;
  return 'RcxEnergy(level: ${_this.level}, day: ${_this.day}, requests: ${_this.requests}, bytes: ${_this.bytes}, capBytes: ${_this.capBytes}, hourlyLimits: ${_this.hourlyLimits})';
}


}

/// @nodoc
abstract mixin class $RcxEnergyCopyWith<$Res>  {
  factory $RcxEnergyCopyWith(RcxEnergy value, $Res Function(RcxEnergy) _then) = _$RcxEnergyCopyWithImpl;
@useResult
$Res call({
 String level, String day, int requests, int bytes, int capBytes, Map<String, int> hourlyLimits
});




}
/// @nodoc
class _$RcxEnergyCopyWithImpl<$Res>
    implements $RcxEnergyCopyWith<$Res> {
  _$RcxEnergyCopyWithImpl(this._self, this._then);

  final RcxEnergy _self;
  final $Res Function(RcxEnergy) _then;

/// Create a copy of RcxEnergy
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? level = null,Object? day = null,Object? requests = null,Object? bytes = null,Object? capBytes = null,Object? hourlyLimits = null,}) {
  return _then(RcxEnergy(
level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as String,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as String,requests: null == requests ? _self.requests : requests // ignore: cast_nullable_to_non_nullable
as int,bytes: null == bytes ? _self.bytes : bytes // ignore: cast_nullable_to_non_nullable
as int,capBytes: null == capBytes ? _self.capBytes : capBytes // ignore: cast_nullable_to_non_nullable
as int,hourlyLimits: null == hourlyLimits ? _self.hourlyLimits : hourlyLimits // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}

}


/// Adds pattern-matching-related methods to [RcxEnergy].
extension RcxEnergyPatterns on RcxEnergy {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RcxEnergy value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RcxEnergy() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RcxEnergy value)  $default,){
final _that = this;
switch (_that) {
case _RcxEnergy():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RcxEnergy value)?  $default,){
final _that = this;
switch (_that) {
case _RcxEnergy() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String level,  String day,  int requests,  int bytes,  int capBytes,  Map<String, int> hourlyLimits)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RcxEnergy() when $default != null:
return $default(_that.level,_that.day,_that.requests,_that.bytes,_that.capBytes,_that.hourlyLimits);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String level,  String day,  int requests,  int bytes,  int capBytes,  Map<String, int> hourlyLimits)  $default,) {final _that = this;
switch (_that) {
case _RcxEnergy():
return $default(_that.level,_that.day,_that.requests,_that.bytes,_that.capBytes,_that.hourlyLimits);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String level,  String day,  int requests,  int bytes,  int capBytes,  Map<String, int> hourlyLimits)?  $default,) {final _that = this;
switch (_that) {
case _RcxEnergy() when $default != null:
return $default(_that.level,_that.day,_that.requests,_that.bytes,_that.capBytes,_that.hourlyLimits);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RcxEnergy implements RcxEnergy {
  const _RcxEnergy({this.level = 'balanced', this.day = '', this.requests = 0, this.bytes = 0, this.capBytes = 0,  Map<String, int> hourlyLimits = const {}}): _hourlyLimits = hourlyLimits;
  factory _RcxEnergy.fromJson(Map<String, dynamic> json) => _$RcxEnergyFromJson(json);

@override@JsonKey() final  String level;
@override@JsonKey() final  String day;
@override@JsonKey() final  int requests;
@override@JsonKey() final  int bytes;
@override@JsonKey() final  int capBytes;
 final  Map<String, int> _hourlyLimits;
@override@JsonKey() Map<String, int> get hourlyLimits {
  if (_hourlyLimits is EqualUnmodifiableMapView) return _hourlyLimits;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_hourlyLimits);
}


/// Create a copy of RcxEnergy
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RcxEnergyCopyWith<_RcxEnergy> get copyWith => __$RcxEnergyCopyWithImpl<_RcxEnergy>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RcxEnergyToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RcxEnergy&&(identical(other.level, level) || other.level == level)&&(identical(other.day, day) || other.day == day)&&(identical(other.requests, requests) || other.requests == requests)&&(identical(other.bytes, bytes) || other.bytes == bytes)&&(identical(other.capBytes, capBytes) || other.capBytes == capBytes)&&const DeepCollectionEquality().equals(other.hourlyLimits, _hourlyLimits));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,level,day,requests,bytes,capBytes,const DeepCollectionEquality().hash(_hourlyLimits));
}

@override
String toString() {
    return 'RcxEnergy(level: $level, day: $day, requests: $requests, bytes: $bytes, capBytes: $capBytes, hourlyLimits: $hourlyLimits)';
}


}

/// @nodoc
abstract mixin class _$RcxEnergyCopyWith<$Res> implements $RcxEnergyCopyWith<$Res> {
  factory _$RcxEnergyCopyWith(_RcxEnergy value, $Res Function(_RcxEnergy) _then) = __$RcxEnergyCopyWithImpl;
@override @useResult
$Res call({
 String level, String day, int requests, int bytes, int capBytes, Map<String, int> hourlyLimits
});




}
/// @nodoc
class __$RcxEnergyCopyWithImpl<$Res>
    implements _$RcxEnergyCopyWith<$Res> {
  __$RcxEnergyCopyWithImpl(this._self, this._then);

  final _RcxEnergy _self;
  final $Res Function(_RcxEnergy) _then;

/// Create a copy of RcxEnergy
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? level = null,Object? day = null,Object? requests = null,Object? bytes = null,Object? capBytes = null,Object? hourlyLimits = null,}) {
  return _then(_RcxEnergy(
level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as String,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as String,requests: null == requests ? _self.requests : requests // ignore: cast_nullable_to_non_nullable
as int,bytes: null == bytes ? _self.bytes : bytes // ignore: cast_nullable_to_non_nullable
as int,capBytes: null == capBytes ? _self.capBytes : capBytes // ignore: cast_nullable_to_non_nullable
as int,hourlyLimits: null == hourlyLimits ? _self._hourlyLimits : hourlyLimits // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}


}


/// @nodoc
mixin _$RcxStatus {

 bool get running; String get mode; String get network; List<RcxGroupStatus> get groups; RcxEnergy get energy; List<RcxReason> get problems; String get split; int get library; RcxScenarioStatus? get scenario; String get tunnelMode;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RcxStatus&&(identical(other.running, _this.running) || other.running == _this.running)&&(identical(other.mode, _this.mode) || other.mode == _this.mode)&&(identical(other.network, _this.network) || other.network == _this.network)&&const DeepCollectionEquality().equals(other.groups, _this.groups)&&(identical(other.energy, _this.energy) || other.energy == _this.energy)&&const DeepCollectionEquality().equals(other.problems, _this.problems)&&(identical(other.split, _this.split) || other.split == _this.split)&&(identical(other.library, _this.library) || other.library == _this.library)&&(identical(other.scenario, _this.scenario) || other.scenario == _this.scenario)&&(identical(other.tunnelMode, _this.tunnelMode) || other.tunnelMode == _this.tunnelMode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RcxStatus;
  return Object.hash(runtimeType,_this.running,_this.mode,_this.network,const DeepCollectionEquality().hash(_this.groups),_this.energy,const DeepCollectionEquality().hash(_this.problems),_this.split,_this.library,_this.scenario,_this.tunnelMode);
}

@override
String toString() {
  final _this = this as RcxStatus;
  return 'RcxStatus(running: ${_this.running}, mode: ${_this.mode}, network: ${_this.network}, groups: ${_this.groups}, energy: ${_this.energy}, problems: ${_this.problems}, split: ${_this.split}, library: ${_this.library}, scenario: ${_this.scenario}, tunnelMode: ${_this.tunnelMode})';
}


}

/// @nodoc
abstract mixin class $RcxStatusCopyWith<$Res>  {
  factory $RcxStatusCopyWith(RcxStatus value, $Res Function(RcxStatus) _then) = _$RcxStatusCopyWithImpl;
@useResult
$Res call({
 bool running, String mode, String network, List<RcxGroupStatus> groups, RcxEnergy energy, List<RcxReason> problems, String split, int library, RcxScenarioStatus? scenario, String tunnelMode
});


$RcxEnergyCopyWith<$Res> get energy;$RcxScenarioStatusCopyWith<$Res>? get scenario;

}
/// @nodoc
class _$RcxStatusCopyWithImpl<$Res>
    implements $RcxStatusCopyWith<$Res> {
  _$RcxStatusCopyWithImpl(this._self, this._then);

  final RcxStatus _self;
  final $Res Function(RcxStatus) _then;

/// Create a copy of RcxStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? running = null,Object? mode = null,Object? network = null,Object? groups = null,Object? energy = null,Object? problems = null,Object? split = null,Object? library = null,Object? scenario = freezed,Object? tunnelMode = null,}) {
  return _then(RcxStatus(
running: null == running ? _self.running : running // ignore: cast_nullable_to_non_nullable
as bool,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as String,network: null == network ? _self.network : network // ignore: cast_nullable_to_non_nullable
as String,groups: null == groups ? _self.groups : groups // ignore: cast_nullable_to_non_nullable
as List<RcxGroupStatus>,energy: null == energy ? _self.energy : energy // ignore: cast_nullable_to_non_nullable
as RcxEnergy,problems: null == problems ? _self.problems : problems // ignore: cast_nullable_to_non_nullable
as List<RcxReason>,split: null == split ? _self.split : split // ignore: cast_nullable_to_non_nullable
as String,library: null == library ? _self.library : library // ignore: cast_nullable_to_non_nullable
as int,scenario: freezed == scenario ? _self.scenario : scenario // ignore: cast_nullable_to_non_nullable
as RcxScenarioStatus?,tunnelMode: null == tunnelMode ? _self.tunnelMode : tunnelMode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of RcxStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RcxEnergyCopyWith<$Res> get energy {
  
  return $RcxEnergyCopyWith<$Res>(_self.energy, (value) {
    return _then(_self.copyWith(energy: value));
  });
}/// Create a copy of RcxStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RcxScenarioStatusCopyWith<$Res>? get scenario {
    if (_self.scenario == null) {
    return null;
  }

  return $RcxScenarioStatusCopyWith<$Res>(_self.scenario!, (value) {
    return _then(_self.copyWith(scenario: value));
  });
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool running,  String mode,  String network,  List<RcxGroupStatus> groups,  RcxEnergy energy,  List<RcxReason> problems,  String split,  int library,  RcxScenarioStatus? scenario,  String tunnelMode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RcxStatus() when $default != null:
return $default(_that.running,_that.mode,_that.network,_that.groups,_that.energy,_that.problems,_that.split,_that.library,_that.scenario,_that.tunnelMode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool running,  String mode,  String network,  List<RcxGroupStatus> groups,  RcxEnergy energy,  List<RcxReason> problems,  String split,  int library,  RcxScenarioStatus? scenario,  String tunnelMode)  $default,) {final _that = this;
switch (_that) {
case _RcxStatus():
return $default(_that.running,_that.mode,_that.network,_that.groups,_that.energy,_that.problems,_that.split,_that.library,_that.scenario,_that.tunnelMode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool running,  String mode,  String network,  List<RcxGroupStatus> groups,  RcxEnergy energy,  List<RcxReason> problems,  String split,  int library,  RcxScenarioStatus? scenario,  String tunnelMode)?  $default,) {final _that = this;
switch (_that) {
case _RcxStatus() when $default != null:
return $default(_that.running,_that.mode,_that.network,_that.groups,_that.energy,_that.problems,_that.split,_that.library,_that.scenario,_that.tunnelMode);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RcxStatus implements RcxStatus {
  const _RcxStatus({this.running = false, this.mode = 'stopped', this.network = '',  List<RcxGroupStatus> groups = const [], this.energy = const RcxEnergy(),  List<RcxReason> problems = const [], this.split = '', this.library = 0, this.scenario, this.tunnelMode = ''}): _groups = groups,_problems = problems;
  factory _RcxStatus.fromJson(Map<String, dynamic> json) => _$RcxStatusFromJson(json);

@override@JsonKey() final  bool running;
@override@JsonKey() final  String mode;
@override@JsonKey() final  String network;
 final  List<RcxGroupStatus> _groups;
@override@JsonKey() List<RcxGroupStatus> get groups {
  if (_groups is EqualUnmodifiableListView) return _groups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_groups);
}

@override@JsonKey() final  RcxEnergy energy;
 final  List<RcxReason> _problems;
@override@JsonKey() List<RcxReason> get problems {
  if (_problems is EqualUnmodifiableListView) return _problems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_problems);
}

@override@JsonKey() final  String split;
@override@JsonKey() final  int library;
@override final  RcxScenarioStatus? scenario;
@override@JsonKey() final  String tunnelMode;

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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RcxStatus&&(identical(other.running, running) || other.running == running)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.network, network) || other.network == network)&&const DeepCollectionEquality().equals(other.groups, _groups)&&(identical(other.energy, energy) || other.energy == energy)&&const DeepCollectionEquality().equals(other.problems, _problems)&&(identical(other.split, split) || other.split == split)&&(identical(other.library, library) || other.library == library)&&(identical(other.scenario, scenario) || other.scenario == scenario)&&(identical(other.tunnelMode, tunnelMode) || other.tunnelMode == tunnelMode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,running,mode,network,const DeepCollectionEquality().hash(_groups),energy,const DeepCollectionEquality().hash(_problems),split,library,scenario,tunnelMode);
}

@override
String toString() {
    return 'RcxStatus(running: $running, mode: $mode, network: $network, groups: $groups, energy: $energy, problems: $problems, split: $split, library: $library, scenario: $scenario, tunnelMode: $tunnelMode)';
}


}

/// @nodoc
abstract mixin class _$RcxStatusCopyWith<$Res> implements $RcxStatusCopyWith<$Res> {
  factory _$RcxStatusCopyWith(_RcxStatus value, $Res Function(_RcxStatus) _then) = __$RcxStatusCopyWithImpl;
@override @useResult
$Res call({
 bool running, String mode, String network, List<RcxGroupStatus> groups, RcxEnergy energy, List<RcxReason> problems, String split, int library, RcxScenarioStatus? scenario, String tunnelMode
});


@override $RcxEnergyCopyWith<$Res> get energy;@override $RcxScenarioStatusCopyWith<$Res>? get scenario;

}
/// @nodoc
class __$RcxStatusCopyWithImpl<$Res>
    implements _$RcxStatusCopyWith<$Res> {
  __$RcxStatusCopyWithImpl(this._self, this._then);

  final _RcxStatus _self;
  final $Res Function(_RcxStatus) _then;

/// Create a copy of RcxStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? running = null,Object? mode = null,Object? network = null,Object? groups = null,Object? energy = null,Object? problems = null,Object? split = null,Object? library = null,Object? scenario = freezed,Object? tunnelMode = null,}) {
  return _then(_RcxStatus(
running: null == running ? _self.running : running // ignore: cast_nullable_to_non_nullable
as bool,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as String,network: null == network ? _self.network : network // ignore: cast_nullable_to_non_nullable
as String,groups: null == groups ? _self._groups : groups // ignore: cast_nullable_to_non_nullable
as List<RcxGroupStatus>,energy: null == energy ? _self.energy : energy // ignore: cast_nullable_to_non_nullable
as RcxEnergy,problems: null == problems ? _self._problems : problems // ignore: cast_nullable_to_non_nullable
as List<RcxReason>,split: null == split ? _self.split : split // ignore: cast_nullable_to_non_nullable
as String,library: null == library ? _self.library : library // ignore: cast_nullable_to_non_nullable
as int,scenario: freezed == scenario ? _self.scenario : scenario // ignore: cast_nullable_to_non_nullable
as RcxScenarioStatus?,tunnelMode: null == tunnelMode ? _self.tunnelMode : tunnelMode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of RcxStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RcxEnergyCopyWith<$Res> get energy {
  
  return $RcxEnergyCopyWith<$Res>(_self.energy, (value) {
    return _then(_self.copyWith(energy: value));
  });
}/// Create a copy of RcxStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RcxScenarioStatusCopyWith<$Res>? get scenario {
    if (_self.scenario == null) {
    return null;
  }

  return $RcxScenarioStatusCopyWith<$Res>(_self.scenario!, (value) {
    return _then(_self.copyWith(scenario: value));
  });
}
}


/// @nodoc
mixin _$RcxScenarioStatus {

 String get id; String get title; String get source; RcxReason? get problem; RcxGroupNetwork? get network;/// The mode it holds on this network; empty leaves it to the user.
 String get mode; bool get manual; bool get holdsMode; Map<String, String> get groups;
/// Create a copy of RcxScenarioStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RcxScenarioStatusCopyWith<RcxScenarioStatus> get copyWith => _$RcxScenarioStatusCopyWithImpl<RcxScenarioStatus>(this as RcxScenarioStatus, _$identity);

  /// Serializes this RcxScenarioStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RcxScenarioStatus;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RcxScenarioStatus&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.source, _this.source) || other.source == _this.source)&&(identical(other.problem, _this.problem) || other.problem == _this.problem)&&(identical(other.network, _this.network) || other.network == _this.network)&&(identical(other.mode, _this.mode) || other.mode == _this.mode)&&(identical(other.manual, _this.manual) || other.manual == _this.manual)&&(identical(other.holdsMode, _this.holdsMode) || other.holdsMode == _this.holdsMode)&&const DeepCollectionEquality().equals(other.groups, _this.groups));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RcxScenarioStatus;
  return Object.hash(runtimeType,_this.id,_this.title,_this.source,_this.problem,_this.network,_this.mode,_this.manual,_this.holdsMode,const DeepCollectionEquality().hash(_this.groups));
}

@override
String toString() {
  final _this = this as RcxScenarioStatus;
  return 'RcxScenarioStatus(id: ${_this.id}, title: ${_this.title}, source: ${_this.source}, problem: ${_this.problem}, network: ${_this.network}, mode: ${_this.mode}, manual: ${_this.manual}, holdsMode: ${_this.holdsMode}, groups: ${_this.groups})';
}


}

/// @nodoc
abstract mixin class $RcxScenarioStatusCopyWith<$Res>  {
  factory $RcxScenarioStatusCopyWith(RcxScenarioStatus value, $Res Function(RcxScenarioStatus) _then) = _$RcxScenarioStatusCopyWithImpl;
@useResult
$Res call({
 String id, String title, String source, RcxReason? problem, RcxGroupNetwork? network, String mode, bool manual, bool holdsMode, Map<String, String> groups
});


$RcxReasonCopyWith<$Res>? get problem;$RcxGroupNetworkCopyWith<$Res>? get network;

}
/// @nodoc
class _$RcxScenarioStatusCopyWithImpl<$Res>
    implements $RcxScenarioStatusCopyWith<$Res> {
  _$RcxScenarioStatusCopyWithImpl(this._self, this._then);

  final RcxScenarioStatus _self;
  final $Res Function(RcxScenarioStatus) _then;

/// Create a copy of RcxScenarioStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? source = null,Object? problem = freezed,Object? network = freezed,Object? mode = null,Object? manual = null,Object? holdsMode = null,Object? groups = null,}) {
  return _then(RcxScenarioStatus(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,problem: freezed == problem ? _self.problem : problem // ignore: cast_nullable_to_non_nullable
as RcxReason?,network: freezed == network ? _self.network : network // ignore: cast_nullable_to_non_nullable
as RcxGroupNetwork?,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as String,manual: null == manual ? _self.manual : manual // ignore: cast_nullable_to_non_nullable
as bool,holdsMode: null == holdsMode ? _self.holdsMode : holdsMode // ignore: cast_nullable_to_non_nullable
as bool,groups: null == groups ? _self.groups : groups // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}
/// Create a copy of RcxScenarioStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RcxReasonCopyWith<$Res>? get problem {
    if (_self.problem == null) {
    return null;
  }

  return $RcxReasonCopyWith<$Res>(_self.problem!, (value) {
    return _then(_self.copyWith(problem: value));
  });
}/// Create a copy of RcxScenarioStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RcxGroupNetworkCopyWith<$Res>? get network {
    if (_self.network == null) {
    return null;
  }

  return $RcxGroupNetworkCopyWith<$Res>(_self.network!, (value) {
    return _then(_self.copyWith(network: value));
  });
}
}


/// Adds pattern-matching-related methods to [RcxScenarioStatus].
extension RcxScenarioStatusPatterns on RcxScenarioStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RcxScenarioStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RcxScenarioStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RcxScenarioStatus value)  $default,){
final _that = this;
switch (_that) {
case _RcxScenarioStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RcxScenarioStatus value)?  $default,){
final _that = this;
switch (_that) {
case _RcxScenarioStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String source,  RcxReason? problem,  RcxGroupNetwork? network,  String mode,  bool manual,  bool holdsMode,  Map<String, String> groups)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RcxScenarioStatus() when $default != null:
return $default(_that.id,_that.title,_that.source,_that.problem,_that.network,_that.mode,_that.manual,_that.holdsMode,_that.groups);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String source,  RcxReason? problem,  RcxGroupNetwork? network,  String mode,  bool manual,  bool holdsMode,  Map<String, String> groups)  $default,) {final _that = this;
switch (_that) {
case _RcxScenarioStatus():
return $default(_that.id,_that.title,_that.source,_that.problem,_that.network,_that.mode,_that.manual,_that.holdsMode,_that.groups);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String source,  RcxReason? problem,  RcxGroupNetwork? network,  String mode,  bool manual,  bool holdsMode,  Map<String, String> groups)?  $default,) {final _that = this;
switch (_that) {
case _RcxScenarioStatus() when $default != null:
return $default(_that.id,_that.title,_that.source,_that.problem,_that.network,_that.mode,_that.manual,_that.holdsMode,_that.groups);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RcxScenarioStatus implements RcxScenarioStatus {
  const _RcxScenarioStatus({required this.id, this.title = '', this.source = '', this.problem, this.network, this.mode = '', this.manual = false, this.holdsMode = false,  Map<String, String> groups = const {}}): _groups = groups;
  factory _RcxScenarioStatus.fromJson(Map<String, dynamic> json) => _$RcxScenarioStatusFromJson(json);

@override final  String id;
@override@JsonKey() final  String title;
@override@JsonKey() final  String source;
@override final  RcxReason? problem;
@override final  RcxGroupNetwork? network;
/// The mode it holds on this network; empty leaves it to the user.
@override@JsonKey() final  String mode;
@override@JsonKey() final  bool manual;
@override@JsonKey() final  bool holdsMode;
 final  Map<String, String> _groups;
@override@JsonKey() Map<String, String> get groups {
  if (_groups is EqualUnmodifiableMapView) return _groups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_groups);
}


/// Create a copy of RcxScenarioStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RcxScenarioStatusCopyWith<_RcxScenarioStatus> get copyWith => __$RcxScenarioStatusCopyWithImpl<_RcxScenarioStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RcxScenarioStatusToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RcxScenarioStatus&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.source, source) || other.source == source)&&(identical(other.problem, problem) || other.problem == problem)&&(identical(other.network, network) || other.network == network)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.manual, manual) || other.manual == manual)&&(identical(other.holdsMode, holdsMode) || other.holdsMode == holdsMode)&&const DeepCollectionEquality().equals(other.groups, _groups));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,title,source,problem,network,mode,manual,holdsMode,const DeepCollectionEquality().hash(_groups));
}

@override
String toString() {
    return 'RcxScenarioStatus(id: $id, title: $title, source: $source, problem: $problem, network: $network, mode: $mode, manual: $manual, holdsMode: $holdsMode, groups: $groups)';
}


}

/// @nodoc
abstract mixin class _$RcxScenarioStatusCopyWith<$Res> implements $RcxScenarioStatusCopyWith<$Res> {
  factory _$RcxScenarioStatusCopyWith(_RcxScenarioStatus value, $Res Function(_RcxScenarioStatus) _then) = __$RcxScenarioStatusCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String source, RcxReason? problem, RcxGroupNetwork? network, String mode, bool manual, bool holdsMode, Map<String, String> groups
});


@override $RcxReasonCopyWith<$Res>? get problem;@override $RcxGroupNetworkCopyWith<$Res>? get network;

}
/// @nodoc
class __$RcxScenarioStatusCopyWithImpl<$Res>
    implements _$RcxScenarioStatusCopyWith<$Res> {
  __$RcxScenarioStatusCopyWithImpl(this._self, this._then);

  final _RcxScenarioStatus _self;
  final $Res Function(_RcxScenarioStatus) _then;

/// Create a copy of RcxScenarioStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? source = null,Object? problem = freezed,Object? network = freezed,Object? mode = null,Object? manual = null,Object? holdsMode = null,Object? groups = null,}) {
  return _then(_RcxScenarioStatus(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,problem: freezed == problem ? _self.problem : problem // ignore: cast_nullable_to_non_nullable
as RcxReason?,network: freezed == network ? _self.network : network // ignore: cast_nullable_to_non_nullable
as RcxGroupNetwork?,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as String,manual: null == manual ? _self.manual : manual // ignore: cast_nullable_to_non_nullable
as bool,holdsMode: null == holdsMode ? _self.holdsMode : holdsMode // ignore: cast_nullable_to_non_nullable
as bool,groups: null == groups ? _self._groups : groups // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

/// Create a copy of RcxScenarioStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RcxReasonCopyWith<$Res>? get problem {
    if (_self.problem == null) {
    return null;
  }

  return $RcxReasonCopyWith<$Res>(_self.problem!, (value) {
    return _then(_self.copyWith(problem: value));
  });
}/// Create a copy of RcxScenarioStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RcxGroupNetworkCopyWith<$Res>? get network {
    if (_self.network == null) {
    return null;
  }

  return $RcxGroupNetworkCopyWith<$Res>(_self.network!, (value) {
    return _then(_self.copyWith(network: value));
  });
}
}


/// @nodoc
mixin _$RcxExplanation {

 String get group; String get profile; RcxDecision get decision; int get freshnessSeconds; DateTime? get at;
/// Create a copy of RcxExplanation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RcxExplanationCopyWith<RcxExplanation> get copyWith => _$RcxExplanationCopyWithImpl<RcxExplanation>(this as RcxExplanation, _$identity);

  /// Serializes this RcxExplanation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RcxExplanation;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RcxExplanation&&(identical(other.group, _this.group) || other.group == _this.group)&&(identical(other.profile, _this.profile) || other.profile == _this.profile)&&(identical(other.decision, _this.decision) || other.decision == _this.decision)&&(identical(other.freshnessSeconds, _this.freshnessSeconds) || other.freshnessSeconds == _this.freshnessSeconds)&&(identical(other.at, _this.at) || other.at == _this.at));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RcxExplanation;
  return Object.hash(runtimeType,_this.group,_this.profile,_this.decision,_this.freshnessSeconds,_this.at);
}

@override
String toString() {
  final _this = this as RcxExplanation;
  return 'RcxExplanation(group: ${_this.group}, profile: ${_this.profile}, decision: ${_this.decision}, freshnessSeconds: ${_this.freshnessSeconds}, at: ${_this.at})';
}


}

/// @nodoc
abstract mixin class $RcxExplanationCopyWith<$Res>  {
  factory $RcxExplanationCopyWith(RcxExplanation value, $Res Function(RcxExplanation) _then) = _$RcxExplanationCopyWithImpl;
@useResult
$Res call({
 String group, String profile, RcxDecision decision, int freshnessSeconds, DateTime? at
});


$RcxDecisionCopyWith<$Res> get decision;

}
/// @nodoc
class _$RcxExplanationCopyWithImpl<$Res>
    implements $RcxExplanationCopyWith<$Res> {
  _$RcxExplanationCopyWithImpl(this._self, this._then);

  final RcxExplanation _self;
  final $Res Function(RcxExplanation) _then;

/// Create a copy of RcxExplanation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? group = null,Object? profile = null,Object? decision = null,Object? freshnessSeconds = null,Object? at = freezed,}) {
  return _then(RcxExplanation(
group: null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as String,profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as String,decision: null == decision ? _self.decision : decision // ignore: cast_nullable_to_non_nullable
as RcxDecision,freshnessSeconds: null == freshnessSeconds ? _self.freshnessSeconds : freshnessSeconds // ignore: cast_nullable_to_non_nullable
as int,at: freezed == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of RcxExplanation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RcxDecisionCopyWith<$Res> get decision {
  
  return $RcxDecisionCopyWith<$Res>(_self.decision, (value) {
    return _then(_self.copyWith(decision: value));
  });
}
}


/// Adds pattern-matching-related methods to [RcxExplanation].
extension RcxExplanationPatterns on RcxExplanation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RcxExplanation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RcxExplanation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RcxExplanation value)  $default,){
final _that = this;
switch (_that) {
case _RcxExplanation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RcxExplanation value)?  $default,){
final _that = this;
switch (_that) {
case _RcxExplanation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String group,  String profile,  RcxDecision decision,  int freshnessSeconds,  DateTime? at)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RcxExplanation() when $default != null:
return $default(_that.group,_that.profile,_that.decision,_that.freshnessSeconds,_that.at);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String group,  String profile,  RcxDecision decision,  int freshnessSeconds,  DateTime? at)  $default,) {final _that = this;
switch (_that) {
case _RcxExplanation():
return $default(_that.group,_that.profile,_that.decision,_that.freshnessSeconds,_that.at);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String group,  String profile,  RcxDecision decision,  int freshnessSeconds,  DateTime? at)?  $default,) {final _that = this;
switch (_that) {
case _RcxExplanation() when $default != null:
return $default(_that.group,_that.profile,_that.decision,_that.freshnessSeconds,_that.at);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RcxExplanation implements RcxExplanation {
  const _RcxExplanation({required this.group, this.profile = '', this.decision = const RcxDecision(), this.freshnessSeconds = 0, this.at});
  factory _RcxExplanation.fromJson(Map<String, dynamic> json) => _$RcxExplanationFromJson(json);

@override final  String group;
@override@JsonKey() final  String profile;
@override@JsonKey() final  RcxDecision decision;
@override@JsonKey() final  int freshnessSeconds;
@override final  DateTime? at;

/// Create a copy of RcxExplanation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RcxExplanationCopyWith<_RcxExplanation> get copyWith => __$RcxExplanationCopyWithImpl<_RcxExplanation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RcxExplanationToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RcxExplanation&&(identical(other.group, group) || other.group == group)&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.decision, decision) || other.decision == decision)&&(identical(other.freshnessSeconds, freshnessSeconds) || other.freshnessSeconds == freshnessSeconds)&&(identical(other.at, at) || other.at == at));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,group,profile,decision,freshnessSeconds,at);
}

@override
String toString() {
    return 'RcxExplanation(group: $group, profile: $profile, decision: $decision, freshnessSeconds: $freshnessSeconds, at: $at)';
}


}

/// @nodoc
abstract mixin class _$RcxExplanationCopyWith<$Res> implements $RcxExplanationCopyWith<$Res> {
  factory _$RcxExplanationCopyWith(_RcxExplanation value, $Res Function(_RcxExplanation) _then) = __$RcxExplanationCopyWithImpl;
@override @useResult
$Res call({
 String group, String profile, RcxDecision decision, int freshnessSeconds, DateTime? at
});


@override $RcxDecisionCopyWith<$Res> get decision;

}
/// @nodoc
class __$RcxExplanationCopyWithImpl<$Res>
    implements _$RcxExplanationCopyWith<$Res> {
  __$RcxExplanationCopyWithImpl(this._self, this._then);

  final _RcxExplanation _self;
  final $Res Function(_RcxExplanation) _then;

/// Create a copy of RcxExplanation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? group = null,Object? profile = null,Object? decision = null,Object? freshnessSeconds = null,Object? at = freezed,}) {
  return _then(_RcxExplanation(
group: null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as String,profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as String,decision: null == decision ? _self.decision : decision // ignore: cast_nullable_to_non_nullable
as RcxDecision,freshnessSeconds: null == freshnessSeconds ? _self.freshnessSeconds : freshnessSeconds // ignore: cast_nullable_to_non_nullable
as int,at: freezed == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of RcxExplanation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RcxDecisionCopyWith<$Res> get decision {
  
  return $RcxDecisionCopyWith<$Res>(_self.decision, (value) {
    return _then(_self.copyWith(decision: value));
  });
}
}


/// @nodoc
mixin _$RcxJournalEntry {

 int get seq; DateTime get at; String get group; String get kind; String get from; String get to; RcxReason get reason;
/// Create a copy of RcxJournalEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RcxJournalEntryCopyWith<RcxJournalEntry> get copyWith => _$RcxJournalEntryCopyWithImpl<RcxJournalEntry>(this as RcxJournalEntry, _$identity);

  /// Serializes this RcxJournalEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RcxJournalEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RcxJournalEntry&&(identical(other.seq, _this.seq) || other.seq == _this.seq)&&(identical(other.at, _this.at) || other.at == _this.at)&&(identical(other.group, _this.group) || other.group == _this.group)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.from, _this.from) || other.from == _this.from)&&(identical(other.to, _this.to) || other.to == _this.to)&&(identical(other.reason, _this.reason) || other.reason == _this.reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RcxJournalEntry;
  return Object.hash(runtimeType,_this.seq,_this.at,_this.group,_this.kind,_this.from,_this.to,_this.reason);
}

@override
String toString() {
  final _this = this as RcxJournalEntry;
  return 'RcxJournalEntry(seq: ${_this.seq}, at: ${_this.at}, group: ${_this.group}, kind: ${_this.kind}, from: ${_this.from}, to: ${_this.to}, reason: ${_this.reason})';
}


}

/// @nodoc
abstract mixin class $RcxJournalEntryCopyWith<$Res>  {
  factory $RcxJournalEntryCopyWith(RcxJournalEntry value, $Res Function(RcxJournalEntry) _then) = _$RcxJournalEntryCopyWithImpl;
@useResult
$Res call({
 int seq, DateTime at, String group, String kind, String from, String to, RcxReason reason
});


$RcxReasonCopyWith<$Res> get reason;

}
/// @nodoc
class _$RcxJournalEntryCopyWithImpl<$Res>
    implements $RcxJournalEntryCopyWith<$Res> {
  _$RcxJournalEntryCopyWithImpl(this._self, this._then);

  final RcxJournalEntry _self;
  final $Res Function(RcxJournalEntry) _then;

/// Create a copy of RcxJournalEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? seq = null,Object? at = null,Object? group = null,Object? kind = null,Object? from = null,Object? to = null,Object? reason = null,}) {
  return _then(RcxJournalEntry(
seq: null == seq ? _self.seq : seq // ignore: cast_nullable_to_non_nullable
as int,at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime,group: null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as String,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as RcxReason,
  ));
}
/// Create a copy of RcxJournalEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RcxReasonCopyWith<$Res> get reason {
  
  return $RcxReasonCopyWith<$Res>(_self.reason, (value) {
    return _then(_self.copyWith(reason: value));
  });
}
}


/// Adds pattern-matching-related methods to [RcxJournalEntry].
extension RcxJournalEntryPatterns on RcxJournalEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RcxJournalEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RcxJournalEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RcxJournalEntry value)  $default,){
final _that = this;
switch (_that) {
case _RcxJournalEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RcxJournalEntry value)?  $default,){
final _that = this;
switch (_that) {
case _RcxJournalEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int seq,  DateTime at,  String group,  String kind,  String from,  String to,  RcxReason reason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RcxJournalEntry() when $default != null:
return $default(_that.seq,_that.at,_that.group,_that.kind,_that.from,_that.to,_that.reason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int seq,  DateTime at,  String group,  String kind,  String from,  String to,  RcxReason reason)  $default,) {final _that = this;
switch (_that) {
case _RcxJournalEntry():
return $default(_that.seq,_that.at,_that.group,_that.kind,_that.from,_that.to,_that.reason);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int seq,  DateTime at,  String group,  String kind,  String from,  String to,  RcxReason reason)?  $default,) {final _that = this;
switch (_that) {
case _RcxJournalEntry() when $default != null:
return $default(_that.seq,_that.at,_that.group,_that.kind,_that.from,_that.to,_that.reason);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RcxJournalEntry implements RcxJournalEntry {
  const _RcxJournalEntry({required this.seq, required this.at, this.group = '', required this.kind, this.from = '', this.to = '', this.reason = const RcxReason(code: '')});
  factory _RcxJournalEntry.fromJson(Map<String, dynamic> json) => _$RcxJournalEntryFromJson(json);

@override final  int seq;
@override final  DateTime at;
@override@JsonKey() final  String group;
@override final  String kind;
@override@JsonKey() final  String from;
@override@JsonKey() final  String to;
@override@JsonKey() final  RcxReason reason;

/// Create a copy of RcxJournalEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RcxJournalEntryCopyWith<_RcxJournalEntry> get copyWith => __$RcxJournalEntryCopyWithImpl<_RcxJournalEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RcxJournalEntryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RcxJournalEntry&&(identical(other.seq, seq) || other.seq == seq)&&(identical(other.at, at) || other.at == at)&&(identical(other.group, group) || other.group == group)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to)&&(identical(other.reason, reason) || other.reason == reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,seq,at,group,kind,from,to,reason);
}

@override
String toString() {
    return 'RcxJournalEntry(seq: $seq, at: $at, group: $group, kind: $kind, from: $from, to: $to, reason: $reason)';
}


}

/// @nodoc
abstract mixin class _$RcxJournalEntryCopyWith<$Res> implements $RcxJournalEntryCopyWith<$Res> {
  factory _$RcxJournalEntryCopyWith(_RcxJournalEntry value, $Res Function(_RcxJournalEntry) _then) = __$RcxJournalEntryCopyWithImpl;
@override @useResult
$Res call({
 int seq, DateTime at, String group, String kind, String from, String to, RcxReason reason
});


@override $RcxReasonCopyWith<$Res> get reason;

}
/// @nodoc
class __$RcxJournalEntryCopyWithImpl<$Res>
    implements _$RcxJournalEntryCopyWith<$Res> {
  __$RcxJournalEntryCopyWithImpl(this._self, this._then);

  final _RcxJournalEntry _self;
  final $Res Function(_RcxJournalEntry) _then;

/// Create a copy of RcxJournalEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? seq = null,Object? at = null,Object? group = null,Object? kind = null,Object? from = null,Object? to = null,Object? reason = null,}) {
  return _then(_RcxJournalEntry(
seq: null == seq ? _self.seq : seq // ignore: cast_nullable_to_non_nullable
as int,at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime,group: null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as String,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as RcxReason,
  ));
}

/// Create a copy of RcxJournalEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RcxReasonCopyWith<$Res> get reason {
  
  return $RcxReasonCopyWith<$Res>(_self.reason, (value) {
    return _then(_self.copyWith(reason: value));
  });
}
}


/// @nodoc
mixin _$RcxProfileInfo {

 String get id;/// `scenario` for an auto control, empty for a group profile.
 String get kind; String get title; String get level; String get source;@JsonKey(name: 'extends') String get extendsId; String get error; Map<String, Map<String, String>> get l10n; List<String> get consent;
/// Create a copy of RcxProfileInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RcxProfileInfoCopyWith<RcxProfileInfo> get copyWith => _$RcxProfileInfoCopyWithImpl<RcxProfileInfo>(this as RcxProfileInfo, _$identity);

  /// Serializes this RcxProfileInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RcxProfileInfo;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RcxProfileInfo&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.level, _this.level) || other.level == _this.level)&&(identical(other.source, _this.source) || other.source == _this.source)&&(identical(other.extendsId, _this.extendsId) || other.extendsId == _this.extendsId)&&(identical(other.error, _this.error) || other.error == _this.error)&&const DeepCollectionEquality().equals(other.l10n, _this.l10n)&&const DeepCollectionEquality().equals(other.consent, _this.consent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RcxProfileInfo;
  return Object.hash(runtimeType,_this.id,_this.kind,_this.title,_this.level,_this.source,_this.extendsId,_this.error,const DeepCollectionEquality().hash(_this.l10n),const DeepCollectionEquality().hash(_this.consent));
}

@override
String toString() {
  final _this = this as RcxProfileInfo;
  return 'RcxProfileInfo(id: ${_this.id}, kind: ${_this.kind}, title: ${_this.title}, level: ${_this.level}, source: ${_this.source}, extendsId: ${_this.extendsId}, error: ${_this.error}, l10n: ${_this.l10n}, consent: ${_this.consent})';
}


}

/// @nodoc
abstract mixin class $RcxProfileInfoCopyWith<$Res>  {
  factory $RcxProfileInfoCopyWith(RcxProfileInfo value, $Res Function(RcxProfileInfo) _then) = _$RcxProfileInfoCopyWithImpl;
@useResult
$Res call({
 String id, String kind, String title, String level, String source,@JsonKey(name: 'extends') String extendsId, String error, Map<String, Map<String, String>> l10n, List<String> consent
});




}
/// @nodoc
class _$RcxProfileInfoCopyWithImpl<$Res>
    implements $RcxProfileInfoCopyWith<$Res> {
  _$RcxProfileInfoCopyWithImpl(this._self, this._then);

  final RcxProfileInfo _self;
  final $Res Function(RcxProfileInfo) _then;

/// Create a copy of RcxProfileInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? kind = null,Object? title = null,Object? level = null,Object? source = null,Object? extendsId = null,Object? error = null,Object? l10n = null,Object? consent = null,}) {
  return _then(RcxProfileInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,extendsId: null == extendsId ? _self.extendsId : extendsId // ignore: cast_nullable_to_non_nullable
as String,error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,l10n: null == l10n ? _self.l10n : l10n // ignore: cast_nullable_to_non_nullable
as Map<String, Map<String, String>>,consent: null == consent ? _self.consent : consent // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [RcxProfileInfo].
extension RcxProfileInfoPatterns on RcxProfileInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RcxProfileInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RcxProfileInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RcxProfileInfo value)  $default,){
final _that = this;
switch (_that) {
case _RcxProfileInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RcxProfileInfo value)?  $default,){
final _that = this;
switch (_that) {
case _RcxProfileInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String kind,  String title,  String level,  String source, @JsonKey(name: 'extends')  String extendsId,  String error,  Map<String, Map<String, String>> l10n,  List<String> consent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RcxProfileInfo() when $default != null:
return $default(_that.id,_that.kind,_that.title,_that.level,_that.source,_that.extendsId,_that.error,_that.l10n,_that.consent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String kind,  String title,  String level,  String source, @JsonKey(name: 'extends')  String extendsId,  String error,  Map<String, Map<String, String>> l10n,  List<String> consent)  $default,) {final _that = this;
switch (_that) {
case _RcxProfileInfo():
return $default(_that.id,_that.kind,_that.title,_that.level,_that.source,_that.extendsId,_that.error,_that.l10n,_that.consent);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String kind,  String title,  String level,  String source, @JsonKey(name: 'extends')  String extendsId,  String error,  Map<String, Map<String, String>> l10n,  List<String> consent)?  $default,) {final _that = this;
switch (_that) {
case _RcxProfileInfo() when $default != null:
return $default(_that.id,_that.kind,_that.title,_that.level,_that.source,_that.extendsId,_that.error,_that.l10n,_that.consent);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RcxProfileInfo implements RcxProfileInfo {
  const _RcxProfileInfo({required this.id, this.kind = '', this.title = '', this.level = '', this.source = '', @JsonKey(name: 'extends') this.extendsId = '', this.error = '',  Map<String, Map<String, String>> l10n = const {},  List<String> consent = const []}): _l10n = l10n,_consent = consent;
  factory _RcxProfileInfo.fromJson(Map<String, dynamic> json) => _$RcxProfileInfoFromJson(json);

@override final  String id;
/// `scenario` for an auto control, empty for a group profile.
@override@JsonKey() final  String kind;
@override@JsonKey() final  String title;
@override@JsonKey() final  String level;
@override@JsonKey() final  String source;
@override@JsonKey(name: 'extends') final  String extendsId;
@override@JsonKey() final  String error;
 final  Map<String, Map<String, String>> _l10n;
@override@JsonKey() Map<String, Map<String, String>> get l10n {
  if (_l10n is EqualUnmodifiableMapView) return _l10n;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_l10n);
}

 final  List<String> _consent;
@override@JsonKey() List<String> get consent {
  if (_consent is EqualUnmodifiableListView) return _consent;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_consent);
}


/// Create a copy of RcxProfileInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RcxProfileInfoCopyWith<_RcxProfileInfo> get copyWith => __$RcxProfileInfoCopyWithImpl<_RcxProfileInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RcxProfileInfoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RcxProfileInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.title, title) || other.title == title)&&(identical(other.level, level) || other.level == level)&&(identical(other.source, source) || other.source == source)&&(identical(other.extendsId, extendsId) || other.extendsId == extendsId)&&(identical(other.error, error) || other.error == error)&&const DeepCollectionEquality().equals(other.l10n, _l10n)&&const DeepCollectionEquality().equals(other.consent, _consent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,kind,title,level,source,extendsId,error,const DeepCollectionEquality().hash(_l10n),const DeepCollectionEquality().hash(_consent));
}

@override
String toString() {
    return 'RcxProfileInfo(id: $id, kind: $kind, title: $title, level: $level, source: $source, extendsId: $extendsId, error: $error, l10n: $l10n, consent: $consent)';
}


}

/// @nodoc
abstract mixin class _$RcxProfileInfoCopyWith<$Res> implements $RcxProfileInfoCopyWith<$Res> {
  factory _$RcxProfileInfoCopyWith(_RcxProfileInfo value, $Res Function(_RcxProfileInfo) _then) = __$RcxProfileInfoCopyWithImpl;
@override @useResult
$Res call({
 String id, String kind, String title, String level, String source,@JsonKey(name: 'extends') String extendsId, String error, Map<String, Map<String, String>> l10n, List<String> consent
});




}
/// @nodoc
class __$RcxProfileInfoCopyWithImpl<$Res>
    implements _$RcxProfileInfoCopyWith<$Res> {
  __$RcxProfileInfoCopyWithImpl(this._self, this._then);

  final _RcxProfileInfo _self;
  final $Res Function(_RcxProfileInfo) _then;

/// Create a copy of RcxProfileInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? kind = null,Object? title = null,Object? level = null,Object? source = null,Object? extendsId = null,Object? error = null,Object? l10n = null,Object? consent = null,}) {
  return _then(_RcxProfileInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,extendsId: null == extendsId ? _self.extendsId : extendsId // ignore: cast_nullable_to_non_nullable
as String,error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,l10n: null == l10n ? _self._l10n : l10n // ignore: cast_nullable_to_non_nullable
as Map<String, Map<String, String>>,consent: null == consent ? _self._consent : consent // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$RcxUserProfile {

 String get text;/// `scenario` for an auto control, empty for a group profile; names are
/// unique across both.
 String get kind; String get from; String get base; List<RcxProfileVersion> get history;
/// Create a copy of RcxUserProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RcxUserProfileCopyWith<RcxUserProfile> get copyWith => _$RcxUserProfileCopyWithImpl<RcxUserProfile>(this as RcxUserProfile, _$identity);

  /// Serializes this RcxUserProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RcxUserProfile;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RcxUserProfile&&(identical(other.text, _this.text) || other.text == _this.text)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.from, _this.from) || other.from == _this.from)&&(identical(other.base, _this.base) || other.base == _this.base)&&const DeepCollectionEquality().equals(other.history, _this.history));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RcxUserProfile;
  return Object.hash(runtimeType,_this.text,_this.kind,_this.from,_this.base,const DeepCollectionEquality().hash(_this.history));
}

@override
String toString() {
  final _this = this as RcxUserProfile;
  return 'RcxUserProfile(text: ${_this.text}, kind: ${_this.kind}, from: ${_this.from}, base: ${_this.base}, history: ${_this.history})';
}


}

/// @nodoc
abstract mixin class $RcxUserProfileCopyWith<$Res>  {
  factory $RcxUserProfileCopyWith(RcxUserProfile value, $Res Function(RcxUserProfile) _then) = _$RcxUserProfileCopyWithImpl;
@useResult
$Res call({
 String text, String kind, String from, String base, List<RcxProfileVersion> history
});




}
/// @nodoc
class _$RcxUserProfileCopyWithImpl<$Res>
    implements $RcxUserProfileCopyWith<$Res> {
  _$RcxUserProfileCopyWithImpl(this._self, this._then);

  final RcxUserProfile _self;
  final $Res Function(RcxUserProfile) _then;

/// Create a copy of RcxUserProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = null,Object? kind = null,Object? from = null,Object? base = null,Object? history = null,}) {
  return _then(RcxUserProfile(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as String,base: null == base ? _self.base : base // ignore: cast_nullable_to_non_nullable
as String,history: null == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as List<RcxProfileVersion>,
  ));
}

}


/// Adds pattern-matching-related methods to [RcxUserProfile].
extension RcxUserProfilePatterns on RcxUserProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RcxUserProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RcxUserProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RcxUserProfile value)  $default,){
final _that = this;
switch (_that) {
case _RcxUserProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RcxUserProfile value)?  $default,){
final _that = this;
switch (_that) {
case _RcxUserProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String text,  String kind,  String from,  String base,  List<RcxProfileVersion> history)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RcxUserProfile() when $default != null:
return $default(_that.text,_that.kind,_that.from,_that.base,_that.history);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String text,  String kind,  String from,  String base,  List<RcxProfileVersion> history)  $default,) {final _that = this;
switch (_that) {
case _RcxUserProfile():
return $default(_that.text,_that.kind,_that.from,_that.base,_that.history);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String text,  String kind,  String from,  String base,  List<RcxProfileVersion> history)?  $default,) {final _that = this;
switch (_that) {
case _RcxUserProfile() when $default != null:
return $default(_that.text,_that.kind,_that.from,_that.base,_that.history);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RcxUserProfile implements RcxUserProfile {
  const _RcxUserProfile({required this.text, this.kind = '', this.from = '', this.base = '',  List<RcxProfileVersion> history = const []}): _history = history;
  factory _RcxUserProfile.fromJson(Map<String, dynamic> json) => _$RcxUserProfileFromJson(json);

@override final  String text;
/// `scenario` for an auto control, empty for a group profile; names are
/// unique across both.
@override@JsonKey() final  String kind;
@override@JsonKey() final  String from;
@override@JsonKey() final  String base;
 final  List<RcxProfileVersion> _history;
@override@JsonKey() List<RcxProfileVersion> get history {
  if (_history is EqualUnmodifiableListView) return _history;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_history);
}


/// Create a copy of RcxUserProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RcxUserProfileCopyWith<_RcxUserProfile> get copyWith => __$RcxUserProfileCopyWithImpl<_RcxUserProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RcxUserProfileToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RcxUserProfile&&(identical(other.text, text) || other.text == text)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.from, from) || other.from == from)&&(identical(other.base, base) || other.base == base)&&const DeepCollectionEquality().equals(other.history, _history));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,text,kind,from,base,const DeepCollectionEquality().hash(_history));
}

@override
String toString() {
    return 'RcxUserProfile(text: $text, kind: $kind, from: $from, base: $base, history: $history)';
}


}

/// @nodoc
abstract mixin class _$RcxUserProfileCopyWith<$Res> implements $RcxUserProfileCopyWith<$Res> {
  factory _$RcxUserProfileCopyWith(_RcxUserProfile value, $Res Function(_RcxUserProfile) _then) = __$RcxUserProfileCopyWithImpl;
@override @useResult
$Res call({
 String text, String kind, String from, String base, List<RcxProfileVersion> history
});




}
/// @nodoc
class __$RcxUserProfileCopyWithImpl<$Res>
    implements _$RcxUserProfileCopyWith<$Res> {
  __$RcxUserProfileCopyWithImpl(this._self, this._then);

  final _RcxUserProfile _self;
  final $Res Function(_RcxUserProfile) _then;

/// Create a copy of RcxUserProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,Object? kind = null,Object? from = null,Object? base = null,Object? history = null,}) {
  return _then(_RcxUserProfile(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as String,base: null == base ? _self.base : base // ignore: cast_nullable_to_non_nullable
as String,history: null == history ? _self._history : history // ignore: cast_nullable_to_non_nullable
as List<RcxProfileVersion>,
  ));
}


}


/// @nodoc
mixin _$RcxProfileVersion {

 DateTime get at; String get text;
/// Create a copy of RcxProfileVersion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RcxProfileVersionCopyWith<RcxProfileVersion> get copyWith => _$RcxProfileVersionCopyWithImpl<RcxProfileVersion>(this as RcxProfileVersion, _$identity);

  /// Serializes this RcxProfileVersion to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RcxProfileVersion;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RcxProfileVersion&&(identical(other.at, _this.at) || other.at == _this.at)&&(identical(other.text, _this.text) || other.text == _this.text));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RcxProfileVersion;
  return Object.hash(runtimeType,_this.at,_this.text);
}

@override
String toString() {
  final _this = this as RcxProfileVersion;
  return 'RcxProfileVersion(at: ${_this.at}, text: ${_this.text})';
}


}

/// @nodoc
abstract mixin class $RcxProfileVersionCopyWith<$Res>  {
  factory $RcxProfileVersionCopyWith(RcxProfileVersion value, $Res Function(RcxProfileVersion) _then) = _$RcxProfileVersionCopyWithImpl;
@useResult
$Res call({
 DateTime at, String text
});




}
/// @nodoc
class _$RcxProfileVersionCopyWithImpl<$Res>
    implements $RcxProfileVersionCopyWith<$Res> {
  _$RcxProfileVersionCopyWithImpl(this._self, this._then);

  final RcxProfileVersion _self;
  final $Res Function(RcxProfileVersion) _then;

/// Create a copy of RcxProfileVersion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? at = null,Object? text = null,}) {
  return _then(RcxProfileVersion(
at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RcxProfileVersion].
extension RcxProfileVersionPatterns on RcxProfileVersion {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RcxProfileVersion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RcxProfileVersion() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RcxProfileVersion value)  $default,){
final _that = this;
switch (_that) {
case _RcxProfileVersion():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RcxProfileVersion value)?  $default,){
final _that = this;
switch (_that) {
case _RcxProfileVersion() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime at,  String text)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RcxProfileVersion() when $default != null:
return $default(_that.at,_that.text);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime at,  String text)  $default,) {final _that = this;
switch (_that) {
case _RcxProfileVersion():
return $default(_that.at,_that.text);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime at,  String text)?  $default,) {final _that = this;
switch (_that) {
case _RcxProfileVersion() when $default != null:
return $default(_that.at,_that.text);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RcxProfileVersion implements RcxProfileVersion {
  const _RcxProfileVersion({required this.at, required this.text});
  factory _RcxProfileVersion.fromJson(Map<String, dynamic> json) => _$RcxProfileVersionFromJson(json);

@override final  DateTime at;
@override final  String text;

/// Create a copy of RcxProfileVersion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RcxProfileVersionCopyWith<_RcxProfileVersion> get copyWith => __$RcxProfileVersionCopyWithImpl<_RcxProfileVersion>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RcxProfileVersionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RcxProfileVersion&&(identical(other.at, at) || other.at == at)&&(identical(other.text, text) || other.text == text));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,at,text);
}

@override
String toString() {
    return 'RcxProfileVersion(at: $at, text: $text)';
}


}

/// @nodoc
abstract mixin class _$RcxProfileVersionCopyWith<$Res> implements $RcxProfileVersionCopyWith<$Res> {
  factory _$RcxProfileVersionCopyWith(_RcxProfileVersion value, $Res Function(_RcxProfileVersion) _then) = __$RcxProfileVersionCopyWithImpl;
@override @useResult
$Res call({
 DateTime at, String text
});




}
/// @nodoc
class __$RcxProfileVersionCopyWithImpl<$Res>
    implements _$RcxProfileVersionCopyWith<$Res> {
  __$RcxProfileVersionCopyWithImpl(this._self, this._then);

  final _RcxProfileVersion _self;
  final $Res Function(_RcxProfileVersion) _then;

/// Create a copy of RcxProfileVersion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? at = null,Object? text = null,}) {
  return _then(_RcxProfileVersion(
at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$RcxIssue {

 int get line; String get path; String get code; Map<String, Object?> get args; String get message;
/// Create a copy of RcxIssue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RcxIssueCopyWith<RcxIssue> get copyWith => _$RcxIssueCopyWithImpl<RcxIssue>(this as RcxIssue, _$identity);

  /// Serializes this RcxIssue to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RcxIssue;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RcxIssue&&(identical(other.line, _this.line) || other.line == _this.line)&&(identical(other.path, _this.path) || other.path == _this.path)&&(identical(other.code, _this.code) || other.code == _this.code)&&const DeepCollectionEquality().equals(other.args, _this.args)&&(identical(other.message, _this.message) || other.message == _this.message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RcxIssue;
  return Object.hash(runtimeType,_this.line,_this.path,_this.code,const DeepCollectionEquality().hash(_this.args),_this.message);
}

@override
String toString() {
  final _this = this as RcxIssue;
  return 'RcxIssue(line: ${_this.line}, path: ${_this.path}, code: ${_this.code}, args: ${_this.args}, message: ${_this.message})';
}


}

/// @nodoc
abstract mixin class $RcxIssueCopyWith<$Res>  {
  factory $RcxIssueCopyWith(RcxIssue value, $Res Function(RcxIssue) _then) = _$RcxIssueCopyWithImpl;
@useResult
$Res call({
 int line, String path, String code, Map<String, Object?> args, String message
});




}
/// @nodoc
class _$RcxIssueCopyWithImpl<$Res>
    implements $RcxIssueCopyWith<$Res> {
  _$RcxIssueCopyWithImpl(this._self, this._then);

  final RcxIssue _self;
  final $Res Function(RcxIssue) _then;

/// Create a copy of RcxIssue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? line = null,Object? path = null,Object? code = null,Object? args = null,Object? message = null,}) {
  return _then(RcxIssue(
line: null == line ? _self.line : line // ignore: cast_nullable_to_non_nullable
as int,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,args: null == args ? _self.args : args // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RcxIssue].
extension RcxIssuePatterns on RcxIssue {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RcxIssue value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RcxIssue() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RcxIssue value)  $default,){
final _that = this;
switch (_that) {
case _RcxIssue():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RcxIssue value)?  $default,){
final _that = this;
switch (_that) {
case _RcxIssue() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int line,  String path,  String code,  Map<String, Object?> args,  String message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RcxIssue() when $default != null:
return $default(_that.line,_that.path,_that.code,_that.args,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int line,  String path,  String code,  Map<String, Object?> args,  String message)  $default,) {final _that = this;
switch (_that) {
case _RcxIssue():
return $default(_that.line,_that.path,_that.code,_that.args,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int line,  String path,  String code,  Map<String, Object?> args,  String message)?  $default,) {final _that = this;
switch (_that) {
case _RcxIssue() when $default != null:
return $default(_that.line,_that.path,_that.code,_that.args,_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RcxIssue implements RcxIssue {
  const _RcxIssue({this.line = 0, this.path = '', this.code = '',  Map<String, Object?> args = const {}, this.message = ''}): _args = args;
  factory _RcxIssue.fromJson(Map<String, dynamic> json) => _$RcxIssueFromJson(json);

@override@JsonKey() final  int line;
@override@JsonKey() final  String path;
@override@JsonKey() final  String code;
 final  Map<String, Object?> _args;
@override@JsonKey() Map<String, Object?> get args {
  if (_args is EqualUnmodifiableMapView) return _args;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_args);
}

@override@JsonKey() final  String message;

/// Create a copy of RcxIssue
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RcxIssueCopyWith<_RcxIssue> get copyWith => __$RcxIssueCopyWithImpl<_RcxIssue>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RcxIssueToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RcxIssue&&(identical(other.line, line) || other.line == line)&&(identical(other.path, path) || other.path == path)&&(identical(other.code, code) || other.code == code)&&const DeepCollectionEquality().equals(other.args, _args)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,line,path,code,const DeepCollectionEquality().hash(_args),message);
}

@override
String toString() {
    return 'RcxIssue(line: $line, path: $path, code: $code, args: $args, message: $message)';
}


}

/// @nodoc
abstract mixin class _$RcxIssueCopyWith<$Res> implements $RcxIssueCopyWith<$Res> {
  factory _$RcxIssueCopyWith(_RcxIssue value, $Res Function(_RcxIssue) _then) = __$RcxIssueCopyWithImpl;
@override @useResult
$Res call({
 int line, String path, String code, Map<String, Object?> args, String message
});




}
/// @nodoc
class __$RcxIssueCopyWithImpl<$Res>
    implements _$RcxIssueCopyWith<$Res> {
  __$RcxIssueCopyWithImpl(this._self, this._then);

  final _RcxIssue _self;
  final $Res Function(_RcxIssue) _then;

/// Create a copy of RcxIssue
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? line = null,Object? path = null,Object? code = null,Object? args = null,Object? message = null,}) {
  return _then(_RcxIssue(
line: null == line ? _self.line : line // ignore: cast_nullable_to_non_nullable
as int,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,args: null == args ? _self._args : args // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$RcxEndpoint {

 String get host; String get use; String get target; bool get thirdParty;
/// Create a copy of RcxEndpoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RcxEndpointCopyWith<RcxEndpoint> get copyWith => _$RcxEndpointCopyWithImpl<RcxEndpoint>(this as RcxEndpoint, _$identity);

  /// Serializes this RcxEndpoint to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RcxEndpoint;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RcxEndpoint&&(identical(other.host, _this.host) || other.host == _this.host)&&(identical(other.use, _this.use) || other.use == _this.use)&&(identical(other.target, _this.target) || other.target == _this.target)&&(identical(other.thirdParty, _this.thirdParty) || other.thirdParty == _this.thirdParty));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RcxEndpoint;
  return Object.hash(runtimeType,_this.host,_this.use,_this.target,_this.thirdParty);
}

@override
String toString() {
  final _this = this as RcxEndpoint;
  return 'RcxEndpoint(host: ${_this.host}, use: ${_this.use}, target: ${_this.target}, thirdParty: ${_this.thirdParty})';
}


}

/// @nodoc
abstract mixin class $RcxEndpointCopyWith<$Res>  {
  factory $RcxEndpointCopyWith(RcxEndpoint value, $Res Function(RcxEndpoint) _then) = _$RcxEndpointCopyWithImpl;
@useResult
$Res call({
 String host, String use, String target, bool thirdParty
});




}
/// @nodoc
class _$RcxEndpointCopyWithImpl<$Res>
    implements $RcxEndpointCopyWith<$Res> {
  _$RcxEndpointCopyWithImpl(this._self, this._then);

  final RcxEndpoint _self;
  final $Res Function(RcxEndpoint) _then;

/// Create a copy of RcxEndpoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? host = null,Object? use = null,Object? target = null,Object? thirdParty = null,}) {
  return _then(RcxEndpoint(
host: null == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String,use: null == use ? _self.use : use // ignore: cast_nullable_to_non_nullable
as String,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as String,thirdParty: null == thirdParty ? _self.thirdParty : thirdParty // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [RcxEndpoint].
extension RcxEndpointPatterns on RcxEndpoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RcxEndpoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RcxEndpoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RcxEndpoint value)  $default,){
final _that = this;
switch (_that) {
case _RcxEndpoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RcxEndpoint value)?  $default,){
final _that = this;
switch (_that) {
case _RcxEndpoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String host,  String use,  String target,  bool thirdParty)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RcxEndpoint() when $default != null:
return $default(_that.host,_that.use,_that.target,_that.thirdParty);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String host,  String use,  String target,  bool thirdParty)  $default,) {final _that = this;
switch (_that) {
case _RcxEndpoint():
return $default(_that.host,_that.use,_that.target,_that.thirdParty);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String host,  String use,  String target,  bool thirdParty)?  $default,) {final _that = this;
switch (_that) {
case _RcxEndpoint() when $default != null:
return $default(_that.host,_that.use,_that.target,_that.thirdParty);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RcxEndpoint implements RcxEndpoint {
  const _RcxEndpoint({required this.host, this.use = '', this.target = '', this.thirdParty = false});
  factory _RcxEndpoint.fromJson(Map<String, dynamic> json) => _$RcxEndpointFromJson(json);

@override final  String host;
@override@JsonKey() final  String use;
@override@JsonKey() final  String target;
@override@JsonKey() final  bool thirdParty;

/// Create a copy of RcxEndpoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RcxEndpointCopyWith<_RcxEndpoint> get copyWith => __$RcxEndpointCopyWithImpl<_RcxEndpoint>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RcxEndpointToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RcxEndpoint&&(identical(other.host, host) || other.host == host)&&(identical(other.use, use) || other.use == use)&&(identical(other.target, target) || other.target == target)&&(identical(other.thirdParty, thirdParty) || other.thirdParty == thirdParty));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,host,use,target,thirdParty);
}

@override
String toString() {
    return 'RcxEndpoint(host: $host, use: $use, target: $target, thirdParty: $thirdParty)';
}


}

/// @nodoc
abstract mixin class _$RcxEndpointCopyWith<$Res> implements $RcxEndpointCopyWith<$Res> {
  factory _$RcxEndpointCopyWith(_RcxEndpoint value, $Res Function(_RcxEndpoint) _then) = __$RcxEndpointCopyWithImpl;
@override @useResult
$Res call({
 String host, String use, String target, bool thirdParty
});




}
/// @nodoc
class __$RcxEndpointCopyWithImpl<$Res>
    implements _$RcxEndpointCopyWith<$Res> {
  __$RcxEndpointCopyWithImpl(this._self, this._then);

  final _RcxEndpoint _self;
  final $Res Function(_RcxEndpoint) _then;

/// Create a copy of RcxEndpoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? host = null,Object? use = null,Object? target = null,Object? thirdParty = null,}) {
  return _then(_RcxEndpoint(
host: null == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String,use: null == use ? _self.use : use // ignore: cast_nullable_to_non_nullable
as String,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as String,thirdParty: null == thirdParty ? _self.thirdParty : thirdParty // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$RcxClause {

@JsonKey(name: 'not') bool get negated; String get field; String get op; List<String> get values; bool get ignoreCase;
/// Create a copy of RcxClause
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RcxClauseCopyWith<RcxClause> get copyWith => _$RcxClauseCopyWithImpl<RcxClause>(this as RcxClause, _$identity);

  /// Serializes this RcxClause to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RcxClause;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RcxClause&&(identical(other.negated, _this.negated) || other.negated == _this.negated)&&(identical(other.field, _this.field) || other.field == _this.field)&&(identical(other.op, _this.op) || other.op == _this.op)&&const DeepCollectionEquality().equals(other.values, _this.values)&&(identical(other.ignoreCase, _this.ignoreCase) || other.ignoreCase == _this.ignoreCase));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RcxClause;
  return Object.hash(runtimeType,_this.negated,_this.field,_this.op,const DeepCollectionEquality().hash(_this.values),_this.ignoreCase);
}

@override
String toString() {
  final _this = this as RcxClause;
  return 'RcxClause(negated: ${_this.negated}, field: ${_this.field}, op: ${_this.op}, values: ${_this.values}, ignoreCase: ${_this.ignoreCase})';
}


}

/// @nodoc
abstract mixin class $RcxClauseCopyWith<$Res>  {
  factory $RcxClauseCopyWith(RcxClause value, $Res Function(RcxClause) _then) = _$RcxClauseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'not') bool negated, String field, String op, List<String> values, bool ignoreCase
});




}
/// @nodoc
class _$RcxClauseCopyWithImpl<$Res>
    implements $RcxClauseCopyWith<$Res> {
  _$RcxClauseCopyWithImpl(this._self, this._then);

  final RcxClause _self;
  final $Res Function(RcxClause) _then;

/// Create a copy of RcxClause
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? negated = null,Object? field = null,Object? op = null,Object? values = null,Object? ignoreCase = null,}) {
  return _then(RcxClause(
negated: null == negated ? _self.negated : negated // ignore: cast_nullable_to_non_nullable
as bool,field: null == field ? _self.field : field // ignore: cast_nullable_to_non_nullable
as String,op: null == op ? _self.op : op // ignore: cast_nullable_to_non_nullable
as String,values: null == values ? _self.values : values // ignore: cast_nullable_to_non_nullable
as List<String>,ignoreCase: null == ignoreCase ? _self.ignoreCase : ignoreCase // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [RcxClause].
extension RcxClausePatterns on RcxClause {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RcxClause value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RcxClause() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RcxClause value)  $default,){
final _that = this;
switch (_that) {
case _RcxClause():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RcxClause value)?  $default,){
final _that = this;
switch (_that) {
case _RcxClause() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'not')  bool negated,  String field,  String op,  List<String> values,  bool ignoreCase)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RcxClause() when $default != null:
return $default(_that.negated,_that.field,_that.op,_that.values,_that.ignoreCase);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'not')  bool negated,  String field,  String op,  List<String> values,  bool ignoreCase)  $default,) {final _that = this;
switch (_that) {
case _RcxClause():
return $default(_that.negated,_that.field,_that.op,_that.values,_that.ignoreCase);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'not')  bool negated,  String field,  String op,  List<String> values,  bool ignoreCase)?  $default,) {final _that = this;
switch (_that) {
case _RcxClause() when $default != null:
return $default(_that.negated,_that.field,_that.op,_that.values,_that.ignoreCase);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RcxClause implements RcxClause {
  const _RcxClause({@JsonKey(name: 'not') this.negated = false, required this.field, this.op = '',  List<String> values = const [], this.ignoreCase = false}): _values = values;
  factory _RcxClause.fromJson(Map<String, dynamic> json) => _$RcxClauseFromJson(json);

@override@JsonKey(name: 'not') final  bool negated;
@override final  String field;
@override@JsonKey() final  String op;
 final  List<String> _values;
@override@JsonKey() List<String> get values {
  if (_values is EqualUnmodifiableListView) return _values;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_values);
}

@override@JsonKey() final  bool ignoreCase;

/// Create a copy of RcxClause
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RcxClauseCopyWith<_RcxClause> get copyWith => __$RcxClauseCopyWithImpl<_RcxClause>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RcxClauseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RcxClause&&(identical(other.negated, negated) || other.negated == negated)&&(identical(other.field, field) || other.field == field)&&(identical(other.op, op) || other.op == op)&&const DeepCollectionEquality().equals(other.values, _values)&&(identical(other.ignoreCase, ignoreCase) || other.ignoreCase == ignoreCase));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,negated,field,op,const DeepCollectionEquality().hash(_values),ignoreCase);
}

@override
String toString() {
    return 'RcxClause(negated: $negated, field: $field, op: $op, values: $values, ignoreCase: $ignoreCase)';
}


}

/// @nodoc
abstract mixin class _$RcxClauseCopyWith<$Res> implements $RcxClauseCopyWith<$Res> {
  factory _$RcxClauseCopyWith(_RcxClause value, $Res Function(_RcxClause) _then) = __$RcxClauseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'not') bool negated, String field, String op, List<String> values, bool ignoreCase
});




}
/// @nodoc
class __$RcxClauseCopyWithImpl<$Res>
    implements _$RcxClauseCopyWith<$Res> {
  __$RcxClauseCopyWithImpl(this._self, this._then);

  final _RcxClause _self;
  final $Res Function(_RcxClause) _then;

/// Create a copy of RcxClause
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? negated = null,Object? field = null,Object? op = null,Object? values = null,Object? ignoreCase = null,}) {
  return _then(_RcxClause(
negated: null == negated ? _self.negated : negated // ignore: cast_nullable_to_non_nullable
as bool,field: null == field ? _self.field : field // ignore: cast_nullable_to_non_nullable
as String,op: null == op ? _self.op : op // ignore: cast_nullable_to_non_nullable
as String,values: null == values ? _self._values : values // ignore: cast_nullable_to_non_nullable
as List<String>,ignoreCase: null == ignoreCase ? _self.ignoreCase : ignoreCase // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$RcxCondForm {

 String get join; List<RcxClause> get clauses; bool get flat; String get error;
/// Create a copy of RcxCondForm
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RcxCondFormCopyWith<RcxCondForm> get copyWith => _$RcxCondFormCopyWithImpl<RcxCondForm>(this as RcxCondForm, _$identity);

  /// Serializes this RcxCondForm to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RcxCondForm;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RcxCondForm&&(identical(other.join, _this.join) || other.join == _this.join)&&const DeepCollectionEquality().equals(other.clauses, _this.clauses)&&(identical(other.flat, _this.flat) || other.flat == _this.flat)&&(identical(other.error, _this.error) || other.error == _this.error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RcxCondForm;
  return Object.hash(runtimeType,_this.join,const DeepCollectionEquality().hash(_this.clauses),_this.flat,_this.error);
}

@override
String toString() {
  final _this = this as RcxCondForm;
  return 'RcxCondForm(join: ${_this.join}, clauses: ${_this.clauses}, flat: ${_this.flat}, error: ${_this.error})';
}


}

/// @nodoc
abstract mixin class $RcxCondFormCopyWith<$Res>  {
  factory $RcxCondFormCopyWith(RcxCondForm value, $Res Function(RcxCondForm) _then) = _$RcxCondFormCopyWithImpl;
@useResult
$Res call({
 String join, List<RcxClause> clauses, bool flat, String error
});




}
/// @nodoc
class _$RcxCondFormCopyWithImpl<$Res>
    implements $RcxCondFormCopyWith<$Res> {
  _$RcxCondFormCopyWithImpl(this._self, this._then);

  final RcxCondForm _self;
  final $Res Function(RcxCondForm) _then;

/// Create a copy of RcxCondForm
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? join = null,Object? clauses = null,Object? flat = null,Object? error = null,}) {
  return _then(RcxCondForm(
join: null == join ? _self.join : join // ignore: cast_nullable_to_non_nullable
as String,clauses: null == clauses ? _self.clauses : clauses // ignore: cast_nullable_to_non_nullable
as List<RcxClause>,flat: null == flat ? _self.flat : flat // ignore: cast_nullable_to_non_nullable
as bool,error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RcxCondForm].
extension RcxCondFormPatterns on RcxCondForm {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RcxCondForm value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RcxCondForm() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RcxCondForm value)  $default,){
final _that = this;
switch (_that) {
case _RcxCondForm():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RcxCondForm value)?  $default,){
final _that = this;
switch (_that) {
case _RcxCondForm() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String join,  List<RcxClause> clauses,  bool flat,  String error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RcxCondForm() when $default != null:
return $default(_that.join,_that.clauses,_that.flat,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String join,  List<RcxClause> clauses,  bool flat,  String error)  $default,) {final _that = this;
switch (_that) {
case _RcxCondForm():
return $default(_that.join,_that.clauses,_that.flat,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String join,  List<RcxClause> clauses,  bool flat,  String error)?  $default,) {final _that = this;
switch (_that) {
case _RcxCondForm() when $default != null:
return $default(_that.join,_that.clauses,_that.flat,_that.error);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RcxCondForm implements RcxCondForm {
  const _RcxCondForm({this.join = 'and',  List<RcxClause> clauses = const [], this.flat = false, this.error = ''}): _clauses = clauses;
  factory _RcxCondForm.fromJson(Map<String, dynamic> json) => _$RcxCondFormFromJson(json);

@override@JsonKey() final  String join;
 final  List<RcxClause> _clauses;
@override@JsonKey() List<RcxClause> get clauses {
  if (_clauses is EqualUnmodifiableListView) return _clauses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_clauses);
}

@override@JsonKey() final  bool flat;
@override@JsonKey() final  String error;

/// Create a copy of RcxCondForm
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RcxCondFormCopyWith<_RcxCondForm> get copyWith => __$RcxCondFormCopyWithImpl<_RcxCondForm>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RcxCondFormToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RcxCondForm&&(identical(other.join, join) || other.join == join)&&const DeepCollectionEquality().equals(other.clauses, _clauses)&&(identical(other.flat, flat) || other.flat == flat)&&(identical(other.error, error) || other.error == error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,join,const DeepCollectionEquality().hash(_clauses),flat,error);
}

@override
String toString() {
    return 'RcxCondForm(join: $join, clauses: $clauses, flat: $flat, error: $error)';
}


}

/// @nodoc
abstract mixin class _$RcxCondFormCopyWith<$Res> implements $RcxCondFormCopyWith<$Res> {
  factory _$RcxCondFormCopyWith(_RcxCondForm value, $Res Function(_RcxCondForm) _then) = __$RcxCondFormCopyWithImpl;
@override @useResult
$Res call({
 String join, List<RcxClause> clauses, bool flat, String error
});




}
/// @nodoc
class __$RcxCondFormCopyWithImpl<$Res>
    implements _$RcxCondFormCopyWith<$Res> {
  __$RcxCondFormCopyWithImpl(this._self, this._then);

  final _RcxCondForm _self;
  final $Res Function(_RcxCondForm) _then;

/// Create a copy of RcxCondForm
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? join = null,Object? clauses = null,Object? flat = null,Object? error = null,}) {
  return _then(_RcxCondForm(
join: null == join ? _self.join : join // ignore: cast_nullable_to_non_nullable
as String,clauses: null == clauses ? _self._clauses : clauses // ignore: cast_nullable_to_non_nullable
as List<RcxClause>,flat: null == flat ? _self.flat : flat // ignore: cast_nullable_to_non_nullable
as bool,error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$RcxField {

 String get name; String get kind; bool get network; List<String> get ops; List<String> get values;
/// Create a copy of RcxField
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RcxFieldCopyWith<RcxField> get copyWith => _$RcxFieldCopyWithImpl<RcxField>(this as RcxField, _$identity);

  /// Serializes this RcxField to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RcxField;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RcxField&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.network, _this.network) || other.network == _this.network)&&const DeepCollectionEquality().equals(other.ops, _this.ops)&&const DeepCollectionEquality().equals(other.values, _this.values));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RcxField;
  return Object.hash(runtimeType,_this.name,_this.kind,_this.network,const DeepCollectionEquality().hash(_this.ops),const DeepCollectionEquality().hash(_this.values));
}

@override
String toString() {
  final _this = this as RcxField;
  return 'RcxField(name: ${_this.name}, kind: ${_this.kind}, network: ${_this.network}, ops: ${_this.ops}, values: ${_this.values})';
}


}

/// @nodoc
abstract mixin class $RcxFieldCopyWith<$Res>  {
  factory $RcxFieldCopyWith(RcxField value, $Res Function(RcxField) _then) = _$RcxFieldCopyWithImpl;
@useResult
$Res call({
 String name, String kind, bool network, List<String> ops, List<String> values
});




}
/// @nodoc
class _$RcxFieldCopyWithImpl<$Res>
    implements $RcxFieldCopyWith<$Res> {
  _$RcxFieldCopyWithImpl(this._self, this._then);

  final RcxField _self;
  final $Res Function(RcxField) _then;

/// Create a copy of RcxField
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? kind = null,Object? network = null,Object? ops = null,Object? values = null,}) {
  return _then(RcxField(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,network: null == network ? _self.network : network // ignore: cast_nullable_to_non_nullable
as bool,ops: null == ops ? _self.ops : ops // ignore: cast_nullable_to_non_nullable
as List<String>,values: null == values ? _self.values : values // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [RcxField].
extension RcxFieldPatterns on RcxField {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RcxField value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RcxField() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RcxField value)  $default,){
final _that = this;
switch (_that) {
case _RcxField():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RcxField value)?  $default,){
final _that = this;
switch (_that) {
case _RcxField() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String kind,  bool network,  List<String> ops,  List<String> values)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RcxField() when $default != null:
return $default(_that.name,_that.kind,_that.network,_that.ops,_that.values);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String kind,  bool network,  List<String> ops,  List<String> values)  $default,) {final _that = this;
switch (_that) {
case _RcxField():
return $default(_that.name,_that.kind,_that.network,_that.ops,_that.values);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String kind,  bool network,  List<String> ops,  List<String> values)?  $default,) {final _that = this;
switch (_that) {
case _RcxField() when $default != null:
return $default(_that.name,_that.kind,_that.network,_that.ops,_that.values);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RcxField implements RcxField {
  const _RcxField({required this.name, required this.kind, this.network = false,  List<String> ops = const [],  List<String> values = const []}): _ops = ops,_values = values;
  factory _RcxField.fromJson(Map<String, dynamic> json) => _$RcxFieldFromJson(json);

@override final  String name;
@override final  String kind;
@override@JsonKey() final  bool network;
 final  List<String> _ops;
@override@JsonKey() List<String> get ops {
  if (_ops is EqualUnmodifiableListView) return _ops;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ops);
}

 final  List<String> _values;
@override@JsonKey() List<String> get values {
  if (_values is EqualUnmodifiableListView) return _values;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_values);
}


/// Create a copy of RcxField
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RcxFieldCopyWith<_RcxField> get copyWith => __$RcxFieldCopyWithImpl<_RcxField>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RcxFieldToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RcxField&&(identical(other.name, name) || other.name == name)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.network, network) || other.network == network)&&const DeepCollectionEquality().equals(other.ops, _ops)&&const DeepCollectionEquality().equals(other.values, _values));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,kind,network,const DeepCollectionEquality().hash(_ops),const DeepCollectionEquality().hash(_values));
}

@override
String toString() {
    return 'RcxField(name: $name, kind: $kind, network: $network, ops: $ops, values: $values)';
}


}

/// @nodoc
abstract mixin class _$RcxFieldCopyWith<$Res> implements $RcxFieldCopyWith<$Res> {
  factory _$RcxFieldCopyWith(_RcxField value, $Res Function(_RcxField) _then) = __$RcxFieldCopyWithImpl;
@override @useResult
$Res call({
 String name, String kind, bool network, List<String> ops, List<String> values
});




}
/// @nodoc
class __$RcxFieldCopyWithImpl<$Res>
    implements _$RcxFieldCopyWith<$Res> {
  __$RcxFieldCopyWithImpl(this._self, this._then);

  final _RcxField _self;
  final $Res Function(_RcxField) _then;

/// Create a copy of RcxField
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? kind = null,Object? network = null,Object? ops = null,Object? values = null,}) {
  return _then(_RcxField(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,network: null == network ? _self.network : network // ignore: cast_nullable_to_non_nullable
as bool,ops: null == ops ? _self._ops : ops // ignore: cast_nullable_to_non_nullable
as List<String>,values: null == values ? _self._values : values // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$RcxStudioResult {

 String get text; Map<String, Object?>? get profile; Map<String, Object?>? get scenario; RcxProfileInfo? get info; List<RcxIssue> get errors; List<RcxIssue> get warnings; List<RcxEndpoint> get endpoints; RcxCondForm? get form; List<RcxField> get fields; List<String> get conflicts; RcxDecision? get current; RcxDecision? get candidate;
/// Create a copy of RcxStudioResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RcxStudioResultCopyWith<RcxStudioResult> get copyWith => _$RcxStudioResultCopyWithImpl<RcxStudioResult>(this as RcxStudioResult, _$identity);

  /// Serializes this RcxStudioResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RcxStudioResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RcxStudioResult&&(identical(other.text, _this.text) || other.text == _this.text)&&const DeepCollectionEquality().equals(other.profile, _this.profile)&&const DeepCollectionEquality().equals(other.scenario, _this.scenario)&&(identical(other.info, _this.info) || other.info == _this.info)&&const DeepCollectionEquality().equals(other.errors, _this.errors)&&const DeepCollectionEquality().equals(other.warnings, _this.warnings)&&const DeepCollectionEquality().equals(other.endpoints, _this.endpoints)&&(identical(other.form, _this.form) || other.form == _this.form)&&const DeepCollectionEquality().equals(other.fields, _this.fields)&&const DeepCollectionEquality().equals(other.conflicts, _this.conflicts)&&(identical(other.current, _this.current) || other.current == _this.current)&&(identical(other.candidate, _this.candidate) || other.candidate == _this.candidate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RcxStudioResult;
  return Object.hash(runtimeType,_this.text,const DeepCollectionEquality().hash(_this.profile),const DeepCollectionEquality().hash(_this.scenario),_this.info,const DeepCollectionEquality().hash(_this.errors),const DeepCollectionEquality().hash(_this.warnings),const DeepCollectionEquality().hash(_this.endpoints),_this.form,const DeepCollectionEquality().hash(_this.fields),const DeepCollectionEquality().hash(_this.conflicts),_this.current,_this.candidate);
}

@override
String toString() {
  final _this = this as RcxStudioResult;
  return 'RcxStudioResult(text: ${_this.text}, profile: ${_this.profile}, scenario: ${_this.scenario}, info: ${_this.info}, errors: ${_this.errors}, warnings: ${_this.warnings}, endpoints: ${_this.endpoints}, form: ${_this.form}, fields: ${_this.fields}, conflicts: ${_this.conflicts}, current: ${_this.current}, candidate: ${_this.candidate})';
}


}

/// @nodoc
abstract mixin class $RcxStudioResultCopyWith<$Res>  {
  factory $RcxStudioResultCopyWith(RcxStudioResult value, $Res Function(RcxStudioResult) _then) = _$RcxStudioResultCopyWithImpl;
@useResult
$Res call({
 String text, Map<String, Object?>? profile, Map<String, Object?>? scenario, RcxProfileInfo? info, List<RcxIssue> errors, List<RcxIssue> warnings, List<RcxEndpoint> endpoints, RcxCondForm? form, List<RcxField> fields, List<String> conflicts, RcxDecision? current, RcxDecision? candidate
});


$RcxProfileInfoCopyWith<$Res>? get info;$RcxCondFormCopyWith<$Res>? get form;$RcxDecisionCopyWith<$Res>? get current;$RcxDecisionCopyWith<$Res>? get candidate;

}
/// @nodoc
class _$RcxStudioResultCopyWithImpl<$Res>
    implements $RcxStudioResultCopyWith<$Res> {
  _$RcxStudioResultCopyWithImpl(this._self, this._then);

  final RcxStudioResult _self;
  final $Res Function(RcxStudioResult) _then;

/// Create a copy of RcxStudioResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = null,Object? profile = freezed,Object? scenario = freezed,Object? info = freezed,Object? errors = null,Object? warnings = null,Object? endpoints = null,Object? form = freezed,Object? fields = null,Object? conflicts = null,Object? current = freezed,Object? candidate = freezed,}) {
  return _then(RcxStudioResult(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>?,scenario: freezed == scenario ? _self.scenario : scenario // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>?,info: freezed == info ? _self.info : info // ignore: cast_nullable_to_non_nullable
as RcxProfileInfo?,errors: null == errors ? _self.errors : errors // ignore: cast_nullable_to_non_nullable
as List<RcxIssue>,warnings: null == warnings ? _self.warnings : warnings // ignore: cast_nullable_to_non_nullable
as List<RcxIssue>,endpoints: null == endpoints ? _self.endpoints : endpoints // ignore: cast_nullable_to_non_nullable
as List<RcxEndpoint>,form: freezed == form ? _self.form : form // ignore: cast_nullable_to_non_nullable
as RcxCondForm?,fields: null == fields ? _self.fields : fields // ignore: cast_nullable_to_non_nullable
as List<RcxField>,conflicts: null == conflicts ? _self.conflicts : conflicts // ignore: cast_nullable_to_non_nullable
as List<String>,current: freezed == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as RcxDecision?,candidate: freezed == candidate ? _self.candidate : candidate // ignore: cast_nullable_to_non_nullable
as RcxDecision?,
  ));
}
/// Create a copy of RcxStudioResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RcxProfileInfoCopyWith<$Res>? get info {
    if (_self.info == null) {
    return null;
  }

  return $RcxProfileInfoCopyWith<$Res>(_self.info!, (value) {
    return _then(_self.copyWith(info: value));
  });
}/// Create a copy of RcxStudioResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RcxCondFormCopyWith<$Res>? get form {
    if (_self.form == null) {
    return null;
  }

  return $RcxCondFormCopyWith<$Res>(_self.form!, (value) {
    return _then(_self.copyWith(form: value));
  });
}/// Create a copy of RcxStudioResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RcxDecisionCopyWith<$Res>? get current {
    if (_self.current == null) {
    return null;
  }

  return $RcxDecisionCopyWith<$Res>(_self.current!, (value) {
    return _then(_self.copyWith(current: value));
  });
}/// Create a copy of RcxStudioResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RcxDecisionCopyWith<$Res>? get candidate {
    if (_self.candidate == null) {
    return null;
  }

  return $RcxDecisionCopyWith<$Res>(_self.candidate!, (value) {
    return _then(_self.copyWith(candidate: value));
  });
}
}


/// Adds pattern-matching-related methods to [RcxStudioResult].
extension RcxStudioResultPatterns on RcxStudioResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RcxStudioResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RcxStudioResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RcxStudioResult value)  $default,){
final _that = this;
switch (_that) {
case _RcxStudioResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RcxStudioResult value)?  $default,){
final _that = this;
switch (_that) {
case _RcxStudioResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String text,  Map<String, Object?>? profile,  Map<String, Object?>? scenario,  RcxProfileInfo? info,  List<RcxIssue> errors,  List<RcxIssue> warnings,  List<RcxEndpoint> endpoints,  RcxCondForm? form,  List<RcxField> fields,  List<String> conflicts,  RcxDecision? current,  RcxDecision? candidate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RcxStudioResult() when $default != null:
return $default(_that.text,_that.profile,_that.scenario,_that.info,_that.errors,_that.warnings,_that.endpoints,_that.form,_that.fields,_that.conflicts,_that.current,_that.candidate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String text,  Map<String, Object?>? profile,  Map<String, Object?>? scenario,  RcxProfileInfo? info,  List<RcxIssue> errors,  List<RcxIssue> warnings,  List<RcxEndpoint> endpoints,  RcxCondForm? form,  List<RcxField> fields,  List<String> conflicts,  RcxDecision? current,  RcxDecision? candidate)  $default,) {final _that = this;
switch (_that) {
case _RcxStudioResult():
return $default(_that.text,_that.profile,_that.scenario,_that.info,_that.errors,_that.warnings,_that.endpoints,_that.form,_that.fields,_that.conflicts,_that.current,_that.candidate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String text,  Map<String, Object?>? profile,  Map<String, Object?>? scenario,  RcxProfileInfo? info,  List<RcxIssue> errors,  List<RcxIssue> warnings,  List<RcxEndpoint> endpoints,  RcxCondForm? form,  List<RcxField> fields,  List<String> conflicts,  RcxDecision? current,  RcxDecision? candidate)?  $default,) {final _that = this;
switch (_that) {
case _RcxStudioResult() when $default != null:
return $default(_that.text,_that.profile,_that.scenario,_that.info,_that.errors,_that.warnings,_that.endpoints,_that.form,_that.fields,_that.conflicts,_that.current,_that.candidate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RcxStudioResult implements RcxStudioResult {
  const _RcxStudioResult({this.text = '',  Map<String, Object?>? profile,  Map<String, Object?>? scenario, this.info,  List<RcxIssue> errors = const [],  List<RcxIssue> warnings = const [],  List<RcxEndpoint> endpoints = const [], this.form,  List<RcxField> fields = const [],  List<String> conflicts = const [], this.current, this.candidate}): _profile = profile,_scenario = scenario,_errors = errors,_warnings = warnings,_endpoints = endpoints,_fields = fields,_conflicts = conflicts;
  factory _RcxStudioResult.fromJson(Map<String, dynamic> json) => _$RcxStudioResultFromJson(json);

@override@JsonKey() final  String text;
 final  Map<String, Object?>? _profile;
@override Map<String, Object?>? get profile {
  final value = _profile;
  if (value == null) return null;
  if (_profile is EqualUnmodifiableMapView) return _profile;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, Object?>? _scenario;
@override Map<String, Object?>? get scenario {
  final value = _scenario;
  if (value == null) return null;
  if (_scenario is EqualUnmodifiableMapView) return _scenario;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  RcxProfileInfo? info;
 final  List<RcxIssue> _errors;
@override@JsonKey() List<RcxIssue> get errors {
  if (_errors is EqualUnmodifiableListView) return _errors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_errors);
}

 final  List<RcxIssue> _warnings;
@override@JsonKey() List<RcxIssue> get warnings {
  if (_warnings is EqualUnmodifiableListView) return _warnings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_warnings);
}

 final  List<RcxEndpoint> _endpoints;
@override@JsonKey() List<RcxEndpoint> get endpoints {
  if (_endpoints is EqualUnmodifiableListView) return _endpoints;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_endpoints);
}

@override final  RcxCondForm? form;
 final  List<RcxField> _fields;
@override@JsonKey() List<RcxField> get fields {
  if (_fields is EqualUnmodifiableListView) return _fields;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_fields);
}

 final  List<String> _conflicts;
@override@JsonKey() List<String> get conflicts {
  if (_conflicts is EqualUnmodifiableListView) return _conflicts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_conflicts);
}

@override final  RcxDecision? current;
@override final  RcxDecision? candidate;

/// Create a copy of RcxStudioResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RcxStudioResultCopyWith<_RcxStudioResult> get copyWith => __$RcxStudioResultCopyWithImpl<_RcxStudioResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RcxStudioResultToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RcxStudioResult&&(identical(other.text, text) || other.text == text)&&const DeepCollectionEquality().equals(other.profile, _profile)&&const DeepCollectionEquality().equals(other.scenario, _scenario)&&(identical(other.info, info) || other.info == info)&&const DeepCollectionEquality().equals(other.errors, _errors)&&const DeepCollectionEquality().equals(other.warnings, _warnings)&&const DeepCollectionEquality().equals(other.endpoints, _endpoints)&&(identical(other.form, form) || other.form == form)&&const DeepCollectionEquality().equals(other.fields, _fields)&&const DeepCollectionEquality().equals(other.conflicts, _conflicts)&&(identical(other.current, current) || other.current == current)&&(identical(other.candidate, candidate) || other.candidate == candidate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,text,const DeepCollectionEquality().hash(_profile),const DeepCollectionEquality().hash(_scenario),info,const DeepCollectionEquality().hash(_errors),const DeepCollectionEquality().hash(_warnings),const DeepCollectionEquality().hash(_endpoints),form,const DeepCollectionEquality().hash(_fields),const DeepCollectionEquality().hash(_conflicts),current,candidate);
}

@override
String toString() {
    return 'RcxStudioResult(text: $text, profile: $profile, scenario: $scenario, info: $info, errors: $errors, warnings: $warnings, endpoints: $endpoints, form: $form, fields: $fields, conflicts: $conflicts, current: $current, candidate: $candidate)';
}


}

/// @nodoc
abstract mixin class _$RcxStudioResultCopyWith<$Res> implements $RcxStudioResultCopyWith<$Res> {
  factory _$RcxStudioResultCopyWith(_RcxStudioResult value, $Res Function(_RcxStudioResult) _then) = __$RcxStudioResultCopyWithImpl;
@override @useResult
$Res call({
 String text, Map<String, Object?>? profile, Map<String, Object?>? scenario, RcxProfileInfo? info, List<RcxIssue> errors, List<RcxIssue> warnings, List<RcxEndpoint> endpoints, RcxCondForm? form, List<RcxField> fields, List<String> conflicts, RcxDecision? current, RcxDecision? candidate
});


@override $RcxProfileInfoCopyWith<$Res>? get info;@override $RcxCondFormCopyWith<$Res>? get form;@override $RcxDecisionCopyWith<$Res>? get current;@override $RcxDecisionCopyWith<$Res>? get candidate;

}
/// @nodoc
class __$RcxStudioResultCopyWithImpl<$Res>
    implements _$RcxStudioResultCopyWith<$Res> {
  __$RcxStudioResultCopyWithImpl(this._self, this._then);

  final _RcxStudioResult _self;
  final $Res Function(_RcxStudioResult) _then;

/// Create a copy of RcxStudioResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,Object? profile = freezed,Object? scenario = freezed,Object? info = freezed,Object? errors = null,Object? warnings = null,Object? endpoints = null,Object? form = freezed,Object? fields = null,Object? conflicts = null,Object? current = freezed,Object? candidate = freezed,}) {
  return _then(_RcxStudioResult(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,profile: freezed == profile ? _self._profile : profile // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>?,scenario: freezed == scenario ? _self._scenario : scenario // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>?,info: freezed == info ? _self.info : info // ignore: cast_nullable_to_non_nullable
as RcxProfileInfo?,errors: null == errors ? _self._errors : errors // ignore: cast_nullable_to_non_nullable
as List<RcxIssue>,warnings: null == warnings ? _self._warnings : warnings // ignore: cast_nullable_to_non_nullable
as List<RcxIssue>,endpoints: null == endpoints ? _self._endpoints : endpoints // ignore: cast_nullable_to_non_nullable
as List<RcxEndpoint>,form: freezed == form ? _self.form : form // ignore: cast_nullable_to_non_nullable
as RcxCondForm?,fields: null == fields ? _self._fields : fields // ignore: cast_nullable_to_non_nullable
as List<RcxField>,conflicts: null == conflicts ? _self._conflicts : conflicts // ignore: cast_nullable_to_non_nullable
as List<String>,current: freezed == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as RcxDecision?,candidate: freezed == candidate ? _self.candidate : candidate // ignore: cast_nullable_to_non_nullable
as RcxDecision?,
  ));
}

/// Create a copy of RcxStudioResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RcxProfileInfoCopyWith<$Res>? get info {
    if (_self.info == null) {
    return null;
  }

  return $RcxProfileInfoCopyWith<$Res>(_self.info!, (value) {
    return _then(_self.copyWith(info: value));
  });
}/// Create a copy of RcxStudioResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RcxCondFormCopyWith<$Res>? get form {
    if (_self.form == null) {
    return null;
  }

  return $RcxCondFormCopyWith<$Res>(_self.form!, (value) {
    return _then(_self.copyWith(form: value));
  });
}/// Create a copy of RcxStudioResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RcxDecisionCopyWith<$Res>? get current {
    if (_self.current == null) {
    return null;
  }

  return $RcxDecisionCopyWith<$Res>(_self.current!, (value) {
    return _then(_self.copyWith(current: value));
  });
}/// Create a copy of RcxStudioResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RcxDecisionCopyWith<$Res>? get candidate {
    if (_self.candidate == null) {
    return null;
  }

  return $RcxDecisionCopyWith<$Res>(_self.candidate!, (value) {
    return _then(_self.copyWith(candidate: value));
  });
}
}

// dart format on
