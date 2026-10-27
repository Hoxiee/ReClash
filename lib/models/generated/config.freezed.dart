// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Filter {

 String get label; String get regex;
/// Create a copy of Filter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FilterCopyWith<Filter> get copyWith => _$FilterCopyWithImpl<Filter>(this as Filter, _$identity);

  /// Serializes this Filter to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Filter;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Filter&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.regex, _this.regex) || other.regex == _this.regex));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Filter;
  return Object.hash(runtimeType,_this.label,_this.regex);
}

@override
String toString() {
  final _this = this as Filter;
  return 'Filter(label: ${_this.label}, regex: ${_this.regex})';
}


}

/// @nodoc
abstract mixin class $FilterCopyWith<$Res>  {
  factory $FilterCopyWith(Filter value, $Res Function(Filter) _then) = _$FilterCopyWithImpl;
@useResult
$Res call({
 String label, String regex
});




}
/// @nodoc
class _$FilterCopyWithImpl<$Res>
    implements $FilterCopyWith<$Res> {
  _$FilterCopyWithImpl(this._self, this._then);

  final Filter _self;
  final $Res Function(Filter) _then;

/// Create a copy of Filter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = null,Object? regex = null,}) {
  return _then(Filter(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,regex: null == regex ? _self.regex : regex // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Filter].
extension FilterPatterns on Filter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Filter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Filter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Filter value)  $default,){
final _that = this;
switch (_that) {
case _Filter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Filter value)?  $default,){
final _that = this;
switch (_that) {
case _Filter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String label,  String regex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Filter() when $default != null:
return $default(_that.label,_that.regex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String label,  String regex)  $default,) {final _that = this;
switch (_that) {
case _Filter():
return $default(_that.label,_that.regex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String label,  String regex)?  $default,) {final _that = this;
switch (_that) {
case _Filter() when $default != null:
return $default(_that.label,_that.regex);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Filter implements Filter {
  const _Filter({required this.label, required this.regex});
  factory _Filter.fromJson(Map<String, dynamic> json) => _$FilterFromJson(json);

@override final  String label;
@override final  String regex;

/// Create a copy of Filter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FilterCopyWith<_Filter> get copyWith => __$FilterCopyWithImpl<_Filter>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FilterToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Filter&&(identical(other.label, label) || other.label == label)&&(identical(other.regex, regex) || other.regex == regex));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,label,regex);
}

@override
String toString() {
    return 'Filter(label: $label, regex: $regex)';
}


}

/// @nodoc
abstract mixin class _$FilterCopyWith<$Res> implements $FilterCopyWith<$Res> {
  factory _$FilterCopyWith(_Filter value, $Res Function(_Filter) _then) = __$FilterCopyWithImpl;
@override @useResult
$Res call({
 String label, String regex
});




}
/// @nodoc
class __$FilterCopyWithImpl<$Res>
    implements _$FilterCopyWith<$Res> {
  __$FilterCopyWithImpl(this._self, this._then);

  final _Filter _self;
  final $Res Function(_Filter) _then;

/// Create a copy of Filter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? regex = null,}) {
  return _then(_Filter(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,regex: null == regex ? _self.regex : regex // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$AppSettingProps {

 String? get locale;@JsonKey(fromJson: sanitizeRegionCode) String? get regionCode;@JsonKey(fromJson: dashboardWidgetsFromJson) List<DashboardWidget> get dashboardWidgets;@JsonKey(unknownEnumValue: DashboardStyle.detailed) DashboardStyle get dashboardStyle;@JsonKey(fromJson: simpleDashboardWidgetsFromJson) List<SimpleDashboardWidget> get simpleDashboardWidgets; bool get onlyStatisticsProxy;@JsonKey(readValue: readNotificationSettings, fromJson: NotificationSettings.safeFromJson) NotificationSettings get notificationSettings; bool get autoLaunch; bool get silentLaunch; bool get autoRun; bool get openLogs; bool get closeConnections; int get delayTestTimeout;@JsonKey(readValue: _readTabAnimation) TabAnimation get tabAnimation; bool get floatingNavigationBar;@JsonKey(unknownEnumValue: NavigationLayout.auto) NavigationLayout get navigationLayout; bool? get sidebarNarrow;@JsonKey(unknownEnumValue: NavigationLabels.always) NavigationLabels get navigationLabels;@JsonKey(unknownEnumValue: AppIcon.standard) AppIcon get appIcon;@JsonKey(unknownEnumValue: TrayIconStyle.color) TrayIconStyle get trayIconStyle; bool get autoCheckUpdate; bool get autoDownloadUpdate; bool get autoInstallUpdate;@JsonKey(fromJson: updateChannelFromJson) UpdateChannel? get updateChannel;@JsonKey(readValue: _readSidebarExpanded) bool get sidebarExpanded; int get acceptedDisclaimerVersion; bool? get setupCompleted; int get setupStep; int? get setupProfileId; String? get setupCoverage; String? get setupRegionCode; bool get setupRegionChosen; bool get setupDirectRoutes; bool get minimizeOnExit; bool get hidden; bool get developerMode; RestoreStrategy get restoreStrategy; bool get showTrayTitle; bool get monochromeTrayIcon; bool get checkCertificate;@JsonKey(readValue: _readUserAgents) List<String> get userAgents; List<Filter> get filters; bool get hideIp; bool get editorLineWrap; EditorFontSize get editorFontSize; bool get preventDuplicateProfiles; bool get autoCheckActiveServices; bool get autoCheckAllServices; bool get serviceCheckOnlyWhenConnected; List<String> get serviceOrder; List<String> get enabledServices; List<String> get disabledServices; Map<String, Map<String, double>> get tableColumnWidths;@JsonKey(unknownEnumValue: WebDashboardFlavor.zashboard) WebDashboardFlavor get webDashboardFlavor;@JsonKey(fromJson: SpeedTestSettings.safeFromJson) SpeedTestSettings get speedTest;
/// Create a copy of AppSettingProps
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppSettingPropsCopyWith<AppSettingProps> get copyWith => _$AppSettingPropsCopyWithImpl<AppSettingProps>(this as AppSettingProps, _$identity);

  /// Serializes this AppSettingProps to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AppSettingProps;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppSettingProps&&(identical(other.locale, _this.locale) || other.locale == _this.locale)&&(identical(other.regionCode, _this.regionCode) || other.regionCode == _this.regionCode)&&const DeepCollectionEquality().equals(other.dashboardWidgets, _this.dashboardWidgets)&&(identical(other.dashboardStyle, _this.dashboardStyle) || other.dashboardStyle == _this.dashboardStyle)&&const DeepCollectionEquality().equals(other.simpleDashboardWidgets, _this.simpleDashboardWidgets)&&(identical(other.onlyStatisticsProxy, _this.onlyStatisticsProxy) || other.onlyStatisticsProxy == _this.onlyStatisticsProxy)&&(identical(other.notificationSettings, _this.notificationSettings) || other.notificationSettings == _this.notificationSettings)&&(identical(other.autoLaunch, _this.autoLaunch) || other.autoLaunch == _this.autoLaunch)&&(identical(other.silentLaunch, _this.silentLaunch) || other.silentLaunch == _this.silentLaunch)&&(identical(other.autoRun, _this.autoRun) || other.autoRun == _this.autoRun)&&(identical(other.openLogs, _this.openLogs) || other.openLogs == _this.openLogs)&&(identical(other.closeConnections, _this.closeConnections) || other.closeConnections == _this.closeConnections)&&(identical(other.delayTestTimeout, _this.delayTestTimeout) || other.delayTestTimeout == _this.delayTestTimeout)&&(identical(other.tabAnimation, _this.tabAnimation) || other.tabAnimation == _this.tabAnimation)&&(identical(other.floatingNavigationBar, _this.floatingNavigationBar) || other.floatingNavigationBar == _this.floatingNavigationBar)&&(identical(other.navigationLayout, _this.navigationLayout) || other.navigationLayout == _this.navigationLayout)&&(identical(other.sidebarNarrow, _this.sidebarNarrow) || other.sidebarNarrow == _this.sidebarNarrow)&&(identical(other.navigationLabels, _this.navigationLabels) || other.navigationLabels == _this.navigationLabels)&&(identical(other.appIcon, _this.appIcon) || other.appIcon == _this.appIcon)&&(identical(other.trayIconStyle, _this.trayIconStyle) || other.trayIconStyle == _this.trayIconStyle)&&(identical(other.autoCheckUpdate, _this.autoCheckUpdate) || other.autoCheckUpdate == _this.autoCheckUpdate)&&(identical(other.autoDownloadUpdate, _this.autoDownloadUpdate) || other.autoDownloadUpdate == _this.autoDownloadUpdate)&&(identical(other.autoInstallUpdate, _this.autoInstallUpdate) || other.autoInstallUpdate == _this.autoInstallUpdate)&&(identical(other.updateChannel, _this.updateChannel) || other.updateChannel == _this.updateChannel)&&(identical(other.sidebarExpanded, _this.sidebarExpanded) || other.sidebarExpanded == _this.sidebarExpanded)&&(identical(other.acceptedDisclaimerVersion, _this.acceptedDisclaimerVersion) || other.acceptedDisclaimerVersion == _this.acceptedDisclaimerVersion)&&(identical(other.setupCompleted, _this.setupCompleted) || other.setupCompleted == _this.setupCompleted)&&(identical(other.setupStep, _this.setupStep) || other.setupStep == _this.setupStep)&&(identical(other.setupProfileId, _this.setupProfileId) || other.setupProfileId == _this.setupProfileId)&&(identical(other.setupCoverage, _this.setupCoverage) || other.setupCoverage == _this.setupCoverage)&&(identical(other.setupRegionCode, _this.setupRegionCode) || other.setupRegionCode == _this.setupRegionCode)&&(identical(other.setupRegionChosen, _this.setupRegionChosen) || other.setupRegionChosen == _this.setupRegionChosen)&&(identical(other.setupDirectRoutes, _this.setupDirectRoutes) || other.setupDirectRoutes == _this.setupDirectRoutes)&&(identical(other.minimizeOnExit, _this.minimizeOnExit) || other.minimizeOnExit == _this.minimizeOnExit)&&(identical(other.hidden, _this.hidden) || other.hidden == _this.hidden)&&(identical(other.developerMode, _this.developerMode) || other.developerMode == _this.developerMode)&&(identical(other.restoreStrategy, _this.restoreStrategy) || other.restoreStrategy == _this.restoreStrategy)&&(identical(other.showTrayTitle, _this.showTrayTitle) || other.showTrayTitle == _this.showTrayTitle)&&(identical(other.monochromeTrayIcon, _this.monochromeTrayIcon) || other.monochromeTrayIcon == _this.monochromeTrayIcon)&&(identical(other.checkCertificate, _this.checkCertificate) || other.checkCertificate == _this.checkCertificate)&&const DeepCollectionEquality().equals(other.userAgents, _this.userAgents)&&const DeepCollectionEquality().equals(other.filters, _this.filters)&&(identical(other.hideIp, _this.hideIp) || other.hideIp == _this.hideIp)&&(identical(other.editorLineWrap, _this.editorLineWrap) || other.editorLineWrap == _this.editorLineWrap)&&(identical(other.editorFontSize, _this.editorFontSize) || other.editorFontSize == _this.editorFontSize)&&(identical(other.preventDuplicateProfiles, _this.preventDuplicateProfiles) || other.preventDuplicateProfiles == _this.preventDuplicateProfiles)&&(identical(other.autoCheckActiveServices, _this.autoCheckActiveServices) || other.autoCheckActiveServices == _this.autoCheckActiveServices)&&(identical(other.autoCheckAllServices, _this.autoCheckAllServices) || other.autoCheckAllServices == _this.autoCheckAllServices)&&(identical(other.serviceCheckOnlyWhenConnected, _this.serviceCheckOnlyWhenConnected) || other.serviceCheckOnlyWhenConnected == _this.serviceCheckOnlyWhenConnected)&&const DeepCollectionEquality().equals(other.serviceOrder, _this.serviceOrder)&&const DeepCollectionEquality().equals(other.enabledServices, _this.enabledServices)&&const DeepCollectionEquality().equals(other.disabledServices, _this.disabledServices)&&const DeepCollectionEquality().equals(other.tableColumnWidths, _this.tableColumnWidths)&&(identical(other.webDashboardFlavor, _this.webDashboardFlavor) || other.webDashboardFlavor == _this.webDashboardFlavor)&&(identical(other.speedTest, _this.speedTest) || other.speedTest == _this.speedTest));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AppSettingProps;
  return Object.hashAll([runtimeType,_this.locale,_this.regionCode,const DeepCollectionEquality().hash(_this.dashboardWidgets),_this.dashboardStyle,const DeepCollectionEquality().hash(_this.simpleDashboardWidgets),_this.onlyStatisticsProxy,_this.notificationSettings,_this.autoLaunch,_this.silentLaunch,_this.autoRun,_this.openLogs,_this.closeConnections,_this.delayTestTimeout,_this.tabAnimation,_this.floatingNavigationBar,_this.navigationLayout,_this.sidebarNarrow,_this.navigationLabels,_this.appIcon,_this.trayIconStyle,_this.autoCheckUpdate,_this.autoDownloadUpdate,_this.autoInstallUpdate,_this.updateChannel,_this.sidebarExpanded,_this.acceptedDisclaimerVersion,_this.setupCompleted,_this.setupStep,_this.setupProfileId,_this.setupCoverage,_this.setupRegionCode,_this.setupRegionChosen,_this.setupDirectRoutes,_this.minimizeOnExit,_this.hidden,_this.developerMode,_this.restoreStrategy,_this.showTrayTitle,_this.monochromeTrayIcon,_this.checkCertificate,const DeepCollectionEquality().hash(_this.userAgents),const DeepCollectionEquality().hash(_this.filters),_this.hideIp,_this.editorLineWrap,_this.editorFontSize,_this.preventDuplicateProfiles,_this.autoCheckActiveServices,_this.autoCheckAllServices,_this.serviceCheckOnlyWhenConnected,const DeepCollectionEquality().hash(_this.serviceOrder),const DeepCollectionEquality().hash(_this.enabledServices),const DeepCollectionEquality().hash(_this.disabledServices),const DeepCollectionEquality().hash(_this.tableColumnWidths),_this.webDashboardFlavor,_this.speedTest]);
}

@override
String toString() {
  final _this = this as AppSettingProps;
  return 'AppSettingProps(locale: ${_this.locale}, regionCode: ${_this.regionCode}, dashboardWidgets: ${_this.dashboardWidgets}, dashboardStyle: ${_this.dashboardStyle}, simpleDashboardWidgets: ${_this.simpleDashboardWidgets}, onlyStatisticsProxy: ${_this.onlyStatisticsProxy}, notificationSettings: ${_this.notificationSettings}, autoLaunch: ${_this.autoLaunch}, silentLaunch: ${_this.silentLaunch}, autoRun: ${_this.autoRun}, openLogs: ${_this.openLogs}, closeConnections: ${_this.closeConnections}, delayTestTimeout: ${_this.delayTestTimeout}, tabAnimation: ${_this.tabAnimation}, floatingNavigationBar: ${_this.floatingNavigationBar}, navigationLayout: ${_this.navigationLayout}, sidebarNarrow: ${_this.sidebarNarrow}, navigationLabels: ${_this.navigationLabels}, appIcon: ${_this.appIcon}, trayIconStyle: ${_this.trayIconStyle}, autoCheckUpdate: ${_this.autoCheckUpdate}, autoDownloadUpdate: ${_this.autoDownloadUpdate}, autoInstallUpdate: ${_this.autoInstallUpdate}, updateChannel: ${_this.updateChannel}, sidebarExpanded: ${_this.sidebarExpanded}, acceptedDisclaimerVersion: ${_this.acceptedDisclaimerVersion}, setupCompleted: ${_this.setupCompleted}, setupStep: ${_this.setupStep}, setupProfileId: ${_this.setupProfileId}, setupCoverage: ${_this.setupCoverage}, setupRegionCode: ${_this.setupRegionCode}, setupRegionChosen: ${_this.setupRegionChosen}, setupDirectRoutes: ${_this.setupDirectRoutes}, minimizeOnExit: ${_this.minimizeOnExit}, hidden: ${_this.hidden}, developerMode: ${_this.developerMode}, restoreStrategy: ${_this.restoreStrategy}, showTrayTitle: ${_this.showTrayTitle}, monochromeTrayIcon: ${_this.monochromeTrayIcon}, checkCertificate: ${_this.checkCertificate}, userAgents: ${_this.userAgents}, filters: ${_this.filters}, hideIp: ${_this.hideIp}, editorLineWrap: ${_this.editorLineWrap}, editorFontSize: ${_this.editorFontSize}, preventDuplicateProfiles: ${_this.preventDuplicateProfiles}, autoCheckActiveServices: ${_this.autoCheckActiveServices}, autoCheckAllServices: ${_this.autoCheckAllServices}, serviceCheckOnlyWhenConnected: ${_this.serviceCheckOnlyWhenConnected}, serviceOrder: ${_this.serviceOrder}, enabledServices: ${_this.enabledServices}, disabledServices: ${_this.disabledServices}, tableColumnWidths: ${_this.tableColumnWidths}, webDashboardFlavor: ${_this.webDashboardFlavor}, speedTest: ${_this.speedTest})';
}


}

/// @nodoc
abstract mixin class $AppSettingPropsCopyWith<$Res>  {
  factory $AppSettingPropsCopyWith(AppSettingProps value, $Res Function(AppSettingProps) _then) = _$AppSettingPropsCopyWithImpl;
@useResult
$Res call({
 String? locale,@JsonKey(fromJson: sanitizeRegionCode) String? regionCode,@JsonKey(fromJson: dashboardWidgetsFromJson) List<DashboardWidget> dashboardWidgets,@JsonKey(unknownEnumValue: DashboardStyle.detailed) DashboardStyle dashboardStyle,@JsonKey(fromJson: simpleDashboardWidgetsFromJson) List<SimpleDashboardWidget> simpleDashboardWidgets, bool onlyStatisticsProxy,@JsonKey(readValue: readNotificationSettings, fromJson: NotificationSettings.safeFromJson) NotificationSettings notificationSettings, bool autoLaunch, bool silentLaunch, bool autoRun, bool openLogs, bool closeConnections, int delayTestTimeout,@JsonKey(readValue: _readTabAnimation) TabAnimation tabAnimation, bool floatingNavigationBar,@JsonKey(unknownEnumValue: NavigationLayout.auto) NavigationLayout navigationLayout, bool? sidebarNarrow,@JsonKey(unknownEnumValue: NavigationLabels.always) NavigationLabels navigationLabels,@JsonKey(unknownEnumValue: AppIcon.standard) AppIcon appIcon,@JsonKey(unknownEnumValue: TrayIconStyle.color) TrayIconStyle trayIconStyle, bool autoCheckUpdate, bool autoDownloadUpdate, bool autoInstallUpdate,@JsonKey(fromJson: updateChannelFromJson) UpdateChannel? updateChannel,@JsonKey(readValue: _readSidebarExpanded) bool sidebarExpanded, int acceptedDisclaimerVersion, bool? setupCompleted, int setupStep, int? setupProfileId, String? setupCoverage, String? setupRegionCode, bool setupRegionChosen, bool setupDirectRoutes, bool minimizeOnExit, bool hidden, bool developerMode, RestoreStrategy restoreStrategy, bool showTrayTitle, bool monochromeTrayIcon, bool checkCertificate,@JsonKey(readValue: _readUserAgents) List<String> userAgents, List<Filter> filters, bool hideIp, bool editorLineWrap, EditorFontSize editorFontSize, bool preventDuplicateProfiles, bool autoCheckActiveServices, bool autoCheckAllServices, bool serviceCheckOnlyWhenConnected, List<String> serviceOrder, List<String> enabledServices, List<String> disabledServices, Map<String, Map<String, double>> tableColumnWidths,@JsonKey(unknownEnumValue: WebDashboardFlavor.zashboard) WebDashboardFlavor webDashboardFlavor,@JsonKey(fromJson: SpeedTestSettings.safeFromJson) SpeedTestSettings speedTest
});


$NotificationSettingsCopyWith<$Res> get notificationSettings;

}
/// @nodoc
class _$AppSettingPropsCopyWithImpl<$Res>
    implements $AppSettingPropsCopyWith<$Res> {
  _$AppSettingPropsCopyWithImpl(this._self, this._then);

  final AppSettingProps _self;
  final $Res Function(AppSettingProps) _then;

/// Create a copy of AppSettingProps
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? locale = freezed,Object? regionCode = freezed,Object? dashboardWidgets = null,Object? dashboardStyle = null,Object? simpleDashboardWidgets = null,Object? onlyStatisticsProxy = null,Object? notificationSettings = null,Object? autoLaunch = null,Object? silentLaunch = null,Object? autoRun = null,Object? openLogs = null,Object? closeConnections = null,Object? delayTestTimeout = null,Object? tabAnimation = null,Object? floatingNavigationBar = null,Object? navigationLayout = null,Object? sidebarNarrow = freezed,Object? navigationLabels = null,Object? appIcon = null,Object? trayIconStyle = null,Object? autoCheckUpdate = null,Object? autoDownloadUpdate = null,Object? autoInstallUpdate = null,Object? updateChannel = freezed,Object? sidebarExpanded = null,Object? acceptedDisclaimerVersion = null,Object? setupCompleted = freezed,Object? setupStep = null,Object? setupProfileId = freezed,Object? setupCoverage = freezed,Object? setupRegionCode = freezed,Object? setupRegionChosen = null,Object? setupDirectRoutes = null,Object? minimizeOnExit = null,Object? hidden = null,Object? developerMode = null,Object? restoreStrategy = null,Object? showTrayTitle = null,Object? monochromeTrayIcon = null,Object? checkCertificate = null,Object? userAgents = null,Object? filters = null,Object? hideIp = null,Object? editorLineWrap = null,Object? editorFontSize = null,Object? preventDuplicateProfiles = null,Object? autoCheckActiveServices = null,Object? autoCheckAllServices = null,Object? serviceCheckOnlyWhenConnected = null,Object? serviceOrder = null,Object? enabledServices = null,Object? disabledServices = null,Object? tableColumnWidths = null,Object? webDashboardFlavor = null,Object? speedTest = null,}) {
  return _then(AppSettingProps(
locale: freezed == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String?,regionCode: freezed == regionCode ? _self.regionCode : regionCode // ignore: cast_nullable_to_non_nullable
as String?,dashboardWidgets: null == dashboardWidgets ? _self.dashboardWidgets : dashboardWidgets // ignore: cast_nullable_to_non_nullable
as List<DashboardWidget>,dashboardStyle: null == dashboardStyle ? _self.dashboardStyle : dashboardStyle // ignore: cast_nullable_to_non_nullable
as DashboardStyle,simpleDashboardWidgets: null == simpleDashboardWidgets ? _self.simpleDashboardWidgets : simpleDashboardWidgets // ignore: cast_nullable_to_non_nullable
as List<SimpleDashboardWidget>,onlyStatisticsProxy: null == onlyStatisticsProxy ? _self.onlyStatisticsProxy : onlyStatisticsProxy // ignore: cast_nullable_to_non_nullable
as bool,notificationSettings: null == notificationSettings ? _self.notificationSettings : notificationSettings // ignore: cast_nullable_to_non_nullable
as NotificationSettings,autoLaunch: null == autoLaunch ? _self.autoLaunch : autoLaunch // ignore: cast_nullable_to_non_nullable
as bool,silentLaunch: null == silentLaunch ? _self.silentLaunch : silentLaunch // ignore: cast_nullable_to_non_nullable
as bool,autoRun: null == autoRun ? _self.autoRun : autoRun // ignore: cast_nullable_to_non_nullable
as bool,openLogs: null == openLogs ? _self.openLogs : openLogs // ignore: cast_nullable_to_non_nullable
as bool,closeConnections: null == closeConnections ? _self.closeConnections : closeConnections // ignore: cast_nullable_to_non_nullable
as bool,delayTestTimeout: null == delayTestTimeout ? _self.delayTestTimeout : delayTestTimeout // ignore: cast_nullable_to_non_nullable
as int,tabAnimation: null == tabAnimation ? _self.tabAnimation : tabAnimation // ignore: cast_nullable_to_non_nullable
as TabAnimation,floatingNavigationBar: null == floatingNavigationBar ? _self.floatingNavigationBar : floatingNavigationBar // ignore: cast_nullable_to_non_nullable
as bool,navigationLayout: null == navigationLayout ? _self.navigationLayout : navigationLayout // ignore: cast_nullable_to_non_nullable
as NavigationLayout,sidebarNarrow: freezed == sidebarNarrow ? _self.sidebarNarrow : sidebarNarrow // ignore: cast_nullable_to_non_nullable
as bool?,navigationLabels: null == navigationLabels ? _self.navigationLabels : navigationLabels // ignore: cast_nullable_to_non_nullable
as NavigationLabels,appIcon: null == appIcon ? _self.appIcon : appIcon // ignore: cast_nullable_to_non_nullable
as AppIcon,trayIconStyle: null == trayIconStyle ? _self.trayIconStyle : trayIconStyle // ignore: cast_nullable_to_non_nullable
as TrayIconStyle,autoCheckUpdate: null == autoCheckUpdate ? _self.autoCheckUpdate : autoCheckUpdate // ignore: cast_nullable_to_non_nullable
as bool,autoDownloadUpdate: null == autoDownloadUpdate ? _self.autoDownloadUpdate : autoDownloadUpdate // ignore: cast_nullable_to_non_nullable
as bool,autoInstallUpdate: null == autoInstallUpdate ? _self.autoInstallUpdate : autoInstallUpdate // ignore: cast_nullable_to_non_nullable
as bool,updateChannel: freezed == updateChannel ? _self.updateChannel : updateChannel // ignore: cast_nullable_to_non_nullable
as UpdateChannel?,sidebarExpanded: null == sidebarExpanded ? _self.sidebarExpanded : sidebarExpanded // ignore: cast_nullable_to_non_nullable
as bool,acceptedDisclaimerVersion: null == acceptedDisclaimerVersion ? _self.acceptedDisclaimerVersion : acceptedDisclaimerVersion // ignore: cast_nullable_to_non_nullable
as int,setupCompleted: freezed == setupCompleted ? _self.setupCompleted : setupCompleted // ignore: cast_nullable_to_non_nullable
as bool?,setupStep: null == setupStep ? _self.setupStep : setupStep // ignore: cast_nullable_to_non_nullable
as int,setupProfileId: freezed == setupProfileId ? _self.setupProfileId : setupProfileId // ignore: cast_nullable_to_non_nullable
as int?,setupCoverage: freezed == setupCoverage ? _self.setupCoverage : setupCoverage // ignore: cast_nullable_to_non_nullable
as String?,setupRegionCode: freezed == setupRegionCode ? _self.setupRegionCode : setupRegionCode // ignore: cast_nullable_to_non_nullable
as String?,setupRegionChosen: null == setupRegionChosen ? _self.setupRegionChosen : setupRegionChosen // ignore: cast_nullable_to_non_nullable
as bool,setupDirectRoutes: null == setupDirectRoutes ? _self.setupDirectRoutes : setupDirectRoutes // ignore: cast_nullable_to_non_nullable
as bool,minimizeOnExit: null == minimizeOnExit ? _self.minimizeOnExit : minimizeOnExit // ignore: cast_nullable_to_non_nullable
as bool,hidden: null == hidden ? _self.hidden : hidden // ignore: cast_nullable_to_non_nullable
as bool,developerMode: null == developerMode ? _self.developerMode : developerMode // ignore: cast_nullable_to_non_nullable
as bool,restoreStrategy: null == restoreStrategy ? _self.restoreStrategy : restoreStrategy // ignore: cast_nullable_to_non_nullable
as RestoreStrategy,showTrayTitle: null == showTrayTitle ? _self.showTrayTitle : showTrayTitle // ignore: cast_nullable_to_non_nullable
as bool,monochromeTrayIcon: null == monochromeTrayIcon ? _self.monochromeTrayIcon : monochromeTrayIcon // ignore: cast_nullable_to_non_nullable
as bool,checkCertificate: null == checkCertificate ? _self.checkCertificate : checkCertificate // ignore: cast_nullable_to_non_nullable
as bool,userAgents: null == userAgents ? _self.userAgents : userAgents // ignore: cast_nullable_to_non_nullable
as List<String>,filters: null == filters ? _self.filters : filters // ignore: cast_nullable_to_non_nullable
as List<Filter>,hideIp: null == hideIp ? _self.hideIp : hideIp // ignore: cast_nullable_to_non_nullable
as bool,editorLineWrap: null == editorLineWrap ? _self.editorLineWrap : editorLineWrap // ignore: cast_nullable_to_non_nullable
as bool,editorFontSize: null == editorFontSize ? _self.editorFontSize : editorFontSize // ignore: cast_nullable_to_non_nullable
as EditorFontSize,preventDuplicateProfiles: null == preventDuplicateProfiles ? _self.preventDuplicateProfiles : preventDuplicateProfiles // ignore: cast_nullable_to_non_nullable
as bool,autoCheckActiveServices: null == autoCheckActiveServices ? _self.autoCheckActiveServices : autoCheckActiveServices // ignore: cast_nullable_to_non_nullable
as bool,autoCheckAllServices: null == autoCheckAllServices ? _self.autoCheckAllServices : autoCheckAllServices // ignore: cast_nullable_to_non_nullable
as bool,serviceCheckOnlyWhenConnected: null == serviceCheckOnlyWhenConnected ? _self.serviceCheckOnlyWhenConnected : serviceCheckOnlyWhenConnected // ignore: cast_nullable_to_non_nullable
as bool,serviceOrder: null == serviceOrder ? _self.serviceOrder : serviceOrder // ignore: cast_nullable_to_non_nullable
as List<String>,enabledServices: null == enabledServices ? _self.enabledServices : enabledServices // ignore: cast_nullable_to_non_nullable
as List<String>,disabledServices: null == disabledServices ? _self.disabledServices : disabledServices // ignore: cast_nullable_to_non_nullable
as List<String>,tableColumnWidths: null == tableColumnWidths ? _self.tableColumnWidths : tableColumnWidths // ignore: cast_nullable_to_non_nullable
as Map<String, Map<String, double>>,webDashboardFlavor: null == webDashboardFlavor ? _self.webDashboardFlavor : webDashboardFlavor // ignore: cast_nullable_to_non_nullable
as WebDashboardFlavor,speedTest: null == speedTest ? _self.speedTest : speedTest // ignore: cast_nullable_to_non_nullable
as SpeedTestSettings,
  ));
}
/// Create a copy of AppSettingProps
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NotificationSettingsCopyWith<$Res> get notificationSettings {
  
  return $NotificationSettingsCopyWith<$Res>(_self.notificationSettings, (value) {
    return _then(_self.copyWith(notificationSettings: value));
  });
}
}


/// Adds pattern-matching-related methods to [AppSettingProps].
extension AppSettingPropsPatterns on AppSettingProps {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppSettingProps value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppSettingProps() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppSettingProps value)  $default,){
final _that = this;
switch (_that) {
case _AppSettingProps():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppSettingProps value)?  $default,){
final _that = this;
switch (_that) {
case _AppSettingProps() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? locale, @JsonKey(fromJson: sanitizeRegionCode)  String? regionCode, @JsonKey(fromJson: dashboardWidgetsFromJson)  List<DashboardWidget> dashboardWidgets, @JsonKey(unknownEnumValue: DashboardStyle.detailed)  DashboardStyle dashboardStyle, @JsonKey(fromJson: simpleDashboardWidgetsFromJson)  List<SimpleDashboardWidget> simpleDashboardWidgets,  bool onlyStatisticsProxy, @JsonKey(readValue: readNotificationSettings, fromJson: NotificationSettings.safeFromJson)  NotificationSettings notificationSettings,  bool autoLaunch,  bool silentLaunch,  bool autoRun,  bool openLogs,  bool closeConnections,  int delayTestTimeout, @JsonKey(readValue: _readTabAnimation)  TabAnimation tabAnimation,  bool floatingNavigationBar, @JsonKey(unknownEnumValue: NavigationLayout.auto)  NavigationLayout navigationLayout,  bool? sidebarNarrow, @JsonKey(unknownEnumValue: NavigationLabels.always)  NavigationLabels navigationLabels, @JsonKey(unknownEnumValue: AppIcon.standard)  AppIcon appIcon, @JsonKey(unknownEnumValue: TrayIconStyle.color)  TrayIconStyle trayIconStyle,  bool autoCheckUpdate,  bool autoDownloadUpdate,  bool autoInstallUpdate, @JsonKey(fromJson: updateChannelFromJson)  UpdateChannel? updateChannel, @JsonKey(readValue: _readSidebarExpanded)  bool sidebarExpanded,  int acceptedDisclaimerVersion,  bool? setupCompleted,  int setupStep,  int? setupProfileId,  String? setupCoverage,  String? setupRegionCode,  bool setupRegionChosen,  bool setupDirectRoutes,  bool minimizeOnExit,  bool hidden,  bool developerMode,  RestoreStrategy restoreStrategy,  bool showTrayTitle,  bool monochromeTrayIcon,  bool checkCertificate, @JsonKey(readValue: _readUserAgents)  List<String> userAgents,  List<Filter> filters,  bool hideIp,  bool editorLineWrap,  EditorFontSize editorFontSize,  bool preventDuplicateProfiles,  bool autoCheckActiveServices,  bool autoCheckAllServices,  bool serviceCheckOnlyWhenConnected,  List<String> serviceOrder,  List<String> enabledServices,  List<String> disabledServices,  Map<String, Map<String, double>> tableColumnWidths, @JsonKey(unknownEnumValue: WebDashboardFlavor.zashboard)  WebDashboardFlavor webDashboardFlavor, @JsonKey(fromJson: SpeedTestSettings.safeFromJson)  SpeedTestSettings speedTest)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppSettingProps() when $default != null:
return $default(_that.locale,_that.regionCode,_that.dashboardWidgets,_that.dashboardStyle,_that.simpleDashboardWidgets,_that.onlyStatisticsProxy,_that.notificationSettings,_that.autoLaunch,_that.silentLaunch,_that.autoRun,_that.openLogs,_that.closeConnections,_that.delayTestTimeout,_that.tabAnimation,_that.floatingNavigationBar,_that.navigationLayout,_that.sidebarNarrow,_that.navigationLabels,_that.appIcon,_that.trayIconStyle,_that.autoCheckUpdate,_that.autoDownloadUpdate,_that.autoInstallUpdate,_that.updateChannel,_that.sidebarExpanded,_that.acceptedDisclaimerVersion,_that.setupCompleted,_that.setupStep,_that.setupProfileId,_that.setupCoverage,_that.setupRegionCode,_that.setupRegionChosen,_that.setupDirectRoutes,_that.minimizeOnExit,_that.hidden,_that.developerMode,_that.restoreStrategy,_that.showTrayTitle,_that.monochromeTrayIcon,_that.checkCertificate,_that.userAgents,_that.filters,_that.hideIp,_that.editorLineWrap,_that.editorFontSize,_that.preventDuplicateProfiles,_that.autoCheckActiveServices,_that.autoCheckAllServices,_that.serviceCheckOnlyWhenConnected,_that.serviceOrder,_that.enabledServices,_that.disabledServices,_that.tableColumnWidths,_that.webDashboardFlavor,_that.speedTest);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? locale, @JsonKey(fromJson: sanitizeRegionCode)  String? regionCode, @JsonKey(fromJson: dashboardWidgetsFromJson)  List<DashboardWidget> dashboardWidgets, @JsonKey(unknownEnumValue: DashboardStyle.detailed)  DashboardStyle dashboardStyle, @JsonKey(fromJson: simpleDashboardWidgetsFromJson)  List<SimpleDashboardWidget> simpleDashboardWidgets,  bool onlyStatisticsProxy, @JsonKey(readValue: readNotificationSettings, fromJson: NotificationSettings.safeFromJson)  NotificationSettings notificationSettings,  bool autoLaunch,  bool silentLaunch,  bool autoRun,  bool openLogs,  bool closeConnections,  int delayTestTimeout, @JsonKey(readValue: _readTabAnimation)  TabAnimation tabAnimation,  bool floatingNavigationBar, @JsonKey(unknownEnumValue: NavigationLayout.auto)  NavigationLayout navigationLayout,  bool? sidebarNarrow, @JsonKey(unknownEnumValue: NavigationLabels.always)  NavigationLabels navigationLabels, @JsonKey(unknownEnumValue: AppIcon.standard)  AppIcon appIcon, @JsonKey(unknownEnumValue: TrayIconStyle.color)  TrayIconStyle trayIconStyle,  bool autoCheckUpdate,  bool autoDownloadUpdate,  bool autoInstallUpdate, @JsonKey(fromJson: updateChannelFromJson)  UpdateChannel? updateChannel, @JsonKey(readValue: _readSidebarExpanded)  bool sidebarExpanded,  int acceptedDisclaimerVersion,  bool? setupCompleted,  int setupStep,  int? setupProfileId,  String? setupCoverage,  String? setupRegionCode,  bool setupRegionChosen,  bool setupDirectRoutes,  bool minimizeOnExit,  bool hidden,  bool developerMode,  RestoreStrategy restoreStrategy,  bool showTrayTitle,  bool monochromeTrayIcon,  bool checkCertificate, @JsonKey(readValue: _readUserAgents)  List<String> userAgents,  List<Filter> filters,  bool hideIp,  bool editorLineWrap,  EditorFontSize editorFontSize,  bool preventDuplicateProfiles,  bool autoCheckActiveServices,  bool autoCheckAllServices,  bool serviceCheckOnlyWhenConnected,  List<String> serviceOrder,  List<String> enabledServices,  List<String> disabledServices,  Map<String, Map<String, double>> tableColumnWidths, @JsonKey(unknownEnumValue: WebDashboardFlavor.zashboard)  WebDashboardFlavor webDashboardFlavor, @JsonKey(fromJson: SpeedTestSettings.safeFromJson)  SpeedTestSettings speedTest)  $default,) {final _that = this;
switch (_that) {
case _AppSettingProps():
return $default(_that.locale,_that.regionCode,_that.dashboardWidgets,_that.dashboardStyle,_that.simpleDashboardWidgets,_that.onlyStatisticsProxy,_that.notificationSettings,_that.autoLaunch,_that.silentLaunch,_that.autoRun,_that.openLogs,_that.closeConnections,_that.delayTestTimeout,_that.tabAnimation,_that.floatingNavigationBar,_that.navigationLayout,_that.sidebarNarrow,_that.navigationLabels,_that.appIcon,_that.trayIconStyle,_that.autoCheckUpdate,_that.autoDownloadUpdate,_that.autoInstallUpdate,_that.updateChannel,_that.sidebarExpanded,_that.acceptedDisclaimerVersion,_that.setupCompleted,_that.setupStep,_that.setupProfileId,_that.setupCoverage,_that.setupRegionCode,_that.setupRegionChosen,_that.setupDirectRoutes,_that.minimizeOnExit,_that.hidden,_that.developerMode,_that.restoreStrategy,_that.showTrayTitle,_that.monochromeTrayIcon,_that.checkCertificate,_that.userAgents,_that.filters,_that.hideIp,_that.editorLineWrap,_that.editorFontSize,_that.preventDuplicateProfiles,_that.autoCheckActiveServices,_that.autoCheckAllServices,_that.serviceCheckOnlyWhenConnected,_that.serviceOrder,_that.enabledServices,_that.disabledServices,_that.tableColumnWidths,_that.webDashboardFlavor,_that.speedTest);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? locale, @JsonKey(fromJson: sanitizeRegionCode)  String? regionCode, @JsonKey(fromJson: dashboardWidgetsFromJson)  List<DashboardWidget> dashboardWidgets, @JsonKey(unknownEnumValue: DashboardStyle.detailed)  DashboardStyle dashboardStyle, @JsonKey(fromJson: simpleDashboardWidgetsFromJson)  List<SimpleDashboardWidget> simpleDashboardWidgets,  bool onlyStatisticsProxy, @JsonKey(readValue: readNotificationSettings, fromJson: NotificationSettings.safeFromJson)  NotificationSettings notificationSettings,  bool autoLaunch,  bool silentLaunch,  bool autoRun,  bool openLogs,  bool closeConnections,  int delayTestTimeout, @JsonKey(readValue: _readTabAnimation)  TabAnimation tabAnimation,  bool floatingNavigationBar, @JsonKey(unknownEnumValue: NavigationLayout.auto)  NavigationLayout navigationLayout,  bool? sidebarNarrow, @JsonKey(unknownEnumValue: NavigationLabels.always)  NavigationLabels navigationLabels, @JsonKey(unknownEnumValue: AppIcon.standard)  AppIcon appIcon, @JsonKey(unknownEnumValue: TrayIconStyle.color)  TrayIconStyle trayIconStyle,  bool autoCheckUpdate,  bool autoDownloadUpdate,  bool autoInstallUpdate, @JsonKey(fromJson: updateChannelFromJson)  UpdateChannel? updateChannel, @JsonKey(readValue: _readSidebarExpanded)  bool sidebarExpanded,  int acceptedDisclaimerVersion,  bool? setupCompleted,  int setupStep,  int? setupProfileId,  String? setupCoverage,  String? setupRegionCode,  bool setupRegionChosen,  bool setupDirectRoutes,  bool minimizeOnExit,  bool hidden,  bool developerMode,  RestoreStrategy restoreStrategy,  bool showTrayTitle,  bool monochromeTrayIcon,  bool checkCertificate, @JsonKey(readValue: _readUserAgents)  List<String> userAgents,  List<Filter> filters,  bool hideIp,  bool editorLineWrap,  EditorFontSize editorFontSize,  bool preventDuplicateProfiles,  bool autoCheckActiveServices,  bool autoCheckAllServices,  bool serviceCheckOnlyWhenConnected,  List<String> serviceOrder,  List<String> enabledServices,  List<String> disabledServices,  Map<String, Map<String, double>> tableColumnWidths, @JsonKey(unknownEnumValue: WebDashboardFlavor.zashboard)  WebDashboardFlavor webDashboardFlavor, @JsonKey(fromJson: SpeedTestSettings.safeFromJson)  SpeedTestSettings speedTest)?  $default,) {final _that = this;
switch (_that) {
case _AppSettingProps() when $default != null:
return $default(_that.locale,_that.regionCode,_that.dashboardWidgets,_that.dashboardStyle,_that.simpleDashboardWidgets,_that.onlyStatisticsProxy,_that.notificationSettings,_that.autoLaunch,_that.silentLaunch,_that.autoRun,_that.openLogs,_that.closeConnections,_that.delayTestTimeout,_that.tabAnimation,_that.floatingNavigationBar,_that.navigationLayout,_that.sidebarNarrow,_that.navigationLabels,_that.appIcon,_that.trayIconStyle,_that.autoCheckUpdate,_that.autoDownloadUpdate,_that.autoInstallUpdate,_that.updateChannel,_that.sidebarExpanded,_that.acceptedDisclaimerVersion,_that.setupCompleted,_that.setupStep,_that.setupProfileId,_that.setupCoverage,_that.setupRegionCode,_that.setupRegionChosen,_that.setupDirectRoutes,_that.minimizeOnExit,_that.hidden,_that.developerMode,_that.restoreStrategy,_that.showTrayTitle,_that.monochromeTrayIcon,_that.checkCertificate,_that.userAgents,_that.filters,_that.hideIp,_that.editorLineWrap,_that.editorFontSize,_that.preventDuplicateProfiles,_that.autoCheckActiveServices,_that.autoCheckAllServices,_that.serviceCheckOnlyWhenConnected,_that.serviceOrder,_that.enabledServices,_that.disabledServices,_that.tableColumnWidths,_that.webDashboardFlavor,_that.speedTest);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppSettingProps implements AppSettingProps {
  const _AppSettingProps({this.locale, @JsonKey(fromJson: sanitizeRegionCode) this.regionCode, @JsonKey(fromJson: dashboardWidgetsFromJson)  List<DashboardWidget> dashboardWidgets = defaultDashboardWidgets, @JsonKey(unknownEnumValue: DashboardStyle.detailed) this.dashboardStyle = DashboardStyle.detailed, @JsonKey(fromJson: simpleDashboardWidgetsFromJson)  List<SimpleDashboardWidget> simpleDashboardWidgets = defaultSimpleDashboardWidgets, this.onlyStatisticsProxy = false, @JsonKey(readValue: readNotificationSettings, fromJson: NotificationSettings.safeFromJson) this.notificationSettings = const NotificationSettings(), this.autoLaunch = false, this.silentLaunch = false, this.autoRun = false, this.openLogs = false, this.closeConnections = true, this.delayTestTimeout = defaultDelayTestTimeout, @JsonKey(readValue: _readTabAnimation) this.tabAnimation = TabAnimation.fade, this.floatingNavigationBar = true, @JsonKey(unknownEnumValue: NavigationLayout.auto) this.navigationLayout = NavigationLayout.auto, this.sidebarNarrow, @JsonKey(unknownEnumValue: NavigationLabels.always) this.navigationLabels = NavigationLabels.always, @JsonKey(unknownEnumValue: AppIcon.standard) this.appIcon = AppIcon.standard, @JsonKey(unknownEnumValue: TrayIconStyle.color) this.trayIconStyle = TrayIconStyle.color, this.autoCheckUpdate = true, this.autoDownloadUpdate = false, this.autoInstallUpdate = false, @JsonKey(fromJson: updateChannelFromJson) this.updateChannel, @JsonKey(readValue: _readSidebarExpanded) this.sidebarExpanded = false, this.acceptedDisclaimerVersion = 0, this.setupCompleted, this.setupStep = 0, this.setupProfileId, this.setupCoverage, this.setupRegionCode, this.setupRegionChosen = false, this.setupDirectRoutes = true, this.minimizeOnExit = true, this.hidden = false, this.developerMode = false, this.restoreStrategy = RestoreStrategy.compatible, this.showTrayTitle = true, this.monochromeTrayIcon = true, this.checkCertificate = true, @JsonKey(readValue: _readUserAgents)  List<String> userAgents = defaultUserAgents,  List<Filter> filters = defaultFilters, this.hideIp = false, this.editorLineWrap = false, this.editorFontSize = EditorFontSize.standard, this.preventDuplicateProfiles = true, this.autoCheckActiveServices = true, this.autoCheckAllServices = false, this.serviceCheckOnlyWhenConnected = true,  List<String> serviceOrder = const [],  List<String> enabledServices = const [],  List<String> disabledServices = const [],  Map<String, Map<String, double>> tableColumnWidths = const {}, @JsonKey(unknownEnumValue: WebDashboardFlavor.zashboard) this.webDashboardFlavor = WebDashboardFlavor.zashboard, @JsonKey(fromJson: SpeedTestSettings.safeFromJson) this.speedTest = const SpeedTestSettings()}): _dashboardWidgets = dashboardWidgets,_simpleDashboardWidgets = simpleDashboardWidgets,_userAgents = userAgents,_filters = filters,_serviceOrder = serviceOrder,_enabledServices = enabledServices,_disabledServices = disabledServices,_tableColumnWidths = tableColumnWidths;
  factory _AppSettingProps.fromJson(Map<String, dynamic> json) => _$AppSettingPropsFromJson(json);

@override final  String? locale;
@override@JsonKey(fromJson: sanitizeRegionCode) final  String? regionCode;
 final  List<DashboardWidget> _dashboardWidgets;
@override@JsonKey(fromJson: dashboardWidgetsFromJson) List<DashboardWidget> get dashboardWidgets {
  if (_dashboardWidgets is EqualUnmodifiableListView) return _dashboardWidgets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dashboardWidgets);
}

@override@JsonKey(unknownEnumValue: DashboardStyle.detailed) final  DashboardStyle dashboardStyle;
 final  List<SimpleDashboardWidget> _simpleDashboardWidgets;
@override@JsonKey(fromJson: simpleDashboardWidgetsFromJson) List<SimpleDashboardWidget> get simpleDashboardWidgets {
  if (_simpleDashboardWidgets is EqualUnmodifiableListView) return _simpleDashboardWidgets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_simpleDashboardWidgets);
}

@override@JsonKey() final  bool onlyStatisticsProxy;
@override@JsonKey(readValue: readNotificationSettings, fromJson: NotificationSettings.safeFromJson) final  NotificationSettings notificationSettings;
@override@JsonKey() final  bool autoLaunch;
@override@JsonKey() final  bool silentLaunch;
@override@JsonKey() final  bool autoRun;
@override@JsonKey() final  bool openLogs;
@override@JsonKey() final  bool closeConnections;
@override@JsonKey() final  int delayTestTimeout;
@override@JsonKey(readValue: _readTabAnimation) final  TabAnimation tabAnimation;
@override@JsonKey() final  bool floatingNavigationBar;
@override@JsonKey(unknownEnumValue: NavigationLayout.auto) final  NavigationLayout navigationLayout;
@override final  bool? sidebarNarrow;
@override@JsonKey(unknownEnumValue: NavigationLabels.always) final  NavigationLabels navigationLabels;
@override@JsonKey(unknownEnumValue: AppIcon.standard) final  AppIcon appIcon;
@override@JsonKey(unknownEnumValue: TrayIconStyle.color) final  TrayIconStyle trayIconStyle;
@override@JsonKey() final  bool autoCheckUpdate;
@override@JsonKey() final  bool autoDownloadUpdate;
@override@JsonKey() final  bool autoInstallUpdate;
@override@JsonKey(fromJson: updateChannelFromJson) final  UpdateChannel? updateChannel;
@override@JsonKey(readValue: _readSidebarExpanded) final  bool sidebarExpanded;
@override@JsonKey() final  int acceptedDisclaimerVersion;
@override final  bool? setupCompleted;
@override@JsonKey() final  int setupStep;
@override final  int? setupProfileId;
@override final  String? setupCoverage;
@override final  String? setupRegionCode;
@override@JsonKey() final  bool setupRegionChosen;
@override@JsonKey() final  bool setupDirectRoutes;
@override@JsonKey() final  bool minimizeOnExit;
@override@JsonKey() final  bool hidden;
@override@JsonKey() final  bool developerMode;
@override@JsonKey() final  RestoreStrategy restoreStrategy;
@override@JsonKey() final  bool showTrayTitle;
@override@JsonKey() final  bool monochromeTrayIcon;
@override@JsonKey() final  bool checkCertificate;
 final  List<String> _userAgents;
@override@JsonKey(readValue: _readUserAgents) List<String> get userAgents {
  if (_userAgents is EqualUnmodifiableListView) return _userAgents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_userAgents);
}

 final  List<Filter> _filters;
@override@JsonKey() List<Filter> get filters {
  if (_filters is EqualUnmodifiableListView) return _filters;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_filters);
}

