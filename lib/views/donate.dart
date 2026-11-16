import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/common/regional/country_profile.dart';
import 'package:reclash/common/regional/region_labels.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';

enum DonationRail { tribute, cloudTips, sponsors }

@immutable
class CryptoWallet {
  final String coin;
  final String network;
  final String address;

  const CryptoWallet({
    required this.coin,
    required this.network,
    required this.address,
  });

  String get id => '$coin $network';

  bool get isConfigured => address.isNotEmpty;
}

@immutable
class DonationConfig {
  final Map<DonationRail, String> links;
  final List<CryptoWallet> wallets;

  const DonationConfig({required this.links, required this.wallets});

  // An empty link or address is a method not set up yet: release builds hide
  // it, debug builds show it as a placeholder so the layout can be checked.
  static const current = DonationConfig(
    links: {
      DonationRail.tribute:
          'https://t.me/tribute/app?startapp=ep_7qtVRlHbQFPp9Q102lRpmDz6n9juUbUnYZsj4rdOjmQzInlH28',
      DonationRail.cloudTips: '',
      DonationRail.sponsors: '',
    },
    wallets: [
      CryptoWallet(
        coin: 'USDT',
        network: 'TRC20',
        address: 'TBoYpUerrafTykTTZpH1ALB7EPr3SAZ35q',
      ),
      CryptoWallet(
        coin: 'USDT',
        network: 'TON',
        address: 'UQA3bMETqY5D04sdhH9RZOA9JOjAFMgwa91R_RYmVZoolMHy',
      ),
      CryptoWallet(
        coin: 'TON',
        network: 'TON',
        address: 'UQBRPR6ljp4rtevQ4_9rXDsMCoNIJCpw96jbWJOVjOM2WxQF',
      ),
      CryptoWallet(
        coin: 'BTC',
        network: 'Bitcoin',
        address: 'bc1q3xcrygxl487zdkvg40l9pp64dqua7aksp9z00m',
      ),
    ],
  );

  bool get hasAny =>
      links.values.any((url) => url.isNotEmpty) ||
      wallets.any((wallet) => wallet.isConfigured);

  List<DonationRail> railsFor(
    String? regionCode, {
    required bool includeUnconfigured,
  }) => [
    for (final rail in donationRailOrder(regionCode))
      if (includeUnconfigured || (links[rail] ?? '').isNotEmpty) rail,
  ];

  List<CryptoWallet> visibleWallets({required bool includeUnconfigured}) => [
    for (final wallet in wallets)
      if (includeUnconfigured || wallet.isConfigured) wallet,
  ];
}

/// Russian cards reach only Russian rails; elsewhere an international card
/// goes through Sponsors first.
List<DonationRail> donationRailOrder(String? regionCode) =>
    switch (regionCode) {
      'RU' => const [
        DonationRail.tribute,
        DonationRail.cloudTips,
        DonationRail.sponsors,
      ],
      _ => const [
        DonationRail.sponsors,
        DonationRail.tribute,
        DonationRail.cloudTips,
      ],
    };

/// Iranian and Chinese cards cannot pay abroad, so crypto leads there.
bool donationPrefersCrypto(String? regionCode) =>
    regionCode == 'IR' || regionCode == 'CN';

bool get showsDonations => kDebugMode || DonationConfig.current.hasAny;

class DonateView extends ConsumerWidget {
  final DonationConfig config;
  final bool includeUnconfigured;

