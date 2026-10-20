import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/common/regional/region_detection.dart';
import 'package:reclash/common/regional/region_labels.dart';
import 'package:reclash/common/setup_check.dart';
import 'package:reclash/features/form/form.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/providers/setup.dart';
import 'package:reclash/subscriptions/compatibility/clients.dart';
import 'package:reclash/subscriptions/compatibility/policy.dart';
import 'package:reclash/subscriptions/compatibility/settings_form.dart';
import 'package:reclash/subscriptions/transport/transport.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/views/disclaimer.dart';
import 'package:reclash/views/region.dart';

String _coverageLabel(AppLocalizations l, SetupCoverage coverage) =>
    switch (coverage) {
      SetupCoverage.tun => l.setupCoverageAll,
      SetupCoverage.system => l.setupCoverageSystem,
      SetupCoverage.local => l.setupCoverageLocal,
    };

String _phaseLabel(AppLocalizations l, SetupPhase phase) => switch (phase) {
  SetupPhase.core => l.setupPhaseCore,
  SetupPhase.profile => l.setupPhaseProfile,
  SetupPhase.connection => l.setupPhaseConnection,
  SetupPhase.route => l.setupPhaseRoute,
};

class SetupWizard extends ConsumerStatefulWidget {
  const SetupWizard({super.key, this.isAndroid});

  final bool? isAndroid;

  @override
  ConsumerState<SetupWizard> createState() => _SetupWizardState();
}

class _SetupWizardState extends ConsumerState<SetupWizard> {
  final _linkController = TextEditingController();
  final _keyController = TextEditingController();
  late final ScrollController _scrollController;
  bool _importing = false;
  bool _saving = false;
  bool _autoRun = false;
  String? _importError;
  SubscriptionCancellation? _importCancellation;
  SubscriptionClientSettings _clientSettings =
      const SubscriptionClientSettings.forNewProfile();
  Future<Profile?> Function(String key, SubscriptionCancellation cancellation)?
  _encryptedImport;

  bool get _isAndroid => widget.isAndroid ?? system.isAndroid;
  SetupSession get _session => ref.read(setupSessionProvider.notifier);
  bool get _locked =>
      _importing || _saving || ref.read(setupSessionProvider).busy;

  @override
  void initState() {
    super.initState();
    _scrollController = sheetScrollController(context);
    _autoRun = ref.read(appSettingProvider).autoRun;
    final link = ref.read(setupSessionProvider).pendingLink;
    if (link != null) {
      _linkController.text = link;
      scheduleMicrotask(() {
        if (mounted) _session.consumeLink();
      });
    }
  }

