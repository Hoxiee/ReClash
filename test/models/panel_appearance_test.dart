import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';

void main() {
  group('parsePanelTheme', () {
    test('reads colour, variant and pure black in any order', () {
      final theme = parsePanelTheme('FF5733:vibrant:pureblack')!;
      expect(theme.primaryColor, 0xFFFF5733);
      expect(theme.schemeVariant, DynamicSchemeVariant.vibrant);
      expect(theme.pureBlack, true);
      final reordered = parsePanelTheme('pureblack;#00FF00')!;
      expect(reordered.primaryColor, 0xFF00FF00);
      expect(reordered.pureBlack, true);
      expect(reordered.schemeVariant, isNull);
    });

    test('keeps an explicit alpha channel', () {
      final theme = parsePanelTheme('80FF5733');
      expect(theme, isA<PanelTheme>());
      expect(theme!.primaryColor, 0x80FF5733);
    });

    test('yields nothing for junk or empty input', () {
      expect(parsePanelTheme(null), isNull);
      expect(parsePanelTheme(''), isNull);
      expect(parsePanelTheme('not-a-colour'), isNull);
    });
  });

  group('parsePanelProxiesView', () {
    test('reads every token', () {
      final view = parsePanelProxiesView(
        'type:list; sort:delay; layout:tight; icon:none; card:min',
      )!;
      expect(view.type, ProxiesType.list);
      expect(view.sortType, ProxiesSortType.delay);
      expect(view.layout, ProxiesLayout.tight);
      expect(view.iconStyle, ProxiesIconStyle.none);
      expect(view.cardType, ProxyCardType.min);
    });

    test('maps the oneline card size onto min', () {
      final view = parsePanelProxiesView('card:oneline');
      expect(view, isA<PanelProxiesView>());
      expect(view!.cardType, ProxyCardType.min);
    });

    test('ignores unknown keys and values', () {
      expect(parsePanelProxiesView('type:grid; mood:blue'), isNull);
      expect(parsePanelProxiesView('layout'), isNull);
      expect(parsePanelProxiesView(null), isNull);
    });
  });

  group('applyPanelProxiesView', () {
    const user = ProxiesStyleProps();

    test('dresses the fields the user has not claimed', () {
      final applied = applyPanelProxiesView(
        user,
        parsePanelProxiesView('type:list; card:min'),
      );
      expect(applied.type, ProxiesType.list);
      expect(applied.cardType, ProxyCardType.min);
      expect(applied.layout, user.layout);
    });

    test('a claimed field stays the user own', () {
      final claimed = user
          .claim(ProxiesStyleField.cardType)
          .copyWith(cardType: ProxyCardType.expand);
      final applied = applyPanelProxiesView(
        claimed,
        parsePanelProxiesView('type:list; card:min'),
      );
      expect(applied.cardType, ProxyCardType.expand);
      expect(applied.type, ProxiesType.list);
    });

    test('nothing applies once the user stops following the panel', () {
      final applied = applyPanelProxiesView(
        user.copyWith(followPanel: false),
        parsePanelProxiesView('type:list'),
      );
      expect(applied, user.copyWith(followPanel: false));
    });

    test('an absent view leaves the user props untouched', () {
      expect(applyPanelProxiesView(user, null), user);
    });
  });

  test('headers carry the view and theme through to PanelMeta', () {
    final meta = PanelMeta.fromHeaders({
      'reclash-view': ['type:list; card:min'],
      'reclash-hex': ['FF5733:pureblack'],
    });
    expect(meta.proxiesView, 'type:list; card:min');
    expect(meta.themeHex, 'FF5733:pureblack');
    expect(meta.hasContent, true);
  });
}
