import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/models/common.dart' show TrafficShowExt;
import 'package:reclash/common/app_update_state.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/common/update.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';

import 'update_content.dart';
import 'update_preferences.dart';

const _contentMaxWidth = 520.0;
const _orbSide = 112.0;
const _orbCompactSide = 88.0;
const _orbCompactBelow = 400.0;
const _scrollBottomPadding = 24.0;
const _fadeHeight = 24.0;
const _orbCentre = 0.3;
const _orbCompactCentre = 0.24;
const _primaryHeight = 52.0;
const _secondaryHeight = 48.0;

class UpdateSheet extends ConsumerStatefulWidget {
  const UpdateSheet({super.key, this.platform});

  final SupportPlatform? platform;

  static final _offer = _SingleSheet();
  static final _preferences = _SingleSheet();

  /// Opens the sheet unless it is already showing, so a repeated tap, the
  /// dashboard card and a check from another page all land on the one sheet.
  static Future<void> show(BuildContext context, {bool preferences = false}) {
    if (preferences) {
      return _preferences.open(
        () => showFormSheet<void>(
          context: context,
          builder: (context) => _preferences.track(
            UpdatePreferences(
              isAndroid: ProviderScope.containerOf(
                context,
                listen: false,
              ).read(appUpdateActionProvider.notifier).isSupported,
            ),
          ),
        ),
      );
    }
    return _offer.open(
      () => showSheet<void>(
        context: context,
        props: nestedPagedSheetProps,
        builder: (_) =>
            _offer.track(NestedPagedSheet(builder: (_) => const UpdateSheet())),
      ),
    );
  }

  @override
  ConsumerState<UpdateSheet> createState() => _UpdateSheetState();
}

/// Tracks a sheet by its mounted content rather than by the route's future,
/// which never completes when a layout change drops the navigator under it.
class _SingleSheet {
  bool _opening = false;
  int _mounted = 0;

  Future<void> open(Future<void> Function() present) {
    if (_opening || _mounted > 0) return Future.value();
    _opening = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _opening = false);
    return present();
  }

  Widget track(Widget child) => _Tracked(sheet: this, child: child);
}

class _Tracked extends StatefulWidget {
  const _Tracked({required this.sheet, required this.child});

  final _SingleSheet sheet;
  final Widget child;

  @override
  State<_Tracked> createState() => _TrackedState();
}

class _TrackedState extends State<_Tracked> {
  @override
  void initState() {
    super.initState();
    widget.sheet._mounted++;
  }

