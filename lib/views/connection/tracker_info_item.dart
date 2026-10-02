import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/widgets/widgets.dart';

String _ruleText(TrackerInfo trackerInfo) {
  final rule = trackerInfo.rule;
  final rulePayload = trackerInfo.rulePayload;
  if (rulePayload.isNotEmpty) {
    return '$rule($rulePayload)';
  }
  return rule;
}

String _endpointText(String ip, String port) {
  if (ip.isEmpty) {
    return '';
  }
  if (port.isNotEmpty) {
    return '$ip:$port';
  }
  return ip;
}

class TrackerInfoItem extends ConsumerWidget {
  final TrackerInfo trackerInfo;
  final bool isLive;
  final Function(String)? onClickKeyword;
  final Widget? trailing;
  final String detailTitle;

  const TrackerInfoItem({
    super.key,
    required this.trackerInfo,
    this.isLive = false,
    this.onClickKeyword,
    this.trailing,
    required this.detailTitle,
  });

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showAppIcon = ref.watch(
      patchClashConfigProvider.select(
        (state) =>
            state.findProcessMode == FindProcessMode.always &&
            (system.isAndroid || system.isDesktop),
      ),
    );
    return RecordListItem(
      onTap: () => _openDetail(context),
      header: _buildHeader(context),
      body: _buildBody(showAppIcon: showAppIcon),
    );
  }

  Widget _buildBody({required bool showAppIcon}) {
    final metadata = trackerInfo.metadata;
    final process = metadata.process;
    final body = _TrackerInfoBody(
      trackerInfo: trackerInfo,
      onClickKeyword: onClickKeyword,
    );
    final hasProcess =
        process.isNotEmpty ||
        (system.isDesktop && metadata.processPath.isNotEmpty);
    if (!showAppIcon || !hasProcess) {
      return body;
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.md,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: process.isEmpty ? null : () => onClickKeyword?.call(process),
          child: system.isAndroid
              ? PackageIcon(packageName: process, size: 40)
              : ProcessIcon(
                  processPath: metadata.processPath,
                  process: process,
                  size: 40,
                  placeholder: const SizedBox.square(dimension: 40),
                ),
        ),
        Expanded(child: body),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final network = Text(
      trackerInfo.metadata.network.toUpperCase(),
      style: const TextStyle(fontWeight: FontWeight.w500),
    );
    if (!isLive) {
      return RecordHeader(
        trailing: trailing,
        children: [RecordTimestamp(trackerInfo.start.showFull), network],
      );
    }
    final color = context.colorScheme.onSurfaceVariant;
    WidgetSpan arrow(Glyph glyph) => WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: GlyphIcon(glyph, size: 12, color: color),
    );
    return RecordHeader(
      trailing: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: [
          Text.rich(
            TextSpan(
              children: [
                arrow(AppGlyphs.arrowUp),
                TextSpan(
                  text: ' ${(trackerInfo.uploadSpeed ?? 0).traffic.show}/s   ',
                ),
                arrow(AppGlyphs.arrowDown),
                TextSpan(
                  text: ' ${(trackerInfo.downloadSpeed ?? 0).traffic.show}/s',
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
      children: [
        Text(trackerInfo.start.getLastUpdateTimeDesc(context)),
        network,
      ],
    );
  }
}

class _TrackerInfoBody extends StatelessWidget {
  final TrackerInfo trackerInfo;
  final Function(String)? onClickKeyword;

  const _TrackerInfoBody({required this.trackerInfo, this.onClickKeyword});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final styles = RecordTextStyles.of(context);
    final metadata = trackerInfo.metadata;
    final rule = _ruleText(trackerInfo);
    final source = [
      trackerInfo.progressText,
      _endpointText(metadata.sourceIP, metadata.sourcePort),
    ].where((text) => text.isNotEmpty).join('  ·  ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.xs,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: _endpointText(
                  trackerInfo.title,
                  metadata.destinationPort,
                ),
                style: styles.primary?.copyWith(fontWeight: FontWeight.w500),
              ),
              if (metadata.host.isNotEmpty && metadata.destinationIP.isNotEmpty)
                TextSpan(
                  text: '  ${metadata.destinationIP}',
                  style: styles.muted,
                ),
            ],
          ),
        ),
        Wrap(
          spacing: 6,
          runSpacing: AppSpacing.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (rule.isNotEmpty) Text(rule, style: styles.secondary),
            for (final (index, chain) in trackerInfo.chains.reversed.indexed)
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 6,
                children: [
                  if (index > 0 || rule.isNotEmpty) const RecordArrow(),
                  Flexible(
                    child: AppTag.compact(
                      chain,
                      background: colorScheme.secondaryContainer,
                      foreground: colorScheme.onSecondaryContainer,
                      onTap: () => onClickKeyword?.call(chain),
                    ),
                  ),
                ],
              ),
          ],
        ),
        if (source.isNotEmpty) Text(source, style: styles.muted),
      ],
    );
  }
}

class TrackerInfoDetailView extends StatelessWidget {
  final TrackerInfo trackerInfo;

  const TrackerInfoDetailView({super.key, required this.trackerInfo});

  String _getProcessText() {
    final process = trackerInfo.metadata.process;
    final uid = trackerInfo.metadata.uid;
    if (uid != 0) {
      return '$process($uid)';
    }
    return process;
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
        if (value.isNotEmpty) DetailRow.text(title: title, value: value),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final metadata = trackerInfo.metadata;
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ).copyWith(bottom: 20, top: context.appBarInset),
      children: [
        generateSectionV3(
          title: appLocalizations.basicInfo,
          items: _buildRows([
            (appLocalizations.creationTime, trackerInfo.start.showFull),
            (appLocalizations.networkType, metadata.network),
            (appLocalizations.process, _getProcessText()),
            (appLocalizations.rule, _ruleText(trackerInfo)),
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
              _endpointText(metadata.sourceIP, metadata.sourcePort),
            ),
            (
              appLocalizations.destination,
              _endpointText(metadata.destinationIP, metadata.destinationPort),
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
