// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../subscription_report.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SubscriptionVerdict {

 String get headline;@JsonKey(unknownEnumValue: SubscriptionFault.unknown) SubscriptionFault get fault; String get health; String get causeCode; String get layer; String get terrain; String get env;
/// Create a copy of SubscriptionVerdict
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubscriptionVerdictCopyWith<SubscriptionVerdict> get copyWith => _$SubscriptionVerdictCopyWithImpl<SubscriptionVerdict>(this as SubscriptionVerdict, _$identity);

  /// Serializes this SubscriptionVerdict to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SubscriptionVerdict;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubscriptionVerdict&&(identical(other.headline, _this.headline) || other.headline == _this.headline)&&(identical(other.fault, _this.fault) || other.fault == _this.fault)&&(identical(other.health, _this.health) || other.health == _this.health)&&(identical(other.causeCode, _this.causeCode) || other.causeCode == _this.causeCode)&&(identical(other.layer, _this.layer) || other.layer == _this.layer)&&(identical(other.terrain, _this.terrain) || other.terrain == _this.terrain)&&(identical(other.env, _this.env) || other.env == _this.env));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SubscriptionVerdict;
  return Object.hash(runtimeType,_this.headline,_this.fault,_this.health,_this.causeCode,_this.layer,_this.terrain,_this.env);
}

@override
String toString() {
  final _this = this as SubscriptionVerdict;
  return 'SubscriptionVerdict(headline: ${_this.headline}, fault: ${_this.fault}, health: ${_this.health}, causeCode: ${_this.causeCode}, layer: ${_this.layer}, terrain: ${_this.terrain}, env: ${_this.env})';
}


}

/// @nodoc
abstract mixin class $SubscriptionVerdictCopyWith<$Res>  {
  factory $SubscriptionVerdictCopyWith(SubscriptionVerdict value, $Res Function(SubscriptionVerdict) _then) = _$SubscriptionVerdictCopyWithImpl;
@useResult
$Res call({
 String headline,@JsonKey(unknownEnumValue: SubscriptionFault.unknown) SubscriptionFault fault, String health, String causeCode, String layer, String terrain, String env
});




}
/// @nodoc
class _$SubscriptionVerdictCopyWithImpl<$Res>
    implements $SubscriptionVerdictCopyWith<$Res> {
  _$SubscriptionVerdictCopyWithImpl(this._self, this._then);

  final SubscriptionVerdict _self;
  final $Res Function(SubscriptionVerdict) _then;

/// Create a copy of SubscriptionVerdict
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? headline = null,Object? fault = null,Object? health = null,Object? causeCode = null,Object? layer = null,Object? terrain = null,Object? env = null,}) {
  return _then(SubscriptionVerdict(
headline: null == headline ? _self.headline : headline // ignore: cast_nullable_to_non_nullable
as String,fault: null == fault ? _self.fault : fault // ignore: cast_nullable_to_non_nullable
as SubscriptionFault,health: null == health ? _self.health : health // ignore: cast_nullable_to_non_nullable
as String,causeCode: null == causeCode ? _self.causeCode : causeCode // ignore: cast_nullable_to_non_nullable
as String,layer: null == layer ? _self.layer : layer // ignore: cast_nullable_to_non_nullable
as String,terrain: null == terrain ? _self.terrain : terrain // ignore: cast_nullable_to_non_nullable
as String,env: null == env ? _self.env : env // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SubscriptionVerdict].
extension SubscriptionVerdictPatterns on SubscriptionVerdict {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubscriptionVerdict value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubscriptionVerdict() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubscriptionVerdict value)  $default,){
final _that = this;
switch (_that) {
case _SubscriptionVerdict():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubscriptionVerdict value)?  $default,){
final _that = this;
switch (_that) {
case _SubscriptionVerdict() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String headline, @JsonKey(unknownEnumValue: SubscriptionFault.unknown)  SubscriptionFault fault,  String health,  String causeCode,  String layer,  String terrain,  String env)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubscriptionVerdict() when $default != null:
return $default(_that.headline,_that.fault,_that.health,_that.causeCode,_that.layer,_that.terrain,_that.env);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String headline, @JsonKey(unknownEnumValue: SubscriptionFault.unknown)  SubscriptionFault fault,  String health,  String causeCode,  String layer,  String terrain,  String env)  $default,) {final _that = this;
switch (_that) {
case _SubscriptionVerdict():
return $default(_that.headline,_that.fault,_that.health,_that.causeCode,_that.layer,_that.terrain,_that.env);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String headline, @JsonKey(unknownEnumValue: SubscriptionFault.unknown)  SubscriptionFault fault,  String health,  String causeCode,  String layer,  String terrain,  String env)?  $default,) {final _that = this;
switch (_that) {
case _SubscriptionVerdict() when $default != null:
return $default(_that.headline,_that.fault,_that.health,_that.causeCode,_that.layer,_that.terrain,_that.env);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubscriptionVerdict implements SubscriptionVerdict {
  const _SubscriptionVerdict({this.headline = '', @JsonKey(unknownEnumValue: SubscriptionFault.unknown) this.fault = SubscriptionFault.unknown, this.health = '', this.causeCode = '', this.layer = '', this.terrain = '', this.env = ''});
  factory _SubscriptionVerdict.fromJson(Map<String, dynamic> json) => _$SubscriptionVerdictFromJson(json);

@override@JsonKey() final  String headline;
@override@JsonKey(unknownEnumValue: SubscriptionFault.unknown) final  SubscriptionFault fault;
@override@JsonKey() final  String health;
@override@JsonKey() final  String causeCode;
@override@JsonKey() final  String layer;
@override@JsonKey() final  String terrain;
@override@JsonKey() final  String env;

/// Create a copy of SubscriptionVerdict
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubscriptionVerdictCopyWith<_SubscriptionVerdict> get copyWith => __$SubscriptionVerdictCopyWithImpl<_SubscriptionVerdict>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubscriptionVerdictToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubscriptionVerdict&&(identical(other.headline, headline) || other.headline == headline)&&(identical(other.fault, fault) || other.fault == fault)&&(identical(other.health, health) || other.health == health)&&(identical(other.causeCode, causeCode) || other.causeCode == causeCode)&&(identical(other.layer, layer) || other.layer == layer)&&(identical(other.terrain, terrain) || other.terrain == terrain)&&(identical(other.env, env) || other.env == env));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,headline,fault,health,causeCode,layer,terrain,env);
}

@override
String toString() {
    return 'SubscriptionVerdict(headline: $headline, fault: $fault, health: $health, causeCode: $causeCode, layer: $layer, terrain: $terrain, env: $env)';
}


}

