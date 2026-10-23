import 'package:reclash/enum/enum.dart';
import 'package:reclash/ui/color.dart';

import 'metadata.dart';

enum ProviderRestriction { noGlobal, androidSecure, denyWidgets }

/// The app settings `reclash-settings` names; listed ones turn on and the
/// rest of this set turns off.
enum ProviderSettingFlag {
  minimize,
  autorun,
  shadowstart,
  autostart,
  autoupdate,
  openlogs,
  closeconnections,
}

/// The `reclash-view` keys ReClash has a setting for, and what each holds.
class ProviderView {
  const ProviderView({
    this.proxiesType,
    this.proxiesSort,
    this.proxiesLayout,
    this.proxiesIcon,
    this.proxiesCard,
    this.floatingNavigationBar,
    this.tabAnimation,
    this.liquidGlass,
    this.primaryColor,
    this.colorStyle,
    this.pureBlack,
  });

  factory ProviderView.fromPairs(Map<String, String> pairs) {
    T? pick<T extends Enum>(String key, List<T> values) => values
        .where((value) => value.name.toLowerCase() == pairs[key])
        .firstOrNull;
    return ProviderView(
      proxiesType: pick('proxies.type', ProxiesType.values),
      proxiesSort: pick('proxies.sort', ProxiesSortType.values),
      proxiesLayout: pick('proxies.layout', ProxiesLayout.values),
      proxiesIcon: pick('proxies.icon', ProxiesIconStyle.values),
      proxiesCard: pick('proxies.card', ProxyCardType.values),
      floatingNavigationBar: switch (pairs['app.navbar']) {
        'floating' => true,
        'docked' => false,
        _ => null,
      },
      tabAnimation: pick('app.tabs', TabAnimation.values),
      liquidGlass: pick('app.glass', LiquidGlassMode.values),
      primaryColor: _color(pairs['app.color']),
      colorStyle: pick('app.style', ColorStyle.values),
      pureBlack: switch (pairs['app.black']) {
        'true' => true,
        'false' => false,
        _ => null,
      },
    );
  }

  final ProxiesType? proxiesType;
  final ProxiesSortType? proxiesSort;
  final ProxiesLayout? proxiesLayout;
  final ProxiesIconStyle? proxiesIcon;
  final ProxyCardType? proxiesCard;
  final bool? floatingNavigationBar;
  final TabAnimation? tabAnimation;
  final LiquidGlassMode? liquidGlass;

  /// An opaque ARGB value; a six-digit colour gets a full alpha.
  final int? primaryColor;
  final ColorStyle? colorStyle;
  final bool? pureBlack;
}

int? _color(String? value) {
  if (value == null) return null;
  final hex = value.startsWith('#') ? value.substring(1) : value;
  if (!RegExp(r'^([0-9a-f]{6}|[0-9a-f]{8})$').hasMatch(hex)) return null;
  final argb = int.parse(hex, radix: 16);
  return hex.length == 6 ? 0xFF000000 | argb : argb;
}

class ProviderBackground {
  const ProviderBackground(this.url, this.opacity);

  final Uri url;

  /// 0–1; `reclash-background` without a number shows the image at 8 %.
  final double opacity;
}

/// What a subscription asks of the app beyond its own panel, read from the
/// snapshot of the current profile.
class ProviderAnnouncement {
  const ProviderAnnouncement(this.text, this.link);

  final String text;
  final Uri? link;
}

class ProviderHints {
  const ProviderHints(this.metadata);

  static const empty = ProviderHints(SubscriptionMetadata());

  final SubscriptionMetadata metadata;

  ProviderView get view =>
      ProviderView.fromPairs(metadata.pairs('presentation.view'));

  /// Null when the provider sends no list or no name it lists is known, so
  /// the user's dashboard stays as it is.
  List<DashboardWidget>? get widgets {
    final names = metadata.strings('presentation.widgets');
    final widgets = [
      for (final name in names)
        ?DashboardWidget.values
            .where((widget) => widget.name.toLowerCase() == name)
            .firstOrNull,
    ];
    return widgets.isEmpty ? null : widgets;
  }

  ProviderBackground? get background {
    final raw = metadata.text('presentation.background');
    final url = raw == null ? null : safeSubscriptionLink(raw);
    if (url == null) return null;
    final opacity = metadata.count('presentation.backgroundOpacity') ?? 8;
    return ProviderBackground(url, opacity / 100);
  }

  /// Null when the provider does not send `reclash-settings`.
  Map<ProviderSettingFlag, bool>? get settings {
    if (!metadata.fields.containsKey('settings.flags')) return null;
    final named = metadata.strings('settings.flags').toSet();
    return {
      for (final flag in ProviderSettingFlag.values)
        flag: named.contains(flag.name),
    };
  }

  Set<ProviderRestriction> get restrictions {
    final named = metadata.strings('settings.restrictions').toSet();
    return {
      for (final restriction in ProviderRestriction.values)
        if (named.contains(restriction.name.toLowerCase())) restriction,
    };
  }

  String? get serverGroup => metadata.text('presentation.serverGroup');

  ProviderAnnouncement? get announcement => _message('announce', 'announceUrl');

  ProviderAnnouncement? get notice => _message('notice', 'noticeUrl');

  ProviderAnnouncement? _message(String textKey, String linkKey) {
    final text = metadata.text('provider.$textKey')?.trim();
    if (text == null || text.isEmpty) return null;
    final link = metadata.text('provider.$linkKey');
    return ProviderAnnouncement(
      text,
      link == null ? null : safeSubscriptionLink(link),
    );
  }

  List<String> get excludedApps => metadata.strings('apps.exclude');

  List<String> get includedApps => metadata.strings('apps.include');

  /// `reclash-approuting: domestic` keeps the home region's apps out of the
  /// tunnel; `domestic:<cc>` names the region instead of the app's own.
  ({bool enabled, String? region}) get domesticApps {
    final value = metadata.strings('apps.routing').firstOrNull;
    if (value == null) return (enabled: false, region: null);
    if (value == 'domestic') return (enabled: true, region: null);
    if (value.startsWith('domestic:') && value.length > 9) {
      return (enabled: true, region: value.substring(9).toUpperCase());
    }
    return (enabled: false, region: null);
  }

  List<String> get fallbackHosts => metadata.strings('transport.fallbackHosts');

  String? get newDomain => metadata.strings('transport.newDomain').firstOrNull;
}
