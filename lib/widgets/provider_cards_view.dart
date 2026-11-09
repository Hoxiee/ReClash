import 'dart:async';
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/subscriptions/metadata/metadata.dart';
import 'package:reclash/subscriptions/metadata/provider_cards.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/widgets/provider_image.dart';

const _bannerRatio = 16 / 9;
const _splitImageExtent = 120.0;
const _heroMaxHeight = 320.0;
const _scrimFade = 48.0;

/// The provider's own link behind an `app` action, null while it has not set
/// one or the action is not a link.
Uri? providerAppLink(SubscriptionMetadata? metadata, ProviderAppAction action) {
  final (path, support) = switch (action) {
    ProviderAppAction.support => ('provider.supportUrl', true),
    ProviderAppAction.website => ('provider.webUrl', false),
    ProviderAppAction.renew => ('provider.buyPlanUrl', false),
    ProviderAppAction.topUp => ('provider.buyTrafficUrl', false),
    _ => (null, false),
  };
  final value = path == null ? null : metadata?.text(path);
  if (value == null) return null;
  return support
      ? safeSubscriptionSupportLink(value)
      : safeSubscriptionLink(value);
}

bool _isLinkAction(ProviderAppAction action) => switch (action) {
  ProviderAppAction.support ||
  ProviderAppAction.website ||
  ProviderAppAction.renew ||
  ProviderAppAction.topUp => true,
  _ => false,
};

bool providerActionAvailable(
  SubscriptionMetadata? metadata,
  ProviderAction? action,
) =>
    action == null ||
    action.kind != ProviderActionKind.app ||
    !_isLinkAction(action.app!) ||
    providerAppLink(metadata, action.app!) != null;

Glyph _glyphOf(String icon) => switch (icon) {
  'support' || 'help' || 'chat' => AppGlyphs.support,
  'speed' => AppGlyphs.speed,
  'link' || 'open' => AppGlyphs.link,
  'copy' => AppGlyphs.copy,
  'share' => AppGlyphs.export,
  'refresh' || 'update' || 'sync' => AppGlyphs.refresh,
  'info' => AppGlyphs.info,
  'warning' => AppGlyphs.warning,
  'star' => AppGlyphs.star,
  'bolt' => AppGlyphs.bolt,
  'key' => AppGlyphs.key,
  'lock' => AppGlyphs.lock,
  'gift' || 'sparkle' => AppGlyphs.sparkle,
  'web' || 'website' || 'globe' => AppGlyphs.language,
  'send' || 'telegram' => AppGlyphs.send,
  'download' => AppGlyphs.cloudDownload,
  'doctor' || 'tools' => AppGlyphs.wrench,
  'clock' || 'renew' => AppGlyphs.clock,
  'account' => AppGlyphs.account,
  _ => AppGlyphs.layers,
};

/// The provider's cards in file order; [cards] are the ones its conditions
/// and the user's dismissals leave.
class ProviderCardsView extends StatefulWidget {
  const ProviderCardsView({
    super.key,
    required this.cards,
    required this.metadata,
    required this.images,
    required this.onAction,
    required this.onDismiss,
    this.gap = 12,
  });

  final List<ProviderCard> cards;
  final SubscriptionMetadata? metadata;
  final ProviderImages images;
  final void Function(ProviderAction action) onAction;
  final void Function(ProviderCard card) onDismiss;
  final double gap;

  @override
  State<ProviderCardsView> createState() => _ProviderCardsViewState();
}

class _ProviderCardsViewState extends State<ProviderCardsView> {
  final _failedImages = <String>{};

  /// A card that draws nothing must leave the column, or its spacing stays.
  bool _draws(ProviderCard card, SubscriptionMetadata? metadata) =>
      !_failedImages.contains(providerCardDismissId(card)) &&
      switch (card) {
        ProviderNote() => true,
        ProviderActions() => card.items.any(
          (item) => providerActionAvailable(metadata, item.action),
        ),
        ProviderBanner() =>
          (card.layout != ProviderBannerLayout.image ||
                  card.image != null ||
                  card.imageDark != null) &&
              (card.countdown == null ||
                  card.countdown! >
                      DateTime.now().millisecondsSinceEpoch ~/ 1000),
      };