@override@JsonKey() final  bool hideIp;
@override@JsonKey() final  bool editorLineWrap;
@override@JsonKey() final  EditorFontSize editorFontSize;
@override@JsonKey() final  bool preventDuplicateProfiles;
@override@JsonKey() final  bool autoCheckActiveServices;
@override@JsonKey() final  bool autoCheckAllServices;
@override@JsonKey() final  bool serviceCheckOnlyWhenConnected;
 final  List<String> _serviceOrder;
@override@JsonKey() List<String> get serviceOrder {
  if (_serviceOrder is EqualUnmodifiableListView) return _serviceOrder;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_serviceOrder);
}

 final  List<String> _enabledServices;
@override@JsonKey() List<String> get enabledServices {
  if (_enabledServices is EqualUnmodifiableListView) return _enabledServices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_enabledServices);
}

 final  List<String> _disabledServices;
@override@JsonKey() List<String> get disabledServices {
  if (_disabledServices is EqualUnmodifiableListView) return _disabledServices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_disabledServices);
}

 final  Map<String, Map<String, double>> _tableColumnWidths;
@override@JsonKey() Map<String, Map<String, double>> get tableColumnWidths {
  if (_tableColumnWidths is EqualUnmodifiableMapView) return _tableColumnWidths;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_tableColumnWidths);
}

