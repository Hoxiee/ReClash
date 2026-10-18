import 'package:reclash/common/app_localizations.dart';

import 'clients.dart';
import 'preview.dart';
import '../imports/import.dart';

extension SubscriptionClientPresetLabel on SubscriptionClientPreset {
  String get label {
    final l10n = currentAppLocalizations;
    return switch (this) {
      SubscriptionClientPreset.auto => l10n.subscriptionClientAuto,
      SubscriptionClientPreset.reclash => l10n.subscriptionClientReclash,
      SubscriptionClientPreset.flClashX => 'FlClashX',
      SubscriptionClientPreset.clashMeta => l10n.subscriptionClientClashMeta,
      SubscriptionClientPreset.clash => l10n.subscriptionClientClash,
      SubscriptionClientPreset.happ => l10n.subscriptionClientHapp,
      SubscriptionClientPreset.incy => l10n.subscriptionClientIncy,
      SubscriptionClientPreset.singbox => l10n.subscriptionClientSingbox,
      SubscriptionClientPreset.v2rayng => l10n.subscriptionClientV2rayng,
      SubscriptionClientPreset.custom => l10n.subscriptionClientCustom,
    };
  }
}

extension SubscriptionFormatLabel on SubscriptionFormat {
  String get label {
    final l10n = currentAppLocalizations;
    return switch (this) {
      SubscriptionFormat.clash => l10n.subscriptionImportFormatClash,
      SubscriptionFormat.shareLinks => l10n.subscriptionImportFormatShareLinks,
      SubscriptionFormat.xray => 'Xray',
      SubscriptionFormat.singbox => 'sing-box',
      SubscriptionFormat.wireguard => 'WireGuard',
      SubscriptionFormat.amnezia => 'AmneziaWG',
      SubscriptionFormat.encrypted => l10n.subscriptionImportFormatEncrypted,
      SubscriptionFormat.unknown => l10n.subscriptionImportFormatUnknown,
    };
  }
}

extension SubscriptionPreviewFailureLabel on SubscriptionPreviewFailure {
  String get label {
    final l10n = currentAppLocalizations;
    return switch (this) {
      SubscriptionPreviewFailure.incompatible =>
        l10n.subscriptionCompatibilityCheckFailed,
      SubscriptionPreviewFailure.timeout =>
        l10n.subscriptionCompatibilityTimeout,
      SubscriptionPreviewFailure.authorization =>
        l10n.subscriptionCompatibilityAuthorization,
      SubscriptionPreviewFailure.rateLimited =>
        l10n.subscriptionCompatibilityRateLimited,
      SubscriptionPreviewFailure.transport =>
        l10n.subscriptionCompatibilityTransport,
      SubscriptionPreviewFailure.superseded =>
        l10n.subscriptionCompatibilitySuperseded,
      SubscriptionPreviewFailure.ageKey => l10n.subscriptionCompatibilityAgeKey,
    };
  }
}