  @override
  Widget build(BuildContext context) {
    final metadata = widget.metadata;
    final cards = widget.cards.where((card) => _draws(card, metadata)).toList();
    if (cards.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: widget.gap,
      children: [
        for (final card in cards)
          KeyedSubtree(
            key: ValueKey(providerCardDismissId(card)),
            child: switch (card) {
              ProviderNote() => _NoteCard(card, scope: widget),
              ProviderBanner() => _BannerCard(
                card,
                scope: widget,
                onImageFailed: () => setState(
                  () => _failedImages.add(providerCardDismissId(card)),
                ),
              ),
              ProviderActions() => _ActionsCard(card, scope: widget),
            },
          ),
      ],
    );
  }
}

class _DismissButton extends StatelessWidget {
  const _DismissButton(this.card, {required this.scope, this.color});

  final ProviderCard card;
  final ProviderCardsView scope;
  final Color? color;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: AppLocalizations.of(context).close,
    icon: GlyphIcon(AppGlyphs.close, size: 18, color: color),
    onPressed: () => scope.onDismiss(card),
  );
}

class _NoteCard extends StatelessWidget {
  const _NoteCard(this.card, {required this.scope});

  final ProviderNote card;
  final ProviderCardsView scope;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final critical = card.level == ProviderNoteLevel.critical;
    final glyph = switch (card.level) {
      ProviderNoteLevel.info => AppGlyphs.info,
      ProviderNoteLevel.warning => AppGlyphs.warning,
      ProviderNoteLevel.critical => AppGlyphs.error,
    };
    final glyphColor = switch (card.level) {
      ProviderNoteLevel.info => scheme.onSurfaceVariant,
      ProviderNoteLevel.warning => scheme.warning,
      ProviderNoteLevel.critical => scheme.onErrorContainer,
    };
    final action = card.action;
    final tappable =
        action != null && providerActionAvailable(scope.metadata, action);
    return CommonCard(
      isError: critical,
      padding: EdgeInsets.fromLTRB(
        16,
        4,
        card.dismissible || tappable ? 8 : 16,
        4,
      ),
      shape: AppShape.xl,
      onPressed: tappable ? () => scope.onAction(action) : null,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Row(
          spacing: 12,
          children: [
            GlyphIcon(glyph, size: 24, color: glyphColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  card.text,
                  style: AppTextStyle.subheadline
                      .of(context)
                      .copyWith(
                        color: critical
                            ? scheme.onErrorContainer
                            : scheme.onSurface,
                      ),
                ),
              ),
            ),
            if (card.dismissible)
              _DismissButton(
                card,
                scope: scope,
                color: critical
                    ? scheme.onErrorContainer
                    : scheme.onSurfaceVariant,
              )
            else if (tappable)
              SizedBox.square(
                dimension: 48,
                child: Center(
                  child: GlyphIcon(
                    AppGlyphs.chevronForward,
                    size: 16,
                    color: critical
                        ? scheme.onErrorContainer
                        : scheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionsCard extends StatelessWidget {
  const _ActionsCard(this.card, {required this.scope});

  final ProviderActions card;
  final ProviderCardsView scope;

  @override
  Widget build(BuildContext context) {
    final items = [
      for (final item in card.items)
        if (providerActionAvailable(scope.metadata, item.action)) item,
    ];
    if (items.isEmpty) return const SizedBox.shrink();
    final scheme = context.colorScheme;
    return CommonCard(
      padding: const EdgeInsets.all(12),
      shape: AppShape.xl,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final columns =
                    constraints.maxWidth >= 480 && items.length % 3 != 1
                    ? math.min(items.length, 3)
                    : 2;
                final width =
                    (constraints.maxWidth - 8 * (columns - 1)) / columns;
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final item in items)
                      SizedBox(
                        width: width,
                        child: FilledButton.tonalIcon(
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 48),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () => scope.onAction(item.action),
                          icon: GlyphIcon(
                            _glyphOf(item.icon),
                            size: 18,
                            fill: 1,
                          ),
                          label: Text(
                            item.label,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          if (card.dismissible)
            _DismissButton(card, scope: scope, color: scheme.onSurfaceVariant),
        ],
      ),
    );
  }
}

enum _ImagePhase { loading, ready, failed }

class _BannerCard extends StatefulWidget {
  const _BannerCard(
    this.card, {
    required this.scope,
    required this.onImageFailed,
  });

  final ProviderBanner card;
  final ProviderCardsView scope;
  final VoidCallback onImageFailed;

  @override
  State<_BannerCard> createState() => _BannerCardState();
}

class _BannerCardState extends State<_BannerCard> {
  Uri? _url;
  ImageProvider? _image;
  _ImagePhase _phase = _ImagePhase.loading;
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    if (widget.card.countdown != null) {
      _tick = Timer.periodic(
        const Duration(minutes: 1),
        (_) => setState(() {}),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final card = widget.card;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final url = (dark ? card.imageDark : null) ?? card.image;
    if (url == null) {
      _url = null;
      _image = null;
      _phase = _ImagePhase.failed;
      return;
    }
    if (url == _url) return;
    _url = url;
    _image = null;
    _phase = _ImagePhase.loading;
    unawaited(
      widget.scope.images.picture(url).then((image) {
        if (!mounted || _url != url) return;
        if (image == null && card.layout == ProviderBannerLayout.image) {
          widget.onImageFailed();
          return;
        }
        setState(() {
          _image = image;
          _phase = image == null ? _ImagePhase.failed : _ImagePhase.ready;
        });
      }),
    );
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  String? _countdown() {
    final end = widget.card.countdown;
    if (end == null) return null;
    final left = Duration(
      seconds: end - DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );
    if (left <= Duration.zero) return null;
    if (left.inDays > 0) {
      return AppLocalizations.of(context).simpleDaysCount(left.inDays);
    }
    final minutes = (left.inMinutes % 60).toString().padLeft(2, '0');
    return '${left.inHours}:$minutes';
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.card;
    final scheme = context.colorScheme;
    final countdown = _countdown();
    if (card.countdown != null && countdown == null) {
      return const SizedBox.shrink();
    }
    if (card.layout == ProviderBannerLayout.image &&
        _phase == _ImagePhase.failed) {
      return const SizedBox.shrink();
    }
    final (fill, fg, variant, buttonFill, buttonText) = switch (card.tone) {
      ProviderBannerTone.surface => (
        null,
        scheme.onSurface,
        scheme.onSurfaceVariant,
        scheme.onSurface,
        scheme.surface,
      ),
      ProviderBannerTone.primary => (
        scheme.primary,
        scheme.onPrimary,
        scheme.onPrimary,
        scheme.onPrimary,
        scheme.primary,
      ),
      ProviderBannerTone.secondary => (
        scheme.secondary,
        scheme.onSecondary,
        scheme.onSecondary,
        scheme.onSecondary,
        scheme.secondary,
      ),
      ProviderBannerTone.tertiary => (
        scheme.tertiary,
        scheme.onTertiary,
        scheme.onTertiary,
        scheme.onTertiary,
        scheme.tertiary,
      ),
    };
    final hero =
        card.layout == ProviderBannerLayout.hero &&
        _phase != _ImagePhase.failed;
    final onImage = hero && _phase == _ImagePhase.ready;
    final overlay =
        card.dismissible && card.layout != ProviderBannerLayout.strip;
    final body = _BannerText(
      card: card,
      countdown: countdown,
      color: onImage ? Colors.white : fg,
      variant: onImage ? Colors.white : variant,
      buttonFill: onImage ? Colors.white : buttonFill,
      buttonText: onImage ? Colors.black : buttonText,
      onAction: widget.scope.onAction,
    );
    final content = switch (card.layout) {
      ProviderBannerLayout.image => ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: _heroMaxHeight),
        child: AspectRatio(
          aspectRatio: _bannerRatio,
          child: Semantics(
            label: card.title ?? card.text,
            image: true,
            child: _picture(),
          ),
        ),
      ),
      ProviderBannerLayout.strip => Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 8, 4),
        child: SizedBox(
          height: 44,
          child: Row(
            spacing: 8,
            children: [
              Expanded(
                child: Text(
                  card.title ?? card.text ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.subheadline
                      .of(context, emphasized: true)
                      .copyWith(color: fg),
                ),
              ),
              if (countdown != null)
                Text(
                  countdown,
                  style: AppTextStyle.footnote
                      .of(context)
                      .copyWith(color: variant),
                ),
              if (card.dismissible)
                _DismissButton(card, scope: widget.scope, color: fg),
            ],
          ),
        ),
      ),
      ProviderBannerLayout.split when _phase != _ImagePhase.failed => Builder(
        builder: (context) {
          final atStart = card.side == ProviderBannerSide.start;
          return ConstrainedBox(
            constraints: const BoxConstraints(minHeight: _splitImageExtent),
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(
                    atStart ? 16 + _splitImageExtent : 16,
                    16,
                    atStart ? 16 : 16 + _splitImageExtent,
                    16,
                  ),
                  child: body,
                ),
                Positioned.directional(
                  textDirection: Directionality.of(context),
                  top: 0,
                  bottom: 0,
                  start: atStart ? 0 : null,
                  end: atStart ? null : 0,
                  width: _splitImageExtent,
                  child: _picture(),
                ),
              ],
            ),
          );
        },
      ),
      ProviderBannerLayout.hero when hero => LayoutBuilder(
        builder: (context, constraints) => Stack(
          children: [
            Positioned.fill(child: _picture()),
            ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: math.min(
                  constraints.maxWidth / _bannerRatio,
                  _heroMaxHeight,
                ),
              ),
              child: Align(
                alignment: AlignmentDirectional.bottomStart,
                child: CustomPaint(
                  painter: onImage ? const _TextScrimPainter() : null,
                  child: Padding(
                    padding: const EdgeInsets.only(top: _scrimFade),
                    child: SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: body,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      _ => Padding(
        padding: EdgeInsetsDirectional.fromSTEB(16, 16, overlay ? 52 : 16, 16),
        child: body,
      ),
    };
    final overImageStart =
        card.layout == ProviderBannerLayout.split &&
        card.side == ProviderBannerSide.start &&
        _phase != _ImagePhase.failed;
    final tappable =
        card.button == null &&
        card.action != null &&
        providerActionAvailable(widget.scope.metadata, card.action);
    final inner = ClipPath(
      clipper: const ShapeBorderClipper(shape: AppShape.xl),
      child: Stack(
        children: [
          SizedBox(width: double.infinity, child: content),
          if (overlay)
            PositionedDirectional(
              top: 4,
              start: overImageStart ? 4 : null,
              end: overImageStart ? null : 4,
              child: IconButton.filledTonal(
                tooltip: AppLocalizations.of(context).close,
                icon: GlyphIcon(
                  AppGlyphs.close,
                  size: 18,
                  fill: 1,
                  color: scheme.onSecondaryContainer,
                ),
                onPressed: () => widget.scope.onDismiss(card),
              ),
            ),
        ],
      ),
    );
    final onTap = tappable ? () => widget.scope.onAction(card.action!) : null;
    if (fill == null) {
      return CommonCard(
        padding: EdgeInsets.zero,
        shape: AppShape.xl,
        onPressed: onTap,
        child: inner,
      );
    }
    return Material(
      color: fill,
      shape: AppShape.xl,
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: inner),
    );
  }

  Widget _picture() {
    final image = _image;
    if (image == null) return const SizedBox.expand();
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = MediaQuery.devicePixelRatioOf(context);
        return Image(
          image: ResizeImage.resizeIfNeeded(
            constraints.hasBoundedWidth
                ? (constraints.maxWidth * scale).round()
                : null,
            null,
            image,
          ),
          fit: BoxFit.cover,
          gaplessPlayback: true,
          excludeFromSemantics: true,
          errorBuilder: (_, _, _) => const SizedBox.expand(),
        );
      },
    );
  }
}

class _BannerText extends StatelessWidget {
  const _BannerText({
    required this.card,
    required this.countdown,
    required this.color,
    required this.variant,
    required this.buttonFill,
    required this.buttonText,
    required this.onAction,
  });

