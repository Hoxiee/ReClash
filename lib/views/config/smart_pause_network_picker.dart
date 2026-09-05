import 'dart:async';

import 'package:reclash/common/common.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi_ssid/wifi_ssid.dart';

typedef SsidListReader = Future<List<String>> Function();

enum _ScanPhase { scanning, ready }

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
      _SmartPauseNetworkPickerState();
}

class _SmartPauseNetworkPickerState
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
          leading: Icon(
            Icons.wifi_rounded,
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
          child: Row(
            children: [
              Expanded(
                child: Text(
                  appLocalizations.pickNetworkDesc,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              CommonMinIconButtonTheme(
                child: IconButton.filledTonal(
                  tooltip: appLocalizations.pickNetworkRefresh,
                  onPressed: _scan,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(child: _buildBody()),
      ],
    );
  }
}