  @override
  void dispose() {
    widget.sheet._mounted--;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _UpdateSheetState extends ConsumerState<UpdateSheet> {
  ScrollController? _scrollController;
  final _underFooter = ValueNotifier(false);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollController ??= sheetScrollController(context);
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    _underFooter.dispose();
    super.dispose();
  }

  bool _track(ScrollMetrics metrics) {
    _underFooter.value = metrics.extentAfter > _scrollBottomPadding;
    return false;
  }

  void _close() => context.safeNestedPop();

  @override
  Widget build(BuildContext context) {
    final update = ref.watch(appUpdateActionProvider);
    final action = ref.read(appUpdateActionProvider.notifier);
    final l = context.appLocalizations;
    final platform = widget.platform ?? SupportPlatform.currentPlatform;
    final release = update.release;
    final offer = update.phase == UpdatePhase.offered && release != null;
    return CommonScaffold(
      title: l.updateTitle,
      iconActions: [
        IconButtonData(
          glyph: AppGlyphs.settings,
          tooltip: l.updatePreferencesTitle,
          onPressed: () => unawaited(
            showInSheet<void>(
              context,
              builder: (context) =>
                  UpdatePreferences(isAndroid: action.isSupported),
            ),
          ),
        ),
      ],
      body: Builder(
        builder: (context) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: NotificationListener<ScrollMetricsNotification>(
                onNotification: (n) => _track(n.metrics),
                child: NotificationListener<ScrollNotification>(
                  onNotification: (n) => _track(n.metrics),
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _underFooter,
                    builder: (context, under, child) => ShaderMask(
                      blendMode: BlendMode.dstIn,
                      shaderCallback: (bounds) => LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white,
                          under ? Colors.transparent : Colors.white,
                        ],
                        stops: [
                          (1 - _fadeHeight / bounds.height).clamp(0.0, 1.0),
                          1,
                        ],
                      ).createShader(bounds),
                      child: child,
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final compact =
                            constraints.maxHeight < _orbCompactBelow;
                        final side = compact ? _orbCompactSide : _orbSide;
                        final centre = compact ? _orbCompactCentre : _orbCentre;
                        return SingleChildScrollView(
                          key: const ValueKey('update-offer-scroll'),
                          controller: _scrollController,
                          padding: EdgeInsets.fromLTRB(
                            16,
                            math.max(
                              context.contentTopPadding,
                              constraints.maxHeight * centre - side / 2,
                            ),
                            16,
                            24,
                          ),
                          child: _Limit(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 240),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              layoutBuilder: (current, previous) => Stack(
                                alignment: Alignment.topCenter,
                                children: [...previous, ?current],
                              ),
                              child: offer
                                  ? _UpdateOffer(
                                      key: const ValueKey('update-offer'),
                                      update: update,
                                      release: release,
                                      orbSide: side,
                                      platform: platform,
                                      note:
                                          action.isSupported &&
                                              update.asset?.sha256 == null
                                          ? l.updateDirectUnavailable
                                          : null,
                                    )
                                  : _UpdateStatus(
                                      key: const ValueKey('update-status'),
                                      update: update,
                                      currentVersion:
                                          globalState.packageInfo.version,
                                      orbSide: side,
                                    ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            _UpdateFooter(
              update: update,
              supported: action.isSupported,
              onClose: _close,
            ),
          ],
        ),
      ),
    );
  }
}

class _Limit extends StatelessWidget {
  const _Limit({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
      child: child,
    ),
  );
}

class _UpdateOffer extends StatelessWidget {
  const _UpdateOffer({
    super.key,
    required this.update,
    required this.release,
    required this.platform,
    required this.orbSide,
    this.note,
  });

  final AppUpdateState update;
  final AppUpdateRelease release;
  final SupportPlatform platform;
  final double orbSide;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final currentVersion = globalState.packageInfo.version;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: UpdateOrb(
            update: update,
            glyph: AppGlyphs.cloudDownload,
            color: context.colorScheme.primary,
            side: orbSide,
          ),
        ),
        const SizedBox(height: 16),
        UpdateOfferHead(
          release: release,
          currentVersion: currentVersion,
          platform: platform,
        ),
        const SizedBox(height: 24),
        UpdateReleaseContent(
          release: release,
          currentVersion: currentVersion,
          platform: platform,
          asset: update.asset,
          verified: update.verified,
          note: note,
          header: false,
        ),
      ],
    );
  }
}

enum _Tone { accent, success, warning, error }

class _UpdateStatus extends StatelessWidget {
  const _UpdateStatus({
    super.key,
    required this.update,
    required this.currentVersion,
    required this.orbSide,
  });

