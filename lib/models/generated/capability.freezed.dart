// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../capability.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CapabilitySelector {

 String? get provider;@JsonKey(name: 'name_contains') String? get nameContains;
/// Create a copy of CapabilitySelector
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CapabilitySelectorCopyWith<CapabilitySelector> get copyWith => _$CapabilitySelectorCopyWithImpl<CapabilitySelector>(this as CapabilitySelector, _$identity);

  /// Serializes this CapabilitySelector to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CapabilitySelector;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CapabilitySelector&&(identical(other.provider, _this.provider) || other.provider == _this.provider)&&(identical(other.nameContains, _this.nameContains) || other.nameContains == _this.nameContains));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CapabilitySelector;
  return Object.hash(runtimeType,_this.provider,_this.nameContains);
}

@override
String toString() {
  final _this = this as CapabilitySelector;
  return 'CapabilitySelector(provider: ${_this.provider}, nameContains: ${_this.nameContains})';
}


}

/// @nodoc
abstract mixin class $CapabilitySelectorCopyWith<$Res>  {
  factory $CapabilitySelectorCopyWith(CapabilitySelector value, $Res Function(CapabilitySelector) _then) = _$CapabilitySelectorCopyWithImpl;
@useResult
$Res call({
 String? provider,@JsonKey(name: 'name_contains') String? nameContains
});




}
/// @nodoc
class _$CapabilitySelectorCopyWithImpl<$Res>
    implements $CapabilitySelectorCopyWith<$Res> {
  _$CapabilitySelectorCopyWithImpl(this._self, this._then);

  final CapabilitySelector _self;
  final $Res Function(CapabilitySelector) _then;

/// Create a copy of CapabilitySelector
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? provider = freezed,Object? nameContains = freezed,}) {
  return _then(CapabilitySelector(
provider: freezed == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String?,nameContains: freezed == nameContains ? _self.nameContains : nameContains // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CapabilitySelector].
extension CapabilitySelectorPatterns on CapabilitySelector {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CapabilitySelector value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CapabilitySelector() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CapabilitySelector value)  $default,){
final _that = this;
switch (_that) {
case _CapabilitySelector():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CapabilitySelector value)?  $default,){
final _that = this;
switch (_that) {
case _CapabilitySelector() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? provider, @JsonKey(name: 'name_contains')  String? nameContains)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CapabilitySelector() when $default != null:
return $default(_that.provider,_that.nameContains);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? provider, @JsonKey(name: 'name_contains')  String? nameContains)  $default,) {final _that = this;
switch (_that) {
case _CapabilitySelector():
return $default(_that.provider,_that.nameContains);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? provider, @JsonKey(name: 'name_contains')  String? nameContains)?  $default,) {final _that = this;
switch (_that) {
case _CapabilitySelector() when $default != null:
return $default(_that.provider,_that.nameContains);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CapabilitySelector implements CapabilitySelector {
  const _CapabilitySelector({this.provider, @JsonKey(name: 'name_contains') this.nameContains});
  factory _CapabilitySelector.fromJson(Map<String, dynamic> json) => _$CapabilitySelectorFromJson(json);

@override final  String? provider;
@override@JsonKey(name: 'name_contains') final  String? nameContains;

/// Create a copy of CapabilitySelector
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CapabilitySelectorCopyWith<_CapabilitySelector> get copyWith => __$CapabilitySelectorCopyWithImpl<_CapabilitySelector>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CapabilitySelectorToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CapabilitySelector&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.nameContains, nameContains) || other.nameContains == nameContains));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,provider,nameContains);
}

@override
String toString() {
    return 'CapabilitySelector(provider: $provider, nameContains: $nameContains)';
}


}

