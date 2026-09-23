import 'dart:async';

import 'package:reclash/common/common.dart';
import 'package:reclash/common/milestones/seasonal.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

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

  Future<void> _checkUpdate(BuildContext context, WidgetRef ref) async {
    final commonAction = ref.read(commonActionProvider.notifier);
    final data = await globalState.safeRun<Map<String, dynamic>?>(
      request.checkForUpdate,
      title: context.appLocalizations.checkUpdate,
    );
    unawaited(commonAction.checkUpdateResultHandle(data: data, isUser: true));
  }

  Widget _buildCreditSection({
    required String title,
    String? subTitle,
    required List<Credit> credits,
  }) {
    final items = [for (final credit in credits) _CreditItem(credit: credit)];
    return SettingSection(title: title, subTitle: subTitle, items: items);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
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
        avatar: 'assets/images/avatar/metacubex.jpg',
        name: 'MetaCubeX',
        role: appLocalizations.creditMihomo,
        link: 'https://github.com/MetaCubeX/mihomo',
      ),
    ];
    return BaseScaffold(
      title: appLocalizations.about,
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: _IdentityCard(),
          ),
          _buildCreditSection(
            title: appLocalizations.madeBy,
            credits: [author],
          ),
          _buildCreditSection(
            title: appLocalizations.gratitude,
            subTitle: appLocalizations.gratitudeDesc,
            credits: gratitude,
          ),
          SettingSection(
            title: appLocalizations.more,
            items: [
              DecorationListItem(
                title: Text(appLocalizations.checkUpdate),
                leading: const Icon(Icons.update),
                onPressed: () {
                  _checkUpdate(context, ref);
                },
              ),
              DecorationListItem(
                title: Text(appLocalizations.sourceCode),
                subtitle: const Text(repository),
                leading: const Icon(Icons.code),
                trailing: const Icon(Icons.launch, size: 20),
                onPressed: () {
                  dialogs.openUrl('https://github.com/$repository');
                },
              ),
              DecorationListItem(
                title: Text(appLocalizations.core),
                subtitle: const Text('mihomo'),
                leading: const Icon(Icons.memory),
                trailing: const Icon(Icons.launch, size: 20),
                onPressed: () {
                  dialogs.openUrl(
                    'https://github.com/Hoxiee/mihomo/tree/ReClash',
                  );
                },
              ),
              DecorationListItem(
                title: const Text('Telegram'),
                leading: const Icon(Icons.telegram),
                trailing: const Icon(Icons.launch, size: 20),
                onPressed: () {
                  dialogs.openUrl('https://t.me/ReClashApp');
                },
              ),
              DecorationListItem(
                title: Text(appLocalizations.license),
                subtitle: const Text('GPL-3.0'),
                leading: const Icon(Icons.balance),
                trailing: const Icon(Icons.launch, size: 20),
                onPressed: () {
                  dialogs.openUrl(
                    'https://github.com/$repository/blob/main/LICENSE',
                  );
                },
              ),
              DecorationListItem(
                title: Text(appLocalizations.licenses),
                subtitle: Text(appLocalizations.licensesDesc),
                leading: const Icon(Icons.menu_book),
                onPressed: () {
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
          const SettingBottomInset(),
        ],
      ),
    );
  }
}

class _IdentityCard extends ConsumerStatefulWidget {
  const _IdentityCard();

  @override
  ConsumerState<_IdentityCard> createState() => _IdentityCardState();
}

class _IdentityCardState extends ConsumerState<_IdentityCard> {
  int _tapCount = 0;
  DateTime? _lastTapAt;

