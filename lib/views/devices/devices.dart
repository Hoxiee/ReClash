import 'dart:async';

import 'package:reclash/common/common.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/companion.dart';
import 'package:reclash/views/tools/scan.dart';
import 'package:reclash/plugins/companion.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'companion_ui.dart';
import 'control_panel.dart';
import 'pairing.dart';
import 'tv_control.dart';

// Entry from Tools → Devices. On a phone: the trusted-TV list and a scanner to add one. On a TV:
// the receiver card comes first. Both roles ship in one app; system.isTV only orders the surface.
class DevicesView extends ConsumerStatefulWidget {
  const DevicesView({super.key});

  @override
  ConsumerState<DevicesView> createState() => _DevicesViewState();
}

class _DevicesViewState extends ConsumerState<DevicesView>
    with WidgetsBindingObserver, ActivePollingMixin<DevicesView> {
  final _client = CompanionClient.instance;
  List<CompanionTargetSummary> _targets = const [];
  final Map<String, CompanionReachability> _health = {};

  @override
  Duration get pollInterval => const Duration(seconds: 6);

  @override
  Future<void> poll(PollGuard isCurrent) async {
    final targets = await _client.targets();
    if (!isCurrent()) return;
    final active = targets.where((t) => t.active).toList();
    final results = await Future.wait(
      active.map((t) => _client.readStateResult(t.deviceId)),
    );
    if (!isCurrent()) return;
    for (var index = 0; index < active.length; index++) {
      _health[active[index].deviceId] = results[index].reachability;
    }
    final live = targets.map((t) => t.deviceId).toSet();
    _health.removeWhere((deviceId, _) => !live.contains(deviceId));
    setState(() => _targets = targets);
  }

  Future<void> _addTelevision() async {
    final raw = await BaseNavigator.push<String>(
      context,
      const ScanPage(mode: ScanMode.companionPairing),
    );
    if (raw == null || !mounted) return;
    await BaseNavigator.push<bool>(context, CompanionPairingView(raw: raw));
    restartPolling();
  }

  Future<void> _openReceiver() async {
    await BaseNavigator.push<void>(context, const TvControlView());
    restartPolling();
  }

  Future<void> _openPanel(CompanionTargetSummary target) async {
    await BaseNavigator.push<void>(
      context,
      CompanionControlPanel(deviceId: target.deviceId, title: target.clientName),
    );
    restartPolling();
  }

  Future<void> _rename(CompanionTargetSummary target) async {
    final l = context.appLocalizations;
    final name = await dialogs.showCommonDialog<String>(
      child: InputDialog(
        title: l.companionRename,
        value: target.clientName,
        labelText: l.companionDeviceName,
      ),
    );
    if (name == null || name.trim().isEmpty) return;
    await _client.rename(target.deviceId, name.trim());
    restartPolling();
  }

  Future<void> _forget(CompanionTargetSummary target) async {
    final l = context.appLocalizations;
    final confirmed = await dialogs.showMessage(
      message: TextSpan(text: target.clientName),
      title: l.companionForgetDevice,
      dangerous: true,
    );
    if (confirmed == true) {
      await _client.forget(target.deviceId);
      restartPolling();
    }
  }

  Future<void> _showActions(CompanionTargetSummary target) async {
    final l = context.appLocalizations;
    final action = await dialogs.showCommonDialog<String>(
      child: CommonDialog(
        title: target.clientName,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListItem(
              leading: const Icon(Icons.drive_file_rename_outline_rounded),
              title: Text(l.companionRename),
              onTap: () => Navigator.of(context).pop('rename'),
            ),
            ListItem(
              leading: const Icon(Icons.refresh_rounded),
              title: Text(l.companionReconnect),
              onTap: () => Navigator.of(context).pop('reconnect'),
            ),
            ListItem(
              leading: const Icon(Icons.delete_outline_rounded),
              title: Text(l.companionForgetDevice),
              onTap: () => Navigator.of(context).pop('forget'),
            ),
          ],
        ),
      ),
    );
    switch (action) {
      case 'rename':
        await _rename(target);
      case 'reconnect':
        restartPolling();
      case 'forget':
        await _forget(target);
    }
  }

  CompanionReachability _healthOf(CompanionTargetSummary target) =>
      target.active
      ? (_health[target.deviceId] ?? CompanionReachability.checking)
      : CompanionReachability.checking;

  String _statusLine(AppLocalizations l, CompanionTargetSummary target) {
    if (!target.active) return l.companionWaitingApproval;
    return switch (_healthOf(target)) {
      CompanionReachability.checking => l.companionStatusChecking,
      CompanionReachability.reachable => l.companionOnline,
      CompanionReachability.identityChanged => l.companionIdentityChanged,
      CompanionReachability.accessRevoked => l.companionAccessRevoked,
      CompanionReachability.incompatible ||
      CompanionReachability.unreachable => _offlineLine(l, target),
    };
  }

  String _offlineLine(AppLocalizations l, CompanionTargetSummary target) {
    final lastSeen = target.lastSeenAtMs;
    if (lastSeen == null) return l.companionNeverConnected;
    final when = DateTime.fromMillisecondsSinceEpoch(
      lastSeen,
    ).getLastUpdateTimeDesc(context);
    return l.companionLastSeen(when);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final receiver = _ActionCard(
      icon: Icons.cast_rounded,
      title: l.companionAddPhone,
      subtitle: l.companionEnableReceiver,
      onTap: () => unawaited(_openReceiver()),
    );
    final addTv = _ActionCard(
      icon: Icons.add_to_queue_rounded,
      title: l.companionAddTelevision,
      subtitle: l.companionScanTvQr,
      onTap: () => unawaited(_addTelevision()),
    );
    final children = <Widget>[
      if (system.isTV) ...[receiver, addTv] else ...[addTv, receiver],
      if (_targets.isNotEmpty) ...[
        _GroupLabel(label: l.devices),
        for (final target in _targets)
          _DeviceCard(
            target: target,
            reachability: _healthOf(target),
            statusLine: _statusLine(l, target),
            onOpen: target.active ? () => unawaited(_openPanel(target)) : null,
            onMenu: () => unawaited(_showActions(target)),
          ),
      ],
    ];
    final list = ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: children.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, index) => children[index],
    );
    return CommonScaffold(title: l.devices, body: CompanionPage(child: list));
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 4),
      child: Text(
        label,
        style: context.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: context.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return CompanionCard(
      onTap: onTap,
      child: Row(
        children: [
          CompanionIconBadge(icon: icon, tone: colorScheme.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right_rounded, color: colorScheme.onSurfaceVariant),
        ],
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({
    required this.target,
    required this.reachability,
    required this.statusLine,
    required this.onOpen,
    required this.onMenu,
  });

  final CompanionTargetSummary target;
  final CompanionReachability reachability;
  final String statusLine;
  final VoidCallback? onOpen;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final dotColor = target.active
        ? companionReachabilityColor(context, reachability)
        : colorScheme.tertiary;
    final info = Row(
      children: [
        CompanionIconBadge(icon: Icons.devices_other_rounded, tone: dotColor),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                target.clientName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  CompanionStatusDot(
                    color: dotColor,
                    pulsing: reachability == CompanionReachability.reachable,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      statusLine,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
    // Card and menu are siblings, never a focusable button nested in another: two clean D-pad
    // stops instead of one that swallows the other.
    return Row(
      children: [
        Expanded(child: CompanionCard(onTap: onOpen, child: info)),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.more_vert_rounded),
          tooltip: l.edit,
          onPressed: onMenu,
        ),
      ],
    );
  }
}
