import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/dashboard/widgets/focusable_tap.dart';
import 'package:reclash/views/dashboard/widgets/hero_orb.dart';
import 'package:reclash/views/dashboard/widgets/hero_routing.dart';
import 'package:reclash/views/dashboard/widgets/hero_surface.dart';
import 'package:reclash/views/dashboard/widgets/hero_words.dart';
import 'package:reclash/views/profiles/add.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

String _countryCodeToEmoji(String code) {
  if (code.length != 2) return '🌐';
  final upper = code.toUpperCase();
  final first = 0x1F1E6 - 0x41 + upper.codeUnitAt(0);
  final second = 0x1F1E6 - 0x41 + upper.codeUnitAt(1);
  return String.fromCharCodes([first, second]);
}

String? _flagToCountryCode(String text) {
  final runes = text.runes.toList();
  for (var i = 0; i < runes.length - 1; i++) {
    final a = runes[i];
    final b = runes[i + 1];
    if (a >= 0x1F1E6 && a <= 0x1F1FF && b >= 0x1F1E6 && b <= 0x1F1FF) {
      final c1 = a - 0x1F1E6 + 0x41;
      final c2 = b - 0x1F1E6 + 0x41;
      return String.fromCharCodes([c1, c2]);
    }
  }
  return null;
}

List<String> _collectGroupFlags(List<Group> groups, Group group) {
  final seen = <String>{};
  final codes = <String>[];
  void walk(Group g, int depth) {
    if (depth > 4) return;
    for (final proxy in g.all) {
      final code = _flagToCountryCode(proxy.name);
      if (code != null) {
        if (seen.add(code)) codes.add(code);
      } else {
        final sub = groups.getGroup(proxy.name);
        if (sub != null) walk(sub, depth + 1);
      }
    }
  }

  walk(group, 0);
  return codes;
}