/// @nodoc
abstract mixin class _$CapabilitySelectorCopyWith<$Res> implements $CapabilitySelectorCopyWith<$Res> {
  factory _$CapabilitySelectorCopyWith(_CapabilitySelector value, $Res Function(_CapabilitySelector) _then) = __$CapabilitySelectorCopyWithImpl;
@override @useResult
$Res call({
 String? provider,@JsonKey(name: 'name_contains') String? nameContains
});




}
/// @nodoc
class __$CapabilitySelectorCopyWithImpl<$Res>
    implements _$CapabilitySelectorCopyWith<$Res> {
  __$CapabilitySelectorCopyWithImpl(this._self, this._then);

  final _CapabilitySelector _self;
  final $Res Function(_CapabilitySelector) _then;

/// Create a copy of CapabilitySelector
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? provider = freezed,Object? nameContains = freezed,}) {
  return _then(_CapabilitySelector(
provider: freezed == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String?,nameContains: freezed == nameContains ? _self.nameContains : nameContains // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CapabilityClaim {

@JsonKey(name: 'cap') String get capabilityId; List<CapabilitySelector> get selectors;
/// Create a copy of CapabilityClaim
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CapabilityClaimCopyWith<CapabilityClaim> get copyWith => _$CapabilityClaimCopyWithImpl<CapabilityClaim>(this as CapabilityClaim, _$identity);

  /// Serializes this CapabilityClaim to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CapabilityClaim;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CapabilityClaim&&(identical(other.capabilityId, _this.capabilityId) || other.capabilityId == _this.capabilityId)&&const DeepCollectionEquality().equals(other.selectors, _this.selectors));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CapabilityClaim;
  return Object.hash(runtimeType,_this.capabilityId,const DeepCollectionEquality().hash(_this.selectors));
}

@override
String toString() {
  final _this = this as CapabilityClaim;
  return 'CapabilityClaim(capabilityId: ${_this.capabilityId}, selectors: ${_this.selectors})';
}


}

/// @nodoc
abstract mixin class $CapabilityClaimCopyWith<$Res>  {
  factory $CapabilityClaimCopyWith(CapabilityClaim value, $Res Function(CapabilityClaim) _then) = _$CapabilityClaimCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'cap') String capabilityId, List<CapabilitySelector> selectors
});




}
/// @nodoc
class _$CapabilityClaimCopyWithImpl<$Res>
    implements $CapabilityClaimCopyWith<$Res> {
  _$CapabilityClaimCopyWithImpl(this._self, this._then);

  final CapabilityClaim _self;
  final $Res Function(CapabilityClaim) _then;

/// Create a copy of CapabilityClaim
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? capabilityId = null,Object? selectors = null,}) {
  return _then(CapabilityClaim(
capabilityId: null == capabilityId ? _self.capabilityId : capabilityId // ignore: cast_nullable_to_non_nullable
as String,selectors: null == selectors ? _self.selectors : selectors // ignore: cast_nullable_to_non_nullable
as List<CapabilitySelector>,
  ));
}

}


/// Adds pattern-matching-related methods to [CapabilityClaim].
extension CapabilityClaimPatterns on CapabilityClaim {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CapabilityClaim value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CapabilityClaim() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CapabilityClaim value)  $default,){
final _that = this;
switch (_that) {
case _CapabilityClaim():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CapabilityClaim value)?  $default,){
final _that = this;
switch (_that) {
case _CapabilityClaim() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'cap')  String capabilityId,  List<CapabilitySelector> selectors)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CapabilityClaim() when $default != null:
return $default(_that.capabilityId,_that.selectors);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'cap')  String capabilityId,  List<CapabilitySelector> selectors)  $default,) {final _that = this;
switch (_that) {
case _CapabilityClaim():
return $default(_that.capabilityId,_that.selectors);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'cap')  String capabilityId,  List<CapabilitySelector> selectors)?  $default,) {final _that = this;
switch (_that) {
case _CapabilityClaim() when $default != null:
return $default(_that.capabilityId,_that.selectors);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CapabilityClaim implements CapabilityClaim {
  const _CapabilityClaim({@JsonKey(name: 'cap') required this.capabilityId, required  List<CapabilitySelector> selectors}): _selectors = selectors;
  factory _CapabilityClaim.fromJson(Map<String, dynamic> json) => _$CapabilityClaimFromJson(json);

@override@JsonKey(name: 'cap') final  String capabilityId;
 final  List<CapabilitySelector> _selectors;
@override List<CapabilitySelector> get selectors {
  if (_selectors is EqualUnmodifiableListView) return _selectors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selectors);
}


/// Create a copy of CapabilityClaim
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CapabilityClaimCopyWith<_CapabilityClaim> get copyWith => __$CapabilityClaimCopyWithImpl<_CapabilityClaim>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CapabilityClaimToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CapabilityClaim&&(identical(other.capabilityId, capabilityId) || other.capabilityId == capabilityId)&&const DeepCollectionEquality().equals(other.selectors, _selectors));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,capabilityId,const DeepCollectionEquality().hash(_selectors));
}