/// @nodoc
abstract mixin class _$SubscriptionVerdictCopyWith<$Res> implements $SubscriptionVerdictCopyWith<$Res> {
  factory _$SubscriptionVerdictCopyWith(_SubscriptionVerdict value, $Res Function(_SubscriptionVerdict) _then) = __$SubscriptionVerdictCopyWithImpl;
@override @useResult
$Res call({
 String headline,@JsonKey(unknownEnumValue: SubscriptionFault.unknown) SubscriptionFault fault, String health, String causeCode, String layer, String terrain, String env
});




}
/// @nodoc
class __$SubscriptionVerdictCopyWithImpl<$Res>
    implements _$SubscriptionVerdictCopyWith<$Res> {
  __$SubscriptionVerdictCopyWithImpl(this._self, this._then);

  final _SubscriptionVerdict _self;
  final $Res Function(_SubscriptionVerdict) _then;

/// Create a copy of SubscriptionVerdict
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? headline = null,Object? fault = null,Object? health = null,Object? causeCode = null,Object? layer = null,Object? terrain = null,Object? env = null,}) {
  return _then(_SubscriptionVerdict(
headline: null == headline ? _self.headline : headline // ignore: cast_nullable_to_non_nullable
as String,fault: null == fault ? _self.fault : fault // ignore: cast_nullable_to_non_nullable
as SubscriptionFault,health: null == health ? _self.health : health // ignore: cast_nullable_to_non_nullable
as String,causeCode: null == causeCode ? _self.causeCode : causeCode // ignore: cast_nullable_to_non_nullable
as String,layer: null == layer ? _self.layer : layer // ignore: cast_nullable_to_non_nullable
as String,terrain: null == terrain ? _self.terrain : terrain // ignore: cast_nullable_to_non_nullable
as String,env: null == env ? _self.env : env // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$SubscriptionUpdateStage {

 String get stage; int get attempts; int get failures; String get dominantError;
/// Create a copy of SubscriptionUpdateStage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubscriptionUpdateStageCopyWith<SubscriptionUpdateStage> get copyWith => _$SubscriptionUpdateStageCopyWithImpl<SubscriptionUpdateStage>(this as SubscriptionUpdateStage, _$identity);

  /// Serializes this SubscriptionUpdateStage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SubscriptionUpdateStage;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubscriptionUpdateStage&&(identical(other.stage, _this.stage) || other.stage == _this.stage)&&(identical(other.attempts, _this.attempts) || other.attempts == _this.attempts)&&(identical(other.failures, _this.failures) || other.failures == _this.failures)&&(identical(other.dominantError, _this.dominantError) || other.dominantError == _this.dominantError));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SubscriptionUpdateStage;
  return Object.hash(runtimeType,_this.stage,_this.attempts,_this.failures,_this.dominantError);
}

@override
String toString() {
  final _this = this as SubscriptionUpdateStage;
  return 'SubscriptionUpdateStage(stage: ${_this.stage}, attempts: ${_this.attempts}, failures: ${_this.failures}, dominantError: ${_this.dominantError})';
}


}

/// @nodoc
abstract mixin class $SubscriptionUpdateStageCopyWith<$Res>  {
  factory $SubscriptionUpdateStageCopyWith(SubscriptionUpdateStage value, $Res Function(SubscriptionUpdateStage) _then) = _$SubscriptionUpdateStageCopyWithImpl;
@useResult
$Res call({
 String stage, int attempts, int failures, String dominantError
});




}
/// @nodoc
class _$SubscriptionUpdateStageCopyWithImpl<$Res>
    implements $SubscriptionUpdateStageCopyWith<$Res> {
  _$SubscriptionUpdateStageCopyWithImpl(this._self, this._then);

  final SubscriptionUpdateStage _self;
  final $Res Function(SubscriptionUpdateStage) _then;

/// Create a copy of SubscriptionUpdateStage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? stage = null,Object? attempts = null,Object? failures = null,Object? dominantError = null,}) {
  return _then(SubscriptionUpdateStage(
stage: null == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as String,attempts: null == attempts ? _self.attempts : attempts // ignore: cast_nullable_to_non_nullable
as int,failures: null == failures ? _self.failures : failures // ignore: cast_nullable_to_non_nullable
as int,dominantError: null == dominantError ? _self.dominantError : dominantError // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SubscriptionUpdateStage].
extension SubscriptionUpdateStagePatterns on SubscriptionUpdateStage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubscriptionUpdateStage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubscriptionUpdateStage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubscriptionUpdateStage value)  $default,){
final _that = this;
switch (_that) {
case _SubscriptionUpdateStage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubscriptionUpdateStage value)?  $default,){
final _that = this;
switch (_that) {
case _SubscriptionUpdateStage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String stage,  int attempts,  int failures,  String dominantError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubscriptionUpdateStage() when $default != null:
return $default(_that.stage,_that.attempts,_that.failures,_that.dominantError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String stage,  int attempts,  int failures,  String dominantError)  $default,) {final _that = this;
switch (_that) {
case _SubscriptionUpdateStage():
return $default(_that.stage,_that.attempts,_that.failures,_that.dominantError);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String stage,  int attempts,  int failures,  String dominantError)?  $default,) {final _that = this;
switch (_that) {
case _SubscriptionUpdateStage() when $default != null:
return $default(_that.stage,_that.attempts,_that.failures,_that.dominantError);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubscriptionUpdateStage implements SubscriptionUpdateStage {
  const _SubscriptionUpdateStage({this.stage = '', this.attempts = 0, this.failures = 0, this.dominantError = ''});
  factory _SubscriptionUpdateStage.fromJson(Map<String, dynamic> json) => _$SubscriptionUpdateStageFromJson(json);

@override@JsonKey() final  String stage;
@override@JsonKey() final  int attempts;
@override@JsonKey() final  int failures;
@override@JsonKey() final  String dominantError;

/// Create a copy of SubscriptionUpdateStage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubscriptionUpdateStageCopyWith<_SubscriptionUpdateStage> get copyWith => __$SubscriptionUpdateStageCopyWithImpl<_SubscriptionUpdateStage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubscriptionUpdateStageToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubscriptionUpdateStage&&(identical(other.stage, stage) || other.stage == stage)&&(identical(other.attempts, attempts) || other.attempts == attempts)&&(identical(other.failures, failures) || other.failures == failures)&&(identical(other.dominantError, dominantError) || other.dominantError == dominantError));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,stage,attempts,failures,dominantError);
}

@override
String toString() {
    return 'SubscriptionUpdateStage(stage: $stage, attempts: $attempts, failures: $failures, dominantError: $dominantError)';
}


}

/// @nodoc
abstract mixin class _$SubscriptionUpdateStageCopyWith<$Res> implements $SubscriptionUpdateStageCopyWith<$Res> {
  factory _$SubscriptionUpdateStageCopyWith(_SubscriptionUpdateStage value, $Res Function(_SubscriptionUpdateStage) _then) = __$SubscriptionUpdateStageCopyWithImpl;
@override @useResult
$Res call({
 String stage, int attempts, int failures, String dominantError
});




}
/// @nodoc
class __$SubscriptionUpdateStageCopyWithImpl<$Res>
    implements _$SubscriptionUpdateStageCopyWith<$Res> {
  __$SubscriptionUpdateStageCopyWithImpl(this._self, this._then);

  final _SubscriptionUpdateStage _self;
  final $Res Function(_SubscriptionUpdateStage) _then;

/// Create a copy of SubscriptionUpdateStage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stage = null,Object? attempts = null,Object? failures = null,Object? dominantError = null,}) {
  return _then(_SubscriptionUpdateStage(
stage: null == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as String,attempts: null == attempts ? _self.attempts : attempts // ignore: cast_nullable_to_non_nullable
as int,failures: null == failures ? _self.failures : failures // ignore: cast_nullable_to_non_nullable
as int,dominantError: null == dominantError ? _self.dominantError : dominantError // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$SubscriptionUpdateHost {

 String get host; int get attempts; int get failures; bool get succeeded; String get lastError;
/// Create a copy of SubscriptionUpdateHost
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubscriptionUpdateHostCopyWith<SubscriptionUpdateHost> get copyWith => _$SubscriptionUpdateHostCopyWithImpl<SubscriptionUpdateHost>(this as SubscriptionUpdateHost, _$identity);

  /// Serializes this SubscriptionUpdateHost to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SubscriptionUpdateHost;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubscriptionUpdateHost&&(identical(other.host, _this.host) || other.host == _this.host)&&(identical(other.attempts, _this.attempts) || other.attempts == _this.attempts)&&(identical(other.failures, _this.failures) || other.failures == _this.failures)&&(identical(other.succeeded, _this.succeeded) || other.succeeded == _this.succeeded)&&(identical(other.lastError, _this.lastError) || other.lastError == _this.lastError));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SubscriptionUpdateHost;
  return Object.hash(runtimeType,_this.host,_this.attempts,_this.failures,_this.succeeded,_this.lastError);
}

@override
String toString() {
  final _this = this as SubscriptionUpdateHost;
  return 'SubscriptionUpdateHost(host: ${_this.host}, attempts: ${_this.attempts}, failures: ${_this.failures}, succeeded: ${_this.succeeded}, lastError: ${_this.lastError})';
}


}

/// @nodoc
abstract mixin class $SubscriptionUpdateHostCopyWith<$Res>  {
  factory $SubscriptionUpdateHostCopyWith(SubscriptionUpdateHost value, $Res Function(SubscriptionUpdateHost) _then) = _$SubscriptionUpdateHostCopyWithImpl;
@useResult
$Res call({
 String host, int attempts, int failures, bool succeeded, String lastError
});




}
/// @nodoc
class _$SubscriptionUpdateHostCopyWithImpl<$Res>
    implements $SubscriptionUpdateHostCopyWith<$Res> {
  _$SubscriptionUpdateHostCopyWithImpl(this._self, this._then);

  final SubscriptionUpdateHost _self;
  final $Res Function(SubscriptionUpdateHost) _then;

/// Create a copy of SubscriptionUpdateHost
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? host = null,Object? attempts = null,Object? failures = null,Object? succeeded = null,Object? lastError = null,}) {
  return _then(SubscriptionUpdateHost(
host: null == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String,attempts: null == attempts ? _self.attempts : attempts // ignore: cast_nullable_to_non_nullable
as int,failures: null == failures ? _self.failures : failures // ignore: cast_nullable_to_non_nullable
as int,succeeded: null == succeeded ? _self.succeeded : succeeded // ignore: cast_nullable_to_non_nullable
as bool,lastError: null == lastError ? _self.lastError : lastError // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SubscriptionUpdateHost].
extension SubscriptionUpdateHostPatterns on SubscriptionUpdateHost {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubscriptionUpdateHost value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubscriptionUpdateHost() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubscriptionUpdateHost value)  $default,){
final _that = this;
switch (_that) {
case _SubscriptionUpdateHost():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubscriptionUpdateHost value)?  $default,){
final _that = this;
switch (_that) {
case _SubscriptionUpdateHost() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String host,  int attempts,  int failures,  bool succeeded,  String lastError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubscriptionUpdateHost() when $default != null:
return $default(_that.host,_that.attempts,_that.failures,_that.succeeded,_that.lastError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String host,  int attempts,  int failures,  bool succeeded,  String lastError)  $default,) {final _that = this;
switch (_that) {
case _SubscriptionUpdateHost():
return $default(_that.host,_that.attempts,_that.failures,_that.succeeded,_that.lastError);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String host,  int attempts,  int failures,  bool succeeded,  String lastError)?  $default,) {final _that = this;
switch (_that) {
case _SubscriptionUpdateHost() when $default != null:
return $default(_that.host,_that.attempts,_that.failures,_that.succeeded,_that.lastError);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubscriptionUpdateHost implements SubscriptionUpdateHost {
  const _SubscriptionUpdateHost({this.host = '', this.attempts = 0, this.failures = 0, this.succeeded = false, this.lastError = ''});
  factory _SubscriptionUpdateHost.fromJson(Map<String, dynamic> json) => _$SubscriptionUpdateHostFromJson(json);

@override@JsonKey() final  String host;
@override@JsonKey() final  int attempts;
@override@JsonKey() final  int failures;
@override@JsonKey() final  bool succeeded;
@override@JsonKey() final  String lastError;

/// Create a copy of SubscriptionUpdateHost
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubscriptionUpdateHostCopyWith<_SubscriptionUpdateHost> get copyWith => __$SubscriptionUpdateHostCopyWithImpl<_SubscriptionUpdateHost>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubscriptionUpdateHostToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubscriptionUpdateHost&&(identical(other.host, host) || other.host == host)&&(identical(other.attempts, attempts) || other.attempts == attempts)&&(identical(other.failures, failures) || other.failures == failures)&&(identical(other.succeeded, succeeded) || other.succeeded == succeeded)&&(identical(other.lastError, lastError) || other.lastError == lastError));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,host,attempts,failures,succeeded,lastError);
}

@override
String toString() {
    return 'SubscriptionUpdateHost(host: $host, attempts: $attempts, failures: $failures, succeeded: $succeeded, lastError: $lastError)';
}


}

/// @nodoc
abstract mixin class _$SubscriptionUpdateHostCopyWith<$Res> implements $SubscriptionUpdateHostCopyWith<$Res> {
  factory _$SubscriptionUpdateHostCopyWith(_SubscriptionUpdateHost value, $Res Function(_SubscriptionUpdateHost) _then) = __$SubscriptionUpdateHostCopyWithImpl;
@override @useResult
$Res call({
 String host, int attempts, int failures, bool succeeded, String lastError
});




}
/// @nodoc
class __$SubscriptionUpdateHostCopyWithImpl<$Res>
    implements _$SubscriptionUpdateHostCopyWith<$Res> {
  __$SubscriptionUpdateHostCopyWithImpl(this._self, this._then);

  final _SubscriptionUpdateHost _self;
  final $Res Function(_SubscriptionUpdateHost) _then;

/// Create a copy of SubscriptionUpdateHost
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? host = null,Object? attempts = null,Object? failures = null,Object? succeeded = null,Object? lastError = null,}) {
  return _then(_SubscriptionUpdateHost(
host: null == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String,attempts: null == attempts ? _self.attempts : attempts // ignore: cast_nullable_to_non_nullable
as int,failures: null == failures ? _self.failures : failures // ignore: cast_nullable_to_non_nullable
as int,succeeded: null == succeeded ? _self.succeeded : succeeded // ignore: cast_nullable_to_non_nullable
as bool,lastError: null == lastError ? _self.lastError : lastError // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$SubscriptionUpdateReport {

 bool get attempted; bool get succeeded; int get generatedAt; int get hostCount; int get attempts; int get failures; bool get hwidRejected; bool get emptyResponse; bool get undialable; String get dominantError; List<SubscriptionUpdateStage> get byStage; List<SubscriptionUpdateHost> get hosts;
/// Create a copy of SubscriptionUpdateReport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubscriptionUpdateReportCopyWith<SubscriptionUpdateReport> get copyWith => _$SubscriptionUpdateReportCopyWithImpl<SubscriptionUpdateReport>(this as SubscriptionUpdateReport, _$identity);

  /// Serializes this SubscriptionUpdateReport to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SubscriptionUpdateReport;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubscriptionUpdateReport&&(identical(other.attempted, _this.attempted) || other.attempted == _this.attempted)&&(identical(other.succeeded, _this.succeeded) || other.succeeded == _this.succeeded)&&(identical(other.generatedAt, _this.generatedAt) || other.generatedAt == _this.generatedAt)&&(identical(other.hostCount, _this.hostCount) || other.hostCount == _this.hostCount)&&(identical(other.attempts, _this.attempts) || other.attempts == _this.attempts)&&(identical(other.failures, _this.failures) || other.failures == _this.failures)&&(identical(other.hwidRejected, _this.hwidRejected) || other.hwidRejected == _this.hwidRejected)&&(identical(other.emptyResponse, _this.emptyResponse) || other.emptyResponse == _this.emptyResponse)&&(identical(other.undialable, _this.undialable) || other.undialable == _this.undialable)&&(identical(other.dominantError, _this.dominantError) || other.dominantError == _this.dominantError)&&const DeepCollectionEquality().equals(other.byStage, _this.byStage)&&const DeepCollectionEquality().equals(other.hosts, _this.hosts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SubscriptionUpdateReport;
  return Object.hash(runtimeType,_this.attempted,_this.succeeded,_this.generatedAt,_this.hostCount,_this.attempts,_this.failures,_this.hwidRejected,_this.emptyResponse,_this.undialable,_this.dominantError,const DeepCollectionEquality().hash(_this.byStage),const DeepCollectionEquality().hash(_this.hosts));
}

@override
String toString() {
  final _this = this as SubscriptionUpdateReport;
  return 'SubscriptionUpdateReport(attempted: ${_this.attempted}, succeeded: ${_this.succeeded}, generatedAt: ${_this.generatedAt}, hostCount: ${_this.hostCount}, attempts: ${_this.attempts}, failures: ${_this.failures}, hwidRejected: ${_this.hwidRejected}, emptyResponse: ${_this.emptyResponse}, undialable: ${_this.undialable}, dominantError: ${_this.dominantError}, byStage: ${_this.byStage}, hosts: ${_this.hosts})';
}


}

/// @nodoc
abstract mixin class $SubscriptionUpdateReportCopyWith<$Res>  {
  factory $SubscriptionUpdateReportCopyWith(SubscriptionUpdateReport value, $Res Function(SubscriptionUpdateReport) _then) = _$SubscriptionUpdateReportCopyWithImpl;
@useResult
$Res call({
 bool attempted, bool succeeded, int generatedAt, int hostCount, int attempts, int failures, bool hwidRejected, bool emptyResponse, bool undialable, String dominantError, List<SubscriptionUpdateStage> byStage, List<SubscriptionUpdateHost> hosts
});




}
/// @nodoc
class _$SubscriptionUpdateReportCopyWithImpl<$Res>
    implements $SubscriptionUpdateReportCopyWith<$Res> {
  _$SubscriptionUpdateReportCopyWithImpl(this._self, this._then);

  final SubscriptionUpdateReport _self;
  final $Res Function(SubscriptionUpdateReport) _then;

/// Create a copy of SubscriptionUpdateReport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? attempted = null,Object? succeeded = null,Object? generatedAt = null,Object? hostCount = null,Object? attempts = null,Object? failures = null,Object? hwidRejected = null,Object? emptyResponse = null,Object? undialable = null,Object? dominantError = null,Object? byStage = null,Object? hosts = null,}) {
  return _then(SubscriptionUpdateReport(
attempted: null == attempted ? _self.attempted : attempted // ignore: cast_nullable_to_non_nullable
as bool,succeeded: null == succeeded ? _self.succeeded : succeeded // ignore: cast_nullable_to_non_nullable
as bool,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as int,hostCount: null == hostCount ? _self.hostCount : hostCount // ignore: cast_nullable_to_non_nullable
as int,attempts: null == attempts ? _self.attempts : attempts // ignore: cast_nullable_to_non_nullable
as int,failures: null == failures ? _self.failures : failures // ignore: cast_nullable_to_non_nullable
as int,hwidRejected: null == hwidRejected ? _self.hwidRejected : hwidRejected // ignore: cast_nullable_to_non_nullable
as bool,emptyResponse: null == emptyResponse ? _self.emptyResponse : emptyResponse // ignore: cast_nullable_to_non_nullable
as bool,undialable: null == undialable ? _self.undialable : undialable // ignore: cast_nullable_to_non_nullable
as bool,dominantError: null == dominantError ? _self.dominantError : dominantError // ignore: cast_nullable_to_non_nullable
as String,byStage: null == byStage ? _self.byStage : byStage // ignore: cast_nullable_to_non_nullable
as List<SubscriptionUpdateStage>,hosts: null == hosts ? _self.hosts : hosts // ignore: cast_nullable_to_non_nullable
as List<SubscriptionUpdateHost>,
  ));
}

}


/// Adds pattern-matching-related methods to [SubscriptionUpdateReport].
extension SubscriptionUpdateReportPatterns on SubscriptionUpdateReport {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubscriptionUpdateReport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubscriptionUpdateReport() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubscriptionUpdateReport value)  $default,){
final _that = this;
switch (_that) {
case _SubscriptionUpdateReport():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubscriptionUpdateReport value)?  $default,){
final _that = this;
switch (_that) {
case _SubscriptionUpdateReport() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool attempted,  bool succeeded,  int generatedAt,  int hostCount,  int attempts,  int failures,  bool hwidRejected,  bool emptyResponse,  bool undialable,  String dominantError,  List<SubscriptionUpdateStage> byStage,  List<SubscriptionUpdateHost> hosts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubscriptionUpdateReport() when $default != null:
return $default(_that.attempted,_that.succeeded,_that.generatedAt,_that.hostCount,_that.attempts,_that.failures,_that.hwidRejected,_that.emptyResponse,_that.undialable,_that.dominantError,_that.byStage,_that.hosts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool attempted,  bool succeeded,  int generatedAt,  int hostCount,  int attempts,  int failures,  bool hwidRejected,  bool emptyResponse,  bool undialable,  String dominantError,  List<SubscriptionUpdateStage> byStage,  List<SubscriptionUpdateHost> hosts)  $default,) {final _that = this;
switch (_that) {
case _SubscriptionUpdateReport():
return $default(_that.attempted,_that.succeeded,_that.generatedAt,_that.hostCount,_that.attempts,_that.failures,_that.hwidRejected,_that.emptyResponse,_that.undialable,_that.dominantError,_that.byStage,_that.hosts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool attempted,  bool succeeded,  int generatedAt,  int hostCount,  int attempts,  int failures,  bool hwidRejected,  bool emptyResponse,  bool undialable,  String dominantError,  List<SubscriptionUpdateStage> byStage,  List<SubscriptionUpdateHost> hosts)?  $default,) {final _that = this;
switch (_that) {
case _SubscriptionUpdateReport() when $default != null:
return $default(_that.attempted,_that.succeeded,_that.generatedAt,_that.hostCount,_that.attempts,_that.failures,_that.hwidRejected,_that.emptyResponse,_that.undialable,_that.dominantError,_that.byStage,_that.hosts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubscriptionUpdateReport implements SubscriptionUpdateReport {
  const _SubscriptionUpdateReport({this.attempted = false, this.succeeded = false, this.generatedAt = 0, this.hostCount = 0, this.attempts = 0, this.failures = 0, this.hwidRejected = false, this.emptyResponse = false, this.undialable = false, this.dominantError = '',  List<SubscriptionUpdateStage> byStage = const [],  List<SubscriptionUpdateHost> hosts = const []}): _byStage = byStage,_hosts = hosts;
  factory _SubscriptionUpdateReport.fromJson(Map<String, dynamic> json) => _$SubscriptionUpdateReportFromJson(json);

@override@JsonKey() final  bool attempted;
@override@JsonKey() final  bool succeeded;
@override@JsonKey() final  int generatedAt;
@override@JsonKey() final  int hostCount;
@override@JsonKey() final  int attempts;
@override@JsonKey() final  int failures;
@override@JsonKey() final  bool hwidRejected;
@override@JsonKey() final  bool emptyResponse;
@override@JsonKey() final  bool undialable;
@override@JsonKey() final  String dominantError;
 final  List<SubscriptionUpdateStage> _byStage;
@override@JsonKey() List<SubscriptionUpdateStage> get byStage {
  if (_byStage is EqualUnmodifiableListView) return _byStage;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_byStage);
}

 final  List<SubscriptionUpdateHost> _hosts;
@override@JsonKey() List<SubscriptionUpdateHost> get hosts {
  if (_hosts is EqualUnmodifiableListView) return _hosts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_hosts);
}


/// Create a copy of SubscriptionUpdateReport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubscriptionUpdateReportCopyWith<_SubscriptionUpdateReport> get copyWith => __$SubscriptionUpdateReportCopyWithImpl<_SubscriptionUpdateReport>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubscriptionUpdateReportToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubscriptionUpdateReport&&(identical(other.attempted, attempted) || other.attempted == attempted)&&(identical(other.succeeded, succeeded) || other.succeeded == succeeded)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&(identical(other.hostCount, hostCount) || other.hostCount == hostCount)&&(identical(other.attempts, attempts) || other.attempts == attempts)&&(identical(other.failures, failures) || other.failures == failures)&&(identical(other.hwidRejected, hwidRejected) || other.hwidRejected == hwidRejected)&&(identical(other.emptyResponse, emptyResponse) || other.emptyResponse == emptyResponse)&&(identical(other.undialable, undialable) || other.undialable == undialable)&&(identical(other.dominantError, dominantError) || other.dominantError == dominantError)&&const DeepCollectionEquality().equals(other.byStage, _byStage)&&const DeepCollectionEquality().equals(other.hosts, _hosts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,attempted,succeeded,generatedAt,hostCount,attempts,failures,hwidRejected,emptyResponse,undialable,dominantError,const DeepCollectionEquality().hash(_byStage),const DeepCollectionEquality().hash(_hosts));
}

@override
String toString() {
    return 'SubscriptionUpdateReport(attempted: $attempted, succeeded: $succeeded, generatedAt: $generatedAt, hostCount: $hostCount, attempts: $attempts, failures: $failures, hwidRejected: $hwidRejected, emptyResponse: $emptyResponse, undialable: $undialable, dominantError: $dominantError, byStage: $byStage, hosts: $hosts)';
}


}

/// @nodoc
abstract mixin class _$SubscriptionUpdateReportCopyWith<$Res> implements $SubscriptionUpdateReportCopyWith<$Res> {
  factory _$SubscriptionUpdateReportCopyWith(_SubscriptionUpdateReport value, $Res Function(_SubscriptionUpdateReport) _then) = __$SubscriptionUpdateReportCopyWithImpl;
@override @useResult
$Res call({
 bool attempted, bool succeeded, int generatedAt, int hostCount, int attempts, int failures, bool hwidRejected, bool emptyResponse, bool undialable, String dominantError, List<SubscriptionUpdateStage> byStage, List<SubscriptionUpdateHost> hosts
});




}
/// @nodoc
class __$SubscriptionUpdateReportCopyWithImpl<$Res>
    implements _$SubscriptionUpdateReportCopyWith<$Res> {
  __$SubscriptionUpdateReportCopyWithImpl(this._self, this._then);

  final _SubscriptionUpdateReport _self;
  final $Res Function(_SubscriptionUpdateReport) _then;

/// Create a copy of SubscriptionUpdateReport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? attempted = null,Object? succeeded = null,Object? generatedAt = null,Object? hostCount = null,Object? attempts = null,Object? failures = null,Object? hwidRejected = null,Object? emptyResponse = null,Object? undialable = null,Object? dominantError = null,Object? byStage = null,Object? hosts = null,}) {
  return _then(_SubscriptionUpdateReport(
attempted: null == attempted ? _self.attempted : attempted // ignore: cast_nullable_to_non_nullable
as bool,succeeded: null == succeeded ? _self.succeeded : succeeded // ignore: cast_nullable_to_non_nullable
as bool,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as int,hostCount: null == hostCount ? _self.hostCount : hostCount // ignore: cast_nullable_to_non_nullable
as int,attempts: null == attempts ? _self.attempts : attempts // ignore: cast_nullable_to_non_nullable
as int,failures: null == failures ? _self.failures : failures // ignore: cast_nullable_to_non_nullable
as int,hwidRejected: null == hwidRejected ? _self.hwidRejected : hwidRejected // ignore: cast_nullable_to_non_nullable
as bool,emptyResponse: null == emptyResponse ? _self.emptyResponse : emptyResponse // ignore: cast_nullable_to_non_nullable
as bool,undialable: null == undialable ? _self.undialable : undialable // ignore: cast_nullable_to_non_nullable
as bool,dominantError: null == dominantError ? _self.dominantError : dominantError // ignore: cast_nullable_to_non_nullable
as String,byStage: null == byStage ? _self._byStage : byStage // ignore: cast_nullable_to_non_nullable
as List<SubscriptionUpdateStage>,hosts: null == hosts ? _self._hosts : hosts // ignore: cast_nullable_to_non_nullable
as List<SubscriptionUpdateHost>,
  ));
}


}


/// @nodoc
mixin _$SubscriptionOutcome {

 String get key; int get attempts; int get failure;
/// Create a copy of SubscriptionOutcome
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubscriptionOutcomeCopyWith<SubscriptionOutcome> get copyWith => _$SubscriptionOutcomeCopyWithImpl<SubscriptionOutcome>(this as SubscriptionOutcome, _$identity);

  /// Serializes this SubscriptionOutcome to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SubscriptionOutcome;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubscriptionOutcome&&(identical(other.key, _this.key) || other.key == _this.key)&&(identical(other.attempts, _this.attempts) || other.attempts == _this.attempts)&&(identical(other.failure, _this.failure) || other.failure == _this.failure));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SubscriptionOutcome;
  return Object.hash(runtimeType,_this.key,_this.attempts,_this.failure);
}

@override
String toString() {
  final _this = this as SubscriptionOutcome;
  return 'SubscriptionOutcome(key: ${_this.key}, attempts: ${_this.attempts}, failure: ${_this.failure})';
}


}

/// @nodoc
abstract mixin class $SubscriptionOutcomeCopyWith<$Res>  {
  factory $SubscriptionOutcomeCopyWith(SubscriptionOutcome value, $Res Function(SubscriptionOutcome) _then) = _$SubscriptionOutcomeCopyWithImpl;
@useResult
$Res call({
 String key, int attempts, int failure
});




}
/// @nodoc
class _$SubscriptionOutcomeCopyWithImpl<$Res>
    implements $SubscriptionOutcomeCopyWith<$Res> {
  _$SubscriptionOutcomeCopyWithImpl(this._self, this._then);

  final SubscriptionOutcome _self;
  final $Res Function(SubscriptionOutcome) _then;

/// Create a copy of SubscriptionOutcome
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? attempts = null,Object? failure = null,}) {
  return _then(SubscriptionOutcome(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,attempts: null == attempts ? _self.attempts : attempts // ignore: cast_nullable_to_non_nullable
as int,failure: null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SubscriptionOutcome].
extension SubscriptionOutcomePatterns on SubscriptionOutcome {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubscriptionOutcome value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubscriptionOutcome() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubscriptionOutcome value)  $default,){
final _that = this;
switch (_that) {
case _SubscriptionOutcome():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubscriptionOutcome value)?  $default,){
final _that = this;
switch (_that) {
case _SubscriptionOutcome() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String key,  int attempts,  int failure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubscriptionOutcome() when $default != null:
return $default(_that.key,_that.attempts,_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String key,  int attempts,  int failure)  $default,) {final _that = this;
switch (_that) {
case _SubscriptionOutcome():
return $default(_that.key,_that.attempts,_that.failure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String key,  int attempts,  int failure)?  $default,) {final _that = this;
switch (_that) {
case _SubscriptionOutcome() when $default != null:
return $default(_that.key,_that.attempts,_that.failure);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubscriptionOutcome implements SubscriptionOutcome {
  const _SubscriptionOutcome({this.key = '', this.attempts = 0, this.failure = 0});
  factory _SubscriptionOutcome.fromJson(Map<String, dynamic> json) => _$SubscriptionOutcomeFromJson(json);

@override@JsonKey() final  String key;
@override@JsonKey() final  int attempts;
@override@JsonKey() final  int failure;

/// Create a copy of SubscriptionOutcome
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubscriptionOutcomeCopyWith<_SubscriptionOutcome> get copyWith => __$SubscriptionOutcomeCopyWithImpl<_SubscriptionOutcome>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubscriptionOutcomeToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubscriptionOutcome&&(identical(other.key, key) || other.key == key)&&(identical(other.attempts, attempts) || other.attempts == attempts)&&(identical(other.failure, failure) || other.failure == failure));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,key,attempts,failure);
}

@override
String toString() {
    return 'SubscriptionOutcome(key: $key, attempts: $attempts, failure: $failure)';
}


}

/// @nodoc
abstract mixin class _$SubscriptionOutcomeCopyWith<$Res> implements $SubscriptionOutcomeCopyWith<$Res> {
  factory _$SubscriptionOutcomeCopyWith(_SubscriptionOutcome value, $Res Function(_SubscriptionOutcome) _then) = __$SubscriptionOutcomeCopyWithImpl;
@override @useResult
$Res call({
 String key, int attempts, int failure
});




}
/// @nodoc
class __$SubscriptionOutcomeCopyWithImpl<$Res>
    implements _$SubscriptionOutcomeCopyWith<$Res> {
  __$SubscriptionOutcomeCopyWithImpl(this._self, this._then);

  final _SubscriptionOutcome _self;
  final $Res Function(_SubscriptionOutcome) _then;

/// Create a copy of SubscriptionOutcome
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? attempts = null,Object? failure = null,}) {
  return _then(_SubscriptionOutcome(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,attempts: null == attempts ? _self.attempts : attempts // ignore: cast_nullable_to_non_nullable
as int,failure: null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$SubscriptionGroupOutcome {

 String get group; int get attempts; int get failure;
/// Create a copy of SubscriptionGroupOutcome
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubscriptionGroupOutcomeCopyWith<SubscriptionGroupOutcome> get copyWith => _$SubscriptionGroupOutcomeCopyWithImpl<SubscriptionGroupOutcome>(this as SubscriptionGroupOutcome, _$identity);

  /// Serializes this SubscriptionGroupOutcome to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SubscriptionGroupOutcome;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubscriptionGroupOutcome&&(identical(other.group, _this.group) || other.group == _this.group)&&(identical(other.attempts, _this.attempts) || other.attempts == _this.attempts)&&(identical(other.failure, _this.failure) || other.failure == _this.failure));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SubscriptionGroupOutcome;
  return Object.hash(runtimeType,_this.group,_this.attempts,_this.failure);
}

@override
String toString() {
  final _this = this as SubscriptionGroupOutcome;
  return 'SubscriptionGroupOutcome(group: ${_this.group}, attempts: ${_this.attempts}, failure: ${_this.failure})';
}


}

/// @nodoc
abstract mixin class $SubscriptionGroupOutcomeCopyWith<$Res>  {
  factory $SubscriptionGroupOutcomeCopyWith(SubscriptionGroupOutcome value, $Res Function(SubscriptionGroupOutcome) _then) = _$SubscriptionGroupOutcomeCopyWithImpl;
@useResult
$Res call({
 String group, int attempts, int failure
});




}
/// @nodoc
class _$SubscriptionGroupOutcomeCopyWithImpl<$Res>
    implements $SubscriptionGroupOutcomeCopyWith<$Res> {
  _$SubscriptionGroupOutcomeCopyWithImpl(this._self, this._then);

  final SubscriptionGroupOutcome _self;
  final $Res Function(SubscriptionGroupOutcome) _then;

/// Create a copy of SubscriptionGroupOutcome
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? group = null,Object? attempts = null,Object? failure = null,}) {
  return _then(SubscriptionGroupOutcome(
group: null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as String,attempts: null == attempts ? _self.attempts : attempts // ignore: cast_nullable_to_non_nullable
as int,failure: null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SubscriptionGroupOutcome].
extension SubscriptionGroupOutcomePatterns on SubscriptionGroupOutcome {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubscriptionGroupOutcome value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubscriptionGroupOutcome() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubscriptionGroupOutcome value)  $default,){
final _that = this;
switch (_that) {
case _SubscriptionGroupOutcome():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubscriptionGroupOutcome value)?  $default,){
final _that = this;
switch (_that) {
case _SubscriptionGroupOutcome() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String group,  int attempts,  int failure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubscriptionGroupOutcome() when $default != null:
return $default(_that.group,_that.attempts,_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String group,  int attempts,  int failure)  $default,) {final _that = this;
switch (_that) {
case _SubscriptionGroupOutcome():
return $default(_that.group,_that.attempts,_that.failure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String group,  int attempts,  int failure)?  $default,) {final _that = this;
switch (_that) {
case _SubscriptionGroupOutcome() when $default != null:
return $default(_that.group,_that.attempts,_that.failure);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubscriptionGroupOutcome implements SubscriptionGroupOutcome {
  const _SubscriptionGroupOutcome({this.group = '', this.attempts = 0, this.failure = 0});
  factory _SubscriptionGroupOutcome.fromJson(Map<String, dynamic> json) => _$SubscriptionGroupOutcomeFromJson(json);

@override@JsonKey() final  String group;
@override@JsonKey() final  int attempts;
@override@JsonKey() final  int failure;

/// Create a copy of SubscriptionGroupOutcome
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubscriptionGroupOutcomeCopyWith<_SubscriptionGroupOutcome> get copyWith => __$SubscriptionGroupOutcomeCopyWithImpl<_SubscriptionGroupOutcome>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubscriptionGroupOutcomeToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubscriptionGroupOutcome&&(identical(other.group, group) || other.group == group)&&(identical(other.attempts, attempts) || other.attempts == attempts)&&(identical(other.failure, failure) || other.failure == failure));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,group,attempts,failure);
}

@override
String toString() {
    return 'SubscriptionGroupOutcome(group: $group, attempts: $attempts, failure: $failure)';
}


}

/// @nodoc
abstract mixin class _$SubscriptionGroupOutcomeCopyWith<$Res> implements $SubscriptionGroupOutcomeCopyWith<$Res> {
  factory _$SubscriptionGroupOutcomeCopyWith(_SubscriptionGroupOutcome value, $Res Function(_SubscriptionGroupOutcome) _then) = __$SubscriptionGroupOutcomeCopyWithImpl;
@override @useResult
$Res call({
 String group, int attempts, int failure
});




}
/// @nodoc
class __$SubscriptionGroupOutcomeCopyWithImpl<$Res>
    implements _$SubscriptionGroupOutcomeCopyWith<$Res> {
  __$SubscriptionGroupOutcomeCopyWithImpl(this._self, this._then);

  final _SubscriptionGroupOutcome _self;
  final $Res Function(_SubscriptionGroupOutcome) _then;

/// Create a copy of SubscriptionGroupOutcome
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? group = null,Object? attempts = null,Object? failure = null,}) {
  return _then(_SubscriptionGroupOutcome(
group: null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as String,attempts: null == attempts ? _self.attempts : attempts // ignore: cast_nullable_to_non_nullable
as int,failure: null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$SubscriptionClassCount {

@JsonKey(name: 'class') String get errorClass; int get count;
/// Create a copy of SubscriptionClassCount
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubscriptionClassCountCopyWith<SubscriptionClassCount> get copyWith => _$SubscriptionClassCountCopyWithImpl<SubscriptionClassCount>(this as SubscriptionClassCount, _$identity);

  /// Serializes this SubscriptionClassCount to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SubscriptionClassCount;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubscriptionClassCount&&(identical(other.errorClass, _this.errorClass) || other.errorClass == _this.errorClass)&&(identical(other.count, _this.count) || other.count == _this.count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SubscriptionClassCount;
  return Object.hash(runtimeType,_this.errorClass,_this.count);
}

@override
String toString() {
  final _this = this as SubscriptionClassCount;
  return 'SubscriptionClassCount(errorClass: ${_this.errorClass}, count: ${_this.count})';
}


}

/// @nodoc
abstract mixin class $SubscriptionClassCountCopyWith<$Res>  {
  factory $SubscriptionClassCountCopyWith(SubscriptionClassCount value, $Res Function(SubscriptionClassCount) _then) = _$SubscriptionClassCountCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'class') String errorClass, int count
});




}
/// @nodoc
class _$SubscriptionClassCountCopyWithImpl<$Res>
    implements $SubscriptionClassCountCopyWith<$Res> {
  _$SubscriptionClassCountCopyWithImpl(this._self, this._then);

  final SubscriptionClassCount _self;
  final $Res Function(SubscriptionClassCount) _then;

/// Create a copy of SubscriptionClassCount
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? errorClass = null,Object? count = null,}) {
  return _then(SubscriptionClassCount(
errorClass: null == errorClass ? _self.errorClass : errorClass // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SubscriptionClassCount].
extension SubscriptionClassCountPatterns on SubscriptionClassCount {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubscriptionClassCount value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubscriptionClassCount() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubscriptionClassCount value)  $default,){
final _that = this;
switch (_that) {
case _SubscriptionClassCount():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubscriptionClassCount value)?  $default,){
final _that = this;
switch (_that) {
case _SubscriptionClassCount() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'class')  String errorClass,  int count)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubscriptionClassCount() when $default != null:
return $default(_that.errorClass,_that.count);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'class')  String errorClass,  int count)  $default,) {final _that = this;
switch (_that) {
case _SubscriptionClassCount():
return $default(_that.errorClass,_that.count);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'class')  String errorClass,  int count)?  $default,) {final _that = this;
switch (_that) {
case _SubscriptionClassCount() when $default != null:
return $default(_that.errorClass,_that.count);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubscriptionClassCount implements SubscriptionClassCount {
  const _SubscriptionClassCount({@JsonKey(name: 'class') this.errorClass = '', this.count = 0});
  factory _SubscriptionClassCount.fromJson(Map<String, dynamic> json) => _$SubscriptionClassCountFromJson(json);

@override@JsonKey(name: 'class') final  String errorClass;
@override@JsonKey() final  int count;

/// Create a copy of SubscriptionClassCount
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubscriptionClassCountCopyWith<_SubscriptionClassCount> get copyWith => __$SubscriptionClassCountCopyWithImpl<_SubscriptionClassCount>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubscriptionClassCountToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubscriptionClassCount&&(identical(other.errorClass, errorClass) || other.errorClass == errorClass)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,errorClass,count);
}

@override
String toString() {
    return 'SubscriptionClassCount(errorClass: $errorClass, count: $count)';
}


}

/// @nodoc
abstract mixin class _$SubscriptionClassCountCopyWith<$Res> implements $SubscriptionClassCountCopyWith<$Res> {
  factory _$SubscriptionClassCountCopyWith(_SubscriptionClassCount value, $Res Function(_SubscriptionClassCount) _then) = __$SubscriptionClassCountCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'class') String errorClass, int count
});




}
/// @nodoc
class __$SubscriptionClassCountCopyWithImpl<$Res>
    implements _$SubscriptionClassCountCopyWith<$Res> {
  __$SubscriptionClassCountCopyWithImpl(this._self, this._then);

  final _SubscriptionClassCount _self;
  final $Res Function(_SubscriptionClassCount) _then;

/// Create a copy of SubscriptionClassCount
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? errorClass = null,Object? count = null,}) {
  return _then(_SubscriptionClassCount(
errorClass: null == errorClass ? _self.errorClass : errorClass // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$SubscriptionDialReport {

 int get attempts; int get success; int get failure; List<SubscriptionOutcome> get byTransport; List<SubscriptionOutcome> get byStage; List<SubscriptionClassCount> get byErrorClass; List<SubscriptionOutcome> get byProtocol; List<SubscriptionGroupOutcome> get byGroup; List<SubscriptionOutcome> get byEgress;
/// Create a copy of SubscriptionDialReport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubscriptionDialReportCopyWith<SubscriptionDialReport> get copyWith => _$SubscriptionDialReportCopyWithImpl<SubscriptionDialReport>(this as SubscriptionDialReport, _$identity);

  /// Serializes this SubscriptionDialReport to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SubscriptionDialReport;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubscriptionDialReport&&(identical(other.attempts, _this.attempts) || other.attempts == _this.attempts)&&(identical(other.success, _this.success) || other.success == _this.success)&&(identical(other.failure, _this.failure) || other.failure == _this.failure)&&const DeepCollectionEquality().equals(other.byTransport, _this.byTransport)&&const DeepCollectionEquality().equals(other.byStage, _this.byStage)&&const DeepCollectionEquality().equals(other.byErrorClass, _this.byErrorClass)&&const DeepCollectionEquality().equals(other.byProtocol, _this.byProtocol)&&const DeepCollectionEquality().equals(other.byGroup, _this.byGroup)&&const DeepCollectionEquality().equals(other.byEgress, _this.byEgress));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SubscriptionDialReport;
  return Object.hash(runtimeType,_this.attempts,_this.success,_this.failure,const DeepCollectionEquality().hash(_this.byTransport),const DeepCollectionEquality().hash(_this.byStage),const DeepCollectionEquality().hash(_this.byErrorClass),const DeepCollectionEquality().hash(_this.byProtocol),const DeepCollectionEquality().hash(_this.byGroup),const DeepCollectionEquality().hash(_this.byEgress));
}

@override
String toString() {
  final _this = this as SubscriptionDialReport;
  return 'SubscriptionDialReport(attempts: ${_this.attempts}, success: ${_this.success}, failure: ${_this.failure}, byTransport: ${_this.byTransport}, byStage: ${_this.byStage}, byErrorClass: ${_this.byErrorClass}, byProtocol: ${_this.byProtocol}, byGroup: ${_this.byGroup}, byEgress: ${_this.byEgress})';
}


}

/// @nodoc
abstract mixin class $SubscriptionDialReportCopyWith<$Res>  {
  factory $SubscriptionDialReportCopyWith(SubscriptionDialReport value, $Res Function(SubscriptionDialReport) _then) = _$SubscriptionDialReportCopyWithImpl;
@useResult
$Res call({
 int attempts, int success, int failure, List<SubscriptionOutcome> byTransport, List<SubscriptionOutcome> byStage, List<SubscriptionClassCount> byErrorClass, List<SubscriptionOutcome> byProtocol, List<SubscriptionGroupOutcome> byGroup, List<SubscriptionOutcome> byEgress
});




}
/// @nodoc
class _$SubscriptionDialReportCopyWithImpl<$Res>
    implements $SubscriptionDialReportCopyWith<$Res> {
  _$SubscriptionDialReportCopyWithImpl(this._self, this._then);

  final SubscriptionDialReport _self;
  final $Res Function(SubscriptionDialReport) _then;

/// Create a copy of SubscriptionDialReport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? attempts = null,Object? success = null,Object? failure = null,Object? byTransport = null,Object? byStage = null,Object? byErrorClass = null,Object? byProtocol = null,Object? byGroup = null,Object? byEgress = null,}) {
  return _then(SubscriptionDialReport(
attempts: null == attempts ? _self.attempts : attempts // ignore: cast_nullable_to_non_nullable
as int,success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as int,failure: null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as int,byTransport: null == byTransport ? _self.byTransport : byTransport // ignore: cast_nullable_to_non_nullable
as List<SubscriptionOutcome>,byStage: null == byStage ? _self.byStage : byStage // ignore: cast_nullable_to_non_nullable
as List<SubscriptionOutcome>,byErrorClass: null == byErrorClass ? _self.byErrorClass : byErrorClass // ignore: cast_nullable_to_non_nullable
as List<SubscriptionClassCount>,byProtocol: null == byProtocol ? _self.byProtocol : byProtocol // ignore: cast_nullable_to_non_nullable
as List<SubscriptionOutcome>,byGroup: null == byGroup ? _self.byGroup : byGroup // ignore: cast_nullable_to_non_nullable
as List<SubscriptionGroupOutcome>,byEgress: null == byEgress ? _self.byEgress : byEgress // ignore: cast_nullable_to_non_nullable
as List<SubscriptionOutcome>,
  ));
}

}


