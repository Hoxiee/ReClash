import 'package:reclash/enum/enum.dart';
import 'package:material_ui/material_ui.dart';

import 'config.dart';

class PanelTheme {
  const PanelTheme({this.primaryColor, this.schemeVariant, this.pureBlack});

  final int? primaryColor;
  final DynamicSchemeVariant? schemeVariant;
  final bool? pureBlack;

  bool get isEmpty =>
      primaryColor == null && schemeVariant == null && pureBlack == null;
}

/// The active profile's panel theme dresses over the user's own choices
/// without ever writing into them, so switching away restores the user.
ThemeProps applyPanelTheme(ThemeProps user, PanelTheme? panel) {
  if (panel == null) return user;
  return user.copyWith(
    primaryColor: panel.primaryColor ?? user.primaryColor,
    schemeVariant: panel.schemeVariant ?? user.schemeVariant,
    pureBlack: panel.pureBlack ?? user.pureBlack,
  );
}

/// `FF5733[:variant][:pureblack]`, tokens after the colour accepted in any
/// order so a panel that emits only `pureblack` still works.
PanelTheme? parsePanelTheme(String? value) {
  final tokens = _splitTokens(value, _themeSeparators);
  if (tokens.isEmpty) return null;
  int? primaryColor;
  DynamicSchemeVariant? schemeVariant;
  bool? pureBlack;
  for (final token in tokens) {
    if (token == 'pureblack') {
      pureBlack = true;
      continue;
    }
    final variant = _schemeVariants[token];
    if (variant != null) {
      schemeVariant = variant;
      continue;
    }
    primaryColor ??= _parseHexColor(token);
  }
  final theme = PanelTheme(
    primaryColor: primaryColor,
    schemeVariant: schemeVariant,
    pureBlack: pureBlack,
  );
  return theme.isEmpty ? null : theme;
}

class PanelProxiesView {
  const PanelProxiesView({
    this.type,
    this.sortType,
    this.layout,
    this.iconStyle,
    this.cardType,
  });

  final ProxiesType? type;
  final ProxiesSortType? sortType;
  final ProxiesLayout? layout;
  final ProxiesIconStyle? iconStyle;
  final ProxyCardType? cardType;

  bool get isEmpty =>
      type == null &&
      sortType == null &&
      layout == null &&
      iconStyle == null &&
      cardType == null;
}

/// `type:list; sort:delay; layout:tight; icon:none; card:min`.
PanelProxiesView? parsePanelProxiesView(String? value) {
  final tokens = _splitTokens(value, _viewSeparators);
  if (tokens.isEmpty) return null;
  ProxiesType? type;
  ProxiesSortType? sortType;
  ProxiesLayout? layout;
  ProxiesIconStyle? iconStyle;
  ProxyCardType? cardType;
  for (final token in tokens) {
    final colon = token.indexOf(':');
    if (colon <= 0) continue;
    final key = token.substring(0, colon).trim();
    final raw = token.substring(colon + 1).trim();
    switch (key) {
      case 'type':
        type ??= _proxiesTypes[raw];
      case 'sort':
        sortType ??= _sortTypes[raw];
      case 'layout':
        layout ??= _layouts[raw];
      case 'icon':
        iconStyle ??= _iconStyles[raw];
      case 'card':
        cardType ??= _cardTypes[raw];
    }
  }
  final view = PanelProxiesView(
    type: type,
    sortType: sortType,
    layout: layout,
    iconStyle: iconStyle,
    cardType: cardType,
  );
  return view.isEmpty ? null : view;
}

/// The panel dresses the proxies page only for its own subscription, and only
/// where the user has not already made that choice themselves.
ProxiesStyleProps applyPanelProxiesView(
  ProxiesStyleProps user,
  PanelProxiesView? view,
) {
  if (view == null || !user.followPanel) return user;
  bool takes(ProxiesStyleField field) => !user.userOwned.contains(field);
  return user.copyWith(
    type: view.type != null && takes(ProxiesStyleField.type)
        ? view.type!
        : user.type,
    sortType: view.sortType != null && takes(ProxiesStyleField.sortType)
        ? view.sortType!
        : user.sortType,
    layout: view.layout != null && takes(ProxiesStyleField.layout)
        ? view.layout!
        : user.layout,
    iconStyle: view.iconStyle != null && takes(ProxiesStyleField.iconStyle)
        ? view.iconStyle!
        : user.iconStyle,
    cardType: view.cardType != null && takes(ProxiesStyleField.cardType)
        ? view.cardType!
        : user.cardType,
  );
}

extension ProxiesStyleClaim on ProxiesStyleProps {
  ProxiesStyleProps claim(ProxiesStyleField field) =>
      copyWith(userOwned: {...userOwned, field});
}

final _themeSeparators = RegExp(r'[;,:]');
final _viewSeparators = RegExp(r'[;,]');

List<String> _splitTokens(String? value, Pattern separators) {
  if (value == null) return const [];
  return value
      .toLowerCase()
      .split(separators)
      .map((token) => token.trim())
      .where((token) => token.isNotEmpty)
      .toList();
}

int? _parseHexColor(String token) {
  final hex = token.startsWith('#') ? token.substring(1) : token;
  if (hex.length != 6 && hex.length != 8) return null;
  final value = int.tryParse(hex, radix: 16);
  if (value == null) return null;
  return hex.length == 6 ? 0xFF000000 | value : value;
}

const _schemeVariants = <String, DynamicSchemeVariant>{
  'tonalspot': DynamicSchemeVariant.tonalSpot,
  'fidelity': DynamicSchemeVariant.fidelity,
  'monochrome': DynamicSchemeVariant.monochrome,
  'neutral': DynamicSchemeVariant.neutral,
  'vibrant': DynamicSchemeVariant.vibrant,
  'expressive': DynamicSchemeVariant.expressive,
  'content': DynamicSchemeVariant.content,
};

const _proxiesTypes = <String, ProxiesType>{
  'tab': ProxiesType.tab,
  'list': ProxiesType.list,
};

const _sortTypes = <String, ProxiesSortType>{
  'default': ProxiesSortType.none,
  'none': ProxiesSortType.none,
  'delay': ProxiesSortType.delay,
  'name': ProxiesSortType.name,
};

const _layouts = <String, ProxiesLayout>{
  'loose': ProxiesLayout.loose,
  'standard': ProxiesLayout.standard,
  'tight': ProxiesLayout.tight,
};

const _iconStyles = <String, ProxiesIconStyle>{
  'none': ProxiesIconStyle.none,
  'standard': ProxiesIconStyle.standard,
  'icon': ProxiesIconStyle.icon,
};

/// `oneline` is a FlClashX card size we do not have; `min` is the nearest.
const _cardTypes = <String, ProxyCardType>{
  'expand': ProxyCardType.expand,
  'shrink': ProxyCardType.shrink,
  'min': ProxyCardType.min,
  'oneline': ProxyCardType.min,
};