@override@JsonKey(unknownEnumValue: WebDashboardFlavor.zashboard) final  WebDashboardFlavor webDashboardFlavor;
@override@JsonKey(fromJson: SpeedTestSettings.safeFromJson) final  SpeedTestSettings speedTest;

/// Create a copy of AppSettingProps
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppSettingPropsCopyWith<_AppSettingProps> get copyWith => __$AppSettingPropsCopyWithImpl<_AppSettingProps>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppSettingPropsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppSettingProps&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.regionCode, regionCode) || other.regionCode == regionCode)&&const DeepCollectionEquality().equals(other.dashboardWidgets, _dashboardWidgets)&&(identical(other.dashboardStyle, dashboardStyle) || other.dashboardStyle == dashboardStyle)&&const DeepCollectionEquality().equals(other.simpleDashboardWidgets, _simpleDashboardWidgets)&&(identical(other.onlyStatisticsProxy, onlyStatisticsProxy) || other.onlyStatisticsProxy == onlyStatisticsProxy)&&(identical(other.notificationSettings, notificationSettings) || other.notificationSettings == notificationSettings)&&(identical(other.autoLaunch, autoLaunch) || other.autoLaunch == autoLaunch)&&(identical(other.silentLaunch, silentLaunch) || other.silentLaunch == silentLaunch)&&(identical(other.autoRun, autoRun) || other.autoRun == autoRun)&&(identical(other.openLogs, openLogs) || other.openLogs == openLogs)&&(identical(other.closeConnections, closeConnections) || other.closeConnections == closeConnections)&&(identical(other.delayTestTimeout, delayTestTimeout) || other.delayTestTimeout == delayTestTimeout)&&(identical(other.tabAnimation, tabAnimation) || other.tabAnimation == tabAnimation)&&(identical(other.floatingNavigationBar, floatingNavigationBar) || other.floatingNavigationBar == floatingNavigationBar)&&(identical(other.navigationLayout, navigationLayout) || other.navigationLayout == navigationLayout)&&(identical(other.sidebarNarrow, sidebarNarrow) || other.sidebarNarrow == sidebarNarrow)&&(identical(other.navigationLabels, navigationLabels) || other.navigationLabels == navigationLabels)&&(identical(other.appIcon, appIcon) || other.appIcon == appIcon)&&(identical(other.trayIconStyle, trayIconStyle) || other.trayIconStyle == trayIconStyle)&&(identical(other.autoCheckUpdate, autoCheckUpdate) || other.autoCheckUpdate == autoCheckUpdate)&&(identical(other.autoDownloadUpdate, autoDownloadUpdate) || other.autoDownloadUpdate == autoDownloadUpdate)&&(identical(other.autoInstallUpdate, autoInstallUpdate) || other.autoInstallUpdate == autoInstallUpdate)&&(identical(other.updateChannel, updateChannel) || other.updateChannel == updateChannel)&&(identical(other.sidebarExpanded, sidebarExpanded) || other.sidebarExpanded == sidebarExpanded)&&(identical(other.acceptedDisclaimerVersion, acceptedDisclaimerVersion) || other.acceptedDisclaimerVersion == acceptedDisclaimerVersion)&&(identical(other.setupCompleted, setupCompleted) || other.setupCompleted == setupCompleted)&&(identical(other.setupStep, setupStep) || other.setupStep == setupStep)&&(identical(other.setupProfileId, setupProfileId) || other.setupProfileId == setupProfileId)&&(identical(other.setupCoverage, setupCoverage) || other.setupCoverage == setupCoverage)&&(identical(other.setupRegionCode, setupRegionCode) || other.setupRegionCode == setupRegionCode)&&(identical(other.setupRegionChosen, setupRegionChosen) || other.setupRegionChosen == setupRegionChosen)&&(identical(other.setupDirectRoutes, setupDirectRoutes) || other.setupDirectRoutes == setupDirectRoutes)&&(identical(other.minimizeOnExit, minimizeOnExit) || other.minimizeOnExit == minimizeOnExit)&&(identical(other.hidden, hidden) || other.hidden == hidden)&&(identical(other.developerMode, developerMode) || other.developerMode == developerMode)&&(identical(other.restoreStrategy, restoreStrategy) || other.restoreStrategy == restoreStrategy)&&(identical(other.showTrayTitle, showTrayTitle) || other.showTrayTitle == showTrayTitle)&&(identical(other.monochromeTrayIcon, monochromeTrayIcon) || other.monochromeTrayIcon == monochromeTrayIcon)&&(identical(other.checkCertificate, checkCertificate) || other.checkCertificate == checkCertificate)&&const DeepCollectionEquality().equals(other.userAgents, _userAgents)&&const DeepCollectionEquality().equals(other.filters, _filters)&&(identical(other.hideIp, hideIp) || other.hideIp == hideIp)&&(identical(other.editorLineWrap, editorLineWrap) || other.editorLineWrap == editorLineWrap)&&(identical(other.editorFontSize, editorFontSize) || other.editorFontSize == editorFontSize)&&(identical(other.preventDuplicateProfiles, preventDuplicateProfiles) || other.preventDuplicateProfiles == preventDuplicateProfiles)&&(identical(other.autoCheckActiveServices, autoCheckActiveServices) || other.autoCheckActiveServices == autoCheckActiveServices)&&(identical(other.autoCheckAllServices, autoCheckAllServices) || other.autoCheckAllServices == autoCheckAllServices)&&(identical(other.serviceCheckOnlyWhenConnected, serviceCheckOnlyWhenConnected) || other.serviceCheckOnlyWhenConnected == serviceCheckOnlyWhenConnected)&&const DeepCollectionEquality().equals(other.serviceOrder, _serviceOrder)&&const DeepCollectionEquality().equals(other.enabledServices, _enabledServices)&&const DeepCollectionEquality().equals(other.disabledServices, _disabledServices)&&const DeepCollectionEquality().equals(other.tableColumnWidths, _tableColumnWidths)&&(identical(other.webDashboardFlavor, webDashboardFlavor) || other.webDashboardFlavor == webDashboardFlavor)&&(identical(other.speedTest, speedTest) || other.speedTest == speedTest));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,locale,regionCode,const DeepCollectionEquality().hash(_dashboardWidgets),dashboardStyle,const DeepCollectionEquality().hash(_simpleDashboardWidgets),onlyStatisticsProxy,notificationSettings,autoLaunch,silentLaunch,autoRun,openLogs,closeConnections,delayTestTimeout,tabAnimation,floatingNavigationBar,navigationLayout,sidebarNarrow,navigationLabels,appIcon,trayIconStyle,autoCheckUpdate,autoDownloadUpdate,autoInstallUpdate,updateChannel,sidebarExpanded,acceptedDisclaimerVersion,setupCompleted,setupStep,setupProfileId,setupCoverage,setupRegionCode,setupRegionChosen,setupDirectRoutes,minimizeOnExit,hidden,developerMode,restoreStrategy,showTrayTitle,monochromeTrayIcon,checkCertificate,const DeepCollectionEquality().hash(_userAgents),const DeepCollectionEquality().hash(_filters),hideIp,editorLineWrap,editorFontSize,preventDuplicateProfiles,autoCheckActiveServices,autoCheckAllServices,serviceCheckOnlyWhenConnected,const DeepCollectionEquality().hash(_serviceOrder),const DeepCollectionEquality().hash(_enabledServices),const DeepCollectionEquality().hash(_disabledServices),const DeepCollectionEquality().hash(_tableColumnWidths),webDashboardFlavor,speedTest]);
}

@override
String toString() {
    return 'AppSettingProps(locale: $locale, regionCode: $regionCode, dashboardWidgets: $dashboardWidgets, dashboardStyle: $dashboardStyle, simpleDashboardWidgets: $simpleDashboardWidgets, onlyStatisticsProxy: $onlyStatisticsProxy, notificationSettings: $notificationSettings, autoLaunch: $autoLaunch, silentLaunch: $silentLaunch, autoRun: $autoRun, openLogs: $openLogs, closeConnections: $closeConnections, delayTestTimeout: $delayTestTimeout, tabAnimation: $tabAnimation, floatingNavigationBar: $floatingNavigationBar, navigationLayout: $navigationLayout, sidebarNarrow: $sidebarNarrow, navigationLabels: $navigationLabels, appIcon: $appIcon, trayIconStyle: $trayIconStyle, autoCheckUpdate: $autoCheckUpdate, autoDownloadUpdate: $autoDownloadUpdate, autoInstallUpdate: $autoInstallUpdate, updateChannel: $updateChannel, sidebarExpanded: $sidebarExpanded, acceptedDisclaimerVersion: $acceptedDisclaimerVersion, setupCompleted: $setupCompleted, setupStep: $setupStep, setupProfileId: $setupProfileId, setupCoverage: $setupCoverage, setupRegionCode: $setupRegionCode, setupRegionChosen: $setupRegionChosen, setupDirectRoutes: $setupDirectRoutes, minimizeOnExit: $minimizeOnExit, hidden: $hidden, developerMode: $developerMode, restoreStrategy: $restoreStrategy, showTrayTitle: $showTrayTitle, monochromeTrayIcon: $monochromeTrayIcon, checkCertificate: $checkCertificate, userAgents: $userAgents, filters: $filters, hideIp: $hideIp, editorLineWrap: $editorLineWrap, editorFontSize: $editorFontSize, preventDuplicateProfiles: $preventDuplicateProfiles, autoCheckActiveServices: $autoCheckActiveServices, autoCheckAllServices: $autoCheckAllServices, serviceCheckOnlyWhenConnected: $serviceCheckOnlyWhenConnected, serviceOrder: $serviceOrder, enabledServices: $enabledServices, disabledServices: $disabledServices, tableColumnWidths: $tableColumnWidths, webDashboardFlavor: $webDashboardFlavor, speedTest: $speedTest)';
}


}