/// Adds pattern-matching-related methods to [SubscriptionDialReport].
extension SubscriptionDialReportPatterns on SubscriptionDialReport {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubscriptionDialReport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubscriptionDialReport() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubscriptionDialReport value)  $default,){
final _that = this;
switch (_that) {
case _SubscriptionDialReport():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubscriptionDialReport value)?  $default,){
final _that = this;
switch (_that) {
case _SubscriptionDialReport() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int attempts,  int success,  int failure,  List<SubscriptionOutcome> byTransport,  List<SubscriptionOutcome> byStage,  List<SubscriptionClassCount> byErrorClass,  List<SubscriptionOutcome> byProtocol,  List<SubscriptionGroupOutcome> byGroup,  List<SubscriptionOutcome> byEgress)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubscriptionDialReport() when $default != null:
return $default(_that.attempts,_that.success,_that.failure,_that.byTransport,_that.byStage,_that.byErrorClass,_that.byProtocol,_that.byGroup,_that.byEgress);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int attempts,  int success,  int failure,  List<SubscriptionOutcome> byTransport,  List<SubscriptionOutcome> byStage,  List<SubscriptionClassCount> byErrorClass,  List<SubscriptionOutcome> byProtocol,  List<SubscriptionGroupOutcome> byGroup,  List<SubscriptionOutcome> byEgress)  $default,) {final _that = this;
switch (_that) {
case _SubscriptionDialReport():
return $default(_that.attempts,_that.success,_that.failure,_that.byTransport,_that.byStage,_that.byErrorClass,_that.byProtocol,_that.byGroup,_that.byEgress);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int attempts,  int success,  int failure,  List<SubscriptionOutcome> byTransport,  List<SubscriptionOutcome> byStage,  List<SubscriptionClassCount> byErrorClass,  List<SubscriptionOutcome> byProtocol,  List<SubscriptionGroupOutcome> byGroup,  List<SubscriptionOutcome> byEgress)?  $default,) {final _that = this;
switch (_that) {
case _SubscriptionDialReport() when $default != null:
return $default(_that.attempts,_that.success,_that.failure,_that.byTransport,_that.byStage,_that.byErrorClass,_that.byProtocol,_that.byGroup,_that.byEgress);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubscriptionDialReport implements SubscriptionDialReport {
  const _SubscriptionDialReport({this.attempts = 0, this.success = 0, this.failure = 0,  List<SubscriptionOutcome> byTransport = const [],  List<SubscriptionOutcome> byStage = const [],  List<SubscriptionClassCount> byErrorClass = const [],  List<SubscriptionOutcome> byProtocol = const [],  List<SubscriptionGroupOutcome> byGroup = const [],  List<SubscriptionOutcome> byEgress = const []}): _byTransport = byTransport,_byStage = byStage,_byErrorClass = byErrorClass,_byProtocol = byProtocol,_byGroup = byGroup,_byEgress = byEgress;
  factory _SubscriptionDialReport.fromJson(Map<String, dynamic> json) => _$SubscriptionDialReportFromJson(json);

@override@JsonKey() final  int attempts;
@override@JsonKey() final  int success;
@override@JsonKey() final  int failure;
 final  List<SubscriptionOutcome> _byTransport;
@override@JsonKey() List<SubscriptionOutcome> get byTransport {
  if (_byTransport is EqualUnmodifiableListView) return _byTransport;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_byTransport);
}

 final  List<SubscriptionOutcome> _byStage;
@override@JsonKey() List<SubscriptionOutcome> get byStage {
  if (_byStage is EqualUnmodifiableListView) return _byStage;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_byStage);
}

 final  List<SubscriptionClassCount> _byErrorClass;
@override@JsonKey() List<SubscriptionClassCount> get byErrorClass {
  if (_byErrorClass is EqualUnmodifiableListView) return _byErrorClass;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_byErrorClass);
}

 final  List<SubscriptionOutcome> _byProtocol;
