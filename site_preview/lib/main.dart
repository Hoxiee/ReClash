import 'dart:async';
import 'dart:js_interop';
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/datetime.dart';
import 'package:reclash/common/number_text.dart';
import 'package:reclash/common/ui_localizations.dart';
import 'package:reclash/features/power/face.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/wallpaper.dart';
import 'package:reclash/subscriptions/metadata/hints.dart';
import 'package:reclash/subscriptions/metadata/metadata.dart';
import 'package:reclash/subscriptions/metadata/provider_cards.dart';
import 'package:reclash/subscriptions/metadata/provider_conditions.dart';
import 'package:reclash/subscriptions/metadata/provider_config.dart';
import 'package:reclash/subscriptions/metadata/provider_power_labels.dart';
import 'package:reclash/ui/app_theme.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/ui/wallpaper_image.dart';
import 'package:reclash/views/dashboard/layout.dart';
import 'package:reclash/views/dashboard/simple/home_view.dart';
import 'package:reclash/views/dashboard/simple/subscription_card_view.dart';
import 'package:reclash/widgets/announcement_card_view.dart';
import 'package:reclash/widgets/profile_import_parts.dart';
import 'package:reclash/widgets/provider_cards_view.dart';
import 'package:reclash/widgets/wallpaper_backdrop.dart';

import 'images.dart';
import 'localizations.dart';

/// The app's default seed, `defaultPrimaryColor`, for a manifest without
/// `view.app.color`.
const _defaultSeed = Color(0xFFFF9500);
const _appVersion = String.fromEnvironment('RECLASH_VERSION');
const _protocol = 1;
const _connectDelay = Duration(milliseconds: 1200);
const _gib = 1 << 30;
const _maxGb = 9007199254740991 ~/ _gib;
const _maxDays = 365000;

void main() => runApp(const PreviewApp());

@JS('window')
external _Window get _window;

extension type _Window._(JSObject _) implements JSObject {
  external _Window get parent;
  external _Location get location;
  external void postMessage(JSAny? message, String targetOrigin);
  external void addEventListener(String type, JSFunction listener);
  external void removeEventListener(String type, JSFunction listener);
}

extension type _Location._(JSObject _) implements JSObject {
  external String get origin;
}

extension type _MessageEvent._(JSObject _) implements JSObject {
  external String get origin;
  external JSAny? get source;
  external JSAny? get data;
}

/// Same-origin `postMessage` to the builder page around the iframe.
class _Bridge {
  _Bridge(this.onMessage) {
    _window.addEventListener('message', _listener);
  }

  final void Function(Map<Object?, Object?> message) onMessage;
  late final JSFunction _listener = _receive.toJS;

  String get _origin => _window.location.origin;

  void _receive(_MessageEvent event) {
    if (event.origin != _origin ||
        !event.source.strictEquals(_window.parent).toDart) {
      return;
    }
    final data = event.data.dartify();
    if (data is Map && data['v'] == _protocol) onMessage(data);
  }

  void dispose() => _window.removeEventListener('message', _listener);

  void post(String type, [Map<String, Object?> fields = const {}]) => _window
      .parent
      .postMessage({'v': _protocol, 'type': type, ...fields}.jsify(), _origin);
}

enum _Screen { home, widgets, import }

class _Scenario {
  const _Scenario({
    this.screen = _Screen.home,
    this.locale = 'en',
    this.dark = false,
    this.platform = 'android',
    this.connected = false,
    this.usedGb = 12,
    this.totalGb = 100,
    this.daysLeft = 23,
  });

  factory _Scenario.fromJson(Map<Object?, Object?> json) {
    num number(String key, num fallback) => switch (json[key]) {
      final num value when value.isFinite && value >= 0 => value,
      _ => fallback,
    };
    return _Scenario(
      screen:
          _Screen.values
              .where((screen) => screen.name == json['screen'])
              .firstOrNull ??
          _Screen.home,
      locale: json['locale'] == 'ru' ? 'ru' : 'en',
      dark: json['theme'] == 'dark',
      platform: switch (json['platform']) {
        final String value
            when const {
              'android',
              'windows',
              'macos',
              'linux',
            }.contains(value) =>
          value,
        _ => 'android',
      },
      connected: json['connected'] == true,
      usedGb: math.min(number('usedGb', 0), _maxGb),
      totalGb: math.min(number('totalGb', 0), _maxGb),
      daysLeft: switch (json['daysLeft']) {
        final num value when value.isFinite => value.clamp(0, _maxDays).toInt(),
        _ => null,
      },
    );
  }