  const DonateView({
    super.key,
    this.config = DonationConfig.current,
    this.includeUnconfigured = kDebugMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final regionCode = ref.watch(
      appSettingProvider.select((state) => state.regionCode),
    );
    final rails = config.railsFor(
      regionCode,
      includeUnconfigured: includeUnconfigured,
    );
    final wallets = config.visibleWallets(
      includeUnconfigured: includeUnconfigured,
    );
    final cryptoFirst = donationPrefersCrypto(regionCode) || rails.isEmpty;
    final featured = cryptoFirst ? null : rails.first;
    final otherRails = rails.skip(featured == null ? 0 : 1).toList();
    final crypto = wallets.isEmpty
        ? null
        : _Section(
            title: appLocalizations.donateCrypto,
            footer: appLocalizations.donateCryptoFooter,
            child: _CryptoCard(
              wallets: wallets,
              recommendedIn: cryptoFirst ? regionCode : null,
            ),
          );
    final cards = otherRails.isEmpty
        ? null
        : _Section(
            title: appLocalizations.donateCards,
            footer: cryptoFirst ? appLocalizations.donateCardsAbroad : null,
            child: generateGroup([
              for (final rail in otherRails)
                _RailItem(rail: rail, url: config.links[rail] ?? ''),
            ]),
          );
    return CommonScaffold(
      title: appLocalizations.donate,
      body: ListView(
        // The Tools workspace already centers a page inside its own cap.
        padding:
            const EdgeInsets.symmetric(horizontal: 16).copyWith(
              top: context.contentTopPadding,
              bottom: 32 + context.bottomInset,
            ) +
            context.bodyInsets,
        children: [
          _DonateHero(
            action: featured == null
                ? null
                : _HeroAction(
                    rail: featured,
                    url: config.links[featured] ?? '',
                    regionCode: regionCode,
                  ),
          ),
          ...(cryptoFirst ? [crypto, cards] : [cards, crypto]),
          _Section(
            title: appLocalizations.donateWithoutMoney,
            child: const _FreeHelp(),
          ),
          const _Thanks(),
        ].nonNulls.toList(),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String? footer;
  final Widget child;

  const _Section({required this.title, this.footer, required this.child});

  @override
  Widget build(BuildContext context) {
    final footer = this.footer;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListHeader(title: title),
        child,
        if (footer != null) ListFooter(text: footer),
      ],
    );
  }
}

class _DonateHero extends StatelessWidget {
  final Widget? action;

  const _DonateHero({required this.action});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final appLocalizations = context.appLocalizations;
    final action = this.action;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Column(
        children: [
          const _BeatingHeart(),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              children: [
                Text(
                  appLocalizations.donateHeroTitle,
                  textAlign: TextAlign.center,
                  style: AppTextStyle.title1.of(context, emphasized: true),
                ),
                const SizedBox(height: 10),
                Text(
                  appLocalizations.donateHeroBody,
                  textAlign: TextAlign.center,
                  style: AppTextStyle.subheadline
                      .of(context)
                      .copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 8,
            children: [
              _Promise(
                glyph: AppGlyphs.block,
                label: appLocalizations.donatePromiseNoAds,
              ),
              _Promise(
                glyph: AppGlyphs.eyeOff,
                label: appLocalizations.donatePromiseNoTracking,
              ),
              _Promise(
                glyph: AppGlyphs.code,
                label: appLocalizations.donatePromiseOpenSource,
              ),
            ],
          ),
          if (action != null) ...[const SizedBox(height: 28), action],
        ],
      ),
    );
  }
}

class _HeroAction extends StatelessWidget {
  final DonationRail rail;
  final String url;
  final String? regionCode;

  const _HeroAction({
    required this.rail,
    required this.url,
    required this.regionCode,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final appLocalizations = context.appLocalizations;
    final style = AppTextStyle.footnote
        .of(context)
        .copyWith(color: colorScheme.onSurfaceVariant);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton.icon(
            onPressed: url.isEmpty
                ? null
                : () => unawaited(dialogs.openUrl(url)),
            style: FilledButton.styleFrom(minimumSize: const Size(0, 52)),
            icon: const GlyphIcon(AppGlyphs.heart, fill: 1),
            label: Text(appLocalizations.donateAction),
          ),
          const SizedBox(height: 12),
          Center(child: _RecommendedLabel(regionCode: regionCode)),
          const SizedBox(height: 2),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: rail.title,
                  style: AppTextStyle.footnote
                      .of(context, emphasized: true)
                      .copyWith(color: colorScheme.onSurface),
                ),
                TextSpan(
                  text:
                      ' · ${url.isEmpty ? appLocalizations.donateNotConfigured : rail.description(appLocalizations)}',
                ),
              ],
            ),
            textAlign: TextAlign.center,
            style: style,
          ),
        ],
      ),
    );
  }
}

