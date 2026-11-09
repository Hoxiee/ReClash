import 'package:reclash/common/constant.dart';
import 'package:reclash/common/exception.dart';
import 'package:reclash/common/network_error.dart';
import 'package:reclash/common/url_scheme.dart';
import 'package:reclash/core/desktop/launch_policy.dart';
import 'package:reclash/core/desktop/privilege.dart';
import 'package:reclash/core/desktop/model.dart';
import 'package:reclash/core/desktop/windows_launcher.dart';
import 'package:reclash/core/desktop/macos_helper.dart';
import 'package:reclash/core/method.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/profile.dart';
import 'package:reclash/subscriptions/compatibility/policy.dart';
import 'package:reclash/subscriptions/transport/transport.dart';
import 'package:material_ui/material_ui.dart';

export 'package:reclash/common/ui_localizations.dart';

final currentAppLocalizations = AppLocalizations.current;

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

String userFacingErrorMessage(Object error, AppLocalizations appLocalizations) {
  return (error is UrlSchemeException
          ? urlSchemeErrorMessage(error.issue, appLocalizations)
          : null) ??
      (error is SubscriptionException
          ? subscriptionFailureMessage(error, appLocalizations)
          : null) ??
      networkErrorMessage(error, appLocalizations) ??
      coreLaunchBlockedMessage(error, appLocalizations) ??
      desktopPrivilegeErrorMessage(error, appLocalizations) ??
      switch (error) {
        AgeSecretKeyRequiredException() =>
          appLocalizations.ageSecretKeyRequiredTip,
        SubscriptionUpdateRejected(:final reason) =>
          subscriptionRetryReasonMessage(reason, appLocalizations),
        CoreMethodException(code: 'rule_set_empty') =>
          appLocalizations.ruleSetEmptyTip,
        CoreMethodException(code: 'rule_set_mixed') =>
          appLocalizations.ruleSetMixedTip,
        CoreMethodException(code: 'rule_set_invalid') =>
          appLocalizations.ruleSetInvalidTip,
        CoreMethodException(:final message) => message,
        _ => error.toString(),
      };
}

String subscriptionFailureMessage(
  SubscriptionException error,
  AppLocalizations l10n,
) => switch (error.failure) {
  SubscriptionFailure.cancelled ||
  SubscriptionFailure.superseded => l10n.subscriptionCompatibilitySuperseded,
  SubscriptionFailure.timeout => l10n.subscriptionCompatibilityTimeout,
  SubscriptionFailure.transport => l10n.subscriptionCompatibilityTransport,
  SubscriptionFailure.tls => l10n.networkTlsError,
  SubscriptionFailure.unauthorized =>
    l10n.subscriptionCompatibilityAuthorization,
  SubscriptionFailure.deviceRequired => l10n.subscriptionDeviceRequired,
  SubscriptionFailure.deviceLimit => l10n.subscriptionDeviceLimit,
  SubscriptionFailure.rateLimited => l10n.subscriptionCompatibilityRateLimited,
  SubscriptionFailure.http when error.status != null && error.status! >= 500 =>
    l10n.networkServerError(error.status!),
  SubscriptionFailure.http when error.status != null =>
    l10n.networkBadResponseError(error.status!),
  SubscriptionFailure.http => l10n.subscriptionCompatibilityCheckFailed,
  SubscriptionFailure.redirect ||
  SubscriptionFailure.oversized ||
  SubscriptionFailure.invalid ||
  SubscriptionFailure.empty => l10n.subscriptionCompatibilityCheckFailed,
};

String subscriptionRetryReasonMessage(
  SubscriptionRetryReason reason,
  AppLocalizations l10n,
) => switch (reason) {
  SubscriptionRetryReason.transport => l10n.subscriptionCompatibilityTransport,
  SubscriptionRetryReason.tls => l10n.networkTlsError,
  SubscriptionRetryReason.timeout => l10n.subscriptionCompatibilityTimeout,
  SubscriptionRetryReason.cancelled => l10n.subscriptionCompatibilitySuperseded,
  SubscriptionRetryReason.unauthorized || SubscriptionRetryReason.forbidden =>
    l10n.subscriptionCompatibilityAuthorization,
  SubscriptionRetryReason.rateLimited =>
    l10n.subscriptionCompatibilityRateLimited,
  SubscriptionRetryReason.deviceConsentRequired =>
    l10n.subscriptionDeviceRequired,
  SubscriptionRetryReason.deviceLimitReached => l10n.subscriptionDeviceLimit,
  SubscriptionRetryReason.unsupportedMediaType ||
  SubscriptionRetryReason.incompatibleResponse ||
  SubscriptionRetryReason.invalidResponse =>
    l10n.subscriptionCompatibilityCheckFailed,
};

