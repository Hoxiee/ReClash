import 'dart:ui';

import 'package:reclash/common/regional/country_profile.dart';

/// Device hints that outlive the UI language (SIM, network, time zone),
/// gathered natively; every field is optional because a device may withhold it.
class RegionSignals {
  const RegionSignals({this.simCountry, this.networkCountry, this.timeZoneId});

  final String? simCountry;
  final String? networkCountry;
  final String? timeZoneId;

  factory RegionSignals.fromMap(Map<Object?, Object?>? map) {
    String? at(String key) {
      final value = map?[key];
      if (value is! String) return null;
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }

    return RegionSignals(
      simCountry: at('simCountry'),
      networkCountry: at('networkCountry'),
      timeZoneId: at('timeZone'),
    );
  }
}

/// First signal naming a country we ship a profile for wins; SIM, then serving
/// network, time zone, locale country, locale language. Null when nothing
/// resolves to a shipped country.
String? detectRegion(RegionSignals signals, Locale? locale) =>
    codeForCountryCode(signals.simCountry) ??
    codeForCountryCode(signals.networkCountry) ??
    codeForTimeZone(signals.timeZoneId) ??
    codeForCountryCode(locale?.countryCode) ??
    codeForLanguage(locale?.languageCode);