@override
String toString() {
    return 'CapabilityClaim(capabilityId: $capabilityId, selectors: $selectors)';
}


}

/// @nodoc
abstract mixin class _$CapabilityClaimCopyWith<$Res> implements $CapabilityClaimCopyWith<$Res> {
  factory _$CapabilityClaimCopyWith(_CapabilityClaim value, $Res Function(_CapabilityClaim) _then) = __$CapabilityClaimCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'cap') String capabilityId, List<CapabilitySelector> selectors
});




}
/// @nodoc
class __$CapabilityClaimCopyWithImpl<$Res>
    implements _$CapabilityClaimCopyWith<$Res> {
  __$CapabilityClaimCopyWithImpl(this._self, this._then);

  final _CapabilityClaim _self;
  final $Res Function(_CapabilityClaim) _then;

/// Create a copy of CapabilityClaim
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? capabilityId = null,Object? selectors = null,}) {
  return _then(_CapabilityClaim(
capabilityId: null == capabilityId ? _self.capabilityId : capabilityId // ignore: cast_nullable_to_non_nullable
as String,selectors: null == selectors ? _self._selectors : selectors // ignore: cast_nullable_to_non_nullable
as List<CapabilitySelector>,
  ));
}


}


/// @nodoc
mixin _$ProviderCapabilityManifest {

 int get version; List<CapabilityClaim> get claims; DateTime get receivedAt; String get sourceHost; bool get stale;
/// Create a copy of ProviderCapabilityManifest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProviderCapabilityManifestCopyWith<ProviderCapabilityManifest> get copyWith => _$ProviderCapabilityManifestCopyWithImpl<ProviderCapabilityManifest>(this as ProviderCapabilityManifest, _$identity);

  /// Serializes this ProviderCapabilityManifest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ProviderCapabilityManifest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProviderCapabilityManifest&&(identical(other.version, _this.version) || other.version == _this.version)&&const DeepCollectionEquality().equals(other.claims, _this.claims)&&(identical(other.receivedAt, _this.receivedAt) || other.receivedAt == _this.receivedAt)&&(identical(other.sourceHost, _this.sourceHost) || other.sourceHost == _this.sourceHost)&&(identical(other.stale, _this.stale) || other.stale == _this.stale));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ProviderCapabilityManifest;
  return Object.hash(runtimeType,_this.version,const DeepCollectionEquality().hash(_this.claims),_this.receivedAt,_this.sourceHost,_this.stale);
}

@override
String toString() {
  final _this = this as ProviderCapabilityManifest;
  return 'ProviderCapabilityManifest(version: ${_this.version}, claims: ${_this.claims}, receivedAt: ${_this.receivedAt}, sourceHost: ${_this.sourceHost}, stale: ${_this.stale})';
}


}