@override@JsonKey() List<SubscriptionOutcome> get byProtocol {
  if (_byProtocol is EqualUnmodifiableListView) return _byProtocol;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_byProtocol);
}

 final  List<SubscriptionGroupOutcome> _byGroup;
@override@JsonKey() List<SubscriptionGroupOutcome> get byGroup {
  if (_byGroup is EqualUnmodifiableListView) return _byGroup;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_byGroup);
}

 final  List<SubscriptionOutcome> _byEgress;
@override@JsonKey() List<SubscriptionOutcome> get byEgress {
  if (_byEgress is EqualUnmodifiableListView) return _byEgress;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_byEgress);
}


/// Create a copy of SubscriptionDialReport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubscriptionDialReportCopyWith<_SubscriptionDialReport> get copyWith => __$SubscriptionDialReportCopyWithImpl<_SubscriptionDialReport>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubscriptionDialReportToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubscriptionDialReport&&(identical(other.attempts, attempts) || other.attempts == attempts)&&(identical(other.success, success) || other.success == success)&&(identical(other.failure, failure) || other.failure == failure)&&const DeepCollectionEquality().equals(other.byTransport, _byTransport)&&const DeepCollectionEquality().equals(other.byStage, _byStage)&&const DeepCollectionEquality().equals(other.byErrorClass, _byErrorClass)&&const DeepCollectionEquality().equals(other.byProtocol, _byProtocol)&&const DeepCollectionEquality().equals(other.byGroup, _byGroup)&&const DeepCollectionEquality().equals(other.byEgress, _byEgress));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,attempts,success,failure,const DeepCollectionEquality().hash(_byTransport),const DeepCollectionEquality().hash(_byStage),const DeepCollectionEquality().hash(_byErrorClass),const DeepCollectionEquality().hash(_byProtocol),const DeepCollectionEquality().hash(_byGroup),const DeepCollectionEquality().hash(_byEgress));
}