String delayFailureText(int delay, AppLocalizations appLocalizations) {
  return delay == delayTimedOutValue
      ? appLocalizations.timeout
      : appLocalizations.delayFailed;
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

String? desktopPrivilegeErrorMessage(Object error, AppLocalizations l10n) {
  final code = switch (error) {
    DesktopCoreFailure(:final cause) when cause != null =>
      _desktopPrivilegeCode(cause) ?? error.code,
    DesktopCoreFailure(:final code) => code,
    _ => _desktopPrivilegeCode(error),
  }?.toLowerCase();
  if (code == null) return null;
  if (code.contains('cancelled')) return l10n.desktopAuthorizationCancelled;
  if (code.contains('requires_approval') || code.contains('requiresapproval')) {
    return l10n.desktopHelperApprovalRequired;
  }
  if (code.contains('sign') ||
      code.contains('team') ||
      code.contains('requirement')) {
    return l10n.desktopSigningRequired;
  }
  if (code.contains('hash') ||
      code.contains('bundle_invalid') ||
      code.contains('bundleinvalid') ||
      code.contains('manifest')) {
    return l10n.desktopBundleInvalid;
  }
  if (code.contains('agentunavailable') || code.contains('pkexecunavailable')) {
    return l10n.desktopAuthorizationAgentUnavailable;
  }
  if (code.contains('denied')) return l10n.desktopAuthorizationDenied;
  if (code.contains('authorization_timeout')) {
    return l10n.desktopAuthorizationTimeout;
  }
  if (code.contains('pending') ||
      code.contains('stop_failed') ||
      code.contains('stopfailed')) {
    return l10n.desktopLaunchPending;
  }
  if (code.contains('authorization_required')) {
    return l10n.desktopAuthorizationRequired;
  }
  if (code.contains('tun_not_ready')) return l10n.desktopTunNotReady;
  if (code == 'linux_registrationconflict') {
    return l10n.desktopHelperRegistrationConflict;
  }
  if (code == 'linux_systemdfailed') return l10n.desktopHelperSystemdFailed;
  if (code == 'linux_protocolmismatch') {
    return l10n.desktopHelperProtocolMismatch;
  }
  if (code == 'linux_systemdunavailable') {
    return l10n.desktopHelperSystemdRequired;
  }
  if (code == 'linux_installbusy') return l10n.desktopLaunchPending;
  if (code.contains('linux_') ||
      code.contains('notready') ||
      code.contains('notregistered') ||
      code.contains('notfound') ||
      code.contains('helper_unavailable')) {
    return l10n.desktopHelperUnavailable;
  }
  if (code.startsWith('windows_') ||
      code.startsWith('macos_') ||
      code.contains('bootstrap') ||
      code.contains('helperresponseinvalid')) {
    return l10n.desktopBootstrapFailed;
  }
  return null;
}

String? _desktopPrivilegeCode(Object error) => switch (error) {
  DesktopPrivilegeException(:final code) => code,
  WindowsLaunchException(:final detail) => detail,
  MacOSHelperException(:final code) => code,
  DesktopCoreFailure(:final cause) when cause != null => _desktopPrivilegeCode(
    cause,
  ),
  _ => null,
};

String urlSchemeErrorMessage(UrlSchemeIssue issue, AppLocalizations l) =>
    switch (issue) {
      UrlSchemeIssue.invalidLink => l.urlSchemeInvalidLink,
      UrlSchemeIssue.unknownCommand => l.urlSchemeUnknownCommand,
      UrlSchemeIssue.missingPayload => l.urlSchemeMissingPayload,
      UrlSchemeIssue.invalidUrl => l.urlSchemeInvalidUrl,
      UrlSchemeIssue.invalidName => l.urlSchemeInvalidName,
      UrlSchemeIssue.invalidBase64 => l.urlSchemeInvalidBase64,
      UrlSchemeIssue.tooLarge => l.urlSchemeTooLarge,
      UrlSchemeIssue.tooDeep => l.urlSchemeTooDeep,
      UrlSchemeIssue.unsupportedEncryption => l.urlSchemeUnsupportedEncryption,
      UrlSchemeIssue.authenticationFailed => l.urlSchemeAuthenticationFailed,
    };
