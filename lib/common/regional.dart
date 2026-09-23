import 'package:reclash/common/provider_reader.dart';
import 'package:reclash/enum/enum.dart';

enum RegionalFacetId {
  smartRouting,
  clashDns,
  desync,
  packageMatcher,
  deviceIdentity,
  season,
}

// Absence = available everywhere; a value = the only regions that may use it.
const _facetRegions = <RegionalFacetId, Set<AppRegion>>{
  RegionalFacetId.desync: {AppRegion.russia, AppRegion.iran},
  RegionalFacetId.deviceIdentity: {AppRegion.russia},
  RegionalFacetId.packageMatcher: {
    AppRegion.russia,
    AppRegion.iran,
    AppRegion.china,
  },
};

Set<RegionalFacetId> regionCapabilities(AppRegion region) => {
  for (final id in RegionalFacetId.values)
    if (_facetRegions[id]?.contains(region) ?? true) id,
};

bool regionAllowsFacet(AppRegion region, RegionalFacetId id) =>
    _facetRegions[id]?.contains(region) ?? true;

class RegionalDefaults<T> {
  const RegionalDefaults(this._table, this._fallback);

  final Map<AppRegion, T> _table;
  final T _fallback;

  T forRegion(AppRegion region) => _table[region] ?? _fallback;

  bool isShipped(T value) =>
      _fallback == value || _table.containsValue(value);
}

/// Editable state re-seeded on a region switch only while still pristine.
abstract interface class SeededRegionalFacet {
  RegionalFacetId get id;

  bool isPristineFor(ProviderReader read, AppRegion region);

  void applyDefaults(ProviderReader read, AppRegion region);
}