/// @nodoc
abstract mixin class _$AppSettingPropsCopyWith<$Res> implements $AppSettingPropsCopyWith<$Res> {
  factory _$AppSettingPropsCopyWith(_AppSettingProps value, $Res Function(_AppSettingProps) _then) = __$AppSettingPropsCopyWithImpl;
@override @useResult
$Res call({
 String? locale,@JsonKey(fromJson: sanitizeRegionCode) String? regionCode,@JsonKey(fromJson: dashboardWidgetsFromJson) List<DashboardWidget> dashboardWidgets,@JsonKey(unknownEnumValue: DashboardStyle.detailed) DashboardStyle dashboardStyle,@JsonKey(fromJson: simpleDashboardWidgetsFromJson) List<SimpleDashboardWidget> simpleDashboardWidgets, bool onlyStatisticsProxy,@JsonKey(readValue: readNotificationSettings, fromJson: NotificationSettings.safeFromJson) NotificationSettings notificationSettings, bool autoLaunch, bool silentLaunch, bool autoRun, bool openLogs, bool closeConnections, int delayTestTimeout,@JsonKey(readValue: _readTabAnimation) TabAnimation tabAnimation, bool floatingNavigationBar,@JsonKey(unknownEnumValue: NavigationLayout.auto) NavigationLayout navigationLayout, bool? sidebarNarrow,@JsonKey(unknownEnumValue: NavigationLabels.always) NavigationLabels navigationLabels,@JsonKey(unknownEnumValue: AppIcon.standard) AppIcon appIcon,@JsonKey(unknownEnumValue: TrayIconStyle.color) TrayIconStyle trayIconStyle, bool autoCheckUpdate, bool autoDownloadUpdate, bool autoInstallUpdate,@JsonKey(fromJson: updateChannelFromJson) UpdateChannel? updateChannel,@JsonKey(readValue: _readSidebarExpanded) bool sidebarExpanded, int acceptedDisclaimerVersion, bool? setupCompleted, int setupStep, int? setupProfileId, String? setupCoverage, String? setupRegionCode, bool setupRegionChosen, bool setupDirectRoutes, bool minimizeOnExit, bool hidden, bool developerMode, RestoreStrategy restoreStrategy, bool showTrayTitle, bool monochromeTrayIcon, bool checkCertificate,@JsonKey(readValue: _readUserAgents) List<String> userAgents, List<Filter> filters, bool hideIp, bool editorLineWrap, EditorFontSize editorFontSize, bool preventDuplicateProfiles, bool autoCheckActiveServices, bool autoCheckAllServices, bool serviceCheckOnlyWhenConnected, List<String> serviceOrder, List<String> enabledServices, List<String> disabledServices, Map<String, Map<String, double>> tableColumnWidths,@JsonKey(unknownEnumValue: WebDashboardFlavor.zashboard) WebDashboardFlavor webDashboardFlavor,@JsonKey(fromJson: SpeedTestSettings.safeFromJson) SpeedTestSettings speedTest
});


@override $NotificationSettingsCopyWith<$Res> get notificationSettings;

}
/// @nodoc
class __$AppSettingPropsCopyWithImpl<$Res>
    implements _$AppSettingPropsCopyWith<$Res> {
  __$AppSettingPropsCopyWithImpl(this._self, this._then);

  final _AppSettingProps _self;
  final $Res Function(_AppSettingProps) _then;

/// Create a copy of AppSettingProps
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? locale = freezed,Object? regionCode = freezed,Object? dashboardWidgets = null,Object? dashboardStyle = null,Object? simpleDashboardWidgets = null,Object? onlyStatisticsProxy = null,Object? notificationSettings = null,Object? autoLaunch = null,Object? silentLaunch = null,Object? autoRun = null,Object? openLogs = null,Object? closeConnections = null,Object? delayTestTimeout = null,Object? tabAnimation = null,Object? floatingNavigationBar = null,Object? navigationLayout = null,Object? sidebarNarrow = freezed,Object? navigationLabels = null,Object? appIcon = null,Object? trayIconStyle = null,Object? autoCheckUpdate = null,Object? autoDownloadUpdate = null,Object? autoInstallUpdate = null,Object? updateChannel = freezed,Object? sidebarExpanded = null,Object? acceptedDisclaimerVersion = null,Object? setupCompleted = freezed,Object? setupStep = null,Object? setupProfileId = freezed,Object? setupCoverage = freezed,Object? setupRegionCode = freezed,Object? setupRegionChosen = null,Object? setupDirectRoutes = null,Object? minimizeOnExit = null,Object? hidden = null,Object? developerMode = null,Object? restoreStrategy = null,Object? showTrayTitle = null,Object? monochromeTrayIcon = null,Object? checkCertificate = null,Object? userAgents = null,Object? filters = null,Object? hideIp = null,Object? editorLineWrap = null,Object? editorFontSize = null,Object? preventDuplicateProfiles = null,Object? autoCheckActiveServices = null,Object? autoCheckAllServices = null,Object? serviceCheckOnlyWhenConnected = null,Object? serviceOrder = null,Object? enabledServices = null,Object? disabledServices = null,Object? tableColumnWidths = null,Object? webDashboardFlavor = null,Object? speedTest = null,}) {
  return _then(_AppSettingProps(
locale: freezed == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String?,regionCode: freezed == regionCode ? _self.regionCode : regionCode // ignore: cast_nullable_to_non_nullable
as String?,dashboardWidgets: null == dashboardWidgets ? _self._dashboardWidgets : dashboardWidgets // ignore: cast_nullable_to_non_nullable
as List<DashboardWidget>,dashboardStyle: null == dashboardStyle ? _self.dashboardStyle : dashboardStyle // ignore: cast_nullable_to_non_nullable
as DashboardStyle,simpleDashboardWidgets: null == simpleDashboardWidgets ? _self._simpleDashboardWidgets : simpleDashboardWidgets // ignore: cast_nullable_to_non_nullable
as List<SimpleDashboardWidget>,onlyStatisticsProxy: null == onlyStatisticsProxy ? _self.onlyStatisticsProxy : onlyStatisticsProxy // ignore: cast_nullable_to_non_nullable
as bool,notificationSettings: null == notificationSettings ? _self.notificationSettings : notificationSettings // ignore: cast_nullable_to_non_nullable
as NotificationSettings,autoLaunch: null == autoLaunch ? _self.autoLaunch : autoLaunch // ignore: cast_nullable_to_non_nullable
as bool,silentLaunch: null == silentLaunch ? _self.silentLaunch : silentLaunch // ignore: cast_nullable_to_non_nullable
as bool,autoRun: null == autoRun ? _self.autoRun : autoRun // ignore: cast_nullable_to_non_nullable
as bool,openLogs: null == openLogs ? _self.openLogs : openLogs // ignore: cast_nullable_to_non_nullable
as bool,closeConnections: null == closeConnections ? _self.closeConnections : closeConnections // ignore: cast_nullable_to_non_nullable
as bool,delayTestTimeout: null == delayTestTimeout ? _self.delayTestTimeout : delayTestTimeout // ignore: cast_nullable_to_non_nullable
as int,tabAnimation: null == tabAnimation ? _self.tabAnimation : tabAnimation // ignore: cast_nullable_to_non_nullable
as TabAnimation,floatingNavigationBar: null == floatingNavigationBar ? _self.floatingNavigationBar : floatingNavigationBar // ignore: cast_nullable_to_non_nullable
as bool,navigationLayout: null == navigationLayout ? _self.navigationLayout : navigationLayout // ignore: cast_nullable_to_non_nullable
as NavigationLayout,sidebarNarrow: freezed == sidebarNarrow ? _self.sidebarNarrow : sidebarNarrow // ignore: cast_nullable_to_non_nullable
as bool?,navigationLabels: null == navigationLabels ? _self.navigationLabels : navigationLabels // ignore: cast_nullable_to_non_nullable
as NavigationLabels,appIcon: null == appIcon ? _self.appIcon : appIcon // ignore: cast_nullable_to_non_nullable
as AppIcon,trayIconStyle: null == trayIconStyle ? _self.trayIconStyle : trayIconStyle // ignore: cast_nullable_to_non_nullable
as TrayIconStyle,autoCheckUpdate: null == autoCheckUpdate ? _self.autoCheckUpdate : autoCheckUpdate // ignore: cast_nullable_to_non_nullable
as bool,autoDownloadUpdate: null == autoDownloadUpdate ? _self.autoDownloadUpdate : autoDownloadUpdate // ignore: cast_nullable_to_non_nullable
as bool,autoInstallUpdate: null == autoInstallUpdate ? _self.autoInstallUpdate : autoInstallUpdate // ignore: cast_nullable_to_non_nullable
as bool,updateChannel: freezed == updateChannel ? _self.updateChannel : updateChannel // ignore: cast_nullable_to_non_nullable
as UpdateChannel?,sidebarExpanded: null == sidebarExpanded ? _self.sidebarExpanded : sidebarExpanded // ignore: cast_nullable_to_non_nullable
as bool,acceptedDisclaimerVersion: null == acceptedDisclaimerVersion ? _self.acceptedDisclaimerVersion : acceptedDisclaimerVersion // ignore: cast_nullable_to_non_nullable
as int,setupCompleted: freezed == setupCompleted ? _self.setupCompleted : setupCompleted // ignore: cast_nullable_to_non_nullable
as bool?,setupStep: null == setupStep ? _self.setupStep : setupStep // ignore: cast_nullable_to_non_nullable
as int,setupProfileId: freezed == setupProfileId ? _self.setupProfileId : setupProfileId // ignore: cast_nullable_to_non_nullable
as int?,setupCoverage: freezed == setupCoverage ? _self.setupCoverage : setupCoverage // ignore: cast_nullable_to_non_nullable
as String?,setupRegionCode: freezed == setupRegionCode ? _self.setupRegionCode : setupRegionCode // ignore: cast_nullable_to_non_nullable
as String?,setupRegionChosen: null == setupRegionChosen ? _self.setupRegionChosen : setupRegionChosen // ignore: cast_nullable_to_non_nullable
as bool,setupDirectRoutes: null == setupDirectRoutes ? _self.setupDirectRoutes : setupDirectRoutes // ignore: cast_nullable_to_non_nullable
as bool,minimizeOnExit: null == minimizeOnExit ? _self.minimizeOnExit : minimizeOnExit // ignore: cast_nullable_to_non_nullable
as bool,hidden: null == hidden ? _self.hidden : hidden // ignore: cast_nullable_to_non_nullable
as bool,developerMode: null == developerMode ? _self.developerMode : developerMode // ignore: cast_nullable_to_non_nullable
as bool,restoreStrategy: null == restoreStrategy ? _self.restoreStrategy : restoreStrategy // ignore: cast_nullable_to_non_nullable
as RestoreStrategy,showTrayTitle: null == showTrayTitle ? _self.showTrayTitle : showTrayTitle // ignore: cast_nullable_to_non_nullable
as bool,monochromeTrayIcon: null == monochromeTrayIcon ? _self.monochromeTrayIcon : monochromeTrayIcon // ignore: cast_nullable_to_non_nullable
as bool,checkCertificate: null == checkCertificate ? _self.checkCertificate : checkCertificate // ignore: cast_nullable_to_non_nullable
as bool,userAgents: null == userAgents ? _self._userAgents : userAgents // ignore: cast_nullable_to_non_nullable
as List<String>,filters: null == filters ? _self._filters : filters // ignore: cast_nullable_to_non_nullable
as List<Filter>,hideIp: null == hideIp ? _self.hideIp : hideIp // ignore: cast_nullable_to_non_nullable
as bool,editorLineWrap: null == editorLineWrap ? _self.editorLineWrap : editorLineWrap // ignore: cast_nullable_to_non_nullable
as bool,editorFontSize: null == editorFontSize ? _self.editorFontSize : editorFontSize // ignore: cast_nullable_to_non_nullable
as EditorFontSize,preventDuplicateProfiles: null == preventDuplicateProfiles ? _self.preventDuplicateProfiles : preventDuplicateProfiles // ignore: cast_nullable_to_non_nullable
as bool,autoCheckActiveServices: null == autoCheckActiveServices ? _self.autoCheckActiveServices : autoCheckActiveServices // ignore: cast_nullable_to_non_nullable
as bool,autoCheckAllServices: null == autoCheckAllServices ? _self.autoCheckAllServices : autoCheckAllServices // ignore: cast_nullable_to_non_nullable
as bool,serviceCheckOnlyWhenConnected: null == serviceCheckOnlyWhenConnected ? _self.serviceCheckOnlyWhenConnected : serviceCheckOnlyWhenConnected // ignore: cast_nullable_to_non_nullable
as bool,serviceOrder: null == serviceOrder ? _self._serviceOrder : serviceOrder // ignore: cast_nullable_to_non_nullable
as List<String>,enabledServices: null == enabledServices ? _self._enabledServices : enabledServices // ignore: cast_nullable_to_non_nullable
as List<String>,disabledServices: null == disabledServices ? _self._disabledServices : disabledServices // ignore: cast_nullable_to_non_nullable
as List<String>,tableColumnWidths: null == tableColumnWidths ? _self._tableColumnWidths : tableColumnWidths // ignore: cast_nullable_to_non_nullable
as Map<String, Map<String, double>>,webDashboardFlavor: null == webDashboardFlavor ? _self.webDashboardFlavor : webDashboardFlavor // ignore: cast_nullable_to_non_nullable
as WebDashboardFlavor,speedTest: null == speedTest ? _self.speedTest : speedTest // ignore: cast_nullable_to_non_nullable
as SpeedTestSettings,
  ));
}

/// Create a copy of AppSettingProps
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NotificationSettingsCopyWith<$Res> get notificationSettings {
  
  return $NotificationSettingsCopyWith<$Res>(_self.notificationSettings, (value) {
    return _then(_self.copyWith(notificationSettings: value));
  });
}
}


/// @nodoc
mixin _$AccessControlProps {

 bool get enable; AccessControlMode get mode; List<String> get acceptList; List<String> get rejectList; AccessSortType get sort; bool get isFilterSystemApp; bool get isFilterNonInternetApp;/// Apps the subscription keeps out of the tunnel that the user put back.
 List<String> get rejectReleased;/// Apps the subscription routes through the tunnel that the user took out.
 List<String> get acceptReleased;
/// Create a copy of AccessControlProps
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccessControlPropsCopyWith<AccessControlProps> get copyWith => _$AccessControlPropsCopyWithImpl<AccessControlProps>(this as AccessControlProps, _$identity);

  /// Serializes this AccessControlProps to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AccessControlProps;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccessControlProps&&(identical(other.enable, _this.enable) || other.enable == _this.enable)&&(identical(other.mode, _this.mode) || other.mode == _this.mode)&&const DeepCollectionEquality().equals(other.acceptList, _this.acceptList)&&const DeepCollectionEquality().equals(other.rejectList, _this.rejectList)&&(identical(other.sort, _this.sort) || other.sort == _this.sort)&&(identical(other.isFilterSystemApp, _this.isFilterSystemApp) || other.isFilterSystemApp == _this.isFilterSystemApp)&&(identical(other.isFilterNonInternetApp, _this.isFilterNonInternetApp) || other.isFilterNonInternetApp == _this.isFilterNonInternetApp)&&const DeepCollectionEquality().equals(other.rejectReleased, _this.rejectReleased)&&const DeepCollectionEquality().equals(other.acceptReleased, _this.acceptReleased));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AccessControlProps;
  return Object.hash(runtimeType,_this.enable,_this.mode,const DeepCollectionEquality().hash(_this.acceptList),const DeepCollectionEquality().hash(_this.rejectList),_this.sort,_this.isFilterSystemApp,_this.isFilterNonInternetApp,const DeepCollectionEquality().hash(_this.rejectReleased),const DeepCollectionEquality().hash(_this.acceptReleased));
}

@override
String toString() {
  final _this = this as AccessControlProps;
  return 'AccessControlProps(enable: ${_this.enable}, mode: ${_this.mode}, acceptList: ${_this.acceptList}, rejectList: ${_this.rejectList}, sort: ${_this.sort}, isFilterSystemApp: ${_this.isFilterSystemApp}, isFilterNonInternetApp: ${_this.isFilterNonInternetApp}, rejectReleased: ${_this.rejectReleased}, acceptReleased: ${_this.acceptReleased})';
}


}

/// @nodoc
abstract mixin class $AccessControlPropsCopyWith<$Res>  {
  factory $AccessControlPropsCopyWith(AccessControlProps value, $Res Function(AccessControlProps) _then) = _$AccessControlPropsCopyWithImpl;
@useResult
$Res call({
 bool enable, AccessControlMode mode, List<String> acceptList, List<String> rejectList, AccessSortType sort, bool isFilterSystemApp, bool isFilterNonInternetApp, List<String> rejectReleased, List<String> acceptReleased
});




}
/// @nodoc
class _$AccessControlPropsCopyWithImpl<$Res>
    implements $AccessControlPropsCopyWith<$Res> {
  _$AccessControlPropsCopyWithImpl(this._self, this._then);

  final AccessControlProps _self;
  final $Res Function(AccessControlProps) _then;

/// Create a copy of AccessControlProps
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enable = null,Object? mode = null,Object? acceptList = null,Object? rejectList = null,Object? sort = null,Object? isFilterSystemApp = null,Object? isFilterNonInternetApp = null,Object? rejectReleased = null,Object? acceptReleased = null,}) {
  return _then(AccessControlProps(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as AccessControlMode,acceptList: null == acceptList ? _self.acceptList : acceptList // ignore: cast_nullable_to_non_nullable
as List<String>,rejectList: null == rejectList ? _self.rejectList : rejectList // ignore: cast_nullable_to_non_nullable
as List<String>,sort: null == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as AccessSortType,isFilterSystemApp: null == isFilterSystemApp ? _self.isFilterSystemApp : isFilterSystemApp // ignore: cast_nullable_to_non_nullable
as bool,isFilterNonInternetApp: null == isFilterNonInternetApp ? _self.isFilterNonInternetApp : isFilterNonInternetApp // ignore: cast_nullable_to_non_nullable
as bool,rejectReleased: null == rejectReleased ? _self.rejectReleased : rejectReleased // ignore: cast_nullable_to_non_nullable
as List<String>,acceptReleased: null == acceptReleased ? _self.acceptReleased : acceptReleased // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [AccessControlProps].
extension AccessControlPropsPatterns on AccessControlProps {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AccessControlProps value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AccessControlProps() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AccessControlProps value)  $default,){
final _that = this;
switch (_that) {
case _AccessControlProps():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AccessControlProps value)?  $default,){
final _that = this;
switch (_that) {
case _AccessControlProps() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enable,  AccessControlMode mode,  List<String> acceptList,  List<String> rejectList,  AccessSortType sort,  bool isFilterSystemApp,  bool isFilterNonInternetApp,  List<String> rejectReleased,  List<String> acceptReleased)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AccessControlProps() when $default != null:
return $default(_that.enable,_that.mode,_that.acceptList,_that.rejectList,_that.sort,_that.isFilterSystemApp,_that.isFilterNonInternetApp,_that.rejectReleased,_that.acceptReleased);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enable,  AccessControlMode mode,  List<String> acceptList,  List<String> rejectList,  AccessSortType sort,  bool isFilterSystemApp,  bool isFilterNonInternetApp,  List<String> rejectReleased,  List<String> acceptReleased)  $default,) {final _that = this;
switch (_that) {
case _AccessControlProps():
return $default(_that.enable,_that.mode,_that.acceptList,_that.rejectList,_that.sort,_that.isFilterSystemApp,_that.isFilterNonInternetApp,_that.rejectReleased,_that.acceptReleased);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enable,  AccessControlMode mode,  List<String> acceptList,  List<String> rejectList,  AccessSortType sort,  bool isFilterSystemApp,  bool isFilterNonInternetApp,  List<String> rejectReleased,  List<String> acceptReleased)?  $default,) {final _that = this;
switch (_that) {
case _AccessControlProps() when $default != null:
return $default(_that.enable,_that.mode,_that.acceptList,_that.rejectList,_that.sort,_that.isFilterSystemApp,_that.isFilterNonInternetApp,_that.rejectReleased,_that.acceptReleased);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AccessControlProps implements AccessControlProps {
  const _AccessControlProps({this.enable = false, this.mode = AccessControlMode.rejectSelected,  List<String> acceptList = const [],  List<String> rejectList = const [], this.sort = AccessSortType.none, this.isFilterSystemApp = true, this.isFilterNonInternetApp = true,  List<String> rejectReleased = const [],  List<String> acceptReleased = const []}): _acceptList = acceptList,_rejectList = rejectList,_rejectReleased = rejectReleased,_acceptReleased = acceptReleased;
  factory _AccessControlProps.fromJson(Map<String, dynamic> json) => _$AccessControlPropsFromJson(json);

@override@JsonKey() final  bool enable;
@override@JsonKey() final  AccessControlMode mode;
 final  List<String> _acceptList;
@override@JsonKey() List<String> get acceptList {
  if (_acceptList is EqualUnmodifiableListView) return _acceptList;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_acceptList);
}

 final  List<String> _rejectList;
@override@JsonKey() List<String> get rejectList {
  if (_rejectList is EqualUnmodifiableListView) return _rejectList;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rejectList);
}

@override@JsonKey() final  AccessSortType sort;
@override@JsonKey() final  bool isFilterSystemApp;
@override@JsonKey() final  bool isFilterNonInternetApp;
/// Apps the subscription keeps out of the tunnel that the user put back.
 final  List<String> _rejectReleased;
/// Apps the subscription keeps out of the tunnel that the user put back.
@override@JsonKey() List<String> get rejectReleased {
  if (_rejectReleased is EqualUnmodifiableListView) return _rejectReleased;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rejectReleased);
}

/// Apps the subscription routes through the tunnel that the user took out.
 final  List<String> _acceptReleased;
/// Apps the subscription routes through the tunnel that the user took out.
@override@JsonKey() List<String> get acceptReleased {
  if (_acceptReleased is EqualUnmodifiableListView) return _acceptReleased;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_acceptReleased);
}


/// Create a copy of AccessControlProps
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccessControlPropsCopyWith<_AccessControlProps> get copyWith => __$AccessControlPropsCopyWithImpl<_AccessControlProps>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AccessControlPropsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccessControlProps&&(identical(other.enable, enable) || other.enable == enable)&&(identical(other.mode, mode) || other.mode == mode)&&const DeepCollectionEquality().equals(other.acceptList, _acceptList)&&const DeepCollectionEquality().equals(other.rejectList, _rejectList)&&(identical(other.sort, sort) || other.sort == sort)&&(identical(other.isFilterSystemApp, isFilterSystemApp) || other.isFilterSystemApp == isFilterSystemApp)&&(identical(other.isFilterNonInternetApp, isFilterNonInternetApp) || other.isFilterNonInternetApp == isFilterNonInternetApp)&&const DeepCollectionEquality().equals(other.rejectReleased, _rejectReleased)&&const DeepCollectionEquality().equals(other.acceptReleased, _acceptReleased));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,enable,mode,const DeepCollectionEquality().hash(_acceptList),const DeepCollectionEquality().hash(_rejectList),sort,isFilterSystemApp,isFilterNonInternetApp,const DeepCollectionEquality().hash(_rejectReleased),const DeepCollectionEquality().hash(_acceptReleased));
}

@override
String toString() {
    return 'AccessControlProps(enable: $enable, mode: $mode, acceptList: $acceptList, rejectList: $rejectList, sort: $sort, isFilterSystemApp: $isFilterSystemApp, isFilterNonInternetApp: $isFilterNonInternetApp, rejectReleased: $rejectReleased, acceptReleased: $acceptReleased)';
}


}

