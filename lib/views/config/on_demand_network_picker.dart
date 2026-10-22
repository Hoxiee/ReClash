import 'dart:async';
import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:wifi_ssid/wifi_ssid.dart';

typedef SsidListReader = Future<List<String>> Function();

Future<String?> showOnDemandNetworkPicker(
  BuildContext context, {
  required Set<String> selected,
}) async {
  var enterManually = false;
  final network = await showSheet<String>(
    context: context,
    builder: (context) => OnDemandNetworkPicker(
      selected: selected,
      onSelected: (ssid) => Navigator.of(context).pop(ssid),
      onEnterManually: () {
        enterManually = true;
        Navigator.of(context).pop();
      },
    ),
  );
  if (!enterManually || !context.mounted) return network;
  return showOnDemandNetworkEntry(context, selected: selected);
}

Future<String?> showOnDemandNetworkEntry(
  BuildContext context, {
  required Set<String> selected,
  String? value,
}) {
  final l = context.appLocalizations;
  return dialogs.showCommonDialog<String>(
    child: InputDialog(
      title: value == null ? l.addNetwork : l.editNetwork,
      value: value ?? '',
      maxLength: 64,
      hintText: l.networkEntryHint,
      validator: (input) {
        if (input == null || input.isEmpty) return l.emptyTip('SSID').trim();
        if (selected.contains(input) && input != value) {
          return l.existsTip('SSID').trim();
        }
        if (RegExp(r'^[0-9a-fA-F:.]+/').hasMatch(input) &&
            !isSubnetRule(input)) {
          return l.invalidCidrContent;
        }
        if (!isSubnetRule(input) && utf8.encode(input).length > 32) {
          return l.invalidSsid;
        }
        return null;
      },
    ),
  );
}

class OnDemandNetworkPicker extends StatefulWidget {
  const OnDemandNetworkPicker({
    super.key,
    required this.selected,
    required this.onSelected,
    this.onEnterManually,
    this.listSsid,
  });

  final Set<String> selected;
  final ValueChanged<String> onSelected;
  final VoidCallback? onEnterManually;
  final SsidListReader? listSsid;

  @override
  State<OnDemandNetworkPicker> createState() => _OnDemandNetworkPickerState();
}

class _OnDemandNetworkPickerState extends State<OnDemandNetworkPicker> {
  bool _loading = true;
  bool _failed = false;
  List<String> _ssids = const [];
  String _query = '';
  bool _scanning = false;

  @override
  void initState() {
    super.initState();
    unawaited(_scan());
  }

  Future<void> _scan() async {
    if (_scanning) return;
    _scanning = true;
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final ssids = await (widget.listSsid ?? wifiSsidManager.listSsid)();
      if (mounted) setState(() => _ssids = ssids.toSet().toList());
    } catch (error) {
      commonPrint.log('Wi-Fi network scan failed: $error');
      if (mounted) setState(() => _failed = true);
    } finally {
      _scanning = false;
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final visible = _ssids
        .where(
          (ssid) =>
              !widget.selected.contains(ssid) &&
              ssid.toLowerCase().contains(_query.toLowerCase()),
        )
        .toList();
    return CommonScaffold(
      title: l.pickNetwork,
      iconActions: [
        IconButtonData(
          glyph: AppGlyphs.refresh,
          tooltip: l.pickNetworkRefresh,
          onPressed: _scan,
        ),
        if (widget.onEnterManually != null)
          IconButtonData(
            glyph: AppGlyphs.keyboard,
            tooltip: l.enterManually,
            onPressed: widget.onEnterManually,
          ),
      ],
      body: Padding(
        padding: EdgeInsets.fromLTRB(16, context.appBarInset, 16, 16),
        child: Column(
          children: [
            SearchField(onChanged: (query) => setState(() => _query = query)),
            const SizedBox(height: 12),
            Expanded(
              child: _loading
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CommonCircleLoading(),
                          const SizedBox(height: 12),
                          Text(
                            l.pickNetworkScanning,
                            style: AppTextStyle.subheadline.of(context),
                          ),
                        ],
                      ),
                    )
                  : _failed
                  ? NullStatus(
                      label: l.onDemandScanFailed,
                      illustration: NullStatusIllustration.wifi,
                    )
                  : visible.isEmpty
                  ? NullStatus(
                      label: l.pickNetworkEmpty,
                      description: l.networkEntryHint,
                      illustration: NullStatusIllustration.wifi,
                    )
                  : ListView.builder(
                      itemCount: visible.length,
                      itemBuilder: (_, index) => ItemPositionProvider(
                        position: ItemPosition.get(index, visible.length),
                        child: DecorationListItem(
                          leading: const GlyphIcon(AppGlyphs.wifi),
                          title: Text(
                            visible[index],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onPressed: () => widget.onSelected(visible[index]),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
