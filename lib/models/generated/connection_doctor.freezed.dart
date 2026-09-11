// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../connection_doctor.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DoctorCapabilities {

 bool get passiveWitness; bool get explicitExam; bool get cancel; bool get dnsFlush; bool get androidAppIngressProbe; bool get tunIngressProof; bool get byedpiStatus; bool get redactedExport;
/// Create a copy of DoctorCapabilities
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DoctorCapabilitiesCopyWith<DoctorCapabilities> get copyWith => _$DoctorCapabilitiesCopyWithImpl<DoctorCapabilities>(this as DoctorCapabilities, _$identity);

  /// Serializes this DoctorCapabilities to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DoctorCapabilities;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DoctorCapabilities&&(identical(other.passiveWitness, _this.passiveWitness) || other.passiveWitness == _this.passiveWitness)&&(identical(other.explicitExam, _this.explicitExam) || other.explicitExam == _this.explicitExam)&&(identical(other.cancel, _this.cancel) || other.cancel == _this.cancel)&&(identical(other.dnsFlush, _this.dnsFlush) || other.dnsFlush == _this.dnsFlush)&&(identical(other.androidAppIngressProbe, _this.androidAppIngressProbe) || other.androidAppIngressProbe == _this.androidAppIngressProbe)&&(identical(other.tunIngressProof, _this.tunIngressProof) || other.tunIngressProof == _this.tunIngressProof)&&(identical(other.byedpiStatus, _this.byedpiStatus) || other.byedpiStatus == _this.byedpiStatus)&&(identical(other.redactedExport, _this.redactedExport) || other.redactedExport == _this.redactedExport));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DoctorCapabilities;
  return Object.hash(runtimeType,_this.passiveWitness,_this.explicitExam,_this.cancel,_this.dnsFlush,_this.androidAppIngressProbe,_this.tunIngressProof,_this.byedpiStatus,_this.redactedExport);
}

@override
String toString() {
  final _this = this as DoctorCapabilities;
  return 'DoctorCapabilities(passiveWitness: ${_this.passiveWitness}, explicitExam: ${_this.explicitExam}, cancel: ${_this.cancel}, dnsFlush: ${_this.dnsFlush}, androidAppIngressProbe: ${_this.androidAppIngressProbe}, tunIngressProof: ${_this.tunIngressProof}, byedpiStatus: ${_this.byedpiStatus}, redactedExport: ${_this.redactedExport})';
}


}

/// @nodoc
abstract mixin class $DoctorCapabilitiesCopyWith<$Res>  {
  factory $DoctorCapabilitiesCopyWith(DoctorCapabilities value, $Res Function(DoctorCapabilities) _then) = _$DoctorCapabilitiesCopyWithImpl;
@useResult
$Res call({
 bool passiveWitness, bool explicitExam, bool cancel, bool dnsFlush, bool androidAppIngressProbe, bool tunIngressProof, bool byedpiStatus, bool redactedExport
});




}
/// @nodoc
class _$DoctorCapabilitiesCopyWithImpl<$Res>
    implements $DoctorCapabilitiesCopyWith<$Res> {
  _$DoctorCapabilitiesCopyWithImpl(this._self, this._then);

  final DoctorCapabilities _self;
  final $Res Function(DoctorCapabilities) _then;

/// Create a copy of DoctorCapabilities
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? passiveWitness = null,Object? explicitExam = null,Object? cancel = null,Object? dnsFlush = null,Object? androidAppIngressProbe = null,Object? tunIngressProof = null,Object? byedpiStatus = null,Object? redactedExport = null,}) {
  return _then(DoctorCapabilities(
passiveWitness: null == passiveWitness ? _self.passiveWitness : passiveWitness // ignore: cast_nullable_to_non_nullable
as bool,explicitExam: null == explicitExam ? _self.explicitExam : explicitExam // ignore: cast_nullable_to_non_nullable
as bool,cancel: null == cancel ? _self.cancel : cancel // ignore: cast_nullable_to_non_nullable
as bool,dnsFlush: null == dnsFlush ? _self.dnsFlush : dnsFlush // ignore: cast_nullable_to_non_nullable
as bool,androidAppIngressProbe: null == androidAppIngressProbe ? _self.androidAppIngressProbe : androidAppIngressProbe // ignore: cast_nullable_to_non_nullable
as bool,tunIngressProof: null == tunIngressProof ? _self.tunIngressProof : tunIngressProof // ignore: cast_nullable_to_non_nullable
as bool,byedpiStatus: null == byedpiStatus ? _self.byedpiStatus : byedpiStatus // ignore: cast_nullable_to_non_nullable
as bool,redactedExport: null == redactedExport ? _self.redactedExport : redactedExport // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [DoctorCapabilities].
extension DoctorCapabilitiesPatterns on DoctorCapabilities {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DoctorCapabilities value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DoctorCapabilities() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DoctorCapabilities value)  $default,){
final _that = this;
switch (_that) {
case _DoctorCapabilities():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DoctorCapabilities value)?  $default,){
final _that = this;
switch (_that) {
case _DoctorCapabilities() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool passiveWitness,  bool explicitExam,  bool cancel,  bool dnsFlush,  bool androidAppIngressProbe,  bool tunIngressProof,  bool byedpiStatus,  bool redactedExport)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DoctorCapabilities() when $default != null:
return $default(_that.passiveWitness,_that.explicitExam,_that.cancel,_that.dnsFlush,_that.androidAppIngressProbe,_that.tunIngressProof,_that.byedpiStatus,_that.redactedExport);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool passiveWitness,  bool explicitExam,  bool cancel,  bool dnsFlush,  bool androidAppIngressProbe,  bool tunIngressProof,  bool byedpiStatus,  bool redactedExport)  $default,) {final _that = this;
switch (_that) {
case _DoctorCapabilities():
return $default(_that.passiveWitness,_that.explicitExam,_that.cancel,_that.dnsFlush,_that.androidAppIngressProbe,_that.tunIngressProof,_that.byedpiStatus,_that.redactedExport);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool passiveWitness,  bool explicitExam,  bool cancel,  bool dnsFlush,  bool androidAppIngressProbe,  bool tunIngressProof,  bool byedpiStatus,  bool redactedExport)?  $default,) {final _that = this;
switch (_that) {
case _DoctorCapabilities() when $default != null:
return $default(_that.passiveWitness,_that.explicitExam,_that.cancel,_that.dnsFlush,_that.androidAppIngressProbe,_that.tunIngressProof,_that.byedpiStatus,_that.redactedExport);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DoctorCapabilities implements DoctorCapabilities {
  const _DoctorCapabilities({this.passiveWitness = false, this.explicitExam = false, this.cancel = false, this.dnsFlush = false, this.androidAppIngressProbe = false, this.tunIngressProof = false, this.byedpiStatus = false, this.redactedExport = false});
  factory _DoctorCapabilities.fromJson(Map<String, dynamic> json) => _$DoctorCapabilitiesFromJson(json);

@override@JsonKey() final  bool passiveWitness;
@override@JsonKey() final  bool explicitExam;
@override@JsonKey() final  bool cancel;
@override@JsonKey() final  bool dnsFlush;
@override@JsonKey() final  bool androidAppIngressProbe;
@override@JsonKey() final  bool tunIngressProof;
@override@JsonKey() final  bool byedpiStatus;
@override@JsonKey() final  bool redactedExport;

/// Create a copy of DoctorCapabilities
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DoctorCapabilitiesCopyWith<_DoctorCapabilities> get copyWith => __$DoctorCapabilitiesCopyWithImpl<_DoctorCapabilities>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DoctorCapabilitiesToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DoctorCapabilities&&(identical(other.passiveWitness, passiveWitness) || other.passiveWitness == passiveWitness)&&(identical(other.explicitExam, explicitExam) || other.explicitExam == explicitExam)&&(identical(other.cancel, cancel) || other.cancel == cancel)&&(identical(other.dnsFlush, dnsFlush) || other.dnsFlush == dnsFlush)&&(identical(other.androidAppIngressProbe, androidAppIngressProbe) || other.androidAppIngressProbe == androidAppIngressProbe)&&(identical(other.tunIngressProof, tunIngressProof) || other.tunIngressProof == tunIngressProof)&&(identical(other.byedpiStatus, byedpiStatus) || other.byedpiStatus == byedpiStatus)&&(identical(other.redactedExport, redactedExport) || other.redactedExport == redactedExport));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,passiveWitness,explicitExam,cancel,dnsFlush,androidAppIngressProbe,tunIngressProof,byedpiStatus,redactedExport);
}

@override
String toString() {
    return 'DoctorCapabilities(passiveWitness: $passiveWitness, explicitExam: $explicitExam, cancel: $cancel, dnsFlush: $dnsFlush, androidAppIngressProbe: $androidAppIngressProbe, tunIngressProof: $tunIngressProof, byedpiStatus: $byedpiStatus, redactedExport: $redactedExport)';
}


}

/// @nodoc
abstract mixin class _$DoctorCapabilitiesCopyWith<$Res> implements $DoctorCapabilitiesCopyWith<$Res> {
  factory _$DoctorCapabilitiesCopyWith(_DoctorCapabilities value, $Res Function(_DoctorCapabilities) _then) = __$DoctorCapabilitiesCopyWithImpl;
@override @useResult
$Res call({
 bool passiveWitness, bool explicitExam, bool cancel, bool dnsFlush, bool androidAppIngressProbe, bool tunIngressProof, bool byedpiStatus, bool redactedExport
});




}
/// @nodoc
class __$DoctorCapabilitiesCopyWithImpl<$Res>
    implements _$DoctorCapabilitiesCopyWith<$Res> {
  __$DoctorCapabilitiesCopyWithImpl(this._self, this._then);

  final _DoctorCapabilities _self;
  final $Res Function(_DoctorCapabilities) _then;

/// Create a copy of DoctorCapabilities
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? passiveWitness = null,Object? explicitExam = null,Object? cancel = null,Object? dnsFlush = null,Object? androidAppIngressProbe = null,Object? tunIngressProof = null,Object? byedpiStatus = null,Object? redactedExport = null,}) {
  return _then(_DoctorCapabilities(
passiveWitness: null == passiveWitness ? _self.passiveWitness : passiveWitness // ignore: cast_nullable_to_non_nullable
as bool,explicitExam: null == explicitExam ? _self.explicitExam : explicitExam // ignore: cast_nullable_to_non_nullable
as bool,cancel: null == cancel ? _self.cancel : cancel // ignore: cast_nullable_to_non_nullable
as bool,dnsFlush: null == dnsFlush ? _self.dnsFlush : dnsFlush // ignore: cast_nullable_to_non_nullable
as bool,androidAppIngressProbe: null == androidAppIngressProbe ? _self.androidAppIngressProbe : androidAppIngressProbe // ignore: cast_nullable_to_non_nullable
as bool,tunIngressProof: null == tunIngressProof ? _self.tunIngressProof : tunIngressProof // ignore: cast_nullable_to_non_nullable
as bool,byedpiStatus: null == byedpiStatus ? _self.byedpiStatus : byedpiStatus // ignore: cast_nullable_to_non_nullable
as bool,redactedExport: null == redactedExport ? _self.redactedExport : redactedExport // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$DoctorGenerations {

 int get environment; int get config; int get routing; int get tun;
/// Create a copy of DoctorGenerations
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DoctorGenerationsCopyWith<DoctorGenerations> get copyWith => _$DoctorGenerationsCopyWithImpl<DoctorGenerations>(this as DoctorGenerations, _$identity);

  /// Serializes this DoctorGenerations to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DoctorGenerations;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DoctorGenerations&&(identical(other.environment, _this.environment) || other.environment == _this.environment)&&(identical(other.config, _this.config) || other.config == _this.config)&&(identical(other.routing, _this.routing) || other.routing == _this.routing)&&(identical(other.tun, _this.tun) || other.tun == _this.tun));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DoctorGenerations;
  return Object.hash(runtimeType,_this.environment,_this.config,_this.routing,_this.tun);
}

@override
String toString() {
  final _this = this as DoctorGenerations;
  return 'DoctorGenerations(environment: ${_this.environment}, config: ${_this.config}, routing: ${_this.routing}, tun: ${_this.tun})';
}


}

/// @nodoc
abstract mixin class $DoctorGenerationsCopyWith<$Res>  {
  factory $DoctorGenerationsCopyWith(DoctorGenerations value, $Res Function(DoctorGenerations) _then) = _$DoctorGenerationsCopyWithImpl;
@useResult
$Res call({
 int environment, int config, int routing, int tun
});




}
/// @nodoc
class _$DoctorGenerationsCopyWithImpl<$Res>
    implements $DoctorGenerationsCopyWith<$Res> {
  _$DoctorGenerationsCopyWithImpl(this._self, this._then);

  final DoctorGenerations _self;
  final $Res Function(DoctorGenerations) _then;

/// Create a copy of DoctorGenerations
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? environment = null,Object? config = null,Object? routing = null,Object? tun = null,}) {
  return _then(DoctorGenerations(
environment: null == environment ? _self.environment : environment // ignore: cast_nullable_to_non_nullable
as int,config: null == config ? _self.config : config // ignore: cast_nullable_to_non_nullable
as int,routing: null == routing ? _self.routing : routing // ignore: cast_nullable_to_non_nullable
as int,tun: null == tun ? _self.tun : tun // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DoctorGenerations].
extension DoctorGenerationsPatterns on DoctorGenerations {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DoctorGenerations value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DoctorGenerations() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DoctorGenerations value)  $default,){
final _that = this;
switch (_that) {
case _DoctorGenerations():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DoctorGenerations value)?  $default,){
final _that = this;
switch (_that) {
case _DoctorGenerations() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int environment,  int config,  int routing,  int tun)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DoctorGenerations() when $default != null:
return $default(_that.environment,_that.config,_that.routing,_that.tun);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int environment,  int config,  int routing,  int tun)  $default,) {final _that = this;
switch (_that) {
case _DoctorGenerations():
return $default(_that.environment,_that.config,_that.routing,_that.tun);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int environment,  int config,  int routing,  int tun)?  $default,) {final _that = this;
switch (_that) {
case _DoctorGenerations() when $default != null:
return $default(_that.environment,_that.config,_that.routing,_that.tun);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DoctorGenerations implements DoctorGenerations {
  const _DoctorGenerations({this.environment = 0, this.config = 0, this.routing = 0, this.tun = 0});
  factory _DoctorGenerations.fromJson(Map<String, dynamic> json) => _$DoctorGenerationsFromJson(json);

@override@JsonKey() final  int environment;
@override@JsonKey() final  int config;
@override@JsonKey() final  int routing;
@override@JsonKey() final  int tun;

/// Create a copy of DoctorGenerations
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DoctorGenerationsCopyWith<_DoctorGenerations> get copyWith => __$DoctorGenerationsCopyWithImpl<_DoctorGenerations>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DoctorGenerationsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DoctorGenerations&&(identical(other.environment, environment) || other.environment == environment)&&(identical(other.config, config) || other.config == config)&&(identical(other.routing, routing) || other.routing == routing)&&(identical(other.tun, tun) || other.tun == tun));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,environment,config,routing,tun);
}

@override
String toString() {
    return 'DoctorGenerations(environment: $environment, config: $config, routing: $routing, tun: $tun)';
}


}