/// @nodoc
abstract mixin class _$AccessControlPropsCopyWith<$Res> implements $AccessControlPropsCopyWith<$Res> {
  factory _$AccessControlPropsCopyWith(_AccessControlProps value, $Res Function(_AccessControlProps) _then) = __$AccessControlPropsCopyWithImpl;
@override @useResult
$Res call({
 bool enable, AccessControlMode mode, List<String> acceptList, List<String> rejectList, AccessSortType sort, bool isFilterSystemApp, bool isFilterNonInternetApp, List<String> rejectReleased, List<String> acceptReleased
});




}
/// @nodoc
class __$AccessControlPropsCopyWithImpl<$Res>
    implements _$AccessControlPropsCopyWith<$Res> {
  __$AccessControlPropsCopyWithImpl(this._self, this._then);

  final _AccessControlProps _self;
  final $Res Function(_AccessControlProps) _then;

/// Create a copy of AccessControlProps
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enable = null,Object? mode = null,Object? acceptList = null,Object? rejectList = null,Object? sort = null,Object? isFilterSystemApp = null,Object? isFilterNonInternetApp = null,Object? rejectReleased = null,Object? acceptReleased = null,}) {
  return _then(_AccessControlProps(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as AccessControlMode,acceptList: null == acceptList ? _self._acceptList : acceptList // ignore: cast_nullable_to_non_nullable
as List<String>,rejectList: null == rejectList ? _self._rejectList : rejectList // ignore: cast_nullable_to_non_nullable
as List<String>,sort: null == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as AccessSortType,isFilterSystemApp: null == isFilterSystemApp ? _self.isFilterSystemApp : isFilterSystemApp // ignore: cast_nullable_to_non_nullable
as bool,isFilterNonInternetApp: null == isFilterNonInternetApp ? _self.isFilterNonInternetApp : isFilterNonInternetApp // ignore: cast_nullable_to_non_nullable
as bool,rejectReleased: null == rejectReleased ? _self._rejectReleased : rejectReleased // ignore: cast_nullable_to_non_nullable
as List<String>,acceptReleased: null == acceptReleased ? _self._acceptReleased : acceptReleased // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$WindowProps {

 double get width; double get height; double? get top; double? get left; double? get scale;
/// Create a copy of WindowProps
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WindowPropsCopyWith<WindowProps> get copyWith => _$WindowPropsCopyWithImpl<WindowProps>(this as WindowProps, _$identity);

  /// Serializes this WindowProps to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as WindowProps;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WindowProps&&(identical(other.width, _this.width) || other.width == _this.width)&&(identical(other.height, _this.height) || other.height == _this.height)&&(identical(other.top, _this.top) || other.top == _this.top)&&(identical(other.left, _this.left) || other.left == _this.left)&&(identical(other.scale, _this.scale) || other.scale == _this.scale));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as WindowProps;
  return Object.hash(runtimeType,_this.width,_this.height,_this.top,_this.left,_this.scale);
}

@override
String toString() {
  final _this = this as WindowProps;
  return 'WindowProps(width: ${_this.width}, height: ${_this.height}, top: ${_this.top}, left: ${_this.left}, scale: ${_this.scale})';
}


}

/// @nodoc
abstract mixin class $WindowPropsCopyWith<$Res>  {
  factory $WindowPropsCopyWith(WindowProps value, $Res Function(WindowProps) _then) = _$WindowPropsCopyWithImpl;
@useResult
$Res call({
 double width, double height, double? top, double? left, double? scale
});




}
/// @nodoc
class _$WindowPropsCopyWithImpl<$Res>
    implements $WindowPropsCopyWith<$Res> {
  _$WindowPropsCopyWithImpl(this._self, this._then);

  final WindowProps _self;
  final $Res Function(WindowProps) _then;

/// Create a copy of WindowProps
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? width = null,Object? height = null,Object? top = freezed,Object? left = freezed,Object? scale = freezed,}) {
  return _then(WindowProps(
width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,top: freezed == top ? _self.top : top // ignore: cast_nullable_to_non_nullable
as double?,left: freezed == left ? _self.left : left // ignore: cast_nullable_to_non_nullable
as double?,scale: freezed == scale ? _self.scale : scale // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [WindowProps].
extension WindowPropsPatterns on WindowProps {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WindowProps value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WindowProps() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WindowProps value)  $default,){
final _that = this;
switch (_that) {
case _WindowProps():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WindowProps value)?  $default,){
final _that = this;
switch (_that) {
case _WindowProps() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double width,  double height,  double? top,  double? left,  double? scale)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WindowProps() when $default != null:
return $default(_that.width,_that.height,_that.top,_that.left,_that.scale);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double width,  double height,  double? top,  double? left,  double? scale)  $default,) {final _that = this;
switch (_that) {
case _WindowProps():
return $default(_that.width,_that.height,_that.top,_that.left,_that.scale);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double width,  double height,  double? top,  double? left,  double? scale)?  $default,) {final _that = this;
switch (_that) {
case _WindowProps() when $default != null:
return $default(_that.width,_that.height,_that.top,_that.left,_that.scale);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WindowProps implements WindowProps {
  const _WindowProps({this.width = 0, this.height = 0, this.top, this.left, this.scale});
  factory _WindowProps.fromJson(Map<String, dynamic> json) => _$WindowPropsFromJson(json);

@override@JsonKey() final  double width;
@override@JsonKey() final  double height;
@override final  double? top;
@override final  double? left;
@override final  double? scale;

/// Create a copy of WindowProps
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WindowPropsCopyWith<_WindowProps> get copyWith => __$WindowPropsCopyWithImpl<_WindowProps>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WindowPropsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WindowProps&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.top, top) || other.top == top)&&(identical(other.left, left) || other.left == left)&&(identical(other.scale, scale) || other.scale == scale));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,width,height,top,left,scale);
}

@override
String toString() {
    return 'WindowProps(width: $width, height: $height, top: $top, left: $left, scale: $scale)';
}


}

/// @nodoc
abstract mixin class _$WindowPropsCopyWith<$Res> implements $WindowPropsCopyWith<$Res> {
  factory _$WindowPropsCopyWith(_WindowProps value, $Res Function(_WindowProps) _then) = __$WindowPropsCopyWithImpl;
@override @useResult
$Res call({
 double width, double height, double? top, double? left, double? scale
});




}
/// @nodoc
class __$WindowPropsCopyWithImpl<$Res>
    implements _$WindowPropsCopyWith<$Res> {
  __$WindowPropsCopyWithImpl(this._self, this._then);

  final _WindowProps _self;
  final $Res Function(_WindowProps) _then;

/// Create a copy of WindowProps
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? width = null,Object? height = null,Object? top = freezed,Object? left = freezed,Object? scale = freezed,}) {
  return _then(_WindowProps(
width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,top: freezed == top ? _self.top : top // ignore: cast_nullable_to_non_nullable
as double?,left: freezed == left ? _self.left : left // ignore: cast_nullable_to_non_nullable
as double?,scale: freezed == scale ? _self.scale : scale // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$VpnProps {

 bool get enable; bool get systemProxy; bool get ipv6; bool get allowBypass; bool get dnsHijacking; AccessControlProps get accessControlProps; bool get onDemandEnabled; bool get onDemandFullStop; bool get onDemandCloseConnections; bool get onDemandStrict;
/// Create a copy of VpnProps
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VpnPropsCopyWith<VpnProps> get copyWith => _$VpnPropsCopyWithImpl<VpnProps>(this as VpnProps, _$identity);

  /// Serializes this VpnProps to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as VpnProps;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VpnProps&&(identical(other.enable, _this.enable) || other.enable == _this.enable)&&(identical(other.systemProxy, _this.systemProxy) || other.systemProxy == _this.systemProxy)&&(identical(other.ipv6, _this.ipv6) || other.ipv6 == _this.ipv6)&&(identical(other.allowBypass, _this.allowBypass) || other.allowBypass == _this.allowBypass)&&(identical(other.dnsHijacking, _this.dnsHijacking) || other.dnsHijacking == _this.dnsHijacking)&&(identical(other.accessControlProps, _this.accessControlProps) || other.accessControlProps == _this.accessControlProps)&&(identical(other.onDemandEnabled, _this.onDemandEnabled) || other.onDemandEnabled == _this.onDemandEnabled)&&(identical(other.onDemandFullStop, _this.onDemandFullStop) || other.onDemandFullStop == _this.onDemandFullStop)&&(identical(other.onDemandCloseConnections, _this.onDemandCloseConnections) || other.onDemandCloseConnections == _this.onDemandCloseConnections)&&(identical(other.onDemandStrict, _this.onDemandStrict) || other.onDemandStrict == _this.onDemandStrict));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as VpnProps;
  return Object.hash(runtimeType,_this.enable,_this.systemProxy,_this.ipv6,_this.allowBypass,_this.dnsHijacking,_this.accessControlProps,_this.onDemandEnabled,_this.onDemandFullStop,_this.onDemandCloseConnections,_this.onDemandStrict);
}

@override
String toString() {
  final _this = this as VpnProps;
  return 'VpnProps(enable: ${_this.enable}, systemProxy: ${_this.systemProxy}, ipv6: ${_this.ipv6}, allowBypass: ${_this.allowBypass}, dnsHijacking: ${_this.dnsHijacking}, accessControlProps: ${_this.accessControlProps}, onDemandEnabled: ${_this.onDemandEnabled}, onDemandFullStop: ${_this.onDemandFullStop}, onDemandCloseConnections: ${_this.onDemandCloseConnections}, onDemandStrict: ${_this.onDemandStrict})';
}


}

/// @nodoc
abstract mixin class $VpnPropsCopyWith<$Res>  {
  factory $VpnPropsCopyWith(VpnProps value, $Res Function(VpnProps) _then) = _$VpnPropsCopyWithImpl;
@useResult
$Res call({
 bool enable, bool systemProxy, bool ipv6, bool allowBypass, bool dnsHijacking, AccessControlProps accessControlProps, bool onDemandEnabled, bool onDemandFullStop, bool onDemandCloseConnections, bool onDemandStrict
});


$AccessControlPropsCopyWith<$Res> get accessControlProps;

}
/// @nodoc
class _$VpnPropsCopyWithImpl<$Res>
    implements $VpnPropsCopyWith<$Res> {
  _$VpnPropsCopyWithImpl(this._self, this._then);

  final VpnProps _self;
  final $Res Function(VpnProps) _then;

/// Create a copy of VpnProps
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enable = null,Object? systemProxy = null,Object? ipv6 = null,Object? allowBypass = null,Object? dnsHijacking = null,Object? accessControlProps = null,Object? onDemandEnabled = null,Object? onDemandFullStop = null,Object? onDemandCloseConnections = null,Object? onDemandStrict = null,}) {
  return _then(VpnProps(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,systemProxy: null == systemProxy ? _self.systemProxy : systemProxy // ignore: cast_nullable_to_non_nullable
as bool,ipv6: null == ipv6 ? _self.ipv6 : ipv6 // ignore: cast_nullable_to_non_nullable
as bool,allowBypass: null == allowBypass ? _self.allowBypass : allowBypass // ignore: cast_nullable_to_non_nullable
as bool,dnsHijacking: null == dnsHijacking ? _self.dnsHijacking : dnsHijacking // ignore: cast_nullable_to_non_nullable
as bool,accessControlProps: null == accessControlProps ? _self.accessControlProps : accessControlProps // ignore: cast_nullable_to_non_nullable
as AccessControlProps,onDemandEnabled: null == onDemandEnabled ? _self.onDemandEnabled : onDemandEnabled // ignore: cast_nullable_to_non_nullable
as bool,onDemandFullStop: null == onDemandFullStop ? _self.onDemandFullStop : onDemandFullStop // ignore: cast_nullable_to_non_nullable
as bool,onDemandCloseConnections: null == onDemandCloseConnections ? _self.onDemandCloseConnections : onDemandCloseConnections // ignore: cast_nullable_to_non_nullable
as bool,onDemandStrict: null == onDemandStrict ? _self.onDemandStrict : onDemandStrict // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of VpnProps
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AccessControlPropsCopyWith<$Res> get accessControlProps {
  
  return $AccessControlPropsCopyWith<$Res>(_self.accessControlProps, (value) {
    return _then(_self.copyWith(accessControlProps: value));
  });
}
}


/// Adds pattern-matching-related methods to [VpnProps].
extension VpnPropsPatterns on VpnProps {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VpnProps value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VpnProps() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VpnProps value)  $default,){
final _that = this;
switch (_that) {
case _VpnProps():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VpnProps value)?  $default,){
final _that = this;
switch (_that) {
case _VpnProps() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enable,  bool systemProxy,  bool ipv6,  bool allowBypass,  bool dnsHijacking,  AccessControlProps accessControlProps,  bool onDemandEnabled,  bool onDemandFullStop,  bool onDemandCloseConnections,  bool onDemandStrict)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VpnProps() when $default != null:
return $default(_that.enable,_that.systemProxy,_that.ipv6,_that.allowBypass,_that.dnsHijacking,_that.accessControlProps,_that.onDemandEnabled,_that.onDemandFullStop,_that.onDemandCloseConnections,_that.onDemandStrict);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enable,  bool systemProxy,  bool ipv6,  bool allowBypass,  bool dnsHijacking,  AccessControlProps accessControlProps,  bool onDemandEnabled,  bool onDemandFullStop,  bool onDemandCloseConnections,  bool onDemandStrict)  $default,) {final _that = this;
switch (_that) {
case _VpnProps():
return $default(_that.enable,_that.systemProxy,_that.ipv6,_that.allowBypass,_that.dnsHijacking,_that.accessControlProps,_that.onDemandEnabled,_that.onDemandFullStop,_that.onDemandCloseConnections,_that.onDemandStrict);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enable,  bool systemProxy,  bool ipv6,  bool allowBypass,  bool dnsHijacking,  AccessControlProps accessControlProps,  bool onDemandEnabled,  bool onDemandFullStop,  bool onDemandCloseConnections,  bool onDemandStrict)?  $default,) {final _that = this;
switch (_that) {
case _VpnProps() when $default != null:
return $default(_that.enable,_that.systemProxy,_that.ipv6,_that.allowBypass,_that.dnsHijacking,_that.accessControlProps,_that.onDemandEnabled,_that.onDemandFullStop,_that.onDemandCloseConnections,_that.onDemandStrict);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VpnProps implements VpnProps {
  const _VpnProps({this.enable = true, this.systemProxy = true, this.ipv6 = false, this.allowBypass = true, this.dnsHijacking = false, this.accessControlProps = defaultAccessControlProps, this.onDemandEnabled = true, this.onDemandFullStop = false, this.onDemandCloseConnections = false, this.onDemandStrict = false});
  factory _VpnProps.fromJson(Map<String, dynamic> json) => _$VpnPropsFromJson(json);

@override@JsonKey() final  bool enable;
@override@JsonKey() final  bool systemProxy;
@override@JsonKey() final  bool ipv6;
@override@JsonKey() final  bool allowBypass;
@override@JsonKey() final  bool dnsHijacking;
@override@JsonKey() final  AccessControlProps accessControlProps;
@override@JsonKey() final  bool onDemandEnabled;
@override@JsonKey() final  bool onDemandFullStop;
@override@JsonKey() final  bool onDemandCloseConnections;
@override@JsonKey() final  bool onDemandStrict;

/// Create a copy of VpnProps
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VpnPropsCopyWith<_VpnProps> get copyWith => __$VpnPropsCopyWithImpl<_VpnProps>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VpnPropsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VpnProps&&(identical(other.enable, enable) || other.enable == enable)&&(identical(other.systemProxy, systemProxy) || other.systemProxy == systemProxy)&&(identical(other.ipv6, ipv6) || other.ipv6 == ipv6)&&(identical(other.allowBypass, allowBypass) || other.allowBypass == allowBypass)&&(identical(other.dnsHijacking, dnsHijacking) || other.dnsHijacking == dnsHijacking)&&(identical(other.accessControlProps, accessControlProps) || other.accessControlProps == accessControlProps)&&(identical(other.onDemandEnabled, onDemandEnabled) || other.onDemandEnabled == onDemandEnabled)&&(identical(other.onDemandFullStop, onDemandFullStop) || other.onDemandFullStop == onDemandFullStop)&&(identical(other.onDemandCloseConnections, onDemandCloseConnections) || other.onDemandCloseConnections == onDemandCloseConnections)&&(identical(other.onDemandStrict, onDemandStrict) || other.onDemandStrict == onDemandStrict));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,enable,systemProxy,ipv6,allowBypass,dnsHijacking,accessControlProps,onDemandEnabled,onDemandFullStop,onDemandCloseConnections,onDemandStrict);
}

@override
String toString() {
    return 'VpnProps(enable: $enable, systemProxy: $systemProxy, ipv6: $ipv6, allowBypass: $allowBypass, dnsHijacking: $dnsHijacking, accessControlProps: $accessControlProps, onDemandEnabled: $onDemandEnabled, onDemandFullStop: $onDemandFullStop, onDemandCloseConnections: $onDemandCloseConnections, onDemandStrict: $onDemandStrict)';
}


}

/// @nodoc
abstract mixin class _$VpnPropsCopyWith<$Res> implements $VpnPropsCopyWith<$Res> {
  factory _$VpnPropsCopyWith(_VpnProps value, $Res Function(_VpnProps) _then) = __$VpnPropsCopyWithImpl;
@override @useResult
$Res call({
 bool enable, bool systemProxy, bool ipv6, bool allowBypass, bool dnsHijacking, AccessControlProps accessControlProps, bool onDemandEnabled, bool onDemandFullStop, bool onDemandCloseConnections, bool onDemandStrict
});


@override $AccessControlPropsCopyWith<$Res> get accessControlProps;

}
/// @nodoc
class __$VpnPropsCopyWithImpl<$Res>
    implements _$VpnPropsCopyWith<$Res> {
  __$VpnPropsCopyWithImpl(this._self, this._then);

  final _VpnProps _self;
  final $Res Function(_VpnProps) _then;

/// Create a copy of VpnProps
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enable = null,Object? systemProxy = null,Object? ipv6 = null,Object? allowBypass = null,Object? dnsHijacking = null,Object? accessControlProps = null,Object? onDemandEnabled = null,Object? onDemandFullStop = null,Object? onDemandCloseConnections = null,Object? onDemandStrict = null,}) {
  return _then(_VpnProps(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,systemProxy: null == systemProxy ? _self.systemProxy : systemProxy // ignore: cast_nullable_to_non_nullable
as bool,ipv6: null == ipv6 ? _self.ipv6 : ipv6 // ignore: cast_nullable_to_non_nullable
as bool,allowBypass: null == allowBypass ? _self.allowBypass : allowBypass // ignore: cast_nullable_to_non_nullable
as bool,dnsHijacking: null == dnsHijacking ? _self.dnsHijacking : dnsHijacking // ignore: cast_nullable_to_non_nullable
as bool,accessControlProps: null == accessControlProps ? _self.accessControlProps : accessControlProps // ignore: cast_nullable_to_non_nullable
as AccessControlProps,onDemandEnabled: null == onDemandEnabled ? _self.onDemandEnabled : onDemandEnabled // ignore: cast_nullable_to_non_nullable
as bool,onDemandFullStop: null == onDemandFullStop ? _self.onDemandFullStop : onDemandFullStop // ignore: cast_nullable_to_non_nullable
as bool,onDemandCloseConnections: null == onDemandCloseConnections ? _self.onDemandCloseConnections : onDemandCloseConnections // ignore: cast_nullable_to_non_nullable
as bool,onDemandStrict: null == onDemandStrict ? _self.onDemandStrict : onDemandStrict // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of VpnProps
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AccessControlPropsCopyWith<$Res> get accessControlProps {
  
  return $AccessControlPropsCopyWith<$Res>(_self.accessControlProps, (value) {
    return _then(_self.copyWith(accessControlProps: value));
  });
}
}


/// @nodoc
mixin _$AuthenticationProps {

 bool get enable; String get username; String get password;
/// Create a copy of AuthenticationProps
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthenticationPropsCopyWith<AuthenticationProps> get copyWith => _$AuthenticationPropsCopyWithImpl<AuthenticationProps>(this as AuthenticationProps, _$identity);

  /// Serializes this AuthenticationProps to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AuthenticationProps;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthenticationProps&&(identical(other.enable, _this.enable) || other.enable == _this.enable)&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.password, _this.password) || other.password == _this.password));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AuthenticationProps;
  return Object.hash(runtimeType,_this.enable,_this.username,_this.password);
}

@override
String toString() {
  final _this = this as AuthenticationProps;
  return 'AuthenticationProps(enable: ${_this.enable}, username: ${_this.username}, password: ${_this.password})';
}


}

/// @nodoc
abstract mixin class $AuthenticationPropsCopyWith<$Res>  {
  factory $AuthenticationPropsCopyWith(AuthenticationProps value, $Res Function(AuthenticationProps) _then) = _$AuthenticationPropsCopyWithImpl;
@useResult
$Res call({
 bool enable, String username, String password
});




}
/// @nodoc
class _$AuthenticationPropsCopyWithImpl<$Res>
    implements $AuthenticationPropsCopyWith<$Res> {
  _$AuthenticationPropsCopyWithImpl(this._self, this._then);

  final AuthenticationProps _self;
  final $Res Function(AuthenticationProps) _then;

/// Create a copy of AuthenticationProps
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enable = null,Object? username = null,Object? password = null,}) {
  return _then(AuthenticationProps(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AuthenticationProps].
extension AuthenticationPropsPatterns on AuthenticationProps {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthenticationProps value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthenticationProps() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthenticationProps value)  $default,){
final _that = this;
switch (_that) {
case _AuthenticationProps():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthenticationProps value)?  $default,){
final _that = this;
switch (_that) {
case _AuthenticationProps() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enable,  String username,  String password)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthenticationProps() when $default != null:
return $default(_that.enable,_that.username,_that.password);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enable,  String username,  String password)  $default,) {final _that = this;
switch (_that) {
case _AuthenticationProps():
return $default(_that.enable,_that.username,_that.password);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enable,  String username,  String password)?  $default,) {final _that = this;
switch (_that) {
case _AuthenticationProps() when $default != null:
return $default(_that.enable,_that.username,_that.password);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuthenticationProps implements AuthenticationProps {
  const _AuthenticationProps({this.enable = false, this.username = '', this.password = ''});
  factory _AuthenticationProps.fromJson(Map<String, dynamic> json) => _$AuthenticationPropsFromJson(json);

@override@JsonKey() final  bool enable;
@override@JsonKey() final  String username;
@override@JsonKey() final  String password;

/// Create a copy of AuthenticationProps
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthenticationPropsCopyWith<_AuthenticationProps> get copyWith => __$AuthenticationPropsCopyWithImpl<_AuthenticationProps>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuthenticationPropsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthenticationProps&&(identical(other.enable, enable) || other.enable == enable)&&(identical(other.username, username) || other.username == username)&&(identical(other.password, password) || other.password == password));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,enable,username,password);
}

