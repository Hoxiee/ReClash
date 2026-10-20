import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/models/common.dart' show TrafficShowExt;
import 'package:reclash/common/app_update_state.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';

import 'update_content.dart';
import 'update_preferences.dart';

class UpdateSheet extends ConsumerStatefulWidget {
  const UpdateSheet({super.key, this.preferences = false, this.platform});

  final bool preferences;
  final SupportPlatform? platform;

  static Future<void> show(BuildContext context, {bool preferences = false}) =>
      showFormSheet<void>(
        context: context,
        props: const SheetProps(detents: [0.72, 0.94]),
        builder: (_) => UpdateSheet(preferences: preferences),
      );

  @override
  ConsumerState<UpdateSheet> createState() => _UpdateSheetState();
}

class _UpdateSheetState extends ConsumerState<UpdateSheet> {
  late bool _preferences = widget.preferences;
  ScrollController? _scrollController;
  final _preferencesKey = GlobalKey<UpdatePreferencesState>();
  bool _canSave = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollController ??= sheetScrollController(context);
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  void _close() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    final update = ref.watch(appUpdateActionProvider);
    final action = ref.read(appUpdateActionProvider.notifier);
    final l = context.appLocalizations;
    final platform = widget.platform ?? SupportPlatform.currentPlatform;
    final note = _preferences
        ? ''
        : _updateNote(context, update, action.isSupported);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SheetToolBar(
          appBar: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                if (_preferences && !widget.preferences)
                  IconButton(
                    tooltip: l.back,
                    onPressed: () => setState(() => _preferences = false),
                    icon: const GlyphIcon(AppGlyphs.arrowBack),
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(start: 8),
                    child: Text(
                      _preferences ? l.updatePreferencesTitle : l.updateTitle,
                      style: AppTextStyle.headline.of(context),
                    ),
                  ),
                ),
                if (!_preferences)
                  IconButton(
                    key: const ValueKey('update-preferences'),
                    tooltip: l.updatePreferencesTitle,
                    onPressed: () => setState(() {
                      _preferences = true;
                      _canSave = true;
                    }),
                    icon: const GlyphIcon(AppGlyphs.settings),
                  ),
                IconButton(
                  tooltip: l.close,
                  onPressed: _close,
                  icon: const GlyphIcon(AppGlyphs.close),
                ),
              ],
            ),
          ),
        ),
        Flexible(
          fit: FlexFit.loose,
          child: SingleChildScrollView(
            key: const ValueKey('update-offer-scroll'),
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 18,
              children: [
                _preferences
                    ? UpdatePreferences(
                        key: _preferencesKey,
                        isAndroid: action.isSupported,
                        onCanSaveChanged: (value) {
                          if (mounted) setState(() => _canSave = value);
                        },
                        onSaved: () {
                          if (widget.preferences) {
                            _close();
                          } else {
                            setState(() => _preferences = false);
                          }
                        },
                      )
                    : update.phase == UpdatePhase.offered &&
                          update.release != null
                    ? UpdateReleaseContent(
                        release: update.release!,
                        currentVersion: globalState.packageInfo.version,
                        platform: platform,
                        asset: update.asset,
                        verified: update.verified,
                      )
                    : _UpdateFlow(update: update),
                if (note.isNotEmpty)
                  Text(
                    note,
                    textAlign: TextAlign.center,
                    style: AppTextStyle.caption1
                        .of(context)
                        .copyWith(color: context.colorScheme.onSurfaceVariant),
                  ),
              ],
            ),
          ),
        ),
        if (_preferences)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
            child: FilledButton(
              key: const ValueKey('update-preferences-save'),
              onPressed: _canSave
                  ? () => unawaited(_preferencesKey.currentState?.save())
                  : null,
              child: Text(l.save),
            ),
          )
        else
          _UpdateFooter(
            update: update,
            supported: action.isSupported,
            onClose: _close,
          ),
      ],
    );
  }
}