/// @nodoc
abstract mixin class _$DoctorGenerationsCopyWith<$Res> implements $DoctorGenerationsCopyWith<$Res> {
  factory _$DoctorGenerationsCopyWith(_DoctorGenerations value, $Res Function(_DoctorGenerations) _then) = __$DoctorGenerationsCopyWithImpl;
@override @useResult
$Res call({
 int environment, int config, int routing, int tun
});




}
/// @nodoc
class __$DoctorGenerationsCopyWithImpl<$Res>
    implements _$DoctorGenerationsCopyWith<$Res> {
  __$DoctorGenerationsCopyWithImpl(this._self, this._then);

  final _DoctorGenerations _self;
  final $Res Function(_DoctorGenerations) _then;

/// Create a copy of DoctorGenerations
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? environment = null,Object? config = null,Object? routing = null,Object? tun = null,}) {
  return _then(_DoctorGenerations(
environment: null == environment ? _self.environment : environment // ignore: cast_nullable_to_non_nullable
as int,config: null == config ? _self.config : config // ignore: cast_nullable_to_non_nullable
as int,routing: null == routing ? _self.routing : routing // ignore: cast_nullable_to_non_nullable
as int,tun: null == tun ? _self.tun : tun // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$DoctorEvidence {

@JsonKey(unknownEnumValue: DoctorEvidenceKind.unknown) DoctorEvidenceKind get kind;@JsonKey(unknownEnumValue: DoctorLayer.unknown) DoctorLayer get layer;@JsonKey(unknownEnumValue: DoctorEvidenceOutcome.unknown) DoctorEvidenceOutcome get outcome;@JsonKey(unknownEnumValue: DoctorConfidence.unknown) DoctorConfidence get confidence; String get code; String get network; String get inbound; int get offsetMillis; int get durationBucketMs; bool get consequence;
/// Create a copy of DoctorEvidence
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DoctorEvidenceCopyWith<DoctorEvidence> get copyWith => _$DoctorEvidenceCopyWithImpl<DoctorEvidence>(this as DoctorEvidence, _$identity);

  /// Serializes this DoctorEvidence to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DoctorEvidence;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DoctorEvidence&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.layer, _this.layer) || other.layer == _this.layer)&&(identical(other.outcome, _this.outcome) || other.outcome == _this.outcome)&&(identical(other.confidence, _this.confidence) || other.confidence == _this.confidence)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.network, _this.network) || other.network == _this.network)&&(identical(other.inbound, _this.inbound) || other.inbound == _this.inbound)&&(identical(other.offsetMillis, _this.offsetMillis) || other.offsetMillis == _this.offsetMillis)&&(identical(other.durationBucketMs, _this.durationBucketMs) || other.durationBucketMs == _this.durationBucketMs)&&(identical(other.consequence, _this.consequence) || other.consequence == _this.consequence));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DoctorEvidence;
  return Object.hash(runtimeType,_this.kind,_this.layer,_this.outcome,_this.confidence,_this.code,_this.network,_this.inbound,_this.offsetMillis,_this.durationBucketMs,_this.consequence);
}

@override
String toString() {
  final _this = this as DoctorEvidence;
  return 'DoctorEvidence(kind: ${_this.kind}, layer: ${_this.layer}, outcome: ${_this.outcome}, confidence: ${_this.confidence}, code: ${_this.code}, network: ${_this.network}, inbound: ${_this.inbound}, offsetMillis: ${_this.offsetMillis}, durationBucketMs: ${_this.durationBucketMs}, consequence: ${_this.consequence})';
}


}

/// @nodoc
abstract mixin class $DoctorEvidenceCopyWith<$Res>  {
  factory $DoctorEvidenceCopyWith(DoctorEvidence value, $Res Function(DoctorEvidence) _then) = _$DoctorEvidenceCopyWithImpl;
@useResult
$Res call({
@JsonKey(unknownEnumValue: DoctorEvidenceKind.unknown) DoctorEvidenceKind kind,@JsonKey(unknownEnumValue: DoctorLayer.unknown) DoctorLayer layer,@JsonKey(unknownEnumValue: DoctorEvidenceOutcome.unknown) DoctorEvidenceOutcome outcome,@JsonKey(unknownEnumValue: DoctorConfidence.unknown) DoctorConfidence confidence, String code, String network, String inbound, int offsetMillis, int durationBucketMs, bool consequence
});




}
/// @nodoc
class _$DoctorEvidenceCopyWithImpl<$Res>
    implements $DoctorEvidenceCopyWith<$Res> {
  _$DoctorEvidenceCopyWithImpl(this._self, this._then);

  final DoctorEvidence _self;
  final $Res Function(DoctorEvidence) _then;

/// Create a copy of DoctorEvidence
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? layer = null,Object? outcome = null,Object? confidence = null,Object? code = null,Object? network = null,Object? inbound = null,Object? offsetMillis = null,Object? durationBucketMs = null,Object? consequence = null,}) {
  return _then(DoctorEvidence(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as DoctorEvidenceKind,layer: null == layer ? _self.layer : layer // ignore: cast_nullable_to_non_nullable
as DoctorLayer,outcome: null == outcome ? _self.outcome : outcome // ignore: cast_nullable_to_non_nullable
as DoctorEvidenceOutcome,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as DoctorConfidence,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,network: null == network ? _self.network : network // ignore: cast_nullable_to_non_nullable
as String,inbound: null == inbound ? _self.inbound : inbound // ignore: cast_nullable_to_non_nullable
as String,offsetMillis: null == offsetMillis ? _self.offsetMillis : offsetMillis // ignore: cast_nullable_to_non_nullable
as int,durationBucketMs: null == durationBucketMs ? _self.durationBucketMs : durationBucketMs // ignore: cast_nullable_to_non_nullable
as int,consequence: null == consequence ? _self.consequence : consequence // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [DoctorEvidence].
extension DoctorEvidencePatterns on DoctorEvidence {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DoctorEvidence value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DoctorEvidence() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DoctorEvidence value)  $default,){
final _that = this;
switch (_that) {
case _DoctorEvidence():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DoctorEvidence value)?  $default,){
final _that = this;
switch (_that) {
case _DoctorEvidence() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: DoctorEvidenceKind.unknown)  DoctorEvidenceKind kind, @JsonKey(unknownEnumValue: DoctorLayer.unknown)  DoctorLayer layer, @JsonKey(unknownEnumValue: DoctorEvidenceOutcome.unknown)  DoctorEvidenceOutcome outcome, @JsonKey(unknownEnumValue: DoctorConfidence.unknown)  DoctorConfidence confidence,  String code,  String network,  String inbound,  int offsetMillis,  int durationBucketMs,  bool consequence)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DoctorEvidence() when $default != null:
return $default(_that.kind,_that.layer,_that.outcome,_that.confidence,_that.code,_that.network,_that.inbound,_that.offsetMillis,_that.durationBucketMs,_that.consequence);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: DoctorEvidenceKind.unknown)  DoctorEvidenceKind kind, @JsonKey(unknownEnumValue: DoctorLayer.unknown)  DoctorLayer layer, @JsonKey(unknownEnumValue: DoctorEvidenceOutcome.unknown)  DoctorEvidenceOutcome outcome, @JsonKey(unknownEnumValue: DoctorConfidence.unknown)  DoctorConfidence confidence,  String code,  String network,  String inbound,  int offsetMillis,  int durationBucketMs,  bool consequence)  $default,) {final _that = this;
switch (_that) {
case _DoctorEvidence():
return $default(_that.kind,_that.layer,_that.outcome,_that.confidence,_that.code,_that.network,_that.inbound,_that.offsetMillis,_that.durationBucketMs,_that.consequence);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(unknownEnumValue: DoctorEvidenceKind.unknown)  DoctorEvidenceKind kind, @JsonKey(unknownEnumValue: DoctorLayer.unknown)  DoctorLayer layer, @JsonKey(unknownEnumValue: DoctorEvidenceOutcome.unknown)  DoctorEvidenceOutcome outcome, @JsonKey(unknownEnumValue: DoctorConfidence.unknown)  DoctorConfidence confidence,  String code,  String network,  String inbound,  int offsetMillis,  int durationBucketMs,  bool consequence)?  $default,) {final _that = this;
switch (_that) {
case _DoctorEvidence() when $default != null:
return $default(_that.kind,_that.layer,_that.outcome,_that.confidence,_that.code,_that.network,_that.inbound,_that.offsetMillis,_that.durationBucketMs,_that.consequence);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DoctorEvidence implements DoctorEvidence {
  const _DoctorEvidence({@JsonKey(unknownEnumValue: DoctorEvidenceKind.unknown) this.kind = DoctorEvidenceKind.unknown, @JsonKey(unknownEnumValue: DoctorLayer.unknown) this.layer = DoctorLayer.unknown, @JsonKey(unknownEnumValue: DoctorEvidenceOutcome.unknown) this.outcome = DoctorEvidenceOutcome.unknown, @JsonKey(unknownEnumValue: DoctorConfidence.unknown) this.confidence = DoctorConfidence.unknown, this.code = '', this.network = '', this.inbound = '', this.offsetMillis = 0, this.durationBucketMs = 0, this.consequence = false});
  factory _DoctorEvidence.fromJson(Map<String, dynamic> json) => _$DoctorEvidenceFromJson(json);

@override@JsonKey(unknownEnumValue: DoctorEvidenceKind.unknown) final  DoctorEvidenceKind kind;
@override@JsonKey(unknownEnumValue: DoctorLayer.unknown) final  DoctorLayer layer;
@override@JsonKey(unknownEnumValue: DoctorEvidenceOutcome.unknown) final  DoctorEvidenceOutcome outcome;
@override@JsonKey(unknownEnumValue: DoctorConfidence.unknown) final  DoctorConfidence confidence;
@override@JsonKey() final  String code;
@override@JsonKey() final  String network;
@override@JsonKey() final  String inbound;
@override@JsonKey() final  int offsetMillis;
@override@JsonKey() final  int durationBucketMs;
@override@JsonKey() final  bool consequence;

/// Create a copy of DoctorEvidence
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DoctorEvidenceCopyWith<_DoctorEvidence> get copyWith => __$DoctorEvidenceCopyWithImpl<_DoctorEvidence>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DoctorEvidenceToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DoctorEvidence&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.layer, layer) || other.layer == layer)&&(identical(other.outcome, outcome) || other.outcome == outcome)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.code, code) || other.code == code)&&(identical(other.network, network) || other.network == network)&&(identical(other.inbound, inbound) || other.inbound == inbound)&&(identical(other.offsetMillis, offsetMillis) || other.offsetMillis == offsetMillis)&&(identical(other.durationBucketMs, durationBucketMs) || other.durationBucketMs == durationBucketMs)&&(identical(other.consequence, consequence) || other.consequence == consequence));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,kind,layer,outcome,confidence,code,network,inbound,offsetMillis,durationBucketMs,consequence);
}

@override
String toString() {
    return 'DoctorEvidence(kind: $kind, layer: $layer, outcome: $outcome, confidence: $confidence, code: $code, network: $network, inbound: $inbound, offsetMillis: $offsetMillis, durationBucketMs: $durationBucketMs, consequence: $consequence)';
}


}