  final _Screen screen;
  final String locale;
  final bool dark;
  final String platform;
  final bool connected;
  final num usedGb;
  final num totalGb;
  final int? daysLeft;
}

class PreviewApp extends StatefulWidget {
  const PreviewApp({super.key});

  @override
  State<PreviewApp> createState() => _PreviewAppState();
}

class _PreviewAppState extends State<PreviewApp> {
  late final _Bridge _bridge = _Bridge(_onMessage);
  final _inspector = _Inspector();
  String _yaml = '';
  ProviderConfig? _config;
  _Scenario _scenario = const _Scenario();
  PowerLink _link = PowerLink.off;
  DateTime? _connectedAt;
  Timer? _connecting;

  @override
  void initState() {
    super.initState();
    _inspector.onSelect = (path) => _bridge.post('select', {'path': path});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _bridge.post('ready');
    });
  }

  @override
  void dispose() {
    _connecting?.cancel();
    _bridge.dispose();
    _inspector.dispose();
    super.dispose();
  }

  void _onMessage(Map<Object?, Object?> message) {
    switch (message['type']) {
      case 'manifest':
        _yaml = message['yaml'] is String ? message['yaml']! as String : '';
        setState(_parse);
      case 'scenario':
        final scenario = message['scenario'];
        if (scenario is! Map) return;
        final next = _Scenario.fromJson(scenario);
        final reparse = next.locale != _scenario.locale;
        setState(() {
          _scenario = next;
          if (reparse) _parse();
          if (next.connected != (_link == PowerLink.on)) {
            _setLink(next.connected ? PowerLink.on : PowerLink.off);
          }
        });
      case 'inspect':
        _inspector.enabled = message['enabled'] == true;
      case 'highlight':
        _inspector.highlight = message['path'] is String
            ? message['path']! as String
            : null;
    }
  }

  void _parse() {
    _config = _yaml.trim().isEmpty
        ? null
        : parseProviderConfig(_yaml, _scenario.locale).config;
  }

  void _setLink(PowerLink link) {
    _connecting?.cancel();
    _link = link;
    _connectedAt = link == PowerLink.on ? DateTime.now() : null;
  }

  void _toggle() {
    if (_link == PowerLink.off) {
      setState(() => _setLink(PowerLink.connecting));
      _connecting = Timer(_connectDelay, () {
        setState(() => _setLink(PowerLink.on));
        _bridge.post('connected', {'connected': true});
      });
    } else {
      setState(() => _setLink(PowerLink.off));
      _bridge.post('connected', {'connected': false});
    }
  }

  void _open(String kind, String value) =>
      _bridge.post('open', {'kind': kind, 'value': value});

  void _onAction(ProviderAction action) => switch (action.kind) {
    ProviderActionKind.url => _open('url', action.url.toString()),
    ProviderActionKind.copy => _open('copy', action.text!),
    ProviderActionKind.share => _open('share', action.text!),
    ProviderActionKind.app => _open('app', action.app!.name),
  };

  @override
  Widget build(BuildContext context) {
    final scenario = _scenario;
    final now = DateTime.now();
    final total = (scenario.totalGb * _gib).round();
    final used = (scenario.usedGb * _gib).round();
    final days = scenario.daysLeft;
    final expire = days == null
        ? 0
        : now.add(Duration(days: days, hours: 1)).millisecondsSinceEpoch ~/
              1000;
    final config = _config;
    final metadata = SubscriptionMetadata({
      'subscription.upload': 0,
      'subscription.download': used,
      'subscription.total': total,
      'subscription.expire': expire,
      'subscription.unlimited': total == 0,
      'subscription.perpetual': expire == 0,
      ...?config?.fields,
    });
    final hints = ProviderHints(metadata, config: config);
    final view = hints.view;
    ColorScheme scheme(Brightness brightness) => seededColorScheme(
      seedColor: Color(
        (brightness == Brightness.dark ? view.primaryColorDark : null) ??
            view.primaryColor ??
            _defaultSeed.toARGB32(),
      ),
      brightness: brightness,
      style: view.colorStyle ?? ColorStyle.vivid,
    ).toPureBlack(view.pureBlack ?? false);
    final locale = Locale(scenario.locale);
    final data = _PreviewData(
      metadata: metadata,
      hints: hints,
      snapshot: ProviderConditionSnapshot(
        now: now,
        platform: scenario.platform,
        appVersion: _appVersion,
        expire: expire,
        total: total,
        used: used,
      ),
      usage: (used: used, total: total, expire: expire),
      link: _link,
      connectedAt: _connectedAt,
      onToggle: _toggle,
      onOpenUrl: (url) => _open('url', url.toString()),
      onAction: _onAction,
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: previewLocales,
      localizationsDelegates: [
        const PreviewLocalizationsDelegate(),
        const PreviewUiLocalizationsDelegate(),
        ...GlobalMaterialLocalizations.delegates,
        ...fallbackMaterialLocalizationsDelegates,
      ],
      themeMode: scenario.dark ? ThemeMode.dark : ThemeMode.light,
      theme: buildAppTheme(
        brightness: Brightness.light,
        colorScheme: scheme(Brightness.light),
        locales: [locale],
      ),
      darkTheme: buildAppTheme(
        brightness: Brightness.dark,
        colorScheme: scheme(Brightness.dark),
        locales: [locale],
      ),
      home: _InspectorScope(
        inspector: _inspector,
        child: _Frame(data: data, screen: scenario.screen),
      ),
    );
  }
}

