import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/views/config/on_demand_network_picker.dart';
import 'package:reclash/views/dashboard/style.dart';
import 'package:reclash/views/dashboard/widgets/card.dart';

/// On-demand in a person's terms: the networks where the tunnel steps aside
/// by itself and comes back once they leave.
class SimpleTrustedNetworksCard extends ConsumerWidget {
  const SimpleTrustedNetworksCard({super.key});

  void _add(WidgetRef ref, String network) {
    ref
        .read(excludeSSIDsProvider.notifier)
        .update(
          (state) => state.contains(network) ? state : [...state, network],
        );
  }

  Future<void> _pick(BuildContext context, WidgetRef ref) async {
    final network = await showOnDemandNetworkPicker(
      context,
      selected: ref.read(excludeSSIDsProvider).toSet(),
    );
    if (network != null) _add(ref, network);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final enabled = ref.watch(
      vpnSettingProvider.select((state) => state.onDemandEnabled),
    );
    final networks = ref.watch(excludeSSIDsProvider);
    final matched = ref.watch(onDemandMatchedNetworksProvider).toSet();
    final ssid = ref.watch(currentSSIDProvider);
    final addCurrent =
        ssid != null && ssid.isNotEmpty && !networks.contains(ssid);
    final accent = AppTextStyle.footnote
        .of(context, emphasized: true)
        .copyWith(color: colorScheme.primary);
    return DashboardCard(
      semanticLabel: appLocalizations.simpleTrustedTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          DashboardCardHeader(
            glyph: AppGlyphs.wifi,
            title: appLocalizations.simpleTrustedTitle,
            trailing: [
              DashboardSwitch(
                value: enabled,
                semanticLabel: appLocalizations.simpleTrustedTitle,
                onChanged: (value) => ref
                    .read(vpnSettingProvider.notifier)
                    .update((state) => state.copyWith(onDemandEnabled: value)),
              ),
            ],
          ),
          Text(
            appLocalizations.simpleTrustedDesc,
            style: DashboardText.label(context).copyWith(height: 1.3),
          ),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (networks.isEmpty)
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 2, end: 4),
                  child: Text(
                    appLocalizations.simpleTrustedEmpty,
                    style: AppTextStyle.footnote
                        .of(context)
                        .copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ),
              for (final network in networks)
                _NetworkChip(
                  name: network,
                  current: enabled && matched.contains(network),
                  onRemove: () => ref
                      .read(excludeSSIDsProvider.notifier)
                      .update(
                        (state) =>
                            state.where((item) => item != network).toList(),
                      ),
                ),
              DashboardBlock(
                radius: AppCorner.full,
                onTap: addCurrent
                    ? () => _add(ref, ssid)
                    : () => globalState.safeRun(() => _pick(context, ref)),
                padding: const EdgeInsetsDirectional.fromSTEB(10, 6, 12, 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 6,
                  children: [
                    GlyphIcon(
                      AppGlyphs.add,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                    Text(
                      addCurrent
                          ? appLocalizations.simpleTrustedThisNetwork
                          : appLocalizations.addNetwork,
                      style: accent,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NetworkChip extends StatefulWidget {
  const _NetworkChip({
    required this.name,
    required this.current,
    required this.onRemove,
  });

  final String name;
  final bool current;
  final VoidCallback onRemove;

  @override
  State<_NetworkChip> createState() => _NetworkChipState();
}

class _NetworkChipState extends State<_NetworkChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final colors = DashboardColors.of(context);
    final current = widget.current;
    final ink = current ? colors.onOkContainer : colorScheme.onSurfaceVariant;
    final removeLabel = context.appLocalizations.remove;
    final showRemove = !system.isDesktop || _hovered;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: current ? colors.okContainer : colors.tone,
          shape: AppShape.full,
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.only(
            start: 10,
            top: 6,
            bottom: 6,
            end: 12,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GlyphIcon(AppGlyphs.wifi, size: 16, color: ink),
              const SizedBox(width: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 160),
                child: Text(
                  widget.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.footnote
                      .of(context, emphasized: true)
                      .copyWith(color: current ? colors.onOkContainer : null),
                ),
              ),
              AnimatedSize(
                duration: context.motionDuration(
                  const Duration(milliseconds: 150),
                ),
                curve: Curves.easeOutCubic,
                alignment: AlignmentDirectional.centerStart,
                child: AnimatedOpacity(
                  duration: context.motionDuration(
                    const Duration(milliseconds: 150),
                  ),
                  opacity: showRemove ? 1 : 0,
                  child: showRemove
                      ? Padding(
                          padding: const EdgeInsetsDirectional.only(start: 4),
                          child: Tooltip(
                            message: removeLabel,
                            child: Semantics(
                              button: true,
                              label: removeLabel,
                              excludeSemantics: true,
                              child: InkResponse(
                                customBorder: AppShape.circle,
                                radius: 12,
                                onTap: widget.onRemove,
                                child: Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: GlyphIcon(
                                    AppGlyphs.close,
                                    size: 14,
                                    color: ink,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