/// @nodoc
abstract mixin class _$DoctorEvidenceCopyWith<$Res> implements $DoctorEvidenceCopyWith<$Res> {
  factory _$DoctorEvidenceCopyWith(_DoctorEvidence value, $Res Function(_DoctorEvidence) _then) = __$DoctorEvidenceCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(unknownEnumValue: DoctorEvidenceKind.unknown) DoctorEvidenceKind kind,@JsonKey(unknownEnumValue: DoctorLayer.unknown) DoctorLayer layer,@JsonKey(unknownEnumValue: DoctorEvidenceOutcome.unknown) DoctorEvidenceOutcome outcome,@JsonKey(unknownEnumValue: DoctorConfidence.unknown) DoctorConfidence confidence, String code, String network, String inbound, int offsetMillis, int durationBucketMs, bool consequence
});




}
/// @nodoc
class __$DoctorEvidenceCopyWithImpl<$Res>
    implements _$DoctorEvidenceCopyWith<$Res> {
  __$DoctorEvidenceCopyWithImpl(this._self, this._then);

  final _DoctorEvidence _self;
  final $Res Function(_DoctorEvidence) _then;

/// Create a copy of DoctorEvidence
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? layer = null,Object? outcome = null,Object? confidence = null,Object? code = null,Object? network = null,Object? inbound = null,Object? offsetMillis = null,Object? durationBucketMs = null,Object? consequence = null,}) {
  return _then(_DoctorEvidence(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as DoctorEvidenceKind,layer: null == layer ? _self.layer : layer // ignore: cast_nullable_to_non_nullable
as DoctorLayer,outcome: null == outcome ? _self.outcome : outcome // ignore: cast_nullable_to_non_nullable
as DoctorEvidenceOutcome,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as DoctorConfidence,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,network: null == network ? _self.network : network // ignore: cast_nullable_to_non_nullable
as String,inbound: null == inbound ? _self.inbound : inbound // ignore: cast_nullable_to_non_nullable
as String,offsetMillis: null == offsetMillis ? _self.offsetMillis : offsetMillis // ignore: cast_nullable_to_non_nullable
as int,durationBucketMs: null == durationBucketMs ? _self.durationBucketMs : durationBucketMs // ignore: cast_nullable_to_non_nullable
as int,consequence: null == consequence ? _self.consequence : consequence // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$DoctorStage {

 String get id;@JsonKey(unknownEnumValue: DoctorStageState.unknown) DoctorStageState get state;@JsonKey(unknownEnumValue: DoctorLayer.unknown) DoctorLayer get layer; String get code;
/// Create a copy of DoctorStage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DoctorStageCopyWith<DoctorStage> get copyWith => _$DoctorStageCopyWithImpl<DoctorStage>(this as DoctorStage, _$identity);

  /// Serializes this DoctorStage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DoctorStage;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DoctorStage&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.state, _this.state) || other.state == _this.state)&&(identical(other.layer, _this.layer) || other.layer == _this.layer)&&(identical(other.code, _this.code) || other.code == _this.code));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DoctorStage;
  return Object.hash(runtimeType,_this.id,_this.state,_this.layer,_this.code);
}

@override
String toString() {
  final _this = this as DoctorStage;
  return 'DoctorStage(id: ${_this.id}, state: ${_this.state}, layer: ${_this.layer}, code: ${_this.code})';
}


}

/// @nodoc
abstract mixin class $DoctorStageCopyWith<$Res>  {
  factory $DoctorStageCopyWith(DoctorStage value, $Res Function(DoctorStage) _then) = _$DoctorStageCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(unknownEnumValue: DoctorStageState.unknown) DoctorStageState state,@JsonKey(unknownEnumValue: DoctorLayer.unknown) DoctorLayer layer, String code
});




}
/// @nodoc
class _$DoctorStageCopyWithImpl<$Res>
    implements $DoctorStageCopyWith<$Res> {
  _$DoctorStageCopyWithImpl(this._self, this._then);

  final DoctorStage _self;
  final $Res Function(DoctorStage) _then;

/// Create a copy of DoctorStage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? state = null,Object? layer = null,Object? code = null,}) {
  return _then(DoctorStage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as DoctorStageState,layer: null == layer ? _self.layer : layer // ignore: cast_nullable_to_non_nullable
as DoctorLayer,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DoctorStage].
extension DoctorStagePatterns on DoctorStage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DoctorStage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DoctorStage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DoctorStage value)  $default,){
final _that = this;
switch (_that) {
case _DoctorStage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DoctorStage value)?  $default,){
final _that = this;
switch (_that) {
case _DoctorStage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(unknownEnumValue: DoctorStageState.unknown)  DoctorStageState state, @JsonKey(unknownEnumValue: DoctorLayer.unknown)  DoctorLayer layer,  String code)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DoctorStage() when $default != null:
return $default(_that.id,_that.state,_that.layer,_that.code);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(unknownEnumValue: DoctorStageState.unknown)  DoctorStageState state, @JsonKey(unknownEnumValue: DoctorLayer.unknown)  DoctorLayer layer,  String code)  $default,) {final _that = this;
switch (_that) {
case _DoctorStage():
return $default(_that.id,_that.state,_that.layer,_that.code);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(unknownEnumValue: DoctorStageState.unknown)  DoctorStageState state, @JsonKey(unknownEnumValue: DoctorLayer.unknown)  DoctorLayer layer,  String code)?  $default,) {final _that = this;
switch (_that) {
case _DoctorStage() when $default != null:
return $default(_that.id,_that.state,_that.layer,_that.code);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DoctorStage implements DoctorStage {
  const _DoctorStage({this.id = '', @JsonKey(unknownEnumValue: DoctorStageState.unknown) this.state = DoctorStageState.unknown, @JsonKey(unknownEnumValue: DoctorLayer.unknown) this.layer = DoctorLayer.unknown, this.code = ''});
  factory _DoctorStage.fromJson(Map<String, dynamic> json) => _$DoctorStageFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey(unknownEnumValue: DoctorStageState.unknown) final  DoctorStageState state;
@override@JsonKey(unknownEnumValue: DoctorLayer.unknown) final  DoctorLayer layer;
@override@JsonKey() final  String code;

/// Create a copy of DoctorStage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DoctorStageCopyWith<_DoctorStage> get copyWith => __$DoctorStageCopyWithImpl<_DoctorStage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DoctorStageToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DoctorStage&&(identical(other.id, id) || other.id == id)&&(identical(other.state, state) || other.state == state)&&(identical(other.layer, layer) || other.layer == layer)&&(identical(other.code, code) || other.code == code));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,state,layer,code);
}

@override
String toString() {
    return 'DoctorStage(id: $id, state: $state, layer: $layer, code: $code)';
}


}

/// @nodoc
abstract mixin class _$DoctorStageCopyWith<$Res> implements $DoctorStageCopyWith<$Res> {
  factory _$DoctorStageCopyWith(_DoctorStage value, $Res Function(_DoctorStage) _then) = __$DoctorStageCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(unknownEnumValue: DoctorStageState.unknown) DoctorStageState state,@JsonKey(unknownEnumValue: DoctorLayer.unknown) DoctorLayer layer, String code
});




}
/// @nodoc
class __$DoctorStageCopyWithImpl<$Res>
    implements _$DoctorStageCopyWith<$Res> {
  __$DoctorStageCopyWithImpl(this._self, this._then);

  final _DoctorStage _self;
  final $Res Function(_DoctorStage) _then;

/// Create a copy of DoctorStage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? state = null,Object? layer = null,Object? code = null,}) {
  return _then(_DoctorStage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as DoctorStageState,layer: null == layer ? _self.layer : layer // ignore: cast_nullable_to_non_nullable
as DoctorLayer,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$DoctorAction {

 String get id; bool get eligible; String get eligibilityReasonCode;
/// Create a copy of DoctorAction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DoctorActionCopyWith<DoctorAction> get copyWith => _$DoctorActionCopyWithImpl<DoctorAction>(this as DoctorAction, _$identity);

  /// Serializes this DoctorAction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DoctorAction;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DoctorAction&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.eligible, _this.eligible) || other.eligible == _this.eligible)&&(identical(other.eligibilityReasonCode, _this.eligibilityReasonCode) || other.eligibilityReasonCode == _this.eligibilityReasonCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DoctorAction;
  return Object.hash(runtimeType,_this.id,_this.eligible,_this.eligibilityReasonCode);
}

@override
String toString() {
  final _this = this as DoctorAction;
  return 'DoctorAction(id: ${_this.id}, eligible: ${_this.eligible}, eligibilityReasonCode: ${_this.eligibilityReasonCode})';
}


}

/// @nodoc
abstract mixin class $DoctorActionCopyWith<$Res>  {
  factory $DoctorActionCopyWith(DoctorAction value, $Res Function(DoctorAction) _then) = _$DoctorActionCopyWithImpl;
@useResult
$Res call({
 String id, bool eligible, String eligibilityReasonCode
});




}
/// @nodoc
class _$DoctorActionCopyWithImpl<$Res>
    implements $DoctorActionCopyWith<$Res> {
  _$DoctorActionCopyWithImpl(this._self, this._then);

  final DoctorAction _self;
  final $Res Function(DoctorAction) _then;

/// Create a copy of DoctorAction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? eligible = null,Object? eligibilityReasonCode = null,}) {
  return _then(DoctorAction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,eligible: null == eligible ? _self.eligible : eligible // ignore: cast_nullable_to_non_nullable
as bool,eligibilityReasonCode: null == eligibilityReasonCode ? _self.eligibilityReasonCode : eligibilityReasonCode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DoctorAction].
extension DoctorActionPatterns on DoctorAction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DoctorAction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DoctorAction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DoctorAction value)  $default,){
final _that = this;
switch (_that) {
case _DoctorAction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DoctorAction value)?  $default,){
final _that = this;
switch (_that) {
case _DoctorAction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  bool eligible,  String eligibilityReasonCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DoctorAction() when $default != null:
return $default(_that.id,_that.eligible,_that.eligibilityReasonCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  bool eligible,  String eligibilityReasonCode)  $default,) {final _that = this;
switch (_that) {
case _DoctorAction():
return $default(_that.id,_that.eligible,_that.eligibilityReasonCode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  bool eligible,  String eligibilityReasonCode)?  $default,) {final _that = this;
switch (_that) {
case _DoctorAction() when $default != null:
return $default(_that.id,_that.eligible,_that.eligibilityReasonCode);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DoctorAction implements DoctorAction {
  const _DoctorAction({required this.id, this.eligible = false, this.eligibilityReasonCode = ''});
  factory _DoctorAction.fromJson(Map<String, dynamic> json) => _$DoctorActionFromJson(json);

@override final  String id;
@override@JsonKey() final  bool eligible;
@override@JsonKey() final  String eligibilityReasonCode;

/// Create a copy of DoctorAction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DoctorActionCopyWith<_DoctorAction> get copyWith => __$DoctorActionCopyWithImpl<_DoctorAction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DoctorActionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DoctorAction&&(identical(other.id, id) || other.id == id)&&(identical(other.eligible, eligible) || other.eligible == eligible)&&(identical(other.eligibilityReasonCode, eligibilityReasonCode) || other.eligibilityReasonCode == eligibilityReasonCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,eligible,eligibilityReasonCode);
}

@override
String toString() {
    return 'DoctorAction(id: $id, eligible: $eligible, eligibilityReasonCode: $eligibilityReasonCode)';
}


}

/// @nodoc
abstract mixin class _$DoctorActionCopyWith<$Res> implements $DoctorActionCopyWith<$Res> {
  factory _$DoctorActionCopyWith(_DoctorAction value, $Res Function(_DoctorAction) _then) = __$DoctorActionCopyWithImpl;
@override @useResult
$Res call({
 String id, bool eligible, String eligibilityReasonCode
});




}
/// @nodoc
class __$DoctorActionCopyWithImpl<$Res>
    implements _$DoctorActionCopyWith<$Res> {
  __$DoctorActionCopyWithImpl(this._self, this._then);

  final _DoctorAction _self;
  final $Res Function(_DoctorAction) _then;

/// Create a copy of DoctorAction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? eligible = null,Object? eligibilityReasonCode = null,}) {
  return _then(_DoctorAction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,eligible: null == eligible ? _self.eligible : eligible // ignore: cast_nullable_to_non_nullable
as bool,eligibilityReasonCode: null == eligibilityReasonCode ? _self.eligibilityReasonCode : eligibilityReasonCode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$DoctorHealAudit {

 String get actionId; int get at; String get outcome; int get beforeRevision; String get reexamId;
/// Create a copy of DoctorHealAudit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DoctorHealAuditCopyWith<DoctorHealAudit> get copyWith => _$DoctorHealAuditCopyWithImpl<DoctorHealAudit>(this as DoctorHealAudit, _$identity);

  /// Serializes this DoctorHealAudit to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DoctorHealAudit;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DoctorHealAudit&&(identical(other.actionId, _this.actionId) || other.actionId == _this.actionId)&&(identical(other.at, _this.at) || other.at == _this.at)&&(identical(other.outcome, _this.outcome) || other.outcome == _this.outcome)&&(identical(other.beforeRevision, _this.beforeRevision) || other.beforeRevision == _this.beforeRevision)&&(identical(other.reexamId, _this.reexamId) || other.reexamId == _this.reexamId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DoctorHealAudit;
  return Object.hash(runtimeType,_this.actionId,_this.at,_this.outcome,_this.beforeRevision,_this.reexamId);
}

@override
String toString() {
  final _this = this as DoctorHealAudit;
  return 'DoctorHealAudit(actionId: ${_this.actionId}, at: ${_this.at}, outcome: ${_this.outcome}, beforeRevision: ${_this.beforeRevision}, reexamId: ${_this.reexamId})';
}


}

/// @nodoc
abstract mixin class $DoctorHealAuditCopyWith<$Res>  {
  factory $DoctorHealAuditCopyWith(DoctorHealAudit value, $Res Function(DoctorHealAudit) _then) = _$DoctorHealAuditCopyWithImpl;
@useResult
$Res call({
 String actionId, int at, String outcome, int beforeRevision, String reexamId
});




}
/// @nodoc
class _$DoctorHealAuditCopyWithImpl<$Res>
    implements $DoctorHealAuditCopyWith<$Res> {
  _$DoctorHealAuditCopyWithImpl(this._self, this._then);

  final DoctorHealAudit _self;
  final $Res Function(DoctorHealAudit) _then;

/// Create a copy of DoctorHealAudit
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? actionId = null,Object? at = null,Object? outcome = null,Object? beforeRevision = null,Object? reexamId = null,}) {
  return _then(DoctorHealAudit(
actionId: null == actionId ? _self.actionId : actionId // ignore: cast_nullable_to_non_nullable
as String,at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as int,outcome: null == outcome ? _self.outcome : outcome // ignore: cast_nullable_to_non_nullable
as String,beforeRevision: null == beforeRevision ? _self.beforeRevision : beforeRevision // ignore: cast_nullable_to_non_nullable
as int,reexamId: null == reexamId ? _self.reexamId : reexamId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DoctorHealAudit].
extension DoctorHealAuditPatterns on DoctorHealAudit {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DoctorHealAudit value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DoctorHealAudit() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DoctorHealAudit value)  $default,){
final _that = this;
switch (_that) {
case _DoctorHealAudit():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DoctorHealAudit value)?  $default,){
final _that = this;
switch (_that) {
case _DoctorHealAudit() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String actionId,  int at,  String outcome,  int beforeRevision,  String reexamId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DoctorHealAudit() when $default != null:
return $default(_that.actionId,_that.at,_that.outcome,_that.beforeRevision,_that.reexamId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String actionId,  int at,  String outcome,  int beforeRevision,  String reexamId)  $default,) {final _that = this;
switch (_that) {
case _DoctorHealAudit():
return $default(_that.actionId,_that.at,_that.outcome,_that.beforeRevision,_that.reexamId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String actionId,  int at,  String outcome,  int beforeRevision,  String reexamId)?  $default,) {final _that = this;
switch (_that) {
case _DoctorHealAudit() when $default != null:
return $default(_that.actionId,_that.at,_that.outcome,_that.beforeRevision,_that.reexamId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DoctorHealAudit implements DoctorHealAudit {
  const _DoctorHealAudit({required this.actionId, this.at = 0, this.outcome = '', this.beforeRevision = 0, this.reexamId = ''});
  factory _DoctorHealAudit.fromJson(Map<String, dynamic> json) => _$DoctorHealAuditFromJson(json);

@override final  String actionId;
@override@JsonKey() final  int at;
@override@JsonKey() final  String outcome;
@override@JsonKey() final  int beforeRevision;
@override@JsonKey() final  String reexamId;

/// Create a copy of DoctorHealAudit
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DoctorHealAuditCopyWith<_DoctorHealAudit> get copyWith => __$DoctorHealAuditCopyWithImpl<_DoctorHealAudit>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DoctorHealAuditToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DoctorHealAudit&&(identical(other.actionId, actionId) || other.actionId == actionId)&&(identical(other.at, at) || other.at == at)&&(identical(other.outcome, outcome) || other.outcome == outcome)&&(identical(other.beforeRevision, beforeRevision) || other.beforeRevision == beforeRevision)&&(identical(other.reexamId, reexamId) || other.reexamId == reexamId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,actionId,at,outcome,beforeRevision,reexamId);
}

@override
String toString() {
    return 'DoctorHealAudit(actionId: $actionId, at: $at, outcome: $outcome, beforeRevision: $beforeRevision, reexamId: $reexamId)';
}


}

/// @nodoc
abstract mixin class _$DoctorHealAuditCopyWith<$Res> implements $DoctorHealAuditCopyWith<$Res> {
  factory _$DoctorHealAuditCopyWith(_DoctorHealAudit value, $Res Function(_DoctorHealAudit) _then) = __$DoctorHealAuditCopyWithImpl;
@override @useResult
$Res call({
 String actionId, int at, String outcome, int beforeRevision, String reexamId
});




}
/// @nodoc
class __$DoctorHealAuditCopyWithImpl<$Res>
    implements _$DoctorHealAuditCopyWith<$Res> {
  __$DoctorHealAuditCopyWithImpl(this._self, this._then);

  final _DoctorHealAudit _self;
  final $Res Function(_DoctorHealAudit) _then;

/// Create a copy of DoctorHealAudit
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? actionId = null,Object? at = null,Object? outcome = null,Object? beforeRevision = null,Object? reexamId = null,}) {
  return _then(_DoctorHealAudit(
actionId: null == actionId ? _self.actionId : actionId // ignore: cast_nullable_to_non_nullable
as String,at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as int,outcome: null == outcome ? _self.outcome : outcome // ignore: cast_nullable_to_non_nullable
as String,beforeRevision: null == beforeRevision ? _self.beforeRevision : beforeRevision // ignore: cast_nullable_to_non_nullable
as int,reexamId: null == reexamId ? _self.reexamId : reexamId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$DoctorIncident {

 String get examId;@JsonKey(unknownEnumValue: DoctorExamMode.unknown) DoctorExamMode get mode;@JsonKey(unknownEnumValue: DoctorExamState.unknown) DoctorExamState get state;@JsonKey(unknownEnumValue: DoctorHealth.unknown) DoctorHealth get health;@JsonKey(unknownEnumValue: DoctorConfidence.unknown) DoctorConfidence get confidence; String get causeCode;@JsonKey(unknownEnumValue: DoctorLayer.unknown) DoctorLayer get layer; int get startedAt; int get finishedAt;
/// Create a copy of DoctorIncident
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DoctorIncidentCopyWith<DoctorIncident> get copyWith => _$DoctorIncidentCopyWithImpl<DoctorIncident>(this as DoctorIncident, _$identity);

  /// Serializes this DoctorIncident to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DoctorIncident;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DoctorIncident&&(identical(other.examId, _this.examId) || other.examId == _this.examId)&&(identical(other.mode, _this.mode) || other.mode == _this.mode)&&(identical(other.state, _this.state) || other.state == _this.state)&&(identical(other.health, _this.health) || other.health == _this.health)&&(identical(other.confidence, _this.confidence) || other.confidence == _this.confidence)&&(identical(other.causeCode, _this.causeCode) || other.causeCode == _this.causeCode)&&(identical(other.layer, _this.layer) || other.layer == _this.layer)&&(identical(other.startedAt, _this.startedAt) || other.startedAt == _this.startedAt)&&(identical(other.finishedAt, _this.finishedAt) || other.finishedAt == _this.finishedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DoctorIncident;
  return Object.hash(runtimeType,_this.examId,_this.mode,_this.state,_this.health,_this.confidence,_this.causeCode,_this.layer,_this.startedAt,_this.finishedAt);
}

@override
String toString() {
  final _this = this as DoctorIncident;
  return 'DoctorIncident(examId: ${_this.examId}, mode: ${_this.mode}, state: ${_this.state}, health: ${_this.health}, confidence: ${_this.confidence}, causeCode: ${_this.causeCode}, layer: ${_this.layer}, startedAt: ${_this.startedAt}, finishedAt: ${_this.finishedAt})';
}


}

/// @nodoc
abstract mixin class $DoctorIncidentCopyWith<$Res>  {
  factory $DoctorIncidentCopyWith(DoctorIncident value, $Res Function(DoctorIncident) _then) = _$DoctorIncidentCopyWithImpl;
@useResult
$Res call({
 String examId,@JsonKey(unknownEnumValue: DoctorExamMode.unknown) DoctorExamMode mode,@JsonKey(unknownEnumValue: DoctorExamState.unknown) DoctorExamState state,@JsonKey(unknownEnumValue: DoctorHealth.unknown) DoctorHealth health,@JsonKey(unknownEnumValue: DoctorConfidence.unknown) DoctorConfidence confidence, String causeCode,@JsonKey(unknownEnumValue: DoctorLayer.unknown) DoctorLayer layer, int startedAt, int finishedAt
});




}
/// @nodoc
class _$DoctorIncidentCopyWithImpl<$Res>
    implements $DoctorIncidentCopyWith<$Res> {
  _$DoctorIncidentCopyWithImpl(this._self, this._then);

  final DoctorIncident _self;
  final $Res Function(DoctorIncident) _then;

/// Create a copy of DoctorIncident
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? examId = null,Object? mode = null,Object? state = null,Object? health = null,Object? confidence = null,Object? causeCode = null,Object? layer = null,Object? startedAt = null,Object? finishedAt = null,}) {
  return _then(DoctorIncident(
examId: null == examId ? _self.examId : examId // ignore: cast_nullable_to_non_nullable
as String,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as DoctorExamMode,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as DoctorExamState,health: null == health ? _self.health : health // ignore: cast_nullable_to_non_nullable
as DoctorHealth,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as DoctorConfidence,causeCode: null == causeCode ? _self.causeCode : causeCode // ignore: cast_nullable_to_non_nullable
as String,layer: null == layer ? _self.layer : layer // ignore: cast_nullable_to_non_nullable
as DoctorLayer,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as int,finishedAt: null == finishedAt ? _self.finishedAt : finishedAt // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DoctorIncident].
extension DoctorIncidentPatterns on DoctorIncident {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DoctorIncident value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DoctorIncident() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DoctorIncident value)  $default,){
final _that = this;
switch (_that) {
case _DoctorIncident():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DoctorIncident value)?  $default,){
final _that = this;
switch (_that) {
case _DoctorIncident() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String examId, @JsonKey(unknownEnumValue: DoctorExamMode.unknown)  DoctorExamMode mode, @JsonKey(unknownEnumValue: DoctorExamState.unknown)  DoctorExamState state, @JsonKey(unknownEnumValue: DoctorHealth.unknown)  DoctorHealth health, @JsonKey(unknownEnumValue: DoctorConfidence.unknown)  DoctorConfidence confidence,  String causeCode, @JsonKey(unknownEnumValue: DoctorLayer.unknown)  DoctorLayer layer,  int startedAt,  int finishedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DoctorIncident() when $default != null:
return $default(_that.examId,_that.mode,_that.state,_that.health,_that.confidence,_that.causeCode,_that.layer,_that.startedAt,_that.finishedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String examId, @JsonKey(unknownEnumValue: DoctorExamMode.unknown)  DoctorExamMode mode, @JsonKey(unknownEnumValue: DoctorExamState.unknown)  DoctorExamState state, @JsonKey(unknownEnumValue: DoctorHealth.unknown)  DoctorHealth health, @JsonKey(unknownEnumValue: DoctorConfidence.unknown)  DoctorConfidence confidence,  String causeCode, @JsonKey(unknownEnumValue: DoctorLayer.unknown)  DoctorLayer layer,  int startedAt,  int finishedAt)  $default,) {final _that = this;
switch (_that) {
case _DoctorIncident():
return $default(_that.examId,_that.mode,_that.state,_that.health,_that.confidence,_that.causeCode,_that.layer,_that.startedAt,_that.finishedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String examId, @JsonKey(unknownEnumValue: DoctorExamMode.unknown)  DoctorExamMode mode, @JsonKey(unknownEnumValue: DoctorExamState.unknown)  DoctorExamState state, @JsonKey(unknownEnumValue: DoctorHealth.unknown)  DoctorHealth health, @JsonKey(unknownEnumValue: DoctorConfidence.unknown)  DoctorConfidence confidence,  String causeCode, @JsonKey(unknownEnumValue: DoctorLayer.unknown)  DoctorLayer layer,  int startedAt,  int finishedAt)?  $default,) {final _that = this;
switch (_that) {
case _DoctorIncident() when $default != null:
return $default(_that.examId,_that.mode,_that.state,_that.health,_that.confidence,_that.causeCode,_that.layer,_that.startedAt,_that.finishedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DoctorIncident implements DoctorIncident {
  const _DoctorIncident({this.examId = '', @JsonKey(unknownEnumValue: DoctorExamMode.unknown) this.mode = DoctorExamMode.unknown, @JsonKey(unknownEnumValue: DoctorExamState.unknown) this.state = DoctorExamState.unknown, @JsonKey(unknownEnumValue: DoctorHealth.unknown) this.health = DoctorHealth.unknown, @JsonKey(unknownEnumValue: DoctorConfidence.unknown) this.confidence = DoctorConfidence.unknown, this.causeCode = '', @JsonKey(unknownEnumValue: DoctorLayer.unknown) this.layer = DoctorLayer.unknown, this.startedAt = 0, this.finishedAt = 0});
  factory _DoctorIncident.fromJson(Map<String, dynamic> json) => _$DoctorIncidentFromJson(json);

@override@JsonKey() final  String examId;
@override@JsonKey(unknownEnumValue: DoctorExamMode.unknown) final  DoctorExamMode mode;
@override@JsonKey(unknownEnumValue: DoctorExamState.unknown) final  DoctorExamState state;
@override@JsonKey(unknownEnumValue: DoctorHealth.unknown) final  DoctorHealth health;
@override@JsonKey(unknownEnumValue: DoctorConfidence.unknown) final  DoctorConfidence confidence;
@override@JsonKey() final  String causeCode;
@override@JsonKey(unknownEnumValue: DoctorLayer.unknown) final  DoctorLayer layer;
@override@JsonKey() final  int startedAt;
@override@JsonKey() final  int finishedAt;

/// Create a copy of DoctorIncident
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DoctorIncidentCopyWith<_DoctorIncident> get copyWith => __$DoctorIncidentCopyWithImpl<_DoctorIncident>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DoctorIncidentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DoctorIncident&&(identical(other.examId, examId) || other.examId == examId)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.state, state) || other.state == state)&&(identical(other.health, health) || other.health == health)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.causeCode, causeCode) || other.causeCode == causeCode)&&(identical(other.layer, layer) || other.layer == layer)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.finishedAt, finishedAt) || other.finishedAt == finishedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,examId,mode,state,health,confidence,causeCode,layer,startedAt,finishedAt);
}

@override
String toString() {
    return 'DoctorIncident(examId: $examId, mode: $mode, state: $state, health: $health, confidence: $confidence, causeCode: $causeCode, layer: $layer, startedAt: $startedAt, finishedAt: $finishedAt)';
}


}

/// @nodoc
abstract mixin class _$DoctorIncidentCopyWith<$Res> implements $DoctorIncidentCopyWith<$Res> {
  factory _$DoctorIncidentCopyWith(_DoctorIncident value, $Res Function(_DoctorIncident) _then) = __$DoctorIncidentCopyWithImpl;
@override @useResult
$Res call({
 String examId,@JsonKey(unknownEnumValue: DoctorExamMode.unknown) DoctorExamMode mode,@JsonKey(unknownEnumValue: DoctorExamState.unknown) DoctorExamState state,@JsonKey(unknownEnumValue: DoctorHealth.unknown) DoctorHealth health,@JsonKey(unknownEnumValue: DoctorConfidence.unknown) DoctorConfidence confidence, String causeCode,@JsonKey(unknownEnumValue: DoctorLayer.unknown) DoctorLayer layer, int startedAt, int finishedAt
});




}
/// @nodoc
class __$DoctorIncidentCopyWithImpl<$Res>
    implements _$DoctorIncidentCopyWith<$Res> {
  __$DoctorIncidentCopyWithImpl(this._self, this._then);

  final _DoctorIncident _self;
  final $Res Function(_DoctorIncident) _then;

/// Create a copy of DoctorIncident
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? examId = null,Object? mode = null,Object? state = null,Object? health = null,Object? confidence = null,Object? causeCode = null,Object? layer = null,Object? startedAt = null,Object? finishedAt = null,}) {
  return _then(_DoctorIncident(
examId: null == examId ? _self.examId : examId // ignore: cast_nullable_to_non_nullable
as String,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as DoctorExamMode,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as DoctorExamState,health: null == health ? _self.health : health // ignore: cast_nullable_to_non_nullable
as DoctorHealth,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as DoctorConfidence,causeCode: null == causeCode ? _self.causeCode : causeCode // ignore: cast_nullable_to_non_nullable
as String,layer: null == layer ? _self.layer : layer // ignore: cast_nullable_to_non_nullable
as DoctorLayer,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as int,finishedAt: null == finishedAt ? _self.finishedAt : finishedAt // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$DoctorProgress {

 String get phase; int get completed; int get total;
/// Create a copy of DoctorProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DoctorProgressCopyWith<DoctorProgress> get copyWith => _$DoctorProgressCopyWithImpl<DoctorProgress>(this as DoctorProgress, _$identity);

  /// Serializes this DoctorProgress to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DoctorProgress;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DoctorProgress&&(identical(other.phase, _this.phase) || other.phase == _this.phase)&&(identical(other.completed, _this.completed) || other.completed == _this.completed)&&(identical(other.total, _this.total) || other.total == _this.total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DoctorProgress;
  return Object.hash(runtimeType,_this.phase,_this.completed,_this.total);
}

@override
String toString() {
  final _this = this as DoctorProgress;
  return 'DoctorProgress(phase: ${_this.phase}, completed: ${_this.completed}, total: ${_this.total})';
}


}

/// @nodoc
abstract mixin class $DoctorProgressCopyWith<$Res>  {
  factory $DoctorProgressCopyWith(DoctorProgress value, $Res Function(DoctorProgress) _then) = _$DoctorProgressCopyWithImpl;
@useResult
$Res call({
 String phase, int completed, int total
});




}
/// @nodoc
class _$DoctorProgressCopyWithImpl<$Res>
    implements $DoctorProgressCopyWith<$Res> {
  _$DoctorProgressCopyWithImpl(this._self, this._then);

  final DoctorProgress _self;
  final $Res Function(DoctorProgress) _then;

/// Create a copy of DoctorProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? phase = null,Object? completed = null,Object? total = null,}) {
  return _then(DoctorProgress(
phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as String,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DoctorProgress].
extension DoctorProgressPatterns on DoctorProgress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DoctorProgress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DoctorProgress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DoctorProgress value)  $default,){
final _that = this;
switch (_that) {
case _DoctorProgress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DoctorProgress value)?  $default,){
final _that = this;
switch (_that) {
case _DoctorProgress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String phase,  int completed,  int total)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DoctorProgress() when $default != null:
return $default(_that.phase,_that.completed,_that.total);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String phase,  int completed,  int total)  $default,) {final _that = this;
switch (_that) {
case _DoctorProgress():
return $default(_that.phase,_that.completed,_that.total);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String phase,  int completed,  int total)?  $default,) {final _that = this;
switch (_that) {
case _DoctorProgress() when $default != null:
return $default(_that.phase,_that.completed,_that.total);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DoctorProgress implements DoctorProgress {
  const _DoctorProgress({this.phase = '', this.completed = 0, this.total = 0});
  factory _DoctorProgress.fromJson(Map<String, dynamic> json) => _$DoctorProgressFromJson(json);

@override@JsonKey() final  String phase;
@override@JsonKey() final  int completed;
@override@JsonKey() final  int total;

/// Create a copy of DoctorProgress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DoctorProgressCopyWith<_DoctorProgress> get copyWith => __$DoctorProgressCopyWithImpl<_DoctorProgress>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DoctorProgressToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DoctorProgress&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.completed, completed) || other.completed == completed)&&(identical(other.total, total) || other.total == total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,phase,completed,total);
}

@override
String toString() {
    return 'DoctorProgress(phase: $phase, completed: $completed, total: $total)';
}


}

/// @nodoc
abstract mixin class _$DoctorProgressCopyWith<$Res> implements $DoctorProgressCopyWith<$Res> {
  factory _$DoctorProgressCopyWith(_DoctorProgress value, $Res Function(_DoctorProgress) _then) = __$DoctorProgressCopyWithImpl;
@override @useResult
$Res call({
 String phase, int completed, int total
});




}
/// @nodoc
class __$DoctorProgressCopyWithImpl<$Res>
    implements _$DoctorProgressCopyWith<$Res> {
  __$DoctorProgressCopyWithImpl(this._self, this._then);

  final _DoctorProgress _self;
  final $Res Function(_DoctorProgress) _then;

/// Create a copy of DoctorProgress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? phase = null,Object? completed = null,Object? total = null,}) {
  return _then(_DoctorProgress(
phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as String,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$DoctorSnapshot {

 int get schemaVersion; int get revision; bool get supported; DoctorCapabilities get capabilities;@JsonKey(unknownEnumValue: DoctorExamState.unknown) DoctorExamState get state;@JsonKey(unknownEnumValue: DoctorHealth.unknown) DoctorHealth get health;@JsonKey(unknownEnumValue: DoctorConfidence.unknown) DoctorConfidence get confidence;@JsonKey(unknownEnumValue: DoctorSeverity.unknown) DoctorSeverity get severity;@JsonKey(unknownEnumValue: DoctorScope.unknown) DoctorScope get scope;@JsonKey(unknownEnumValue: DoctorPathKind.unknown) DoctorPathKind get pathKind;@JsonKey(unknownEnumValue: DoctorCaptureState.unknown) DoctorCaptureState get captureState; List<DoctorStage> get stages; String get examId;@JsonKey(unknownEnumValue: DoctorExamMode.unknown) DoctorExamMode get mode; String get causeCode;@JsonKey(unknownEnumValue: DoctorLayer.unknown) DoctorLayer get layer; DoctorProgress get progress; DoctorGenerations get generations; DoctorGenerations get startGenerations; int get startedAt; int get updatedAt; int get freshUntil; int get evidenceDropped; List<DoctorEvidence> get evidence; List<DoctorAction> get actions; List<DoctorHealAudit> get healAudit; List<DoctorIncident> get incidents;
/// Create a copy of DoctorSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DoctorSnapshotCopyWith<DoctorSnapshot> get copyWith => _$DoctorSnapshotCopyWithImpl<DoctorSnapshot>(this as DoctorSnapshot, _$identity);

  /// Serializes this DoctorSnapshot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DoctorSnapshot;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DoctorSnapshot&&(identical(other.schemaVersion, _this.schemaVersion) || other.schemaVersion == _this.schemaVersion)&&(identical(other.revision, _this.revision) || other.revision == _this.revision)&&(identical(other.supported, _this.supported) || other.supported == _this.supported)&&(identical(other.capabilities, _this.capabilities) || other.capabilities == _this.capabilities)&&(identical(other.state, _this.state) || other.state == _this.state)&&(identical(other.health, _this.health) || other.health == _this.health)&&(identical(other.confidence, _this.confidence) || other.confidence == _this.confidence)&&(identical(other.severity, _this.severity) || other.severity == _this.severity)&&(identical(other.scope, _this.scope) || other.scope == _this.scope)&&(identical(other.pathKind, _this.pathKind) || other.pathKind == _this.pathKind)&&(identical(other.captureState, _this.captureState) || other.captureState == _this.captureState)&&const DeepCollectionEquality().equals(other.stages, _this.stages)&&(identical(other.examId, _this.examId) || other.examId == _this.examId)&&(identical(other.mode, _this.mode) || other.mode == _this.mode)&&(identical(other.causeCode, _this.causeCode) || other.causeCode == _this.causeCode)&&(identical(other.layer, _this.layer) || other.layer == _this.layer)&&(identical(other.progress, _this.progress) || other.progress == _this.progress)&&(identical(other.generations, _this.generations) || other.generations == _this.generations)&&(identical(other.startGenerations, _this.startGenerations) || other.startGenerations == _this.startGenerations)&&(identical(other.startedAt, _this.startedAt) || other.startedAt == _this.startedAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.freshUntil, _this.freshUntil) || other.freshUntil == _this.freshUntil)&&(identical(other.evidenceDropped, _this.evidenceDropped) || other.evidenceDropped == _this.evidenceDropped)&&const DeepCollectionEquality().equals(other.evidence, _this.evidence)&&const DeepCollectionEquality().equals(other.actions, _this.actions)&&const DeepCollectionEquality().equals(other.healAudit, _this.healAudit)&&const DeepCollectionEquality().equals(other.incidents, _this.incidents));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DoctorSnapshot;
  return Object.hashAll([runtimeType,_this.schemaVersion,_this.revision,_this.supported,_this.capabilities,_this.state,_this.health,_this.confidence,_this.severity,_this.scope,_this.pathKind,_this.captureState,const DeepCollectionEquality().hash(_this.stages),_this.examId,_this.mode,_this.causeCode,_this.layer,_this.progress,_this.generations,_this.startGenerations,_this.startedAt,_this.updatedAt,_this.freshUntil,_this.evidenceDropped,const DeepCollectionEquality().hash(_this.evidence),const DeepCollectionEquality().hash(_this.actions),const DeepCollectionEquality().hash(_this.healAudit),const DeepCollectionEquality().hash(_this.incidents)]);
}

@override
String toString() {
  final _this = this as DoctorSnapshot;
  return 'DoctorSnapshot(schemaVersion: ${_this.schemaVersion}, revision: ${_this.revision}, supported: ${_this.supported}, capabilities: ${_this.capabilities}, state: ${_this.state}, health: ${_this.health}, confidence: ${_this.confidence}, severity: ${_this.severity}, scope: ${_this.scope}, pathKind: ${_this.pathKind}, captureState: ${_this.captureState}, stages: ${_this.stages}, examId: ${_this.examId}, mode: ${_this.mode}, causeCode: ${_this.causeCode}, layer: ${_this.layer}, progress: ${_this.progress}, generations: ${_this.generations}, startGenerations: ${_this.startGenerations}, startedAt: ${_this.startedAt}, updatedAt: ${_this.updatedAt}, freshUntil: ${_this.freshUntil}, evidenceDropped: ${_this.evidenceDropped}, evidence: ${_this.evidence}, actions: ${_this.actions}, healAudit: ${_this.healAudit}, incidents: ${_this.incidents})';
}


}

/// @nodoc
abstract mixin class $DoctorSnapshotCopyWith<$Res>  {
  factory $DoctorSnapshotCopyWith(DoctorSnapshot value, $Res Function(DoctorSnapshot) _then) = _$DoctorSnapshotCopyWithImpl;
@useResult
$Res call({
 int schemaVersion, int revision, bool supported, DoctorCapabilities capabilities,@JsonKey(unknownEnumValue: DoctorExamState.unknown) DoctorExamState state,@JsonKey(unknownEnumValue: DoctorHealth.unknown) DoctorHealth health,@JsonKey(unknownEnumValue: DoctorConfidence.unknown) DoctorConfidence confidence,@JsonKey(unknownEnumValue: DoctorSeverity.unknown) DoctorSeverity severity,@JsonKey(unknownEnumValue: DoctorScope.unknown) DoctorScope scope,@JsonKey(unknownEnumValue: DoctorPathKind.unknown) DoctorPathKind pathKind,@JsonKey(unknownEnumValue: DoctorCaptureState.unknown) DoctorCaptureState captureState, List<DoctorStage> stages, String examId,@JsonKey(unknownEnumValue: DoctorExamMode.unknown) DoctorExamMode mode, String causeCode,@JsonKey(unknownEnumValue: DoctorLayer.unknown) DoctorLayer layer, DoctorProgress progress, DoctorGenerations generations, DoctorGenerations startGenerations, int startedAt, int updatedAt, int freshUntil, int evidenceDropped, List<DoctorEvidence> evidence, List<DoctorAction> actions, List<DoctorHealAudit> healAudit, List<DoctorIncident> incidents
});


$DoctorCapabilitiesCopyWith<$Res> get capabilities;$DoctorProgressCopyWith<$Res> get progress;$DoctorGenerationsCopyWith<$Res> get generations;$DoctorGenerationsCopyWith<$Res> get startGenerations;

}
/// @nodoc
class _$DoctorSnapshotCopyWithImpl<$Res>
    implements $DoctorSnapshotCopyWith<$Res> {
  _$DoctorSnapshotCopyWithImpl(this._self, this._then);

  final DoctorSnapshot _self;
  final $Res Function(DoctorSnapshot) _then;

/// Create a copy of DoctorSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? revision = null,Object? supported = null,Object? capabilities = null,Object? state = null,Object? health = null,Object? confidence = null,Object? severity = null,Object? scope = null,Object? pathKind = null,Object? captureState = null,Object? stages = null,Object? examId = null,Object? mode = null,Object? causeCode = null,Object? layer = null,Object? progress = null,Object? generations = null,Object? startGenerations = null,Object? startedAt = null,Object? updatedAt = null,Object? freshUntil = null,Object? evidenceDropped = null,Object? evidence = null,Object? actions = null,Object? healAudit = null,Object? incidents = null,}) {
  return _then(DoctorSnapshot(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,revision: null == revision ? _self.revision : revision // ignore: cast_nullable_to_non_nullable
as int,supported: null == supported ? _self.supported : supported // ignore: cast_nullable_to_non_nullable
as bool,capabilities: null == capabilities ? _self.capabilities : capabilities // ignore: cast_nullable_to_non_nullable
as DoctorCapabilities,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as DoctorExamState,health: null == health ? _self.health : health // ignore: cast_nullable_to_non_nullable
as DoctorHealth,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as DoctorConfidence,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as DoctorSeverity,scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as DoctorScope,pathKind: null == pathKind ? _self.pathKind : pathKind // ignore: cast_nullable_to_non_nullable
as DoctorPathKind,captureState: null == captureState ? _self.captureState : captureState // ignore: cast_nullable_to_non_nullable
as DoctorCaptureState,stages: null == stages ? _self.stages : stages // ignore: cast_nullable_to_non_nullable
as List<DoctorStage>,examId: null == examId ? _self.examId : examId // ignore: cast_nullable_to_non_nullable
as String,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as DoctorExamMode,causeCode: null == causeCode ? _self.causeCode : causeCode // ignore: cast_nullable_to_non_nullable
as String,layer: null == layer ? _self.layer : layer // ignore: cast_nullable_to_non_nullable
as DoctorLayer,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as DoctorProgress,generations: null == generations ? _self.generations : generations // ignore: cast_nullable_to_non_nullable
as DoctorGenerations,startGenerations: null == startGenerations ? _self.startGenerations : startGenerations // ignore: cast_nullable_to_non_nullable
as DoctorGenerations,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as int,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as int,freshUntil: null == freshUntil ? _self.freshUntil : freshUntil // ignore: cast_nullable_to_non_nullable
as int,evidenceDropped: null == evidenceDropped ? _self.evidenceDropped : evidenceDropped // ignore: cast_nullable_to_non_nullable
as int,evidence: null == evidence ? _self.evidence : evidence // ignore: cast_nullable_to_non_nullable
as List<DoctorEvidence>,actions: null == actions ? _self.actions : actions // ignore: cast_nullable_to_non_nullable
as List<DoctorAction>,healAudit: null == healAudit ? _self.healAudit : healAudit // ignore: cast_nullable_to_non_nullable
as List<DoctorHealAudit>,incidents: null == incidents ? _self.incidents : incidents // ignore: cast_nullable_to_non_nullable
as List<DoctorIncident>,
  ));
}
/// Create a copy of DoctorSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DoctorCapabilitiesCopyWith<$Res> get capabilities {
  
  return $DoctorCapabilitiesCopyWith<$Res>(_self.capabilities, (value) {
    return _then(_self.copyWith(capabilities: value));
  });
}/// Create a copy of DoctorSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DoctorProgressCopyWith<$Res> get progress {
  
  return $DoctorProgressCopyWith<$Res>(_self.progress, (value) {
    return _then(_self.copyWith(progress: value));
  });
}/// Create a copy of DoctorSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DoctorGenerationsCopyWith<$Res> get generations {
  
  return $DoctorGenerationsCopyWith<$Res>(_self.generations, (value) {
    return _then(_self.copyWith(generations: value));
  });
}/// Create a copy of DoctorSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DoctorGenerationsCopyWith<$Res> get startGenerations {
  
  return $DoctorGenerationsCopyWith<$Res>(_self.startGenerations, (value) {
    return _then(_self.copyWith(startGenerations: value));
  });
}
}


/// Adds pattern-matching-related methods to [DoctorSnapshot].
extension DoctorSnapshotPatterns on DoctorSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DoctorSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DoctorSnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DoctorSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _DoctorSnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DoctorSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _DoctorSnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int schemaVersion,  int revision,  bool supported,  DoctorCapabilities capabilities, @JsonKey(unknownEnumValue: DoctorExamState.unknown)  DoctorExamState state, @JsonKey(unknownEnumValue: DoctorHealth.unknown)  DoctorHealth health, @JsonKey(unknownEnumValue: DoctorConfidence.unknown)  DoctorConfidence confidence, @JsonKey(unknownEnumValue: DoctorSeverity.unknown)  DoctorSeverity severity, @JsonKey(unknownEnumValue: DoctorScope.unknown)  DoctorScope scope, @JsonKey(unknownEnumValue: DoctorPathKind.unknown)  DoctorPathKind pathKind, @JsonKey(unknownEnumValue: DoctorCaptureState.unknown)  DoctorCaptureState captureState,  List<DoctorStage> stages,  String examId, @JsonKey(unknownEnumValue: DoctorExamMode.unknown)  DoctorExamMode mode,  String causeCode, @JsonKey(unknownEnumValue: DoctorLayer.unknown)  DoctorLayer layer,  DoctorProgress progress,  DoctorGenerations generations,  DoctorGenerations startGenerations,  int startedAt,  int updatedAt,  int freshUntil,  int evidenceDropped,  List<DoctorEvidence> evidence,  List<DoctorAction> actions,  List<DoctorHealAudit> healAudit,  List<DoctorIncident> incidents)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DoctorSnapshot() when $default != null:
return $default(_that.schemaVersion,_that.revision,_that.supported,_that.capabilities,_that.state,_that.health,_that.confidence,_that.severity,_that.scope,_that.pathKind,_that.captureState,_that.stages,_that.examId,_that.mode,_that.causeCode,_that.layer,_that.progress,_that.generations,_that.startGenerations,_that.startedAt,_that.updatedAt,_that.freshUntil,_that.evidenceDropped,_that.evidence,_that.actions,_that.healAudit,_that.incidents);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int schemaVersion,  int revision,  bool supported,  DoctorCapabilities capabilities, @JsonKey(unknownEnumValue: DoctorExamState.unknown)  DoctorExamState state, @JsonKey(unknownEnumValue: DoctorHealth.unknown)  DoctorHealth health, @JsonKey(unknownEnumValue: DoctorConfidence.unknown)  DoctorConfidence confidence, @JsonKey(unknownEnumValue: DoctorSeverity.unknown)  DoctorSeverity severity, @JsonKey(unknownEnumValue: DoctorScope.unknown)  DoctorScope scope, @JsonKey(unknownEnumValue: DoctorPathKind.unknown)  DoctorPathKind pathKind, @JsonKey(unknownEnumValue: DoctorCaptureState.unknown)  DoctorCaptureState captureState,  List<DoctorStage> stages,  String examId, @JsonKey(unknownEnumValue: DoctorExamMode.unknown)  DoctorExamMode mode,  String causeCode, @JsonKey(unknownEnumValue: DoctorLayer.unknown)  DoctorLayer layer,  DoctorProgress progress,  DoctorGenerations generations,  DoctorGenerations startGenerations,  int startedAt,  int updatedAt,  int freshUntil,  int evidenceDropped,  List<DoctorEvidence> evidence,  List<DoctorAction> actions,  List<DoctorHealAudit> healAudit,  List<DoctorIncident> incidents)  $default,) {final _that = this;
switch (_that) {
case _DoctorSnapshot():
return $default(_that.schemaVersion,_that.revision,_that.supported,_that.capabilities,_that.state,_that.health,_that.confidence,_that.severity,_that.scope,_that.pathKind,_that.captureState,_that.stages,_that.examId,_that.mode,_that.causeCode,_that.layer,_that.progress,_that.generations,_that.startGenerations,_that.startedAt,_that.updatedAt,_that.freshUntil,_that.evidenceDropped,_that.evidence,_that.actions,_that.healAudit,_that.incidents);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int schemaVersion,  int revision,  bool supported,  DoctorCapabilities capabilities, @JsonKey(unknownEnumValue: DoctorExamState.unknown)  DoctorExamState state, @JsonKey(unknownEnumValue: DoctorHealth.unknown)  DoctorHealth health, @JsonKey(unknownEnumValue: DoctorConfidence.unknown)  DoctorConfidence confidence, @JsonKey(unknownEnumValue: DoctorSeverity.unknown)  DoctorSeverity severity, @JsonKey(unknownEnumValue: DoctorScope.unknown)  DoctorScope scope, @JsonKey(unknownEnumValue: DoctorPathKind.unknown)  DoctorPathKind pathKind, @JsonKey(unknownEnumValue: DoctorCaptureState.unknown)  DoctorCaptureState captureState,  List<DoctorStage> stages,  String examId, @JsonKey(unknownEnumValue: DoctorExamMode.unknown)  DoctorExamMode mode,  String causeCode, @JsonKey(unknownEnumValue: DoctorLayer.unknown)  DoctorLayer layer,  DoctorProgress progress,  DoctorGenerations generations,  DoctorGenerations startGenerations,  int startedAt,  int updatedAt,  int freshUntil,  int evidenceDropped,  List<DoctorEvidence> evidence,  List<DoctorAction> actions,  List<DoctorHealAudit> healAudit,  List<DoctorIncident> incidents)?  $default,) {final _that = this;
switch (_that) {
case _DoctorSnapshot() when $default != null:
return $default(_that.schemaVersion,_that.revision,_that.supported,_that.capabilities,_that.state,_that.health,_that.confidence,_that.severity,_that.scope,_that.pathKind,_that.captureState,_that.stages,_that.examId,_that.mode,_that.causeCode,_that.layer,_that.progress,_that.generations,_that.startGenerations,_that.startedAt,_that.updatedAt,_that.freshUntil,_that.evidenceDropped,_that.evidence,_that.actions,_that.healAudit,_that.incidents);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DoctorSnapshot extends DoctorSnapshot {
  const _DoctorSnapshot({this.schemaVersion = 1, this.revision = 0, this.supported = false, this.capabilities = const DoctorCapabilities(), @JsonKey(unknownEnumValue: DoctorExamState.unknown) this.state = DoctorExamState.unknown, @JsonKey(unknownEnumValue: DoctorHealth.unknown) this.health = DoctorHealth.unknown, @JsonKey(unknownEnumValue: DoctorConfidence.unknown) this.confidence = DoctorConfidence.unknown, @JsonKey(unknownEnumValue: DoctorSeverity.unknown) this.severity = DoctorSeverity.unknown, @JsonKey(unknownEnumValue: DoctorScope.unknown) this.scope = DoctorScope.unknown, @JsonKey(unknownEnumValue: DoctorPathKind.unknown) this.pathKind = DoctorPathKind.unknown, @JsonKey(unknownEnumValue: DoctorCaptureState.unknown) this.captureState = DoctorCaptureState.unknown,  List<DoctorStage> stages = const [], this.examId = '', @JsonKey(unknownEnumValue: DoctorExamMode.unknown) this.mode = DoctorExamMode.unknown, this.causeCode = '', @JsonKey(unknownEnumValue: DoctorLayer.unknown) this.layer = DoctorLayer.unknown, this.progress = const DoctorProgress(), this.generations = const DoctorGenerations(), this.startGenerations = const DoctorGenerations(), this.startedAt = 0, this.updatedAt = 0, this.freshUntil = 0, this.evidenceDropped = 0,  List<DoctorEvidence> evidence = const [],  List<DoctorAction> actions = const [],  List<DoctorHealAudit> healAudit = const [],  List<DoctorIncident> incidents = const []}): _stages = stages,_evidence = evidence,_actions = actions,_healAudit = healAudit,_incidents = incidents,super._();
  factory _DoctorSnapshot.fromJson(Map<String, dynamic> json) => _$DoctorSnapshotFromJson(json);

@override@JsonKey() final  int schemaVersion;
@override@JsonKey() final  int revision;
@override@JsonKey() final  bool supported;
@override@JsonKey() final  DoctorCapabilities capabilities;
@override@JsonKey(unknownEnumValue: DoctorExamState.unknown) final  DoctorExamState state;
@override@JsonKey(unknownEnumValue: DoctorHealth.unknown) final  DoctorHealth health;
@override@JsonKey(unknownEnumValue: DoctorConfidence.unknown) final  DoctorConfidence confidence;
@override@JsonKey(unknownEnumValue: DoctorSeverity.unknown) final  DoctorSeverity severity;
@override@JsonKey(unknownEnumValue: DoctorScope.unknown) final  DoctorScope scope;
@override@JsonKey(unknownEnumValue: DoctorPathKind.unknown) final  DoctorPathKind pathKind;
@override@JsonKey(unknownEnumValue: DoctorCaptureState.unknown) final  DoctorCaptureState captureState;
 final  List<DoctorStage> _stages;
@override@JsonKey() List<DoctorStage> get stages {
  if (_stages is EqualUnmodifiableListView) return _stages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_stages);
}

@override@JsonKey() final  String examId;
@override@JsonKey(unknownEnumValue: DoctorExamMode.unknown) final  DoctorExamMode mode;
@override@JsonKey() final  String causeCode;
@override@JsonKey(unknownEnumValue: DoctorLayer.unknown) final  DoctorLayer layer;
@override@JsonKey() final  DoctorProgress progress;
@override@JsonKey() final  DoctorGenerations generations;
@override@JsonKey() final  DoctorGenerations startGenerations;
@override@JsonKey() final  int startedAt;
@override@JsonKey() final  int updatedAt;
@override@JsonKey() final  int freshUntil;
@override@JsonKey() final  int evidenceDropped;
 final  List<DoctorEvidence> _evidence;
@override@JsonKey() List<DoctorEvidence> get evidence {
  if (_evidence is EqualUnmodifiableListView) return _evidence;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_evidence);
}

 final  List<DoctorAction> _actions;
@override@JsonKey() List<DoctorAction> get actions {
  if (_actions is EqualUnmodifiableListView) return _actions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_actions);
}

 final  List<DoctorHealAudit> _healAudit;
@override@JsonKey() List<DoctorHealAudit> get healAudit {
  if (_healAudit is EqualUnmodifiableListView) return _healAudit;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_healAudit);
}

 final  List<DoctorIncident> _incidents;
@override@JsonKey() List<DoctorIncident> get incidents {
  if (_incidents is EqualUnmodifiableListView) return _incidents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_incidents);
}


