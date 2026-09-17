import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';

void main() {
  group('parsePanelBackground', () {
    test('parses a web URL with default and explicit opacity', () {
      final defaultBackground = parsePanelBackground(
        'https://cdn.example.com/background.webp',
      );
      final explicitBackground = parsePanelBackground(
        'http://panel.test/background.jpg,35',
      );

      expect(defaultBackground?.url, 'https://cdn.example.com/background.webp');
      expect(defaultBackground?.opacity, 0.1);
      expect(explicitBackground?.url, 'http://panel.test/background.jpg');
      expect(explicitBackground?.opacity, 0.35);
    });

    test('clamps opacity and preserves commas without a numeric suffix', () {
      expect(
        parsePanelBackground('https://example.com/image.jpg,0')?.opacity,
        0.01,
      );
      expect(
        parsePanelBackground('https://example.com/image.jpg,200')?.opacity,
        1,
      );
      expect(
        parsePanelBackground('https://example.com/image,a.jpg')?.url,
        'https://example.com/image,a.jpg',
      );
    });

    test('accepts a bundled asset background', () {
      final background = parsePanelBackground(
        'asset:assets/images/developer/developer_ember_bg.svg,22',
      );

      expect(background?.url, 'asset:assets/images/developer/developer_ember_bg.svg');
      expect(background?.opacity, 0.22);
      expect(
        parsePanelBackground('asset:assets/images/logo.svg')?.opacity,
        0.1,
      );
      expect(parsePanelBackground('asset:'), isNull);
    });

    test('rejects unsafe and malformed URLs', () {
      for (final value in [
        'file:///tmp/background.jpg',
        'data:image/png;base64,AAAA',
        'javascript:alert(1)',
        'https://user:secret@example.com/background.jpg',
        '/relative/background.jpg',
        '',
      ]) {
        expect(
          parsePanelBackground(value),
          isNull,
          reason: '"$value" must not become a background',
        );
      }
    });
  });

  group('parsePanelHeroRing', () {
    test('reads exactly three gradient colours', () {
      expect(parsePanelHeroRing('35B5FF,3657FF,A638F4'), const [
        Color(0xFF35B5FF),
        Color(0xFF3657FF),
        Color(0xFFA638F4),
      ]);
      expect(parsePanelHeroRing('#FF0000;#00FF00;#0000FF'), const [
        Color(0xFFFF0000),
        Color(0xFF00FF00),
        Color(0xFF0000FF),
      ]);
    });

    test('rejects incomplete and malformed gradients', () {
      expect(parsePanelHeroRing(null), isNull);
      expect(parsePanelHeroRing('FF0000,00FF00'), isNull);
      expect(parsePanelHeroRing('FF0000,broken,0000FF'), isNull);
      expect(parsePanelHeroRing('FF0000,00FF00,0000FF,FFFFFF'), isNull);
    });
  });

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
      'reclash-heroring': ['35B5FF,3657FF,A638F4'],
    });
    expect(meta.proxiesView, 'type:list; card:min');
    expect(meta.themeHex, 'FF5733:pureblack');
    expect(meta.heroRing, '35B5FF,3657FF,A638F4');
    expect(meta.hasContent, true);
  });
}