/// @nodoc
abstract mixin class $ProviderCapabilityManifestCopyWith<$Res>  {
  factory $ProviderCapabilityManifestCopyWith(ProviderCapabilityManifest value, $Res Function(ProviderCapabilityManifest) _then) = _$ProviderCapabilityManifestCopyWithImpl;
@useResult
$Res call({
 int version, List<CapabilityClaim> claims, DateTime receivedAt, String sourceHost, bool stale
});




}
/// @nodoc
class _$ProviderCapabilityManifestCopyWithImpl<$Res>
    implements $ProviderCapabilityManifestCopyWith<$Res> {
  _$ProviderCapabilityManifestCopyWithImpl(this._self, this._then);

  final ProviderCapabilityManifest _self;
  final $Res Function(ProviderCapabilityManifest) _then;

/// Create a copy of ProviderCapabilityManifest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? version = null,Object? claims = null,Object? receivedAt = null,Object? sourceHost = null,Object? stale = null,}) {
  return _then(ProviderCapabilityManifest(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,claims: null == claims ? _self.claims : claims // ignore: cast_nullable_to_non_nullable
as List<CapabilityClaim>,receivedAt: null == receivedAt ? _self.receivedAt : receivedAt // ignore: cast_nullable_to_non_nullable
as DateTime,sourceHost: null == sourceHost ? _self.sourceHost : sourceHost // ignore: cast_nullable_to_non_nullable
as String,stale: null == stale ? _self.stale : stale // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ProviderCapabilityManifest].
extension ProviderCapabilityManifestPatterns on ProviderCapabilityManifest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProviderCapabilityManifest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProviderCapabilityManifest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProviderCapabilityManifest value)  $default,){
final _that = this;
switch (_that) {
case _ProviderCapabilityManifest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProviderCapabilityManifest value)?  $default,){
final _that = this;
switch (_that) {
case _ProviderCapabilityManifest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int version,  List<CapabilityClaim> claims,  DateTime receivedAt,  String sourceHost,  bool stale)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProviderCapabilityManifest() when $default != null:
return $default(_that.version,_that.claims,_that.receivedAt,_that.sourceHost,_that.stale);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int version,  List<CapabilityClaim> claims,  DateTime receivedAt,  String sourceHost,  bool stale)  $default,) {final _that = this;
switch (_that) {
case _ProviderCapabilityManifest():
return $default(_that.version,_that.claims,_that.receivedAt,_that.sourceHost,_that.stale);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int version,  List<CapabilityClaim> claims,  DateTime receivedAt,  String sourceHost,  bool stale)?  $default,) {final _that = this;
switch (_that) {
case _ProviderCapabilityManifest() when $default != null:
return $default(_that.version,_that.claims,_that.receivedAt,_that.sourceHost,_that.stale);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProviderCapabilityManifest implements ProviderCapabilityManifest {
  const _ProviderCapabilityManifest({required this.version,  List<CapabilityClaim> claims = const [], required this.receivedAt, required this.sourceHost, this.stale = false}): _claims = claims;
  factory _ProviderCapabilityManifest.fromJson(Map<String, dynamic> json) => _$ProviderCapabilityManifestFromJson(json);

@override final  int version;
 final  List<CapabilityClaim> _claims;
@override@JsonKey() List<CapabilityClaim> get claims {
  if (_claims is EqualUnmodifiableListView) return _claims;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_claims);
}

@override final  DateTime receivedAt;
@override final  String sourceHost;
@override@JsonKey() final  bool stale;

/// Create a copy of ProviderCapabilityManifest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProviderCapabilityManifestCopyWith<_ProviderCapabilityManifest> get copyWith => __$ProviderCapabilityManifestCopyWithImpl<_ProviderCapabilityManifest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProviderCapabilityManifestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProviderCapabilityManifest&&(identical(other.version, version) || other.version == version)&&const DeepCollectionEquality().equals(other.claims, _claims)&&(identical(other.receivedAt, receivedAt) || other.receivedAt == receivedAt)&&(identical(other.sourceHost, sourceHost) || other.sourceHost == sourceHost)&&(identical(other.stale, stale) || other.stale == stale));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,version,const DeepCollectionEquality().hash(_claims),receivedAt,sourceHost,stale);
}

@override
String toString() {
    return 'ProviderCapabilityManifest(version: $version, claims: $claims, receivedAt: $receivedAt, sourceHost: $sourceHost, stale: $stale)';
}


}