/// Create a copy of DoctorSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DoctorSnapshotCopyWith<_DoctorSnapshot> get copyWith => __$DoctorSnapshotCopyWithImpl<_DoctorSnapshot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DoctorSnapshotToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DoctorSnapshot&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.revision, revision) || other.revision == revision)&&(identical(other.supported, supported) || other.supported == supported)&&(identical(other.capabilities, capabilities) || other.capabilities == capabilities)&&(identical(other.state, state) || other.state == state)&&(identical(other.health, health) || other.health == health)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.scope, scope) || other.scope == scope)&&(identical(other.pathKind, pathKind) || other.pathKind == pathKind)&&(identical(other.captureState, captureState) || other.captureState == captureState)&&const DeepCollectionEquality().equals(other.stages, _stages)&&(identical(other.examId, examId) || other.examId == examId)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.causeCode, causeCode) || other.causeCode == causeCode)&&(identical(other.layer, layer) || other.layer == layer)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.generations, generations) || other.generations == generations)&&(identical(other.startGenerations, startGenerations) || other.startGenerations == startGenerations)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.freshUntil, freshUntil) || other.freshUntil == freshUntil)&&(identical(other.evidenceDropped, evidenceDropped) || other.evidenceDropped == evidenceDropped)&&const DeepCollectionEquality().equals(other.evidence, _evidence)&&const DeepCollectionEquality().equals(other.actions, _actions)&&const DeepCollectionEquality().equals(other.healAudit, _healAudit)&&const DeepCollectionEquality().equals(other.incidents, _incidents));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,schemaVersion,revision,supported,capabilities,state,health,confidence,severity,scope,pathKind,captureState,const DeepCollectionEquality().hash(_stages),examId,mode,causeCode,layer,progress,generations,startGenerations,startedAt,updatedAt,freshUntil,evidenceDropped,const DeepCollectionEquality().hash(_evidence),const DeepCollectionEquality().hash(_actions),const DeepCollectionEquality().hash(_healAudit),const DeepCollectionEquality().hash(_incidents)]);
}