class _UpdateFlow extends StatelessWidget {
  const _UpdateFlow({required this.update});
  final AppUpdateState update;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final (title, description, glyph) = switch (update.phase) {
      UpdatePhase.downloading => (
        l.downloadingUpdate,
        l.updateDownloadDescription,
        AppGlyphs.cloudDownload,
      ),
      UpdatePhase.paused => (
        l.updatePausedTitle,
        l.updatePausedDescription,
        AppGlyphs.cloudDownload,
      ),
      UpdatePhase.verifying => (
        l.updateVerifyingTitle,
        l.updateVerifyingDescription,
        AppGlyphs.verified,
      ),
      UpdatePhase.ready => (
        l.updateReadyTitle,
        l.updateReadyDescription,
        AppGlyphs.checkCircle,
      ),
      UpdatePhase.vpnActive => (
        l.updateVpnTitle,
        l.updateVpnDescription,
        AppGlyphs.vpn,
      ),
      UpdatePhase.permission => (
        l.updatePermissionTitle,
        l.updatePermissionRequired,
        AppGlyphs.appsList,
      ),
      UpdatePhase.confirmation => (
        l.updateConfirmationTitle,
        l.updateConfirmationDescription,
        AppGlyphs.verified,
      ),
      UpdatePhase.installing => (
        l.updateInstallingTitle,
        l.updateInstallingDescription,
        AppGlyphs.cloudSync,
      ),
      UpdatePhase.installed => (
        l.updateInstalledTitle,
        l.updateInstalledDescription,
        AppGlyphs.checkCircle,
      ),
      UpdatePhase.upToDate => (
        l.updateCurrentTitle,
        l.updateNoUpdates,
        AppGlyphs.checkCircle,
      ),
      UpdatePhase.checkFailed => (
        l.updateCheckFailed,
        l.updateCheckFailedDescription,
        AppGlyphs.wifiOff,
      ),
      UpdatePhase.downloadFailed => (
        l.updateDownloadFailed,
        l.updateDownloadFailedDescription,
        AppGlyphs.wifiOff,
      ),
      UpdatePhase.verifyFailed => (
        l.updateVerifyFailedTitle,
        l.updateVerifyFailedDescription,
        AppGlyphs.warning,
      ),
      UpdatePhase.installFailed => (
        l.updateInstallFailed,
        l.updateInstallFailedDescription,
        AppGlyphs.warning,
      ),
      _ => (l.checkUpdate, l.updateCheckingDescription, AppGlyphs.cloudSync),
    };
    final failure = const {
      UpdatePhase.checkFailed,
      UpdatePhase.downloadFailed,
      UpdatePhase.verifyFailed,
      UpdatePhase.installFailed,
    }.contains(update.phase);
    return Semantics(
      liveRegion: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 18,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: ShapeDecoration(
                color: context.raisedSurfaceLevel.colorOf(context.colorScheme),
                shape: AppShape.lg,
              ),
              child: GlyphIcon(
                glyph,
                size: 34,
                color: failure
                    ? context.colorScheme.error
                    : context.colorScheme.primary,
              ),
            ),
          ),
          Text(title, style: AppTextStyle.title1.of(context, emphasized: true)),
          Text(
            description,
            style: AppTextStyle.subheadline
                .of(context)
                .copyWith(color: context.colorScheme.onSurfaceVariant),
          ),
          if (update.release case final release?)
            Text(release.tag, style: AppTextStyle.footnote.of(context)),
          if (const {
            UpdatePhase.downloading,
            UpdatePhase.paused,
            UpdatePhase.downloadFailed,
          }.contains(update.phase))
            _DownloadMeter(update: update),
          if (update.phase == UpdatePhase.verifying ||
              update.phase == UpdatePhase.installing ||
              update.phase == UpdatePhase.checking)
            const LinearProgressIndicator(),
          if (update.verified)
            CommonCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  GlyphIcon(
                    AppGlyphs.verified,
                    size: 20,
                    color: context.colorScheme.success,
                  ),
                  Expanded(
                    child: Text(
                      l.updatePackageVerified,
                      style: AppTextStyle.footnote.of(context),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _DownloadMeter extends StatelessWidget {
  const _DownloadMeter({required this.update});
  final AppUpdateState update;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final progress = update.progress;
    final remaining = update.remainingSeconds;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        if (progress != null)
          Text(
            '${(progress * 100).floor()}%',
            style: AppTextStyle.largeTitle.of(context, emphasized: true),
          ),
        LinearProgressIndicator(
          value:
              progress ?? (update.phase == UpdatePhase.downloading ? null : 0),
        ),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            Text(
              update.total > 0
                  ? '${update.received.traffic.show} / ${update.total.traffic.show}'
                  : update.received.traffic.show,
              style: AppTextStyle.footnote.of(context),
            ),
            if (update.bytesPerSecond > 0)
              Text(
                l.updateTransferSpeed(
                  update.bytesPerSecond.round().traffic.show,
                ),
                style: AppTextStyle.footnote.of(context),
              ),
            if (remaining != null)
              Text(
                l.updateRemainingTime(
                  remaining < 60
                      ? l.updateSeconds(remaining)
                      : l.updateMinutes((remaining / 60).ceil()),
                ),
                style: AppTextStyle.footnote.of(context),
              ),
          ],
        ),
      ],
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
    final (primary, secondary) = switch (update.phase) {
      UpdatePhase.offered => (
        supported && update.asset?.sha256 != null
            ? l.updateDownloadAction
            : l.goDownload,
        l.updateNotNow,
      ),
      UpdatePhase.downloading => (
        l.updateContinueBackground,
        l.updatePauseAction,
      ),
      UpdatePhase.paused => (l.updateResumeAction, l.updateCancelDownload),
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
    void accept() {
      switch (update.phase) {
        case UpdatePhase.offered:
          if (!supported || update.asset?.sha256 == null) {
            final release = update.release;
            if (release != null) {
              unawaited(
                dialogs.openUrl(
                  release.source.releasePage(release.tag).toString(),
                ),
              );
            }
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

    final style = AppTextStyle.subheadline.of(context, emphasized: true);
    final primaryButton = FilledButton(
      key: const ValueKey('update-offer-accept'),
      style: FilledButton.styleFrom(textStyle: style),
      onPressed: update.phase == UpdatePhase.checking ? null : accept,
      child: Text(primary, textAlign: TextAlign.center),
    );
    final secondaryButton = TextButton(
      key: const ValueKey('update-offer-dismiss'),
      style: TextButton.styleFrom(textStyle: style),
      onPressed: dismiss,
      child: Text(secondary, textAlign: TextAlign.center),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          int buttonWidth(String label) {
            final painter = TextPainter(
              text: TextSpan(text: label, style: style),
              textDirection: Directionality.of(context),
              textScaler: MediaQuery.textScalerOf(context),
            )..layout();
            final width = (painter.width + 48).ceil();
            painter.dispose();
            return width;
          }

          final primaryWidth = buttonWidth(primary);
          final secondaryWidth = buttonWidth(secondary);
          final row =
              secondary.isNotEmpty &&
              (SheetProvider.of(context)?.type == SheetType.formSheet ||
                  constraints.maxWidth >= 500) &&
              primaryWidth + secondaryWidth + 12 <= constraints.maxWidth;
          if (row) {
            return Row(
              spacing: 12,
              children: [
                Expanded(flex: secondaryWidth, child: secondaryButton),
                Expanded(flex: primaryWidth, child: primaryButton),
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: [
              primaryButton,
              if (secondary.isNotEmpty) secondaryButton,
            ],
          );
        },
      ),
    );
  }
}

String _updateNote(
  BuildContext context,
  AppUpdateState update,
  bool supported,
) {
  final l = context.appLocalizations;
  return switch (update.phase) {
    UpdatePhase.offered =>
      supported && update.asset?.sha256 != null
          ? l.updateOfferDownloadNote
          : supported
          ? l.updateDirectUnavailable
          : l.updateDesktopDescription,
    UpdatePhase.downloading => l.updateBackgroundNote,
    UpdatePhase.verifying ||
    UpdatePhase.verifyFailed => l.updateVerificationGuard,
    UpdatePhase.ready || UpdatePhase.vpnActive => l.updateVpnInstallNote,
    UpdatePhase.downloadFailed ||
    UpdatePhase.installFailed => l.updateExistingVersionSafe,
    _ => '',
  };
}
