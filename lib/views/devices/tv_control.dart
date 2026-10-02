import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/models/companion.dart';
import 'package:reclash/plugins/companion.dart';
import 'package:reclash/state.dart';
import 'package:reclash/widgets/widgets.dart';

import 'companion_ui.dart';

// TV receiver settings: turn the LAN listener on, open a time-boxed pairing window with its QR,
// confirm a pending phone locally, and revoke trusted phones. Approval is a local action only —
// the phone can never confirm itself remotely, and Back rejects a pending phone without stopping VPN.
class TvControlView extends ConsumerStatefulWidget {
  const TvControlView({super.key});

  @override
  ConsumerState<TvControlView> createState() => _TvControlViewState();
}

class _TvControlViewState extends ConsumerState<TvControlView>
    with WidgetsBindingObserver, ActivePollingMixin<TvControlView> {
  final _receiver = CompanionReceiver.instance;
  bool _running = false;
  bool _busy = false;
  List<CompanionTrustedPhone> _phones = const [];

  @override
  Duration get pollInterval => const Duration(seconds: 4);

  @override
  Future<void> poll(PollGuard isCurrent) async {
    final running = await _receiver.isRunning();
    final phones = running
        ? await _receiver.trustedClients()
        : const <CompanionTrustedPhone>[];
    if (!isCurrent()) return;
    setState(() {
      _running = running;
      _phones = phones;
    });
  }

  Future<void> _refresh() => Future.sync(restartPolling);

  Future<void> _toggle(bool enable) async {
    setState(() => _busy = true);
    try {
      if (enable) {
        await _receiver.enable();
      } else {
        await _receiver.disable();
      }
      await _refresh();
    } on PlatformException catch (error) {
      _showError(error.code);
    } catch (_) {
      _showError('unreachable');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _addPhone() async {
    final offer = await globalState.safeRun(_receiver.openPairingWindow);
    if (offer == null || !mounted) return;
    await dialogs.showCommonDialog<void>(
      context: context,
      dismissible: false,
      child: _PairingWindowDialog(receiver: _receiver, offer: offer),
    );
    await _receiver.cancelPairingWindow();
    await _refresh();
  }

  Future<void> _revoke(CompanionTrustedPhone phone) async {
    final l = context.appLocalizations;
    final confirmed = await dialogs.showMessage(
      message: TextSpan(text: phone.clientName),
      title: l.companionRevokePhone,
      dangerous: true,
    );
    if (confirmed != true) return;
    await _receiver.revokeClient(phone.clientId);
    await _refresh();
  }

  Future<void> _resetIdentity() async {
    final l = context.appLocalizations;
    final confirmed = await dialogs.showMessage(
      message: TextSpan(text: l.companionResetIdentityDesc),
      title: l.companionResetIdentity,
      dangerous: true,
    );
    if (confirmed == true) {
      await _receiver.resetIdentity();
      await _refresh();
    }
  }

  void _showError(String code) {
    if (!mounted) return;
    final l = context.appLocalizations;
    final message = switch (code) {
      'noLan' => l.companionNoLan,
      _ => l.companionUnreachable,
    };
    context.showNotifier(message);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final children = <Widget>[
      _ReceiverHeroCard(
        running: _running,
        onChanged: _busy ? null : (value) => unawaited(_toggle(value)),
      ),
      if (_running)
        _ActionCard(
          icon: AppGlyphs.qrCode,
          title: l.companionAddPhone,
          subtitle: l.companionScanTvQr,
          onTap: () => unawaited(_addPhone()),
        ),
      if (_running) _GroupLabel(label: l.companionTrustedPhones),
      if (_running && _phones.isEmpty)
        const _EmptyPhonesCard()
      else if (_running)
        for (final phone in _phones)
          _TrustedPhoneCard(
            phone: phone,
            onRevoke: () => unawaited(_revoke(phone)),
          ),
      if (_running)
        _ActionCard(
          icon: AppGlyphs.reset,
          title: l.companionResetIdentity,
          subtitle: l.companionResetIdentityDesc,
          tone: context.colorScheme.error,
          onTap: () => unawaited(_resetIdentity()),
        ),
    ];
    final list = ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      itemCount: children.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (_, index) => children[index],
    );
    return CommonScaffold(
      title: l.companionAddPhone,
      body: CompanionPage(child: list),
    );
  }
}

class _ReceiverHeroCard extends StatelessWidget {
  const _ReceiverHeroCard({required this.running, required this.onChanged});

  final bool running;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final tone = running ? colorScheme.primary : colorScheme.onSurfaceVariant;
    return CommonCard(
      type: CommonCardType.filled,
      radius: AppCorner.xl,
      accent: running ? colorScheme.primary : null,
      padding: const EdgeInsets.all(18),
      onPressed: onChanged == null ? null : () => onChanged!(!running),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppMedallion(icon: AppGlyphs.tethering, tone: tone, size: 52),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Text(
                  l.companionEnableReceiver,
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: running
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              ExcludeFocus(
                child: IgnorePointer(
                  child: Switch(value: running, onChanged: (_) {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            running
                ? l.companionLanHelp
                : (system.isTV
                      ? l.companionReceiverExplain
                      : l.companionReceiverExplainPhone),
            style: context.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs, top: AppSpacing.xs),
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

class _EmptyPhonesCard extends StatelessWidget {
  const _EmptyPhonesCard();

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final colorScheme = context.colorScheme;
    return CommonCard(
      type: CommonCardType.filled,
      radius: AppCorner.xl,
      padding: AppInsets.lg,
      child: Row(
        children: [
          GlyphIcon(AppGlyphs.devices, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              l.companionLanHelp,
              style: context.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustedPhoneCard extends StatelessWidget {
  const _TrustedPhoneCard({required this.phone, required this.onRevoke});

  final CompanionTrustedPhone phone;
  final VoidCallback onRevoke;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final colorScheme = context.colorScheme;
    return CommonCard(
      type: CommonCardType.filled,
      radius: AppCorner.xl,
      padding: AppInsets.lg,
      child: Row(
        children: [
          AppMedallion(icon: AppGlyphs.devices, tone: colorScheme.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  phone.clientName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  DateTime.fromMillisecondsSinceEpoch(
                    phone.lastSeenAtMs,
                  ).getLastUpdateTimeDesc(context),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          TextButton(onPressed: onRevoke, child: Text(l.companionRevokePhone)),
        ],
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
    this.tone,
  });

  final Glyph icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? tone;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final accent = tone ?? colorScheme.primary;
    return CommonCard(
      type: CommonCardType.filled,
      radius: AppCorner.xl,
      padding: AppInsets.lg,
      onPressed: onTap,
      child: Row(
        children: [
          AppMedallion(icon: icon, tone: accent),
          const SizedBox(width: AppSpacing.md),
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
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  subtitle,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          GlyphIcon(
            AppGlyphs.chevronForward,
            color: colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

class _PairingWindowDialog extends StatefulWidget {
  const _PairingWindowDialog({required this.receiver, required this.offer});

  final CompanionReceiver receiver;
  final CompanionQrOffer offer;

  @override
  State<_PairingWindowDialog> createState() => _PairingWindowDialogState();
}

class _PairingWindowDialogState extends State<_PairingWindowDialog> {
  Timer? _pollTimer;
  Timer? _countdownTimer;
  CompanionPendingPhone? _pending;
  bool _resolving = false;
  late int _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = (widget.offer.expiresInMs / 1000).ceil();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => unawaited(_poll()),
    );
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _remaining = _remaining > 0 ? _remaining - 1 : 0);
      if (_remaining == 0 && _pending == null) Navigator.of(context).pop();
    });
  }

  Future<void> _poll() async {
    final pending = await widget.receiver.pendingPairing();
    if (!mounted) return;
    if (pending != null && _pending?.clientId != pending.clientId) {
      setState(() => _pending = pending);
    }
  }

  Future<void> _reject() async {
    if (_resolving) return;
    _resolving = true;
    await widget.receiver.rejectPending();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _approve() async {
    if (_resolving) return;
    setState(() => _resolving = true);
    final approved = await widget.receiver.approvePending();
    if (!mounted) return;
    // A lost approval must not close as success: reopen the gate so the local user can retry.
    if (!approved) {
      setState(() => _resolving = false);
      context.showNotifier(context.appLocalizations.companionCommandFailed);
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final pending = _pending;
    return CommonDialog(
      title: pending == null ? l.companionScanTvQr : l.companionConfirmPhone,
      actions: [
        TextButton(
          autofocus: true,
          onPressed: pending == null
              ? () => Navigator.of(context).pop()
              : () => unawaited(_reject()),
          child: Text(pending == null ? l.cancel : l.companionReject),
        ),
        if (pending != null)
          FilledButton(
            onPressed: () => unawaited(_approve()),
            child: Text(l.confirm),
          ),
      ],
      child: pending == null
          ? _QrBody(qr: widget.offer.qr, remaining: _remaining)
          : _PendingBody(pending: pending),
    );
  }
}

class _QrBody extends StatelessWidget {
  const _QrBody({required this.qr, required this.remaining});

  final String qr;
  final int remaining;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final low = remaining <= 10;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l.companionScanWithPhone,
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 18),
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: AppRadius.lg,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.18),
                blurRadius: 24,
                spreadRadius: 1,
              ),
            ],
          ),
          child: StyledQrCode(
            data: qr,
            size: 220,
            logo: SvgPicture.asset(
              'assets/images/marks/reclash-mark-color.svg',
            ),
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: ShapeDecoration(
            shape: AppShape.all(AppCorner.full),
            color: (low ? colorScheme.error : colorScheme.primary).withValues(
              alpha: 0.12,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GlyphIcon(
                AppGlyphs.hourglass,
                size: 16,
                color: low ? colorScheme.error : colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                l.companionPairingExpires(remaining),
                style: context.textTheme.bodyMedium?.copyWith(
                  color: low ? colorScheme.error : colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontFamily: FontFamily.jetBrainsMono.value,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GlyphIcon(
              AppGlyphs.wifi,
              size: 15,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                l.companionLanHelp,
                textAlign: TextAlign.center,
                style: context.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PendingBody extends StatelessWidget {
  const _PendingBody({required this.pending});

  final CompanionPendingPhone pending;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final colorScheme = context.colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppMedallion(
          icon: AppGlyphs.devices,
          tone: colorScheme.primary,
          size: 56,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          pending.clientName,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: ShapeDecoration(
            shape: AppShape.md,
            color: colorScheme.primary.withValues(alpha: 0.12),
          ),
          child: Text(
            pending.confirmationCode,
            style: context.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.primary,
              fontFamily: FontFamily.jetBrainsMono.value,
              letterSpacing: 4,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(l.companionConfirmOnTv, textAlign: TextAlign.center),
      ],
    );
  }
}
