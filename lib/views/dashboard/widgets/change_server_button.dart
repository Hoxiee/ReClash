import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _flagEmoji = RegExp(r'[\u{1F1E6}-\u{1F1FF}]{2}', unicode: true);
final _countryCode = RegExp(r'\b([A-Z]{2})\b');

String? _flagOf(String name) {
  final emoji = _flagEmoji.firstMatch(name);
  if (emoji != null) {
    return emoji.group(0);
  }
  final code = _countryCode.firstMatch(name);
  if (code == null) {
    return null;
  }
  return code.group(0)!;
}

String _countryCodeToEmoji(String countryCode) {
  final code = countryCode.toUpperCase();
  final first = code.codeUnitAt(0) - 0x41 + 0x1F1E6;
  final second = code.codeUnitAt(1) - 0x41 + 0x1F1E6;
  return String.fromCharCode(first) + String.fromCharCode(second);
}

class ChangeServerButton extends ConsumerWidget {
  const ChangeServerButton({super.key});

  void _handleToProxies(WidgetRef ref) {
    ref.read(currentPageLabelProvider.notifier).toPage(PageLabel.proxies);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final group = ref.watch(
      currentProfileProvider.select((state) => state?.panelMeta?.serverInfoGroup),
    );
    return SizedBox(
      height: getWidgetHeight(1),
      child: RepaintBoundary(
        child: CommonCard(
          radius: AppCorner.lg,
          onPressed: () {
            _handleToProxies(ref);
          },
          child: group == null
              ? _buildFallback(context, appLocalizations.changeServer)
              : _buildServer(context, ref, group),
        ),
      ),
    );
  }

  Widget _buildFallback(BuildContext context, String label) {
    return Container(
      padding: baseInfoEdgeInsets,
      child: Row(
        children: [
          Icon(Icons.shuffle, color: context.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.titleSmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServer(BuildContext context, WidgetRef ref, String group) {
    final appLocalizations = context.appLocalizations;
    final proxyName = ref.watch(
      realSelectedProxyStateProvider(group).select((state) => state.proxyName),
    );
    final delay = ref.watch(delayProvider(proxyName: proxyName));
    final flagSource = _flagOf(proxyName);
    final flag = flagSource == null
        ? Icon(Icons.public, color: context.colorScheme.onSurfaceVariant)
        : Text(
            flagSource.length == 2
                ? _countryCodeToEmoji(flagSource)
                : flagSource,
            style: context.textTheme.titleMedium?.toLight.copyWith(
              fontFamily: FontFamily.twEmoji.value,
            ),
          );
    final delayColor = getDelayColor(delay);
    final delayStyle = delayColor == null
        ? context.textTheme.bodyMedium?.toLight.adjustSize(1)
        : context.textTheme.bodyMedium
              ?.toLight
              .adjustSize(1)
              .copyWith(color: delayColor);
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          height: globalState.measure.titleMediumHeight + 16,
          padding: baseInfoEdgeInsets.copyWith(bottom: 0),
          child: Row(
            children: [
              flag,
              const SizedBox(width: 8),
              Flexible(
                child: TooltipText(
                  text: Text(
                    proxyName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.titleSmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: baseInfoEdgeInsets.copyWith(top: 0),
          height: globalState.measure.bodyMediumHeight + 2,
          child: FadeThroughBox(
            child: Text(
              delay == null || delay == 0
                  ? appLocalizations.timeout
                  : '${delay}ms',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: delayStyle,
            ),
          ),
        ),
      ],
    );
  }
}
