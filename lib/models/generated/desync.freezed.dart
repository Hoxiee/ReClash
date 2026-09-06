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
mixin _$DesyncStrategy implements DiagnosticableTreeMixin {

 String get name; List<String> get args;
/// Create a copy of DesyncStrategy
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DesyncStrategyCopyWith<DesyncStrategy> get copyWith => _$DesyncStrategyCopyWithImpl<DesyncStrategy>(this as DesyncStrategy, _$identity);

  /// Serializes this DesyncStrategy to a JSON map.
  Map<String, dynamic> toJson();

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  final _this = this as DesyncStrategy;
  properties
    ..add(DiagnosticsProperty('type', 'DesyncStrategy'))
    ..add(DiagnosticsProperty('name', _this.name))..add(DiagnosticsProperty('args', _this.args));
}

@override
bool operator ==(Object other) {
  final _this = this as DesyncStrategy;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DesyncStrategy&&(identical(other.name, _this.name) || other.name == _this.name)&&const DeepCollectionEquality().equals(other.args, _this.args));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DesyncStrategy;
  return Object.hash(runtimeType,_this.name,const DeepCollectionEquality().hash(_this.args));
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  final _this = this as DesyncStrategy;
  return 'DesyncStrategy(name: ${_this.name}, args: ${_this.args})';
}


}

/// @nodoc
abstract mixin class $DesyncStrategyCopyWith<$Res>  {
  factory $DesyncStrategyCopyWith(DesyncStrategy value, $Res Function(DesyncStrategy) _then) = _$DesyncStrategyCopyWithImpl;
@useResult
$Res call({
 String name, List<String> args
});




}
/// @nodoc
class _$DesyncStrategyCopyWithImpl<$Res>
    implements $DesyncStrategyCopyWith<$Res> {
  _$DesyncStrategyCopyWithImpl(this._self, this._then);

  final DesyncStrategy _self;
  final $Res Function(DesyncStrategy) _then;

/// Create a copy of DesyncStrategy
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? args = null,}) {
  return _then(DesyncStrategy(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,args: null == args ? _self.args : args // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [DesyncStrategy].
extension DesyncStrategyPatterns on DesyncStrategy {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DesyncStrategy value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DesyncStrategy() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DesyncStrategy value)  $default,){
final _that = this;
switch (_that) {
case _DesyncStrategy():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DesyncStrategy value)?  $default,){
final _that = this;
switch (_that) {
case _DesyncStrategy() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  List<String> args)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DesyncStrategy() when $default != null:
return $default(_that.name,_that.args);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  List<String> args)  $default,) {final _that = this;
switch (_that) {
case _DesyncStrategy():
return $default(_that.name,_that.args);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  List<String> args)?  $default,) {final _that = this;
switch (_that) {
case _DesyncStrategy() when $default != null:
return $default(_that.name,_that.args);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DesyncStrategy with DiagnosticableTreeMixin implements DesyncStrategy {
  const _DesyncStrategy({required this.name,  List<String> args = const []}): _args = args;
  factory _DesyncStrategy.fromJson(Map<String, dynamic> json) => _$DesyncStrategyFromJson(json);

@override final  String name;
 final  List<String> _args;
@override@JsonKey() List<String> get args {
  if (_args is EqualUnmodifiableListView) return _args;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_args);
}


/// Create a copy of DesyncStrategy
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DesyncStrategyCopyWith<_DesyncStrategy> get copyWith => __$DesyncStrategyCopyWithImpl<_DesyncStrategy>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DesyncStrategyToJson(this, );
}
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
    ..add(DiagnosticsProperty('type', 'DesyncStrategy'))
    ..add(DiagnosticsProperty('name', name))..add(DiagnosticsProperty('args', args));
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DesyncStrategy&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.args, _args));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,const DeepCollectionEquality().hash(_args));
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
    return 'DesyncStrategy(name: $name, args: $args)';
}


}

