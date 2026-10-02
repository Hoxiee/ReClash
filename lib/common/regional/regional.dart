import 'package:reclash/common/regional/country_profile.dart';
import 'package:reclash/common/util/provider_reader.dart';

enum RegionalFacetId { clashDns, desync, packageMatcher, deviceIdentity }

Set<RegionalFacetId> regionCapabilities(String? code) =>
    capabilitiesForCode(code);

bool regionAllowsFacet(String? code, RegionalFacetId id) =>
    capabilitiesForCode(code).contains(id);

class RegionalDefaults<T> {
  const RegionalDefaults(this._table, this._fallback);

  final Map<String, T> _table;
  final T _fallback;

  T forRegion(String? code) => _table[normalizedRegionCode(code)] ?? _fallback;

  bool isShipped(T value) => _fallback == value || _table.containsValue(value);
}

/// Editable state re-seeded on a region switch only while still pristine.
abstract interface class SeededRegionalFacet {
  RegionalFacetId get id;

  bool isPristineFor(ProviderReader read, String? code);

  void applyDefaults(ProviderReader read, String? code);
}