  void _handleTap() {
    if (!ref.read(milestoneSettingProvider).findingsEnabled) return;
    final now = DateTime.now();
    if (_lastTapAt == null ||
        now.difference(_lastTapAt!) > const Duration(milliseconds: 650)) {
      _tapCount = 0;
    }
    _lastTapAt = now;
    _tapCount++;
    if (_tapCount < 7) return;
    _tapCount = 0;
    ref.read(milestonesProvider.notifier).discover('marks');
    showExtend(context, builder: (_) => const MarksView());
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final textTheme = context.textTheme;
    final version = globalState.packageInfo.version;
    final platform = SupportPlatform.currentPlatform.name;
    return CommonCard(
      type: CommonCardType.filled,
      radius: AppCorner.xl,
      padding: const EdgeInsets.all(20),
      onPressed: _handleTap,
      onLongPress: () {
        Clipboard.setData(
          ClipboardData(
            text:
                '$appName $version '
                '(${globalState.packageInfo.buildNumber}) · $platform',
          ),
        );
        context.showNotifier(appLocalizations.copySuccess);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          Row(
            spacing: 16,
            children: [
              _DeveloperModeDetector(
                onEnterDeveloperMode: () {
                  ref
                      .read(appSettingProvider.notifier)
                      .update((state) => state.copyWith(developerMode: true));
                  context.showNotifier(
                    appLocalizations.developerModeEnableTip,
                    level: MessageLevel.success,
                  );
                },
                child: Image.asset(
                  'assets/images/icon.png',
                  width: 64,
                  height: 64,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 6,
                  children: [
                    Text(
                      appName,
                      style: textTheme.headlineSmall?.copyWith(
                        color: context.colorScheme.onSurface,
                      ),
                    ),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        MetaChip(label: 'v$version'),
                        MetaChip(label: platform),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Text(
            appLocalizations.desc,
            style: textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          const _SeasonAnniversary(),
          const _CrownHistory(),
          Text(
            appLocalizations.copyDiagnostics,
            style: textTheme.labelSmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant.opacity60,
            ),
          ),
        ],
      ),
    );
  }
}

class _SeasonAnniversary extends ConsumerWidget {
  const _SeasonAnniversary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(milestoneSettingProvider).seasonalEnabled) {
      return const SizedBox.shrink();
    }
    final motif = ref.watch(visibleSeasonProvider);
    final firstRun = motif == SeasonalMotif.firstRun
        ? ref.watch(visibleOdometerProvider)?.firstRunMillis
        : null;
    final date = firstRun == null || firstRun <= 0
        ? ''
        : ' · ${MaterialLocalizations.of(context).formatMediumDate(DateTime.fromMillisecondsSinceEpoch(firstRun))}';
    final text = switch (motif) {
      SeasonalMotif.birthday => context.appLocalizations.seasonBirthdayNote,
      SeasonalMotif.firstRun =>
        '${context.appLocalizations.seasonFirstRunNote}$date',
      _ => null,
    };
    return text == null
        ? const SizedBox.shrink()
        : Text(
            text,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.primary,
            ),
          );
  }
}

class _CrownHistory extends ConsumerWidget {
  const _CrownHistory();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unlocked = ref.watch(
      visibleMilestonesProvider.select(
        (state) => state.unlocked.contains('crown'),
      ),
    );
    final snapshot = ref.watch(visibleOdometerProvider);
    if (!unlocked || snapshot == null || snapshot.firstRunMillis <= 0) {
      return const SizedBox.shrink();
    }
    final date = MaterialLocalizations.of(context).formatMediumDate(
      DateTime.fromMillisecondsSinceEpoch(snapshot.firstRunMillis),
    );
    final days =
        snapshot.totalCoveredMillis ~/ const Duration(days: 1).inMilliseconds;
    return Text(
      context.appLocalizations.crownHistory(date, days),
      style: context.textTheme.bodySmall?.copyWith(
        color: context.colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class MarksView extends StatelessWidget {
  const MarksView({super.key});

  static const _assets = [
    'assets/images/marks/reclash-mark-color.svg',
    'assets/images/marks/reclash-icon-primary.svg',
    'assets/images/marks/reclash-avatar-aurora.svg',
    'assets/images/marks/reclash-avatar-midnight.svg',
    'assets/images/marks/reclash-avatar-porcelain.svg',
    'assets/images/marks/reclash-avatar-electric.svg',
  ];

  @override
  Widget build(BuildContext context) {
    return AdaptiveSheetScaffold(
      title: context.appLocalizations.findingMarks,
      body: GridView.builder(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          16 + BottomInsetScope.of(context),
        ),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 180,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemCount: _assets.length,
        itemBuilder: (_, index) => CommonCard(
          type: CommonCardType.filled,
          padding: const EdgeInsets.all(18),
          child: SvgPicture.asset(_assets[index]),
        ),
      ),
    );
  }
}

class _CreditItem extends StatelessWidget {
  final Credit credit;

  const _CreditItem({required this.credit});

  @override
  Widget build(BuildContext context) {
    return DecorationListItem(
      leading: SizedBox(
        width: 40,
        height: 40,
        child: CircleAvatar(foregroundImage: AssetImage(credit.avatar)),
      ),
      title: Text(credit.name),
      subtitle: Text(credit.role),
      trailing: const Icon(Icons.launch, size: 20),
      onPressed: () {
        dialogs.openUrl(credit.link);
      },
    );
  }
}

class _DeveloperModeDetector extends StatefulWidget {
  final Widget child;
  final VoidCallback onEnterDeveloperMode;

  const _DeveloperModeDetector({
    required this.onEnterDeveloperMode,
    required this.child,
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