/// @nodoc
abstract mixin class _$ProviderCapabilityManifestCopyWith<$Res> implements $ProviderCapabilityManifestCopyWith<$Res> {
  factory _$ProviderCapabilityManifestCopyWith(_ProviderCapabilityManifest value, $Res Function(_ProviderCapabilityManifest) _then) = __$ProviderCapabilityManifestCopyWithImpl;
@override @useResult
$Res call({
 int version, List<CapabilityClaim> claims, DateTime receivedAt, String sourceHost, bool stale
});




}
/// @nodoc
class __$ProviderCapabilityManifestCopyWithImpl<$Res>
    implements _$ProviderCapabilityManifestCopyWith<$Res> {
  __$ProviderCapabilityManifestCopyWithImpl(this._self, this._then);

  final _ProviderCapabilityManifest _self;
  final $Res Function(_ProviderCapabilityManifest) _then;

/// Create a copy of ProviderCapabilityManifest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? version = null,Object? claims = null,Object? receivedAt = null,Object? sourceHost = null,Object? stale = null,}) {
  return _then(_ProviderCapabilityManifest(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,claims: null == claims ? _self._claims : claims // ignore: cast_nullable_to_non_nullable
as List<CapabilityClaim>,receivedAt: null == receivedAt ? _self.receivedAt : receivedAt // ignore: cast_nullable_to_non_nullable
as DateTime,sourceHost: null == sourceHost ? _self.sourceHost : sourceHost // ignore: cast_nullable_to_non_nullable
as String,stale: null == stale ? _self.stale : stale // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$ServiceRoutePolicy {

 String get capabilityId; bool get enabled; ServiceRouteFallback get fallback;
/// Create a copy of ServiceRoutePolicy
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServiceRoutePolicyCopyWith<ServiceRoutePolicy> get copyWith => _$ServiceRoutePolicyCopyWithImpl<ServiceRoutePolicy>(this as ServiceRoutePolicy, _$identity);

  /// Serializes this ServiceRoutePolicy to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ServiceRoutePolicy;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServiceRoutePolicy&&(identical(other.capabilityId, _this.capabilityId) || other.capabilityId == _this.capabilityId)&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled)&&(identical(other.fallback, _this.fallback) || other.fallback == _this.fallback));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ServiceRoutePolicy;
  return Object.hash(runtimeType,_this.capabilityId,_this.enabled,_this.fallback);
}

@override
String toString() {
  final _this = this as ServiceRoutePolicy;
  return 'ServiceRoutePolicy(capabilityId: ${_this.capabilityId}, enabled: ${_this.enabled}, fallback: ${_this.fallback})';
}


}

/// @nodoc
abstract mixin class $ServiceRoutePolicyCopyWith<$Res>  {
  factory $ServiceRoutePolicyCopyWith(ServiceRoutePolicy value, $Res Function(ServiceRoutePolicy) _then) = _$ServiceRoutePolicyCopyWithImpl;
@useResult
$Res call({
 String capabilityId, bool enabled, ServiceRouteFallback fallback
});




}
/// @nodoc
class _$ServiceRoutePolicyCopyWithImpl<$Res>
    implements $ServiceRoutePolicyCopyWith<$Res> {
  _$ServiceRoutePolicyCopyWithImpl(this._self, this._then);

  final ServiceRoutePolicy _self;
  final $Res Function(ServiceRoutePolicy) _then;

/// Create a copy of ServiceRoutePolicy
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? capabilityId = null,Object? enabled = null,Object? fallback = null,}) {
  return _then(ServiceRoutePolicy(
capabilityId: null == capabilityId ? _self.capabilityId : capabilityId // ignore: cast_nullable_to_non_nullable
as String,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,fallback: null == fallback ? _self.fallback : fallback // ignore: cast_nullable_to_non_nullable
as ServiceRouteFallback,
  ));
}

}