  final AppUpdateState update;
  final String currentVersion;
  final double orbSide;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final tag = update.release?.tag;
    final installed = l.updateInstalledVersion(currentVersion);
    final (title, detail, glyph, tone) = switch (update.phase) {
      UpdatePhase.downloading => (
        l.downloadingUpdate,
        tag,
        AppGlyphs.cloudDownload,
        _Tone.accent,
      ),
      UpdatePhase.paused => (
        l.updatePausedTitle,
        tag,
        AppGlyphs.cloudDownload,
        _Tone.accent,
      ),
      UpdatePhase.verifying => (
        l.updateVerifyingTitle,
        tag,
        AppGlyphs.verified,
        _Tone.accent,
      ),
      UpdatePhase.ready => (
        l.updateReadyTitle,
        tag,
        AppGlyphs.check,
        _Tone.success,
      ),
      UpdatePhase.vpnActive => (
        l.updateVpnTitle,
        l.updateVpnDescription,
        AppGlyphs.vpn,
        _Tone.warning,
      ),
      UpdatePhase.permission => (
        l.updatePermissionTitle,
        l.updatePermissionRequired,
        AppGlyphs.appsList,
        _Tone.accent,
      ),
      UpdatePhase.confirmation => (
        l.updateConfirmationTitle,
        l.updateConfirmationDescription,
        AppGlyphs.verified,
        _Tone.accent,
      ),
      UpdatePhase.installing => (
        l.updateInstallingTitle,
        l.updateInstallingDescription,
        AppGlyphs.sync,
        _Tone.accent,
      ),
      UpdatePhase.installed => (
        l.updateInstalledTitle,
        tag,
        AppGlyphs.check,
        _Tone.success,
      ),
      UpdatePhase.upToDate => (
        l.updateCurrentTitle,
        installed,
        AppGlyphs.check,
        _Tone.success,
      ),
      UpdatePhase.checkFailed => (
        l.updateCheckFailed,
        l.updateCheckFailedDescription,
        AppGlyphs.wifiOff,
        _Tone.error,
      ),
      UpdatePhase.downloadFailed => (
        l.updateDownloadFailed,
        l.updateDownloadFailedDescription,
        AppGlyphs.wifiOff,
        _Tone.error,
      ),
      UpdatePhase.verifyFailed => (
        l.updateVerifyFailedTitle,
        l.updateVerifyFailedDescription,
        AppGlyphs.warning,
        _Tone.error,
      ),
      UpdatePhase.installFailed => (
        l.updateInstallFailed,
        l.updateInstallFailedDescription,
        AppGlyphs.warning,
        _Tone.error,
      ),
      _ => (
        l.updateCheckingTitle,
        installed,
        AppGlyphs.cloudSync,
        _Tone.accent,
      ),
    };
    final transfer = const {
      UpdatePhase.downloading,
      UpdatePhase.paused,
      UpdatePhase.downloadFailed,
    }.contains(update.phase);
    final muted = context.colorScheme.onSurfaceVariant;
    return Semantics(
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 6,
          children: [
            Center(
              child: UpdateOrb(
                update: update,
                glyph: glyph,
                side: orbSide,
                color: switch (tone) {
                  _Tone.accent => context.colorScheme.primary,
                  _Tone.success => context.colorScheme.success,
                  _Tone.warning => context.colorScheme.warning,
                  _Tone.error => context.colorScheme.error,
                },
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyle.title2.of(context, emphasized: true),
            ),
            if (detail != null)
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: Text(
                    detail,
                    textAlign: TextAlign.center,
                    style: AppTextStyle.subheadline
                        .of(context)
                        .copyWith(color: muted),
                  ),
                ),
              ),
            if (transfer) _TransferLine(update: update),
            if (update.verified)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 6,
                  children: [
                    GlyphIcon(
                      AppGlyphs.verified,
                      size: 16,
                      color: context.colorScheme.success,
                    ),
                    Flexible(
                      child: Text(
                        l.updatePackageVerified,
                        style: AppTextStyle.footnote
                            .of(context)
                            .copyWith(color: muted),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A glyph well ringed by the update's progress: the download share while it
/// transfers, a full ring once the package is in hand, a spinner while busy.
class UpdateOrb extends StatelessWidget {
  const UpdateOrb({
    super.key,
    required this.update,
    required this.glyph,
    required this.color,
    this.side = 112,
  });

  final AppUpdateState update;
  final Glyph glyph;
  final Color color;
  final double side;

  @override
  Widget build(BuildContext context) {
    final phase = update.phase;
    final progress = update.progress;
    final transfer = const {
      UpdatePhase.downloading,
      UpdatePhase.paused,
      UpdatePhase.downloadFailed,
    }.contains(phase);
    final spinning =
        const {
          UpdatePhase.checking,
          UpdatePhase.verifying,
          UpdatePhase.installing,
        }.contains(phase) ||
        (phase == UpdatePhase.downloading && progress == null);
    final filled =
        update.verified ||
        const {
          UpdatePhase.ready,
          UpdatePhase.installed,
          UpdatePhase.upToDate,
        }.contains(phase);
    final value = transfer ? progress ?? 0.0 : (filled ? 1.0 : 0.0);
    // A small orb keeps its glyph instead of the percentage, and draws the
    // glyph larger so it still reads inside the narrower well.
    final large = side >= 80;
    final percent = transfer && progress != null && large;
    final well = side * 0.6;
    return SizedBox.square(
      dimension: side,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: well,
            height: well,
            decoration: ShapeDecoration(
              color: context.raisedSurfaceLevel.colorOf(context.colorScheme),
              shape: const CircleBorder(),
            ),
          ),
          if (spinning)
            CommonCircleLoading(size: side, color: color)
          else
            TweenAnimationBuilder<double>(
              tween: Tween(end: value),
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => CustomPaint(
                size: Size.square(side),
                painter: _RingPainter(value: value, color: color),
              ),
            ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween(begin: 0.7, end: 1.0).animate(animation),
                child: child,
              ),
            ),
            child: percent
                ? Text(
                    '${(progress * 100).floor()}%',
                    key: const ValueKey('update-orb-percent'),
                    style: AppTextStyle.headline
                        .of(context, emphasized: true)
                        .copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                  )
                : GlyphIcon(
                    glyph,
                    key: ValueKey((glyph, color)),
                    size: side * (large ? 0.32 : 0.4),
                    color: color,
                  ),
          ),
        ],
      ),
    );
  }
}