String _stripLeadingEmoji(String text) {
  bool isEmojiRune(int r) {
    final isFlag = r >= 0x1F1E6 && r <= 0x1F1FF;
    final isModifier =
        r == 0x200D || r == 0xFE0F || (r >= 0x1F3FB && r <= 0x1F3FF);
    final isPictograph = (r >= 0x1F000 && r <= 0x1FAFF) ||
        (r >= 0x2600 && r <= 0x27BF) ||
        (r >= 0x2190 && r <= 0x21FF) ||
        (r >= 0x2B00 && r <= 0x2BFF) ||
        (r >= 0x2300 && r <= 0x23FF);
    return isFlag || isModifier || isPictograph;
  }

  bool isSpace(int r) =>
      r == 0x20 || r == 0x09 || r == 0xA0 || r == 0x0A || r == 0x0D;

  final runes = text.runes.toList();
  var start = 0;
  while (start < runes.length &&
      (isEmojiRune(runes[start]) || isSpace(runes[start]))) {
    start++;
  }
  return String.fromCharCodes(runes.sublist(start))
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

String _formatBytes(int bytes) {
  if (bytes <= 0) return '0';
  const units = ['B', 'KB', 'MB', 'GB', 'TB'];
  var value = bytes.toDouble();
  var i = 0;
  while (value >= 1024 && i < units.length - 1) {
    value /= 1024;
    i++;
  }
  return '${value.toStringAsFixed(1)} ${units[i]}';
}

String? _decodeAnnounce(String? value) {
  if (value == null) return null;
  final trimmed = value.trim();
  if (trimmed.isEmpty) return null;
  final decoded = _decodeBase64(trimmed);
  if (decoded == null || decoded.trim().isEmpty) return null;
  return decoded.trim();
}

String? _decodeBase64(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  var text = value.trim();
  if (text.startsWith('base64:')) text = text.substring(7).trim();
  if (text.isEmpty) return null;
  try {
    final normalized = base64.normalize(text);
    final decoded = utf8.decode(base64.decode(normalized)).trim();
    return decoded.isEmpty ? null : decoded;
  } catch (_) {
    return value.trim().isEmpty ? null : value.trim();
  }
}

String _resolveToDisplayName(List<Group> groups, String proxyName) {
  final group = groups.getGroup(proxyName);
  if (group == null) return proxyName;
  final now = group.now;
  if (now == null || now.isEmpty) return group.name;
  return now;
}

typedef _HeroServerInfo = ({
  String serverName,
  String? testUrl,
  String flags,
  int otherLocations,
});

_HeroServerInfo _selectServerInfo(
  List<Group> groups,
  String? serverInfoHeader,
) {
  var serverName = '';
  String? testUrl;
  Group? activeGroup;
  if (serverInfoHeader != null && serverInfoHeader.isNotEmpty) {
    final groupName =
        _decodeBase64(serverInfoHeader) ?? serverInfoHeader.trim();
    final group = groups.getGroup(groupName);
    if (group != null) {
      activeGroup = group;
      serverName = _resolveToDisplayName(groups, group.name);
      testUrl = group.testUrl;
    }
  }
  if (serverName.isEmpty) {
    for (final g in groups) {
      final now = g.realNow;
      if (now.isNotEmpty && now != 'DIRECT' && now != 'REJECT') {
        activeGroup = g;
        serverName = _resolveToDisplayName(groups, g.name);
        testUrl = g.testUrl;
        break;
      }
    }
  }
  final nameCountryCode = _flagToCountryCode(serverName);
  final groupFlagCodes = activeGroup != null
      ? _collectGroupFlags(groups, activeGroup)
      : const <String>[];
  final activeUpper = nameCountryCode?.toUpperCase();
  final otherCodes =
      groupFlagCodes.where((c) => c.toUpperCase() != activeUpper).toList();
  final rawOther = otherCodes.isNotEmpty
      ? otherCodes.length
      : (activeGroup != null ? activeGroup.all.length - 1 : 0);
  final otherLocations = rawOther < 0 ? 0 : rawOther;
  // The flag codes travel as a comma-joined string so the record stays
  // value-equal — a plain List compares by identity and would rebuild the
  // whole board on every groups tick even when nothing on screen changed.
  return (
    serverName: serverName,
    testUrl: testUrl,
    flags: otherCodes.join(','),
    otherLocations: otherLocations,
  );
}

class HeroConnect extends ConsumerWidget {
  const HeroConnect({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasProfile = ref.watch(
      profilesProvider.select((state) => state.isNotEmpty),
    );
    if (!hasProfile) return const _EmptyHero();

    final isReady = ref.watch(initProvider);
    final profile = ref.watch(currentProfileProvider);
    final panelMeta = profile?.panelMeta;
    final announce = _decodeAnnounce(panelMeta?.announce);
    final sub = profile?.subscriptionInfo;
    final hasSub = sub != null && (sub.total > 0 || sub.expire > 0);

    final buyPlanUrl = panelMeta?.buyPlanUrl;
    final buyTrafficUrl = panelMeta?.buyTrafficUrl;
    final buyUrl = (buyPlanUrl != null && buyPlanUrl.isNotEmpty)
        ? buyPlanUrl
        : (buyTrafficUrl != null && buyTrafficUrl.isNotEmpty)
            ? buyTrafficUrl
            : null;

    final serverInfoHeader = panelMeta?.serverInfoGroup;
    final mode = ref.watch(
      patchClashConfigProvider.select((state) => state.mode),
    );
    final serverInfo = ref.watch(
      groupsProvider.select(
        (state) => _selectServerInfo(
          switch (mode) {
            Mode.direct => const <Group>[],
            Mode.global => state.toList(),
            Mode.rule => state
                .where((item) => item.hidden == false)
                .where((element) => element.name != GroupName.GLOBAL.name)
                .toList(),
          },
          serverInfoHeader,
        ),
      ),
    );
    final serverName = serverInfo.serverName;
    final testUrl = serverInfo.testUrl;
    final otherCodes = serverInfo.flags.isEmpty
        ? const <String>[]
        : serverInfo.flags.split(',');
    final otherLocations = serverInfo.otherLocations;
    final displayName = _stripLeadingEmoji(serverName);
    final nameCountryCode = _flagToCountryCode(serverName);
    final isUpdating = profile != null &&
        ref.watch(isUpdatingProvider(profile.updatingKey));

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 8),
          _OrbSection(isReady: isReady, displayName: displayName),
          const SizedBox(height: 16),
          _ServerPanel(
            serverName: serverName,
            displayName: displayName,
            nameCountryCode: nameCountryCode,
            testUrl: testUrl,
            otherCodes: otherCodes,
            otherLocations: otherLocations,
          ),
          if (hasSub) ...[
            const SizedBox(height: 12),
            _TrafficCard(sub: sub, buyUrl: buyUrl),
          ],
          const SizedBox(height: 12),
          _HeroActionRow(
            isUpdating: isUpdating,
            onUpdate: profile == null
                ? null
                : () => unawaited(
                      ref
                          .read(profilesActionProvider.notifier)
                          .updateProfile(profile, showLoading: true),
                    ),
            supportUrl: panelMeta?.supportUrl,
          ),
          if (announce != null && announce.isNotEmpty) ...[
            const SizedBox(height: 12),
            _AnnounceBanner(text: announce),
          ],
          SizedBox(height: 12 + BottomInsetScope.of(context)),
        ],
      ),
    );
  }
}

