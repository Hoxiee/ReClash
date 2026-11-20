import 'package:reclash/common/common.dart';
import 'package:reclash/common/ip_sources.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/ip_quality.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class IpSourceManageView extends ConsumerWidget {
  const IpSourceManageView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = context.appLocalizations;
    final sources = ref.watch(ipSourcesProvider);
    final enabled = ref.watch(enabledIpSourcesProvider);
    final settings = ref.read(appSettingProvider.notifier);

    void reorder(int oldIndex, int newIndex) {
      settings.update(
        (state) => state.copyWith(
          ipSourceOrder: [
            for (final source in sources.copyAndReorder(oldIndex, newIndex))
              source.name,
          ],
        ),
      );
    }

    void toggle(IpSource source, bool value) {
      settings.update((state) {
        final disabled = {...state.disabledIpSources};
        final enabled = {...state.enabledIpSources};
        if (value) {
          disabled.remove(source.name);
          enabled.add(source.name);
        } else {
          disabled.add(source.name);
          enabled.remove(source.name);
        }
        return state.copyWith(
          enabledIpSources: enabled.toList(),
          disabledIpSources: disabled.toList(),
        );
      });
    }

    Widget itemAt(int index) {
      final source = sources[index];
      final isEnabled = enabled.contains(source);
      final locked = isEnabled && isLastIpSourceOfKind(source, enabled);
      return _IpSourceItem(
        key: ValueKey(source),
        source: source,
        index: index,
        position: ItemPosition.get(index, sources.length),
        enabled: isEnabled,
        onChanged: locked ? null : (value) => toggle(source, value),
      );
    }

    return CommonScaffold(
      title: localizations.ipSources,
      body: CustomScrollView(
        shrinkWrap: true,
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(height: context.contentTopPadding),
          ),
          SliverReorderableList(
            itemBuilder: (_, index) => itemAt(index),
            itemCount: sources.length,
            proxyDecorator: (child, index, animation) =>
                commonProxyDecorator(itemAt(index), index, animation),
            onReorderItem: reorder,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(bottom: 16 + context.bottomInset),
              child: ListFooter(text: localizations.ipSourcesFooter),
            ),
          ),
        ],
      ),
    );
  }
}

class _IpSourceItem extends StatelessWidget {
  const _IpSourceItem({
    super.key,
    required this.source,
    required this.index,
    required this.position,
    required this.enabled,
    required this.onChanged,
  });

  final IpSource source;
  final int index;
  final ItemPosition position;
  final bool enabled;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final localizations = context.appLocalizations;
    final onChanged = this.onChanged;
    final roles = [
      if (source.echoUrl != null) localizations.ipSourceAddress,
      if (source.quality != null) localizations.ipSourceQuality,
    ];
    return ReorderableDelayedDragStartListener(
      index: index,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ItemPositionProvider(
          position: position,
          child: DecorationListItem(
            onPressed: onChanged == null ? null : () => onChanged(!enabled),
            title: Text(
              source.label,
              style: enabled
                  ? null
                  : TextStyle(color: context.colorScheme.onSurfaceVariant),
            ),
            subtitle: Text(roles.join(' · ')),
            trailing: CommonSwitch(value: enabled, onChanged: onChanged),
          ),
        ),
      ),
    );
  }
}