class _Promise extends StatelessWidget {
  final Glyph glyph;
  final String label;

  const _Promise({required this.glyph, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: context.raisedSurfaceLevel.colorOf(colorScheme),
        shape: AppShape.full,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 5, 10, 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 5,
          children: [
            GlyphIcon(glyph, size: 15, color: colorScheme.onSurfaceVariant),
            Text(
              label,
              style: AppTextStyle.caption1.of(context, emphasized: true),
            ),
          ],
        ),
      ),
    );
  }
}

class _BeatingHeart extends StatefulWidget {
  const _BeatingHeart();

  @override
  State<_BeatingHeart> createState() => _BeatingHeartState();
}

class _BeatingHeartState extends State<_BeatingHeart>
    with TickerProviderStateMixin {
  static const _heart = 84.0;
  static const _glow = 220.0;
  static const _height = 176.0;
  static const _sparks = 7;

  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  late final _burst = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  var _burstSeed = 0;

  late final Animation<double> _scale = TweenSequence([
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.14), weight: 12),
    TweenSequenceItem(tween: Tween(begin: 1.14, end: 0.98), weight: 12),
    TweenSequenceItem(tween: Tween(begin: 0.98, end: 1.1), weight: 10),
    TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 22),
    TweenSequenceItem(tween: ConstantTween(1.0), weight: 44),
  ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!MediaQuery.disableAnimationsOf(context) &&
        _controller.status == AnimationStatus.dismissed) {
      unawaited(_beat(times: 2));
    }
  }

  Future<void> _beat({int times = 1}) async {
    for (var i = 0; i < times && mounted; i++) {
      try {
        await _controller.forward(from: 0).orCancel;
      } on TickerCanceled {
        return;
      }
    }
  }

  void _tap() {
    unawaited(_beat());
    setState(() => _burstSeed++);
    unawaited(_burst.forward(from: 0));
  }

  @override
  void dispose() {
    _controller.dispose();
    _burst.dispose();
    super.dispose();
  }

  Widget _spark(int index, Color color) {
    final random = math.Random(_burstSeed * _sparks + index);
    final drift = (random.nextDouble() * 2 - 1) * 56;
    final rise = 56 + random.nextDouble() * 40;
    final size = 12 + random.nextDouble() * 10;
    final delay = index / _sparks * 0.3;
    return AnimatedBuilder(
      animation: _burst,
      builder: (context, child) {
        final t = ((_burst.value - delay) / (1 - delay)).clamp(0.0, 1.0);
        if (t == 0 || t == 1) return const SizedBox.shrink();
        final travel = Curves.easeOutCubic.transform(t);
        return Opacity(
          opacity: t < 0.15 ? t / 0.15 : 1 - Curves.easeIn.transform(t),
          child: Transform.translate(
            offset: Offset(drift * travel, -rise * travel),
            child: Transform.scale(scale: 0.6 + 0.4 * travel, child: child),
          ),
        );
      },
      child: GlyphIcon(AppGlyphs.heart, size: size, fill: 1, color: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return GestureDetector(
      onTap: MediaQuery.disableAnimationsOf(context) ? null : _tap,
      child: SizedBox(
        width: _glow,
        height: _height,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            ScaleTransition(
              scale: _scale,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      colorScheme.primary.withValues(alpha: 0.32),
                      colorScheme.primary.withValues(alpha: 0.1),
                      colorScheme.primary.withValues(alpha: 0),
                    ],
                    stops: const [0, 0.45, 1],
                  ),
                ),
                child: const SizedBox.square(dimension: _glow),
              ),
            ),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final wave = (_controller.value / 0.6).clamp(0.0, 1.0);
                if (wave == 0 || wave == 1) return const SizedBox.shrink();
                final spread = Curves.easeOutCubic.transform(wave);
                return DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.primary.withValues(
                      alpha: 0.22 * (1 - wave),
                    ),
                  ),
                  child: SizedBox.square(
                    dimension: _heart + (_glow - _heart) * spread,
                  ),
                );
              },
            ),
            for (var i = 0; i < _sparks; i++)
              _spark(i, i.isEven ? colorScheme.primary : colorScheme.tertiary),
            ScaleTransition(
              scale: _scale,
              child: GlyphIcon(
                AppGlyphs.heart,
                size: _heart,
                fill: 1,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension on DonationRail {
  Glyph get glyph => switch (this) {
    DonationRail.tribute => AppGlyphs.send,
    DonationRail.cloudTips => AppGlyphs.card,
    DonationRail.sponsors => AppGlyphs.heart,
  };

  String get title => switch (this) {
    DonationRail.tribute => 'Tribute',
    DonationRail.cloudTips => 'CloudTips',
    DonationRail.sponsors => 'GitHub Sponsors',
  };

  String description(AppLocalizations l) => switch (this) {
    DonationRail.tribute => l.donateTributeDesc,
    DonationRail.cloudTips => l.donateCloudTipsDesc,
    DonationRail.sponsors => l.donateSponsorsDesc,
  };
}

class _GlyphWell extends StatelessWidget {
  static const _size = 40.0;

  final Glyph glyph;

  const _GlyphWell({required this.glyph});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: context.raisedSurfaceLevel.colorOf(colorScheme),
        shape: AppShape.all(AppCorner.fit(_size)),
      ),
      child: SizedBox.square(
        dimension: _size,
        child: Center(
          child: GlyphIcon(
            glyph,
            size: _size / 2,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _RecommendedLabel extends StatelessWidget {
  final String? regionCode;

  const _RecommendedLabel({required this.regionCode});

  @override
  Widget build(BuildContext context) {
    final regionCode = this.regionCode;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        if (regionCode != null && regionCode != otherRegionCode)
          Text(
            regionFlag(regionCode),
            style: AppTextStyle.custom(
              context,
              size: 16,
              leading: 18,
            ).copyWith(fontFamily: FontFamily.twEmoji.value),
          ),
        Flexible(
          child: Text(
            context.appLocalizations.donateRecommended,
            style: AppTextStyle.footnote
                .of(context, emphasized: true)
                .copyWith(color: context.colorScheme.primary),
          ),
        ),
      ],
    );
  }
}

class _RailItem extends StatelessWidget {
  final DonationRail rail;
  final String url;

  const _RailItem({required this.rail, required this.url});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return ListItem(
      leading: _GlyphWell(glyph: rail.glyph),
      title: Text(rail.title),
      subtitle: Text(
        url.isEmpty
            ? appLocalizations.donateNotConfigured
            : rail.description(appLocalizations),
      ),
      trailing: const GlyphIcon(AppGlyphs.openExternal),
      onTap: url.isEmpty ? null : () => unawaited(dialogs.openUrl(url)),
    );
  }
}

class _CryptoCard extends StatefulWidget {
  final List<CryptoWallet> wallets;
  final String? recommendedIn;

  const _CryptoCard({required this.wallets, required this.recommendedIn});

  @override
  State<_CryptoCard> createState() => _CryptoCardState();
}

class _CryptoCardState extends State<_CryptoCard> {
  static const _wideLayout = 520.0;
  static const _copiedHold = Duration(seconds: 2);

  late String _id = widget.wallets.first.id;
  String? _copiedId;
  Timer? _copiedTimer;

  CryptoWallet get _wallet => widget.wallets.firstWhere(
    (wallet) => wallet.id == _id,
    orElse: () => widget.wallets.first,
  );

  List<String> get _coins =>
      {for (final wallet in widget.wallets) wallet.coin}.toList();

  List<CryptoWallet> _sameCoin(CryptoWallet wallet) => [
    for (final other in widget.wallets)
      if (other.coin == wallet.coin) other,
  ];

  Future<void> _copy(CryptoWallet wallet) async {
    await Clipboard.setData(ClipboardData(text: wallet.address));
    if (!mounted) return;
    _copiedTimer?.cancel();
    _copiedTimer = Timer(_copiedHold, () {
      if (mounted) setState(() => _copiedId = null);
    });
    setState(() => _copiedId = wallet.id);
  }

  @override
  void dispose() {
    _copiedTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wallet = _wallet;
    final recommendedIn = widget.recommendedIn;
    final onCopy = wallet.isConfigured ? () => unawaited(_copy(wallet)) : null;
    return CommonCard(
      shape: AppShape.xl,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          if (recommendedIn != null)
            _RecommendedLabel(regionCode: recommendedIn),
          if (_coins.length > 1)
            SegmentedControl<String>(
              segments: [for (final coin in _coins) (coin, coin)],
              value: wallet.coin,
              onChanged: (coin) => setState(
                () => _id = widget.wallets
                    .firstWhere((wallet) => wallet.coin == coin)
                    .id,
              ),
            ),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= _wideLayout;
              final code = _Swap(
                id: wallet.id,
                child: _WalletCode(wallet: wallet, size: wide ? 176 : 184),
              );
              final details = _WalletDetails(
                wallet: wallet,
                networks: _sameCoin(wallet),
                wide: wide,
                copied: _copiedId == wallet.id,
                onCopy: onCopy,
                onNetwork: (id) => setState(() => _id = id),
              );
              return wide
                  ? Row(
                      spacing: 20,
                      children: [
                        code,
                        Expanded(child: details),
                      ],
                    )
                  : Column(spacing: 16, children: [code, details]);
            },
          ),
        ],
      ),
    );
  }
}