@override
String toString() {
    return 'DoctorSnapshot(schemaVersion: $schemaVersion, revision: $revision, supported: $supported, capabilities: $capabilities, state: $state, health: $health, confidence: $confidence, severity: $severity, scope: $scope, pathKind: $pathKind, captureState: $captureState, stages: $stages, examId: $examId, mode: $mode, causeCode: $causeCode, layer: $layer, progress: $progress, generations: $generations, startGenerations: $startGenerations, startedAt: $startedAt, updatedAt: $updatedAt, freshUntil: $freshUntil, evidenceDropped: $evidenceDropped, evidence: $evidence, actions: $actions, healAudit: $healAudit, incidents: $incidents)';
}


}

/// @nodoc
abstract mixin class _$DoctorSnapshotCopyWith<$Res> implements $DoctorSnapshotCopyWith<$Res> {
  factory _$DoctorSnapshotCopyWith(_DoctorSnapshot value, $Res Function(_DoctorSnapshot) _then) = __$DoctorSnapshotCopyWithImpl;
@override @useResult
$Res call({
 int schemaVersion, int revision, bool supported, DoctorCapabilities capabilities,@JsonKey(unknownEnumValue: DoctorExamState.unknown) DoctorExamState state,@JsonKey(unknownEnumValue: DoctorHealth.unknown) DoctorHealth health,@JsonKey(unknownEnumValue: DoctorConfidence.unknown) DoctorConfidence confidence,@JsonKey(unknownEnumValue: DoctorSeverity.unknown) DoctorSeverity severity,@JsonKey(unknownEnumValue: DoctorScope.unknown) DoctorScope scope,@JsonKey(unknownEnumValue: DoctorPathKind.unknown) DoctorPathKind pathKind,@JsonKey(unknownEnumValue: DoctorCaptureState.unknown) DoctorCaptureState captureState, List<DoctorStage> stages, String examId,@JsonKey(unknownEnumValue: DoctorExamMode.unknown) DoctorExamMode mode, String causeCode,@JsonKey(unknownEnumValue: DoctorLayer.unknown) DoctorLayer layer, DoctorProgress progress, DoctorGenerations generations, DoctorGenerations startGenerations, int startedAt, int updatedAt, int freshUntil, int evidenceDropped, List<DoctorEvidence> evidence, List<DoctorAction> actions, List<DoctorHealAudit> healAudit, List<DoctorIncident> incidents
});


@override $DoctorCapabilitiesCopyWith<$Res> get capabilities;@override $DoctorProgressCopyWith<$Res> get progress;@override $DoctorGenerationsCopyWith<$Res> get generations;@override $DoctorGenerationsCopyWith<$Res> get startGenerations;

}
/// @nodoc
class __$DoctorSnapshotCopyWithImpl<$Res>
    implements _$DoctorSnapshotCopyWith<$Res> {
  __$DoctorSnapshotCopyWithImpl(this._self, this._then);

  final _DoctorSnapshot _self;
  final $Res Function(_DoctorSnapshot) _then;

/// Create a copy of DoctorSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? revision = null,Object? supported = null,Object? capabilities = null,Object? state = null,Object? health = null,Object? confidence = null,Object? severity = null,Object? scope = null,Object? pathKind = null,Object? captureState = null,Object? stages = null,Object? examId = null,Object? mode = null,Object? causeCode = null,Object? layer = null,Object? progress = null,Object? generations = null,Object? startGenerations = null,Object? startedAt = null,Object? updatedAt = null,Object? freshUntil = null,Object? evidenceDropped = null,Object? evidence = null,Object? actions = null,Object? healAudit = null,Object? incidents = null,}) {
  return _then(_DoctorSnapshot(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,revision: null == revision ? _self.revision : revision // ignore: cast_nullable_to_non_nullable
as int,supported: null == supported ? _self.supported : supported // ignore: cast_nullable_to_non_nullable
as bool,capabilities: null == capabilities ? _self.capabilities : capabilities // ignore: cast_nullable_to_non_nullable
as DoctorCapabilities,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as DoctorExamState,health: null == health ? _self.health : health // ignore: cast_nullable_to_non_nullable
as DoctorHealth,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as DoctorConfidence,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as DoctorSeverity,scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as DoctorScope,pathKind: null == pathKind ? _self.pathKind : pathKind // ignore: cast_nullable_to_non_nullable
as DoctorPathKind,captureState: null == captureState ? _self.captureState : captureState // ignore: cast_nullable_to_non_nullable
as DoctorCaptureState,stages: null == stages ? _self._stages : stages // ignore: cast_nullable_to_non_nullable
as List<DoctorStage>,examId: null == examId ? _self.examId : examId // ignore: cast_nullable_to_non_nullable
as String,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as DoctorExamMode,causeCode: null == causeCode ? _self.causeCode : causeCode // ignore: cast_nullable_to_non_nullable
as String,layer: null == layer ? _self.layer : layer // ignore: cast_nullable_to_non_nullable
as DoctorLayer,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as DoctorProgress,generations: null == generations ? _self.generations : generations // ignore: cast_nullable_to_non_nullable
as DoctorGenerations,startGenerations: null == startGenerations ? _self.startGenerations : startGenerations // ignore: cast_nullable_to_non_nullable
as DoctorGenerations,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as int,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as int,freshUntil: null == freshUntil ? _self.freshUntil : freshUntil // ignore: cast_nullable_to_non_nullable
as int,evidenceDropped: null == evidenceDropped ? _self.evidenceDropped : evidenceDropped // ignore: cast_nullable_to_non_nullable
as int,evidence: null == evidence ? _self._evidence : evidence // ignore: cast_nullable_to_non_nullable
as List<DoctorEvidence>,actions: null == actions ? _self._actions : actions // ignore: cast_nullable_to_non_nullable
as List<DoctorAction>,healAudit: null == healAudit ? _self._healAudit : healAudit // ignore: cast_nullable_to_non_nullable
as List<DoctorHealAudit>,incidents: null == incidents ? _self._incidents : incidents // ignore: cast_nullable_to_non_nullable
as List<DoctorIncident>,
  ));
}