@override
String toString() {
    return 'AuthenticationProps(enable: $enable, username: $username, password: $password)';
}


}

/// @nodoc
abstract mixin class _$AuthenticationPropsCopyWith<$Res> implements $AuthenticationPropsCopyWith<$Res> {
  factory _$AuthenticationPropsCopyWith(_AuthenticationProps value, $Res Function(_AuthenticationProps) _then) = __$AuthenticationPropsCopyWithImpl;
@override @useResult
$Res call({
 bool enable, String username, String password
});




}
/// @nodoc
class __$AuthenticationPropsCopyWithImpl<$Res>
    implements _$AuthenticationPropsCopyWith<$Res> {
  __$AuthenticationPropsCopyWithImpl(this._self, this._then);

  final _AuthenticationProps _self;
  final $Res Function(_AuthenticationProps) _then;

/// Create a copy of AuthenticationProps
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enable = null,Object? username = null,Object? password = null,}) {
  return _then(_AuthenticationProps(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$NetworkProps {

 bool get systemProxy; List<String> get bypassDomain; bool get bypassPrivateRoute; bool get autoSetSystemDns; bool get appendSystemDns; AuthenticationProps get authentication;
/// Create a copy of NetworkProps
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NetworkPropsCopyWith<NetworkProps> get copyWith => _$NetworkPropsCopyWithImpl<NetworkProps>(this as NetworkProps, _$identity);

  /// Serializes this NetworkProps to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as NetworkProps;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NetworkProps&&(identical(other.systemProxy, _this.systemProxy) || other.systemProxy == _this.systemProxy)&&const DeepCollectionEquality().equals(other.bypassDomain, _this.bypassDomain)&&(identical(other.bypassPrivateRoute, _this.bypassPrivateRoute) || other.bypassPrivateRoute == _this.bypassPrivateRoute)&&(identical(other.autoSetSystemDns, _this.autoSetSystemDns) || other.autoSetSystemDns == _this.autoSetSystemDns)&&(identical(other.appendSystemDns, _this.appendSystemDns) || other.appendSystemDns == _this.appendSystemDns)&&(identical(other.authentication, _this.authentication) || other.authentication == _this.authentication));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as NetworkProps;
  return Object.hash(runtimeType,_this.systemProxy,const DeepCollectionEquality().hash(_this.bypassDomain),_this.bypassPrivateRoute,_this.autoSetSystemDns,_this.appendSystemDns,_this.authentication);
}

@override
String toString() {
  final _this = this as NetworkProps;
  return 'NetworkProps(systemProxy: ${_this.systemProxy}, bypassDomain: ${_this.bypassDomain}, bypassPrivateRoute: ${_this.bypassPrivateRoute}, autoSetSystemDns: ${_this.autoSetSystemDns}, appendSystemDns: ${_this.appendSystemDns}, authentication: ${_this.authentication})';
}


}

/// @nodoc
abstract mixin class $NetworkPropsCopyWith<$Res>  {
  factory $NetworkPropsCopyWith(NetworkProps value, $Res Function(NetworkProps) _then) = _$NetworkPropsCopyWithImpl;
@useResult
$Res call({
 bool systemProxy, List<String> bypassDomain, bool bypassPrivateRoute, bool autoSetSystemDns, bool appendSystemDns, AuthenticationProps authentication
});


$AuthenticationPropsCopyWith<$Res> get authentication;

}
/// @nodoc
class _$NetworkPropsCopyWithImpl<$Res>
    implements $NetworkPropsCopyWith<$Res> {
  _$NetworkPropsCopyWithImpl(this._self, this._then);

  final NetworkProps _self;
  final $Res Function(NetworkProps) _then;

/// Create a copy of NetworkProps
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? systemProxy = null,Object? bypassDomain = null,Object? bypassPrivateRoute = null,Object? autoSetSystemDns = null,Object? appendSystemDns = null,Object? authentication = null,}) {
  return _then(NetworkProps(
systemProxy: null == systemProxy ? _self.systemProxy : systemProxy // ignore: cast_nullable_to_non_nullable
as bool,bypassDomain: null == bypassDomain ? _self.bypassDomain : bypassDomain // ignore: cast_nullable_to_non_nullable
as List<String>,bypassPrivateRoute: null == bypassPrivateRoute ? _self.bypassPrivateRoute : bypassPrivateRoute // ignore: cast_nullable_to_non_nullable
as bool,autoSetSystemDns: null == autoSetSystemDns ? _self.autoSetSystemDns : autoSetSystemDns // ignore: cast_nullable_to_non_nullable
as bool,appendSystemDns: null == appendSystemDns ? _self.appendSystemDns : appendSystemDns // ignore: cast_nullable_to_non_nullable
as bool,authentication: null == authentication ? _self.authentication : authentication // ignore: cast_nullable_to_non_nullable
as AuthenticationProps,
  ));
}
/// Create a copy of NetworkProps
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthenticationPropsCopyWith<$Res> get authentication {
  
  return $AuthenticationPropsCopyWith<$Res>(_self.authentication, (value) {
    return _then(_self.copyWith(authentication: value));
  });
}
}


/// Adds pattern-matching-related methods to [NetworkProps].
extension NetworkPropsPatterns on NetworkProps {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NetworkProps value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NetworkProps() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NetworkProps value)  $default,){
final _that = this;
switch (_that) {
case _NetworkProps():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NetworkProps value)?  $default,){
final _that = this;
switch (_that) {
case _NetworkProps() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool systemProxy,  List<String> bypassDomain,  bool bypassPrivateRoute,  bool autoSetSystemDns,  bool appendSystemDns,  AuthenticationProps authentication)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NetworkProps() when $default != null:
return $default(_that.systemProxy,_that.bypassDomain,_that.bypassPrivateRoute,_that.autoSetSystemDns,_that.appendSystemDns,_that.authentication);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool systemProxy,  List<String> bypassDomain,  bool bypassPrivateRoute,  bool autoSetSystemDns,  bool appendSystemDns,  AuthenticationProps authentication)  $default,) {final _that = this;
switch (_that) {
case _NetworkProps():
return $default(_that.systemProxy,_that.bypassDomain,_that.bypassPrivateRoute,_that.autoSetSystemDns,_that.appendSystemDns,_that.authentication);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool systemProxy,  List<String> bypassDomain,  bool bypassPrivateRoute,  bool autoSetSystemDns,  bool appendSystemDns,  AuthenticationProps authentication)?  $default,) {final _that = this;
switch (_that) {
case _NetworkProps() when $default != null:
return $default(_that.systemProxy,_that.bypassDomain,_that.bypassPrivateRoute,_that.autoSetSystemDns,_that.appendSystemDns,_that.authentication);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NetworkProps implements NetworkProps {
  const _NetworkProps({this.systemProxy = true,  List<String> bypassDomain = defaultBypassDomain, this.bypassPrivateRoute = true, this.autoSetSystemDns = true, this.appendSystemDns = false, this.authentication = defaultAuthenticationProps}): _bypassDomain = bypassDomain;
  factory _NetworkProps.fromJson(Map<String, dynamic> json) => _$NetworkPropsFromJson(json);

@override@JsonKey() final  bool systemProxy;
 final  List<String> _bypassDomain;
@override@JsonKey() List<String> get bypassDomain {
  if (_bypassDomain is EqualUnmodifiableListView) return _bypassDomain;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bypassDomain);
}

@override@JsonKey() final  bool bypassPrivateRoute;
@override@JsonKey() final  bool autoSetSystemDns;
@override@JsonKey() final  bool appendSystemDns;
@override@JsonKey() final  AuthenticationProps authentication;

/// Create a copy of NetworkProps
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NetworkPropsCopyWith<_NetworkProps> get copyWith => __$NetworkPropsCopyWithImpl<_NetworkProps>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NetworkPropsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NetworkProps&&(identical(other.systemProxy, systemProxy) || other.systemProxy == systemProxy)&&const DeepCollectionEquality().equals(other.bypassDomain, _bypassDomain)&&(identical(other.bypassPrivateRoute, bypassPrivateRoute) || other.bypassPrivateRoute == bypassPrivateRoute)&&(identical(other.autoSetSystemDns, autoSetSystemDns) || other.autoSetSystemDns == autoSetSystemDns)&&(identical(other.appendSystemDns, appendSystemDns) || other.appendSystemDns == appendSystemDns)&&(identical(other.authentication, authentication) || other.authentication == authentication));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,systemProxy,const DeepCollectionEquality().hash(_bypassDomain),bypassPrivateRoute,autoSetSystemDns,appendSystemDns,authentication);
}

@override
String toString() {
    return 'NetworkProps(systemProxy: $systemProxy, bypassDomain: $bypassDomain, bypassPrivateRoute: $bypassPrivateRoute, autoSetSystemDns: $autoSetSystemDns, appendSystemDns: $appendSystemDns, authentication: $authentication)';
}


}

/// @nodoc
abstract mixin class _$NetworkPropsCopyWith<$Res> implements $NetworkPropsCopyWith<$Res> {
  factory _$NetworkPropsCopyWith(_NetworkProps value, $Res Function(_NetworkProps) _then) = __$NetworkPropsCopyWithImpl;
@override @useResult
$Res call({
 bool systemProxy, List<String> bypassDomain, bool bypassPrivateRoute, bool autoSetSystemDns, bool appendSystemDns, AuthenticationProps authentication
});


@override $AuthenticationPropsCopyWith<$Res> get authentication;

}
/// @nodoc
class __$NetworkPropsCopyWithImpl<$Res>
    implements _$NetworkPropsCopyWith<$Res> {
  __$NetworkPropsCopyWithImpl(this._self, this._then);

  final _NetworkProps _self;
  final $Res Function(_NetworkProps) _then;

/// Create a copy of NetworkProps
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? systemProxy = null,Object? bypassDomain = null,Object? bypassPrivateRoute = null,Object? autoSetSystemDns = null,Object? appendSystemDns = null,Object? authentication = null,}) {
  return _then(_NetworkProps(
systemProxy: null == systemProxy ? _self.systemProxy : systemProxy // ignore: cast_nullable_to_non_nullable
as bool,bypassDomain: null == bypassDomain ? _self._bypassDomain : bypassDomain // ignore: cast_nullable_to_non_nullable
as List<String>,bypassPrivateRoute: null == bypassPrivateRoute ? _self.bypassPrivateRoute : bypassPrivateRoute // ignore: cast_nullable_to_non_nullable
as bool,autoSetSystemDns: null == autoSetSystemDns ? _self.autoSetSystemDns : autoSetSystemDns // ignore: cast_nullable_to_non_nullable
as bool,appendSystemDns: null == appendSystemDns ? _self.appendSystemDns : appendSystemDns // ignore: cast_nullable_to_non_nullable
as bool,authentication: null == authentication ? _self.authentication : authentication // ignore: cast_nullable_to_non_nullable
as AuthenticationProps,
  ));
}

/// Create a copy of NetworkProps
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthenticationPropsCopyWith<$Res> get authentication {
  
  return $AuthenticationPropsCopyWith<$Res>(_self.authentication, (value) {
    return _then(_self.copyWith(authentication: value));
  });
}
}


/// @nodoc
mixin _$ProxiesStyleProps {

 ProxiesType get type; ProxiesSortType get sortType; ProxiesLayout get layout;@JsonKey(fromJson: proxiesIconStyleSafeFromJson) ProxiesIconStyle get iconStyle;@JsonKey(fromJson: proxyCardTypeSafeFromJson) ProxyCardType get cardType; bool get hideTimeoutProxies;
/// Create a copy of ProxiesStyleProps
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProxiesStylePropsCopyWith<ProxiesStyleProps> get copyWith => _$ProxiesStylePropsCopyWithImpl<ProxiesStyleProps>(this as ProxiesStyleProps, _$identity);

  /// Serializes this ProxiesStyleProps to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ProxiesStyleProps;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProxiesStyleProps&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.sortType, _this.sortType) || other.sortType == _this.sortType)&&(identical(other.layout, _this.layout) || other.layout == _this.layout)&&(identical(other.iconStyle, _this.iconStyle) || other.iconStyle == _this.iconStyle)&&(identical(other.cardType, _this.cardType) || other.cardType == _this.cardType)&&(identical(other.hideTimeoutProxies, _this.hideTimeoutProxies) || other.hideTimeoutProxies == _this.hideTimeoutProxies));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ProxiesStyleProps;
  return Object.hash(runtimeType,_this.type,_this.sortType,_this.layout,_this.iconStyle,_this.cardType,_this.hideTimeoutProxies);
}

@override
String toString() {
  final _this = this as ProxiesStyleProps;
  return 'ProxiesStyleProps(type: ${_this.type}, sortType: ${_this.sortType}, layout: ${_this.layout}, iconStyle: ${_this.iconStyle}, cardType: ${_this.cardType}, hideTimeoutProxies: ${_this.hideTimeoutProxies})';
}


}

/// @nodoc
abstract mixin class $ProxiesStylePropsCopyWith<$Res>  {
  factory $ProxiesStylePropsCopyWith(ProxiesStyleProps value, $Res Function(ProxiesStyleProps) _then) = _$ProxiesStylePropsCopyWithImpl;
@useResult
$Res call({
 ProxiesType type, ProxiesSortType sortType, ProxiesLayout layout,@JsonKey(fromJson: proxiesIconStyleSafeFromJson) ProxiesIconStyle iconStyle,@JsonKey(fromJson: proxyCardTypeSafeFromJson) ProxyCardType cardType, bool hideTimeoutProxies
});




}
/// @nodoc
class _$ProxiesStylePropsCopyWithImpl<$Res>
    implements $ProxiesStylePropsCopyWith<$Res> {
  _$ProxiesStylePropsCopyWithImpl(this._self, this._then);

  final ProxiesStyleProps _self;
  final $Res Function(ProxiesStyleProps) _then;

/// Create a copy of ProxiesStyleProps
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? sortType = null,Object? layout = null,Object? iconStyle = null,Object? cardType = null,Object? hideTimeoutProxies = null,}) {
  return _then(ProxiesStyleProps(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ProxiesType,sortType: null == sortType ? _self.sortType : sortType // ignore: cast_nullable_to_non_nullable
as ProxiesSortType,layout: null == layout ? _self.layout : layout // ignore: cast_nullable_to_non_nullable
as ProxiesLayout,iconStyle: null == iconStyle ? _self.iconStyle : iconStyle // ignore: cast_nullable_to_non_nullable
as ProxiesIconStyle,cardType: null == cardType ? _self.cardType : cardType // ignore: cast_nullable_to_non_nullable
as ProxyCardType,hideTimeoutProxies: null == hideTimeoutProxies ? _self.hideTimeoutProxies : hideTimeoutProxies // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ProxiesStyleProps].
extension ProxiesStylePropsPatterns on ProxiesStyleProps {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProxiesStyleProps value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProxiesStyleProps() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProxiesStyleProps value)  $default,){
final _that = this;
switch (_that) {
case _ProxiesStyleProps():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProxiesStyleProps value)?  $default,){
final _that = this;
switch (_that) {
case _ProxiesStyleProps() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ProxiesType type,  ProxiesSortType sortType,  ProxiesLayout layout, @JsonKey(fromJson: proxiesIconStyleSafeFromJson)  ProxiesIconStyle iconStyle, @JsonKey(fromJson: proxyCardTypeSafeFromJson)  ProxyCardType cardType,  bool hideTimeoutProxies)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProxiesStyleProps() when $default != null:
return $default(_that.type,_that.sortType,_that.layout,_that.iconStyle,_that.cardType,_that.hideTimeoutProxies);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ProxiesType type,  ProxiesSortType sortType,  ProxiesLayout layout, @JsonKey(fromJson: proxiesIconStyleSafeFromJson)  ProxiesIconStyle iconStyle, @JsonKey(fromJson: proxyCardTypeSafeFromJson)  ProxyCardType cardType,  bool hideTimeoutProxies)  $default,) {final _that = this;
switch (_that) {
case _ProxiesStyleProps():
return $default(_that.type,_that.sortType,_that.layout,_that.iconStyle,_that.cardType,_that.hideTimeoutProxies);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ProxiesType type,  ProxiesSortType sortType,  ProxiesLayout layout, @JsonKey(fromJson: proxiesIconStyleSafeFromJson)  ProxiesIconStyle iconStyle, @JsonKey(fromJson: proxyCardTypeSafeFromJson)  ProxyCardType cardType,  bool hideTimeoutProxies)?  $default,) {final _that = this;
switch (_that) {
case _ProxiesStyleProps() when $default != null:
return $default(_that.type,_that.sortType,_that.layout,_that.iconStyle,_that.cardType,_that.hideTimeoutProxies);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProxiesStyleProps implements ProxiesStyleProps {
  const _ProxiesStyleProps({this.type = ProxiesType.list, this.sortType = ProxiesSortType.none, this.layout = ProxiesLayout.standard, @JsonKey(fromJson: proxiesIconStyleSafeFromJson) this.iconStyle = ProxiesIconStyle.filled, @JsonKey(fromJson: proxyCardTypeSafeFromJson) this.cardType = ProxyCardType.standard, this.hideTimeoutProxies = false});
  factory _ProxiesStyleProps.fromJson(Map<String, dynamic> json) => _$ProxiesStylePropsFromJson(json);

@override@JsonKey() final  ProxiesType type;
@override@JsonKey() final  ProxiesSortType sortType;
@override@JsonKey() final  ProxiesLayout layout;
@override@JsonKey(fromJson: proxiesIconStyleSafeFromJson) final  ProxiesIconStyle iconStyle;
@override@JsonKey(fromJson: proxyCardTypeSafeFromJson) final  ProxyCardType cardType;
@override@JsonKey() final  bool hideTimeoutProxies;

/// Create a copy of ProxiesStyleProps
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProxiesStylePropsCopyWith<_ProxiesStyleProps> get copyWith => __$ProxiesStylePropsCopyWithImpl<_ProxiesStyleProps>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProxiesStylePropsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProxiesStyleProps&&(identical(other.type, type) || other.type == type)&&(identical(other.sortType, sortType) || other.sortType == sortType)&&(identical(other.layout, layout) || other.layout == layout)&&(identical(other.iconStyle, iconStyle) || other.iconStyle == iconStyle)&&(identical(other.cardType, cardType) || other.cardType == cardType)&&(identical(other.hideTimeoutProxies, hideTimeoutProxies) || other.hideTimeoutProxies == hideTimeoutProxies));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,type,sortType,layout,iconStyle,cardType,hideTimeoutProxies);
}

@override
String toString() {
    return 'ProxiesStyleProps(type: $type, sortType: $sortType, layout: $layout, iconStyle: $iconStyle, cardType: $cardType, hideTimeoutProxies: $hideTimeoutProxies)';
}


}

