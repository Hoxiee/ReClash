import 'package:dio/dio.dart';
import 'package:reclash/common/exception.dart';
import 'package:reclash/common/incy_links.dart';
import 'package:reclash/core/desktop/launch_policy.dart';
import 'package:reclash/core/method.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/profile.dart';
import 'package:material_ui/material_ui.dart';

final currentAppLocalizations = AppLocalizations.current;

final fallbackMaterialLocalizationsDelegates = [
  for (final delegate in GlobalMaterialLocalizations.delegates)
    FallbackLocalizationsDelegate(delegate),
];

class FallbackLocalizationsDelegate extends LocalizationsDelegate<dynamic> {
  const FallbackLocalizationsDelegate(this.delegate);

  final LocalizationsDelegate<dynamic> delegate;

  @override
  Type get type => delegate.type;

  @override
  bool isSupported(Locale locale) => !delegate.isSupported(locale);

  @override
  Future<dynamic> load(Locale locale) => delegate.load(const Locale('en'));

  @override
  bool shouldReload(FallbackLocalizationsDelegate old) => false;
}

String? networkErrorMessage(Object error, AppLocalizations appLocalizations) {
  if (error case CoreMethodException(:final code)) {
    return switch (code) {
      'request_bad_response' => appLocalizations.networkException,
      'request_error' => appLocalizations.unknownNetworkError,
      _ => null,
    };
  }
  if (error is DioException) {
    return error.type == DioExceptionType.badResponse
        ? appLocalizations.networkException
        : appLocalizations.unknownNetworkError;
  }
  return null;
}

String? coreLaunchBlockedMessage(
  Object error,
  AppLocalizations appLocalizations,
) {
  if (!isPolicyBlockedLaunch(error)) {
    return null;
  }
  return switch (smartAppControlStateReader()) {
    SmartAppControlState.on || SmartAppControlState.evaluation =>
      appLocalizations.coreBlockedBySmartAppControlTip,
    _ => appLocalizations.coreBlockedByPolicyTip(launchOsError(error)!),
  };
}

String profileImportFailureMessage(
  ProfileImportFailure failure,
  AppLocalizations appLocalizations,
) => switch (failure) {
  ProfileImportFailure.invalidUrl =>
    appLocalizations.profileUrlInvalidValidationDesc,
  ProfileImportFailure.invalidQrCode =>
    appLocalizations.pleaseUploadValidQrcode,
  ProfileImportFailure.invalidConfig =>
    appLocalizations.profileImportInvalidConfig,
  ProfileImportFailure.fetchRejected => appLocalizations.networkException,
  ProfileImportFailure.fetchFailed => appLocalizations.unknownNetworkError,
  ProfileImportFailure.emptyResponse =>
    appLocalizations.profileImportEmptyResponse,
  ProfileImportFailure.fileReadFailed =>
    appLocalizations.profileImportFileReadFailed,
  ProfileImportFailure.unexpected => appLocalizations.profileImportFailed,
};

String profileImportFormatLabel(
  ProfileImportFormat format,
  AppLocalizations appLocalizations,
) => switch (format) {
  ProfileImportFormat.clash => appLocalizations.profileImportFormatClash,
  ProfileImportFormat.shareLinks => appLocalizations.profileImportFormatLinks,
  ProfileImportFormat.xray => appLocalizations.profileImportFormatXray,
  ProfileImportFormat.singbox => appLocalizations.profileImportFormatSingbox,
  ProfileImportFormat.wireguard =>
    appLocalizations.profileImportFormatWireguard,
};

String subscriptionClientLabel(
  SubscriptionClient client,
  AppLocalizations appLocalizations,
) => switch (client) {
  SubscriptionClient.auto => appLocalizations.subscriptionClientAuto,
  SubscriptionClient.clashMeta => appLocalizations.subscriptionClientClashMeta,
  SubscriptionClient.clash => appLocalizations.subscriptionClientClash,
  SubscriptionClient.happ => appLocalizations.subscriptionClientHapp,
  SubscriptionClient.incy => appLocalizations.subscriptionClientIncy,
  SubscriptionClient.singbox => appLocalizations.subscriptionClientSingbox,
  SubscriptionClient.v2rayng => appLocalizations.subscriptionClientV2rayNG,
  SubscriptionClient.custom => appLocalizations.subscriptionClientCustom,
};

String incyLinkErrorMessage(
  IncyLinkException _,
  AppLocalizations appLocalizations,
) => appLocalizations.profileImportUnsupportedLink;

String userFacingErrorMessage(Object error, AppLocalizations appLocalizations) {
  return networkErrorMessage(error, appLocalizations) ??
      coreLaunchBlockedMessage(error, appLocalizations) ??
      switch (error) {
        CoreMethodException(:final message) => message,
        _ => error.toString(),
      };
}

Locale? getLocaleForString(String? localString) {
  if (localString == null) return null;
  final localSplit = localString.split('_');
  if (localSplit.length == 1) {
    return Locale(localSplit[0]);
  }
  if (localSplit.length == 2) {
    return Locale(localSplit[0], localSplit[1]);
  }
  if (localSplit.length == 3) {
    return Locale.fromSubtags(
      languageCode: localSplit[0],
      scriptCode: localSplit[1],
      countryCode: localSplit[2],
    );
  }
  return null;
}