/// @nodoc
abstract mixin class _$DesyncStrategyCopyWith<$Res> implements $DesyncStrategyCopyWith<$Res> {
  factory _$DesyncStrategyCopyWith(_DesyncStrategy value, $Res Function(_DesyncStrategy) _then) = __$DesyncStrategyCopyWithImpl;
@override @useResult
$Res call({
 String name, List<String> args
});




}
/// @nodoc
class __$DesyncStrategyCopyWithImpl<$Res>
    implements _$DesyncStrategyCopyWith<$Res> {
  __$DesyncStrategyCopyWithImpl(this._self, this._then);

  final _DesyncStrategy _self;
  final $Res Function(_DesyncStrategy) _then;

/// Create a copy of DesyncStrategy
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? args = null,}) {
  return _then(_DesyncStrategy(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,args: null == args ? _self._args : args // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$DesyncProps implements DiagnosticableTreeMixin {

 bool get enabled; bool get onlyDpi; int get port; List<DesyncCategory> get categories; bool get forceTcp; List<String> get strategyArgs; bool get cacheEnabled; int get cacheTtl; List<DesyncStrategy> get savedStrategies; List<String> get testSiteLists; bool get testRunning; List<String>? get testRestoreArgs;
/// Create a copy of DesyncProps
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DesyncPropsCopyWith<DesyncProps> get copyWith => _$DesyncPropsCopyWithImpl<DesyncProps>(this as DesyncProps, _$identity);

  /// Serializes this DesyncProps to a JSON map.
  Map<String, dynamic> toJson();

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  final _this = this as DesyncProps;
  properties
    ..add(DiagnosticsProperty('type', 'DesyncProps'))
    ..add(DiagnosticsProperty('enabled', _this.enabled))..add(DiagnosticsProperty('onlyDpi', _this.onlyDpi))..add(DiagnosticsProperty('port', _this.port))..add(DiagnosticsProperty('categories', _this.categories))..add(DiagnosticsProperty('forceTcp', _this.forceTcp))..add(DiagnosticsProperty('strategyArgs', _this.strategyArgs))..add(DiagnosticsProperty('cacheEnabled', _this.cacheEnabled))..add(DiagnosticsProperty('cacheTtl', _this.cacheTtl))..add(DiagnosticsProperty('savedStrategies', _this.savedStrategies))..add(DiagnosticsProperty('testSiteLists', _this.testSiteLists))..add(DiagnosticsProperty('testRunning', _this.testRunning))..add(DiagnosticsProperty('testRestoreArgs', _this.testRestoreArgs));
}

@override
bool operator ==(Object other) {
  final _this = this as DesyncProps;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DesyncProps&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled)&&(identical(other.onlyDpi, _this.onlyDpi) || other.onlyDpi == _this.onlyDpi)&&(identical(other.port, _this.port) || other.port == _this.port)&&const DeepCollectionEquality().equals(other.categories, _this.categories)&&(identical(other.forceTcp, _this.forceTcp) || other.forceTcp == _this.forceTcp)&&const DeepCollectionEquality().equals(other.strategyArgs, _this.strategyArgs)&&(identical(other.cacheEnabled, _this.cacheEnabled) || other.cacheEnabled == _this.cacheEnabled)&&(identical(other.cacheTtl, _this.cacheTtl) || other.cacheTtl == _this.cacheTtl)&&const DeepCollectionEquality().equals(other.savedStrategies, _this.savedStrategies)&&const DeepCollectionEquality().equals(other.testSiteLists, _this.testSiteLists)&&(identical(other.testRunning, _this.testRunning) || other.testRunning == _this.testRunning)&&const DeepCollectionEquality().equals(other.testRestoreArgs, _this.testRestoreArgs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DesyncProps;
  return Object.hash(runtimeType,_this.enabled,_this.onlyDpi,_this.port,const DeepCollectionEquality().hash(_this.categories),_this.forceTcp,const DeepCollectionEquality().hash(_this.strategyArgs),_this.cacheEnabled,_this.cacheTtl,const DeepCollectionEquality().hash(_this.savedStrategies),const DeepCollectionEquality().hash(_this.testSiteLists),_this.testRunning,const DeepCollectionEquality().hash(_this.testRestoreArgs));
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  final _this = this as DesyncProps;
  return 'DesyncProps(enabled: ${_this.enabled}, onlyDpi: ${_this.onlyDpi}, port: ${_this.port}, categories: ${_this.categories}, forceTcp: ${_this.forceTcp}, strategyArgs: ${_this.strategyArgs}, cacheEnabled: ${_this.cacheEnabled}, cacheTtl: ${_this.cacheTtl}, savedStrategies: ${_this.savedStrategies}, testSiteLists: ${_this.testSiteLists}, testRunning: ${_this.testRunning}, testRestoreArgs: ${_this.testRestoreArgs})';
}


}

/// @nodoc
abstract mixin class $DesyncPropsCopyWith<$Res>  {
  factory $DesyncPropsCopyWith(DesyncProps value, $Res Function(DesyncProps) _then) = _$DesyncPropsCopyWithImpl;
@useResult
$Res call({
 bool enabled, bool onlyDpi, int port, List<DesyncCategory> categories, bool forceTcp, List<String> strategyArgs, bool cacheEnabled, int cacheTtl, List<DesyncStrategy> savedStrategies, List<String> testSiteLists, bool testRunning, List<String>? testRestoreArgs
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
@pragma('vm:prefer-inline') @override $Res call({Object? enabled = null,Object? onlyDpi = null,Object? port = null,Object? categories = null,Object? forceTcp = null,Object? strategyArgs = null,Object? cacheEnabled = null,Object? cacheTtl = null,Object? savedStrategies = null,Object? testSiteLists = null,Object? testRunning = null,Object? testRestoreArgs = freezed,}) {
  return _then(DesyncProps(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,onlyDpi: null == onlyDpi ? _self.onlyDpi : onlyDpi // ignore: cast_nullable_to_non_nullable
as bool,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<DesyncCategory>,forceTcp: null == forceTcp ? _self.forceTcp : forceTcp // ignore: cast_nullable_to_non_nullable
as bool,strategyArgs: null == strategyArgs ? _self.strategyArgs : strategyArgs // ignore: cast_nullable_to_non_nullable
as List<String>,cacheEnabled: null == cacheEnabled ? _self.cacheEnabled : cacheEnabled // ignore: cast_nullable_to_non_nullable
as bool,cacheTtl: null == cacheTtl ? _self.cacheTtl : cacheTtl // ignore: cast_nullable_to_non_nullable
as int,savedStrategies: null == savedStrategies ? _self.savedStrategies : savedStrategies // ignore: cast_nullable_to_non_nullable
as List<DesyncStrategy>,testSiteLists: null == testSiteLists ? _self.testSiteLists : testSiteLists // ignore: cast_nullable_to_non_nullable
as List<String>,testRunning: null == testRunning ? _self.testRunning : testRunning // ignore: cast_nullable_to_non_nullable
as bool,testRestoreArgs: freezed == testRestoreArgs ? _self.testRestoreArgs : testRestoreArgs // ignore: cast_nullable_to_non_nullable
as List<String>?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enabled,  bool onlyDpi,  int port,  List<DesyncCategory> categories,  bool forceTcp,  List<String> strategyArgs,  bool cacheEnabled,  int cacheTtl,  List<DesyncStrategy> savedStrategies,  List<String> testSiteLists,  bool testRunning,  List<String>? testRestoreArgs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DesyncProps() when $default != null:
return $default(_that.enabled,_that.onlyDpi,_that.port,_that.categories,_that.forceTcp,_that.strategyArgs,_that.cacheEnabled,_that.cacheTtl,_that.savedStrategies,_that.testSiteLists,_that.testRunning,_that.testRestoreArgs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enabled,  bool onlyDpi,  int port,  List<DesyncCategory> categories,  bool forceTcp,  List<String> strategyArgs,  bool cacheEnabled,  int cacheTtl,  List<DesyncStrategy> savedStrategies,  List<String> testSiteLists,  bool testRunning,  List<String>? testRestoreArgs)  $default,) {final _that = this;
switch (_that) {
case _DesyncProps():
return $default(_that.enabled,_that.onlyDpi,_that.port,_that.categories,_that.forceTcp,_that.strategyArgs,_that.cacheEnabled,_that.cacheTtl,_that.savedStrategies,_that.testSiteLists,_that.testRunning,_that.testRestoreArgs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enabled,  bool onlyDpi,  int port,  List<DesyncCategory> categories,  bool forceTcp,  List<String> strategyArgs,  bool cacheEnabled,  int cacheTtl,  List<DesyncStrategy> savedStrategies,  List<String> testSiteLists,  bool testRunning,  List<String>? testRestoreArgs)?  $default,) {final _that = this;
switch (_that) {
case _DesyncProps() when $default != null:
return $default(_that.enabled,_that.onlyDpi,_that.port,_that.categories,_that.forceTcp,_that.strategyArgs,_that.cacheEnabled,_that.cacheTtl,_that.savedStrategies,_that.testSiteLists,_that.testRunning,_that.testRestoreArgs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DesyncProps with DiagnosticableTreeMixin implements DesyncProps {
  const _DesyncProps({this.enabled = false, this.onlyDpi = false, this.port = defaultDesyncPort,  List<DesyncCategory> categories = const [DesyncCategory.youtube, DesyncCategory.discord], this.forceTcp = true,  List<String> strategyArgs = desyncDefaultStrategy, this.cacheEnabled = true, this.cacheTtl = defaultDesyncCacheTtl,  List<DesyncStrategy> savedStrategies = const [],  List<String> testSiteLists = defaultDesyncTestSiteLists, this.testRunning = false,  List<String>? testRestoreArgs = null}): _categories = categories,_strategyArgs = strategyArgs,_savedStrategies = savedStrategies,_testSiteLists = testSiteLists,_testRestoreArgs = testRestoreArgs;
  factory _DesyncProps.fromJson(Map<String, dynamic> json) => _$DesyncPropsFromJson(json);

@override@JsonKey() final  bool enabled;
@override@JsonKey() final  bool onlyDpi;
@override@JsonKey() final  int port;
 final  List<DesyncCategory> _categories;
@override@JsonKey() List<DesyncCategory> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

@override@JsonKey() final  bool forceTcp;
 final  List<String> _strategyArgs;
@override@JsonKey() List<String> get strategyArgs {
  if (_strategyArgs is EqualUnmodifiableListView) return _strategyArgs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_strategyArgs);
}

@override@JsonKey() final  bool cacheEnabled;
@override@JsonKey() final  int cacheTtl;
 final  List<DesyncStrategy> _savedStrategies;
@override@JsonKey() List<DesyncStrategy> get savedStrategies {
  if (_savedStrategies is EqualUnmodifiableListView) return _savedStrategies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_savedStrategies);
}

 final  List<String> _testSiteLists;
@override@JsonKey() List<String> get testSiteLists {
  if (_testSiteLists is EqualUnmodifiableListView) return _testSiteLists;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_testSiteLists);
}

@override@JsonKey() final  bool testRunning;
 final  List<String>? _testRestoreArgs;
@override@JsonKey() List<String>? get testRestoreArgs {
  final value = _testRestoreArgs;
  if (value == null) return null;
  if (_testRestoreArgs is EqualUnmodifiableListView) return _testRestoreArgs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


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
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
    ..add(DiagnosticsProperty('type', 'DesyncProps'))
    ..add(DiagnosticsProperty('enabled', enabled))..add(DiagnosticsProperty('onlyDpi', onlyDpi))..add(DiagnosticsProperty('port', port))..add(DiagnosticsProperty('categories', categories))..add(DiagnosticsProperty('forceTcp', forceTcp))..add(DiagnosticsProperty('strategyArgs', strategyArgs))..add(DiagnosticsProperty('cacheEnabled', cacheEnabled))..add(DiagnosticsProperty('cacheTtl', cacheTtl))..add(DiagnosticsProperty('savedStrategies', savedStrategies))..add(DiagnosticsProperty('testSiteLists', testSiteLists))..add(DiagnosticsProperty('testRunning', testRunning))..add(DiagnosticsProperty('testRestoreArgs', testRestoreArgs));
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DesyncProps&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.onlyDpi, onlyDpi) || other.onlyDpi == onlyDpi)&&(identical(other.port, port) || other.port == port)&&const DeepCollectionEquality().equals(other.categories, _categories)&&(identical(other.forceTcp, forceTcp) || other.forceTcp == forceTcp)&&const DeepCollectionEquality().equals(other.strategyArgs, _strategyArgs)&&(identical(other.cacheEnabled, cacheEnabled) || other.cacheEnabled == cacheEnabled)&&(identical(other.cacheTtl, cacheTtl) || other.cacheTtl == cacheTtl)&&const DeepCollectionEquality().equals(other.savedStrategies, _savedStrategies)&&const DeepCollectionEquality().equals(other.testSiteLists, _testSiteLists)&&(identical(other.testRunning, testRunning) || other.testRunning == testRunning)&&const DeepCollectionEquality().equals(other.testRestoreArgs, _testRestoreArgs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,enabled,onlyDpi,port,const DeepCollectionEquality().hash(_categories),forceTcp,const DeepCollectionEquality().hash(_strategyArgs),cacheEnabled,cacheTtl,const DeepCollectionEquality().hash(_savedStrategies),const DeepCollectionEquality().hash(_testSiteLists),testRunning,const DeepCollectionEquality().hash(_testRestoreArgs));
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
    return 'DesyncProps(enabled: $enabled, onlyDpi: $onlyDpi, port: $port, categories: $categories, forceTcp: $forceTcp, strategyArgs: $strategyArgs, cacheEnabled: $cacheEnabled, cacheTtl: $cacheTtl, savedStrategies: $savedStrategies, testSiteLists: $testSiteLists, testRunning: $testRunning, testRestoreArgs: $testRestoreArgs)';
}


}

/// @nodoc
abstract mixin class _$DesyncPropsCopyWith<$Res> implements $DesyncPropsCopyWith<$Res> {
  factory _$DesyncPropsCopyWith(_DesyncProps value, $Res Function(_DesyncProps) _then) = __$DesyncPropsCopyWithImpl;
@override @useResult
$Res call({
 bool enabled, bool onlyDpi, int port, List<DesyncCategory> categories, bool forceTcp, List<String> strategyArgs, bool cacheEnabled, int cacheTtl, List<DesyncStrategy> savedStrategies, List<String> testSiteLists, bool testRunning, List<String>? testRestoreArgs
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
@override @pragma('vm:prefer-inline') $Res call({Object? enabled = null,Object? onlyDpi = null,Object? port = null,Object? categories = null,Object? forceTcp = null,Object? strategyArgs = null,Object? cacheEnabled = null,Object? cacheTtl = null,Object? savedStrategies = null,Object? testSiteLists = null,Object? testRunning = null,Object? testRestoreArgs = freezed,}) {
  return _then(_DesyncProps(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,onlyDpi: null == onlyDpi ? _self.onlyDpi : onlyDpi // ignore: cast_nullable_to_non_nullable
as bool,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<DesyncCategory>,forceTcp: null == forceTcp ? _self.forceTcp : forceTcp // ignore: cast_nullable_to_non_nullable
as bool,strategyArgs: null == strategyArgs ? _self._strategyArgs : strategyArgs // ignore: cast_nullable_to_non_nullable
as List<String>,cacheEnabled: null == cacheEnabled ? _self.cacheEnabled : cacheEnabled // ignore: cast_nullable_to_non_nullable
as bool,cacheTtl: null == cacheTtl ? _self.cacheTtl : cacheTtl // ignore: cast_nullable_to_non_nullable
as int,savedStrategies: null == savedStrategies ? _self._savedStrategies : savedStrategies // ignore: cast_nullable_to_non_nullable
as List<DesyncStrategy>,testSiteLists: null == testSiteLists ? _self._testSiteLists : testSiteLists // ignore: cast_nullable_to_non_nullable
as List<String>,testRunning: null == testRunning ? _self.testRunning : testRunning // ignore: cast_nullable_to_non_nullable
as bool,testRestoreArgs: freezed == testRestoreArgs ? _self._testRestoreArgs : testRestoreArgs // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}

// dart format on