/// @nodoc
abstract mixin class _$ProxiesStylePropsCopyWith<$Res> implements $ProxiesStylePropsCopyWith<$Res> {
  factory _$ProxiesStylePropsCopyWith(_ProxiesStyleProps value, $Res Function(_ProxiesStyleProps) _then) = __$ProxiesStylePropsCopyWithImpl;
@override @useResult
$Res call({
 ProxiesType type, ProxiesSortType sortType, ProxiesLayout layout,@JsonKey(fromJson: proxiesIconStyleSafeFromJson) ProxiesIconStyle iconStyle,@JsonKey(fromJson: proxyCardTypeSafeFromJson) ProxyCardType cardType, bool hideTimeoutProxies
});




}
/// @nodoc
class __$ProxiesStylePropsCopyWithImpl<$Res>
    implements _$ProxiesStylePropsCopyWith<$Res> {
  __$ProxiesStylePropsCopyWithImpl(this._self, this._then);

  final _ProxiesStyleProps _self;
  final $Res Function(_ProxiesStyleProps) _then;

/// Create a copy of ProxiesStyleProps
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? sortType = null,Object? layout = null,Object? iconStyle = null,Object? cardType = null,Object? hideTimeoutProxies = null,}) {
  return _then(_ProxiesStyleProps(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ProxiesType,sortType: null == sortType ? _self.sortType : sortType // ignore: cast_nullable_to_non_nullable
as ProxiesSortType,layout: null == layout ? _self.layout : layout // ignore: cast_nullable_to_non_nullable
as ProxiesLayout,iconStyle: null == iconStyle ? _self.iconStyle : iconStyle // ignore: cast_nullable_to_non_nullable
as ProxiesIconStyle,cardType: null == cardType ? _self.cardType : cardType // ignore: cast_nullable_to_non_nullable
as ProxyCardType,hideTimeoutProxies: null == hideTimeoutProxies ? _self.hideTimeoutProxies : hideTimeoutProxies // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$TextScale {

 bool get enable; double get scale;
/// Create a copy of TextScale
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TextScaleCopyWith<TextScale> get copyWith => _$TextScaleCopyWithImpl<TextScale>(this as TextScale, _$identity);

  /// Serializes this TextScale to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TextScale;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TextScale&&(identical(other.enable, _this.enable) || other.enable == _this.enable)&&(identical(other.scale, _this.scale) || other.scale == _this.scale));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TextScale;
  return Object.hash(runtimeType,_this.enable,_this.scale);
}

@override
String toString() {
  final _this = this as TextScale;
  return 'TextScale(enable: ${_this.enable}, scale: ${_this.scale})';
}


}

/// @nodoc
abstract mixin class $TextScaleCopyWith<$Res>  {
  factory $TextScaleCopyWith(TextScale value, $Res Function(TextScale) _then) = _$TextScaleCopyWithImpl;
@useResult
$Res call({
 bool enable, double scale
});




}
/// @nodoc
class _$TextScaleCopyWithImpl<$Res>
    implements $TextScaleCopyWith<$Res> {
  _$TextScaleCopyWithImpl(this._self, this._then);

  final TextScale _self;
  final $Res Function(TextScale) _then;

/// Create a copy of TextScale
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enable = null,Object? scale = null,}) {
  return _then(TextScale(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,scale: null == scale ? _self.scale : scale // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [TextScale].
extension TextScalePatterns on TextScale {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TextScale value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TextScale() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TextScale value)  $default,){
final _that = this;
switch (_that) {
case _TextScale():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TextScale value)?  $default,){
final _that = this;
switch (_that) {
case _TextScale() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enable,  double scale)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TextScale() when $default != null:
return $default(_that.enable,_that.scale);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enable,  double scale)  $default,) {final _that = this;
switch (_that) {
case _TextScale():
return $default(_that.enable,_that.scale);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enable,  double scale)?  $default,) {final _that = this;
switch (_that) {
case _TextScale() when $default != null:
return $default(_that.enable,_that.scale);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TextScale implements TextScale {
  const _TextScale({this.enable = false, this.scale = 1.0});
  factory _TextScale.fromJson(Map<String, dynamic> json) => _$TextScaleFromJson(json);

@override@JsonKey() final  bool enable;
@override@JsonKey() final  double scale;

/// Create a copy of TextScale
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TextScaleCopyWith<_TextScale> get copyWith => __$TextScaleCopyWithImpl<_TextScale>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TextScaleToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TextScale&&(identical(other.enable, enable) || other.enable == enable)&&(identical(other.scale, scale) || other.scale == scale));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,enable,scale);
}

@override
String toString() {
    return 'TextScale(enable: $enable, scale: $scale)';
}


}

/// @nodoc
abstract mixin class _$TextScaleCopyWith<$Res> implements $TextScaleCopyWith<$Res> {
  factory _$TextScaleCopyWith(_TextScale value, $Res Function(_TextScale) _then) = __$TextScaleCopyWithImpl;
@override @useResult
$Res call({
 bool enable, double scale
});




}
/// @nodoc
class __$TextScaleCopyWithImpl<$Res>
    implements _$TextScaleCopyWith<$Res> {
  __$TextScaleCopyWithImpl(this._self, this._then);

  final _TextScale _self;
  final $Res Function(_TextScale) _then;

/// Create a copy of TextScale
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enable = null,Object? scale = null,}) {
  return _then(_TextScale(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,scale: null == scale ? _self.scale : scale // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$ThemeProps {

 int? get primaryColor; List<int> get primaryColors; ThemeMode get themeMode;@JsonKey(readValue: _readColorStyle) ColorStyle get colorStyle;@JsonKey(unknownEnumValue: ColorContrast.standard) ColorContrast get contrast; bool get pureBlack; bool get sidebarBlur;@JsonKey(readValue: _readLiquidGlass) LiquidGlassMode get liquidGlass;@JsonKey(fromJson: WallpaperProps.safeFromJson) WallpaperProps get wallpaper; TextScale get textScale;@JsonKey(name: 'systemFontFamily') String? get fontFamily;
/// Create a copy of ThemeProps
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ThemePropsCopyWith<ThemeProps> get copyWith => _$ThemePropsCopyWithImpl<ThemeProps>(this as ThemeProps, _$identity);

  /// Serializes this ThemeProps to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ThemeProps;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ThemeProps&&(identical(other.primaryColor, _this.primaryColor) || other.primaryColor == _this.primaryColor)&&const DeepCollectionEquality().equals(other.primaryColors, _this.primaryColors)&&(identical(other.themeMode, _this.themeMode) || other.themeMode == _this.themeMode)&&(identical(other.colorStyle, _this.colorStyle) || other.colorStyle == _this.colorStyle)&&(identical(other.contrast, _this.contrast) || other.contrast == _this.contrast)&&(identical(other.pureBlack, _this.pureBlack) || other.pureBlack == _this.pureBlack)&&(identical(other.sidebarBlur, _this.sidebarBlur) || other.sidebarBlur == _this.sidebarBlur)&&(identical(other.liquidGlass, _this.liquidGlass) || other.liquidGlass == _this.liquidGlass)&&(identical(other.wallpaper, _this.wallpaper) || other.wallpaper == _this.wallpaper)&&(identical(other.textScale, _this.textScale) || other.textScale == _this.textScale)&&(identical(other.fontFamily, _this.fontFamily) || other.fontFamily == _this.fontFamily));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ThemeProps;
  return Object.hash(runtimeType,_this.primaryColor,const DeepCollectionEquality().hash(_this.primaryColors),_this.themeMode,_this.colorStyle,_this.contrast,_this.pureBlack,_this.sidebarBlur,_this.liquidGlass,_this.wallpaper,_this.textScale,_this.fontFamily);
}

@override
String toString() {
  final _this = this as ThemeProps;
  return 'ThemeProps(primaryColor: ${_this.primaryColor}, primaryColors: ${_this.primaryColors}, themeMode: ${_this.themeMode}, colorStyle: ${_this.colorStyle}, contrast: ${_this.contrast}, pureBlack: ${_this.pureBlack}, sidebarBlur: ${_this.sidebarBlur}, liquidGlass: ${_this.liquidGlass}, wallpaper: ${_this.wallpaper}, textScale: ${_this.textScale}, fontFamily: ${_this.fontFamily})';
}


}

/// @nodoc
abstract mixin class $ThemePropsCopyWith<$Res>  {
  factory $ThemePropsCopyWith(ThemeProps value, $Res Function(ThemeProps) _then) = _$ThemePropsCopyWithImpl;
@useResult
$Res call({
 int? primaryColor, List<int> primaryColors, ThemeMode themeMode,@JsonKey(readValue: _readColorStyle) ColorStyle colorStyle,@JsonKey(unknownEnumValue: ColorContrast.standard) ColorContrast contrast, bool pureBlack, bool sidebarBlur,@JsonKey(readValue: _readLiquidGlass) LiquidGlassMode liquidGlass,@JsonKey(fromJson: WallpaperProps.safeFromJson) WallpaperProps wallpaper, TextScale textScale,@JsonKey(name: 'systemFontFamily') String? fontFamily
});


$WallpaperPropsCopyWith<$Res> get wallpaper;$TextScaleCopyWith<$Res> get textScale;

}
/// @nodoc
class _$ThemePropsCopyWithImpl<$Res>
    implements $ThemePropsCopyWith<$Res> {
  _$ThemePropsCopyWithImpl(this._self, this._then);

  final ThemeProps _self;
  final $Res Function(ThemeProps) _then;

/// Create a copy of ThemeProps
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? primaryColor = freezed,Object? primaryColors = null,Object? themeMode = null,Object? colorStyle = null,Object? contrast = null,Object? pureBlack = null,Object? sidebarBlur = null,Object? liquidGlass = null,Object? wallpaper = null,Object? textScale = null,Object? fontFamily = freezed,}) {
  return _then(ThemeProps(
primaryColor: freezed == primaryColor ? _self.primaryColor : primaryColor // ignore: cast_nullable_to_non_nullable
as int?,primaryColors: null == primaryColors ? _self.primaryColors : primaryColors // ignore: cast_nullable_to_non_nullable
as List<int>,themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as ThemeMode,colorStyle: null == colorStyle ? _self.colorStyle : colorStyle // ignore: cast_nullable_to_non_nullable
as ColorStyle,contrast: null == contrast ? _self.contrast : contrast // ignore: cast_nullable_to_non_nullable
as ColorContrast,pureBlack: null == pureBlack ? _self.pureBlack : pureBlack // ignore: cast_nullable_to_non_nullable
as bool,sidebarBlur: null == sidebarBlur ? _self.sidebarBlur : sidebarBlur // ignore: cast_nullable_to_non_nullable
as bool,liquidGlass: null == liquidGlass ? _self.liquidGlass : liquidGlass // ignore: cast_nullable_to_non_nullable
as LiquidGlassMode,wallpaper: null == wallpaper ? _self.wallpaper : wallpaper // ignore: cast_nullable_to_non_nullable
as WallpaperProps,textScale: null == textScale ? _self.textScale : textScale // ignore: cast_nullable_to_non_nullable
as TextScale,fontFamily: freezed == fontFamily ? _self.fontFamily : fontFamily // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of ThemeProps
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WallpaperPropsCopyWith<$Res> get wallpaper {
  
  return $WallpaperPropsCopyWith<$Res>(_self.wallpaper, (value) {
    return _then(_self.copyWith(wallpaper: value));
  });
}/// Create a copy of ThemeProps
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TextScaleCopyWith<$Res> get textScale {
  
  return $TextScaleCopyWith<$Res>(_self.textScale, (value) {
    return _then(_self.copyWith(textScale: value));
  });
}
}


/// Adds pattern-matching-related methods to [ThemeProps].
extension ThemePropsPatterns on ThemeProps {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ThemeProps value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ThemeProps() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ThemeProps value)  $default,){
final _that = this;
switch (_that) {
case _ThemeProps():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ThemeProps value)?  $default,){
final _that = this;
switch (_that) {
case _ThemeProps() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? primaryColor,  List<int> primaryColors,  ThemeMode themeMode, @JsonKey(readValue: _readColorStyle)  ColorStyle colorStyle, @JsonKey(unknownEnumValue: ColorContrast.standard)  ColorContrast contrast,  bool pureBlack,  bool sidebarBlur, @JsonKey(readValue: _readLiquidGlass)  LiquidGlassMode liquidGlass, @JsonKey(fromJson: WallpaperProps.safeFromJson)  WallpaperProps wallpaper,  TextScale textScale, @JsonKey(name: 'systemFontFamily')  String? fontFamily)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ThemeProps() when $default != null:
return $default(_that.primaryColor,_that.primaryColors,_that.themeMode,_that.colorStyle,_that.contrast,_that.pureBlack,_that.sidebarBlur,_that.liquidGlass,_that.wallpaper,_that.textScale,_that.fontFamily);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? primaryColor,  List<int> primaryColors,  ThemeMode themeMode, @JsonKey(readValue: _readColorStyle)  ColorStyle colorStyle, @JsonKey(unknownEnumValue: ColorContrast.standard)  ColorContrast contrast,  bool pureBlack,  bool sidebarBlur, @JsonKey(readValue: _readLiquidGlass)  LiquidGlassMode liquidGlass, @JsonKey(fromJson: WallpaperProps.safeFromJson)  WallpaperProps wallpaper,  TextScale textScale, @JsonKey(name: 'systemFontFamily')  String? fontFamily)  $default,) {final _that = this;
switch (_that) {
case _ThemeProps():
return $default(_that.primaryColor,_that.primaryColors,_that.themeMode,_that.colorStyle,_that.contrast,_that.pureBlack,_that.sidebarBlur,_that.liquidGlass,_that.wallpaper,_that.textScale,_that.fontFamily);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? primaryColor,  List<int> primaryColors,  ThemeMode themeMode, @JsonKey(readValue: _readColorStyle)  ColorStyle colorStyle, @JsonKey(unknownEnumValue: ColorContrast.standard)  ColorContrast contrast,  bool pureBlack,  bool sidebarBlur, @JsonKey(readValue: _readLiquidGlass)  LiquidGlassMode liquidGlass, @JsonKey(fromJson: WallpaperProps.safeFromJson)  WallpaperProps wallpaper,  TextScale textScale, @JsonKey(name: 'systemFontFamily')  String? fontFamily)?  $default,) {final _that = this;
switch (_that) {
case _ThemeProps() when $default != null:
return $default(_that.primaryColor,_that.primaryColors,_that.themeMode,_that.colorStyle,_that.contrast,_that.pureBlack,_that.sidebarBlur,_that.liquidGlass,_that.wallpaper,_that.textScale,_that.fontFamily);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ThemeProps implements ThemeProps {
  const _ThemeProps({this.primaryColor,  List<int> primaryColors = defaultPrimaryColors, this.themeMode = ThemeMode.system, @JsonKey(readValue: _readColorStyle) this.colorStyle = ColorStyle.vivid, @JsonKey(unknownEnumValue: ColorContrast.standard) this.contrast = ColorContrast.standard, this.pureBlack = false, this.sidebarBlur = false, @JsonKey(readValue: _readLiquidGlass) this.liquidGlass = LiquidGlassMode.none, @JsonKey(fromJson: WallpaperProps.safeFromJson) this.wallpaper = const WallpaperProps(), this.textScale = const TextScale(), @JsonKey(name: 'systemFontFamily') this.fontFamily}): _primaryColors = primaryColors;
  factory _ThemeProps.fromJson(Map<String, dynamic> json) => _$ThemePropsFromJson(json);

@override final  int? primaryColor;
 final  List<int> _primaryColors;
@override@JsonKey() List<int> get primaryColors {
  if (_primaryColors is EqualUnmodifiableListView) return _primaryColors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_primaryColors);
}

@override@JsonKey() final  ThemeMode themeMode;
@override@JsonKey(readValue: _readColorStyle) final  ColorStyle colorStyle;
@override@JsonKey(unknownEnumValue: ColorContrast.standard) final  ColorContrast contrast;
@override@JsonKey() final  bool pureBlack;
@override@JsonKey() final  bool sidebarBlur;
@override@JsonKey(readValue: _readLiquidGlass) final  LiquidGlassMode liquidGlass;
@override@JsonKey(fromJson: WallpaperProps.safeFromJson) final  WallpaperProps wallpaper;
@override@JsonKey() final  TextScale textScale;
@override@JsonKey(name: 'systemFontFamily') final  String? fontFamily;

/// Create a copy of ThemeProps
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ThemePropsCopyWith<_ThemeProps> get copyWith => __$ThemePropsCopyWithImpl<_ThemeProps>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ThemePropsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ThemeProps&&(identical(other.primaryColor, primaryColor) || other.primaryColor == primaryColor)&&const DeepCollectionEquality().equals(other.primaryColors, _primaryColors)&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.colorStyle, colorStyle) || other.colorStyle == colorStyle)&&(identical(other.contrast, contrast) || other.contrast == contrast)&&(identical(other.pureBlack, pureBlack) || other.pureBlack == pureBlack)&&(identical(other.sidebarBlur, sidebarBlur) || other.sidebarBlur == sidebarBlur)&&(identical(other.liquidGlass, liquidGlass) || other.liquidGlass == liquidGlass)&&(identical(other.wallpaper, wallpaper) || other.wallpaper == wallpaper)&&(identical(other.textScale, textScale) || other.textScale == textScale)&&(identical(other.fontFamily, fontFamily) || other.fontFamily == fontFamily));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,primaryColor,const DeepCollectionEquality().hash(_primaryColors),themeMode,colorStyle,contrast,pureBlack,sidebarBlur,liquidGlass,wallpaper,textScale,fontFamily);
}

@override
String toString() {
    return 'ThemeProps(primaryColor: $primaryColor, primaryColors: $primaryColors, themeMode: $themeMode, colorStyle: $colorStyle, contrast: $contrast, pureBlack: $pureBlack, sidebarBlur: $sidebarBlur, liquidGlass: $liquidGlass, wallpaper: $wallpaper, textScale: $textScale, fontFamily: $fontFamily)';
}


}

