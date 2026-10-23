import 'dart:async';

import 'package:reclash/common/app_update_state.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class _Credit {
  final String avatar;
  final String project;
  final String name;
  final String role;
  final String link;

  const _Credit({
    required this.avatar,
    required this.project,
    required this.name,
    required this.role,
    required this.link,
  });
}

class AboutView extends ConsumerWidget {
  const AboutView({super.key});

  Widget _buildLinkItem({
    required Glyph glyph,
    required String title,
    required String url,
    required String label,
  }) {
    return ListItem(
      leading: _LinkBadge(glyph: glyph),
      title: Text(title),
      subtitle: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: const GlyphIcon(AppGlyphs.openExternal),
      onTap: () {
        dialogs.openUrl(url);
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final isLoading = ref.watch(
      appUpdateActionProvider.select(
        (state) => state.phase == UpdatePhase.checking,
      ),
    );
    final gratitude = [
      _Credit(
        avatar: 'assets/images/avatar/chen08209.jpg',
        project: 'FlClash',
        name: 'chen08209',
        role: appLocalizations.creditFlClash,
        link: 'https://github.com/chen08209/FlClash',
      ),
      _Credit(
        avatar: 'assets/images/avatar/pluralplay.jpg',
        project: 'FlClashX',
        name: 'pluralplay',
        role: appLocalizations.creditFlClashX,
        link: 'https://github.com/pluralplay/FlClashX',
      ),
      _Credit(
        avatar: 'assets/images/avatar/chenx-dust.jpg',
        project: 'FlClash-Patched',
        name: 'chenx-dust',
        role: appLocalizations.creditFlClashPatched,
        link: 'https://github.com/chenx-dust/FlClash-Patched',
      ),
      _Credit(
        avatar: 'assets/images/avatar/metacubex.jpg',
        project: 'mihomo',
        name: 'MetaCubeX',
        role: appLocalizations.creditMihomo,
        link: 'https://github.com/MetaCubeX/mihomo',
      ),
      _Credit(
        avatar: 'assets/images/avatar/hufrea.jpg',
        project: 'ByeDPI',
        name: 'hufrea',
        role: appLocalizations.creditByeDpi,
        link: 'https://github.com/hufrea/byedpi',
      ),
    ];
    return CommonScaffold(
      isLoading: isLoading,
      title: appLocalizations.about,
      body: ListView(
        padding:
            const EdgeInsets.symmetric(horizontal: 16).copyWith(
              top: context.contentTopPadding,
              bottom: 32 + context.bottomInset,
            ) +
            context.bodyInsets,
        children: [
          _AboutHero(
            isCheckingUpdate: isLoading,
            onCheckUpdate: () {
              unawaited(
                ref
                    .read(commonActionProvider.notifier)
                    .checkForUpdates(context),
              );
            },
            onEnterDeveloperMode: () {
              ref
                  .read(appSettingProvider.notifier)
                  .update((state) => state.copyWith(developerMode: true));
              context.showNotifier(
                appLocalizations.developerModeEnableTip,
                level: MessageLevel.success,
              );
            },
          ),
          const SizedBox(height: 8),
          generateSection(
            title: appLocalizations.maintainer,
            items: [
              ListItem(
                leading: const SizedBox.square(
                  dimension: 40,
                  child: CircleAvatar(
                    foregroundImage: AssetImage(
                      'assets/images/avatar/hoxiee.jpg',
                    ),
                  ),
                ),
                title: const Text('Hoxiee'),
                subtitle: const Text('github.com/Hoxiee'),
                trailing: const GlyphIcon(AppGlyphs.openExternal),
                onTap: () {
                  unawaited(dialogs.openUrl('https://github.com/Hoxiee'));
                },
              ),
            ],
          ),
          generateSection(
            title: appLocalizations.more,
            items: [
              _buildLinkItem(
                glyph: AppGlyphs.code,
                title: appLocalizations.project,
                url: 'https://github.com/$repository',
                label: 'github.com/$repository',
              ),
              _buildLinkItem(
                glyph: AppGlyphs.cpu,
                title: appLocalizations.core,
                url: 'https://github.com/Hoxiee/mihomo/tree/ReClash',
                label: 'github.com/Hoxiee/mihomo',
              ),
              _buildLinkItem(
                glyph: AppGlyphs.send,
                title: 'Telegram',
                url: 'https://t.me/ReClashApp',
                label: 't.me/ReClashApp',
              ),
              ListItem(
                leading: const _LinkBadge(glyph: AppGlyphs.gavel),
                title: Text(appLocalizations.license),
                subtitle: const Text('GPL-3.0'),
                trailing: const GlyphIcon(AppGlyphs.openExternal),
                onTap: () {
                  dialogs.openUrl(
                    'https://github.com/$repository/blob/main/LICENSE',
                  );
                },
              ),
              ListItem(
                leading: const _LinkBadge(glyph: AppGlyphs.info),
                title: Text(appLocalizations.licenses),
                subtitle: Text(appLocalizations.licensesDesc),
                trailing: const GlyphIcon(AppGlyphs.openExternal),
                onTap: () {
                  showLicensePage(
                    context: context,
                    applicationName: appName,
                    applicationVersion: 'v${globalState.packageInfo.version}',
                    applicationIcon: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Image.asset(
                        'assets/images/icon.png',
                        width: 48,
                        height: 48,
                      ),
                    ),
                    applicationLegalese: 'GPL-3.0',
                  );
                },
              ),
            ],
          ),
          generateSection(
            title: appLocalizations.gratitude,
            footer: appLocalizations.gratitudeDesc,
            items: [_Acknowledgments(credits: gratitude)],
          ),
        ],
      ),
    );
  }
}

class _Acknowledgments extends StatelessWidget {
  final List<_Credit> credits;

