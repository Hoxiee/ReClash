import 'package:reclash/l10n/l10n.dart';

import 'country_profile.dart';

String regionLabel(AppLocalizations l, String? value) =>
    switch (sanitizeRegionCode(value)) {
      'RU' => l.regionRussia,
      'IR' => l.regionIran,
      'CN' => l.regionChina,
      'EG' => l.regionEgypt,
      otherRegionCode => l.regionOther,
      _ => l.regionNotSet,
    };

String regionFlag(String? value) => switch (sanitizeRegionCode(value)) {
  'RU' => '🇷🇺',
  'IR' => '🇮🇷',
  'CN' => '🇨🇳',
  'EG' => '🇪🇬',
  _ => '🌐',
};
