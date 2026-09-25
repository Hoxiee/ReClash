import 'dart:async';
import 'package:reclash/icons/icons.dart';

import 'package:reclash/common/common.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi_ssid/wifi_ssid.dart';

typedef SsidListReader = Future<List<String>> Function();

enum _ScanPhase { scanning, ready }

/// Both entry points — the long press on either dashboard's pause button and
/// the add action in settings — open the picker through here so refresh sits in
/// the app-bar capsule next to manual entry instead of inside the body.
Future<String?> showSmartPauseNetworkPickerSheet(
  BuildContext context, {
  required Set<String> selected,
  required ValueChanged<String> onSelected,
  VoidCallback? onEnterManually,
  SsidListReader? listSsid,
}) {
  final pickerKey = GlobalKey<SmartPauseNetworkPickerState>();
  return showSheet<String>(
    context: context,
    props: const SheetProps(maxHeight: 520),
    builder: (sheetContext) {
      final appLocalizations = sheetContext.appLocalizations;
      return SizedBox(
        height: 460,
        child: AdaptiveSheetScaffold(
          title: appLocalizations.pickNetwork,
          body: SmartPauseNetworkPicker(
            key: pickerKey,
            selected: selected,
            onSelected: (ssid) {
              Navigator.of(sheetContext).maybePop();
              onSelected(ssid);
            },
            listSsid: listSsid,
          ),
          actions: [
            IconButtonData(
              tooltip: appLocalizations.pickNetworkRefresh,
              glyph: AppGlyphs.refresh,
              onPressed: () => pickerKey.currentState?.refresh(),
            ),
            if (onEnterManually != null)
              IconButtonData(
                tooltip: appLocalizations.enterManually,
                glyph: AppGlyphs.keyboard,
                onPressed: onEnterManually,
              ),
          ],
        ),
      );
    },
  );
}

/// Reached by a long press on the pause button, on either dashboard.
void showSmartPauseNetworkSheet(BuildContext context, WidgetRef ref) {
  showSmartPauseNetworkPickerSheet(
    context,
    selected: ref
        .read(vpnSettingProvider.select((state) => state.smartPauseNetworks))
        .toSet(),
    onSelected: (ssid) {
      ref.read(vpnSettingProvider.notifier).update((state) {
        if (state.smartPauseNetworks.any(
          (item) => item.trim().toLowerCase() == ssid.toLowerCase(),
        )) {
          return state;
        }
        return state.copyWith(
          smartPauseNetworks: [...state.smartPauseNetworks, ssid],
        );
      });
    },
  );
}

class SmartPauseNetworkPicker extends ConsumerStatefulWidget {
  const SmartPauseNetworkPicker({
    super.key,
    required this.selected,
    required this.onSelected,
    this.listSsid,
  });

  final Set<String> selected;
  final ValueChanged<String> onSelected;
  final SsidListReader? listSsid;

  @override
  ConsumerState<SmartPauseNetworkPicker> createState() =>
      SmartPauseNetworkPickerState();
}

class SmartPauseNetworkPickerState
    extends ConsumerState<SmartPauseNetworkPicker> {
  late final SsidListReader _listSsid =
      widget.listSsid ?? wifiSsidManager.listSsid;

  _ScanPhase _phase = _ScanPhase.scanning;
  List<String> _ssids = const [];

  @override
  void initState() {
    super.initState();
    unawaited(_scan());
  }

  void refresh() => unawaited(_scan());

  Future<void> _scan() async {
    setState(() => _phase = _ScanPhase.scanning);
    try {
      final ssids = await _listSsid();
      if (!mounted) {
        return;
      }
      setState(() {
        _ssids = ssids;
        _phase = _ScanPhase.ready;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _phase = _ScanPhase.ready);
    }
  }

  Widget _buildBody() {
    final appLocalizations = context.appLocalizations;
    if (_phase == _ScanPhase.scanning) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            const CommonCircleLoading(),
            Text(
              appLocalizations.pickNetworkScanning,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }
    final known = _ssids.where((ssid) => !_isTrusted(ssid)).toList();
    if (known.isEmpty) {
      return NullStatus(
        label: appLocalizations.pickNetworkEmpty,
        description: appLocalizations.networkEntryHint,
        illustration: NullStatusIllustration.wifi,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: known.length,
      itemBuilder: (_, index) {
        final ssid = known[index];
        return DecorationListItem(
          minVerticalPadding: 8,
          contentPadding: const EdgeInsets.only(left: 16, right: 16),
          leading: GlyphIcon(
            AppGlyphs.wifi,
            color: context.colorScheme.onSurfaceVariant,
          ),
          title: TooltipText(
            text: Text(ssid, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          onPressed: () => widget.onSelected(ssid),
        );
      },
    );
  }

  bool _isTrusted(String ssid) {
    final low = ssid.trim().toLowerCase();
    return widget.selected.any((item) => item.trim().toLowerCase() == low);
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            appLocalizations.pickNetworkDesc,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(child: _buildBody()),
      ],
    );
  }
}