/// Matches the ring of [CommonCircleLoading] at the same size, so a spinner
/// giving way to a measured download keeps its place.
class _RingPainter extends CustomPainter {
  _RingPainter({required this.value, required this.color});

  final double value;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;
    final strokeWidth = side / 12;
    final radius = (side * 20 / 24 - strokeWidth) / 2;
    final center = size.center(Offset.zero);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, stroke..color = color.opacity12);
    if (value <= 0) return;
    stroke.color = color;
    if (value >= 1) {
      canvas.drawCircle(center, radius, stroke);
      return;
    }
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      value * 2 * math.pi,
      false,
      stroke,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.value != value || oldDelegate.color != color;
}

class _TransferLine extends StatelessWidget {
  const _TransferLine({required this.update});
  final AppUpdateState update;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final remaining = update.remainingSeconds;
    final parts = [
      update.total > 0
          ? '${update.received.traffic.show} / ${update.total.traffic.show}'
          : update.received.traffic.show,
      if (update.phase == UpdatePhase.downloading &&
          update.bytesPerSecond > 0) ...[
        l.updateTransferSpeed(update.bytesPerSecond.round().traffic.show),
        if (remaining != null)
          l.updateRemainingTime(
            remaining < 60
                ? l.updateSeconds(remaining)
                : l.updateMinutes((remaining / 60).ceil()),
          ),
      ],
    ];
    return Text(
      parts.join('  ·  '),
      textAlign: TextAlign.center,
      style: AppTextStyle.footnote
          .of(context)
          .copyWith(
            color: context.colorScheme.onSurfaceVariant,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
    );
  }
}