  const _Acknowledgments({required this.credits});

  static const _gap = 12.0;
  static const _tileWidth = 160.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(16) / 16;
        final minTileWidth = _tileWidth * textScale;
        final columns = constraints.maxWidth >= minTileWidth * 4 + _gap * 3
            ? 4
            : constraints.maxWidth >= minTileWidth * 2 + _gap
            ? 2
            : 1;
        final projects = credits.skip(1).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: _gap,
          children: [
            _CreditCard(credit: credits.first, isFeatured: true),
            for (var start = 0; start < projects.length; start += columns)
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: _gap,
                  children: [
                    for (final credit in projects.skip(start).take(columns))
                      Expanded(
                        child: _CreditCard(
                          credit: credit,
                          isInline: columns == 1,
                        ),
                      ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _CreditCard extends StatelessWidget {
  final _Credit credit;
  final bool isFeatured;
  final bool isInline;

  const _CreditCard({
    required this.credit,
    this.isFeatured = false,
    this.isInline = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final avatar = SizedBox.square(
      dimension: isFeatured ? 48 : 36,
      child: CircleAvatar(foregroundImage: AssetImage(credit.avatar)),
    );
    final external = GlyphIcon(
      AppGlyphs.openExternal,
      size: 16,
      fill: 1,
      color: colorScheme.onSurfaceVariant,
    );
    final title = Text(
      credit.project,
      semanticsLabel: isFeatured ? null : '${credit.project}, ${credit.role}',
      style: (isFeatured ? AppTextStyle.headline : AppTextStyle.subheadline)
          .of(context, emphasized: true)
          .copyWith(color: colorScheme.onSurface),
    );
    final name = Text(
      credit.name,
      style: AppTextStyle.caption1
          .of(context)
          .copyWith(color: colorScheme.onSurfaceVariant),
    );
    return Tooltip(
      message: '${credit.name}: ${credit.role}',
      child: CommonCard(
        shape: isFeatured || isInline ? AppShape.xl : AppShape.lg,
        padding: EdgeInsets.all(isFeatured ? 16 : 12),
        onPressed: () => unawaited(dialogs.openUrl(credit.link)),
        child: isFeatured || isInline
            ? Row(
                spacing: 14,
                children: [
                  avatar,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 4,
                      children: [
                        title,
                        name,
                        if (isFeatured)
                          Text(
                            credit.role,
                            style: AppTextStyle.footnote
                                .of(context)
                                .copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                      ],
                    ),
                  ),
                  external,
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [avatar, external],
                  ),
                  const SizedBox(height: 10),
                  title,
                  const SizedBox(height: 2),
                  name,
                ],
              ),
      ),
    );
  }
}

class _AboutHero extends StatelessWidget {
  final bool isCheckingUpdate;
  final VoidCallback onCheckUpdate;
  final VoidCallback onEnterDeveloperMode;

  const _AboutHero({
    required this.isCheckingUpdate,
    required this.onCheckUpdate,
    required this.onEnterDeveloperMode,
  });

  static const _logoSize = 96.0;
  static const _logoInset = 14.0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final appLocalizations = context.appLocalizations;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        children: [
          _DeveloperModeDetector(
            onEnterDeveloperMode: onEnterDeveloperMode,
            child: DecoratedBox(
              decoration: ShapeDecoration(
                color: context.raisedSurfaceLevel.colorOf(colorScheme),
                shape: AppShape.all(AppCorner.fit(_logoSize)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(_logoInset),
                child: Image.asset(
                  'assets/images/icon.png',
                  width: _logoSize - _logoInset * 2,
                  height: _logoSize - _logoInset * 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            appName,
            style: AppTextStyle.title2.of(context, emphasized: true),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _Pill(
                label: 'v${globalState.packageInfo.version}',
                color: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              _Pill(
                label: 'GPL-3.0',
                color: context.raisedSurfaceLevel.colorOf(colorScheme),
                foregroundColor: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Text(
              appLocalizations.desc,
              textAlign: TextAlign.center,
              style: AppTextStyle.subheadline
                  .of(context)
                  .copyWith(color: colorScheme.onSurfaceVariant, height: 1.5),
            ),
          ),
          const SizedBox(height: 20),
          TonalButton(
            size: TonalButtonSize.bar,
            glyph: AppGlyphs.sync,
            label: appLocalizations.checkUpdate,
            onPressed: isCheckingUpdate ? null : onCheckUpdate,
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  final Color foregroundColor;

  const _Pill({
    required this.label,
    required this.color,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(color: color, shape: AppShape.full),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Text(
          label,
          style: AppTextStyle.caption1
              .of(context, emphasized: true)
              .copyWith(color: foregroundColor),
        ),
      ),
    );
  }
}

class _LinkBadge extends StatelessWidget {
  final Glyph glyph;

  const _LinkBadge({required this.glyph});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: context.raisedSurfaceLevel.colorOf(colorScheme),
        shape: AppShape.md,
      ),
      child: SizedBox.square(
        dimension: 40,
        child: Center(
          child: GlyphIcon(
            glyph,
            size: 20,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _DeveloperModeDetector extends StatefulWidget {
  final Widget child;
  final VoidCallback onEnterDeveloperMode;

  const _DeveloperModeDetector({
    required this.child,
    required this.onEnterDeveloperMode,
  });

  @override
  State<_DeveloperModeDetector> createState() => _DeveloperModeDetectorState();
}

class _DeveloperModeDetectorState extends State<_DeveloperModeDetector> {
  int _counter = 0;
  Timer? _timer;

  void _handleTap() {
    _counter++;
    if (_counter >= 5) {
      widget.onEnterDeveloperMode();
      _resetCounter();
    } else {
      _timer?.cancel();
      _timer = Timer(const Duration(seconds: 1), _resetCounter);
    }
  }

  void _resetCounter() {
    _counter = 0;
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: _handleTap, child: widget.child);
  }
}
