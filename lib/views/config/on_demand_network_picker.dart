import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/plugins/app.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:wifi_ssid/wifi_ssid.dart';

typedef SsidListReader = Future<List<String>> Function();

Future<void> requestLocationPermission(
  BuildContext context,
  WidgetRef ref, {
  bool? isAndroid,
  bool? isMacOS,
}) async {
  final l = context.appLocalizations;
  final android = isAndroid ?? system.isAndroid;
  final macOS = isMacOS ?? system.isMacOS;
  void handlePermanentlyDenied() {
    if (macOS) {
      dialogs.showMessage(
        title: l.locationPermissionRequired,
        cancelable: false,
        message: TextSpan(
          style: AppTextStyle.subheadline.of(context),
          text: l.locationPermissionGuide(appName),
        ),
      );
    } else if (android) {
      app?.openAppSettings();
    }
  }

  final permission = ref.read(locationPermissionsProvider);
  if (permission == WifiSsidPermission.granted) {
    return;
  }
  if (permission == WifiSsidPermission.permanentlyDenied) {
    handlePermanentlyDenied();
    return;
  }
  final WifiSsidPermission? res;
  try {
    res = await ref.read(locationPermissionsProvider.notifier).request();
  } on PlatformException catch (e) {
    commonPrint.log('requestPermission error $e', logLevel: LogLevel.warning);
    return;
  }
  if (res == null || !context.mounted) {
    return;
  }
  switch (res) {
    case WifiSsidPermission.granted:
      return;
    case WifiSsidPermission.permanentlyDenied:
      handlePermanentlyDenied();
      return;
    case WifiSsidPermission.denied:
      break;
  }
  final needGo = await dialogs.showMessage(
    title: l.locationPermissionRequired,
    message: TextSpan(text: l.locationPermissionDeniedMessage),
    confirmText: l.go,
  );
  if (needGo != true) {
    return;
  }
  unawaited(app?.openAppSettings());
}

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

class OnDemandNetworkPicker extends ConsumerStatefulWidget {
  const OnDemandNetworkPicker({
    super.key,
    required this.selected,
    required this.onSelected,
    this.onEnterManually,
    this.listSsid,
    this.requiresLocation,
  });

  final Set<String> selected;
  final ValueChanged<String> onSelected;
  final VoidCallback? onEnterManually;
  final SsidListReader? listSsid;
  final bool? requiresLocation;

  @override
  ConsumerState<OnDemandNetworkPicker> createState() =>
      _OnDemandNetworkPickerState();
}

class _OnDemandNetworkPickerState extends ConsumerState<OnDemandNetworkPicker> {
  bool _loading = true;
  bool _failed = false;
  List<String> _ssids = const [];
  bool _scanning = false;

  bool get _requiresLocation =>
      widget.requiresLocation ?? (system.isAndroid || system.isMacOS);

  bool get _permissionMissing =>
      _requiresLocation &&
      ref.read(locationPermissionsProvider) != WifiSsidPermission.granted;

  @override
  void initState() {
    super.initState();
    ref.listenManual(locationPermissionsProvider, (previous, next) {
      if (next == WifiSsidPermission.granted &&
          previous != WifiSsidPermission.granted) {
        unawaited(_scan());
      }
    });
    if (!_permissionMissing) unawaited(_scan());
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

  Widget _buildRefreshButton() => TonalButton(
    size: TonalButtonSize.bar,
    glyph: AppGlyphs.refresh,
    label: context.appLocalizations.pickNetworkRefresh,
    onPressed: _scan,
  );

  Widget _buildContent(List<String> visible) {
    final l = context.appLocalizations;
    final permissionMissing =
        _requiresLocation &&
        ref.watch(locationPermissionsProvider) != WifiSsidPermission.granted;
    if (permissionMissing) {
      return NullStatus(
        label: l.locationPermissionRequired,
        description: l.pickNetworkPermissionDesc,
        illustration: NullStatusIllustration.permission,
        action: TonalButton(
          size: TonalButtonSize.bar,
          glyph: AppGlyphs.lockOpen,
          label: l.authorize,
          onPressed: () => requestLocationPermission(context, ref),
        ),
      );
    }
    if (_loading) {
      return Center(
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
      );
    }
    if (_failed) {
      return NullStatus(
        label: l.onDemandScanFailed,
        illustration: NullStatusIllustration.wifi,
        action: _buildRefreshButton(),
      );
    }
    if (visible.isEmpty) {
      return NullStatus(
        label: l.pickNetworkEmpty,
        illustration: NullStatusIllustration.wifi,
        action: _buildRefreshButton(),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.zero,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final onEnterManually = widget.onEnterManually;
    final visible = _ssids
        .where((ssid) => !widget.selected.contains(ssid))
        .toList();
    return CommonScaffold(
      title: l.pickNetwork,
      body: Padding(
        padding: EdgeInsets.fromLTRB(16, context.appBarInset, 16, 16),
        child: Column(
          children: [
            if (onEnterManually != null) ...[
              generateSection(
                items: [
                  DecorationListItem(
                    leading: const GlyphIcon(AppGlyphs.keyboard),
                    title: Text(l.enterManually),
                    subtitle: Text(l.networkEntryHint),
                    onPressed: onEnterManually,
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            Expanded(child: _buildContent(visible)),
          ],
        ),
      ),
    );
  }
}