@override
String toString() {
    return 'SubscriptionDialReport(attempts: $attempts, success: $success, failure: $failure, byTransport: $byTransport, byStage: $byStage, byErrorClass: $byErrorClass, byProtocol: $byProtocol, byGroup: $byGroup, byEgress: $byEgress)';
}


}

/// @nodoc
abstract mixin class _$SubscriptionDialReportCopyWith<$Res> implements $SubscriptionDialReportCopyWith<$Res> {
  factory _$SubscriptionDialReportCopyWith(_SubscriptionDialReport value, $Res Function(_SubscriptionDialReport) _then) = __$SubscriptionDialReportCopyWithImpl;
@override @useResult
$Res call({
 int attempts, int success, int failure, List<SubscriptionOutcome> byTransport, List<SubscriptionOutcome> byStage, List<SubscriptionClassCount> byErrorClass, List<SubscriptionOutcome> byProtocol, List<SubscriptionGroupOutcome> byGroup, List<SubscriptionOutcome> byEgress
});




}
/// @nodoc
class __$SubscriptionDialReportCopyWithImpl<$Res>
    implements _$SubscriptionDialReportCopyWith<$Res> {
  __$SubscriptionDialReportCopyWithImpl(this._self, this._then);

  final _SubscriptionDialReport _self;
  final $Res Function(_SubscriptionDialReport) _then;

/// Create a copy of SubscriptionDialReport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? attempts = null,Object? success = null,Object? failure = null,Object? byTransport = null,Object? byStage = null,Object? byErrorClass = null,Object? byProtocol = null,Object? byGroup = null,Object? byEgress = null,}) {
  return _then(_SubscriptionDialReport(
attempts: null == attempts ? _self.attempts : attempts // ignore: cast_nullable_to_non_nullable
as int,success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as int,failure: null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as int,byTransport: null == byTransport ? _self._byTransport : byTransport // ignore: cast_nullable_to_non_nullable
as List<SubscriptionOutcome>,byStage: null == byStage ? _self._byStage : byStage // ignore: cast_nullable_to_non_nullable
as List<SubscriptionOutcome>,byErrorClass: null == byErrorClass ? _self._byErrorClass : byErrorClass // ignore: cast_nullable_to_non_nullable
as List<SubscriptionClassCount>,byProtocol: null == byProtocol ? _self._byProtocol : byProtocol // ignore: cast_nullable_to_non_nullable
as List<SubscriptionOutcome>,byGroup: null == byGroup ? _self._byGroup : byGroup // ignore: cast_nullable_to_non_nullable
as List<SubscriptionGroupOutcome>,byEgress: null == byEgress ? _self._byEgress : byEgress // ignore: cast_nullable_to_non_nullable
as List<SubscriptionOutcome>,
  ));
}


}


/// @nodoc
mixin _$SubscriptionNodeReport {

 String get alias; String get protocol; String get transport; String get egressCountry; List<String> get groups; int get positionHint; int get attempts; int get failures; int get successes; int get failStreak; String get dominantClass; int get delayBucketMs;
/// Create a copy of SubscriptionNodeReport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubscriptionNodeReportCopyWith<SubscriptionNodeReport> get copyWith => _$SubscriptionNodeReportCopyWithImpl<SubscriptionNodeReport>(this as SubscriptionNodeReport, _$identity);

  /// Serializes this SubscriptionNodeReport to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SubscriptionNodeReport;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubscriptionNodeReport&&(identical(other.alias, _this.alias) || other.alias == _this.alias)&&(identical(other.protocol, _this.protocol) || other.protocol == _this.protocol)&&(identical(other.transport, _this.transport) || other.transport == _this.transport)&&(identical(other.egressCountry, _this.egressCountry) || other.egressCountry == _this.egressCountry)&&const DeepCollectionEquality().equals(other.groups, _this.groups)&&(identical(other.positionHint, _this.positionHint) || other.positionHint == _this.positionHint)&&(identical(other.attempts, _this.attempts) || other.attempts == _this.attempts)&&(identical(other.failures, _this.failures) || other.failures == _this.failures)&&(identical(other.successes, _this.successes) || other.successes == _this.successes)&&(identical(other.failStreak, _this.failStreak) || other.failStreak == _this.failStreak)&&(identical(other.dominantClass, _this.dominantClass) || other.dominantClass == _this.dominantClass)&&(identical(other.delayBucketMs, _this.delayBucketMs) || other.delayBucketMs == _this.delayBucketMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SubscriptionNodeReport;
  return Object.hash(runtimeType,_this.alias,_this.protocol,_this.transport,_this.egressCountry,const DeepCollectionEquality().hash(_this.groups),_this.positionHint,_this.attempts,_this.failures,_this.successes,_this.failStreak,_this.dominantClass,_this.delayBucketMs);
}

@override
String toString() {
  final _this = this as SubscriptionNodeReport;
  return 'SubscriptionNodeReport(alias: ${_this.alias}, protocol: ${_this.protocol}, transport: ${_this.transport}, egressCountry: ${_this.egressCountry}, groups: ${_this.groups}, positionHint: ${_this.positionHint}, attempts: ${_this.attempts}, failures: ${_this.failures}, successes: ${_this.successes}, failStreak: ${_this.failStreak}, dominantClass: ${_this.dominantClass}, delayBucketMs: ${_this.delayBucketMs})';
}


}