/// Adds pattern-matching-related methods to [ServiceRoutePolicy].
extension ServiceRoutePolicyPatterns on ServiceRoutePolicy {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ServiceRoutePolicy value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ServiceRoutePolicy() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ServiceRoutePolicy value)  $default,){
final _that = this;
switch (_that) {
case _ServiceRoutePolicy():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ServiceRoutePolicy value)?  $default,){
final _that = this;
switch (_that) {
case _ServiceRoutePolicy() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String capabilityId,  bool enabled,  ServiceRouteFallback fallback)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ServiceRoutePolicy() when $default != null:
return $default(_that.capabilityId,_that.enabled,_that.fallback);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String capabilityId,  bool enabled,  ServiceRouteFallback fallback)  $default,) {final _that = this;
switch (_that) {
case _ServiceRoutePolicy():
return $default(_that.capabilityId,_that.enabled,_that.fallback);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String capabilityId,  bool enabled,  ServiceRouteFallback fallback)?  $default,) {final _that = this;
switch (_that) {
case _ServiceRoutePolicy() when $default != null:
return $default(_that.capabilityId,_that.enabled,_that.fallback);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ServiceRoutePolicy implements ServiceRoutePolicy {
  const _ServiceRoutePolicy({required this.capabilityId, this.enabled = false, this.fallback = ServiceRouteFallback.main});
  factory _ServiceRoutePolicy.fromJson(Map<String, dynamic> json) => _$ServiceRoutePolicyFromJson(json);

@override final  String capabilityId;
@override@JsonKey() final  bool enabled;
@override@JsonKey() final  ServiceRouteFallback fallback;

/// Create a copy of ServiceRoutePolicy
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ServiceRoutePolicyCopyWith<_ServiceRoutePolicy> get copyWith => __$ServiceRoutePolicyCopyWithImpl<_ServiceRoutePolicy>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ServiceRoutePolicyToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ServiceRoutePolicy&&(identical(other.capabilityId, capabilityId) || other.capabilityId == capabilityId)&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.fallback, fallback) || other.fallback == fallback));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,capabilityId,enabled,fallback);
}

@override
String toString() {
    return 'ServiceRoutePolicy(capabilityId: $capabilityId, enabled: $enabled, fallback: $fallback)';
}


}

/// @nodoc
abstract mixin class _$ServiceRoutePolicyCopyWith<$Res> implements $ServiceRoutePolicyCopyWith<$Res> {
  factory _$ServiceRoutePolicyCopyWith(_ServiceRoutePolicy value, $Res Function(_ServiceRoutePolicy) _then) = __$ServiceRoutePolicyCopyWithImpl;
@override @useResult
$Res call({
 String capabilityId, bool enabled, ServiceRouteFallback fallback
});




}
/// @nodoc
class __$ServiceRoutePolicyCopyWithImpl<$Res>
    implements _$ServiceRoutePolicyCopyWith<$Res> {
  __$ServiceRoutePolicyCopyWithImpl(this._self, this._then);

  final _ServiceRoutePolicy _self;
  final $Res Function(_ServiceRoutePolicy) _then;

/// Create a copy of ServiceRoutePolicy
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? capabilityId = null,Object? enabled = null,Object? fallback = null,}) {
  return _then(_ServiceRoutePolicy(
capabilityId: null == capabilityId ? _self.capabilityId : capabilityId // ignore: cast_nullable_to_non_nullable
as String,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,fallback: null == fallback ? _self.fallback : fallback // ignore: cast_nullable_to_non_nullable
as ServiceRouteFallback,
  ));
}


}


/// @nodoc
mixin _$ManualCapabilitySelector {

 String get capabilityId; String? get provider; String get nameContains;
/// Create a copy of ManualCapabilitySelector
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ManualCapabilitySelectorCopyWith<ManualCapabilitySelector> get copyWith => _$ManualCapabilitySelectorCopyWithImpl<ManualCapabilitySelector>(this as ManualCapabilitySelector, _$identity);

  /// Serializes this ManualCapabilitySelector to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ManualCapabilitySelector;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ManualCapabilitySelector&&(identical(other.capabilityId, _this.capabilityId) || other.capabilityId == _this.capabilityId)&&(identical(other.provider, _this.provider) || other.provider == _this.provider)&&(identical(other.nameContains, _this.nameContains) || other.nameContains == _this.nameContains));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ManualCapabilitySelector;
  return Object.hash(runtimeType,_this.capabilityId,_this.provider,_this.nameContains);
}

@override
String toString() {
  final _this = this as ManualCapabilitySelector;
  return 'ManualCapabilitySelector(capabilityId: ${_this.capabilityId}, provider: ${_this.provider}, nameContains: ${_this.nameContains})';
}


}