/// Create a copy of DoctorSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DoctorCapabilitiesCopyWith<$Res> get capabilities {
  
  return $DoctorCapabilitiesCopyWith<$Res>(_self.capabilities, (value) {
    return _then(_self.copyWith(capabilities: value));
  });
}/// Create a copy of DoctorSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DoctorProgressCopyWith<$Res> get progress {
  
  return $DoctorProgressCopyWith<$Res>(_self.progress, (value) {
    return _then(_self.copyWith(progress: value));
  });
}/// Create a copy of DoctorSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DoctorGenerationsCopyWith<$Res> get generations {
  
  return $DoctorGenerationsCopyWith<$Res>(_self.generations, (value) {
    return _then(_self.copyWith(generations: value));
  });
}/// Create a copy of DoctorSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DoctorGenerationsCopyWith<$Res> get startGenerations {
  
  return $DoctorGenerationsCopyWith<$Res>(_self.startGenerations, (value) {
    return _then(_self.copyWith(startGenerations: value));
  });
}
}


/// @nodoc
mixin _$DoctorStatus {

 int get revision;@JsonKey(unknownEnumValue: DoctorExamState.unknown) DoctorExamState get state;@JsonKey(unknownEnumValue: DoctorHealth.unknown) DoctorHealth get health;@JsonKey(unknownEnumValue: DoctorConfidence.unknown) DoctorConfidence get confidence; String get causeCode;
/// Create a copy of DoctorStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DoctorStatusCopyWith<DoctorStatus> get copyWith => _$DoctorStatusCopyWithImpl<DoctorStatus>(this as DoctorStatus, _$identity);

  /// Serializes this DoctorStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DoctorStatus;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DoctorStatus&&(identical(other.revision, _this.revision) || other.revision == _this.revision)&&(identical(other.state, _this.state) || other.state == _this.state)&&(identical(other.health, _this.health) || other.health == _this.health)&&(identical(other.confidence, _this.confidence) || other.confidence == _this.confidence)&&(identical(other.causeCode, _this.causeCode) || other.causeCode == _this.causeCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DoctorStatus;
  return Object.hash(runtimeType,_this.revision,_this.state,_this.health,_this.confidence,_this.causeCode);
}

@override
String toString() {
  final _this = this as DoctorStatus;
  return 'DoctorStatus(revision: ${_this.revision}, state: ${_this.state}, health: ${_this.health}, confidence: ${_this.confidence}, causeCode: ${_this.causeCode})';
}


}

