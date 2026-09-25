import 'package:reclash/common/common.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _Routing { direct, proxy, reject, unknown }

class _RoutingStyle {
  final Color background;
  final Color foreground;
  final Glyph icon;

  const _RoutingStyle(this.background, this.foreground, this.icon);
}

_Routing _routingOf(List<String> chains) {
  if (chains.isEmpty) {
    return _Routing.unknown;
  }
  final upper = chains.map((chain) => chain.toUpperCase());
  if (upper.any(
    (chain) =>
        chain.startsWith('REJECT') || chain == 'BLACKHOLE' || chain == 'PASS',
  )) {
    return _Routing.reject;
  }
  if (upper.contains('DIRECT')) {
    return _Routing.direct;
  }
  return _Routing.proxy;
}

_RoutingStyle _routingStyle(BuildContext context, _Routing routing) {
  final colorScheme = context.colorScheme;
  return switch (routing) {
    _Routing.proxy => _RoutingStyle(
      colorScheme.primaryContainer,
      colorScheme.onPrimaryContainer,
      AppGlyphs.vpn,
    ),
    _Routing.direct => _RoutingStyle(
      colorScheme.tertiaryContainer,
      colorScheme.onTertiaryContainer,
      AppGlyphs.openExternal,
    ),
    _Routing.reject => _RoutingStyle(
      colorScheme.errorContainer,
      colorScheme.onErrorContainer,
      AppGlyphs.block,
    ),
    _Routing.unknown => _RoutingStyle(
      colorScheme.surfaceContainerHighest,
      colorScheme.onSurfaceVariant,
      AppGlyphs.help,
    ),
  };
}

class TrackerInfoItem extends ConsumerWidget {
  final TrackerInfo trackerInfo;
  final Function(String)? onClickKeyword;
  final Widget? trailing;
  final String detailTitle;

  const TrackerInfoItem({
    super.key,
    required this.trackerInfo,
    this.onClickKeyword,
    this.trailing,
    required this.detailTitle,
  });

  String get _host {
    final host = trackerInfo.title;
    return host.isEmpty ? trackerInfo.desc : host;
  }

  String get _networkTag {
    final network = trackerInfo.metadata.network.toUpperCase();
    final port = trackerInfo.metadata.destinationPort;
    if (network.isEmpty) {
      return port.isEmpty ? '' : ':$port';
    }
    return port.isEmpty ? network : '$network:$port';
  }

  String get _outboundLabel {
    final chains = trackerInfo.chains;
    return chains.isEmpty ? '' : chains.first;
  }

  void _openDetail(BuildContext context) {
    showExtend(
      context,
      builder: (_) {
        return AdaptiveSheetScaffold(
          sheetTransparentToolBar: true,
          body: TrackerInfoDetailView(trackerInfo: trackerInfo),
          title: detailTitle,
        );
      },
    );
  }

  String get _countryCode {
    for (final code in trackerInfo.metadata.destinationGeoIP) {
      final trimmed = code.trim();
      final upper = trimmed.toUpperCase();
      if (trimmed.isEmpty || upper == 'PRIVATE' || upper == 'LAN') {
        continue;
      }
      return upper.length > 3 ? upper.substring(0, 3) : upper;
    }
    return '';
  }