/// @nodoc
abstract mixin class _$ThemePropsCopyWith<$Res> implements $ThemePropsCopyWith<$Res> {
  factory _$ThemePropsCopyWith(_ThemeProps value, $Res Function(_ThemeProps) _then) = __$ThemePropsCopyWithImpl;
@override @useResult
$Res call({
 int? primaryColor, List<int> primaryColors, ThemeMode themeMode,@JsonKey(readValue: _readColorStyle) ColorStyle colorStyle,@JsonKey(unknownEnumValue: ColorContrast.standard) ColorContrast contrast, bool pureBlack, bool sidebarBlur,@JsonKey(readValue: _readLiquidGlass) LiquidGlassMode liquidGlass,@JsonKey(fromJson: WallpaperProps.safeFromJson) WallpaperProps wallpaper, TextScale textScale,@JsonKey(name: 'systemFontFamily') String? fontFamily
});


@override $WallpaperPropsCopyWith<$Res> get wallpaper;@override $TextScaleCopyWith<$Res> get textScale;

}
/// @nodoc
class __$ThemePropsCopyWithImpl<$Res>
    implements _$ThemePropsCopyWith<$Res> {
  __$ThemePropsCopyWithImpl(this._self, this._then);

  final _ThemeProps _self;
  final $Res Function(_ThemeProps) _then;

/// Create a copy of ThemeProps
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? primaryColor = freezed,Object? primaryColors = null,Object? themeMode = null,Object? colorStyle = null,Object? contrast = null,Object? pureBlack = null,Object? sidebarBlur = null,Object? liquidGlass = null,Object? wallpaper = null,Object? textScale = null,Object? fontFamily = freezed,}) {
  return _then(_ThemeProps(
primaryColor: freezed == primaryColor ? _self.primaryColor : primaryColor // ignore: cast_nullable_to_non_nullable
as int?,primaryColors: null == primaryColors ? _self._primaryColors : primaryColors // ignore: cast_nullable_to_non_nullable
as List<int>,themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as ThemeMode,colorStyle: null == colorStyle ? _self.colorStyle : colorStyle // ignore: cast_nullable_to_non_nullable
as ColorStyle,contrast: null == contrast ? _self.contrast : contrast // ignore: cast_nullable_to_non_nullable
as ColorContrast,pureBlack: null == pureBlack ? _self.pureBlack : pureBlack // ignore: cast_nullable_to_non_nullable
as bool,sidebarBlur: null == sidebarBlur ? _self.sidebarBlur : sidebarBlur // ignore: cast_nullable_to_non_nullable
as bool,liquidGlass: null == liquidGlass ? _self.liquidGlass : liquidGlass // ignore: cast_nullable_to_non_nullable
as LiquidGlassMode,wallpaper: null == wallpaper ? _self.wallpaper : wallpaper // ignore: cast_nullable_to_non_nullable
as WallpaperProps,textScale: null == textScale ? _self.textScale : textScale // ignore: cast_nullable_to_non_nullable
as TextScale,fontFamily: freezed == fontFamily ? _self.fontFamily : fontFamily // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of ThemeProps
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WallpaperPropsCopyWith<$Res> get wallpaper {
  
  return $WallpaperPropsCopyWith<$Res>(_self.wallpaper, (value) {
    return _then(_self.copyWith(wallpaper: value));
  });
}/// Create a copy of ThemeProps
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TextScaleCopyWith<$Res> get textScale {
  
  return $TextScaleCopyWith<$Res>(_self.textScale, (value) {
    return _then(_self.copyWith(textScale: value));
  });
}
}


/// @nodoc
mixin _$Config {

 int? get currentProfileId; List<HotKeyAction> get hotKeyActions;@JsonKey(fromJson: AppSettingProps.safeFromJson) AppSettingProps get appSettingProps; DAVProps? get davProps; NetworkProps get networkProps; VpnProps get vpnProps;@JsonKey(fromJson: ThemeProps.safeFromJson) ThemeProps get themeProps; ProxiesStyleProps get proxiesStyleProps;@JsonKey(name: 'windowGeometry') WindowProps get windowProps; PatchClashConfig get patchClashConfig; List<String> get excludeSSIDs;/// The user's own routing profiles, shared by every subscription.
 Map<String, RcxUserProfile> get rcxProfiles;@JsonKey(fromJson: ProviderSettingsState.safeFromJson) ProviderSettingsState get providerSettings;
/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConfigCopyWith<Config> get copyWith => _$ConfigCopyWithImpl<Config>(this as Config, _$identity);

  /// Serializes this Config to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Config;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Config&&(identical(other.currentProfileId, _this.currentProfileId) || other.currentProfileId == _this.currentProfileId)&&const DeepCollectionEquality().equals(other.hotKeyActions, _this.hotKeyActions)&&(identical(other.appSettingProps, _this.appSettingProps) || other.appSettingProps == _this.appSettingProps)&&(identical(other.davProps, _this.davProps) || other.davProps == _this.davProps)&&(identical(other.networkProps, _this.networkProps) || other.networkProps == _this.networkProps)&&(identical(other.vpnProps, _this.vpnProps) || other.vpnProps == _this.vpnProps)&&(identical(other.themeProps, _this.themeProps) || other.themeProps == _this.themeProps)&&(identical(other.proxiesStyleProps, _this.proxiesStyleProps) || other.proxiesStyleProps == _this.proxiesStyleProps)&&(identical(other.windowProps, _this.windowProps) || other.windowProps == _this.windowProps)&&(identical(other.patchClashConfig, _this.patchClashConfig) || other.patchClashConfig == _this.patchClashConfig)&&const DeepCollectionEquality().equals(other.excludeSSIDs, _this.excludeSSIDs)&&const DeepCollectionEquality().equals(other.rcxProfiles, _this.rcxProfiles)&&(identical(other.providerSettings, _this.providerSettings) || other.providerSettings == _this.providerSettings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Config;
  return Object.hash(runtimeType,_this.currentProfileId,const DeepCollectionEquality().hash(_this.hotKeyActions),_this.appSettingProps,_this.davProps,_this.networkProps,_this.vpnProps,_this.themeProps,_this.proxiesStyleProps,_this.windowProps,_this.patchClashConfig,const DeepCollectionEquality().hash(_this.excludeSSIDs),const DeepCollectionEquality().hash(_this.rcxProfiles),_this.providerSettings);
}

@override
String toString() {
  final _this = this as Config;
  return 'Config(currentProfileId: ${_this.currentProfileId}, hotKeyActions: ${_this.hotKeyActions}, appSettingProps: ${_this.appSettingProps}, davProps: ${_this.davProps}, networkProps: ${_this.networkProps}, vpnProps: ${_this.vpnProps}, themeProps: ${_this.themeProps}, proxiesStyleProps: ${_this.proxiesStyleProps}, windowProps: ${_this.windowProps}, patchClashConfig: ${_this.patchClashConfig}, excludeSSIDs: ${_this.excludeSSIDs}, rcxProfiles: ${_this.rcxProfiles}, providerSettings: ${_this.providerSettings})';
}


}

/// @nodoc
abstract mixin class $ConfigCopyWith<$Res>  {
  factory $ConfigCopyWith(Config value, $Res Function(Config) _then) = _$ConfigCopyWithImpl;
@useResult
$Res call({
 int? currentProfileId, List<HotKeyAction> hotKeyActions,@JsonKey(fromJson: AppSettingProps.safeFromJson) AppSettingProps appSettingProps, DAVProps? davProps, NetworkProps networkProps, VpnProps vpnProps,@JsonKey(fromJson: ThemeProps.safeFromJson) ThemeProps themeProps, ProxiesStyleProps proxiesStyleProps,@JsonKey(name: 'windowGeometry') WindowProps windowProps, PatchClashConfig patchClashConfig, List<String> excludeSSIDs, Map<String, RcxUserProfile> rcxProfiles,@JsonKey(fromJson: ProviderSettingsState.safeFromJson) ProviderSettingsState providerSettings
});


$AppSettingPropsCopyWith<$Res> get appSettingProps;$DAVPropsCopyWith<$Res>? get davProps;$NetworkPropsCopyWith<$Res> get networkProps;$VpnPropsCopyWith<$Res> get vpnProps;$ThemePropsCopyWith<$Res> get themeProps;$ProxiesStylePropsCopyWith<$Res> get proxiesStyleProps;$WindowPropsCopyWith<$Res> get windowProps;$PatchClashConfigCopyWith<$Res> get patchClashConfig;$ProviderSettingsStateCopyWith<$Res> get providerSettings;

}
/// @nodoc
class _$ConfigCopyWithImpl<$Res>
    implements $ConfigCopyWith<$Res> {
  _$ConfigCopyWithImpl(this._self, this._then);

  final Config _self;
  final $Res Function(Config) _then;

/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentProfileId = freezed,Object? hotKeyActions = null,Object? appSettingProps = null,Object? davProps = freezed,Object? networkProps = null,Object? vpnProps = null,Object? themeProps = null,Object? proxiesStyleProps = null,Object? windowProps = null,Object? patchClashConfig = null,Object? excludeSSIDs = null,Object? rcxProfiles = null,Object? providerSettings = null,}) {
  return _then(Config(
currentProfileId: freezed == currentProfileId ? _self.currentProfileId : currentProfileId // ignore: cast_nullable_to_non_nullable
as int?,hotKeyActions: null == hotKeyActions ? _self.hotKeyActions : hotKeyActions // ignore: cast_nullable_to_non_nullable
as List<HotKeyAction>,appSettingProps: null == appSettingProps ? _self.appSettingProps : appSettingProps // ignore: cast_nullable_to_non_nullable
as AppSettingProps,davProps: freezed == davProps ? _self.davProps : davProps // ignore: cast_nullable_to_non_nullable
as DAVProps?,networkProps: null == networkProps ? _self.networkProps : networkProps // ignore: cast_nullable_to_non_nullable
as NetworkProps,vpnProps: null == vpnProps ? _self.vpnProps : vpnProps // ignore: cast_nullable_to_non_nullable
as VpnProps,themeProps: null == themeProps ? _self.themeProps : themeProps // ignore: cast_nullable_to_non_nullable
as ThemeProps,proxiesStyleProps: null == proxiesStyleProps ? _self.proxiesStyleProps : proxiesStyleProps // ignore: cast_nullable_to_non_nullable
as ProxiesStyleProps,windowProps: null == windowProps ? _self.windowProps : windowProps // ignore: cast_nullable_to_non_nullable
as WindowProps,patchClashConfig: null == patchClashConfig ? _self.patchClashConfig : patchClashConfig // ignore: cast_nullable_to_non_nullable
as PatchClashConfig,excludeSSIDs: null == excludeSSIDs ? _self.excludeSSIDs : excludeSSIDs // ignore: cast_nullable_to_non_nullable
as List<String>,rcxProfiles: null == rcxProfiles ? _self.rcxProfiles : rcxProfiles // ignore: cast_nullable_to_non_nullable
as Map<String, RcxUserProfile>,providerSettings: null == providerSettings ? _self.providerSettings : providerSettings // ignore: cast_nullable_to_non_nullable
as ProviderSettingsState,
  ));
}
/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppSettingPropsCopyWith<$Res> get appSettingProps {
  
  return $AppSettingPropsCopyWith<$Res>(_self.appSettingProps, (value) {
    return _then(_self.copyWith(appSettingProps: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DAVPropsCopyWith<$Res>? get davProps {
    if (_self.davProps == null) {
    return null;
  }

  return $DAVPropsCopyWith<$Res>(_self.davProps!, (value) {
    return _then(_self.copyWith(davProps: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NetworkPropsCopyWith<$Res> get networkProps {
  
  return $NetworkPropsCopyWith<$Res>(_self.networkProps, (value) {
    return _then(_self.copyWith(networkProps: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VpnPropsCopyWith<$Res> get vpnProps {
  
  return $VpnPropsCopyWith<$Res>(_self.vpnProps, (value) {
    return _then(_self.copyWith(vpnProps: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ThemePropsCopyWith<$Res> get themeProps {
  
  return $ThemePropsCopyWith<$Res>(_self.themeProps, (value) {
    return _then(_self.copyWith(themeProps: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProxiesStylePropsCopyWith<$Res> get proxiesStyleProps {
  
  return $ProxiesStylePropsCopyWith<$Res>(_self.proxiesStyleProps, (value) {
    return _then(_self.copyWith(proxiesStyleProps: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WindowPropsCopyWith<$Res> get windowProps {
  
  return $WindowPropsCopyWith<$Res>(_self.windowProps, (value) {
    return _then(_self.copyWith(windowProps: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PatchClashConfigCopyWith<$Res> get patchClashConfig {
  
  return $PatchClashConfigCopyWith<$Res>(_self.patchClashConfig, (value) {
    return _then(_self.copyWith(patchClashConfig: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProviderSettingsStateCopyWith<$Res> get providerSettings {
  
  return $ProviderSettingsStateCopyWith<$Res>(_self.providerSettings, (value) {
    return _then(_self.copyWith(providerSettings: value));
  });
}
}


/// Adds pattern-matching-related methods to [Config].
extension ConfigPatterns on Config {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Config value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Config() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Config value)  $default,){
final _that = this;
switch (_that) {
case _Config():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Config value)?  $default,){
final _that = this;
switch (_that) {
case _Config() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? currentProfileId,  List<HotKeyAction> hotKeyActions, @JsonKey(fromJson: AppSettingProps.safeFromJson)  AppSettingProps appSettingProps,  DAVProps? davProps,  NetworkProps networkProps,  VpnProps vpnProps, @JsonKey(fromJson: ThemeProps.safeFromJson)  ThemeProps themeProps,  ProxiesStyleProps proxiesStyleProps, @JsonKey(name: 'windowGeometry')  WindowProps windowProps,  PatchClashConfig patchClashConfig,  List<String> excludeSSIDs,  Map<String, RcxUserProfile> rcxProfiles, @JsonKey(fromJson: ProviderSettingsState.safeFromJson)  ProviderSettingsState providerSettings)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Config() when $default != null:
return $default(_that.currentProfileId,_that.hotKeyActions,_that.appSettingProps,_that.davProps,_that.networkProps,_that.vpnProps,_that.themeProps,_that.proxiesStyleProps,_that.windowProps,_that.patchClashConfig,_that.excludeSSIDs,_that.rcxProfiles,_that.providerSettings);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? currentProfileId,  List<HotKeyAction> hotKeyActions, @JsonKey(fromJson: AppSettingProps.safeFromJson)  AppSettingProps appSettingProps,  DAVProps? davProps,  NetworkProps networkProps,  VpnProps vpnProps, @JsonKey(fromJson: ThemeProps.safeFromJson)  ThemeProps themeProps,  ProxiesStyleProps proxiesStyleProps, @JsonKey(name: 'windowGeometry')  WindowProps windowProps,  PatchClashConfig patchClashConfig,  List<String> excludeSSIDs,  Map<String, RcxUserProfile> rcxProfiles, @JsonKey(fromJson: ProviderSettingsState.safeFromJson)  ProviderSettingsState providerSettings)  $default,) {final _that = this;
switch (_that) {
case _Config():
return $default(_that.currentProfileId,_that.hotKeyActions,_that.appSettingProps,_that.davProps,_that.networkProps,_that.vpnProps,_that.themeProps,_that.proxiesStyleProps,_that.windowProps,_that.patchClashConfig,_that.excludeSSIDs,_that.rcxProfiles,_that.providerSettings);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? currentProfileId,  List<HotKeyAction> hotKeyActions, @JsonKey(fromJson: AppSettingProps.safeFromJson)  AppSettingProps appSettingProps,  DAVProps? davProps,  NetworkProps networkProps,  VpnProps vpnProps, @JsonKey(fromJson: ThemeProps.safeFromJson)  ThemeProps themeProps,  ProxiesStyleProps proxiesStyleProps, @JsonKey(name: 'windowGeometry')  WindowProps windowProps,  PatchClashConfig patchClashConfig,  List<String> excludeSSIDs,  Map<String, RcxUserProfile> rcxProfiles, @JsonKey(fromJson: ProviderSettingsState.safeFromJson)  ProviderSettingsState providerSettings)?  $default,) {final _that = this;
switch (_that) {
case _Config() when $default != null:
return $default(_that.currentProfileId,_that.hotKeyActions,_that.appSettingProps,_that.davProps,_that.networkProps,_that.vpnProps,_that.themeProps,_that.proxiesStyleProps,_that.windowProps,_that.patchClashConfig,_that.excludeSSIDs,_that.rcxProfiles,_that.providerSettings);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Config implements Config {
  const _Config({this.currentProfileId,  List<HotKeyAction> hotKeyActions = const [], @JsonKey(fromJson: AppSettingProps.safeFromJson) this.appSettingProps = defaultAppSettingProps, this.davProps, this.networkProps = defaultNetworkProps, this.vpnProps = defaultVpnProps, @JsonKey(fromJson: ThemeProps.safeFromJson) required this.themeProps, this.proxiesStyleProps = defaultProxiesStyleProps, @JsonKey(name: 'windowGeometry') this.windowProps = defaultWindowProps, this.patchClashConfig = defaultClashConfig,  List<String> excludeSSIDs = const [],  Map<String, RcxUserProfile> rcxProfiles = const {}, @JsonKey(fromJson: ProviderSettingsState.safeFromJson) this.providerSettings = const ProviderSettingsState()}): _hotKeyActions = hotKeyActions,_excludeSSIDs = excludeSSIDs,_rcxProfiles = rcxProfiles;
  factory _Config.fromJson(Map<String, dynamic> json) => _$ConfigFromJson(json);

@override final  int? currentProfileId;
 final  List<HotKeyAction> _hotKeyActions;
@override@JsonKey() List<HotKeyAction> get hotKeyActions {
  if (_hotKeyActions is EqualUnmodifiableListView) return _hotKeyActions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_hotKeyActions);
}

@override@JsonKey(fromJson: AppSettingProps.safeFromJson) final  AppSettingProps appSettingProps;
@override final  DAVProps? davProps;
@override@JsonKey() final  NetworkProps networkProps;
@override@JsonKey() final  VpnProps vpnProps;
@override@JsonKey(fromJson: ThemeProps.safeFromJson) final  ThemeProps themeProps;
@override@JsonKey() final  ProxiesStyleProps proxiesStyleProps;
@override@JsonKey(name: 'windowGeometry') final  WindowProps windowProps;
@override@JsonKey() final  PatchClashConfig patchClashConfig;
 final  List<String> _excludeSSIDs;
@override@JsonKey() List<String> get excludeSSIDs {
  if (_excludeSSIDs is EqualUnmodifiableListView) return _excludeSSIDs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_excludeSSIDs);
}

/// The user's own routing profiles, shared by every subscription.
 final  Map<String, RcxUserProfile> _rcxProfiles;
/// The user's own routing profiles, shared by every subscription.
@override@JsonKey() Map<String, RcxUserProfile> get rcxProfiles {
  if (_rcxProfiles is EqualUnmodifiableMapView) return _rcxProfiles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_rcxProfiles);
}

@override@JsonKey(fromJson: ProviderSettingsState.safeFromJson) final  ProviderSettingsState providerSettings;

/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConfigCopyWith<_Config> get copyWith => __$ConfigCopyWithImpl<_Config>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConfigToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Config&&(identical(other.currentProfileId, currentProfileId) || other.currentProfileId == currentProfileId)&&const DeepCollectionEquality().equals(other.hotKeyActions, _hotKeyActions)&&(identical(other.appSettingProps, appSettingProps) || other.appSettingProps == appSettingProps)&&(identical(other.davProps, davProps) || other.davProps == davProps)&&(identical(other.networkProps, networkProps) || other.networkProps == networkProps)&&(identical(other.vpnProps, vpnProps) || other.vpnProps == vpnProps)&&(identical(other.themeProps, themeProps) || other.themeProps == themeProps)&&(identical(other.proxiesStyleProps, proxiesStyleProps) || other.proxiesStyleProps == proxiesStyleProps)&&(identical(other.windowProps, windowProps) || other.windowProps == windowProps)&&(identical(other.patchClashConfig, patchClashConfig) || other.patchClashConfig == patchClashConfig)&&const DeepCollectionEquality().equals(other.excludeSSIDs, _excludeSSIDs)&&const DeepCollectionEquality().equals(other.rcxProfiles, _rcxProfiles)&&(identical(other.providerSettings, providerSettings) || other.providerSettings == providerSettings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,currentProfileId,const DeepCollectionEquality().hash(_hotKeyActions),appSettingProps,davProps,networkProps,vpnProps,themeProps,proxiesStyleProps,windowProps,patchClashConfig,const DeepCollectionEquality().hash(_excludeSSIDs),const DeepCollectionEquality().hash(_rcxProfiles),providerSettings);
}

@override
String toString() {
    return 'Config(currentProfileId: $currentProfileId, hotKeyActions: $hotKeyActions, appSettingProps: $appSettingProps, davProps: $davProps, networkProps: $networkProps, vpnProps: $vpnProps, themeProps: $themeProps, proxiesStyleProps: $proxiesStyleProps, windowProps: $windowProps, patchClashConfig: $patchClashConfig, excludeSSIDs: $excludeSSIDs, rcxProfiles: $rcxProfiles, providerSettings: $providerSettings)';
}


}

/// @nodoc
abstract mixin class _$ConfigCopyWith<$Res> implements $ConfigCopyWith<$Res> {
  factory _$ConfigCopyWith(_Config value, $Res Function(_Config) _then) = __$ConfigCopyWithImpl;
@override @useResult
$Res call({
 int? currentProfileId, List<HotKeyAction> hotKeyActions,@JsonKey(fromJson: AppSettingProps.safeFromJson) AppSettingProps appSettingProps, DAVProps? davProps, NetworkProps networkProps, VpnProps vpnProps,@JsonKey(fromJson: ThemeProps.safeFromJson) ThemeProps themeProps, ProxiesStyleProps proxiesStyleProps,@JsonKey(name: 'windowGeometry') WindowProps windowProps, PatchClashConfig patchClashConfig, List<String> excludeSSIDs, Map<String, RcxUserProfile> rcxProfiles,@JsonKey(fromJson: ProviderSettingsState.safeFromJson) ProviderSettingsState providerSettings
});


@override $AppSettingPropsCopyWith<$Res> get appSettingProps;@override $DAVPropsCopyWith<$Res>? get davProps;@override $NetworkPropsCopyWith<$Res> get networkProps;@override $VpnPropsCopyWith<$Res> get vpnProps;@override $ThemePropsCopyWith<$Res> get themeProps;@override $ProxiesStylePropsCopyWith<$Res> get proxiesStyleProps;@override $WindowPropsCopyWith<$Res> get windowProps;@override $PatchClashConfigCopyWith<$Res> get patchClashConfig;@override $ProviderSettingsStateCopyWith<$Res> get providerSettings;

}
/// @nodoc
class __$ConfigCopyWithImpl<$Res>
    implements _$ConfigCopyWith<$Res> {
  __$ConfigCopyWithImpl(this._self, this._then);

  final _Config _self;
  final $Res Function(_Config) _then;

/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentProfileId = freezed,Object? hotKeyActions = null,Object? appSettingProps = null,Object? davProps = freezed,Object? networkProps = null,Object? vpnProps = null,Object? themeProps = null,Object? proxiesStyleProps = null,Object? windowProps = null,Object? patchClashConfig = null,Object? excludeSSIDs = null,Object? rcxProfiles = null,Object? providerSettings = null,}) {
  return _then(_Config(
currentProfileId: freezed == currentProfileId ? _self.currentProfileId : currentProfileId // ignore: cast_nullable_to_non_nullable
as int?,hotKeyActions: null == hotKeyActions ? _self._hotKeyActions : hotKeyActions // ignore: cast_nullable_to_non_nullable
as List<HotKeyAction>,appSettingProps: null == appSettingProps ? _self.appSettingProps : appSettingProps // ignore: cast_nullable_to_non_nullable
as AppSettingProps,davProps: freezed == davProps ? _self.davProps : davProps // ignore: cast_nullable_to_non_nullable
as DAVProps?,networkProps: null == networkProps ? _self.networkProps : networkProps // ignore: cast_nullable_to_non_nullable
as NetworkProps,vpnProps: null == vpnProps ? _self.vpnProps : vpnProps // ignore: cast_nullable_to_non_nullable
as VpnProps,themeProps: null == themeProps ? _self.themeProps : themeProps // ignore: cast_nullable_to_non_nullable
as ThemeProps,proxiesStyleProps: null == proxiesStyleProps ? _self.proxiesStyleProps : proxiesStyleProps // ignore: cast_nullable_to_non_nullable
as ProxiesStyleProps,windowProps: null == windowProps ? _self.windowProps : windowProps // ignore: cast_nullable_to_non_nullable
as WindowProps,patchClashConfig: null == patchClashConfig ? _self.patchClashConfig : patchClashConfig // ignore: cast_nullable_to_non_nullable
as PatchClashConfig,excludeSSIDs: null == excludeSSIDs ? _self._excludeSSIDs : excludeSSIDs // ignore: cast_nullable_to_non_nullable
as List<String>,rcxProfiles: null == rcxProfiles ? _self._rcxProfiles : rcxProfiles // ignore: cast_nullable_to_non_nullable
as Map<String, RcxUserProfile>,providerSettings: null == providerSettings ? _self.providerSettings : providerSettings // ignore: cast_nullable_to_non_nullable
as ProviderSettingsState,
  ));
}

/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppSettingPropsCopyWith<$Res> get appSettingProps {
  
  return $AppSettingPropsCopyWith<$Res>(_self.appSettingProps, (value) {
    return _then(_self.copyWith(appSettingProps: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DAVPropsCopyWith<$Res>? get davProps {
    if (_self.davProps == null) {
    return null;
  }

  return $DAVPropsCopyWith<$Res>(_self.davProps!, (value) {
    return _then(_self.copyWith(davProps: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NetworkPropsCopyWith<$Res> get networkProps {
  
  return $NetworkPropsCopyWith<$Res>(_self.networkProps, (value) {
    return _then(_self.copyWith(networkProps: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VpnPropsCopyWith<$Res> get vpnProps {
  
  return $VpnPropsCopyWith<$Res>(_self.vpnProps, (value) {
    return _then(_self.copyWith(vpnProps: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ThemePropsCopyWith<$Res> get themeProps {
  
  return $ThemePropsCopyWith<$Res>(_self.themeProps, (value) {
    return _then(_self.copyWith(themeProps: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProxiesStylePropsCopyWith<$Res> get proxiesStyleProps {
  
  return $ProxiesStylePropsCopyWith<$Res>(_self.proxiesStyleProps, (value) {
    return _then(_self.copyWith(proxiesStyleProps: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WindowPropsCopyWith<$Res> get windowProps {
  
  return $WindowPropsCopyWith<$Res>(_self.windowProps, (value) {
    return _then(_self.copyWith(windowProps: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PatchClashConfigCopyWith<$Res> get patchClashConfig {
  
  return $PatchClashConfigCopyWith<$Res>(_self.patchClashConfig, (value) {
    return _then(_self.copyWith(patchClashConfig: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProviderSettingsStateCopyWith<$Res> get providerSettings {
  
  return $ProviderSettingsStateCopyWith<$Res>(_self.providerSettings, (value) {
    return _then(_self.copyWith(providerSettings: value));
  });
}
}

// dart format on