/// @nodoc
abstract mixin class $DoctorStatusCopyWith<$Res>  {
  factory $DoctorStatusCopyWith(DoctorStatus value, $Res Function(DoctorStatus) _then) = _$DoctorStatusCopyWithImpl;
@useResult
$Res call({
 int revision,@JsonKey(unknownEnumValue: DoctorExamState.unknown) DoctorExamState state,@JsonKey(unknownEnumValue: DoctorHealth.unknown) DoctorHealth health,@JsonKey(unknownEnumValue: DoctorConfidence.unknown) DoctorConfidence confidence, String causeCode
});




}
/// @nodoc
class _$DoctorStatusCopyWithImpl<$Res>
    implements $DoctorStatusCopyWith<$Res> {
  _$DoctorStatusCopyWithImpl(this._self, this._then);

  final DoctorStatus _self;
  final $Res Function(DoctorStatus) _then;

/// Create a copy of DoctorStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? revision = null,Object? state = null,Object? health = null,Object? confidence = null,Object? causeCode = null,}) {
  return _then(DoctorStatus(
revision: null == revision ? _self.revision : revision // ignore: cast_nullable_to_non_nullable
as int,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as DoctorExamState,health: null == health ? _self.health : health // ignore: cast_nullable_to_non_nullable
as DoctorHealth,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as DoctorConfidence,causeCode: null == causeCode ? _self.causeCode : causeCode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DoctorStatus].
extension DoctorStatusPatterns on DoctorStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DoctorStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DoctorStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DoctorStatus value)  $default,){
final _that = this;
switch (_that) {
case _DoctorStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DoctorStatus value)?  $default,){
final _that = this;
switch (_that) {
case _DoctorStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int revision, @JsonKey(unknownEnumValue: DoctorExamState.unknown)  DoctorExamState state, @JsonKey(unknownEnumValue: DoctorHealth.unknown)  DoctorHealth health, @JsonKey(unknownEnumValue: DoctorConfidence.unknown)  DoctorConfidence confidence,  String causeCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DoctorStatus() when $default != null:
return $default(_that.revision,_that.state,_that.health,_that.confidence,_that.causeCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int revision, @JsonKey(unknownEnumValue: DoctorExamState.unknown)  DoctorExamState state, @JsonKey(unknownEnumValue: DoctorHealth.unknown)  DoctorHealth health, @JsonKey(unknownEnumValue: DoctorConfidence.unknown)  DoctorConfidence confidence,  String causeCode)  $default,) {final _that = this;
switch (_that) {
case _DoctorStatus():
return $default(_that.revision,_that.state,_that.health,_that.confidence,_that.causeCode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int revision, @JsonKey(unknownEnumValue: DoctorExamState.unknown)  DoctorExamState state, @JsonKey(unknownEnumValue: DoctorHealth.unknown)  DoctorHealth health, @JsonKey(unknownEnumValue: DoctorConfidence.unknown)  DoctorConfidence confidence,  String causeCode)?  $default,) {final _that = this;
switch (_that) {
case _DoctorStatus() when $default != null:
return $default(_that.revision,_that.state,_that.health,_that.confidence,_that.causeCode);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DoctorStatus implements DoctorStatus {
  const _DoctorStatus({this.revision = 0, @JsonKey(unknownEnumValue: DoctorExamState.unknown) this.state = DoctorExamState.unknown, @JsonKey(unknownEnumValue: DoctorHealth.unknown) this.health = DoctorHealth.unknown, @JsonKey(unknownEnumValue: DoctorConfidence.unknown) this.confidence = DoctorConfidence.unknown, this.causeCode = ''});
  factory _DoctorStatus.fromJson(Map<String, dynamic> json) => _$DoctorStatusFromJson(json);

@override@JsonKey() final  int revision;
@override@JsonKey(unknownEnumValue: DoctorExamState.unknown) final  DoctorExamState state;
@override@JsonKey(unknownEnumValue: DoctorHealth.unknown) final  DoctorHealth health;
@override@JsonKey(unknownEnumValue: DoctorConfidence.unknown) final  DoctorConfidence confidence;
@override@JsonKey() final  String causeCode;

/// Create a copy of DoctorStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DoctorStatusCopyWith<_DoctorStatus> get copyWith => __$DoctorStatusCopyWithImpl<_DoctorStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DoctorStatusToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DoctorStatus&&(identical(other.revision, revision) || other.revision == revision)&&(identical(other.state, state) || other.state == state)&&(identical(other.health, health) || other.health == health)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.causeCode, causeCode) || other.causeCode == causeCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,revision,state,health,confidence,causeCode);
}

@override
String toString() {
    return 'DoctorStatus(revision: $revision, state: $state, health: $health, confidence: $confidence, causeCode: $causeCode)';
}


}

/// @nodoc
abstract mixin class _$DoctorStatusCopyWith<$Res> implements $DoctorStatusCopyWith<$Res> {
  factory _$DoctorStatusCopyWith(_DoctorStatus value, $Res Function(_DoctorStatus) _then) = __$DoctorStatusCopyWithImpl;
@override @useResult
$Res call({
 int revision,@JsonKey(unknownEnumValue: DoctorExamState.unknown) DoctorExamState state,@JsonKey(unknownEnumValue: DoctorHealth.unknown) DoctorHealth health,@JsonKey(unknownEnumValue: DoctorConfidence.unknown) DoctorConfidence confidence, String causeCode
});




}
/// @nodoc
class __$DoctorStatusCopyWithImpl<$Res>
    implements _$DoctorStatusCopyWith<$Res> {
  __$DoctorStatusCopyWithImpl(this._self, this._then);

  final _DoctorStatus _self;
  final $Res Function(_DoctorStatus) _then;

/// Create a copy of DoctorStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? revision = null,Object? state = null,Object? health = null,Object? confidence = null,Object? causeCode = null,}) {
  return _then(_DoctorStatus(
revision: null == revision ? _self.revision : revision // ignore: cast_nullable_to_non_nullable
as int,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as DoctorExamState,health: null == health ? _self.health : health // ignore: cast_nullable_to_non_nullable
as DoctorHealth,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as DoctorConfidence,causeCode: null == causeCode ? _self.causeCode : causeCode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$DoctorStartParams {

 DoctorExamMode get mode;
/// Create a copy of DoctorStartParams
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DoctorStartParamsCopyWith<DoctorStartParams> get copyWith => _$DoctorStartParamsCopyWithImpl<DoctorStartParams>(this as DoctorStartParams, _$identity);

  /// Serializes this DoctorStartParams to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DoctorStartParams;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DoctorStartParams&&(identical(other.mode, _this.mode) || other.mode == _this.mode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DoctorStartParams;
  return Object.hash(runtimeType,_this.mode);
}

@override
String toString() {
  final _this = this as DoctorStartParams;
  return 'DoctorStartParams(mode: ${_this.mode})';
}


}

/// @nodoc
abstract mixin class $DoctorStartParamsCopyWith<$Res>  {
  factory $DoctorStartParamsCopyWith(DoctorStartParams value, $Res Function(DoctorStartParams) _then) = _$DoctorStartParamsCopyWithImpl;
@useResult
$Res call({
 DoctorExamMode mode
});




}
/// @nodoc
class _$DoctorStartParamsCopyWithImpl<$Res>
    implements $DoctorStartParamsCopyWith<$Res> {
  _$DoctorStartParamsCopyWithImpl(this._self, this._then);

  final DoctorStartParams _self;
  final $Res Function(DoctorStartParams) _then;

/// Create a copy of DoctorStartParams
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mode = null,}) {
  return _then(DoctorStartParams(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as DoctorExamMode,
  ));
}

}


/// Adds pattern-matching-related methods to [DoctorStartParams].
extension DoctorStartParamsPatterns on DoctorStartParams {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DoctorStartParams value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DoctorStartParams() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DoctorStartParams value)  $default,){
final _that = this;
switch (_that) {
case _DoctorStartParams():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DoctorStartParams value)?  $default,){
final _that = this;
switch (_that) {
case _DoctorStartParams() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DoctorExamMode mode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DoctorStartParams() when $default != null:
return $default(_that.mode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DoctorExamMode mode)  $default,) {final _that = this;
switch (_that) {
case _DoctorStartParams():
return $default(_that.mode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DoctorExamMode mode)?  $default,) {final _that = this;
switch (_that) {
case _DoctorStartParams() when $default != null:
return $default(_that.mode);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DoctorStartParams implements DoctorStartParams {
  const _DoctorStartParams({required this.mode});
  factory _DoctorStartParams.fromJson(Map<String, dynamic> json) => _$DoctorStartParamsFromJson(json);

@override final  DoctorExamMode mode;

/// Create a copy of DoctorStartParams
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DoctorStartParamsCopyWith<_DoctorStartParams> get copyWith => __$DoctorStartParamsCopyWithImpl<_DoctorStartParams>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DoctorStartParamsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DoctorStartParams&&(identical(other.mode, mode) || other.mode == mode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,mode);
}

@override
String toString() {
    return 'DoctorStartParams(mode: $mode)';
}


}

/// @nodoc
abstract mixin class _$DoctorStartParamsCopyWith<$Res> implements $DoctorStartParamsCopyWith<$Res> {
  factory _$DoctorStartParamsCopyWith(_DoctorStartParams value, $Res Function(_DoctorStartParams) _then) = __$DoctorStartParamsCopyWithImpl;
@override @useResult
$Res call({
 DoctorExamMode mode
});




}
/// @nodoc
class __$DoctorStartParamsCopyWithImpl<$Res>
    implements _$DoctorStartParamsCopyWith<$Res> {
  __$DoctorStartParamsCopyWithImpl(this._self, this._then);

  final _DoctorStartParams _self;
  final $Res Function(_DoctorStartParams) _then;

/// Create a copy of DoctorStartParams
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mode = null,}) {
  return _then(_DoctorStartParams(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as DoctorExamMode,
  ));
}


}


/// @nodoc
mixin _$DoctorCancelParams {

 String get examId;
/// Create a copy of DoctorCancelParams
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DoctorCancelParamsCopyWith<DoctorCancelParams> get copyWith => _$DoctorCancelParamsCopyWithImpl<DoctorCancelParams>(this as DoctorCancelParams, _$identity);

  /// Serializes this DoctorCancelParams to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DoctorCancelParams;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DoctorCancelParams&&(identical(other.examId, _this.examId) || other.examId == _this.examId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DoctorCancelParams;
  return Object.hash(runtimeType,_this.examId);
}

@override
String toString() {
  final _this = this as DoctorCancelParams;
  return 'DoctorCancelParams(examId: ${_this.examId})';
}


}

/// @nodoc
abstract mixin class $DoctorCancelParamsCopyWith<$Res>  {
  factory $DoctorCancelParamsCopyWith(DoctorCancelParams value, $Res Function(DoctorCancelParams) _then) = _$DoctorCancelParamsCopyWithImpl;
@useResult
$Res call({
 String examId
});




}
/// @nodoc
class _$DoctorCancelParamsCopyWithImpl<$Res>
    implements $DoctorCancelParamsCopyWith<$Res> {
  _$DoctorCancelParamsCopyWithImpl(this._self, this._then);

  final DoctorCancelParams _self;
  final $Res Function(DoctorCancelParams) _then;

/// Create a copy of DoctorCancelParams
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? examId = null,}) {
  return _then(DoctorCancelParams(
examId: null == examId ? _self.examId : examId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DoctorCancelParams].
extension DoctorCancelParamsPatterns on DoctorCancelParams {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DoctorCancelParams value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DoctorCancelParams() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DoctorCancelParams value)  $default,){
final _that = this;
switch (_that) {
case _DoctorCancelParams():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DoctorCancelParams value)?  $default,){
final _that = this;
switch (_that) {
case _DoctorCancelParams() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String examId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DoctorCancelParams() when $default != null:
return $default(_that.examId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String examId)  $default,) {final _that = this;
switch (_that) {
case _DoctorCancelParams():
return $default(_that.examId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String examId)?  $default,) {final _that = this;
switch (_that) {
case _DoctorCancelParams() when $default != null:
return $default(_that.examId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DoctorCancelParams implements DoctorCancelParams {
  const _DoctorCancelParams({required this.examId});
  factory _DoctorCancelParams.fromJson(Map<String, dynamic> json) => _$DoctorCancelParamsFromJson(json);

@override final  String examId;

/// Create a copy of DoctorCancelParams
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DoctorCancelParamsCopyWith<_DoctorCancelParams> get copyWith => __$DoctorCancelParamsCopyWithImpl<_DoctorCancelParams>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DoctorCancelParamsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DoctorCancelParams&&(identical(other.examId, examId) || other.examId == examId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,examId);
}

@override
String toString() {
    return 'DoctorCancelParams(examId: $examId)';
}


}

/// @nodoc
abstract mixin class _$DoctorCancelParamsCopyWith<$Res> implements $DoctorCancelParamsCopyWith<$Res> {
  factory _$DoctorCancelParamsCopyWith(_DoctorCancelParams value, $Res Function(_DoctorCancelParams) _then) = __$DoctorCancelParamsCopyWithImpl;
@override @useResult
$Res call({
 String examId
});




}
/// @nodoc
class __$DoctorCancelParamsCopyWithImpl<$Res>
    implements _$DoctorCancelParamsCopyWith<$Res> {
  __$DoctorCancelParamsCopyWithImpl(this._self, this._then);

  final _DoctorCancelParams _self;
  final $Res Function(_DoctorCancelParams) _then;

/// Create a copy of DoctorCancelParams
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? examId = null,}) {
  return _then(_DoctorCancelParams(
examId: null == examId ? _self.examId : examId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$DoctorReport {

 int get schemaVersion; String get coreVersion; String get platform; String get architecture; int get generatedAt;@JsonKey(unknownEnumValue: DoctorExamState.unknown) DoctorExamState get state;@JsonKey(unknownEnumValue: DoctorHealth.unknown) DoctorHealth get health;@JsonKey(unknownEnumValue: DoctorConfidence.unknown) DoctorConfidence get confidence;@JsonKey(unknownEnumValue: DoctorScope.unknown) DoctorScope get scope;@JsonKey(unknownEnumValue: DoctorPathKind.unknown) DoctorPathKind get pathKind;@JsonKey(unknownEnumValue: DoctorCaptureState.unknown) DoctorCaptureState get captureState; List<DoctorStage> get stages;@JsonKey(unknownEnumValue: DoctorExamMode.unknown) DoctorExamMode get mode; String get causeCode;@JsonKey(unknownEnumValue: DoctorLayer.unknown) DoctorLayer get layer; DoctorGenerations get generations; List<DoctorEvidence> get evidence; List<DoctorHealAudit> get healAudit; List<DoctorIncident> get incidents;
/// Create a copy of DoctorReport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DoctorReportCopyWith<DoctorReport> get copyWith => _$DoctorReportCopyWithImpl<DoctorReport>(this as DoctorReport, _$identity);

  /// Serializes this DoctorReport to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DoctorReport;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DoctorReport&&(identical(other.schemaVersion, _this.schemaVersion) || other.schemaVersion == _this.schemaVersion)&&(identical(other.coreVersion, _this.coreVersion) || other.coreVersion == _this.coreVersion)&&(identical(other.platform, _this.platform) || other.platform == _this.platform)&&(identical(other.architecture, _this.architecture) || other.architecture == _this.architecture)&&(identical(other.generatedAt, _this.generatedAt) || other.generatedAt == _this.generatedAt)&&(identical(other.state, _this.state) || other.state == _this.state)&&(identical(other.health, _this.health) || other.health == _this.health)&&(identical(other.confidence, _this.confidence) || other.confidence == _this.confidence)&&(identical(other.scope, _this.scope) || other.scope == _this.scope)&&(identical(other.pathKind, _this.pathKind) || other.pathKind == _this.pathKind)&&(identical(other.captureState, _this.captureState) || other.captureState == _this.captureState)&&const DeepCollectionEquality().equals(other.stages, _this.stages)&&(identical(other.mode, _this.mode) || other.mode == _this.mode)&&(identical(other.causeCode, _this.causeCode) || other.causeCode == _this.causeCode)&&(identical(other.layer, _this.layer) || other.layer == _this.layer)&&(identical(other.generations, _this.generations) || other.generations == _this.generations)&&const DeepCollectionEquality().equals(other.evidence, _this.evidence)&&const DeepCollectionEquality().equals(other.healAudit, _this.healAudit)&&const DeepCollectionEquality().equals(other.incidents, _this.incidents));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DoctorReport;
  return Object.hashAll([runtimeType,_this.schemaVersion,_this.coreVersion,_this.platform,_this.architecture,_this.generatedAt,_this.state,_this.health,_this.confidence,_this.scope,_this.pathKind,_this.captureState,const DeepCollectionEquality().hash(_this.stages),_this.mode,_this.causeCode,_this.layer,_this.generations,const DeepCollectionEquality().hash(_this.evidence),const DeepCollectionEquality().hash(_this.healAudit),const DeepCollectionEquality().hash(_this.incidents)]);
}

@override
String toString() {
  final _this = this as DoctorReport;
  return 'DoctorReport(schemaVersion: ${_this.schemaVersion}, coreVersion: ${_this.coreVersion}, platform: ${_this.platform}, architecture: ${_this.architecture}, generatedAt: ${_this.generatedAt}, state: ${_this.state}, health: ${_this.health}, confidence: ${_this.confidence}, scope: ${_this.scope}, pathKind: ${_this.pathKind}, captureState: ${_this.captureState}, stages: ${_this.stages}, mode: ${_this.mode}, causeCode: ${_this.causeCode}, layer: ${_this.layer}, generations: ${_this.generations}, evidence: ${_this.evidence}, healAudit: ${_this.healAudit}, incidents: ${_this.incidents})';
}


}

/// @nodoc
abstract mixin class $DoctorReportCopyWith<$Res>  {
  factory $DoctorReportCopyWith(DoctorReport value, $Res Function(DoctorReport) _then) = _$DoctorReportCopyWithImpl;
@useResult
$Res call({
 int schemaVersion, String coreVersion, String platform, String architecture, int generatedAt,@JsonKey(unknownEnumValue: DoctorExamState.unknown) DoctorExamState state,@JsonKey(unknownEnumValue: DoctorHealth.unknown) DoctorHealth health,@JsonKey(unknownEnumValue: DoctorConfidence.unknown) DoctorConfidence confidence,@JsonKey(unknownEnumValue: DoctorScope.unknown) DoctorScope scope,@JsonKey(unknownEnumValue: DoctorPathKind.unknown) DoctorPathKind pathKind,@JsonKey(unknownEnumValue: DoctorCaptureState.unknown) DoctorCaptureState captureState, List<DoctorStage> stages,@JsonKey(unknownEnumValue: DoctorExamMode.unknown) DoctorExamMode mode, String causeCode,@JsonKey(unknownEnumValue: DoctorLayer.unknown) DoctorLayer layer, DoctorGenerations generations, List<DoctorEvidence> evidence, List<DoctorHealAudit> healAudit, List<DoctorIncident> incidents
});


$DoctorGenerationsCopyWith<$Res> get generations;

}
/// @nodoc
class _$DoctorReportCopyWithImpl<$Res>
    implements $DoctorReportCopyWith<$Res> {
  _$DoctorReportCopyWithImpl(this._self, this._then);

  final DoctorReport _self;
  final $Res Function(DoctorReport) _then;

/// Create a copy of DoctorReport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? coreVersion = null,Object? platform = null,Object? architecture = null,Object? generatedAt = null,Object? state = null,Object? health = null,Object? confidence = null,Object? scope = null,Object? pathKind = null,Object? captureState = null,Object? stages = null,Object? mode = null,Object? causeCode = null,Object? layer = null,Object? generations = null,Object? evidence = null,Object? healAudit = null,Object? incidents = null,}) {
  return _then(DoctorReport(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,coreVersion: null == coreVersion ? _self.coreVersion : coreVersion // ignore: cast_nullable_to_non_nullable
as String,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String,architecture: null == architecture ? _self.architecture : architecture // ignore: cast_nullable_to_non_nullable
as String,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as int,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as DoctorExamState,health: null == health ? _self.health : health // ignore: cast_nullable_to_non_nullable
as DoctorHealth,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as DoctorConfidence,scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as DoctorScope,pathKind: null == pathKind ? _self.pathKind : pathKind // ignore: cast_nullable_to_non_nullable
as DoctorPathKind,captureState: null == captureState ? _self.captureState : captureState // ignore: cast_nullable_to_non_nullable
as DoctorCaptureState,stages: null == stages ? _self.stages : stages // ignore: cast_nullable_to_non_nullable
as List<DoctorStage>,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as DoctorExamMode,causeCode: null == causeCode ? _self.causeCode : causeCode // ignore: cast_nullable_to_non_nullable
as String,layer: null == layer ? _self.layer : layer // ignore: cast_nullable_to_non_nullable
as DoctorLayer,generations: null == generations ? _self.generations : generations // ignore: cast_nullable_to_non_nullable
as DoctorGenerations,evidence: null == evidence ? _self.evidence : evidence // ignore: cast_nullable_to_non_nullable
as List<DoctorEvidence>,healAudit: null == healAudit ? _self.healAudit : healAudit // ignore: cast_nullable_to_non_nullable
as List<DoctorHealAudit>,incidents: null == incidents ? _self.incidents : incidents // ignore: cast_nullable_to_non_nullable
as List<DoctorIncident>,
  ));
}
/// Create a copy of DoctorReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DoctorGenerationsCopyWith<$Res> get generations {
  
  return $DoctorGenerationsCopyWith<$Res>(_self.generations, (value) {
    return _then(_self.copyWith(generations: value));
  });
}
}


/// Adds pattern-matching-related methods to [DoctorReport].
extension DoctorReportPatterns on DoctorReport {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DoctorReport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DoctorReport() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DoctorReport value)  $default,){
final _that = this;
switch (_that) {
case _DoctorReport():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DoctorReport value)?  $default,){
final _that = this;
switch (_that) {
case _DoctorReport() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int schemaVersion,  String coreVersion,  String platform,  String architecture,  int generatedAt, @JsonKey(unknownEnumValue: DoctorExamState.unknown)  DoctorExamState state, @JsonKey(unknownEnumValue: DoctorHealth.unknown)  DoctorHealth health, @JsonKey(unknownEnumValue: DoctorConfidence.unknown)  DoctorConfidence confidence, @JsonKey(unknownEnumValue: DoctorScope.unknown)  DoctorScope scope, @JsonKey(unknownEnumValue: DoctorPathKind.unknown)  DoctorPathKind pathKind, @JsonKey(unknownEnumValue: DoctorCaptureState.unknown)  DoctorCaptureState captureState,  List<DoctorStage> stages, @JsonKey(unknownEnumValue: DoctorExamMode.unknown)  DoctorExamMode mode,  String causeCode, @JsonKey(unknownEnumValue: DoctorLayer.unknown)  DoctorLayer layer,  DoctorGenerations generations,  List<DoctorEvidence> evidence,  List<DoctorHealAudit> healAudit,  List<DoctorIncident> incidents)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DoctorReport() when $default != null:
return $default(_that.schemaVersion,_that.coreVersion,_that.platform,_that.architecture,_that.generatedAt,_that.state,_that.health,_that.confidence,_that.scope,_that.pathKind,_that.captureState,_that.stages,_that.mode,_that.causeCode,_that.layer,_that.generations,_that.evidence,_that.healAudit,_that.incidents);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int schemaVersion,  String coreVersion,  String platform,  String architecture,  int generatedAt, @JsonKey(unknownEnumValue: DoctorExamState.unknown)  DoctorExamState state, @JsonKey(unknownEnumValue: DoctorHealth.unknown)  DoctorHealth health, @JsonKey(unknownEnumValue: DoctorConfidence.unknown)  DoctorConfidence confidence, @JsonKey(unknownEnumValue: DoctorScope.unknown)  DoctorScope scope, @JsonKey(unknownEnumValue: DoctorPathKind.unknown)  DoctorPathKind pathKind, @JsonKey(unknownEnumValue: DoctorCaptureState.unknown)  DoctorCaptureState captureState,  List<DoctorStage> stages, @JsonKey(unknownEnumValue: DoctorExamMode.unknown)  DoctorExamMode mode,  String causeCode, @JsonKey(unknownEnumValue: DoctorLayer.unknown)  DoctorLayer layer,  DoctorGenerations generations,  List<DoctorEvidence> evidence,  List<DoctorHealAudit> healAudit,  List<DoctorIncident> incidents)  $default,) {final _that = this;
switch (_that) {
case _DoctorReport():
return $default(_that.schemaVersion,_that.coreVersion,_that.platform,_that.architecture,_that.generatedAt,_that.state,_that.health,_that.confidence,_that.scope,_that.pathKind,_that.captureState,_that.stages,_that.mode,_that.causeCode,_that.layer,_that.generations,_that.evidence,_that.healAudit,_that.incidents);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int schemaVersion,  String coreVersion,  String platform,  String architecture,  int generatedAt, @JsonKey(unknownEnumValue: DoctorExamState.unknown)  DoctorExamState state, @JsonKey(unknownEnumValue: DoctorHealth.unknown)  DoctorHealth health, @JsonKey(unknownEnumValue: DoctorConfidence.unknown)  DoctorConfidence confidence, @JsonKey(unknownEnumValue: DoctorScope.unknown)  DoctorScope scope, @JsonKey(unknownEnumValue: DoctorPathKind.unknown)  DoctorPathKind pathKind, @JsonKey(unknownEnumValue: DoctorCaptureState.unknown)  DoctorCaptureState captureState,  List<DoctorStage> stages, @JsonKey(unknownEnumValue: DoctorExamMode.unknown)  DoctorExamMode mode,  String causeCode, @JsonKey(unknownEnumValue: DoctorLayer.unknown)  DoctorLayer layer,  DoctorGenerations generations,  List<DoctorEvidence> evidence,  List<DoctorHealAudit> healAudit,  List<DoctorIncident> incidents)?  $default,) {final _that = this;
switch (_that) {
case _DoctorReport() when $default != null:
return $default(_that.schemaVersion,_that.coreVersion,_that.platform,_that.architecture,_that.generatedAt,_that.state,_that.health,_that.confidence,_that.scope,_that.pathKind,_that.captureState,_that.stages,_that.mode,_that.causeCode,_that.layer,_that.generations,_that.evidence,_that.healAudit,_that.incidents);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DoctorReport implements DoctorReport {
  const _DoctorReport({this.schemaVersion = 1, this.coreVersion = '', this.platform = '', this.architecture = '', this.generatedAt = 0, @JsonKey(unknownEnumValue: DoctorExamState.unknown) this.state = DoctorExamState.unknown, @JsonKey(unknownEnumValue: DoctorHealth.unknown) this.health = DoctorHealth.unknown, @JsonKey(unknownEnumValue: DoctorConfidence.unknown) this.confidence = DoctorConfidence.unknown, @JsonKey(unknownEnumValue: DoctorScope.unknown) this.scope = DoctorScope.unknown, @JsonKey(unknownEnumValue: DoctorPathKind.unknown) this.pathKind = DoctorPathKind.unknown, @JsonKey(unknownEnumValue: DoctorCaptureState.unknown) this.captureState = DoctorCaptureState.unknown,  List<DoctorStage> stages = const [], @JsonKey(unknownEnumValue: DoctorExamMode.unknown) this.mode = DoctorExamMode.unknown, this.causeCode = '', @JsonKey(unknownEnumValue: DoctorLayer.unknown) this.layer = DoctorLayer.unknown, this.generations = const DoctorGenerations(),  List<DoctorEvidence> evidence = const [],  List<DoctorHealAudit> healAudit = const [],  List<DoctorIncident> incidents = const []}): _stages = stages,_evidence = evidence,_healAudit = healAudit,_incidents = incidents;
  factory _DoctorReport.fromJson(Map<String, dynamic> json) => _$DoctorReportFromJson(json);

@override@JsonKey() final  int schemaVersion;
@override@JsonKey() final  String coreVersion;
@override@JsonKey() final  String platform;
@override@JsonKey() final  String architecture;
@override@JsonKey() final  int generatedAt;
@override@JsonKey(unknownEnumValue: DoctorExamState.unknown) final  DoctorExamState state;
@override@JsonKey(unknownEnumValue: DoctorHealth.unknown) final  DoctorHealth health;
@override@JsonKey(unknownEnumValue: DoctorConfidence.unknown) final  DoctorConfidence confidence;
@override@JsonKey(unknownEnumValue: DoctorScope.unknown) final  DoctorScope scope;
@override@JsonKey(unknownEnumValue: DoctorPathKind.unknown) final  DoctorPathKind pathKind;
@override@JsonKey(unknownEnumValue: DoctorCaptureState.unknown) final  DoctorCaptureState captureState;
 final  List<DoctorStage> _stages;
@override@JsonKey() List<DoctorStage> get stages {
  if (_stages is EqualUnmodifiableListView) return _stages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_stages);
}

@override@JsonKey(unknownEnumValue: DoctorExamMode.unknown) final  DoctorExamMode mode;
@override@JsonKey() final  String causeCode;
@override@JsonKey(unknownEnumValue: DoctorLayer.unknown) final  DoctorLayer layer;
@override@JsonKey() final  DoctorGenerations generations;
 final  List<DoctorEvidence> _evidence;
@override@JsonKey() List<DoctorEvidence> get evidence {
  if (_evidence is EqualUnmodifiableListView) return _evidence;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_evidence);
}

 final  List<DoctorHealAudit> _healAudit;
@override@JsonKey() List<DoctorHealAudit> get healAudit {
  if (_healAudit is EqualUnmodifiableListView) return _healAudit;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_healAudit);
}

 final  List<DoctorIncident> _incidents;
@override@JsonKey() List<DoctorIncident> get incidents {
  if (_incidents is EqualUnmodifiableListView) return _incidents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_incidents);
}


/// Create a copy of DoctorReport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DoctorReportCopyWith<_DoctorReport> get copyWith => __$DoctorReportCopyWithImpl<_DoctorReport>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DoctorReportToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DoctorReport&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.coreVersion, coreVersion) || other.coreVersion == coreVersion)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.architecture, architecture) || other.architecture == architecture)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&(identical(other.state, state) || other.state == state)&&(identical(other.health, health) || other.health == health)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.scope, scope) || other.scope == scope)&&(identical(other.pathKind, pathKind) || other.pathKind == pathKind)&&(identical(other.captureState, captureState) || other.captureState == captureState)&&const DeepCollectionEquality().equals(other.stages, _stages)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.causeCode, causeCode) || other.causeCode == causeCode)&&(identical(other.layer, layer) || other.layer == layer)&&(identical(other.generations, generations) || other.generations == generations)&&const DeepCollectionEquality().equals(other.evidence, _evidence)&&const DeepCollectionEquality().equals(other.healAudit, _healAudit)&&const DeepCollectionEquality().equals(other.incidents, _incidents));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,schemaVersion,coreVersion,platform,architecture,generatedAt,state,health,confidence,scope,pathKind,captureState,const DeepCollectionEquality().hash(_stages),mode,causeCode,layer,generations,const DeepCollectionEquality().hash(_evidence),const DeepCollectionEquality().hash(_healAudit),const DeepCollectionEquality().hash(_incidents)]);
}

@override
String toString() {
    return 'DoctorReport(schemaVersion: $schemaVersion, coreVersion: $coreVersion, platform: $platform, architecture: $architecture, generatedAt: $generatedAt, state: $state, health: $health, confidence: $confidence, scope: $scope, pathKind: $pathKind, captureState: $captureState, stages: $stages, mode: $mode, causeCode: $causeCode, layer: $layer, generations: $generations, evidence: $evidence, healAudit: $healAudit, incidents: $incidents)';
}


}