  Widget _routingAvatar(_RoutingStyle style) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: ShapeDecoration(color: style.background, shape: AppShape.md),
      child: GlyphIcon(style.icon, size: 22, color: style.foreground),
    );
  }

  Widget _buildLeading(
    BuildContext context,
    bool showAppIcon,
    _RoutingStyle style,
  ) {
    final Widget avatar;
    if (showAppIcon) {
      final process = trackerInfo.metadata.process;
      final Widget iconChild = system.isAndroid
          ? PackageIcon(
              packageName: process,
              size: 44,
              placeholder: _routingAvatar(style),
            )
          : ProcessIcon(
              processPath: trackerInfo.metadata.processPath,
              process: process,
              size: 44,
              placeholder: _routingAvatar(style),
            );
      avatar = GestureDetector(
        onTap: () {
          if (process.isEmpty) return;
          onClickKeyword?.call(process);
        },
        child: Container(
          width: 44,
          height: 44,
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: context.colorScheme.surfaceContainerHighest,
            shape: AppShape.md.copyWith(
              side: BorderSide(color: style.background, width: 2),
            ),
          ),
          child: iconChild,
        ),
      );
    } else {
      avatar = _routingAvatar(style);
    }
    final code = _countryCode;
    if (code.isEmpty) {
      return avatar;
    }
    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        Positioned(right: -4, bottom: -4, child: _CountryBadge(code: code)),
      ],
    );
  }

  @override
  Widget build(BuildContext context, ref) {
    final colorScheme = context.colorScheme;
    final showAppIcon = ref.watch(
      patchClashConfigProvider.select(
        (state) =>
            state.findProcessMode == FindProcessMode.always &&
            (system.isAndroid || system.isDesktop),
      ),
    );
    final style = _routingStyle(context, _routingOf(trackerInfo.chains));
    final outbound = _outboundLabel;
    final networkTag = _networkTag;
    final rule = trackerInfo.rule;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => _openDetail(context),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 14,
            children: [
              _buildLeading(context, showAppIcon, style),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Text(
                      _host,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleSmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (networkTag.isNotEmpty || rule.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 8,
                        children: [
                          if (networkTag.isNotEmpty)
                            _MetaTag(label: networkTag),
                          if (rule.isNotEmpty)
                            Flexible(
                              child: Text(
                                rule,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                        ],
                      ),
                    if (outbound.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: _RoutingPill(
                          label: outbound,
                          style: style,
                          onPressed: () => onClickKeyword?.call(outbound),
                        ),
                      ),
                  ],
                ),
              ),
              _TrafficPanel(trackerInfo: trackerInfo),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}

class _TrafficPanel extends StatelessWidget {
  final TrackerInfo trackerInfo;

  const _TrafficPanel({required this.trackerInfo});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final downSpeed = trackerInfo.downloadSpeed ?? 0;
    final upSpeed = trackerInfo.uploadSpeed ?? 0;
    final downLive = downSpeed > 0;
    final upLive = upSpeed > 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        Text(
          trackerInfo.start.getLastUpdateTimeDesc(context),
          style: context.textTheme.labelSmall?.copyWith(
            color: colorScheme.outline,
          ),
        ),
        _SpeedLine(
          icon: AppGlyphs.arrowDown,
          accent: colorScheme.primary,
          live: downLive,
          value: downLive
              ? '${downSpeed.traffic.show}/s'
              : trackerInfo.download.traffic.show,
        ),
        _SpeedLine(
          icon: AppGlyphs.arrowUp,
          accent: colorScheme.tertiary,
          live: upLive,
          value: upLive
              ? '${upSpeed.traffic.show}/s'
              : trackerInfo.upload.traffic.show,
        ),
      ],
    );
  }
}

class _SpeedLine extends StatelessWidget {
  final Glyph icon;
  final Color accent;
  final bool live;
  final String value;

  const _SpeedLine({
    required this.icon,
    required this.accent,
    required this.live,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final color = live ? accent : colorScheme.onSurfaceVariant;
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: live ? accent.opacity12 : Colors.transparent,
        shape: AppShape.full,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            GlyphIcon(icon, size: 12, color: color),
            Text(
              value,
              style: context.textTheme.labelSmall?.toJetBrainsMono.copyWith(
                color: color,
                fontWeight: live ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaTag extends StatelessWidget {
  final String label;

  const _MetaTag({required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: colorScheme.surfaceContainerHighest,
        shape: AppShape.sm,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        child: Text(
          label,
          style: context.textTheme.labelSmall
              ?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              )
              .toJetBrainsMono,
        ),
      ),
    );
  }
}

class _CountryBadge extends StatelessWidget {
  final String code;

  const _CountryBadge({required this.code});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: colorScheme.surfaceContainerHighest,
        shape: AppShape.full.copyWith(
          side: BorderSide(color: colorScheme.surface, width: 2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        child: Text(
          code,
          style: context.textTheme.labelSmall
              ?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              )
              .toJetBrainsMono,
        ),
      ),
    );
  }
}

class _RoutingPill extends StatelessWidget {
  final String label;
  final _RoutingStyle style;
  final VoidCallback? onPressed;