typedef _Usage = ({int used, int total, int expire});

class _PreviewData {
  const _PreviewData({
    required this.metadata,
    required this.hints,
    required this.snapshot,
    required this.usage,
    required this.link,
    required this.connectedAt,
    required this.onToggle,
    required this.onOpenUrl,
    required this.onAction,
  });

  final SubscriptionMetadata metadata;
  final ProviderHints hints;
  final ProviderConditionSnapshot snapshot;
  final _Usage usage;
  final PowerLink link;
  final DateTime? connectedAt;
  final VoidCallback onToggle;
  final void Function(Uri url) onOpenUrl;
  final void Function(ProviderAction action) onAction;

  static final images = PreviewImages(Uri.base);
}

/// Builds the screen the scenario names over the provider's wallpaper; home
/// and widgets swipe between each other as on a phone.
class _Frame extends StatefulWidget {
  const _Frame({required this.data, required this.screen});

  final _PreviewData data;
  final _Screen screen;

  @override
  State<_Frame> createState() => _FrameState();
}

class _FrameState extends State<_Frame> {
  late final _pager = PageController(
    initialPage: widget.screen == _Screen.widgets ? 1 : 0,
  );

  @override
  void didUpdateWidget(_Frame oldWidget) {
    super.didUpdateWidget(oldWidget);
    final page = switch (widget.screen) {
      _Screen.home => 0,
      _Screen.widgets => 1,
      _Screen.import => null,
    };
    if (page != null && widget.screen != oldWidget.screen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pager.hasClients) _pager.jumpToPage(page);
      });
    }
  }

  @override
  void dispose() {
    _pager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final background = data.hints.background;
    final wallpaper = background == null
        ? null
        : _PreviewData.images.source(background.url);
    final colorScheme = context.colorScheme;
    final body = widget.screen == _Screen.import
        ? _ImportScreen(data: data)
        : Stack(
            children: [
              Positioned.fill(
                child: BottomInsetScope(
                  inset: NavigationDock.insetOf(context),
                  child: LayoutBuilder(
                    builder: (context, constraints) => DashboardDensityScope(
                      density: DashboardDensity.mobile,
                      scale: 1,
                      child: PageView(
                        controller: _pager,
                        children: [
                          _HomeScreen(data: data, width: constraints.maxWidth),
                          _WidgetsScreen(
                            data: data,
                            width: constraints.maxWidth,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const Align(alignment: Alignment.bottomCenter, child: _Dock()),
            ],
          );
    return MeasureScope(
      measure: Measure.of(context, 1),
      child: _Anchor(
        path: 'wallpaper',
        enabled: background != null,
        child: WallpaperBackdrop(
          image: wallpaper == null ? null : RasterWallpaperSource(wallpaper),
          settings: WallpaperProps(
            enabled: wallpaper != null,
            opacity: background?.opacity ?? 0.35,
          ),
          baseColor: colorScheme.surface,
          builder: (context, _) => Material(
            type: MaterialType.transparency,
            child: SafeArea(child: body),
          ),
        ),
      ),
    );
  }
}

/// The app's floating dock as a phone with a subscription shows it. The list
/// mirrors the mobile entries of `lib/views/navigation.dart`, which the
/// preview cannot import: it builds every page and their providers.
class _Dock extends StatelessWidget {
  const _Dock();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return NavigationDock(
      destinations: [
        NavigationDockDestination(
          glyph: AppGlyphs.dashboard,
          label: l10n.dashboard,
        ),
        NavigationDockDestination(
          glyph: AppGlyphs.proxies,
          label: l10n.proxies,
        ),
        NavigationDockDestination(
          glyph: AppGlyphs.profiles,
          label: l10n.profiles,
        ),
        NavigationDockDestination(glyph: AppGlyphs.tools, label: l10n.tools),
      ],
      selectedIndex: 0,
      onSelected: (_) {},
    );
  }
}

class _HomeScreen extends StatefulWidget {
  const _HomeScreen({required this.data, required this.width});

  final _PreviewData data;
  final double width;

  @override
  State<_HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<_HomeScreen>
    with AutomaticKeepAliveClientMixin {
  Timer? _tick;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (widget.data.link == PowerLink.on) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final data = widget.data;
    final hints = data.hints;
    final link = data.link;
    final dark = context.colorScheme.brightness == Brightness.dark;
    final side = dashboardMobileSideOf(widget.width);
    final padding = EdgeInsets.fromLTRB(
      side,
      16,
      side,
      12 + context.bottomInset,
    );
    final hint = hints.powerButton;
    final labels = hints.powerLabels[link.name];
    final label = labels == null || labels.isEmpty
        ? null
        : resolveProviderPowerLabel(labels.first, _placeholders(data));
    final connectedAt = data.connectedAt;
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: padding,
        child: FillHero(
          viewport: constraints.maxHeight - padding.vertical,
          minHero: SimplePowerView.heightOf(160),
          hero: _Anchor(
            path: 'power-button',
            child: SimplePowerView(
              minSize: 160,
              maxSize: 220,
              face: PowerFace.plain(link),
              onPressed: data.onToggle,
              logo: data.metadata.logoFor(dark: dark) ?? '',
              images: _PreviewData.images,
              look: (shape: hint.shapes.first, type: hint.type),
              status: _Anchor(
                path: 'power-labels.${link.name}',
                child: PowerStatusView(
                  face: PowerFace.plain(link),
                  custom: label,
                  pausedHint: AppLocalizations.of(
                    context,
                  ).simpleStatusPausedHint,
                  live: PowerLiveLineView(
                    time: getTimeText(
                      connectedAt == null
                          ? null
                          : DateTime.now()
                                .difference(connectedAt)
                                .inMilliseconds,
                    ),
                    down: 1.4 * (1 << 20),
                    up: 96 * (1 << 10),
                  ),
                ),
              ),
            ),
          ),
          below: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: _Anchor(
              path: 'provider',
              child: SubscriptionCardView(
                hasProfile: true,
                title: data.metadata.name ?? 'example.com',
                metadata: data.metadata,
                usage: data.usage,
                images: _PreviewData.images,
                onTap: () {},
                onOpenLink: data.onOpenUrl,
                subtitle: Text(
                  AppLocalizations.of(context).profileUpdatedAt(
                    DateTime.now().getLastUpdateTimeDesc(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.footnote
                      .of(context)
                      .copyWith(color: context.colorScheme.onSurfaceVariant),
                ),
                sync: IconButton(
                  tooltip: AppLocalizations.of(context).update,
                  onPressed: () {},
                  icon: const GlyphIcon(AppGlyphs.sync, size: 20),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Map<String, String?> _placeholders(_PreviewData data) {
    final (:used, :total, :expire) = data.usage;
    return {
      'daysLeft': expire == 0
          ? null
          : '${remainingDays(expire: expire, now: DateTime.now())}',
      'trafficLeft': total <= 0 ? null : _traffic(math.max(0, total - used)),
      'server': 'Amsterdam',
    };
  }
}

String _traffic(num bytes) {
  final (:value, :unit) = bytes.trafficParts;
  return '$value $unit';
}

class _WidgetsScreen extends StatelessWidget {
  const _WidgetsScreen({required this.data, required this.width});

  final _PreviewData data;
  final double width;

  @override
  Widget build(BuildContext context) {
    final hints = data.hints;
    final config = hints.config;
    final all = config?.cards ?? const <ProviderCard>[];
    final visible = visibleProviderCards(all, data.snapshot, const {});
    final side = dashboardMobileSideOf(width);
    final announcement = hints.announcement;
    final notice = hints.notice;
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            side,
            16,
            side,
            12 + context.bottomInset,
          ),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                if (announcement != null)
                  _Anchor(
                    path: 'provider.announce',
                    child: OpenAnnouncementCardView(
                      announcement: announcement,
                      onOpenLink: data.onOpenUrl,
                    ),
                  ),
                if (notice != null)
                  _Anchor(
                    path: 'provider.notice',
                    child: NoticeCardView(
                      announcement: notice,
                      onPressed: () {
                        if (notice.link case final link?) data.onOpenUrl(link);
                      },
                      onDismiss: () {},
                    ),
                  ),
                for (final card in visible)
                  _Anchor(
                    path: 'cards.${all.indexOf(card)}',
                    child: ProviderCardsView(
                      cards: [card],
                      metadata: data.metadata,
                      images: _PreviewData.images,
                      onAction: data.onAction,
                      onDismiss: (_) {},
                    ),
                  ),
                if (announcement == null && notice == null && visible.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      AppLocalizations.of(context).simpleDashboardEmpty,
                      textAlign: TextAlign.center,
                      style: AppTextStyle.footnote.of(context),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ImportScreen extends StatelessWidget {
  const _ImportScreen({required this.data});

  final _PreviewData data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final metadata = data.metadata;
    final dark = context.colorScheme.brightness == Brightness.dark;
    final logo = metadata.logoFor(dark: dark) ?? '';
    final announce = metadata.announce?.trim();
    const host = 'sub.example.com';
    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Material(
          color: context.colorScheme.surfaceContainerLow,
          shape: AppShape.top(AppCorner.xxl),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.profileImportTitle,
                  textAlign: TextAlign.center,
                  style: AppTextStyle.headline.of(context),
                ),
                const SizedBox(height: 12),
                _Anchor(
                  path: 'provider',
                  child: ImportHero(
                    monogram: metadata.name,
                    logoBytes: null,
                    logoIsSvg: false,
                    logoBuilder: logo.isEmpty
                        ? null
                        : (fallback) => _PreviewData.images.logo(
                            logo,
                            fallback: fallback,
                          ),
                    account: metadata.accountTitle,
                    kind: metadata.kind,
                    glyph: AppGlyphs.cloudDownload,
                    loading: false,
                    title: metadata.name ?? host,
                    caption: metadata.hideUrl ? '' : host,
                  ),
                ),
                if (announce != null && announce.isNotEmpty)
                  _Anchor(
                    path: 'provider.announce',
                    child: ImportAnnounce(text: announce),
                  ),
                ImportStats(nodes: 24, usage: data.usage),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: 8,
                  children: [
                    TextButton(onPressed: () {}, child: Text(l10n.cancel)),
                    TextButton(onPressed: () {}, child: Text(l10n.add)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Logos and pictures straight from the network; an image host without CORS
/// headers still shows through an `<img>` element.
/// Which manifest element the pointer is over in inspect mode, and which one
/// the builder form points at.
class _Inspector extends ChangeNotifier {
  void Function(String path)? onSelect;
  final _anchors = <_AnchorState>{};

  bool _enabled = false;
  bool get enabled => _enabled;
  set enabled(bool value) {
    if (value == _enabled) return;
    _enabled = value;
    _hovered = null;
    notifyListeners();
  }

  String? _highlight;
  String? get highlight => _highlight;
  set highlight(String? value) {
    if (value == _highlight) return;
    _highlight = value;
    notifyListeners();
    if (value == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = _anchors
          .where((anchor) => anchor.mounted && _related(anchor.path, value))
          .firstOrNull;
      if (target != null) {
        unawaited(
          Scrollable.ensureVisible(
            target.context,
            alignment: 0.5,
            duration: const Duration(milliseconds: 250),
          ),
        );
      }
    });
  }

  String? _hovered;

  bool active(String path) =>
      (_enabled && _hovered == path) ||
      (_highlight != null && _related(path, _highlight!));

  static bool _related(String anchor, String path) =>
      anchor == path ||
      path.startsWith('$anchor.') ||
      anchor.startsWith('$path.');

  /// The smallest anchor under [position], so a nested element wins over
  /// the one around it.
  String? _hit(Offset position) {
    _AnchorState? best;
    var bestArea = double.infinity;
    for (final anchor in _anchors) {
      final box = anchor.context.findRenderObject();
      if (!anchor.widget.enabled ||
          box is! RenderBox ||
          !box.attached ||
          !box.hasSize) {
        continue;
      }
      final rect = box.localToGlobal(Offset.zero) & box.size;
      final area = rect.width * rect.height;
      if (rect.contains(position) && area < bestArea) {
        best = anchor;
        bestArea = area;
      }
    }
    return best?.path;
  }

  void hover(Offset position) {
    final path = _hit(position);
    if (path == _hovered) return;
    _hovered = path;
    notifyListeners();
  }

  void tap(Offset position) {
    final path = _hit(position);
    if (path != null) onSelect?.call(path);
  }
}

/// In inspect mode the app underneath stops taking input; a tap names the
/// element under it instead.
class _InspectorScope extends StatelessWidget {
  const _InspectorScope({required this.inspector, required this.child});

  final _Inspector inspector;
  final Widget child;

  @override
  Widget build(BuildContext context) => _InspectorProvider(
    inspector: inspector,
    child: ListenableBuilder(
      listenable: inspector,
      builder: (context, child) => Listener(
        behavior: HitTestBehavior.translucent,
        onPointerHover: inspector.enabled
            ? (event) => inspector.hover(event.position)
            : null,
        onPointerDown: inspector.enabled
            ? (event) => inspector.hover(event.position)
            : null,
        onPointerUp: inspector.enabled
            ? (event) => inspector.tap(event.position)
            : null,
        child: MouseRegion(
          cursor: inspector.enabled
              ? SystemMouseCursors.click
              : MouseCursor.defer,
          child: AbsorbPointer(absorbing: inspector.enabled, child: child),
        ),
      ),
      child: child,
    ),
  );
}

class _InspectorProvider extends InheritedWidget {
  const _InspectorProvider({required this.inspector, required super.child});

  final _Inspector inspector;

  static _Inspector of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_InspectorProvider>()!.inspector;

  @override
  bool updateShouldNotify(_InspectorProvider oldWidget) =>
      inspector != oldWidget.inspector;
}

/// Marks the manifest element [path] around an app widget; it outlines it
/// while hovered in inspect mode or highlighted by the builder.
class _Anchor extends StatefulWidget {
  const _Anchor({required this.path, required this.child, this.enabled = true});

  final String path;
  final bool enabled;
  final Widget child;

  @override
  State<_Anchor> createState() => _AnchorState();
}

class _AnchorState extends State<_Anchor> {
  late final _Inspector _inspector = _InspectorProvider.of(context);

  String get path => widget.path;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _inspector._anchors.add(this);
  }

  @override
  void dispose() {
    _inspector._anchors.remove(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _inspector,
    builder: (context, child) => CustomPaint(
      foregroundPainter: widget.enabled && _inspector.active(path)
          ? _OutlinePainter(context.colorScheme.tertiary)
          : null,
      child: child,
    ),
    child: widget.child,
  );
}

class _OutlinePainter extends CustomPainter {
  const _OutlinePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(1);
    canvas.drawRect(rect, Paint()..color = color.withValues(alpha: 0.08));
    AppShape.md
        .copyWith(side: BorderSide(color: color, width: 2))
        .paint(canvas, rect);
  }

  @override
  bool shouldRepaint(_OutlinePainter oldDelegate) => oldDelegate.color != color;
}
