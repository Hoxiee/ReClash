import 'dart:ui';

import 'country_profile.dart';

class RegionSignals {
  const RegionSignals({this.timeZoneId});

  final String? timeZoneId;
}

class RegionDetectionResult {
  const RegionDetectionResult(this.countryCode, this.source);

  final String countryCode;
  final RegionDetectionSource source;
}

enum RegionDetectionSource { timeZone, localeCountry, localeLanguage }

RegionDetectionResult? detectRegionWithSource(
  RegionSignals signals,
  Locale? locale,
) {
  final timeZone = codeForTimeZone(signals.timeZoneId);
  if (timeZone != null) {
    return RegionDetectionResult(timeZone, RegionDetectionSource.timeZone);
  }
  final country = codeForCountryCode(locale?.countryCode);
  if (country != null) {
    return RegionDetectionResult(country, RegionDetectionSource.localeCountry);
  }
  if (normalizedRegionCode(locale?.countryCode) != null ||
      locale?.scriptCode == 'Hant') {
    return null;
  }
  final language = codeForLanguage(locale?.languageCode);
  if (language != null) {
    return RegionDetectionResult(
      language,
      RegionDetectionSource.localeLanguage,
    );
  }
  return null;
}

String? detectRegion(RegionSignals signals, Locale? locale) =>
    detectRegionWithSource(signals, locale)?.countryCode;