/// @nodoc
abstract mixin class $SubscriptionNodeReportCopyWith<$Res>  {
  factory $SubscriptionNodeReportCopyWith(SubscriptionNodeReport value, $Res Function(SubscriptionNodeReport) _then) = _$SubscriptionNodeReportCopyWithImpl;
@useResult
$Res call({
 String alias, String protocol, String transport, String egressCountry, List<String> groups, int positionHint, int attempts, int failures, int successes, int failStreak, String dominantClass, int delayBucketMs
});




}
/// @nodoc
class _$SubscriptionNodeReportCopyWithImpl<$Res>
    implements $SubscriptionNodeReportCopyWith<$Res> {
  _$SubscriptionNodeReportCopyWithImpl(this._self, this._then);

  final SubscriptionNodeReport _self;
  final $Res Function(SubscriptionNodeReport) _then;

/// Create a copy of SubscriptionNodeReport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? alias = null,Object? protocol = null,Object? transport = null,Object? egressCountry = null,Object? groups = null,Object? positionHint = null,Object? attempts = null,Object? failures = null,Object? successes = null,Object? failStreak = null,Object? dominantClass = null,Object? delayBucketMs = null,}) {
  return _then(SubscriptionNodeReport(
alias: null == alias ? _self.alias : alias // ignore: cast_nullable_to_non_nullable
as String,protocol: null == protocol ? _self.protocol : protocol // ignore: cast_nullable_to_non_nullable
as String,transport: null == transport ? _self.transport : transport // ignore: cast_nullable_to_non_nullable
as String,egressCountry: null == egressCountry ? _self.egressCountry : egressCountry // ignore: cast_nullable_to_non_nullable
as String,groups: null == groups ? _self.groups : groups // ignore: cast_nullable_to_non_nullable
as List<String>,positionHint: null == positionHint ? _self.positionHint : positionHint // ignore: cast_nullable_to_non_nullable
as int,attempts: null == attempts ? _self.attempts : attempts // ignore: cast_nullable_to_non_nullable
as int,failures: null == failures ? _self.failures : failures // ignore: cast_nullable_to_non_nullable
as int,successes: null == successes ? _self.successes : successes // ignore: cast_nullable_to_non_nullable
as int,failStreak: null == failStreak ? _self.failStreak : failStreak // ignore: cast_nullable_to_non_nullable
as int,dominantClass: null == dominantClass ? _self.dominantClass : dominantClass // ignore: cast_nullable_to_non_nullable
as String,delayBucketMs: null == delayBucketMs ? _self.delayBucketMs : delayBucketMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SubscriptionNodeReport].
extension SubscriptionNodeReportPatterns on SubscriptionNodeReport {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubscriptionNodeReport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubscriptionNodeReport() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubscriptionNodeReport value)  $default,){
final _that = this;
switch (_that) {
case _SubscriptionNodeReport():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubscriptionNodeReport value)?  $default,){
final _that = this;
switch (_that) {
case _SubscriptionNodeReport() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String alias,  String protocol,  String transport,  String egressCountry,  List<String> groups,  int positionHint,  int attempts,  int failures,  int successes,  int failStreak,  String dominantClass,  int delayBucketMs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubscriptionNodeReport() when $default != null:
return $default(_that.alias,_that.protocol,_that.transport,_that.egressCountry,_that.groups,_that.positionHint,_that.attempts,_that.failures,_that.successes,_that.failStreak,_that.dominantClass,_that.delayBucketMs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String alias,  String protocol,  String transport,  String egressCountry,  List<String> groups,  int positionHint,  int attempts,  int failures,  int successes,  int failStreak,  String dominantClass,  int delayBucketMs)  $default,) {final _that = this;
switch (_that) {
case _SubscriptionNodeReport():
return $default(_that.alias,_that.protocol,_that.transport,_that.egressCountry,_that.groups,_that.positionHint,_that.attempts,_that.failures,_that.successes,_that.failStreak,_that.dominantClass,_that.delayBucketMs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String alias,  String protocol,  String transport,  String egressCountry,  List<String> groups,  int positionHint,  int attempts,  int failures,  int successes,  int failStreak,  String dominantClass,  int delayBucketMs)?  $default,) {final _that = this;
switch (_that) {
case _SubscriptionNodeReport() when $default != null:
return $default(_that.alias,_that.protocol,_that.transport,_that.egressCountry,_that.groups,_that.positionHint,_that.attempts,_that.failures,_that.successes,_that.failStreak,_that.dominantClass,_that.delayBucketMs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubscriptionNodeReport implements SubscriptionNodeReport {
  const _SubscriptionNodeReport({this.alias = '', this.protocol = '', this.transport = '', this.egressCountry = '',  List<String> groups = const [], this.positionHint = 0, this.attempts = 0, this.failures = 0, this.successes = 0, this.failStreak = 0, this.dominantClass = '', this.delayBucketMs = 0}): _groups = groups;
  factory _SubscriptionNodeReport.fromJson(Map<String, dynamic> json) => _$SubscriptionNodeReportFromJson(json);

@override@JsonKey() final  String alias;
@override@JsonKey() final  String protocol;
@override@JsonKey() final  String transport;
@override@JsonKey() final  String egressCountry;
 final  List<String> _groups;
@override@JsonKey() List<String> get groups {
  if (_groups is EqualUnmodifiableListView) return _groups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_groups);
}

@override@JsonKey() final  int positionHint;
@override@JsonKey() final  int attempts;
@override@JsonKey() final  int failures;
@override@JsonKey() final  int successes;
@override@JsonKey() final  int failStreak;
@override@JsonKey() final  String dominantClass;
@override@JsonKey() final  int delayBucketMs;

/// Create a copy of SubscriptionNodeReport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubscriptionNodeReportCopyWith<_SubscriptionNodeReport> get copyWith => __$SubscriptionNodeReportCopyWithImpl<_SubscriptionNodeReport>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubscriptionNodeReportToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubscriptionNodeReport&&(identical(other.alias, alias) || other.alias == alias)&&(identical(other.protocol, protocol) || other.protocol == protocol)&&(identical(other.transport, transport) || other.transport == transport)&&(identical(other.egressCountry, egressCountry) || other.egressCountry == egressCountry)&&const DeepCollectionEquality().equals(other.groups, _groups)&&(identical(other.positionHint, positionHint) || other.positionHint == positionHint)&&(identical(other.attempts, attempts) || other.attempts == attempts)&&(identical(other.failures, failures) || other.failures == failures)&&(identical(other.successes, successes) || other.successes == successes)&&(identical(other.failStreak, failStreak) || other.failStreak == failStreak)&&(identical(other.dominantClass, dominantClass) || other.dominantClass == dominantClass)&&(identical(other.delayBucketMs, delayBucketMs) || other.delayBucketMs == delayBucketMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,alias,protocol,transport,egressCountry,const DeepCollectionEquality().hash(_groups),positionHint,attempts,failures,successes,failStreak,dominantClass,delayBucketMs);
}

@override
String toString() {
    return 'SubscriptionNodeReport(alias: $alias, protocol: $protocol, transport: $transport, egressCountry: $egressCountry, groups: $groups, positionHint: $positionHint, attempts: $attempts, failures: $failures, successes: $successes, failStreak: $failStreak, dominantClass: $dominantClass, delayBucketMs: $delayBucketMs)';
}


}

/// @nodoc
abstract mixin class _$SubscriptionNodeReportCopyWith<$Res> implements $SubscriptionNodeReportCopyWith<$Res> {
  factory _$SubscriptionNodeReportCopyWith(_SubscriptionNodeReport value, $Res Function(_SubscriptionNodeReport) _then) = __$SubscriptionNodeReportCopyWithImpl;
@override @useResult
$Res call({
 String alias, String protocol, String transport, String egressCountry, List<String> groups, int positionHint, int attempts, int failures, int successes, int failStreak, String dominantClass, int delayBucketMs
});




}
/// @nodoc
class __$SubscriptionNodeReportCopyWithImpl<$Res>
    implements _$SubscriptionNodeReportCopyWith<$Res> {
  __$SubscriptionNodeReportCopyWithImpl(this._self, this._then);

  final _SubscriptionNodeReport _self;
  final $Res Function(_SubscriptionNodeReport) _then;

/// Create a copy of SubscriptionNodeReport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? alias = null,Object? protocol = null,Object? transport = null,Object? egressCountry = null,Object? groups = null,Object? positionHint = null,Object? attempts = null,Object? failures = null,Object? successes = null,Object? failStreak = null,Object? dominantClass = null,Object? delayBucketMs = null,}) {
  return _then(_SubscriptionNodeReport(
alias: null == alias ? _self.alias : alias // ignore: cast_nullable_to_non_nullable
as String,protocol: null == protocol ? _self.protocol : protocol // ignore: cast_nullable_to_non_nullable
as String,transport: null == transport ? _self.transport : transport // ignore: cast_nullable_to_non_nullable
as String,egressCountry: null == egressCountry ? _self.egressCountry : egressCountry // ignore: cast_nullable_to_non_nullable
as String,groups: null == groups ? _self._groups : groups // ignore: cast_nullable_to_non_nullable
as List<String>,positionHint: null == positionHint ? _self.positionHint : positionHint // ignore: cast_nullable_to_non_nullable
as int,attempts: null == attempts ? _self.attempts : attempts // ignore: cast_nullable_to_non_nullable
as int,failures: null == failures ? _self.failures : failures // ignore: cast_nullable_to_non_nullable
as int,successes: null == successes ? _self.successes : successes // ignore: cast_nullable_to_non_nullable
as int,failStreak: null == failStreak ? _self.failStreak : failStreak // ignore: cast_nullable_to_non_nullable
as int,dominantClass: null == dominantClass ? _self.dominantClass : dominantClass // ignore: cast_nullable_to_non_nullable
as String,delayBucketMs: null == delayBucketMs ? _self.delayBucketMs : delayBucketMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$SubscriptionReport {

 SubscriptionVerdict? get verdict; int get schemaVersion; int get generatedAt; String get coreVersion; String get appVersion; String get platform; String get architecture; int get windowStart; int get windowEnd; String get terrain; String get env; List<String> get presets; int get droppedEvents; int get configNodeCount; int get observedNodeCount; SubscriptionUpdateReport? get subscriptionUpdate; SubscriptionDialReport get runtimeDial; List<SubscriptionNodeReport> get nodes;
/// Create a copy of SubscriptionReport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubscriptionReportCopyWith<SubscriptionReport> get copyWith => _$SubscriptionReportCopyWithImpl<SubscriptionReport>(this as SubscriptionReport, _$identity);

  /// Serializes this SubscriptionReport to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SubscriptionReport;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubscriptionReport&&(identical(other.verdict, _this.verdict) || other.verdict == _this.verdict)&&(identical(other.schemaVersion, _this.schemaVersion) || other.schemaVersion == _this.schemaVersion)&&(identical(other.generatedAt, _this.generatedAt) || other.generatedAt == _this.generatedAt)&&(identical(other.coreVersion, _this.coreVersion) || other.coreVersion == _this.coreVersion)&&(identical(other.appVersion, _this.appVersion) || other.appVersion == _this.appVersion)&&(identical(other.platform, _this.platform) || other.platform == _this.platform)&&(identical(other.architecture, _this.architecture) || other.architecture == _this.architecture)&&(identical(other.windowStart, _this.windowStart) || other.windowStart == _this.windowStart)&&(identical(other.windowEnd, _this.windowEnd) || other.windowEnd == _this.windowEnd)&&(identical(other.terrain, _this.terrain) || other.terrain == _this.terrain)&&(identical(other.env, _this.env) || other.env == _this.env)&&const DeepCollectionEquality().equals(other.presets, _this.presets)&&(identical(other.droppedEvents, _this.droppedEvents) || other.droppedEvents == _this.droppedEvents)&&(identical(other.configNodeCount, _this.configNodeCount) || other.configNodeCount == _this.configNodeCount)&&(identical(other.observedNodeCount, _this.observedNodeCount) || other.observedNodeCount == _this.observedNodeCount)&&(identical(other.subscriptionUpdate, _this.subscriptionUpdate) || other.subscriptionUpdate == _this.subscriptionUpdate)&&(identical(other.runtimeDial, _this.runtimeDial) || other.runtimeDial == _this.runtimeDial)&&const DeepCollectionEquality().equals(other.nodes, _this.nodes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SubscriptionReport;
  return Object.hash(runtimeType,_this.verdict,_this.schemaVersion,_this.generatedAt,_this.coreVersion,_this.appVersion,_this.platform,_this.architecture,_this.windowStart,_this.windowEnd,_this.terrain,_this.env,const DeepCollectionEquality().hash(_this.presets),_this.droppedEvents,_this.configNodeCount,_this.observedNodeCount,_this.subscriptionUpdate,_this.runtimeDial,const DeepCollectionEquality().hash(_this.nodes));
}

@override
String toString() {
  final _this = this as SubscriptionReport;
  return 'SubscriptionReport(verdict: ${_this.verdict}, schemaVersion: ${_this.schemaVersion}, generatedAt: ${_this.generatedAt}, coreVersion: ${_this.coreVersion}, appVersion: ${_this.appVersion}, platform: ${_this.platform}, architecture: ${_this.architecture}, windowStart: ${_this.windowStart}, windowEnd: ${_this.windowEnd}, terrain: ${_this.terrain}, env: ${_this.env}, presets: ${_this.presets}, droppedEvents: ${_this.droppedEvents}, configNodeCount: ${_this.configNodeCount}, observedNodeCount: ${_this.observedNodeCount}, subscriptionUpdate: ${_this.subscriptionUpdate}, runtimeDial: ${_this.runtimeDial}, nodes: ${_this.nodes})';
}


}

/// @nodoc
abstract mixin class $SubscriptionReportCopyWith<$Res>  {
  factory $SubscriptionReportCopyWith(SubscriptionReport value, $Res Function(SubscriptionReport) _then) = _$SubscriptionReportCopyWithImpl;
@useResult
$Res call({
 SubscriptionVerdict? verdict, int schemaVersion, int generatedAt, String coreVersion, String appVersion, String platform, String architecture, int windowStart, int windowEnd, String terrain, String env, List<String> presets, int droppedEvents, int configNodeCount, int observedNodeCount, SubscriptionUpdateReport? subscriptionUpdate, SubscriptionDialReport runtimeDial, List<SubscriptionNodeReport> nodes
});


$SubscriptionVerdictCopyWith<$Res>? get verdict;$SubscriptionUpdateReportCopyWith<$Res>? get subscriptionUpdate;$SubscriptionDialReportCopyWith<$Res> get runtimeDial;

}
/// @nodoc
class _$SubscriptionReportCopyWithImpl<$Res>
    implements $SubscriptionReportCopyWith<$Res> {
  _$SubscriptionReportCopyWithImpl(this._self, this._then);

  final SubscriptionReport _self;
  final $Res Function(SubscriptionReport) _then;

/// Create a copy of SubscriptionReport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? verdict = freezed,Object? schemaVersion = null,Object? generatedAt = null,Object? coreVersion = null,Object? appVersion = null,Object? platform = null,Object? architecture = null,Object? windowStart = null,Object? windowEnd = null,Object? terrain = null,Object? env = null,Object? presets = null,Object? droppedEvents = null,Object? configNodeCount = null,Object? observedNodeCount = null,Object? subscriptionUpdate = freezed,Object? runtimeDial = null,Object? nodes = null,}) {
  return _then(SubscriptionReport(
verdict: freezed == verdict ? _self.verdict : verdict // ignore: cast_nullable_to_non_nullable
as SubscriptionVerdict?,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as int,coreVersion: null == coreVersion ? _self.coreVersion : coreVersion // ignore: cast_nullable_to_non_nullable
as String,appVersion: null == appVersion ? _self.appVersion : appVersion // ignore: cast_nullable_to_non_nullable
as String,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String,architecture: null == architecture ? _self.architecture : architecture // ignore: cast_nullable_to_non_nullable
as String,windowStart: null == windowStart ? _self.windowStart : windowStart // ignore: cast_nullable_to_non_nullable
as int,windowEnd: null == windowEnd ? _self.windowEnd : windowEnd // ignore: cast_nullable_to_non_nullable
as int,terrain: null == terrain ? _self.terrain : terrain // ignore: cast_nullable_to_non_nullable
as String,env: null == env ? _self.env : env // ignore: cast_nullable_to_non_nullable
as String,presets: null == presets ? _self.presets : presets // ignore: cast_nullable_to_non_nullable
as List<String>,droppedEvents: null == droppedEvents ? _self.droppedEvents : droppedEvents // ignore: cast_nullable_to_non_nullable
as int,configNodeCount: null == configNodeCount ? _self.configNodeCount : configNodeCount // ignore: cast_nullable_to_non_nullable
as int,observedNodeCount: null == observedNodeCount ? _self.observedNodeCount : observedNodeCount // ignore: cast_nullable_to_non_nullable
as int,subscriptionUpdate: freezed == subscriptionUpdate ? _self.subscriptionUpdate : subscriptionUpdate // ignore: cast_nullable_to_non_nullable
as SubscriptionUpdateReport?,runtimeDial: null == runtimeDial ? _self.runtimeDial : runtimeDial // ignore: cast_nullable_to_non_nullable
as SubscriptionDialReport,nodes: null == nodes ? _self.nodes : nodes // ignore: cast_nullable_to_non_nullable
as List<SubscriptionNodeReport>,
  ));
}
/// Create a copy of SubscriptionReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SubscriptionVerdictCopyWith<$Res>? get verdict {
    if (_self.verdict == null) {
    return null;
  }

  return $SubscriptionVerdictCopyWith<$Res>(_self.verdict!, (value) {
    return _then(_self.copyWith(verdict: value));
  });
}/// Create a copy of SubscriptionReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SubscriptionUpdateReportCopyWith<$Res>? get subscriptionUpdate {
    if (_self.subscriptionUpdate == null) {
    return null;
  }

  return $SubscriptionUpdateReportCopyWith<$Res>(_self.subscriptionUpdate!, (value) {
    return _then(_self.copyWith(subscriptionUpdate: value));
  });
}/// Create a copy of SubscriptionReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SubscriptionDialReportCopyWith<$Res> get runtimeDial {
  
  return $SubscriptionDialReportCopyWith<$Res>(_self.runtimeDial, (value) {
    return _then(_self.copyWith(runtimeDial: value));
  });
}
}


/// Adds pattern-matching-related methods to [SubscriptionReport].
extension SubscriptionReportPatterns on SubscriptionReport {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubscriptionReport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubscriptionReport() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubscriptionReport value)  $default,){
final _that = this;
switch (_that) {
case _SubscriptionReport():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubscriptionReport value)?  $default,){
final _that = this;
switch (_that) {
case _SubscriptionReport() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SubscriptionVerdict? verdict,  int schemaVersion,  int generatedAt,  String coreVersion,  String appVersion,  String platform,  String architecture,  int windowStart,  int windowEnd,  String terrain,  String env,  List<String> presets,  int droppedEvents,  int configNodeCount,  int observedNodeCount,  SubscriptionUpdateReport? subscriptionUpdate,  SubscriptionDialReport runtimeDial,  List<SubscriptionNodeReport> nodes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubscriptionReport() when $default != null:
return $default(_that.verdict,_that.schemaVersion,_that.generatedAt,_that.coreVersion,_that.appVersion,_that.platform,_that.architecture,_that.windowStart,_that.windowEnd,_that.terrain,_that.env,_that.presets,_that.droppedEvents,_that.configNodeCount,_that.observedNodeCount,_that.subscriptionUpdate,_that.runtimeDial,_that.nodes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SubscriptionVerdict? verdict,  int schemaVersion,  int generatedAt,  String coreVersion,  String appVersion,  String platform,  String architecture,  int windowStart,  int windowEnd,  String terrain,  String env,  List<String> presets,  int droppedEvents,  int configNodeCount,  int observedNodeCount,  SubscriptionUpdateReport? subscriptionUpdate,  SubscriptionDialReport runtimeDial,  List<SubscriptionNodeReport> nodes)  $default,) {final _that = this;
switch (_that) {
case _SubscriptionReport():
return $default(_that.verdict,_that.schemaVersion,_that.generatedAt,_that.coreVersion,_that.appVersion,_that.platform,_that.architecture,_that.windowStart,_that.windowEnd,_that.terrain,_that.env,_that.presets,_that.droppedEvents,_that.configNodeCount,_that.observedNodeCount,_that.subscriptionUpdate,_that.runtimeDial,_that.nodes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SubscriptionVerdict? verdict,  int schemaVersion,  int generatedAt,  String coreVersion,  String appVersion,  String platform,  String architecture,  int windowStart,  int windowEnd,  String terrain,  String env,  List<String> presets,  int droppedEvents,  int configNodeCount,  int observedNodeCount,  SubscriptionUpdateReport? subscriptionUpdate,  SubscriptionDialReport runtimeDial,  List<SubscriptionNodeReport> nodes)?  $default,) {final _that = this;
switch (_that) {
case _SubscriptionReport() when $default != null:
return $default(_that.verdict,_that.schemaVersion,_that.generatedAt,_that.coreVersion,_that.appVersion,_that.platform,_that.architecture,_that.windowStart,_that.windowEnd,_that.terrain,_that.env,_that.presets,_that.droppedEvents,_that.configNodeCount,_that.observedNodeCount,_that.subscriptionUpdate,_that.runtimeDial,_that.nodes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubscriptionReport implements SubscriptionReport {
  const _SubscriptionReport({this.verdict, this.schemaVersion = 1, this.generatedAt = 0, this.coreVersion = '', this.appVersion = '', this.platform = '', this.architecture = '', this.windowStart = 0, this.windowEnd = 0, this.terrain = '', this.env = '',  List<String> presets = const [], this.droppedEvents = 0, this.configNodeCount = 0, this.observedNodeCount = 0, this.subscriptionUpdate, this.runtimeDial = const SubscriptionDialReport(),  List<SubscriptionNodeReport> nodes = const []}): _presets = presets,_nodes = nodes;
  factory _SubscriptionReport.fromJson(Map<String, dynamic> json) => _$SubscriptionReportFromJson(json);

@override final  SubscriptionVerdict? verdict;
@override@JsonKey() final  int schemaVersion;
@override@JsonKey() final  int generatedAt;
@override@JsonKey() final  String coreVersion;
@override@JsonKey() final  String appVersion;
@override@JsonKey() final  String platform;
@override@JsonKey() final  String architecture;
@override@JsonKey() final  int windowStart;
@override@JsonKey() final  int windowEnd;
@override@JsonKey() final  String terrain;
@override@JsonKey() final  String env;
 final  List<String> _presets;
@override@JsonKey() List<String> get presets {
  if (_presets is EqualUnmodifiableListView) return _presets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_presets);
}

@override@JsonKey() final  int droppedEvents;
@override@JsonKey() final  int configNodeCount;
@override@JsonKey() final  int observedNodeCount;
@override final  SubscriptionUpdateReport? subscriptionUpdate;
@override@JsonKey() final  SubscriptionDialReport runtimeDial;
 final  List<SubscriptionNodeReport> _nodes;
@override@JsonKey() List<SubscriptionNodeReport> get nodes {
  if (_nodes is EqualUnmodifiableListView) return _nodes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_nodes);
}


/// Create a copy of SubscriptionReport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubscriptionReportCopyWith<_SubscriptionReport> get copyWith => __$SubscriptionReportCopyWithImpl<_SubscriptionReport>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubscriptionReportToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubscriptionReport&&(identical(other.verdict, verdict) || other.verdict == verdict)&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&(identical(other.coreVersion, coreVersion) || other.coreVersion == coreVersion)&&(identical(other.appVersion, appVersion) || other.appVersion == appVersion)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.architecture, architecture) || other.architecture == architecture)&&(identical(other.windowStart, windowStart) || other.windowStart == windowStart)&&(identical(other.windowEnd, windowEnd) || other.windowEnd == windowEnd)&&(identical(other.terrain, terrain) || other.terrain == terrain)&&(identical(other.env, env) || other.env == env)&&const DeepCollectionEquality().equals(other.presets, _presets)&&(identical(other.droppedEvents, droppedEvents) || other.droppedEvents == droppedEvents)&&(identical(other.configNodeCount, configNodeCount) || other.configNodeCount == configNodeCount)&&(identical(other.observedNodeCount, observedNodeCount) || other.observedNodeCount == observedNodeCount)&&(identical(other.subscriptionUpdate, subscriptionUpdate) || other.subscriptionUpdate == subscriptionUpdate)&&(identical(other.runtimeDial, runtimeDial) || other.runtimeDial == runtimeDial)&&const DeepCollectionEquality().equals(other.nodes, _nodes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,verdict,schemaVersion,generatedAt,coreVersion,appVersion,platform,architecture,windowStart,windowEnd,terrain,env,const DeepCollectionEquality().hash(_presets),droppedEvents,configNodeCount,observedNodeCount,subscriptionUpdate,runtimeDial,const DeepCollectionEquality().hash(_nodes));
}

@override
String toString() {
    return 'SubscriptionReport(verdict: $verdict, schemaVersion: $schemaVersion, generatedAt: $generatedAt, coreVersion: $coreVersion, appVersion: $appVersion, platform: $platform, architecture: $architecture, windowStart: $windowStart, windowEnd: $windowEnd, terrain: $terrain, env: $env, presets: $presets, droppedEvents: $droppedEvents, configNodeCount: $configNodeCount, observedNodeCount: $observedNodeCount, subscriptionUpdate: $subscriptionUpdate, runtimeDial: $runtimeDial, nodes: $nodes)';
}


}

/// @nodoc
abstract mixin class _$SubscriptionReportCopyWith<$Res> implements $SubscriptionReportCopyWith<$Res> {
  factory _$SubscriptionReportCopyWith(_SubscriptionReport value, $Res Function(_SubscriptionReport) _then) = __$SubscriptionReportCopyWithImpl;
@override @useResult
$Res call({
 SubscriptionVerdict? verdict, int schemaVersion, int generatedAt, String coreVersion, String appVersion, String platform, String architecture, int windowStart, int windowEnd, String terrain, String env, List<String> presets, int droppedEvents, int configNodeCount, int observedNodeCount, SubscriptionUpdateReport? subscriptionUpdate, SubscriptionDialReport runtimeDial, List<SubscriptionNodeReport> nodes
});


@override $SubscriptionVerdictCopyWith<$Res>? get verdict;@override $SubscriptionUpdateReportCopyWith<$Res>? get subscriptionUpdate;@override $SubscriptionDialReportCopyWith<$Res> get runtimeDial;

}
/// @nodoc
class __$SubscriptionReportCopyWithImpl<$Res>
    implements _$SubscriptionReportCopyWith<$Res> {
  __$SubscriptionReportCopyWithImpl(this._self, this._then);

  final _SubscriptionReport _self;
  final $Res Function(_SubscriptionReport) _then;

/// Create a copy of SubscriptionReport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? verdict = freezed,Object? schemaVersion = null,Object? generatedAt = null,Object? coreVersion = null,Object? appVersion = null,Object? platform = null,Object? architecture = null,Object? windowStart = null,Object? windowEnd = null,Object? terrain = null,Object? env = null,Object? presets = null,Object? droppedEvents = null,Object? configNodeCount = null,Object? observedNodeCount = null,Object? subscriptionUpdate = freezed,Object? runtimeDial = null,Object? nodes = null,}) {
  return _then(_SubscriptionReport(
verdict: freezed == verdict ? _self.verdict : verdict // ignore: cast_nullable_to_non_nullable
as SubscriptionVerdict?,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as int,coreVersion: null == coreVersion ? _self.coreVersion : coreVersion // ignore: cast_nullable_to_non_nullable
as String,appVersion: null == appVersion ? _self.appVersion : appVersion // ignore: cast_nullable_to_non_nullable
as String,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String,architecture: null == architecture ? _self.architecture : architecture // ignore: cast_nullable_to_non_nullable
as String,windowStart: null == windowStart ? _self.windowStart : windowStart // ignore: cast_nullable_to_non_nullable
as int,windowEnd: null == windowEnd ? _self.windowEnd : windowEnd // ignore: cast_nullable_to_non_nullable
as int,terrain: null == terrain ? _self.terrain : terrain // ignore: cast_nullable_to_non_nullable
as String,env: null == env ? _self.env : env // ignore: cast_nullable_to_non_nullable
as String,presets: null == presets ? _self._presets : presets // ignore: cast_nullable_to_non_nullable
as List<String>,droppedEvents: null == droppedEvents ? _self.droppedEvents : droppedEvents // ignore: cast_nullable_to_non_nullable
as int,configNodeCount: null == configNodeCount ? _self.configNodeCount : configNodeCount // ignore: cast_nullable_to_non_nullable
as int,observedNodeCount: null == observedNodeCount ? _self.observedNodeCount : observedNodeCount // ignore: cast_nullable_to_non_nullable
as int,subscriptionUpdate: freezed == subscriptionUpdate ? _self.subscriptionUpdate : subscriptionUpdate // ignore: cast_nullable_to_non_nullable
as SubscriptionUpdateReport?,runtimeDial: null == runtimeDial ? _self.runtimeDial : runtimeDial // ignore: cast_nullable_to_non_nullable
as SubscriptionDialReport,nodes: null == nodes ? _self._nodes : nodes // ignore: cast_nullable_to_non_nullable
as List<SubscriptionNodeReport>,
  ));
}

/// Create a copy of SubscriptionReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SubscriptionVerdictCopyWith<$Res>? get verdict {
    if (_self.verdict == null) {
    return null;
  }

  return $SubscriptionVerdictCopyWith<$Res>(_self.verdict!, (value) {
    return _then(_self.copyWith(verdict: value));
  });
}/// Create a copy of SubscriptionReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SubscriptionUpdateReportCopyWith<$Res>? get subscriptionUpdate {
    if (_self.subscriptionUpdate == null) {
    return null;
  }

  return $SubscriptionUpdateReportCopyWith<$Res>(_self.subscriptionUpdate!, (value) {
    return _then(_self.copyWith(subscriptionUpdate: value));
  });
}/// Create a copy of SubscriptionReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SubscriptionDialReportCopyWith<$Res> get runtimeDial {
  
  return $SubscriptionDialReportCopyWith<$Res>(_self.runtimeDial, (value) {
    return _then(_self.copyWith(runtimeDial: value));
  });
}
}