class _UpdateFooter extends ConsumerWidget {
  const _UpdateFooter({
    required this.update,
    required this.supported,
    required this.onClose,
  });
  final AppUpdateState update;
  final bool supported;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    final action = ref.read(appUpdateActionProvider.notifier);
    final direct = supported && update.asset?.sha256 != null;
    final size = update.asset?.size;
    final (primary, secondary) = switch (update.phase) {
      UpdatePhase.offered => (
        !direct
            ? l.goDownload
            : size != null
            ? '${l.updateDownloadAction}  ·  ${size.traffic.show}'
            : l.updateDownloadAction,
        l.updateNotNow,
      ),
      UpdatePhase.downloading => (
        l.updateContinueBackground,
        l.updatePauseAction,
      ),
      UpdatePhase.paused => (l.updateResumeAction, l.updateCancelDownload),
      UpdatePhase.checking => ('', ''),
      UpdatePhase.verifying => (l.updateContinueBackground, ''),
      UpdatePhase.ready => (l.updateInstallNow, l.updateNotNow),
      UpdatePhase.vpnActive => (l.updateDisconnectInstall, l.updateNotNow),
      UpdatePhase.permission => (l.updateOpenAndroidSettings, l.updateNotNow),
      UpdatePhase.confirmation => (l.updateContinueInstall, l.updateNotNow),
      UpdatePhase.installing => (l.updateCloseWindow, ''),
      UpdatePhase.downloadFailed => (l.updateResumeAction, l.updateNotNow),
      UpdatePhase.verifyFailed => (l.updateDownloadAgain, l.updateNotNow),
      UpdatePhase.installFailed => (l.updateRetryInstall, l.updateNotNow),
      UpdatePhase.checkFailed => (l.updateRetryCheck, l.updateNotNow),
      _ => (l.updateGotIt, ''),
    };
    final external = update.phase == UpdatePhase.offered && !direct;
    void accept() {
      switch (update.phase) {
        case UpdatePhase.offered:
          if (!direct) {
            final release = update.release;
            if (release != null) {
              unawaited(
                dialogs.openUrl(
                  release.source.releasePage(release.tag).toString(),
                ),
              );
            }
            onClose();
          } else {
            unawaited(action.download());
          }
        case UpdatePhase.paused:
        case UpdatePhase.downloadFailed:
          unawaited(action.download());
        case UpdatePhase.verifyFailed:
          unawaited(action.download(restart: true));
        case UpdatePhase.ready:
        case UpdatePhase.installFailed:
          unawaited(action.installNow());
        case UpdatePhase.vpnActive:
          unawaited(action.installNow(disconnectVpn: true));
        case UpdatePhase.permission:
          unawaited(action.openPermission());
        case UpdatePhase.confirmation:
          unawaited(action.confirmInstall());
        case UpdatePhase.checkFailed:
          unawaited(action.check());
        default:
          onClose();
      }
    }

    void dismiss() {
      if (update.phase == UpdatePhase.downloading) {
        action.pause();
      } else if (update.phase == UpdatePhase.paused) {
        unawaited(action.cancelDownload());
      } else {
        onClose();
      }
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 12 + context.bottomInset),
      child: _Limit(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: _primaryHeight,
              child: primary.isEmpty
                  ? null
                  : external
                  ? FilledButton.icon(
                      key: const ValueKey('update-offer-accept'),
                      onPressed: accept,
                      iconAlignment: IconAlignment.end,
                      icon: const GlyphIcon(
                        AppGlyphs.openExternal,
                        size: 18,
                        fill: 1,
                      ),
                      label: Text(primary, textAlign: TextAlign.center),
                    )
                  : FilledButton(
                      key: const ValueKey('update-offer-accept'),
                      onPressed: accept,
                      child: Text(primary, textAlign: TextAlign.center),
                    ),
            ),
            SizedBox(
              height: _secondaryHeight,
              child: Center(
                child: secondary.isEmpty
                    ? null
                    : TextButton(
                        key: const ValueKey('update-offer-dismiss'),
                        onPressed: dismiss,
                        child: Text(secondary, textAlign: TextAlign.center),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
