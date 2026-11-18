import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/core/desktop/site_lock_policy.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/views/chains/issues.dart';
import 'package:reclash/views/site_lock_editor.dart';
import 'package:reclash/widgets/settings/setting_target.dart';
import 'package:reclash/widgets/widgets.dart';

const _maxLocks = 32;
const _refreshInterval = Duration(seconds: 10);

class SiteLockView extends ConsumerStatefulWidget {
  const SiteLockView({super.key, this.hostFirewall});

  /// Whether the host firewall status applies; the current platform when null.
  final bool? hostFirewall;

  @override
  ConsumerState<SiteLockView> createState() => _SiteLockViewState();
}

class _SiteLockViewState extends ConsumerState<SiteLockView> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _refresh();
    _timer = Timer.periodic(_refreshInterval, (_) => _refresh());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _refresh() =>
      unawaited(ref.read(siteLockReportStateProvider.notifier).refresh());

  String _label(SiteLock lock) =>
      lock.name.isNotEmpty ? lock.name : lock.match.firstOrNull ?? lock.id;

  String _names(List<SiteLock> locks, List<String> ids) => [
    for (final lock in locks)
      if (ids.contains(lock.id)) _label(lock),
  ].join(', ');

  void _write(List<SiteLock> locks) =>
      ref.read(siteLocksProvider.notifier).value = locks;

  Future<void> _edit(SiteLock lock, {bool isNew = false}) async {
    final edited = await showSiteLockEditor(context, lock, isNew: isNew);
    if (edited == null || !mounted) return;
    final locks = ref.read(siteLocksProvider);
    _write(
      locks.any((item) => item.id == edited.id)
          ? [for (final item in locks) item.id == edited.id ? edited : item]
          : [...locks, edited],
    );
  }

  Future<void> _add() =>
      _edit(SiteLock(id: snowflake.id.toString(), enabled: true), isNew: true);

  void _toggle(SiteLock lock, bool enabled) => _write([
    for (final item in ref.read(siteLocksProvider))
      item.id == lock.id ? item.copyWith(enabled: enabled) : item,
  ]);

  Future<void> _delete(SiteLock lock) async {
    final l = context.appLocalizations;
    final confirmed = await dialogs.showMessage(
      message: TextSpan(text: l.siteLockDeleteConfirm(_label(lock))),
      destructive: true,
      confirmText: l.delete,
    );
    if (confirmed != true || !mounted) return;
    _write([
      for (final item in ref.read(siteLocksProvider))
        if (item.id != lock.id) item,
    ]);
  }

  ({String text, Color? color}) _stateOf(
    AppLocalizations l,
    SiteLock lock,
    SiteLockReport? report,
  ) {
    final colorScheme = context.colorScheme;
    final problem = report?.problems
        .where((item) => item.id == lock.id)
        .firstOrNull;
    if (problem != null && problem.message.isNotEmpty) {
      return (text: problem.message, color: colorScheme.error);
    }
    if (!lock.enabled) return (text: l.siteLockOff, color: null);
    final state = report?.locks.where((item) => item.id == lock.id).firstOrNull;
    final exit = state?.exit;
    return switch (state?.status) {
      SiteLockStatus.ready => (
        text: exit == null ? l.siteLockReady : l.siteLockThrough(exit),
        color: null,
      ),
      SiteLockStatus.disabled => (text: l.siteLockOff, color: null),
      SiteLockStatus.noExit => (
        text: l.siteLockNoExit,
        color: colorScheme.error,
      ),
      SiteLockStatus.exitsDown => (
        text: l.siteLockExitsDown,
        color: colorScheme.warning,
      ),
      _ => (text: l.siteLockWaiting, color: null),
    };
  }

  Widget _row(AppLocalizations l, SiteLock lock, SiteLockReport? report) {
    final state = _stateOf(l, lock, report);
    return ContextMenuRegion(
      menuItems: [
        CommonPopupMenuItem(
          danger: true,
          glyph: AppGlyphs.delete,
          label: l.delete,
          onPressed: () => unawaited(_delete(lock)),
        ),
      ],
      child: ListItem(
        title: Text(_label(lock), maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(state.text, style: TextStyle(color: state.color)),
        trailing: CommonSwitch(
          value: lock.enabled,
          onChanged: (value) => _toggle(lock, value),
        ),
        onTap: () => unawaited(_edit(lock)),
      ),
    );
  }

  List<Widget> _banners(
    AppLocalizations l,
    List<SiteLock> locks,
    SiteLockReport? report,
  ) {
    final host = widget.hostFirewall ?? system.isLinux;
    final anyEnabled = locks.any((lock) => lock.enabled);
    final tunEnabled = ref.watch(
      patchClashConfigProvider.select((state) => state.tun.enable),
    );
    final hostStatus = ref.watch(siteLockHostStateProvider);
    Widget card(IssueTone tone, String title, String body) =>
        IssueCard(tone: tone, title: title, body: body);
    return [
      if (report != null && !report.applied)
        card(
          IssueTone.error,
          l.siteLockRejectedTitle,
          [
            l.siteLockRejectedBody,
            for (final problem in report.problems)
              if (problem.message.isNotEmpty) problem.message,
          ].join('\n'),
        ),
      if (host && anyEnabled) ...[
        if (hostStatus == SiteLockHostStatus.helperUnavailable)
          card(IssueTone.warning, l.siteLockHelperTitle, l.siteLockHelperBody),
        if (hostStatus == SiteLockHostStatus.failed)
          card(
            IssueTone.error,
            l.siteLockFirewallTitle,
            l.siteLockFirewallBody,
          ),
        if (!tunEnabled)
          card(IssueTone.warning, l.siteLockTunOffTitle, l.siteLockTunOffBody),
      ],
      for (final warning in report?.warnings ?? const <SiteLockWarning>[])
        if (_names(locks, warning.locks) case final names when names.isNotEmpty)
          switch (warning.code) {
            'sniffer-off' => card(
              IssueTone.warning,
              l.siteLockSnifferTitle,
              l.siteLockSnifferBody(names),
            ),
            'core-only' => card(
              IssueTone.warning,
              l.siteLockCoreOnlyTitle,
              l.siteLockCoreOnlyBody(names),
            ),
            _ => const SizedBox.shrink(),
          },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final locks = ref.watch(siteLocksProvider);
    final report = ref.watch(siteLockReportStateProvider);
    final gap = listHeaderPaddingOf(context).top;
    return CommonScaffold(
      title: l.siteLockTitle,
      primaryAction: IconButtonData(
        glyph: AppGlyphs.add,
        tooltip: l.siteLockNew,
        onPressed: locks.length >= _maxLocks ? null : () => unawaited(_add()),
      ),
      body: NullStatusSwitcher(
        isEmpty: locks.isEmpty,
        nullStatus: NullStatus(
          label: l.siteLockEmpty,
          description: l.siteLockEmptyHint,
          illustration: NullStatusIllustration.rules,
          action: TonalButton(
            size: TonalButtonSize.bar,
            glyph: AppGlyphs.addCircle,
            label: l.add,
            onPressed: () => unawaited(_add()),
          ),
        ),
        child: SettingsPageScroll(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ).copyWith(top: context.sectionsTopPadding, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final banner in _banners(l, locks, report))
                  Padding(
                    padding: EdgeInsets.only(top: gap),
                    child: banner,
                  ),
                generateSection(
                  items: [for (final lock in locks) _row(l, lock, report)],
                  footer: l.siteLockFooter,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
