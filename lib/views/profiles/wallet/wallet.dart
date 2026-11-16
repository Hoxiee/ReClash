import 'package:reclash/common/common.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/ui/ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pass.dart';
import 'stack_card.dart';

class ProfilesWallet extends ConsumerStatefulWidget {
  const ProfilesWallet({
    super.key,
    required this.profiles,
    required this.currentProfileId,
    required this.spacing,
  });

  final List<Profile> profiles;
  final int? currentProfileId;
  final double spacing;

  @override
  ConsumerState<ProfilesWallet> createState() => _ProfilesWalletState();
}

class _ProfilesWalletState extends ConsumerState<ProfilesWallet> {
  static const _horizontalPadding = 16.0;
  static const _passWidth = 420.0;
  static const _foldAfter = 5;

  late final ScrollController _controller;
  var _expanded = false;

  @override
  void initState() {
    super.initState();
    _controller = sheetScrollController(context);
    _ensureBrands();
  }

  @override
  void didUpdateWidget(ProfilesWallet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.profiles, widget.profiles)) _ensureBrands();
  }

  void _ensureBrands() {
    final action = ref.read(profilesActionProvider.notifier);
    for (final profile in widget.profiles) {
      action.ensureBrand(profile);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  EdgeInsets get _padding => EdgeInsets.only(
    left: _horizontalPadding,
    right: _horizontalPadding,
    top: context.contentTopPadding,
    bottom: 16 + context.bottomInset,
  );

  void _activate(Profile profile) {
    ref.read(currentProfileIdProvider.notifier).value = profile.id;
  }

  @override
  Widget build(BuildContext context) {
    final currentId = widget.currentProfileId;
    Profile? current;
    final others = <Profile>[];
    for (final profile in widget.profiles) {
      if (profile.id == currentId) {
        current = profile;
      } else {
        others.add(profile);
      }
    }
    final pass = current == null
        ? null
        : AnimatedSwitcher(
            duration: context.motionDuration(commonDuration),
            child: WalletPass(key: ValueKey(current.id), profile: current),
          );
    return WidthBuilder(
      builder: (context, width) {
        final cardsMinWidth = profileItemMinWidth.ap(context);
        final wide =
            width - _horizontalPadding * 2 >=
            _passWidth + widget.spacing * 2 + cardsMinWidth;
        return SingleChildScrollView(
          key: profilesStoreKey,
          controller: _controller,
          padding: _padding,
          child: wide
              ? _wideBody(pass, others)
              : _narrowBody(context, pass, others),
        );
      },
    );
  }

  Widget _header(BuildContext context, String title, {int? count}) {
    final appLocalizations = context.appLocalizations;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(title, style: AppTextStyle.headline.of(context)),
          if (count != null)
            Text(
              appLocalizations.walletProfilesCount(count),
              style: AppTextStyle.footnote
                  .of(context)
                  .copyWith(color: context.colorScheme.onSurfaceVariant),
            ),
        ],
      ),
    );
  }

  Widget _wideBody(Widget? pass, List<Profile> others) {
    final grid = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (others.isNotEmpty)
          _header(
            context,
            context.appLocalizations.walletOthers,
            count: others.length,
          ),
        LayoutBuilder(
          builder: (_, constraints) {
            final columns =
                constraints.maxWidth >=
                    profileItemMinWidth.ap(context) * 2 + widget.spacing
                ? 2
                : 1;
            final cardWidth =
                (constraints.maxWidth - widget.spacing * (columns - 1)) /
                columns;
            return Wrap(
              spacing: widget.spacing,
              runSpacing: widget.spacing,
              children: [
                for (final profile in others)
                  SizedBox(
                    width: cardWidth,
                    height: walletStackCardHeight,
                    child: WalletStackCard(
                      key: ValueKey(profile.id),
                      profile: profile,
                      onPressed: () => _activate(profile),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: widget.spacing * 2,
      children: [
        if (pass != null)
          SizedBox(
            width: _passWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _header(context, context.appLocalizations.walletCurrent),
                pass,
              ],
            ),
          ),
        Expanded(child: grid),
      ],
    );
  }

  Widget _narrowBody(BuildContext context, Widget? pass, List<Profile> others) {
    final appLocalizations = context.appLocalizations;
    final folded = !_expanded && others.length > _foldAfter;
    final shown = folded ? others.sublist(0, _foldAfter) : others;
    final hidden = others.length - _foldAfter;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ?pass,
        if (others.isNotEmpty) ...[
          SizedBox(height: pass == null ? 0 : 20),
          if (pass != null)
            _header(
              context,
              appLocalizations.walletOthers,
              count: others.length,
            ),
          AnimatedSize(
            duration: context.motionDuration(commonDuration),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _OverlapStack(
                  profiles: shown,
                  peekEdges: folded,
                  onPressed: _activate,
                ),
                if (others.length > _foldAfter)
                  Center(
                    child: TextButton(
                      onPressed: () => setState(() => _expanded = !_expanded),
                      style: TextButton.styleFrom(
                        foregroundColor: context.colorScheme.onSurfaceVariant,
                      ),
                      child: Text(
                        folded
                            ? appLocalizations.walletShowMore(hidden)
                            : appLocalizations.showLess,
                        style: AppTextStyle.subheadline.of(
                          context,
                          emphasized: true,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _OverlapStack extends StatelessWidget {
  const _OverlapStack({
    required this.profiles,
    required this.peekEdges,
    required this.onPressed,
  });

  static const _overlap = 14.0;
  static const _edgeStep = 8.0;
  static const _edgeInset = 12.0;

  final List<Profile> profiles;
  final bool peekEdges;
  final void Function(Profile profile) onPressed;

  @override
  Widget build(BuildContext context) {
    if (profiles.isEmpty) return const SizedBox.shrink();
    final colorScheme = context.colorScheme;
    const pitch = walletStackCardHeight - _overlap;
    final cardsEnd = pitch * (profiles.length - 1) + walletStackCardHeight;
    final level = context.raisedSurfaceLevel;
    return SizedBox(
      height: cardsEnd + (peekEdges ? _edgeStep * 2 : 0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (peekEdges)
            for (var i = 2; i >= 1; i--)
              Positioned(
                left: _edgeInset * i,
                right: _edgeInset * i,
                top: cardsEnd + _edgeStep * i - walletStackCardHeight,
                height: walletStackCardHeight,
                child: DecoratedBox(
                  decoration: ShapeDecoration(
                    color: level.colorOf(colorScheme),
                    shape: AppShape.xl,
                    shadows: walletLiftShadows(colorScheme.brightness),
                  ),
                ),
              ),
          for (var i = 0; i < profiles.length; i++)
            Positioned(
              left: 0,
              right: 0,
              top: pitch * i,
              height: walletStackCardHeight,
              child: WalletStackCard(
                key: ValueKey(profiles[i].id),
                profile: profiles[i],
                lifted: i > 0,
                onPressed: () => onPressed(profiles[i]),
              ),
            ),
        ],
      ),
    );
  }
}
