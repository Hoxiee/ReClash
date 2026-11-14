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
  static const _maxContentWidth = 680.0;

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
    final cards = rails.isEmpty
        ? null
        : _Section(
            title: appLocalizations.donateCards,
            footer: cryptoFirst ? appLocalizations.donateCardsAbroad : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                if (!cryptoFirst)
                  _FeaturedRail(
                    rail: rails.first,
                    url: config.links[rails.first] ?? '',
                    regionCode: regionCode,
                  ),
                if (rails.length > (cryptoFirst ? 0 : 1))
                  generateGroup([
                    for (final rail in rails.skip(cryptoFirst ? 0 : 1))
                      _RailItem(rail: rail, url: config.links[rail] ?? ''),
                  ]),
              ],
            ),
          );
    return CommonScaffold(
      title: appLocalizations.donate,
      body: LayoutBuilder(
        builder: (context, constraints) => ListView(
          padding:
              EdgeInsets.symmetric(
                horizontal: math.max(
                  16,
                  (constraints.maxWidth - _maxContentWidth) / 2,
                ),
              ).copyWith(
                top: context.contentTopPadding,
                bottom: 32 + context.bottomInset,
              ) +
              context.bodyInsets,
          children: [
            const _DonateHero(),
            ...(cryptoFirst ? [crypto, cards] : [cards, crypto]),
            _Section(
              title: appLocalizations.donateWithoutMoney,
              child: const _FreeHelp(),
            ),
            const _Thanks(),
          ].nonNulls.toList(),
        ),
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
  const _DonateHero();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final appLocalizations = context.appLocalizations;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 4),
      child: Column(
        children: [
          const _BeatingHeart(),
          const SizedBox(height: 2),
          Text(
            appLocalizations.donateHeroTitle,
            textAlign: TextAlign.center,
            style: AppTextStyle.title2.of(context, emphasized: true),
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Text(
              appLocalizations.donateHeroBody,
              textAlign: TextAlign.center,
              style: AppTextStyle.subheadline
                  .of(context)
                  .copyWith(color: colorScheme.onSurfaceVariant, height: 1.5),
            ),
          ),
        ],
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
    with SingleTickerProviderStateMixin {
  static const _size = 96.0;
  static const _glow = 148.0;

  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return GestureDetector(
      onTap: MediaQuery.disableAnimationsOf(context) ? null : _beat,
      child: SizedBox.square(
        dimension: _glow,
        child: Stack(
          alignment: Alignment.center,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    colorScheme.primary.withValues(alpha: 0.3),
                    colorScheme.primary.withValues(alpha: 0),
                  ],
                ),
              ),
              child: const SizedBox.square(dimension: _glow),
            ),
            ScaleTransition(
              scale: _scale,
              child: DecoratedBox(
                decoration: ShapeDecoration(
                  color: context.raisedSurfaceLevel.colorOf(colorScheme),
                  shape: AppShape.all(AppCorner.fit(_size)),
                ),
                child: SizedBox.square(
                  dimension: _size,
                  child: Center(
                    child: GlyphIcon(
                      AppGlyphs.heart,
                      size: 48,
                      fill: 1,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
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
  final Glyph glyph;
  final double size;
  final Color? color;

  const _GlyphWell({required this.glyph, this.size = 40, this.color});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: context.raisedSurfaceLevel.colorOf(colorScheme),
        shape: AppShape.all(AppCorner.fit(size)),
      ),
      child: SizedBox.square(
        dimension: size,
        child: Center(
          child: GlyphIcon(
            glyph,
            size: size / 2,
            color: color ?? colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _FeaturedRail extends StatelessWidget {
  final DonationRail rail;
  final String url;
  final String? regionCode;

  const _FeaturedRail({
    required this.rail,
    required this.url,
    required this.regionCode,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final appLocalizations = context.appLocalizations;
    final onPressed = url.isEmpty
        ? null
        : () => unawaited(dialogs.openUrl(url));
    return CommonCard(
      shape: AppShape.xl,
      padding: const EdgeInsets.all(16),
      onPressed: onPressed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          Row(
            spacing: 14,
            children: [
              _GlyphWell(
                glyph: rail.glyph,
                size: 52,
                color: colorScheme.primary,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    _RecommendedLabel(regionCode: regionCode),
                    Text(
                      rail.title,
                      style: AppTextStyle.title3.of(context, emphasized: true),
                    ),
                    Text(
                      url.isEmpty
                          ? appLocalizations.donateNotConfigured
                          : rail.description(appLocalizations),
                      style: AppTextStyle.footnote
                          .of(context)
                          .copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
          FilledButton.icon(
            onPressed: onPressed,
            icon: const GlyphIcon(AppGlyphs.heart, fill: 1),
            label: Text(appLocalizations.donateAction),
          ),
        ],
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

  late String _id = widget.wallets.first.id;

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
    if (mounted) {
      context.showNotifier(
        context.appLocalizations.copySuccess,
        level: MessageLevel.success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final wallet = _wallet;
    final recommendedIn = widget.recommendedIn;
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
          if (_sameCoin(wallet).length > 1)
            SegmentedControl<String>(
              segments: [
                for (final other in _sameCoin(wallet))
                  (other.id, other.network),
              ],
              value: wallet.id,
              onChanged: (id) => setState(() => _id = id),
            ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            layoutBuilder: (current, previous) => Stack(
              alignment: Alignment.topCenter,
              children: [...previous, ?current],
            ),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween(begin: 0.96, end: 1.0).animate(animation),
                child: child,
              ),
            ),
            child: LayoutBuilder(
              key: ValueKey(wallet.id),
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= _wideLayout;
                final code = _WalletCode(
                  wallet: wallet,
                  size: wide ? 168 : 200,
                );
                final details = _WalletDetails(
                  wallet: wallet,
                  wide: wide,
                  onCopy: wallet.isConfigured ? () => _copy(wallet) : null,
                );
                return wide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 20,
                        children: [
                          code,
                          Expanded(child: details),
                        ],
                      )
                    : Column(spacing: 16, children: [code, details]);
              },
            ),
          ),
        ],
      ),
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
  final bool wide;
  final VoidCallback? onCopy;

  const _WalletDetails({
    required this.wallet,
    required this.wide,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final appLocalizations = context.appLocalizations;
    final align = wide ? CrossAxisAlignment.start : CrossAxisAlignment.center;
    final textAlign = wide ? TextAlign.start : TextAlign.center;
    return Column(
      crossAxisAlignment: align,
      spacing: 10,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: [
            Text(
              wallet.coin,
              style: AppTextStyle.title3.of(context, emphasized: true),
            ),
            _NetworkChip(network: wallet.network),
          ],
        ),
        DecoratedBox(
          decoration: ShapeDecoration(
            color: context.raisedSurfaceLevel.colorOf(colorScheme),
            shape: AppShape.md,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: wallet.isConfigured
                ? SelectableText(
                    wallet.address,
                    textAlign: textAlign,
                    style: AppTextStyle.footnote
                        .of(context)
                        .copyWith(
                          fontFamily: FontFamily.jetBrainsMono.value,
                          color: colorScheme.onSurface,
                          height: 1.45,
                        ),
                  )
                : Text(
                    appLocalizations.donateNotConfigured,
                    textAlign: textAlign,
                    style: AppTextStyle.footnote
                        .of(context)
                        .copyWith(color: colorScheme.onSurfaceVariant),
                  ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            GlyphIcon(AppGlyphs.warning, size: 18, color: colorScheme.warning),
            Flexible(
              child: Text(
                appLocalizations.donateNetworkWarning(
                  wallet.coin,
                  wallet.network,
                ),
                style: AppTextStyle.footnote
                    .of(context)
                    .copyWith(color: colorScheme.onSurface),
              ),
            ),
          ],
        ),
        TonalButton(
          glyph: AppGlyphs.copy,
          label: appLocalizations.donateCopyAddress,
          onPressed: onCopy,
        ),
      ],
    );
  }
}

class _NetworkChip extends StatelessWidget {
  final String network;

  const _NetworkChip({required this.network});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: colorScheme.warningContainer,
        shape: AppShape.full,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        child: Text(
          network,
          style: AppTextStyle.caption1
              .of(context, emphasized: true)
              .copyWith(color: colorScheme.onWarningContainer),
        ),
      ),
    );
  }
}

class _FreeHelp extends StatelessWidget {
  const _FreeHelp();

  static const _minTileWidth = 150.0;
  static const _gap = 12.0;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final tiles = [
      _FreeHelpTile(
        glyph: AppGlyphs.star,
        title: appLocalizations.donateStar,
        subtitle: appLocalizations.donateStarDesc,
        url: 'https://github.com/$repository',
      ),
      _FreeHelpTile(
        glyph: AppGlyphs.compose,
        title: appLocalizations.donateReport,
        subtitle: appLocalizations.donateReportDesc,
        url: 'https://github.com/$repository/issues/new/choose',
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(16) / 16;
        if (constraints.maxWidth < _minTileWidth * textScale * 2 + _gap) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: _gap,
            children: tiles,
          );
        }
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: _gap,
            children: [for (final tile in tiles) Expanded(child: tile)],
          ),
        );
      },
    );
  }
}

class _FreeHelpTile extends StatelessWidget {
  final Glyph glyph;
  final String title;
  final String subtitle;
  final String url;

  const _FreeHelpTile({
    required this.glyph,
    required this.title,
    required this.subtitle,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return CommonCard(
      shape: AppShape.lg,
      padding: const EdgeInsets.all(14),
      onPressed: () => unawaited(dialogs.openUrl(url)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _GlyphWell(glyph: glyph, size: 36),
              GlyphIcon(
                AppGlyphs.openExternal,
                size: 16,
                fill: 1,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTextStyle.subheadline.of(context, emphasized: true),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppTextStyle.caption1
                .of(context)
                .copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
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
