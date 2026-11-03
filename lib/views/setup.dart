import 'dart:async';

import 'package:animations/animations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/common/regional/country_profile.dart';
import 'package:reclash/common/regional/region_labels.dart';
import 'package:reclash/common/setup_check.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/form/form.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/plugins/app.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/providers/setup.dart';
import 'package:reclash/subscriptions/compatibility/clients.dart';
import 'package:reclash/subscriptions/compatibility/policy.dart';
import 'package:reclash/subscriptions/compatibility/settings_form.dart';
import 'package:reclash/subscriptions/external_link.dart';
import 'package:reclash/subscriptions/transport/transport.dart';
import 'package:reclash/ui/code_label.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/views/disclaimer.dart';
import 'package:reclash/views/region.dart';
import 'package:reclash/views/setup_apps_sheet.dart';
import 'package:reclash/widgets/profile_import_dialog.dart';

const _regionOptions = ['RU', 'IR', 'CN', 'EG', otherRegionCode];

/// The numbered part of the wizard; language and consent come before it.
const _journey = [
  SetupStep.profile,
  SetupStep.coverage,
  SetupStep.region,
  SetupStep.summary,
];

const _actionHeight = 56.0;
const _sidePanelWidth = 300.0;
const _phoneCodeSize = 132.0;

/// Controls standing on the page itself: dark mode's raised card level sits
/// too close to the page to outline a button or a progress track.
Color _controlFill(BuildContext context) {
  final colors = context.colorScheme;
  return colors.brightness == Brightness.dark
      ? SurfaceLevel.inset.colorOf(colors)
      : context.raisedSurfaceLevel.colorOf(colors);
}

int? _journeyIndex(SetupStep step) => switch (step) {
  SetupStep.language || SetupStep.agreement => null,
  SetupStep.profile => 0,
  SetupStep.coverage => 1,
  SetupStep.region => 2,
  SetupStep.summary => 3,
};

String _journeyLabel(AppLocalizations l, SetupStep step) => switch (step) {
  SetupStep.coverage => l.setupReceiptCoverage,
  SetupStep.region => l.setupReceiptRegion,
  SetupStep.summary => l.setupReceiptSummary,
  _ => l.setupReceiptProfile,
};

Glyph _journeyGlyph(SetupStep step) => switch (step) {
  SetupStep.coverage => AppGlyphs.vpn,
  SetupStep.region => AppGlyphs.locate,
  SetupStep.summary => AppGlyphs.check,
  _ => AppGlyphs.profiles,
};

String _coverageLabel(AppLocalizations l, SetupCoverage coverage) =>
    switch (coverage) {
      SetupCoverage.tun => l.setupCoverageAll,
      SetupCoverage.system => l.setupCoverageSystem,
      SetupCoverage.local => l.setupCoverageLocal,
    };

Glyph _coverageGlyph(SetupCoverage coverage) => switch (coverage) {
  SetupCoverage.tun => AppGlyphs.vpn,
  SetupCoverage.system => AppGlyphs.devices,
  SetupCoverage.local => AppGlyphs.link,
};

String _regionChoiceLabel(AppLocalizations l, SetupDraft draft) =>
    !draft.regionChosen
    ? l.regionNotSet
    : draft.regionCode == null
    ? l.setupRegionNeutral
    : regionLabel(l, draft.regionCode);

class SetupWizard extends ConsumerStatefulWidget {
  const SetupWizard({super.key, this.isAndroid, this.isTV});

  final bool? isAndroid;
  final bool? isTV;

  @override
  ConsumerState<SetupWizard> createState() => _SetupWizardState();
}