  const _RoutingPill({
    required this.label,
    required this.style,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: style.background,
      shape: AppShape.full,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 3, 10, 3),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              GlyphIcon(style.icon, size: 13, color: style.foreground),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.labelMedium?.copyWith(
                  color: style.foreground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TrackerInfoDetailView extends StatelessWidget {
  final TrackerInfo trackerInfo;

  const TrackerInfoDetailView({super.key, required this.trackerInfo});

  String _getRuleText() {
    final rule = trackerInfo.rule;
    final rulePayload = trackerInfo.rulePayload;
    if (rulePayload.isNotEmpty) {
      return '$rule($rulePayload)';
    }
    return rule;
  }

  String _getProcessText() {
    final process = trackerInfo.metadata.process;
    final uid = trackerInfo.metadata.uid;
    if (uid != 0) {
      return '$process($uid)';
    }
    return process;
  }

  String _getEndpointText(String ip, String port) {
    if (ip.isEmpty) {
      return '';
    }
    if (port.isNotEmpty) {
      return '$ip:$port';
    }
    return ip;
  }

  Widget _buildChains(BuildContext context) {
    return DecorationListItem(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 20,
        children: [
          Text(context.appLocalizations.proxyChains),
          Flexible(
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              alignment: WrapAlignment.end,
              children: [
                for (final chain in trackerInfo.chains) MetaChip(label: chain),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildRows(List<(String, String)> entries) {
    return [
      for (final (title, value) in entries)
        if (value.isNotEmpty) _DetailRow(title: title, value: value),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final metadata = trackerInfo.metadata;
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ).copyWith(bottom: 20, top: context.sheetTopPadding),
      children: [
        generateSectionV3(
          title: appLocalizations.basicInfo,
          items: _buildRows([
            (appLocalizations.creationTime, trackerInfo.start.showFull),
            (appLocalizations.networkType, metadata.network),
            (appLocalizations.process, _getProcessText()),
            (appLocalizations.rule, _getRuleText()),
            (appLocalizations.upload, trackerInfo.upload.traffic.show),
            (appLocalizations.download, trackerInfo.download.traffic.show),
          ]),
        ),
        generateSectionV3(
          title: appLocalizations.address,
          items: _buildRows([
            (appLocalizations.host, metadata.host),
            (
              appLocalizations.source,
              _getEndpointText(metadata.sourceIP, metadata.sourcePort),
            ),
            (
              appLocalizations.destination,
              _getEndpointText(
                metadata.destinationIP,
                metadata.destinationPort,
              ),
            ),
            (
              appLocalizations.destinationGeoIP,
              metadata.destinationGeoIP.join(' '),
            ),
            (appLocalizations.destinationIPASN, metadata.destinationIPASN),
            (appLocalizations.remoteDestination, metadata.remoteDestination),
          ]),
        ),
        generateSectionV3(
          title: appLocalizations.proxies,
          items: [
            ..._buildRows([
              (appLocalizations.specialProxy, metadata.specialProxy),
              (appLocalizations.specialRules, metadata.specialRules),
              (appLocalizations.dnsMode, metadata.dnsMode?.name ?? ''),
            ]),
            _buildChains(context),
          ],
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String title;
  final String value;

  const _DetailRow({required this.title, required this.value});

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted) return;
    context.showNotifier(context.appLocalizations.copySuccess);
  }

  @override
  Widget build(BuildContext context) {
    return DecorationListItem(
      onPressed: () => _copy(context),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 20,
        children: [
          Text(title),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