class _Swap extends StatelessWidget {
  final Object id;
  final Widget child;

  const _Swap({required this.id, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 240),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (current, previous) =>
          Stack(alignment: Alignment.center, children: [...previous, ?current]),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween(begin: 0.96, end: 1.0).animate(animation),
          child: child,
        ),
      ),
      child: KeyedSubtree(key: ValueKey(id), child: child),
    );
  }
}

class _WalletCode extends StatelessWidget {
  final CryptoWallet wallet;
  final double size;

  const _WalletCode({required this.wallet, required this.size});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    if (wallet.isConfigured) {
      return SizedBox.square(
        dimension: size,
        child: QrCodeView(data: wallet.address, size: size),
      );
    }
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: context.raisedSurfaceLevel.colorOf(colorScheme),
        shape: AppShape.md,
      ),
      child: SizedBox.square(
        dimension: size,
        child: Center(
          child: GlyphIcon(
            AppGlyphs.qrCode,
            size: size / 3,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}

class _WalletDetails extends StatelessWidget {
  final CryptoWallet wallet;
  final List<CryptoWallet> networks;
  final bool wide;
  final bool copied;
  final VoidCallback? onCopy;
  final ValueChanged<String> onNetwork;

  const _WalletDetails({
    required this.wallet,
    required this.networks,
    required this.wide,
    required this.copied,
    required this.onCopy,
    required this.onNetwork,
  });

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final alignment = wide
        ? AlignmentDirectional.centerStart
        : Alignment.center;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Align(
          alignment: alignment,
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 2),
                child: Text(
                  wallet.coin,
                  style: AppTextStyle.title3.of(context, emphasized: true),
                ),
              ),
              for (final network in networks)
                _NetworkChip(
                  network: network.network,
                  selected: network.id == wallet.id,
                  onTap: networks.length > 1
                      ? () => onNetwork(network.id)
                      : null,
                ),
            ],
          ),
        ),
        _Swap(
          id: wallet.id,
          child: _AddressField(
            wallet: wallet,
            centered: !wide,
            copied: copied,
            onCopy: onCopy,
          ),
        ),
        _NetworkWarning(
          text: appLocalizations.donateNetworkWarning(
            wallet.coin,
            wallet.network,
          ),
        ),
        Align(
          alignment: alignment,
          child: TonalButton(
            glyph: copied ? AppGlyphs.check : AppGlyphs.copy,
            label: copied
                ? appLocalizations.donateCopied
                : appLocalizations.donateCopyAddress,
            onPressed: onCopy,
          ),
        ),
      ],
    );
  }
}