  final ProviderBanner card;
  final String? countdown;
  final Color color;
  final Color variant;
  final Color buttonFill;
  final Color buttonText;
  final void Function(ProviderAction action) onAction;

  @override
  Widget build(BuildContext context) {
    final button = card.button;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        if (card.title case final title?)
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.title3
                .of(context, emphasized: true)
                .copyWith(color: color),
          ),
        if (card.text case final text?)
          Text(
            text,
            style: AppTextStyle.subheadline
                .of(context)
                .copyWith(color: variant),
          ),
        if (countdown case final countdown?)
          Text(
            countdown,
            style: AppTextStyle.footnote.of(context).copyWith(color: variant),
          ),
        if (button != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: buttonFill,
                foregroundColor: buttonText,
              ),
              onPressed: () => onAction(button.action),
              child: Text(button.label),
            ),
          ),
      ],
    );
  }
}

/// Covers the text block rather than the card, so copy of any length stays
/// below the transparent part of the fade.
class _TextScrimPainter extends CustomPainter {
  const _TextScrimPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: [0, _scrimFade / size.height, 1],
      colors: const [Color(0x00000000), Color(0x8C000000), Color(0xB3000000)],
    );
    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));
  }

  @override
  bool shouldRepaint(_TextScrimPainter oldDelegate) => false;
}