/// @nodoc
abstract mixin class _$DoctorReportCopyWith<$Res> implements $DoctorReportCopyWith<$Res> {
  factory _$DoctorReportCopyWith(_DoctorReport value, $Res Function(_DoctorReport) _then) = __$DoctorReportCopyWithImpl;
@override @useResult
$Res call({
 int schemaVersion, String coreVersion, String platform, String architecture, int generatedAt,@JsonKey(unknownEnumValue: DoctorExamState.unknown) DoctorExamState state,@JsonKey(unknownEnumValue: DoctorHealth.unknown) DoctorHealth health,@JsonKey(unknownEnumValue: DoctorConfidence.unknown) DoctorConfidence confidence,@JsonKey(unknownEnumValue: DoctorScope.unknown) DoctorScope scope,@JsonKey(unknownEnumValue: DoctorPathKind.unknown) DoctorPathKind pathKind,@JsonKey(unknownEnumValue: DoctorCaptureState.unknown) DoctorCaptureState captureState, List<DoctorStage> stages,@JsonKey(unknownEnumValue: DoctorExamMode.unknown) DoctorExamMode mode, String causeCode,@JsonKey(unknownEnumValue: DoctorLayer.unknown) DoctorLayer layer, DoctorGenerations generations, List<DoctorEvidence> evidence, List<DoctorHealAudit> healAudit, List<DoctorIncident> incidents
});


@override $DoctorGenerationsCopyWith<$Res> get generations;

}
/// @nodoc
class __$DoctorReportCopyWithImpl<$Res>
    implements _$DoctorReportCopyWith<$Res> {
  __$DoctorReportCopyWithImpl(this._self, this._then);

  final _DoctorReport _self;
  final $Res Function(_DoctorReport) _then;

/// Create a copy of DoctorReport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? coreVersion = null,Object? platform = null,Object? architecture = null,Object? generatedAt = null,Object? state = null,Object? health = null,Object? confidence = null,Object? scope = null,Object? pathKind = null,Object? captureState = null,Object? stages = null,Object? mode = null,Object? causeCode = null,Object? layer = null,Object? generations = null,Object? evidence = null,Object? healAudit = null,Object? incidents = null,}) {
  return _then(_DoctorReport(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,coreVersion: null == coreVersion ? _self.coreVersion : coreVersion // ignore: cast_nullable_to_non_nullable
as String,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String,architecture: null == architecture ? _self.architecture : architecture // ignore: cast_nullable_to_non_nullable
as String,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as int,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as DoctorExamState,health: null == health ? _self.health : health // ignore: cast_nullable_to_non_nullable
as DoctorHealth,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as DoctorConfidence,scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as DoctorScope,pathKind: null == pathKind ? _self.pathKind : pathKind // ignore: cast_nullable_to_non_nullable
as DoctorPathKind,captureState: null == captureState ? _self.captureState : captureState // ignore: cast_nullable_to_non_nullable
as DoctorCaptureState,stages: null == stages ? _self._stages : stages // ignore: cast_nullable_to_non_nullable
as List<DoctorStage>,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as DoctorExamMode,causeCode: null == causeCode ? _self.causeCode : causeCode // ignore: cast_nullable_to_non_nullable
as String,layer: null == layer ? _self.layer : layer // ignore: cast_nullable_to_non_nullable
as DoctorLayer,generations: null == generations ? _self.generations : generations // ignore: cast_nullable_to_non_nullable
as DoctorGenerations,evidence: null == evidence ? _self._evidence : evidence // ignore: cast_nullable_to_non_nullable
as List<DoctorEvidence>,healAudit: null == healAudit ? _self._healAudit : healAudit // ignore: cast_nullable_to_non_nullable
as List<DoctorHealAudit>,incidents: null == incidents ? _self._incidents : incidents // ignore: cast_nullable_to_non_nullable
as List<DoctorIncident>,
  ));
}

/// Create a copy of DoctorReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DoctorGenerationsCopyWith<$Res> get generations {
  
  return $DoctorGenerationsCopyWith<$Res>(_self.generations, (value) {
    return _then(_self.copyWith(generations: value));
  });
}
}


/// @nodoc
mixin _$DoctorHealParams {

 String get examId; int get revision; String get actionId;
/// Create a copy of DoctorHealParams
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DoctorHealParamsCopyWith<DoctorHealParams> get copyWith => _$DoctorHealParamsCopyWithImpl<DoctorHealParams>(this as DoctorHealParams, _$identity);

  /// Serializes this DoctorHealParams to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DoctorHealParams;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DoctorHealParams&&(identical(other.examId, _this.examId) || other.examId == _this.examId)&&(identical(other.revision, _this.revision) || other.revision == _this.revision)&&(identical(other.actionId, _this.actionId) || other.actionId == _this.actionId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DoctorHealParams;
  return Object.hash(runtimeType,_this.examId,_this.revision,_this.actionId);
}

@override
String toString() {
  final _this = this as DoctorHealParams;
  return 'DoctorHealParams(examId: ${_this.examId}, revision: ${_this.revision}, actionId: ${_this.actionId})';
}


}

/// @nodoc
abstract mixin class $DoctorHealParamsCopyWith<$Res>  {
  factory $DoctorHealParamsCopyWith(DoctorHealParams value, $Res Function(DoctorHealParams) _then) = _$DoctorHealParamsCopyWithImpl;
@useResult
$Res call({
 String examId, int revision, String actionId
});




}
/// @nodoc
class _$DoctorHealParamsCopyWithImpl<$Res>
    implements $DoctorHealParamsCopyWith<$Res> {
  _$DoctorHealParamsCopyWithImpl(this._self, this._then);

  final DoctorHealParams _self;
  final $Res Function(DoctorHealParams) _then;

/// Create a copy of DoctorHealParams
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? examId = null,Object? revision = null,Object? actionId = null,}) {
  return _then(DoctorHealParams(
examId: null == examId ? _self.examId : examId // ignore: cast_nullable_to_non_nullable
as String,revision: null == revision ? _self.revision : revision // ignore: cast_nullable_to_non_nullable
as int,actionId: null == actionId ? _self.actionId : actionId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DoctorHealParams].
extension DoctorHealParamsPatterns on DoctorHealParams {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DoctorHealParams value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DoctorHealParams() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DoctorHealParams value)  $default,){
final _that = this;
switch (_that) {
case _DoctorHealParams():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DoctorHealParams value)?  $default,){
final _that = this;
switch (_that) {
case _DoctorHealParams() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String examId,  int revision,  String actionId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DoctorHealParams() when $default != null:
return $default(_that.examId,_that.revision,_that.actionId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String examId,  int revision,  String actionId)  $default,) {final _that = this;
switch (_that) {
case _DoctorHealParams():
return $default(_that.examId,_that.revision,_that.actionId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String examId,  int revision,  String actionId)?  $default,) {final _that = this;
switch (_that) {
case _DoctorHealParams() when $default != null:
return $default(_that.examId,_that.revision,_that.actionId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DoctorHealParams implements DoctorHealParams {
  const _DoctorHealParams({required this.examId, required this.revision, this.actionId = 'flushDns'});
  factory _DoctorHealParams.fromJson(Map<String, dynamic> json) => _$DoctorHealParamsFromJson(json);

@override final  String examId;
@override final  int revision;
@override@JsonKey() final  String actionId;

/// Create a copy of DoctorHealParams
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DoctorHealParamsCopyWith<_DoctorHealParams> get copyWith => __$DoctorHealParamsCopyWithImpl<_DoctorHealParams>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DoctorHealParamsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DoctorHealParams&&(identical(other.examId, examId) || other.examId == examId)&&(identical(other.revision, revision) || other.revision == revision)&&(identical(other.actionId, actionId) || other.actionId == actionId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,examId,revision,actionId);
}

@override
String toString() {
    return 'DoctorHealParams(examId: $examId, revision: $revision, actionId: $actionId)';
}


}

/// @nodoc
abstract mixin class _$DoctorHealParamsCopyWith<$Res> implements $DoctorHealParamsCopyWith<$Res> {
  factory _$DoctorHealParamsCopyWith(_DoctorHealParams value, $Res Function(_DoctorHealParams) _then) = __$DoctorHealParamsCopyWithImpl;
@override @useResult
$Res call({
 String examId, int revision, String actionId
});




}
/// @nodoc
class __$DoctorHealParamsCopyWithImpl<$Res>
    implements _$DoctorHealParamsCopyWith<$Res> {
  __$DoctorHealParamsCopyWithImpl(this._self, this._then);

  final _DoctorHealParams _self;
  final $Res Function(_DoctorHealParams) _then;

/// Create a copy of DoctorHealParams
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? examId = null,Object? revision = null,Object? actionId = null,}) {
  return _then(_DoctorHealParams(
examId: null == examId ? _self.examId : examId // ignore: cast_nullable_to_non_nullable
as String,revision: null == revision ? _self.revision : revision // ignore: cast_nullable_to_non_nullable
as int,actionId: null == actionId ? _self.actionId : actionId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