  @override
  void dispose() {
    _importCancellation?.cancel();
    _linkController.dispose();
    _keyController.dispose();
    _scrollController.dispose();
    super.dispose();
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
        _encryptedImport = null;
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
    unawaited(
      _import(
        (key, cancellation) => ref
            .read(profilesActionProvider.notifier)
            .importProfileFromLink(
              link,
              ageSecretKey: key,
              select: false,
              clientSettings: clientSettings,
              reviewContext: context,
              cancellation: cancellation,
            ),
      ),
    );
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
        return ref
            .read(profilesActionProvider.notifier)
            .importProfileFromLink(
              link!,
              ageSecretKey: key,
              select: false,
              clientSettings: clientSettings,
              reviewContext: context,
              cancellation: cancellation,
            );
      }),
    );
  }

  void _back(SetupStep step) {
    if (_locked) return;
    final previous = switch (step) {
      SetupStep.language => null,
      SetupStep.agreement => SetupStep.language,
      SetupStep.profile => SetupStep.language,
      SetupStep.coverage => SetupStep.profile,
      SetupStep.checking || SetupStep.result => SetupStep.coverage,
    };
    if (previous != null) unawaited(_transition(() => _session.next(previous)));
  }

  Future<void> _leave() async {
    if (_locked) return;
    if (await _session.persist() && mounted) {
      await ref.read(systemActionProvider.notifier).handleExit();
    }
  }

  Future<void> _check() async {
    if (_locked) return;
    if (ref.read(setupSessionProvider).needsVpnRestart) {
      final consent = await dialogs.showMessage(
        context: context,
        message: TextSpan(
          text: context.appLocalizations.vpnConfigChangeDetected,
        ),
        confirmText: context.appLocalizations.restart,
      );
      if (consent != true || !mounted) return;
      await _session.check(restartVpn: true);
    } else {
      await _session.check();
    }
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
    ref.listen(setupSessionProvider.select((value) => value.pendingLink), (
      _,
      link,
    ) {
      if (link != null) {
        _linkController.text = link;
        _session.consumeLink();
      }
    });
    ref.listen(setupSessionProvider.select((value) => value.step), (_, _) {
      if (_scrollController.hasClients) _scrollController.jumpTo(0);
    });
    final locked = _importing || _saving || state.busy;
    final error = state.saveError ? l.setupSaveError : state.error;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !locked) _back(state.step);
      },
      child: Scaffold(
        backgroundColor: SurfaceLevel.page.colorOf(context.colorScheme),
        body: SafeArea(
          child: Column(
            children: [
              _header(state, l, locked),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ErrorBanner(message: error),
                ),
              Expanded(
                child: state.step == SetupStep.agreement
                    ? DisclaimerView(
                        key: ValueKey(
                          ref.watch(
                            appSettingProvider.select((value) => value.locale),
                          ),
                        ),
                        requireConsent: true,
                        onAgree: () =>
                            unawaited(_transition(_session.acceptAgreement)),
                        onDecline: () => unawaited(_leave()),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final scale =
                              MediaQuery.textScalerOf(
                                context,
                              ).scale(AppTextStyle.subheadline.size) /
                              AppTextStyle.subheadline.size;
                          final wide =
                              constraints.maxWidth >= 940 &&
                              constraints.maxHeight >= 520 * scale;
                          final hasReceipt =
                              state.step.index >= SetupStep.profile.index;
                          if (wide && hasReceipt) {
                            return Align(
                              alignment: Alignment.topCenter,
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 1164,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    spacing: 28,
                                    children: [
                                      Expanded(
                                        child: SingleChildScrollView(
                                          controller: _scrollController,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 24,
                                          ),
                                          child: _body(state, l, locked),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 300,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 24,
                                          ),
                                          child: _SetupReceipt(state: state),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  controller: _scrollController,
                                  padding: const EdgeInsets.all(16),
                                  child: Center(
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            state.step == SetupStep.language
                                            ? 640
                                            : 760,
                                      ),
                                      child: _body(state, l, locked),
                                    ),
                                  ),
                                ),
                              ),
                              if (hasReceipt)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    8,
                                    16,
                                    12,
                                  ),
                                  child: Center(
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 760,
                                      ),
                                      child: _SetupReceipt(
                                        state: state,
                                        compact: true,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
              ),
              if (state.step != SetupStep.agreement) _actions(state, l, locked),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(SetupSessionState state, AppLocalizations l, bool locked) {
    final sequence = state.step.index;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        spacing: 12,
        children: [
          if (sequence > 0)
            IconButton(
              tooltip: l.back,
              onPressed: locked ? null : () => _back(state.step),
              icon: const GlyphIcon(AppGlyphs.chevronBack),
            )
          else
            Image.asset('assets/images/icon.png', width: 28, height: 28),
          Expanded(
            child: Text(l.setupTitle, style: AppTextStyle.headline.of(context)),
          ),
          if (sequence >= SetupStep.profile.index)
            Text(
              l.setupStepStatus(sequence - 1, 4),
              style: AppTextStyle.caption1
                  .of(context)
                  .copyWith(color: context.colorScheme.onSurfaceVariant),
            ),
          IconButton(
            tooltip: l.exit,
            onPressed: locked ? null : () => unawaited(_leave()),
            icon: const GlyphIcon(AppGlyphs.close),
          ),
        ],
      ),
    );
  }

  Widget _hero({
    required Glyph glyph,
    required String title,
    required String description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Row(
          spacing: 14,
          children: [
            CommonCard(
              padding: const EdgeInsets.all(12),
              shape: AppShape.md,
              child: GlyphIcon(
                glyph,
                size: 24,
                color: context.colorScheme.primary,
              ),
            ),
            Expanded(
              child: Text(
                title,
                style: AppTextStyle.title1.of(context, emphasized: true),
              ),
            ),
          ],
        ),
        Text(
          description,
          style: AppTextStyle.subheadline
              .of(context)
              .copyWith(color: context.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _body(SetupSessionState state, AppLocalizations l, bool locked) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 24,
      children: [
        switch (state.step) {
          SetupStep.language => _language(l, locked),
          SetupStep.profile => _profile(state, l, locked),
          SetupStep.coverage => _coverage(state, l, locked),
          SetupStep.checking => _checking(state, l),
          SetupStep.result => _result(state, l, locked),
          SetupStep.agreement => const SizedBox.shrink(),
        },
      ],
    );
  }

  Widget _language(AppLocalizations l, bool locked) {
    final locale = getLocaleForString(
      ref.watch(appSettingProvider.select((value) => value.locale)),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 24,
      children: [
        _hero(
          glyph: AppGlyphs.language,
          title: l.setupLanguageTitle,
          description: l.setupLanguageDescription,
        ),
        generateSection(
          items: [
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
                    : () => unawaited(
                        _session.selectLanguage(option?.toString()),
                      ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _profile(SetupSessionState state, AppLocalizations l, bool locked) {
    final profiles = ref.watch(profilesProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 24,
      children: [
        _hero(
          glyph: AppGlyphs.profiles,
          title: l.setupProfileTitle,
          description: l.setupProfileDescription,
        ),
        if (profiles.isNotEmpty)
          generateSection(
            title: l.setupProfileCount(profiles.length),
            items: [
              for (final profile in profiles)
                DecorationListItem(
                  leading: const GlyphIcon(AppGlyphs.profiles),
                  title: Text(profile.realLabel),
                  subtitle: profile.id == state.draft.profileId
                      ? Text(l.setupProfileReady)
                      : null,
                  isSelected: profile.id == state.draft.profileId,
                  trailing: profile.id == state.draft.profileId
                      ? const SelectionCheck()
                      : null,
                  onPressed: locked
                      ? null
                      : () => _session.selectProfile(profile.id),
                ),
            ],
          ),
        if (_importError != null) ErrorBanner(message: _importError),
        CommonCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              Text(
                l.setupProfileImport,
                style: AppTextStyle.headline.of(context),
              ),
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
              ExcludeFocus(
                excluding: locked,
                child: IgnorePointer(
                  ignoring: locked,
                  child: SubscriptionClientSettingsSection(
                    initial: _clientSettings,
                    onChanged: (value) =>
                        setState(() => _clientSettings = value),
                    onFormChanged: () {},
                  ),
                ),
              ),
              OverflowBar(
                alignment: MainAxisAlignment.start,
                spacing: 12,
                overflowSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: locked ? null : _importLink,
                    icon: _importing
                        ? const CommonCircleLoading(size: 18)
                        : const GlyphIcon(AppGlyphs.link, fill: 1, size: 18),
                    label: Text(l.import),
                  ),
                  TextButton.icon(
                    onPressed: locked ? null : _importFile,
                    icon: const GlyphIcon(AppGlyphs.importFile, size: 18),
                    label: Text(l.file),
                  ),
                  TextButton.icon(
                    onPressed: locked ? null : _importQr,
                    icon: const GlyphIcon(AppGlyphs.qrCode, size: 18),
                    label: Text(l.qrcode),
                  ),
                  if (_importing)
                    TextButton(onPressed: _cancelImport, child: Text(l.cancel)),
                ],
              ),
              if (_encryptedImport != null) ...[
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
                  onPressed: locked
                      ? null
                      : () => unawaited(_import(_encryptedImport!)),
                  child: Text(l.setupLanguageContinue),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _chooseRegion({String? suggestedRegionCode}) async {
    await showFormSheet<void>(
      context: context,
      builder: (sheetContext) => RegionView(
        isAndroid: _isAndroid,
        initialRegionCode:
            suggestedRegionCode ??
            ref.read(setupSessionProvider).draft.regionCode,
        onApply: (code) {
          _session.selectRegion(code);
          Navigator.of(sheetContext).pop();
        },
      ),
    );
  }

  Widget _coverage(SetupSessionState state, AppLocalizations l, bool locked) {
    final detected = ref.watch(detectedRegionProvider);
    final draft = state.draft;
    final options = _isAndroid
        ? const [SetupCoverage.tun, SetupCoverage.local]
        : SetupCoverage.values;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 24,
      children: [
        _hero(
          glyph: AppGlyphs.devices,
          title: l.setupCoverageTitle,
          description: l.setupCoverageDescription,
        ),
        generateSection(
          items: [
            for (final coverage in options)
              DecorationListItem(
                leading: GlyphIcon(switch (coverage) {
                  SetupCoverage.tun => AppGlyphs.vpn,
                  SetupCoverage.system => AppGlyphs.devices,
                  SetupCoverage.local => AppGlyphs.link,
                }),
                title: Text(_coverageLabel(l, coverage)),
                subtitle: Text(switch (coverage) {
                  SetupCoverage.tun =>
                    _isAndroid
                        ? l.setupCoverageAndroidDescription
                        : l.setupCoverageAllDescription,
                  SetupCoverage.system => l.setupCoverageSystemDescription,
                  SetupCoverage.local => l.setupCoverageLocalDescription,
                }),
                isSelected: coverage == draft.coverage,
                trailing: coverage == draft.coverage
                    ? const SelectionCheck()
                    : null,
                onPressed: locked
                    ? null
                    : () => _session.selectCoverage(coverage),
              ),
          ],
          footer: l.setupCoverageNote,
        ),
        generateSection(
          title: l.appRegion,
          items: [
            DecorationListItem(
              leading: const GlyphIcon(AppGlyphs.language),
              title: Text(l.regionChoose),
              subtitle: Text(regionLabel(l, draft.regionCode)),
              trailing: const GlyphIcon(AppGlyphs.chevronForward, size: 18),
              onPressed: locked ? null : () => unawaited(_chooseRegion()),
            ),
          ],
          footer: l.regionCustomPreserved,
        ),
        if (!draft.regionChosen && detected.value != null)
          CommonCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                Text(
                  l.regionDetected(
                    regionLabel(l, detected.value!.countryCode),
                    switch (detected.value!.source) {
                      RegionDetectionSource.timeZone => l.regionSourceTimeZone,
                      RegionDetectionSource.localeCountry =>
                        l.regionSourceLocaleCountry,
                      RegionDetectionSource.localeLanguage =>
                        l.regionSourceLocaleLanguage,
                    },
                  ),
                  style: AppTextStyle.headline.of(context),
                ),
                Text(
                  l.setupRegionDescription,
                  style: AppTextStyle.subheadline.of(context),
                ),
                OverflowBar(
                  spacing: 12,
                  overflowSpacing: 8,
                  children: [
                    TextButton(
                      onPressed: locked
                          ? null
                          : () => _session.selectRegion(null),
                      child: Text(l.setupRegionNeutral),
                    ),
                    FilledButton(
                      onPressed: locked
                          ? null
                          : () => unawaited(
                              _chooseRegion(
                                suggestedRegionCode:
                                    detected.value!.countryCode,
                              ),
                            ),
                      child: Text(l.regionPreviewTitle),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _checking(SetupSessionState state, AppLocalizations l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 24,
      children: [
        _hero(
          glyph: AppGlyphs.target,
          title: l.setupCheckingTitle,
          description: l.setupCheckingDescription,
        ),
        _SetupPhases(phases: state.phases),
        Text(
          l.setupCheckLimit,
          style: AppTextStyle.footnote
              .of(context)
              .copyWith(color: context.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _result(SetupSessionState state, AppLocalizations l, bool locked) {
    final report =
        state.report ?? const SetupReport(verdict: SetupVerdict.unconfirmed);
    final title = switch (report.verdict) {
      SetupVerdict.connected => l.setupConnectedTitle,
      SetupVerdict.partial => l.setupPartialTitle,
      SetupVerdict.local => l.setupLocalTitle,
      SetupVerdict.saved || SetupVerdict.safeMode => l.setupSavedTitle,
      SetupVerdict.stopped => l.setupStoppedTitle,
      SetupVerdict.permission => l.setupPermissionTitle,
      SetupVerdict.stale || SetupVerdict.unconfirmed => l.setupUnconfirmedTitle,
      SetupVerdict.failed => l.setupFailedTitle,
    };
    final description = switch (report.verdict) {
      SetupVerdict.connected => l.setupConnectedDescription,
      SetupVerdict.partial => l.setupPartialDescription,
      SetupVerdict.local => l.setupLocalDescription,
      SetupVerdict.saved => l.setupSavedDescription,
      SetupVerdict.safeMode => l.setupSafeMode,
      SetupVerdict.stopped => l.setupStoppedDescription,
      SetupVerdict.permission => l.setupPermissionDescription,
      SetupVerdict.stale => l.setupRouteChanged,
      SetupVerdict.unconfirmed => l.setupUnconfirmedDescription,
      SetupVerdict.failed => l.setupUnknownError,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 24,
      children: [
        _hero(
          glyph: report.confirmed
              ? AppGlyphs.check
              : switch (report.verdict) {
                  SetupVerdict.saved ||
                  SetupVerdict.safeMode => AppGlyphs.clock,
                  SetupVerdict.permission => AppGlyphs.vpn,
                  _ => AppGlyphs.info,
                },
          title: title,
          description: description,
        ),
        if (report.confirmed)
          CommonCard(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                GlyphIcon(
                  AppGlyphs.check,
                  size: 28,
                  color: context.colorScheme.success,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      Text(
                        l.setupConfirmed,
                        style: AppTextStyle.headline.of(context),
                      ),
                      if (report.chains.isNotEmpty)
                        Text(
                          report.chains.reversed.join(' › '),
                          style: AppTextStyle.subheadline.of(context),
                        ),
                      if (report.delay != null && report.delay! > 0)
                        Text(
                          '${report.delay} ms',
                          style: AppTextStyle.title2.of(context),
                        ),
                      Text(
                        l.setupCheckLimit,
                        style: AppTextStyle.footnote
                            .of(context)
                            .copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        if (report.verdict == SetupVerdict.local) _localProxy(l),
        if (report.confirmed)
          generateSection(
            items: [
              DecorationListItem(
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
        if (report.error != null)
          CommonCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Text(
                  l.setupErrorDetails,
                  style: AppTextStyle.headline.of(context),
                ),
                SelectableText(
                  report.error!,
                  style: AppTextStyle.footnote.of(context),
                ),
              ],
            ),
          ),
        if (report.phases.isNotEmpty) _SetupPhases(phases: report.phases),
        Text(
          l.setupFinishDescription,
          style: AppTextStyle.footnote
              .of(context)
              .copyWith(color: context.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _localProxy(AppLocalizations l) {
    final port = ref.watch(
      patchClashConfigProvider.select((value) => value.mixedPort),
    );
    final address = 'http://127.0.0.1:$port';
    return CommonCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          SelectableText(address, style: AppTextStyle.title3.of(context)),
          TextButton.icon(
            onPressed: () async {
              try {
                await Clipboard.setData(ClipboardData(text: address));
              } catch (error) {
                if (mounted) _session.showError(error);
              }
            },
            icon: const GlyphIcon(AppGlyphs.copy, size: 18),
            label: Text(l.setupCopyProxy),
          ),
        ],
      ),
    );
  }

  Widget _actions(SetupSessionState state, AppLocalizations l, bool locked) {
    final report = state.report;
    final isResult = state.step == SetupStep.result;
    final canFinish = isResult && report != null;
    final saved = report?.verdict == SetupVerdict.saved;
    final primaryLabel = switch (state.step) {
      SetupStep.language || SetupStep.profile => l.setupLanguageContinue,
      SetupStep.coverage => l.setupCheckAction,
      SetupStep.checking => l.cancel,
      SetupStep.result =>
        report?.confirmed == true || saved ? l.done : l.setupRepeat,
      SetupStep.agreement => l.agree,
    };
    void primary() {
      switch (state.step) {
        case SetupStep.language:
          final accepted =
              ref.read(appSettingProvider).acceptedDisclaimerVersion >=
              disclaimerVersion;
          unawaited(
            _transition(
              () => _session.next(
                accepted ? SetupStep.profile : SetupStep.agreement,
              ),
            ),
          );
        case SetupStep.profile:
          unawaited(_transition(() => _session.next(SetupStep.coverage)));
        case SetupStep.coverage:
          unawaited(_check());
        case SetupStep.checking:
          _session.cancelCheck();
        case SetupStep.result:
          if (report?.confirmed == true || saved) {
            unawaited(_transition(() => _session.finish(autoRun: _autoRun)));
          } else {
            unawaited(_check());
          }
        case SetupStep.agreement:
          break;
      }
    }

    final primaryDisabled =
        state.step != SetupStep.checking &&
        (locked ||
            (state.step == SetupStep.profile && state.draft.profileId == null));
    final secondaryActions = <Widget>[
      if (state.step == SetupStep.profile ||
          state.step == SetupStep.coverage ||
          (canFinish && !saved && !report.confirmed))
        TextButton(
          onPressed: locked
              ? null
              : () => unawaited(_transition(_session.saveWithoutConnection)),
          child: Text(
            state.step == SetupStep.profile
                ? l.setupProfileSkip
                : l.setupSaveWithoutConnection,
          ),
        ),
      if (isResult && report?.confirmed == true)
        TextButton(
          onPressed: locked ? null : () => unawaited(_check()),
          child: Text(l.setupRepeat),
        ),
      if (isResult && !saved && report?.confirmed != true)
        TextButton(
          onPressed: locked ? null : () => _back(state.step),
          child: Text(l.back),
        ),
    ];
    final primaryAction = FilledButton.icon(
      onPressed: primaryDisabled ? null : primary,
      icon: _saving
          ? const CommonCircleLoading(size: 18)
          : GlyphIcon(
              state.step == SetupStep.checking
                  ? AppGlyphs.close
                  : canFinish && (report.confirmed || saved)
                  ? AppGlyphs.check
                  : AppGlyphs.chevronForward,
              size: 18,
              fill: 1,
            ),
      label: Text(primaryLabel),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: LayoutBuilder(
                builder: (context, constraints) => constraints.maxWidth < 600
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: 8,
                        children: [
                          primaryAction,
                          if (secondaryActions.isNotEmpty)
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 12,
                              runSpacing: 4,
                              children: secondaryActions,
                            ),
                        ],
                      )
                    : OverflowBar(
                        alignment: MainAxisAlignment.end,
                        spacing: 12,
                        overflowSpacing: 8,
                        children: [...secondaryActions, primaryAction],
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SetupPhases extends StatelessWidget {
  const _SetupPhases({required this.phases});

  final List<SetupPhaseResult> phases;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final completed = phases
        .where(
          (phase) =>
              phase.status != SetupPhaseStatus.waiting &&
              phase.status != SetupPhaseStatus.running,
        )
        .length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Row(
          spacing: 12,
          children: [
            Expanded(
              child: Text(
                l.setupReport,
                style: AppTextStyle.headline.of(context),
              ),
            ),
            Text(
              l.setupStepStatus(completed, phases.length),
              style: AppTextStyle.caption1
                  .of(context)
                  .copyWith(color: context.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        if (phases.isNotEmpty)
          LinearProgressIndicator(
            value: completed / phases.length,
            minHeight: 4,
          ),
        generateSection(
          items: [
            for (final phase in phases)
              DecorationListItem(
                leading: CommonCard(
                  shape: AppShape.full,
                  padding: const EdgeInsets.all(8),
                  child: phase.status == SetupPhaseStatus.running
                      ? const CommonCircleLoading(size: 20)
                      : GlyphIcon(
                          switch (phase.status) {
                            SetupPhaseStatus.confirmed => AppGlyphs.check,
                            SetupPhaseStatus.failed => AppGlyphs.error,
                            SetupPhaseStatus.unconfirmed => AppGlyphs.info,
                            SetupPhaseStatus.waiting ||
                            SetupPhaseStatus.skipped ||
                            SetupPhaseStatus.running => AppGlyphs.clock,
                          },
                          size: 20,
                          color: switch (phase.status) {
                            SetupPhaseStatus.confirmed =>
                              context.colorScheme.success,
                            SetupPhaseStatus.failed =>
                              context.colorScheme.error,
                            SetupPhaseStatus.unconfirmed =>
                              context.colorScheme.warning,
                            _ => context.colorScheme.onSurfaceVariant,
                          },
                        ),
                ),
                title: Text(_phaseLabel(l, phase.phase)),
                subtitle: Text(
                  switch (phase.status) {
                    SetupPhaseStatus.confirmed => l.setupConfirmed,
                    SetupPhaseStatus.failed ||
                    SetupPhaseStatus.unconfirmed => l.setupUnavailable,
                    SetupPhaseStatus.running => l.connecting,
                    SetupPhaseStatus.waiting ||
                    SetupPhaseStatus.skipped => l.setupNotChecked,
                  },
                  style: AppTextStyle.footnote
                      .of(context)
                      .copyWith(
                        color: phase.status == SetupPhaseStatus.running
                            ? context.colorScheme.primary
                            : context.colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _SetupReceipt extends ConsumerWidget {
  const _SetupReceipt({required this.state, this.compact = false});

  final SetupSessionState state;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    final profile = ref
        .watch(profilesProvider)
        .getProfile(state.draft.profileId ?? -1);
    final report = state.report;
    final checkValue = state.checking
        ? l.connecting
        : switch (report?.verdict) {
            SetupVerdict.connected || SetupVerdict.partial => l.setupConfirmed,
            SetupVerdict.local => l.setupLocalTitle,
            SetupVerdict.saved || SetupVerdict.safeMode => l.setupSavedTitle,
            SetupVerdict.stopped => l.setupStoppedTitle,
            SetupVerdict.permission => l.setupPermissionTitle,
            SetupVerdict.failed => l.setupFailedTitle,
            SetupVerdict.stale ||
            SetupVerdict.unconfirmed => l.setupUnconfirmedTitle,
            null => l.setupNotChecked,
          };
    final checkColor = report?.confirmed == true
        ? context.colorScheme.success
        : switch (report?.verdict) {
            SetupVerdict.failed => context.colorScheme.error,
            SetupVerdict.permission ||
            SetupVerdict.unconfirmed ||
            SetupVerdict.stale => context.colorScheme.warning,
            _ => context.colorScheme.onSurfaceVariant,
          };
    final progress = switch (state.step) {
      SetupStep.language || SetupStep.agreement || SetupStep.profile => 1,
      SetupStep.coverage => 2,
      SetupStep.checking || SetupStep.result => 3,
    };
    if (compact) {
      return CommonCard(
        shape: AppShape.xl,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        onPressed: () => unawaited(
          showSheet<void>(
            context: context,
            builder: (sheetContext) => Consumer(
              builder: (context, ref, _) => CommonScaffold(
                title: context.appLocalizations.setupReceipt,
                body: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ).copyWith(top: context.appBarInset, bottom: 20),
                  child: _SetupReceipt(state: ref.watch(setupSessionProvider)),
                ),
              ),
            ),
          ),
        ),
        child: Row(
          spacing: 12,
          children: [
            GlyphIcon(
              AppGlyphs.link,
              size: 20,
              color: context.colorScheme.onSurfaceVariant,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Text(
                    l.setupReceipt,
                    style: AppTextStyle.subheadline.of(
                      context,
                      emphasized: true,
                    ),
                  ),
                  Text(
                    profile?.realLabel ?? l.none,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.caption1
                        .of(context)
                        .copyWith(color: context.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Text(
              l.setupStepStatus(progress, 3),
              style: AppTextStyle.caption1
                  .of(context)
                  .copyWith(color: context.colorScheme.onSurfaceVariant),
            ),
            const GlyphIcon(AppGlyphs.chevronUp, size: 18),
          ],
        ),
      );
    }
    return CommonCard(
      shape: AppShape.xl,
      padding: const EdgeInsets.all(16),
      child: Builder(
        builder: (context) {
          final rows = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 4,
            children: [
              _step(
                context,
                number: 1,
                label: l.setupReceiptProfile,
                value: profile?.realLabel ?? l.none,
                current: state.step == SetupStep.profile,
                done: profile != null,
              ),
              _step(
                context,
                number: 2,
                label: l.setupReceiptCoverage,
                value: _coverageLabel(l, state.draft.coverage),
                current: state.step == SetupStep.coverage,
                done: state.step.index > SetupStep.coverage.index,
              ),
              _step(
                context,
                number: 3,
                label: l.setupReceiptCheck,
                value: checkValue,
                current: state.step.index >= SetupStep.checking.index,
                done: report?.confirmed == true,
                running: state.checking,
                statusColor: checkColor,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1),
              ),
              _fact(
                context,
                AppGlyphs.language,
                l.appRegion,
                regionLabel(l, state.draft.regionCode),
              ),
              if (report?.confirmed == true && report!.chains.isNotEmpty)
                _fact(
                  context,
                  AppGlyphs.target,
                  l.server,
                  report.chains.reversed.join(' › '),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 14, 12, 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    GlyphIcon(
                      AppGlyphs.settings,
                      size: 16,
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                    Expanded(
                      child: Text(
                        l.setupFinishDescription,
                        style: AppTextStyle.caption1
                            .of(context)
                            .copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
          final title = Row(
            spacing: 10,
            children: [
              GlyphIcon(
                AppGlyphs.link,
                size: 20,
                color: context.colorScheme.onSurfaceVariant,
              ),
              Expanded(
                child: Text(
                  l.setupReceipt,
                  style: AppTextStyle.headline.of(context),
                ),
              ),
              Text(
                l.setupStepStatus(progress, 3),
                style: AppTextStyle.caption1
                    .of(context)
                    .copyWith(color: context.colorScheme.onSurfaceVariant),
              ),
            ],
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [title, rows],
          );
        },
      ),
    );
  }

  Widget _step(
    BuildContext context, {
    required int number,
    required String label,
    required String value,
    required bool current,
    required bool done,
    bool running = false,
    Color? statusColor,
  }) {
    Widget content(BuildContext context) {
      final color = statusColor ?? context.colorScheme.primary;
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Material(
            shape: AppShape.full,
            color: current && !done && statusColor == null
                ? context.colorScheme.primary
                : context.raisedSurfaceLevel.colorOf(context.colorScheme),
            child: SizedBox.square(
              dimension: 28,
              child: Center(
                child: running
                    ? const CommonCircleLoading(size: 18)
                    : done
                    ? GlyphIcon(AppGlyphs.check, size: 16, color: color)
                    : Text(
                        MaterialLocalizations.of(context).formatDecimal(number),
                        style: AppTextStyle.caption1
                            .of(context, emphasized: true)
                            .copyWith(
                              color: current && statusColor == null
                                  ? context.colorScheme.onPrimary
                                  : context.colorScheme.onSurfaceVariant,
                            ),
                      ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text(
                  label,
                  style: AppTextStyle.caption1
                      .of(context)
                      .copyWith(color: context.colorScheme.onSurfaceVariant),
                ),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.subheadline
                      .of(context, emphasized: true)
                      .copyWith(color: statusColor),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return current
        ? CommonCard(
            shape: AppShape.md,
            padding: const EdgeInsets.all(12),
            child: Builder(builder: content),
          )
        : Padding(padding: const EdgeInsets.all(12), child: content(context));
  }

  Widget _fact(BuildContext context, Glyph glyph, String label, String value) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            GlyphIcon(
              glyph,
              size: 16,
              color: context.colorScheme.onSurfaceVariant,
            ),
            Text(
              label,
              style: AppTextStyle.caption1
                  .of(context)
                  .copyWith(color: context.colorScheme.onSurfaceVariant),
            ),
            Expanded(
              child: Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: AppTextStyle.footnote.of(context),
              ),
            ),
          ],
        ),
      );
}
