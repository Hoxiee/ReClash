import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/subscriptions/metadata/hints.dart';
import 'package:reclash/subscriptions/metadata/provider_cards.dart';
import 'package:reclash/subscriptions/metadata/provider_conditions.dart';
import 'package:reclash/subscriptions/metadata/provider_power_labels.dart';
import 'package:reclash/ui/color.dart';

void main() {
  final schema =
      jsonDecode(File('provider-config.schema.json').readAsStringSync())
          as Map<String, dynamic>;
  final defs = schema['\$defs'] as Map<String, dynamic>;
  final properties = schema['properties'] as Map<String, dynamic>;

  Map<String, dynamic> at(Map<String, dynamic> node, List<String> path) {
    var current = node;
    for (final key in path) {
      current = current[key] as Map<String, dynamic>;
    }
    return current;
  }

  Set<String> enumOf(Map<String, dynamic> node) => {
    ...(node['enum'] as List).cast<String>(),
  };

  Set<String> names(Iterable<Enum> values) => {for (final v in values) v.name};

  Map<String, dynamic> card(String name) => defs[name] as Map<String, dynamic>;

  Set<String> cardEnum(String card, String key) =>
      enumOf(at(defs, [card, 'properties', key]));

  Set<String> viewEnum(String group, String key) =>
      enumOf(at(properties, ['view', 'properties', group, 'properties', key]));

  test('card enums match the parser', () {
    expect(cardEnum('banner', 'layout'), names(ProviderBannerLayout.values));
    expect(cardEnum('banner', 'side'), names(ProviderBannerSide.values));
    expect(cardEnum('banner', 'tone'), names(ProviderBannerTone.values));
    expect(cardEnum('note', 'level'), names(ProviderNoteLevel.values));
    expect(
      enumOf(defs['appAction'] as Map<String, dynamic>),
      names(ProviderAppAction.values),
    );
  });

  test('presentation enums match the app', () {
    expect(viewEnum('proxies', 'type'), names(ProxiesType.values));
    expect(viewEnum('proxies', 'sort'), names(ProxiesSortType.values));
    expect(viewEnum('proxies', 'layout'), names(ProxiesLayout.values));
    expect(viewEnum('proxies', 'icon'), names(ProxiesIconStyle.values));
    expect(viewEnum('proxies', 'card'), names(ProxyCardType.values));
    expect(viewEnum('app', 'tabs'), names(TabAnimation.values));
    expect(viewEnum('app', 'glass'), names(LiquidGlassMode.values));
    expect(viewEnum('app', 'style'), names(ColorStyle.values));
    expect(
      enumOf(at(properties, ['power-button', 'properties', 'type'])),
      names(ProviderPowerType.values),
    );
    expect(
      enumOf(at(properties, ['widgets', 'items'])),
      names(DashboardWidget.values),
    );
    final shapes = [
      for (final of in (defs['powerShape']! as Map)['anyOf'] as List)
        ...enumOf(of as Map<String, dynamic>),
    ];
    expect(shapes.toSet(), {...names(ProviderPowerShape.values), 'random'});
  });

  test('conditions and power labels match the parser', () {
    expect(
      (at(defs, ['when', 'properties']).keys).toSet(),
      ProviderWhen.knownKeys,
    );
    expect(
      at(properties, ['power-labels', 'properties']).keys.toSet(),
      providerPowerLabelStates.toSet(),
    );
    final platforms = at(defs, ['when', 'properties', 'platforms', 'items']);
    expect(enumOf(platforms), providerPlatforms);
  });

  test('icons match the glyphs the app draws', () {
    final source = File('lib/widgets/provider_cards.dart').readAsStringSync();
    final start = source.indexOf('Glyph _glyphOf');
    final glyphs = source.substring(start, source.indexOf('};', start));
    final icons = {
      for (final m in RegExp(r"'([a-z]+)'").allMatches(glyphs)) m.group(1)!,
    };
    expect(enumOf(card('icon')), icons);
  });
}