/// @nodoc
abstract mixin class $ManualCapabilitySelectorCopyWith<$Res>  {
  factory $ManualCapabilitySelectorCopyWith(ManualCapabilitySelector value, $Res Function(ManualCapabilitySelector) _then) = _$ManualCapabilitySelectorCopyWithImpl;
@useResult
$Res call({
 String capabilityId, String? provider, String nameContains
});




}
/// @nodoc
class _$ManualCapabilitySelectorCopyWithImpl<$Res>
    implements $ManualCapabilitySelectorCopyWith<$Res> {
  _$ManualCapabilitySelectorCopyWithImpl(this._self, this._then);

  final ManualCapabilitySelector _self;
  final $Res Function(ManualCapabilitySelector) _then;

/// Create a copy of ManualCapabilitySelector
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? capabilityId = null,Object? provider = freezed,Object? nameContains = null,}) {
  return _then(ManualCapabilitySelector(
capabilityId: null == capabilityId ? _self.capabilityId : capabilityId // ignore: cast_nullable_to_non_nullable
as String,provider: freezed == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String?,nameContains: null == nameContains ? _self.nameContains : nameContains // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ManualCapabilitySelector].
extension ManualCapabilitySelectorPatterns on ManualCapabilitySelector {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ManualCapabilitySelector value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ManualCapabilitySelector() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ManualCapabilitySelector value)  $default,){
final _that = this;
switch (_that) {
case _ManualCapabilitySelector():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ManualCapabilitySelector value)?  $default,){
final _that = this;
switch (_that) {
case _ManualCapabilitySelector() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String capabilityId,  String? provider,  String nameContains)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ManualCapabilitySelector() when $default != null:
return $default(_that.capabilityId,_that.provider,_that.nameContains);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String capabilityId,  String? provider,  String nameContains)  $default,) {final _that = this;
switch (_that) {
case _ManualCapabilitySelector():
return $default(_that.capabilityId,_that.provider,_that.nameContains);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String capabilityId,  String? provider,  String nameContains)?  $default,) {final _that = this;
switch (_that) {
case _ManualCapabilitySelector() when $default != null:
return $default(_that.capabilityId,_that.provider,_that.nameContains);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ManualCapabilitySelector implements ManualCapabilitySelector {
  const _ManualCapabilitySelector({required this.capabilityId, this.provider, required this.nameContains});
  factory _ManualCapabilitySelector.fromJson(Map<String, dynamic> json) => _$ManualCapabilitySelectorFromJson(json);

@override final  String capabilityId;
@override final  String? provider;
@override final  String nameContains;

/// Create a copy of ManualCapabilitySelector
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ManualCapabilitySelectorCopyWith<_ManualCapabilitySelector> get copyWith => __$ManualCapabilitySelectorCopyWithImpl<_ManualCapabilitySelector>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ManualCapabilitySelectorToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ManualCapabilitySelector&&(identical(other.capabilityId, capabilityId) || other.capabilityId == capabilityId)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.nameContains, nameContains) || other.nameContains == nameContains));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,capabilityId,provider,nameContains);
}

@override
String toString() {
    return 'ManualCapabilitySelector(capabilityId: $capabilityId, provider: $provider, nameContains: $nameContains)';
}


}

/// @nodoc
abstract mixin class _$ManualCapabilitySelectorCopyWith<$Res> implements $ManualCapabilitySelectorCopyWith<$Res> {
  factory _$ManualCapabilitySelectorCopyWith(_ManualCapabilitySelector value, $Res Function(_ManualCapabilitySelector) _then) = __$ManualCapabilitySelectorCopyWithImpl;
@override @useResult
$Res call({
 String capabilityId, String? provider, String nameContains
});




}
/// @nodoc
class __$ManualCapabilitySelectorCopyWithImpl<$Res>
    implements _$ManualCapabilitySelectorCopyWith<$Res> {
  __$ManualCapabilitySelectorCopyWithImpl(this._self, this._then);

  final _ManualCapabilitySelector _self;
  final $Res Function(_ManualCapabilitySelector) _then;

/// Create a copy of ManualCapabilitySelector
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? capabilityId = null,Object? provider = freezed,Object? nameContains = null,}) {
  return _then(_ManualCapabilitySelector(
capabilityId: null == capabilityId ? _self.capabilityId : capabilityId // ignore: cast_nullable_to_non_nullable
as String,provider: freezed == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String?,nameContains: null == nameContains ? _self.nameContains : nameContains // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