class _OrbSection extends ConsumerStatefulWidget {
  const _OrbSection({required this.isReady, required this.displayName});

  final bool isReady;
  final String displayName;

  @override
  ConsumerState<_OrbSection> createState() => _OrbSectionState();
}

class _OrbSectionState extends ConsumerState<_OrbSection> {
  HeroOrbPhase _phase = HeroOrbPhase.off;

  @override
  void initState() {
    super.initState();
    if (ref.read(runTimeProvider) != null) {
      _phase = ref.read(pausedProvider)
          ? HeroOrbPhase.paused
          : HeroOrbPhase.on;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final runMinutes = ref.watch(
      runTimeProvider.select((value) => value == null ? null : value ~/ 60000),
    );
    final isConnected = runMinutes != null && _phase != HeroOrbPhase.paused;

    final title = switch (_phase) {
      HeroOrbPhase.on => appLocalizations.heroProtected,
      HeroOrbPhase.connecting => appLocalizations.heroConnecting,
      HeroOrbPhase.paused => appLocalizations.heroPaused,
      HeroOrbPhase.off => appLocalizations.heroNotProtected,
    };
    final subtitle = switch (_phase) {
      HeroOrbPhase.on => appLocalizations.connectedFor(
          heroDurationWords(runMinutes),
        ),
      HeroOrbPhase.connecting => widget.displayName,
      HeroOrbPhase.paused => appLocalizations.heroTapToResume,
      HeroOrbPhase.off => appLocalizations.heroTapToConnect,
    };

    final lastTraffic = isConnected
        ? ref.watch(
            trafficsProvider.select(
              (state) => state.list.isEmpty ? null : state.list.last,
            ),
          )
        : null;

    return Column(
      children: [
        const SizedBox(height: 18),
        HeroOrb(
          size: 220,
          enabled: widget.isReady,
          onPhaseChanged: (phase) => setState(() => _phase = phase),
        ),
        const SizedBox(height: 18),
        Text(
          title,
          textAlign: TextAlign.center,
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        RepaintBoundary(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: isConnected ? 1 : 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SpeedEntry(
                  icon: Icons.south_rounded,
                  value: lastTraffic?.down,
                ),
                const SizedBox(width: 22),
                _SpeedEntry(icon: Icons.north_rounded, value: lastTraffic?.up),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SpeedEntry extends StatelessWidget {
  const _SpeedEntry({required this.icon, required this.value});

  final IconData icon;
  final num? value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final show = value?.traffic;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(
          show != null ? show.value : '—',
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontFamily: FontFamily.jetBrainsMono.value,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          show != null ? '${show.unit}/s' : '',
          style: context.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    const size = 104.0;
    const radius = size * 0.25;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.asset('assets/images/icon.png',
          width: size, height: size, fit: BoxFit.cover),
    );
  }
}

class _TrafficCard extends StatelessWidget {
  const _TrafficCard({required this.sub, this.buyUrl});

  final SubscriptionInfo sub;
  final String? buyUrl;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final used = sub.upload + sub.download;
    final total = sub.total;
    final unlimited = total <= 0;
    final progress = total > 0 ? (used / total).clamp(0.0, 1.0) : 0.0;
    final barColor = progress > 0.9
        ? Colors.red.shade400
        : progress > 0.7
            ? Colors.orange.shade400
            : colorScheme.primary;

    int? daysLeft;
    if (sub.expire > 0) {
      daysLeft = DateTime.fromMillisecondsSinceEpoch(sub.expire * 1000)
          .difference(DateTime.now())
          .inDays;
      if (daysLeft < 0) daysLeft = 0;
    }

    final daysUrgent = daysLeft != null && daysLeft <= 3;
    final daysColor = daysUrgent ? Colors.red.shade400 : colorScheme.primary;
    final free = total > 0 ? (total - used).clamp(0, total) : 0;

    return HeroSurface(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  appLocalizations.subscriptionCaption,
                  style: context.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (daysLeft != null) ...[
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(heroPillRadius),
                    color: daysColor.withValues(alpha: 0.14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.event_rounded, size: 14, color: daysColor),
                      const SizedBox(width: 5),
                      Text(
                        '${appLocalizations.remaining} $daysLeft ${heroDaysWord(daysLeft)}',
                        style: context.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: daysColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          if (unlimited)
            Text(
              _formatBytes(used),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                fontFamily: FontFamily.jetBrainsMono.value,
              ),
            )
          else
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: _formatBytes(free),
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontFamily: FontFamily.jetBrainsMono.value,
                    ),
                  ),
                  const TextSpan(text: ' '),
                  TextSpan(
                    text: appLocalizations.trafficFreeOfTotal(
                      _formatBytes(total),
                    ),
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          if (!unlimited) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(heroInlayRadius),
              child: Stack(
                children: [
                  Container(
                      height: 8, color: colorScheme.surfaceContainerHighest),
                  FractionallySizedBox(
                    widthFactor: progress <= 0 ? 0.0 : progress,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(heroInlayRadius),
                        gradient: LinearGradient(
                          colors: [barColor.withValues(alpha: 0.7), barColor],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: _ActionChip(
              icon: Icons.autorenew_rounded,
              label: appLocalizations.renewSubscription,
              compact: true,
              onTap: buyUrl != null && buyUrl!.isNotEmpty
                  ? () => unawaited(dialogs.openUrl(buyUrl!))
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _ServerPanel extends StatelessWidget {
  const _ServerPanel({
    required this.serverName,
    required this.displayName,
    required this.nameCountryCode,
    required this.testUrl,
    this.otherCodes = const [],
    this.otherLocations = 0,
  });

  final String serverName;
  final String displayName;
  final String? nameCountryCode;
  final String? testUrl;
  final List<String> otherCodes;
  final int otherLocations;

  @override
  Widget build(BuildContext context) => HeroSurface(
        child: Column(
          children: [
            _ServerZone(
              serverName: serverName,
              displayName: displayName,
              nameCountryCode: nameCountryCode,
              testUrl: testUrl,
              otherCodes: otherCodes,
              otherLocations: otherLocations,
            ),
            const HeroCardDivider(),
            const HeroRoutingRow(),
          ],
        ),
      );
}

class _ServerZone extends ConsumerWidget {
  const _ServerZone({
    required this.serverName,
    required this.displayName,
    required this.nameCountryCode,
    required this.testUrl,
    this.otherCodes = const [],
    this.otherLocations = 0,
  });

  final String serverName;
  final String displayName;
  final String? nameCountryCode;
  final String? testUrl;
  final List<String> otherCodes;
  final int otherLocations;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final isConnected =
        ref.watch(runTimeProvider.select((value) => value != null));
    final delay = serverName.isNotEmpty
        ? ref.watch(delayProvider(proxyName: serverName, testUrl: testUrl))
        : null;
    final networkState = ref.watch(networkDetectionProvider);
    final ipInfo = networkState.ipInfo;

    final code = nameCountryCode ?? ipInfo?.countryCode ?? '';
    final flag = _countryCodeToEmoji(code);
    final title = displayName.isNotEmpty ? displayName : '—';

    return FocusableTap(
      borderRadius: heroCardRadius,
      onTap: () =>
          ref.read(currentPageLabelProvider.notifier).toPage(PageLabel.proxies),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            _FlagCircle(
              countryCode: code,
              fallbackEmoji: flag,
              otherCodes: otherCodes,
              stackCount: otherLocations,
              size: 44,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: context.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (isConnected) ...[
                    const SizedBox(height: 3),
                    if (ipInfo != null)
                      Text(
                        ipInfo.ip,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontFamily: FontFamily.jetBrainsMono.value,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    else if (networkState.isLoading)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CommonCircleLoading(
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 7),
                          Text(
                            appLocalizations.determiningIp,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        '—',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontFamily: FontFamily.jetBrainsMono.value,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 46,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _SignalBars(delay: delay),
                  if (delay != null && delay > 0) ...[
                    const SizedBox(height: 3),
                    Text(
                      '$delay ms',
                      textAlign: TextAlign.center,
                      style: context.textTheme.labelSmall?.copyWith(
                        color:
                            getDelayColor(delay) ??
                                colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        fontFamily: FontFamily.jetBrainsMono.value,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _FlagCircle extends StatelessWidget {
  const _FlagCircle({
    required this.countryCode,
    required this.fallbackEmoji,
    this.otherCodes = const [],
    this.stackCount = 0,
    this.size = 52,
  });

  final String countryCode;
  final String fallbackEmoji;
  final List<String> otherCodes;
  final int stackCount;
  final double size;

  @override
  Widget build(BuildContext context) {
    final size = this.size;
    final colorScheme = context.colorScheme;
    final cc = countryCode.trim().toLowerCase();

    Widget fallback() => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colorScheme.surfaceContainerHighest,
          ),
          alignment: Alignment.center,
          child:
              EmojiText(fallbackEmoji, style: TextStyle(fontSize: size * 0.5)),
        );

    final active = cc.length != 2
        ? fallback()
        : ClipOval(
            child: CachedNetworkImage(
              imageUrl: 'https://flagcdn.com/w160/$cc.png',
              width: size,
              height: size,
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(
                width: size,
                height: size,
                color: colorScheme.surfaceContainerHighest,
              ),
              errorWidget: (_, _, _) => fallback(),
            ),
          );

    final backs = otherCodes.take(2).toList();
    Widget backFlag(int i, String code) {
      final s = size * (1 - 0.14 * i);
      return Transform.translate(
        offset: Offset(0, -10.0 * i),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: colorScheme.surface, width: 1.5),
          ),
          child: ClipOval(
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl:
                      'https://flagcdn.com/w80/${code.toLowerCase()}.png',
                  width: s,
                  height: s,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => SizedBox(width: s, height: s),
                  errorWidget: (_, _, _) => Container(
                    width: s,
                    height: s,
                    color: colorScheme.surfaceContainerHighest,
                  ),
                ),
                Positioned.fill(
                  child: ColoredBox(
                      color: Colors.black.withValues(alpha: 0.15 * i)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final badge = stackCount <= 0
        ? null
        : Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(heroPillRadius),
              color: colorScheme.primary,
              border: Border.all(color: colorScheme.surface, width: 1.5),
            ),
            child: Text(
              '+$stackCount',
              style: context.textTheme.labelSmall?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.w700,
                fontFamily: FontFamily.jetBrainsMono.value,
              ),
            ),
          );

    final unit = Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        for (var i = backs.length; i >= 1; i--) backFlag(i, backs[i - 1]),
        active,
        if (badge != null) Positioned(right: -3, bottom: -3, child: badge),
      ],
    );

    final topPeek = backs.isEmpty
        ? 0.0
        : (10.0 * backs.length +
                size * (1 - 0.14 * backs.length) / 2 -
                size / 2 +
                2)
            .clamp(0.0, 40.0)
            .toDouble();
    final bottomPeek = badge != null ? 7.0 : 0.0;

    if (topPeek == 0 && bottomPeek == 0) {
      return SizedBox(width: size, height: size, child: unit);
    }
    return SizedBox(
      width: size,
      height: size + topPeek + bottomPeek,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
              top: topPeek, left: 0, width: size, height: size, child: unit),
        ],
      ),
    );
  }
}

class _SignalBars extends StatelessWidget {
  const _SignalBars({required this.delay});

  final int? delay;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final dim = colorScheme.onSurfaceVariant.withValues(alpha: 0.25);

    final int level;
    final Color color;
    if (delay == null || delay == 0) {
      level = 0;
      color = dim;
    } else if (delay! < 0) {
      level = 0;
      color = Colors.red.shade400;
    } else {
      color = getDelayColor(delay) ?? Colors.green;
      level = delay! < 150
          ? 4
          : delay! < 300
              ? 3
              : delay! < 600
                  ? 2
                  : 1;
    }

    const heights = [9.0, 13.0, 17.0, 21.0];
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(
          4,
          (i) => Padding(
                padding: EdgeInsets.only(left: i == 0 ? 0 : 3),
                child: Container(
                  width: 4,
                  height: heights[i],
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(heroInlayRadius),
                    color: i < level ? color : dim,
                  ),
                ),
              )),
    );
  }
}

class _EmptyHero extends StatelessWidget {
  const _EmptyHero();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        const _Logo(),
        const SizedBox(height: 16),
        Text(
          appName,
          style: context.textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            autofocus: true,
            onPressed: () {
              showExtend(
                context,
                builder: (context) => AdaptiveSheetScaffold(
                  title: context.appLocalizations.addProfile,
                  body: AddProfileView(context: context),
                ),
              );
            },
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            icon: const Icon(Icons.add_rounded, size: 20),
            label: Text(context.appLocalizations.addProfile),
          ),
        ),
      ],
    );
  }
}

class _AnnounceBanner extends StatelessWidget {
  const _AnnounceBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(heroCardRadius),
        color: colorScheme.secondaryContainer,
      ),
      child: EmojiText(
        text,
        style: context.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSecondaryContainer,
          height: 1.4,
        ),
      ),
    );
  }
}

class _HeroActionRow extends ConsumerWidget {
  const _HeroActionRow({
    required this.isUpdating,
    required this.onUpdate,
    this.supportUrl,
  });

  final bool isUpdating;
  final VoidCallback? onUpdate;
  final String? supportUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final hasSupport = supportUrl != null && supportUrl!.isNotEmpty;
    final showPauseChip =
        ref.watch(isStartProvider) &&
        (ref.watch(tunEnabledProvider) || ref.watch(pausedProvider));
    return Row(
      children: [
        Expanded(
          child: _ActionChip(
            icon: Icons.refresh_rounded,
            label: appLocalizations.update,
            busy: isUpdating,
            onTap: onUpdate,
          ),
        ),
        if (hasSupport) ...[
          const SizedBox(width: 10),
          Expanded(
            child: _ActionChip(
              icon: Icons.support_agent_rounded,
              label: appLocalizations.support,
              onTap: () => unawaited(dialogs.openUrl(supportUrl!)),
            ),
          ),
        ],
        if (showPauseChip) ...[
          const SizedBox(width: 10),
          const _PauseChip(),
        ],
        const SizedBox(width: 10),
        const _ModeChip(),
      ],
    );
  }
}

class _PauseChip extends ConsumerWidget {
  const _PauseChip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = context.colorScheme;
    final appLocalizations = context.appLocalizations;
    final paused = ref.watch(pausedProvider);
    return Tooltip(
      message: paused ? appLocalizations.resume : appLocalizations.pause,
      child: FocusableTap(
        borderRadius: heroPillRadius,
        onTap: () => ref.read(commonActionProvider.notifier).togglePaused(),
        child: HeroSurface(
          radius: heroPillRadius,
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: Icon(
            paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
            size: 18,
            color: colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

class _ModeChip extends ConsumerWidget {
  const _ModeChip();

  IconData _modeIcon(Mode mode) => switch (mode) {
        Mode.rule => Icons.rule,
        Mode.global => Icons.public,
        Mode.direct => Icons.flash_on,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = context.colorScheme;
    final mode = ref.watch(
      patchClashConfigProvider.select((state) => state.mode),
    );
    return CommonPopupBox(
      targetBuilder: (open) => Tooltip(
        message: mode.label,
        child: FocusableTap(
          borderRadius: heroPillRadius,
          onTap: () => open(offset: const Offset(0, 20)),
          child: HeroSurface(
            radius: heroPillRadius,
            width: 44,
            height: 44,
            alignment: Alignment.center,
            child: Icon(_modeIcon(mode), size: 18, color: colorScheme.primary),
          ),
        ),
      ),
      popupBuilder: (_) => CommonPopupMenu(
        items: [
          for (final item in Mode.values)
            CommonPopupMenuItem(
              icon: _modeIcon(item),
              label: item.label,
              onPressed: () {
                ref.read(setupActionProvider.notifier).changeMode(item);
              },
            ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.busy = false,
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool busy;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final height = compact ? 34.0 : 44.0;
    final iconSize = compact ? 16.0 : 18.0;
    return FocusableTap(
      borderRadius: heroPillRadius,
      onTap: busy ? null : onTap,
      child: HeroSurface(
        radius: heroPillRadius,
        height: height,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: iconSize,
              height: iconSize,
              child: busy
                  ? CommonCircleLoading(color: colorScheme.primary)
                  : Icon(icon, size: iconSize, color: colorScheme.primary),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: (compact
                        ? context.textTheme.labelMedium
                        : context.textTheme.labelLarge)
                    ?.copyWith(fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