/// @nodoc
mixin _$SubscriptionNodeLabel {

 String get protocol; String get transport; List<String> get groups; int get positionHint;
/// Create a copy of SubscriptionNodeLabel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubscriptionNodeLabelCopyWith<SubscriptionNodeLabel> get copyWith => _$SubscriptionNodeLabelCopyWithImpl<SubscriptionNodeLabel>(this as SubscriptionNodeLabel, _$identity);

  /// Serializes this SubscriptionNodeLabel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SubscriptionNodeLabel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubscriptionNodeLabel&&(identical(other.protocol, _this.protocol) || other.protocol == _this.protocol)&&(identical(other.transport, _this.transport) || other.transport == _this.transport)&&const DeepCollectionEquality().equals(other.groups, _this.groups)&&(identical(other.positionHint, _this.positionHint) || other.positionHint == _this.positionHint));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SubscriptionNodeLabel;
  return Object.hash(runtimeType,_this.protocol,_this.transport,const DeepCollectionEquality().hash(_this.groups),_this.positionHint);
}

@override
String toString() {
  final _this = this as SubscriptionNodeLabel;
  return 'SubscriptionNodeLabel(protocol: ${_this.protocol}, transport: ${_this.transport}, groups: ${_this.groups}, positionHint: ${_this.positionHint})';
}


}