class _SetupWizardState extends ConsumerState<SetupWizard>
    with SingleTickerProviderStateMixin {
  final _linkController = TextEditingController();
  final _keyController = TextEditingController();
  late final ScrollController _scrollController;
  late final _position = AnimationController.unbounded(
    vsync: this,
    value: (_journeyIndex(ref.read(setupSessionProvider).step) ?? 0).toDouble(),
  );
  bool _importing = false;
  bool _saving = false;
  bool _autoRun = false;
  bool _connectNow = true;
  bool _addingProfile = false;
  bool _requestOptions = false;
  bool _showRules = false;
  bool _fromSummary = false;
  bool _backwards = false;
  bool _readToEnd = false;
  String? _importError;
  SubscriptionCancellation? _importCancellation;
  SubscriptionClientSettings _clientSettings =
      const SubscriptionClientSettings.forNewProfile();
  Future<Profile?> Function(String key, SubscriptionCancellation cancellation)?
  _encryptedImport;

  bool get _isAndroid => widget.isAndroid ?? system.isAndroid;
  bool get _isTV => widget.isTV ?? system.isTV;
  SetupSession get _session => ref.read(setupSessionProvider.notifier);
  bool get _locked =>
      _importing || _saving || ref.read(setupSessionProvider).busy;
  bool get _hasLink => _linkController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _scrollController = sheetScrollController(context);
    _autoRun = ref.read(appSettingProvider).autoRun;
    _linkController.addListener(_onLinkChanged);
    scheduleMicrotask(() {
      if (mounted) _session.followDetectedRegion();
    });
    scheduleMicrotask(_adoptLink);
  }

  /// A link held before consent waits until the profile step, where the
  /// field exists and consent has been given.
  void _adoptLink() {
    if (!mounted) return;
    final state = ref.read(setupSessionProvider);
    final link = state.pendingLink;
    if (link == null || state.step.index < SetupStep.profile.index) return;
    _linkController.text = link;
    _session.consumeLink();
  }

  @override
  void dispose() {
    _importCancellation?.cancel();
    _linkController.removeListener(_onLinkChanged);
    _linkController.dispose();
    _keyController.dispose();
    _scrollController.dispose();
    _position.dispose();
    super.dispose();
  }

  void _onLinkChanged() {
    if (!mounted) return;
    setState(() => _importError = null);
  }

  Future<void> _transition(Future<bool> Function() action) async {
    if (_locked) return;
    setState(() => _saving = true);
    try {
      await action();
    } catch (error) {
      if (mounted) _session.showError(error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _import(
    Future<Profile?> Function(String key, SubscriptionCancellation cancellation)
    action,
  ) async {
    if (_locked) return;
    final cancellation = SubscriptionCancellation();
    _importCancellation = cancellation;
    setState(() {
      _importing = true;
      _importError = null;
      _encryptedImport = null;
    });
    try {
      if (!await _session.prepareCore() || !mounted || cancellation.cancelled) {
        return;
      }
      final profile = await action(_keyController.text.trim(), cancellation);
      if (!mounted || cancellation.cancelled) return;
      if (profile != null) {
        _session.selectProfile(profile.id);
        _linkController.clear();
        _keyController.clear();
        setState(() {
          _encryptedImport = null;
          _addingProfile = false;
        });
      }
    } on AgeSecretKeyRequiredException {
      if (mounted && !cancellation.cancelled) {
        setState(() => _encryptedImport = action);
      }
    } on SubscriptionUpdateCancelled {
      return;
    } on SubscriptionUpdateSuperseded {
      return;
    } on SubscriptionUpdateRejected catch (error) {
      if (error.reason == SubscriptionRetryReason.cancelled) return;
      if (mounted && !cancellation.cancelled) {
        await dialogs.showSubscriptionFailure(error);
      }
    } on SubscriptionException catch (error) {
      if (error.failure == SubscriptionFailure.cancelled ||
          error.failure == SubscriptionFailure.superseded) {
        return;
      }
      if (mounted && !cancellation.cancelled) {
        await dialogs.showSubscriptionFailure(error);
      }
    } catch (error) {
      if (mounted && !cancellation.cancelled) {
        setState(
          () => _importError = userFacingErrorMessage(
            error,
            context.appLocalizations,
          ),
        );
      }
    } finally {
      cancellation.cancel();
      if (identical(_importCancellation, cancellation)) {
        _importCancellation = null;
        if (mounted) setState(() => _importing = false);
      }
    }
  }

  void _cancelImport() {
    _importCancellation?.cancel();
    _importCancellation = null;
    setState(() => _importing = false);
  }

  void _importLink() {
    final link = _linkController.text.trim();
    if (!isProfileLinkInput(link)) {
      setState(
        () => _importError =
            context.appLocalizations.profileUrlInvalidValidationDesc,
      );
      return;
    }
    if (!link.isShareLink && !_clientSettings.isValid) {
      setState(
        () => _importError =
            context.appLocalizations.subscriptionClientCustomUserAgentInvalid,
      );
      return;
    }
    final clientSettings = _clientSettings;
    ({ProfileLinkSource source, ProfileLinkImport choice})? confirmed;
    unawaited(
      _import((key, cancellation) async {
        confirmed ??= await _confirmLink(link);
        if (confirmed == null || !mounted || cancellation.cancelled) {
          return null;
        }
        return ref
            .read(profilesActionProvider.notifier)
            .importProfileFromLink(
              link,
              label: confirmed!.choice.label,
              ageSecretKey: key,
              select: false,
              clientSettings: confirmed!.source.preset == null
                  ? clientSettings
                  : confirmed!.choice.clientSettings,
              reviewContext: context,
              cancellation: cancellation,
            );
      }),
    );
  }

  /// The preview a deep link gets, so a pasted or typed link is checked
  /// before it is downloaded into a profile.
  Future<({ProfileLinkSource source, ProfileLinkImport choice})?> _confirmLink(
    String link,
  ) async {
    final source = await resolveProfileLink(link);
    if (!mounted) return null;
    final profiles = ref.read(profilesActionProvider.notifier);
    final choice = await showProfileImportDialog(
      source,
      preview: profiles.previewProfileLinkSource,
      duplicateOf: profiles.duplicateProfileLabel(source),
    );
    return choice == null ? null : (source: source, choice: choice);
  }

  Future<void> _previewProfile(
    Profile profile, {
    required bool selected,
  }) async {
    final pick = await showProfilePreviewDialog(profile, selected: selected);
    if (pick == true && mounted) _session.selectProfile(profile.id);
  }

  Future<void> _deleteProfile(Profile profile) async {
    final l = context.appLocalizations;
    final confirmed = await dialogs.showMessage(
      title: l.tip,
      message: TextSpan(text: l.deleteTip(l.profile)),
      destructive: true,
      confirmText: l.delete,
    );
    if (confirmed != true || !mounted) return;
    await ref.read(profilesActionProvider.notifier).deleteProfile(profile.id);
    if (!mounted ||
        ref.read(setupSessionProvider).draft.profileId != profile.id) {
      return;
    }
    _session.selectProfile(ref.read(profilesProvider).firstOrNull?.id);
  }

  /// Pastes the clipboard and, when it holds a profile link, imports it at
  /// once: pasting is what a first-time user does with the link they got.
  Future<void> _pasteLink() async {
    try {
      final text = (await Clipboard.getData(Clipboard.kTextPlain))?.text;
      if (text == null || !mounted) return;
      _linkController.text = text.trim();
      if (isProfileLinkInput(_linkController.text)) _importLink();
    } catch (error) {
      if (mounted) _session.showError(error);
    }
  }

  void _importFile() {
    List<int>? data;
    String? name;
    unawaited(
      _import((key, cancellation) async {
        if (data == null) {
          final file = await picker.pickerFile();
          if (file == null) return null;
          data = await file.readBytes();
          name = file.name;
        }
        if (!mounted || cancellation.cancelled) return null;
        return ref
            .read(profilesActionProvider.notifier)
            .importProfileData(
              data!,
              name: name!,
              ageSecretKey: key,
              select: false,
              reviewContext: context,
              cancellation: cancellation,
            );
      }),
    );
  }

  void _importQr() {
    String? link;
    ({ProfileLinkSource source, ProfileLinkImport choice})? confirmed;
    final clientSettings = _clientSettings;
    unawaited(
      _import((key, cancellation) async {
        link ??= await picker.pickerConfigQRCode();
        if (link == null || !mounted || cancellation.cancelled) return null;
        if (!link!.isShareLink && !clientSettings.isValid) {
          throw MessageException(
            context.appLocalizations.subscriptionClientCustomUserAgentInvalid,
          );
        }
        confirmed ??= await _confirmLink(link!);
        if (confirmed == null || !mounted || cancellation.cancelled) {
          return null;
        }
        return ref
            .read(profilesActionProvider.notifier)
            .importProfileFromLink(
              link!,
              label: confirmed!.choice.label,
              ageSecretKey: key,
              select: false,
              clientSettings: clientSettings,
              reviewContext: context,
              cancellation: cancellation,
            );
      }),
    );
  }

  /// A step opened from the summary returns to it instead of walking on.
  SetupStep? _previous(SetupStep step) =>
      _fromSummary && step != SetupStep.summary
      ? SetupStep.summary
      : switch (step) {
          SetupStep.language => null,
          SetupStep.agreement || SetupStep.profile => SetupStep.language,
          SetupStep.coverage => SetupStep.profile,
          SetupStep.region => SetupStep.coverage,
          SetupStep.summary => SetupStep.region,
        };

  SetupStep _following(SetupStep step) =>
      _fromSummary ? SetupStep.summary : _journey[_journey.indexOf(step) + 1];

  void _goTo(SetupStep target) {
    if (_locked) return;
    final wasEditing = _fromSummary;
    setState(
      () => _fromSummary =
          target != SetupStep.summary &&
          (wasEditing ||
              ref.read(setupSessionProvider).step == SetupStep.summary),
    );
    unawaited(
      _transition(() async {
        final moved = await _session.next(target);
        if (!moved && mounted) setState(() => _fromSummary = wasEditing);
        return moved;
      }),
    );
  }

  void _back() {
    final previous = _previous(ref.read(setupSessionProvider).step);
    if (previous != null) _goTo(previous);
  }

  Future<void> _skip() async {
    if (_locked) return;
    final l = context.appLocalizations;
    final skip = await dialogs.showMessage(
      context: sheetNavigatorOf(context).context,
      title: l.setupSkipTitle,
      message: TextSpan(text: l.setupSkipMessage),
      confirmText: l.setupSkip,
    );
    if (skip == true && mounted) await _transition(_session.skip);
  }

  /// The agreement can be accepted once its end has been on screen.
  bool _trackReading(Notification notification) {
    if (_readToEnd ||
        ref.read(setupSessionProvider).step != SetupStep.agreement) {
      return false;
    }
    final metrics = switch (notification) {
      ScrollNotification(depth: 0, :final metrics) ||
      ScrollMetricsNotification(depth: 0, :final metrics) => metrics,
      _ => null,
    };
    if (metrics != null && metrics.extentAfter <= 1) {
      setState(() => _readToEnd = true);
    }
    return false;
  }

  Future<void> _exit() async {
    if (_locked) return;
    if (await _session.persist() && mounted) {
      await ref.read(systemActionProvider.notifier).handleExit();
    }
  }

  void _continueFromLanguage() {
    final accepted =
        ref.read(appSettingProvider).acceptedDisclaimerVersion >=
        disclaimerVersion;
    unawaited(
      _transition(
        () => _session.next(accepted ? SetupStep.profile : SetupStep.agreement),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(setupSessionProvider);
    final l = context.appLocalizations;
    ref.listen(setupSessionProvider.select((value) => value.active), (
      _,
      active,
    ) {
      if (!active) _importCancellation?.cancel();
    });
    ref.listen(
      setupSessionProvider.select((value) => (value.pendingLink, value.step)),
      (_, _) => _adoptLink(),
    );
    ref.listen(setupSessionProvider.select((value) => value.step), (
      previous,
      step,
    ) {
      _backwards = previous != null && step.index < previous.index;
      if (step == SetupStep.agreement) _readToEnd = false;
      final index = _journeyIndex(step);
      if (index != null) {
        springToSegment(_position, index, instant: context.disableAnimations);
      }
      if (_scrollController.hasClients) _scrollController.jumpTo(0);
    });
    final locked = _importing || _saving || state.busy;
    final error = state.saveError ? l.setupSaveError : state.error;
    final accepted = ref.watch(
      appSettingProvider.select(
        (value) => value.acceptedDisclaimerVersion >= disclaimerVersion,
      ),
    );
    final pageColor = SurfaceLevel.page.colorOf(context.colorScheme);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !locked) _back();
      },
      child: Scaffold(
        backgroundColor: PageBackgroundRegistration.maybeOf(context) == null
            ? pageColor
            : Colors.transparent,
        body: PageBackground(
          baseColor: pageColor,
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final scale =
                    MediaQuery.textScalerOf(
                      context,
                    ).scale(AppTextStyle.subheadline.size) /
                    AppTextStyle.subheadline.size;
                final journey = _journeyIndex(state.step) != null;
                final current = _journeyIndex(state.step) ?? 0;
                final unlocked = _fromSummary ? _journey.length : current;
                final wide =
                    journey &&
                    constraints.maxWidth >= 940 &&
                    constraints.maxHeight >= 560 * scale;
                final gutter = constraints.maxWidth >= 600 ? 24.0 : 16.0;
                final frameWidth = wide ? 1040.0 : 640.0;
                Widget framed(Widget child) => Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: frameWidth + gutter * 2,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: gutter),
                      child: child,
                    ),
                  ),
                );
                final content = NotificationListener<Notification>(
                  onNotification: _trackReading,
                  child: _FadedEdge(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(top: 16, bottom: 32),
                      child: framed(_body(state, l, locked)),
                    ),
                  ),
                );
                return Column(
                  children: [
                    framed(
                      _header(
                        state,
                        l,
                        locked,
                        unlocked: unlocked,
                        control: journey && constraints.maxWidth >= 600,
                        stepBar: journey && constraints.maxWidth < 600,
                        canSkip: accepted && state.step != SetupStep.agreement,
                      ),
                    ),
                    AnimatedReveal(
                      visible: error != null,
                      child: framed(
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: ErrorBanner(message: error ?? ''),
                        ),
                      ),
                    ),
                    Expanded(
                      child: wide
                          ? framed(
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 32,
                                children: [
                                  Expanded(
                                    child: _FadedEdge(
                                      child: SingleChildScrollView(
                                        controller: _scrollController,
                                        padding: const EdgeInsets.only(
                                          top: 16,
                                          bottom: 32,
                                        ),
                                        child: _body(state, l, locked),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: _sidePanelWidth,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 16),
                                      child: _SetupReceipt(
                                        state: state,
                                        unlocked: unlocked,
                                        onStep: locked ? null : _goTo,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : content,
                    ),
                    framed(_actions(state, l, locked, wide: wide)),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(
    SetupSessionState state,
    AppLocalizations l,
    bool locked, {
    required int unlocked,
    required bool control,
    required bool stepBar,
    required bool canSkip,
  }) {
    final index = _journeyIndex(state.step);
    final colors = context.colorScheme;
    final duration = context.motionDuration(commonDuration);
    final segments = [
      for (final step in _journey)
        GlyphSegment(
          value: step,
          glyph: _journeyGlyph(step),
          label: _journeyLabel(l, step),
        ),
    ];
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Image.asset('assets/images/icon.png', width: 36, height: 36),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: duration,
                      curve: Curves.easeInOutCubic,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: index == null
                          ? AppTextStyle.headline.of(context)
                          : AppTextStyle.footnote
                                .of(context)
                                .copyWith(color: colors.onSurfaceVariant),
                      child: AnimatedSwitcher(
                        duration: duration,
                        layoutBuilder: (current, previous) => Stack(
                          alignment: AlignmentDirectional.centerStart,
                          children: [...previous, ?current],
                        ),
                        child: Text(
                          index == null
                              ? l.setupTitle
                              : '${l.setupTitle} · '
                                    '${l.setupStepStatus(index + 1, _journey.length)}',
                          key: ValueKey(index),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    AnimatedReveal(
                      visible: index != null,
                      alignment: AlignmentDirectional.topStart,
                      child: DefaultTextStyle.merge(
                        style: AppTextStyle.title3.of(
                          context,
                          emphasized: true,
                        ),
                        child: RollingTitle(
                          labels: [
                            for (final step in _journey) _journeyLabel(l, step),
                          ],
                          position: _position,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _SideReveal(
                visible: control,
                alignment: AlignmentDirectional.centerEnd,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 12),
                  child: GlyphSegmentedControl<SetupStep>(
                    segments: segments,
                    value: state.step,
                    position: _position,
                    onChanged: (step) {
                      final target = _journey.indexOf(step);
                      if (!locked && target != index && target < unlocked) {
                        _goTo(step);
                      }
                    },
                  ),
                ),
              ),
              _SideReveal(
                visible: canSkip || state.step == SetupStep.agreement,
                alignment: AlignmentDirectional.centerEnd,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 12),
                  child: _SkipButton(
                    glyph: state.step == SetupStep.agreement
                        ? AppGlyphs.power
                        : AppGlyphs.skip,
                    label: state.step == SetupStep.agreement
                        ? l.exit
                        : l.setupSkip,
                    onPressed: locked
                        ? null
                        : state.step == SetupStep.agreement
                        ? () => unawaited(_exit())
                        : canSkip
                        ? () => unawaited(_skip())
                        : null,
                  ),
                ),
              ),
            ],
          ),
          AnimatedReveal(
            visible: stepBar,
            child: Padding(
              padding: const EdgeInsets.only(top: 14),
              child: _StepBar(
                current: index ?? 0,
                unlocked: unlocked,
                onStep: locked ? null : _goTo,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _hero({required String title, required String description}) {
    final colors = context.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyle.title1.of(context, emphasized: true)),
        const SizedBox(height: 8),
        Text(
          description,
          style: AppTextStyle.body
              .of(context)
              .copyWith(color: colors.onSurfaceVariant),
        ),
      ],
    );
  }

  /// Notes sit on the inset of list captions, like a [ListFooter].
  Widget _note(String text, {Glyph? glyph}) {
    final style = AppTextStyle.footnote
        .of(context)
        .copyWith(color: context.colorScheme.onSurfaceVariant);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: glyph == null
          ? Text(text, style: style)
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                GlyphIcon(glyph, size: 18, color: style.color),
                Expanded(child: Text(text, style: style)),
              ],
            ),
    );
  }

  /// A titled group without the page-level gap [generateSection] puts above
  /// its header, which the step's own spacing already provides.
  Widget _section(String title, List<Widget> items, {String? footer}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListHeader(
          title: title,
          padding: listHeaderPaddingOf(context).copyWith(top: 0),
        ),
        AnimatedEntries(grouped: true, children: items),
        if (footer != null) ListFooter(text: footer),
      ],
    );
  }

  Widget _badge(String text) {
    final colors = context.colorScheme;
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: colors.primaryContainer,
        shape: AppShape.full,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Text(
          text,
          style: AppTextStyle.caption1
              .of(context, emphasized: true)
              .copyWith(color: colors.onPrimaryContainer),
        ),
      ),
    );
  }

  Widget _titled(String title, {bool recommended = false}) {
    if (!recommended) return Text(title);
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(title),
        _badge(context.appLocalizations.setupRecommended),
      ],
    );
  }

  Widget _body(SetupSessionState state, AppLocalizations l, bool locked) {
    return PageTransitionSwitcher(
      duration: context.motionDuration(const Duration(milliseconds: 360)),
      reverse: _backwards,
      layoutBuilder: (entries) => Stack(
        fit: StackFit.passthrough,
        alignment: Alignment.topCenter,
        children: entries,
      ),
      transitionBuilder: (child, animation, secondaryAnimation) =>
          SharedAxisTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.horizontal,
            fillColor: Colors.transparent,
            child: child,
          ),
      child: KeyedSubtree(
        key: ValueKey(state.step),
        child: switch (state.step) {
          SetupStep.language => _language(l, locked),
          SetupStep.profile => _profile(state, l, locked),
          SetupStep.coverage => _coverage(state, l, locked),
          SetupStep.region => _region(state, l, locked),
          SetupStep.summary => _summary(state, l, locked),
          SetupStep.agreement => _agreement(l),
        },
      ),
    );
  }

  Widget _agreement(AppLocalizations l) {
    final colors = context.colorScheme;
    final text = AppTextStyle.subheadline
        .of(context)
        .copyWith(color: colors.onSurfaceVariant, height: 1.5);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        _hero(title: l.disclaimer, description: l.disclaimerDesc),
        const SizedBox(height: 4),
        for (final (index, term) in DisclaimerView.terms(l).indexed)
          DecoratedBox(
            decoration: ShapeDecoration(
              color: context.raisedSurfaceLevel.colorOf(colors),
              shape: AppShape.xl,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  Text(
                    '${index + 1}. ${term.title}',
                    style: AppTextStyle.headline.of(context),
                  ),
                  for (final paragraph in term.content.split('\n\n'))
                    Text(paragraph, style: text),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _language(AppLocalizations l, bool locked) {
    final locale = getLocaleForString(
      ref.watch(appSettingProvider.select((value) => value.locale)),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 28,
      children: [
        _hero(
          title: l.setupLanguageTitle,
          description: l.setupLanguageDescription,
        ),
        generateGroup([
          for (final option in <Locale?>[
            null,
            ...AppLocalizations.delegate.supportedLocales,
          ])
            DecorationListItem(
              isSelected: locale == option,
              leading: option == null
                  ? const GlyphIcon(AppGlyphs.language)
                  : Text(
                      option.flagEmoji,
                      style: AppTextStyle.title3
                          .of(context)
                          .copyWith(fontFamily: FontFamily.twEmoji.value),
                    ),
              title: Text(option?.nativeLabel ?? l.defaultText),
              subtitle: Text(option?.englishLabel ?? l.followSystem),
              trailing: locale == option ? const SelectionCheck() : null,
              onPressed: locked
                  ? null
                  : () =>
                        unawaited(_session.selectLanguage(option?.toString())),
            ),
        ]),
      ],
    );
  }

  Widget _profile(SetupSessionState state, AppLocalizations l, bool locked) {
    final profiles = ref.watch(profilesProvider);
    final importing =
        profiles.isEmpty ||
        _addingProfile ||
        _importing ||
        _encryptedImport != null ||
        _hasLink;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _hero(
          title: l.setupProfileTitle,
          description: l.setupProfileDescription,
        ),
        AnimatedReveal(
          visible: profiles.isNotEmpty,
          child: Padding(
            padding: const EdgeInsets.only(top: 28),
            child: _section(l.setupProfileCount(profiles.length), [
              for (final profile in profiles)
                ContextMenuRegion(
                  key: ValueKey(profile.id),
                  menuItems: locked
                      ? null
                      : [
                          CommonPopupMenuItem(
                            danger: true,
                            glyph: AppGlyphs.delete,
                            label: l.delete,
                            onPressed: () => unawaited(_deleteProfile(profile)),
                          ),
                        ],
                  child: DecorationListItem(
                    leading: GlyphIcon(
                      profile.type == ProfileType.url
                          ? AppGlyphs.cloudDownload
                          : AppGlyphs.profiles,
                    ),
                    title: Text(
                      profile.realLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: switch (Uri.tryParse(profile.url)?.host) {
                      final host? when host.isNotEmpty => Text(
                        host,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      _ => null,
                    },
                    isSelected: profile.id == state.draft.profileId,
                    trailing: profile.id == state.draft.profileId
                        ? const SelectionCheck()
                        : null,
                    onPressed: locked
                        ? null
                        : () => unawaited(
                            _previewProfile(
                              profile,
                              selected: profile.id == state.draft.profileId,
                            ),
                          ),
                  ),
                ),
              if (!importing)
                DecorationListItem(
                  key: const ValueKey('import-another'),
                  leading: GlyphIcon(
                    AppGlyphs.add,
                    color: context.colorScheme.primary,
                  ),
                  title: Text(
                    l.setupProfileImportAnother,
                    style: TextStyle(color: context.colorScheme.primary),
                  ),
                  onPressed: locked
                      ? null
                      : () => setState(() => _addingProfile = true),
                ),
            ]),
          ),
        ),
        AnimatedReveal(
          visible: importing,
          child: Padding(
            padding: const EdgeInsets.only(top: 28),
            child: _importCard(
              l,
              locked,
              another: profiles.isNotEmpty,
              withoutProfile: state.draft.profileId == null,
            ),
          ),
        ),
        AnimatedReveal(
          visible: !importing && state.draft.profileId == null,
          child: Padding(
            padding: const EdgeInsets.only(top: 28),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: _withoutProfile(l, locked),
            ),
          ),
        ),
      ],
    );
  }

  Widget _withoutProfile(AppLocalizations l, bool locked) => TextButton(
    onPressed: locked ? null : () => _goTo(SetupStep.coverage),
    child: Text(l.setupProfileWithout),
  );

  Widget _importCard(
    AppLocalizations l,
    bool locked, {
    required bool another,
    required bool withoutProfile,
  }) {
    final colors = context.colorScheme;
    Widget source(Glyph glyph, String label, VoidCallback onPressed) =>
        Expanded(
          child: CommonCard(
            shape: AppShape.lg,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            onPressed: locked ? null : onPressed,
            child: Column(
              spacing: 6,
              children: [
                GlyphIcon(glyph, size: 24, color: colors.primary),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.footnote.of(context, emphasized: true),
                ),
              ],
            ),
          ),
        );
    final dismissible = another && _addingProfile && !_hasLink;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CommonCard(
          shape: AppShape.xl,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AnimatedReveal(
                visible: another || _importing,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          another
                              ? l.setupProfileImportAnother
                              : l.setupProfileImport,
                          style: AppTextStyle.headline.of(context),
                        ),
                      ),
                      AnimatedSize(
                        duration: context.motionDuration(commonDuration),
                        curve: Curves.easeInOutCubic,
                        alignment: AlignmentDirectional.centerEnd,
                        child: _importing || dismissible
                            ? Padding(
                                padding: const EdgeInsetsDirectional.only(
                                  start: 12,
                                ),
                                child: TextButton(
                                  onPressed: _importing
                                      ? _cancelImport
                                      : () => setState(
                                          () => _addingProfile = false,
                                        ),
                                  child: Text(l.cancel),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
              if (_isTV)
                _PhoneLink(
                  onLink: (link) {
                    _linkController.text = link;
                    _importLink();
                  },
                )
              else
                Text(
                  l.setupProfileImportHint,
                  style: AppTextStyle.subheadline
                      .of(context)
                      .copyWith(color: colors.onSurfaceVariant),
                ),
              const SizedBox(height: 16),
              FilledInputTheme(
                child: TextField(
                  controller: _linkController,
                  enabled: !locked,
                  autocorrect: false,
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.go,
                  onSubmitted: (_) => _importLink(),
                  decoration: InputDecoration(hintText: l.setupProfileLinkHint),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                spacing: 8,
                children: [
                  source(
                    AppGlyphs.paste,
                    l.paste,
                    () => unawaited(_pasteLink()),
                  ),
                  source(AppGlyphs.importFile, l.file, _importFile),
                  if (!_isTV) source(AppGlyphs.qrCode, l.qrcode, _importQr),
                ],
              ),
              AnimatedReveal(
                visible: _importError != null,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: ErrorBanner(message: _importError ?? ''),
                ),
              ),
              AnimatedReveal(
                visible: _encryptedImport != null,
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 12,
                    children: [
                      Text(
                        l.setupAgeKeyDescription,
                        style: AppTextStyle.subheadline.of(context),
                      ),
                      FilledInputTheme(
                        child: SecretTextFormField(
                          controller: _keyController,
                          decoration: InputDecoration(hintText: l.ageSecretKey),
                        ),
                      ),
                      FilledButton(
                        onPressed: locked || _encryptedImport == null
                            ? null
                            : () => unawaited(_import(_encryptedImport!)),
                        child: Text(l.setupLanguageContinue),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            TextButton.icon(
              onPressed: () =>
                  setState(() => _requestOptions = !_requestOptions),
              icon: AnimatedRotation(
                turns: _requestOptions ? 0 : -0.25,
                duration: context.motionDuration(commonDuration),
                child: const GlyphIcon(AppGlyphs.chevronDown, size: 18),
              ),
              label: Text(l.setupProfileOptions),
            ),
            AnimatedReveal(
              visible: withoutProfile && !_importing,
              child: _withoutProfile(l, locked),
            ),
          ],
        ),
        AnimatedReveal(
          visible: _requestOptions,
          child: ExcludeFocus(
            excluding: locked || !_requestOptions,
            child: IgnorePointer(
              ignoring: locked,
              child: SubscriptionClientSettingsSection(
                initial: _clientSettings,
                onChanged: (value) => setState(() => _clientSettings = value),
                onFormChanged: () {},
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _choice({
    required Glyph glyph,
    required String title,
    required String description,
    required bool selected,
    required VoidCallback? onPressed,
    bool recommended = false,
  }) {
    final colors = context.colorScheme;
    return CommonCard(
      isSelected: selected,
      shape: AppShape.xl,
      padding: const EdgeInsets.all(16),
      onPressed: onPressed,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 14,
        children: [
          AnimatedContainer(
            duration: context.motionDuration(commonDuration),
            curve: Curves.easeInOutCubic,
            width: 44,
            height: 44,
            decoration: ShapeDecoration(
              color: selected ? colors.primary : colors.primaryContainer,
              shape: AppShape.md,
            ),
            child: Center(
              child: TweenAnimationBuilder<Color?>(
                tween: ColorTween(
                  end: selected ? colors.onPrimary : colors.onPrimaryContainer,
                ),
                duration: context.motionDuration(commonDuration),
                builder: (_, color, _) =>
                    GlyphIcon(glyph, size: 24, color: color),
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                DefaultTextStyle.merge(
                  style: AppTextStyle.headline.of(context),
                  child: _titled(title, recommended: recommended),
                ),
                Text(
                  description,
                  style: AppTextStyle.subheadline
                      .of(context)
                      .copyWith(color: colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 24,
            height: 24,
            child: AnimatedSwitcher(
              duration: context.motionDuration(commonDuration),
              child: selected
                  ? const SelectionCheck(key: ValueKey('selected'))
                  : const SizedBox.shrink(key: ValueKey('unselected')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _coverage(SetupSessionState state, AppLocalizations l, bool locked) {
    final draft = state.draft;
    final options = _isAndroid
        ? const [SetupCoverage.tun, SetupCoverage.local]
        : SetupCoverage.values;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 28,
      children: [
        _hero(
          title: l.setupCoverageTitle,
          description: l.setupCoverageDescription,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            for (final coverage in options)
              _choice(
                glyph: _coverageGlyph(coverage),
                title: _coverageLabel(l, coverage),
                description: switch (coverage) {
                  SetupCoverage.tun =>
                    _isAndroid
                        ? l.setupCoverageAndroidDescription
                        : l.setupCoverageAllDescription,
                  SetupCoverage.system => l.setupCoverageSystemDescription,
                  SetupCoverage.local => l.setupCoverageLocalDescription,
                },
                recommended: coverage == SetupCoverage.tun,
                selected: coverage == draft.coverage,
                onPressed: locked
                    ? null
                    : () => _session.selectCoverage(coverage),
              ),
          ],
        ),
        _note(l.setupCoverageNote, glyph: AppGlyphs.info),
      ],
    );
  }

  Widget _region(SetupSessionState state, AppLocalizations l, bool locked) {
    final draft = state.draft;
    final detected = ref.watch(
      detectedRegionProvider.select((value) => value.value?.countryCode),
    );
    final selected = draft.regionChosen ? draft.regionCode : null;
    final changes = selected == null
        ? const <(Glyph, String)>[]
        : regionChanges(ref, l, selected);
    final directRules = draft.regionChosen
        ? directRulesForCode(draft.regionCode)
        : const <String>[];
    DecorationListItem option({
      required Widget leading,
      required String title,
      required bool isSelected,
      required String? code,
    }) => DecorationListItem(
      isSelected: isSelected,
      leading: SizedBox(width: 28, child: Center(child: leading)),
      title: _titled(title, recommended: code != null && code == detected),
      trailing: isSelected ? const SelectionCheck() : null,
      onPressed: locked ? null : () => _session.selectRegion(code),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _hero(
          title: l.setupRegionTitle,
          description: l.setupRegionStepDescription,
        ),
        const SizedBox(height: 28),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            generateGroup([
              for (final code in _regionOptions)
                option(
                  leading: Text(
                    regionFlag(code),
                    style: AppTextStyle.title3
                        .of(context)
                        .copyWith(fontFamily: FontFamily.twEmoji.value),
                  ),
                  title: regionLabel(l, code),
                  isSelected: draft.regionChosen && code == draft.regionCode,
                  code: code,
                ),
              option(
                leading: const GlyphIcon(AppGlyphs.block, size: 24),
                title: l.setupRegionNeutral,
                isSelected: draft.regionChosen && draft.regionCode == null,
                code: null,
              ),
            ]),
            AnimatedSize(
              duration: context.motionDuration(commonDuration),
              curve: Curves.easeInOutCubic,
              alignment: Alignment.topCenter,
              child: ListFooter(
                text: draft.regionChosen
                    ? l.regionCustomPreserved
                    : l.setupRegionUnchosen,
              ),
            ),
          ],
        ),
        AnimatedReveal(
          visible: directRules.isNotEmpty,
          child: Padding(
            padding: const EdgeInsets.only(top: 28),
            child: _directRoutes(state, l, locked, directRules),
          ),
        ),
        AnimatedReveal(
          visible: changes.isNotEmpty,
          child: Padding(
            padding: const EdgeInsets.only(top: 28),
            child: _changes(l.regionChangesTitle, changes),
          ),
        ),
      ],
    );
  }

  Widget _directRoutes(
    SetupSessionState state,
    AppLocalizations l,
    bool locked,
    List<String> rules,
  ) {
    final draft = state.draft;
    final routes = _section(l.setupDirectSection, footer: l.setupDirectHint, [
      DecorationListItem(
        key: const ValueKey('direct-routes'),
        leading: const GlyphIcon(AppGlyphs.split),
        title: Text(l.setupDirectTitle),
        trailing: Switch(
          value: draft.directRoutes,
          onChanged: locked ? null : _session.selectDirectRoutes,
        ),
        onPressed: locked
            ? null
            : () => _session.selectDirectRoutes(!draft.directRoutes),
      ),
      if (draft.directRoutes)
        AnimatedSize(
          key: const ValueKey('direct-rules'),
          duration: context.motionDuration(commonDuration),
          curve: Curves.easeInOutCubic,
          alignment: Alignment.topCenter,
          child: DecorationListItem(
            leading: const GlyphIcon(AppGlyphs.rules),
            title: Text(l.setupDirectRules),
            subtitle: _showRules
                ? Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [for (final rule in rules) CodeLabel(rule)],
                    ),
                  )
                : null,
            trailing: AnimatedRotation(
              turns: _showRules ? 0.5 : 0,
              duration: context.motionDuration(commonDuration),
              child: const GlyphIcon(AppGlyphs.chevronDown, size: 18),
            ),
            onPressed: () => setState(() => _showRules = !_showRules),
          ),
        ),
    ]);
    if (!_session.offersDirectApps) return routes;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        routes,
        generateGroup([_directApps(state, l, locked)]),
      ],
    );
  }

  Widget _changes(String title, List<(Glyph, String)> changes) {
    final colors = context.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListHeader(
          title: title,
          padding: listHeaderPaddingOf(context).copyWith(top: 0),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AnimatedSize(
            duration: context.motionDuration(commonDuration),
            curve: Curves.easeInOutCubic,
            alignment: Alignment.topCenter,
            child: AnimatedSwitcher(
              duration: context.motionDuration(commonDuration),
              layoutBuilder: (current, previous) => Stack(
                fit: StackFit.passthrough,
                alignment: Alignment.topCenter,
                children: [...previous, ?current],
              ),
              child: Column(
                key: ValueKey(changes.map((change) => change.$2).join('|')),
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  for (final (glyph, label) in changes)
                    Row(
                      spacing: 12,
                      children: [
                        GlyphIcon(glyph, size: 20, color: colors.primary),
                        Expanded(
                          child: Text(
                            label,
                            style: AppTextStyle.subheadline.of(context),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _directApps(SetupSessionState state, AppLocalizations l, bool locked) {
    return AnimatedSize(
      duration: context.motionDuration(commonDuration),
      curve: Curves.easeInOutCubic,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: context.motionDuration(commonDuration),
        layoutBuilder: (current, previous) => Stack(
          fit: StackFit.passthrough,
          alignment: Alignment.topCenter,
          children: [...previous, ?current],
        ),
        child: _directAppsItem(state, l, locked),
      ),
    );
  }

  Widget _directAppsItem(
    SetupSessionState state,
    AppLocalizations l,
    bool locked,
  ) {
    final apps = state.draft.directApps;
    const leading = GlyphIcon(AppGlyphs.appsList);
    if (state.scanningApps) {
      return DecorationListItem(
        key: const ValueKey('scanning'),
        leading: leading,
        title: Text(l.setupDirectAppsScanning),
        trailing: const CommonCircleLoading(size: 20),
      );
    }
    if (apps == null) {
      return DecorationListItem(
        key: const ValueKey('find'),
        leading: leading,
        title: Text(l.setupDirectAppsTitle),
        subtitle: Text(l.setupDirectAppsFindDescription),
        trailing: FilledButton.tonal(
          onPressed: locked ? null : () => unawaited(_session.findDirectApps()),
          child: Text(l.setupDirectAppsFind),
        ),
      );
    }
    if (apps.isEmpty) {
      return DecorationListItem(
        key: const ValueKey('none'),
        leading: leading,
        title: Text(l.setupDirectAppsTitle),
        subtitle: Text(l.setupDirectAppsNone),
        trailing: TextButton(
          onPressed: locked ? null : () => unawaited(_session.findDirectApps()),
          child: Text(l.setupDirectAppsFind),
        ),
      );
    }
    return DecorationListItem(
      key: const ValueKey('apps'),
      leading: leading,
      title: Text(l.setupDirectAppsTitle),
      subtitle: Text(l.setupDirectApps(apps.length)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          DirectAppsStack(apps: apps),
          const GlyphIcon(AppGlyphs.chevronForward, size: 18),
        ],
      ),
      onPressed: locked ? null : () => unawaited(showDirectAppsSheet(context)),
    );
  }

  Widget _summary(SetupSessionState state, AppLocalizations l, bool locked) {
    final draft = state.draft;
    final profile = ref
        .watch(profilesProvider)
        .getProfile(draft.profileId ?? -1);
    final safeMode = ref.watch(safeModeProvider);
    final running = ref.watch(isStartProvider);
    final runnable = profile != null && !safeMode;
    final directRules = draft.regionChosen
        ? directRulesForCode(draft.regionCode)
        : const <String>[];
    final apps = _session.offersDirectApps ? draft.directApps : null;
    final colors = context.colorScheme;
    DecorationListItem row(
      Glyph glyph,
      String label,
      String value,
      SetupStep step, {
      required Key key,
      bool warning = false,
    }) => DecorationListItem(
      key: key,
      leading: GlyphIcon(glyph, color: warning ? colors.warning : null),
      title: Text(label),
      subtitle: Text(
        value,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: warning ? TextStyle(color: colors.warning) : null,
      ),
      trailing: const GlyphIcon(AppGlyphs.chevronForward, size: 18),
      onPressed: locked ? null : () => _goTo(step),
    );
    Widget below(Widget child) =>
        Padding(padding: const EdgeInsets.only(top: 28), child: child);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _hero(
          title: l.setupSummaryTitle,
          description: l.setupSummaryDescription,
        ),
        const SizedBox(height: 28),
        AnimatedEntries(
          grouped: true,
          children: [
            row(
              AppGlyphs.profiles,
              l.setupReceiptProfile,
              profile?.realLabel ?? l.setupNoProfile,
              SetupStep.profile,
              warning: profile == null,
              key: const ValueKey('profile'),
            ),
            row(
              _coverageGlyph(draft.coverage),
              l.setupReceiptCoverage,
              _coverageLabel(l, draft.coverage),
              SetupStep.coverage,
              key: const ValueKey('coverage'),
            ),
            row(
              AppGlyphs.locate,
              l.setupReceiptRegion,
              _regionChoiceLabel(l, draft),
              SetupStep.region,
              key: const ValueKey('region'),
            ),
            if (directRules.isNotEmpty)
              row(
                AppGlyphs.split,
                l.setupDirectSection,
                !draft.directRoutes
                    ? l.setupDirectOff
                    : apps != null && apps.isNotEmpty
                    ? '${l.setupDirectOn} · ${l.setupDirectApps(apps.length)}'
                    : l.setupDirectOn,
                SetupStep.region,
                key: const ValueKey('direct'),
              ),
          ],
        ),
        AnimatedReveal(
          visible: profile == null,
          child: below(
            _note(l.setupNoProfileDescription, glyph: AppGlyphs.info),
          ),
        ),
        AnimatedReveal(
          visible: safeMode,
          child: below(_note(l.setupSafeMode, glyph: AppGlyphs.info)),
        ),
        AnimatedReveal(
          visible: draft.coverage == SetupCoverage.local,
          child: below(_localProxy(l)),
        ),
        AnimatedReveal(
          visible: runnable,
          child: below(
            AnimatedEntries(
              grouped: true,
              children: [
                if (!running)
                  DecorationListItem(
                    key: const ValueKey('connect-now'),
                    leading: const GlyphIcon(AppGlyphs.power),
                    title: Text(l.setupConnectNow),
                    subtitle: Text(l.setupConnectNowDescription),
                    trailing: Switch(
                      value: _connectNow,
                      onChanged: locked
                          ? null
                          : (value) => setState(() => _connectNow = value),
                    ),
                    onPressed: locked
                        ? null
                        : () => setState(() => _connectNow = !_connectNow),
                  ),
                DecorationListItem(
                  key: const ValueKey('auto-connect'),
                  leading: const GlyphIcon(AppGlyphs.sparkle),
                  title: Text(l.setupAutoConnect),
                  subtitle: Text(l.setupAutoConnectDescription),
                  trailing: Switch(
                    value: _autoRun,
                    onChanged: locked
                        ? null
                        : (value) => setState(() => _autoRun = value),
                  ),
                  onPressed: locked
                      ? null
                      : () => setState(() => _autoRun = !_autoRun),
                ),
              ],
            ),
          ),
        ),
        below(_note(l.setupFinishDescription)),
      ],
    );
  }

  Widget _localProxy(AppLocalizations l) {
    final port = ref.watch(
      patchClashConfigProvider.select((value) => value.mixedPort),
    );
    final address = 'http://127.0.0.1:$port';
    return CommonCard(
      shape: AppShape.xl,
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      child: Row(
        spacing: 12,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  l.setupLocalTitle,
                  style: AppTextStyle.footnote
                      .of(context)
                      .copyWith(color: context.colorScheme.onSurfaceVariant),
                ),
                SelectableText(
                  address,
                  style: AppTextStyle.headline.of(context),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: l.setupCopyProxy,
            onPressed: () async {
              try {
                await Clipboard.setData(ClipboardData(text: address));
              } catch (error) {
                if (mounted) _session.showError(error);
              }
            },
            icon: const GlyphIcon(AppGlyphs.copy),
          ),
        ],
      ),
    );
  }

  Widget _actions(
    SetupSessionState state,
    AppLocalizations l,
    bool locked, {
    required bool wide,
  }) {
    final draft = state.draft;
    final runnable =
        draft.profileId != null &&
        !ref.watch(safeModeProvider) &&
        !ref.watch(isStartProvider);
    final forwardLabel = _fromSummary
        ? l.setupBackToSummary
        : l.setupLanguageContinue;
    final (label, glyph, onPressed) = switch (state.step) {
      SetupStep.language => (
        l.setupLanguageContinue,
        AppGlyphs.chevronForward,
        _continueFromLanguage,
      ),
      SetupStep.profile when _importing || _hasLink => (
        l.setupProfileAdd,
        AppGlyphs.add,
        _importing ? null : _importLink,
      ),
      SetupStep.profile => (
        draft.profileId == null ? l.setupProfileAdd : forwardLabel,
        draft.profileId == null ? AppGlyphs.add : AppGlyphs.chevronForward,
        draft.profileId == null
            ? null
            : () => _goTo(_following(SetupStep.profile)),
      ),
      SetupStep.coverage => (
        forwardLabel,
        AppGlyphs.chevronForward,
        () => _goTo(_following(SetupStep.coverage)),
      ),
      SetupStep.region => (
        forwardLabel,
        AppGlyphs.chevronForward,
        () => _goTo(_following(SetupStep.region)),
      ),
      SetupStep.summary when runnable && _connectNow => (
        l.setupConnect,
        AppGlyphs.power,
        () => unawaited(
          _transition(() => _session.finish(connect: true, autoRun: _autoRun)),
        ),
      ),
      SetupStep.summary => (
        l.done,
        AppGlyphs.check,
        () => unawaited(
          _transition(() => _session.finish(connect: false, autoRun: _autoRun)),
        ),
      ),
      SetupStep.agreement => (
        _readToEnd ? l.agree : l.disclaimerReadToEnd,
        AppGlyphs.check,
        _readToEnd
            ? () => unawaited(_transition(_session.acceptAgreement))
            : null,
      ),
    };
    final busy = _importing || _saving || state.busy;
    final primary = _PrimaryButton(
      label: label,
      glyph: glyph,
      busy: busy && state.step != SetupStep.language,
      onPressed: locked ? null : onPressed,
    );
    final canGoBack = _previous(state.step) != null;
    return Padding(
      padding: EdgeInsets.only(top: wide ? 16 : 12, bottom: 24),
      child: Row(
        children: [
          _SideReveal(
            visible: canGoBack,
            alignment: AlignmentDirectional.centerStart,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(end: 12),
              child: _BackButton(
                tooltip: l.back,
                onPressed: locked || !canGoBack ? null : _back,
              ),
            ),
          ),
          if (wide) ...[
            const Spacer(),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 240),
              child: primary,
            ),
          ] else
            Expanded(child: primary),
        ],
      ),
    );
  }
}

/// A TV has no camera to scan a code with, and typing a link on a remote takes
/// hundreds of presses, so a phone scans this code and sends the link instead.
class _PhoneLink extends ConsumerStatefulWidget {
  const _PhoneLink({required this.onLink});

  final ValueChanged<String> onLink;

  @override
  ConsumerState<_PhoneLink> createState() => _PhoneLinkState();
}

class _PhoneLinkState extends ConsumerState<_PhoneLink> {
  LinkReceiver? _receiver;
  AppLifecycleListener? _settingsReturn;
  bool _failed = false;
  bool _denied = false;

  @override
  void initState() {
    super.initState();
    unawaited(_listen());
  }

  @override
  void dispose() {
    _settingsReturn?.dispose();
    unawaited(_receiver?.close());
    super.dispose();
  }

  Future<void> _listen() async {
    final permitted = await app?.requestLocalNetworkPermission() ?? true;
    if (!mounted) return;
    if (!permitted) {
      setState(() => _denied = true);
      return;
    }
    final l = currentAppLocalizations;
    final receiver = await LinkReceiver.start(
      (
        title: l.sendFromPhonePageTitle,
        hint: l.sendFromPhonePageHint,
        send: l.send,
        sent: l.sendFromPhonePageSent,
        invalid: l.invalidLinkTip,
      ),
      palette: (
        light: ref.read(genColorSchemeProvider(Brightness.light)),
        dark: ref.read(genColorSchemeProvider(Brightness.dark)),
      ),
    ).catchError((Object _) => null);
    if (!mounted) {
      unawaited(receiver?.close());
      return;
    }
    setState(() {
      _receiver = receiver;
      _denied = false;
      _failed = receiver == null;
    });
    final link = await receiver?.link;
    if (link == null || !mounted) return;
    widget.onLink(link);
    // A receiver takes one link, and the import it starts can still fail.
    unawaited(_listen());
  }

  void _openSettings() {
    _settingsReturn ??= AppLifecycleListener(
      onResume: () {
        _settingsReturn?.dispose();
        _settingsReturn = null;
        unawaited(_listen());
      },
    );
    unawaited(app?.openAppSettings());
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final colors = context.colorScheme;
    final secondary = AppTextStyle.subheadline
        .of(context)
        .copyWith(color: colors.onSurfaceVariant);
    final address = _receiver?.address.toString();
    final title = Text(
      l.sendFromPhone,
      style: AppTextStyle.headline.of(context),
    );
    final Widget content;
    if (_denied || _failed) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6,
        children: [
          title,
          Text(
            _denied
                ? l.sendFromPhonePermissionDenied
                : l.sendFromPhoneNoNetwork,
            style: secondary,
          ),
          if (_denied)
            TextButton(onPressed: _openSettings, child: Text(l.settings)),
        ],
      );
    } else {
      content = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          if (address != null)
            QrCodeView(data: address, size: _phoneCodeSize)
          else
            DecoratedBox(
              decoration: ShapeDecoration(
                color: SurfaceLevel.inset.colorOf(colors),
                shape: AppShape.md,
              ),
              child: SizedBox.square(
                dimension: _phoneCodeSize,
                child: Center(
                  child: GlyphIcon(
                    AppGlyphs.qrCode,
                    size: 40,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6,
              children: [
                title,
                Text(l.sendFromPhoneTip, style: secondary),
                Text(
                  address ?? '',
                  style: AppTextStyle.footnote
                      .of(context)
                      .copyWith(color: colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      );
    }
    return AnimatedSize(
      duration: context.motionDuration(commonDuration),
      curve: Curves.easeInOutCubic,
      alignment: AlignmentDirectional.topStart,
      child: content,
    );
  }
}

/// Fades a scroll view out along its bottom edge, so content passing under
/// the action bar reads as more to scroll rather than cut off, over the page
/// colour and a wallpaper alike.
class _FadedEdge extends StatelessWidget {
  const _FadedEdge({required this.child});

  final Widget child;

  static const _fade = 32.0;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (bounds) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [Colors.white, Colors.white, Colors.transparent],
        stops: [0, 1 - _fade / bounds.height.clamp(_fade, double.infinity), 1],
      ).createShader(bounds),
      child: child,
    );
  }
}

/// Opens a control's place in a row and folds it away, without clipping it: a
/// press swells the control past its own box, which a clip would cut off.
class _SideReveal extends StatelessWidget {
  const _SideReveal({
    required this.visible,
    required this.alignment,
    required this.child,
  });

  final bool visible;
  final AlignmentGeometry alignment;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final duration = context.motionDuration(commonDuration);
    return AnimatedSize(
      duration: duration,
      curve: Curves.easeInOutCubic,
      alignment: alignment,
      clipBehavior: Clip.none,
      child: ExcludeFocus(
        excluding: !visible,
        child: IgnorePointer(
          ignoring: !visible,
          child: AnimatedOpacity(
            opacity: visible ? 1 : 0,
            duration: duration,
            child: Align(
              alignment: alignment,
              widthFactor: visible ? 1 : 0,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// An icon that slides its label out while a pointer hovers it; touch has no
/// hover, so there the icon alone leads to the confirmation.
class _SkipButton extends StatefulWidget {
  const _SkipButton({
    required this.label,
    required this.onPressed,
    this.glyph = AppGlyphs.skip,
  });

  final String label;
  final Glyph glyph;
  final VoidCallback? onPressed;

  @override
  State<_SkipButton> createState() => _SkipButtonState();
}

class _SkipButtonState extends State<_SkipButton> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final enabled = widget.onPressed != null;
    final foreground = enabled
        ? colors.onSurface
        : colors.onSurface.withValues(alpha: 0.38);
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      excludeSemantics: true,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: ElasticPress(
          enabled: enabled,
          child: FocusRing(
            shape: AppShape.full,
            child: Material(
              color: _controlFill(context),
              shape: AppShape.full,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: widget.onPressed,
                onFocusChange: (focused) => setState(() => _focused = focused),
                child: SizedBox(
                  height: 40,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedSize(
                          duration: context.motionDuration(commonDuration),
                          curve: Curves.easeOutCubic,
                          alignment: AlignmentDirectional.centerEnd,
                          child: (_hovered || _focused) && enabled
                              ? Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                    start: 6,
                                    end: 6,
                                  ),
                                  child: Text(
                                    widget.label,
                                    maxLines: 1,
                                    style: AppTextStyle.subheadline
                                        .of(context, emphasized: true)
                                        .copyWith(color: foreground),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        GlyphIcon(widget.glyph, size: 20, color: foreground),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.glyph,
    required this.busy,
    required this.onPressed,
  });

  final String label;
  final Glyph glyph;
  final bool busy;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final enabled = onPressed != null;
    final forward = glyph == AppGlyphs.chevronForward;
    final icon = busy
        ? CommonCircleLoading(size: 20, color: colors.onPrimary)
        : GlyphIcon(glyph, size: 20, fill: 1);
    return ElasticPress(
      enabled: enabled,
      child: AnimatedContainer(
        duration: context.motionDuration(commonDuration),
        decoration: ShapeDecoration(
          shape: AppShape.full,
          shadows: [
            if (enabled)
              BoxShadow(
                color: colors.primary.withValues(alpha: 0.32),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, _actionHeight),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            textStyle: AppTextStyle.headline.of(context),
          ),
          child: AnimatedSwitcher(
            duration: context.motionDuration(commonDuration),
            child: Row(
              key: ValueKey((label, glyph, busy)),
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 10,
              children: [
                if (!forward || busy) icon,
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (forward && !busy) icon,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.tooltip, required this.onPressed});

  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElasticPress(
      enabled: onPressed != null,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: _controlFill(context),
          disabledBackgroundColor: _controlFill(context),
          fixedSize: const Size.square(_actionHeight),
          minimumSize: const Size.square(_actionHeight),
        ),
        icon: const GlyphIcon(AppGlyphs.chevronBack),
      ),
    );
  }
}

class _StepBar extends StatelessWidget {
  const _StepBar({required this.current, required this.unlocked, this.onStep});

  final int current;
  final int unlocked;
  final ValueChanged<SetupStep>? onStep;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final colors = context.colorScheme;
    return Row(
      spacing: 6,
      children: [
        for (final (index, step) in _journey.indexed)
          Expanded(
            child: _StepTap(
              enabled: index != current && index < unlocked && onStep != null,
              onTap: () => onStep?.call(step),
              label: _journeyLabel(l, step),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: AnimatedContainer(
                  duration: context.motionDuration(commonDuration),
                  height: 6,
                  decoration: ShapeDecoration(
                    shape: AppShape.full,
                    color: index <= current || index < unlocked
                        ? colors.primary
                        : colors.brightness == Brightness.dark
                        ? colors.outlineVariant
                        : _controlFill(context),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _StepTap extends StatelessWidget {
  const _StepTap({
    required this.enabled,
    required this.onTap,
    required this.label,
    required this.child,
  });

  final bool enabled;
  final VoidCallback onTap;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: enabled,
      label: label,
      excludeSemantics: true,
      child: Material(
        type: MaterialType.transparency,
        child: FocusRing(
          shape: AppShape.md,
          child: InkWell(
            customBorder: AppShape.md,
            onTap: enabled ? onTap : null,
            child: child,
          ),
        ),
      ),
    );
  }
}

class _SetupReceipt extends ConsumerWidget {
  const _SetupReceipt({
    required this.state,
    required this.unlocked,
    this.onStep,
  });

  final SetupSessionState state;
  final int unlocked;
  final ValueChanged<SetupStep>? onStep;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    final draft = state.draft;
    final profile = ref
        .watch(profilesProvider)
        .getProfile(draft.profileId ?? -1);
    final current = _journeyIndex(state.step) ?? 0;
    bool done(int index) =>
        index != current && index < unlocked && index < _journey.length - 1;
    final values = [
      profile?.realLabel ?? l.setupNoProfile,
      _coverageLabel(l, draft.coverage),
      _regionChoiceLabel(l, draft),
      null,
    ];
    return CommonCard(
      shape: AppShape.xl,
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 4,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
            child: Text(
              l.setupReceipt,
              style: AppTextStyle.headline.of(context),
            ),
          ),
          for (final (index, step) in _journey.indexed)
            _StepTap(
              enabled: index != current && index < unlocked && onStep != null,
              onTap: () => onStep?.call(step),
              label: _journeyLabel(l, step),
              child: _row(
                context,
                number: index + 1,
                label: _journeyLabel(l, step),
                value: done(index) ? values[index] : null,
                current: index == current,
                done: done(index),
              ),
            ),
        ],
      ),
    );
  }

  Widget _row(
    BuildContext context, {
    required int number,
    required String label,
    required String? value,
    required bool current,
    required bool done,
  }) {
    final colors = context.colorScheme;
    final duration = context.motionDuration(commonDuration);
    final marker = AnimatedContainer(
      duration: duration,
      curve: Curves.easeInOutCubic,
      width: 28,
      height: 28,
      decoration: ShapeDecoration(
        shape: AppShape.full,
        color: current
            ? colors.primary
            : done
            ? colors.primaryContainer
            : context.raisedSurfaceLevel.colorOf(colors),
      ),
      child: Center(
        child: AnimatedSwitcher(
          duration: duration,
          child: done
              ? GlyphIcon(
                  AppGlyphs.check,
                  key: const ValueKey('done'),
                  size: 16,
                  color: colors.onPrimaryContainer,
                )
              : Text(
                  MaterialLocalizations.of(context).formatDecimal(number),
                  key: const ValueKey('number'),
                  style: AppTextStyle.caption1
                      .of(context, emphasized: true)
                      .copyWith(
                        color: current
                            ? colors.onPrimary
                            : colors.onSurfaceVariant,
                      ),
                ),
        ),
      ),
    );
    return AnimatedContainer(
      duration: duration,
      curve: Curves.easeInOutCubic,
      decoration: ShapeDecoration(
        shape: AppShape.md,
        color: current
            ? context.raisedSurfaceLevel.colorOf(colors)
            : Colors.transparent,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          spacing: 12,
          children: [
            marker,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyle.subheadline
                        .of(context, emphasized: current)
                        .copyWith(
                          color: current || done
                              ? colors.onSurface
                              : colors.onSurfaceVariant,
                        ),
                  ),
                  AnimatedReveal(
                    visible: value != null,
                    alignment: AlignmentDirectional.topStart,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        value ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.footnote
                            .of(context)
                            .copyWith(color: colors.onSurfaceVariant),
                      ),
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
