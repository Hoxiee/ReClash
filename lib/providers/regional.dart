import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/providers/config.dart';

extension RegionCapability on WidgetRef {
  bool regionAllows(RegionalFacetId id) =>
      watch(regionCapabilitiesProvider).contains(id);
}