/// @nodoc
abstract mixin class $SubscriptionNodeLabelCopyWith<$Res>  {
  factory $SubscriptionNodeLabelCopyWith(SubscriptionNodeLabel value, $Res Function(SubscriptionNodeLabel) _then) = _$SubscriptionNodeLabelCopyWithImpl;
@useResult
$Res call({
 String protocol, String transport, List<String> groups, int positionHint
});




}
/// @nodoc
class _$SubscriptionNodeLabelCopyWithImpl<$Res>
    implements $SubscriptionNodeLabelCopyWith<$Res> {
  _$SubscriptionNodeLabelCopyWithImpl(this._self, this._then);

  final SubscriptionNodeLabel _self;
  final $Res Function(SubscriptionNodeLabel) _then;

/// Create a copy of SubscriptionNodeLabel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? protocol = null,Object? transport = null,Object? groups = null,Object? positionHint = null,}) {
  return _then(SubscriptionNodeLabel(
protocol: null == protocol ? _self.protocol : protocol // ignore: cast_nullable_to_non_nullable
as String,transport: null == transport ? _self.transport : transport // ignore: cast_nullable_to_non_nullable
as String,groups: null == groups ? _self.groups : groups // ignore: cast_nullable_to_non_nullable
as List<String>,positionHint: null == positionHint ? _self.positionHint : positionHint // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SubscriptionNodeLabel].
extension SubscriptionNodeLabelPatterns on SubscriptionNodeLabel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubscriptionNodeLabel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubscriptionNodeLabel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubscriptionNodeLabel value)  $default,){
final _that = this;
switch (_that) {
case _SubscriptionNodeLabel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubscriptionNodeLabel value)?  $default,){
final _that = this;
switch (_that) {
case _SubscriptionNodeLabel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String protocol,  String transport,  List<String> groups,  int positionHint)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubscriptionNodeLabel() when $default != null:
return $default(_that.protocol,_that.transport,_that.groups,_that.positionHint);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String protocol,  String transport,  List<String> groups,  int positionHint)  $default,) {final _that = this;
switch (_that) {
case _SubscriptionNodeLabel():
return $default(_that.protocol,_that.transport,_that.groups,_that.positionHint);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String protocol,  String transport,  List<String> groups,  int positionHint)?  $default,) {final _that = this;
switch (_that) {
case _SubscriptionNodeLabel() when $default != null:
return $default(_that.protocol,_that.transport,_that.groups,_that.positionHint);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubscriptionNodeLabel implements SubscriptionNodeLabel {
  const _SubscriptionNodeLabel({this.protocol = '', this.transport = '',  List<String> groups = const [], this.positionHint = 0}): _groups = groups;
  factory _SubscriptionNodeLabel.fromJson(Map<String, dynamic> json) => _$SubscriptionNodeLabelFromJson(json);

@override@JsonKey() final  String protocol;
@override@JsonKey() final  String transport;
 final  List<String> _groups;
@override@JsonKey() List<String> get groups {
  if (_groups is EqualUnmodifiableListView) return _groups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_groups);
}

@override@JsonKey() final  int positionHint;

/// Create a copy of SubscriptionNodeLabel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubscriptionNodeLabelCopyWith<_SubscriptionNodeLabel> get copyWith => __$SubscriptionNodeLabelCopyWithImpl<_SubscriptionNodeLabel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubscriptionNodeLabelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubscriptionNodeLabel&&(identical(other.protocol, protocol) || other.protocol == protocol)&&(identical(other.transport, transport) || other.transport == transport)&&const DeepCollectionEquality().equals(other.groups, _groups)&&(identical(other.positionHint, positionHint) || other.positionHint == positionHint));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,protocol,transport,const DeepCollectionEquality().hash(_groups),positionHint);
}

@override
String toString() {
    return 'SubscriptionNodeLabel(protocol: $protocol, transport: $transport, groups: $groups, positionHint: $positionHint)';
}


}

/// @nodoc
abstract mixin class _$SubscriptionNodeLabelCopyWith<$Res> implements $SubscriptionNodeLabelCopyWith<$Res> {
  factory _$SubscriptionNodeLabelCopyWith(_SubscriptionNodeLabel value, $Res Function(_SubscriptionNodeLabel) _then) = __$SubscriptionNodeLabelCopyWithImpl;
@override @useResult
$Res call({
 String protocol, String transport, List<String> groups, int positionHint
});




}
/// @nodoc
class __$SubscriptionNodeLabelCopyWithImpl<$Res>
    implements _$SubscriptionNodeLabelCopyWith<$Res> {
  __$SubscriptionNodeLabelCopyWithImpl(this._self, this._then);

  final _SubscriptionNodeLabel _self;
  final $Res Function(_SubscriptionNodeLabel) _then;

/// Create a copy of SubscriptionNodeLabel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? protocol = null,Object? transport = null,Object? groups = null,Object? positionHint = null,}) {
  return _then(_SubscriptionNodeLabel(
protocol: null == protocol ? _self.protocol : protocol // ignore: cast_nullable_to_non_nullable
as String,transport: null == transport ? _self.transport : transport // ignore: cast_nullable_to_non_nullable
as String,groups: null == groups ? _self._groups : groups // ignore: cast_nullable_to_non_nullable
as List<String>,positionHint: null == positionHint ? _self.positionHint : positionHint // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$SubscriptionMetadata {

 Map<String, SubscriptionNodeLabel> get nodes; List<String> get presets;
/// Create a copy of SubscriptionMetadata
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubscriptionMetadataCopyWith<SubscriptionMetadata> get copyWith => _$SubscriptionMetadataCopyWithImpl<SubscriptionMetadata>(this as SubscriptionMetadata, _$identity);

  /// Serializes this SubscriptionMetadata to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SubscriptionMetadata;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubscriptionMetadata&&const DeepCollectionEquality().equals(other.nodes, _this.nodes)&&const DeepCollectionEquality().equals(other.presets, _this.presets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SubscriptionMetadata;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.nodes),const DeepCollectionEquality().hash(_this.presets));
}

@override
String toString() {
  final _this = this as SubscriptionMetadata;
  return 'SubscriptionMetadata(nodes: ${_this.nodes}, presets: ${_this.presets})';
}


}

/// @nodoc
abstract mixin class $SubscriptionMetadataCopyWith<$Res>  {
  factory $SubscriptionMetadataCopyWith(SubscriptionMetadata value, $Res Function(SubscriptionMetadata) _then) = _$SubscriptionMetadataCopyWithImpl;
@useResult
$Res call({
 Map<String, SubscriptionNodeLabel> nodes, List<String> presets
});




}
/// @nodoc
class _$SubscriptionMetadataCopyWithImpl<$Res>
    implements $SubscriptionMetadataCopyWith<$Res> {
  _$SubscriptionMetadataCopyWithImpl(this._self, this._then);

  final SubscriptionMetadata _self;
  final $Res Function(SubscriptionMetadata) _then;

/// Create a copy of SubscriptionMetadata
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? nodes = null,Object? presets = null,}) {
  return _then(SubscriptionMetadata(
nodes: null == nodes ? _self.nodes : nodes // ignore: cast_nullable_to_non_nullable
as Map<String, SubscriptionNodeLabel>,presets: null == presets ? _self.presets : presets // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [SubscriptionMetadata].
extension SubscriptionMetadataPatterns on SubscriptionMetadata {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubscriptionMetadata value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubscriptionMetadata() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubscriptionMetadata value)  $default,){
final _that = this;
switch (_that) {
case _SubscriptionMetadata():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubscriptionMetadata value)?  $default,){
final _that = this;
switch (_that) {
case _SubscriptionMetadata() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, SubscriptionNodeLabel> nodes,  List<String> presets)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubscriptionMetadata() when $default != null:
return $default(_that.nodes,_that.presets);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, SubscriptionNodeLabel> nodes,  List<String> presets)  $default,) {final _that = this;
switch (_that) {
case _SubscriptionMetadata():
return $default(_that.nodes,_that.presets);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, SubscriptionNodeLabel> nodes,  List<String> presets)?  $default,) {final _that = this;
switch (_that) {
case _SubscriptionMetadata() when $default != null:
return $default(_that.nodes,_that.presets);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubscriptionMetadata implements SubscriptionMetadata {
  const _SubscriptionMetadata({ Map<String, SubscriptionNodeLabel> nodes = const {},  List<String> presets = const []}): _nodes = nodes,_presets = presets;
  factory _SubscriptionMetadata.fromJson(Map<String, dynamic> json) => _$SubscriptionMetadataFromJson(json);

 final  Map<String, SubscriptionNodeLabel> _nodes;
@override@JsonKey() Map<String, SubscriptionNodeLabel> get nodes {
  if (_nodes is EqualUnmodifiableMapView) return _nodes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_nodes);
}

 final  List<String> _presets;
@override@JsonKey() List<String> get presets {
  if (_presets is EqualUnmodifiableListView) return _presets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_presets);
}


/// Create a copy of SubscriptionMetadata
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubscriptionMetadataCopyWith<_SubscriptionMetadata> get copyWith => __$SubscriptionMetadataCopyWithImpl<_SubscriptionMetadata>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubscriptionMetadataToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubscriptionMetadata&&const DeepCollectionEquality().equals(other.nodes, _nodes)&&const DeepCollectionEquality().equals(other.presets, _presets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_nodes),const DeepCollectionEquality().hash(_presets));
}

@override
String toString() {
    return 'SubscriptionMetadata(nodes: $nodes, presets: $presets)';
}


}

/// @nodoc
abstract mixin class _$SubscriptionMetadataCopyWith<$Res> implements $SubscriptionMetadataCopyWith<$Res> {
  factory _$SubscriptionMetadataCopyWith(_SubscriptionMetadata value, $Res Function(_SubscriptionMetadata) _then) = __$SubscriptionMetadataCopyWithImpl;
@override @useResult
$Res call({
 Map<String, SubscriptionNodeLabel> nodes, List<String> presets
});




}
/// @nodoc
class __$SubscriptionMetadataCopyWithImpl<$Res>
    implements _$SubscriptionMetadataCopyWith<$Res> {
  __$SubscriptionMetadataCopyWithImpl(this._self, this._then);

  final _SubscriptionMetadata _self;
  final $Res Function(_SubscriptionMetadata) _then;

/// Create a copy of SubscriptionMetadata
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? nodes = null,Object? presets = null,}) {
  return _then(_SubscriptionMetadata(
nodes: null == nodes ? _self._nodes : nodes // ignore: cast_nullable_to_non_nullable
as Map<String, SubscriptionNodeLabel>,presets: null == presets ? _self._presets : presets // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
