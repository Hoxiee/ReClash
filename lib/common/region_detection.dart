import 'dart:ui';

import 'package:reclash/enum/enum.dart';

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

const _countryRegions = <String, AppRegion>{
  'RU': AppRegion.russia,
  'IR': AppRegion.iran,
  'CN': AppRegion.china,
};

const _languageRegions = <String, AppRegion>{
  'ru': AppRegion.russia,
  'fa': AppRegion.iran,
  'zh': AppRegion.china,
};

// A faked locale can't hide the time zone, and it needs no SIM.
const _russianZones = {
  'Europe/Kaliningrad',
  'Europe/Moscow',
  'Europe/Simferopol',
  'Europe/Kirov',
  'Europe/Volgograd',
  'Europe/Astrakhan',
  'Europe/Saratov',
  'Europe/Ulyanovsk',
  'Europe/Samara',
  'Asia/Yekaterinburg',
  'Asia/Omsk',
  'Asia/Novosibirsk',
  'Asia/Barnaul',
  'Asia/Tomsk',
  'Asia/Novokuznetsk',
  'Asia/Krasnoyarsk',
  'Asia/Irkutsk',
  'Asia/Chita',
  'Asia/Yakutsk',
  'Asia/Khandyga',
  'Asia/Vladivostok',
  'Asia/Ust-Nera',
  'Asia/Magadan',
  'Asia/Sakhalin',
  'Asia/Srednekolymsk',
  'Asia/Kamchatka',
  'Asia/Anadyr',
};

const _iranianZones = {'Asia/Tehran'};

const _chineseZones = {
  'Asia/Shanghai',
  'Asia/Urumqi',
  'Asia/Chongqing',
  'Asia/Harbin',
  'Asia/Kashgar',
};

AppRegion? _regionForCountry(String? code) =>
    code == null ? null : _countryRegions[code.trim().toUpperCase()];

AppRegion? _regionForLanguage(String? code) =>
    code == null ? null : _languageRegions[code.trim().toLowerCase()];

AppRegion? _regionForTimeZone(String? id) {
  if (id == null) return null;
  final zone = id.trim();
  if (_russianZones.contains(zone)) return AppRegion.russia;
  if (_iranianZones.contains(zone)) return AppRegion.iran;
  if (_chineseZones.contains(zone)) return AppRegion.china;
  return null;
}

/// First signal naming a region we ship a strategy for wins; SIM, then serving
/// network, time zone, locale country, locale language. Otherwise [other].
AppRegion detectRegion(RegionSignals signals, Locale? locale) {
  return _regionForCountry(signals.simCountry) ??
      _regionForCountry(signals.networkCountry) ??
      _regionForTimeZone(signals.timeZoneId) ??
      _regionForCountry(locale?.countryCode) ??
      _regionForLanguage(locale?.languageCode) ??
      AppRegion.other;
}