class _AddressField extends StatelessWidget {
  final CryptoWallet wallet;
  final bool centered;
  final bool copied;
  final VoidCallback? onCopy;

  const _AddressField({
    required this.wallet,
    required this.centered,
    required this.copied,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final configured = wallet.isConfigured;
    return Material(
      color: context.raisedSurfaceLevel.colorOf(colorScheme),
      shape: AppShape.md,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onCopy,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
          child: Row(
            spacing: 12,
            children: [
              Expanded(
                child: Text(
                  configured
                      ? wallet.address
                      : context.appLocalizations.donateNotConfigured,
                  textAlign: centered ? TextAlign.center : TextAlign.start,
                  style: configured
                      ? AppTextStyle.footnote
                            .of(context)
                            .copyWith(
                              fontFamily: FontFamily.jetBrainsMono.value,
                              color: colorScheme.onSurface,
                              height: 1.45,
                            )
                      : AppTextStyle.footnote
                            .of(context)
                            .copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ),
              if (configured)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: GlyphIcon(
                    copied ? AppGlyphs.check : AppGlyphs.copy,
                    key: ValueKey(copied),
                    size: 18,
                    color: copied
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NetworkChip extends StatelessWidget {
  final String network;
  final bool selected;
  final VoidCallback? onTap;

  const _NetworkChip({
    required this.network,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Semantics(
      selected: selected,
      button: onTap != null,
      child: Material(
        color: selected
            ? colorScheme.warningContainer
            : context.raisedSurfaceLevel.colorOf(colorScheme),
        shape: AppShape.full,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            child: Text(
              network,
              style: AppTextStyle.caption1
                  .of(context, emphasized: true)
                  .copyWith(
                    color: selected
                        ? colorScheme.onWarningContainer
                        : colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NetworkWarning extends StatelessWidget {
  final String text;

  const _NetworkWarning({required this.text});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          GlyphIcon(AppGlyphs.warning, size: 18, color: colorScheme.warning),
          Expanded(
            child: Text(
              text,
              style: AppTextStyle.footnote
                  .of(context)
                  .copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

class _FreeHelp extends StatelessWidget {
  const _FreeHelp();

  Future<void> _copyLink(BuildContext context) async {
    await Clipboard.setData(
      const ClipboardData(text: 'https://github.com/$repository'),
    );
    if (context.mounted) {
      context.showNotifier(
        context.appLocalizations.copySuccess,
        level: MessageLevel.success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return generateGroup([
      ListItem(
        leading: const _GlyphWell(glyph: AppGlyphs.star),
        title: Text(appLocalizations.donateStar),
        subtitle: Text(appLocalizations.donateStarDesc),
        trailing: const GlyphIcon(AppGlyphs.openExternal),
        onTap: () =>
            unawaited(dialogs.openUrl('https://github.com/$repository')),
      ),
      ListItem(
        leading: const _GlyphWell(glyph: AppGlyphs.compose),
        title: Text(appLocalizations.donateReport),
        subtitle: Text(appLocalizations.donateReportDesc),
        trailing: const GlyphIcon(AppGlyphs.openExternal),
        onTap: () => unawaited(
          dialogs.openUrl('https://github.com/$repository/issues/new/choose'),
        ),
      ),
      ListItem(
        leading: const _GlyphWell(glyph: AppGlyphs.megaphone),
        title: Text(appLocalizations.donateShare),
        subtitle: Text(appLocalizations.donateShareDesc),
        trailing: const GlyphIcon(AppGlyphs.copy),
        onTap: () => unawaited(_copyLink(context)),
      ),
    ]);
  }
}

class _Thanks extends StatelessWidget {
  const _Thanks();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
      child: Column(
        spacing: 8,
        children: [
          GlyphIcon(
            AppGlyphs.heart,
            size: 18,
            fill: 1,
            color: colorScheme.primary.withValues(alpha: 0.7),
          ),
          Text(
            context.appLocalizations.donateThanks,
            textAlign: TextAlign.center,
            style: AppTextStyle.footnote
                .of(context)
                .copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
