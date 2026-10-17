import 'dart:async';

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class Contributor {
  final String avatar;
  final String name;

  const Contributor({required this.avatar, required this.name});
}

@immutable
class Credit {
  final String avatar;
  final String name;
  final String role;
  final String link;

  const Credit({
    required this.avatar,
    required this.name,
    required this.role,
    required this.link,
  });
}

class AboutView extends ConsumerWidget {
  const AboutView({super.key});

  static const _contributors = [
    Contributor(avatar: 'assets/images/avatar/june2.jpg', name: 'June2'),
    Contributor(avatar: 'assets/images/avatar/arue.jpg', name: 'Arue'),
  ];

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

  Widget _buildCreditItem({required Credit credit}) {
    return ListItem(
      leading: SizedBox(
        width: 40,
        height: 40,
        child: CircleAvatar(foregroundImage: AssetImage(credit.avatar)),
      ),
      title: Text(credit.name),
      subtitle: Text(credit.role),
      trailing: const GlyphIcon(AppGlyphs.openExternal),
      onTap: () {
        dialogs.openUrl(credit.link);
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final isLoading = ref.watch(loadingProvider(LoadingTag.checkUpdate));
    final author = Credit(
      avatar: 'assets/images/avatar/hoxiee.jpg',
      name: 'Hoxiee',
      role: appLocalizations.roleAuthor,
      link: 'https://github.com/Hoxiee',
    );
    final gratitude = [
      Credit(
        avatar: 'assets/images/avatar/chen08209.jpg',
        name: 'chen08209',
        role: appLocalizations.creditFlClash,
        link: 'https://github.com/chen08209/FlClash',
      ),
      Credit(
        avatar: 'assets/images/avatar/pluralplay.jpg',
        name: 'pluralplay',
        role: appLocalizations.creditFlClashX,
        link: 'https://github.com/pluralplay/FlClashX',
      ),
      Credit(
        avatar: 'assets/images/avatar/chenx-dust.jpg',
        name: 'chenx-dust',
        role: appLocalizations.creditFlClashPatched,
        link: 'https://github.com/chenx-dust/FlClash-Patched',
      ),
      Credit(
        avatar: 'assets/images/avatar/metacubex.jpg',
        name: 'MetaCubeX',
        role: appLocalizations.creditMihomo,
        link: 'https://github.com/MetaCubeX/mihomo',
      ),
      Credit(
        avatar: 'assets/images/avatar/hufrea.jpg',
        name: 'hufrea',
        role: appLocalizations.creditByeDpi,
        link: 'https://github.com/hufrea/byedpi',
      ),
    ];
    return CommonScaffold(
      isLoading: isLoading,
      title: appLocalizations.about,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(
          top: context.contentTopPadding,
          bottom: 32 + context.bottomInset,
        ),
        children: [
          _AboutHero(
            isCheckingUpdate: isLoading,
            onCheckUpdate: () {
              unawaited(
                ref.read(commonActionProvider.notifier).checkForUpdates(),
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
            title: appLocalizations.madeBy,
            items: [_buildCreditItem(credit: author)],
          ),
          generateSection(
            title: appLocalizations.gratitude,
            footer: appLocalizations.gratitudeDesc,
            items: [
              for (final credit in gratitude) _buildCreditItem(credit: credit),
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
            title: appLocalizations.otherContributors,
            items: [
              for (final contributor in _contributors)
                ListItem(
                  leading: CircleAvatar(
                    foregroundImage: AssetImage(contributor.avatar),
                  ),
                  title: Text(contributor.name),
                  subtitle: Text(appLocalizations.appIconDesign),
                ),
            ],
          ),
        ],
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
