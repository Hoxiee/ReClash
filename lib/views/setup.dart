import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/common/regional/country_profile.dart';
import 'package:reclash/common/regional/region_labels.dart';
import 'package:reclash/common/setup_check.dart';
import 'package:reclash/features/doctor/path.dart';
import 'package:reclash/features/form/form.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/providers/setup.dart';
import 'package:reclash/subscriptions/compatibility/clients.dart';
import 'package:reclash/subscriptions/compatibility/policy.dart';
import 'package:reclash/subscriptions/compatibility/settings_form.dart';
import 'package:reclash/subscriptions/transport/transport.dart';
import 'package:reclash/ui/code_label.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/views/disclaimer.dart';
import 'package:reclash/views/doctor/path.dart';
import 'package:reclash/views/region.dart';

const _regionOptions = ['RU', 'IR', 'CN', 'EG', otherRegionCode];

/// The numbered part of the wizard; language and consent come before it.
const _journey = [
  SetupStep.profile,
  SetupStep.coverage,
  SetupStep.region,
  SetupStep.checking,
];

int? _journeyIndex(SetupStep step) => switch (step) {
  SetupStep.language || SetupStep.agreement => null,
  SetupStep.profile => 0,
  SetupStep.coverage => 1,
  SetupStep.region => 2,
  SetupStep.checking || SetupStep.result => 3,
};

String _journeyLabel(AppLocalizations l, SetupStep step) => switch (step) {
  SetupStep.coverage => l.setupReceiptCoverage,
  SetupStep.region => l.setupReceiptRegion,
  SetupStep.checking || SetupStep.result => l.setupReceiptCheck,
  _ => l.setupReceiptProfile,
};

String _coverageLabel(AppLocalizations l, SetupCoverage coverage) =>
    switch (coverage) {
      SetupCoverage.tun => l.setupCoverageAll,
      SetupCoverage.system => l.setupCoverageSystem,
      SetupCoverage.local => l.setupCoverageLocal,
    };

String _regionChoiceLabel(AppLocalizations l, SetupDraft draft) =>
    !draft.regionChosen
    ? l.regionNotSet
    : draft.regionCode == null
    ? l.setupRegionNeutral
    : regionLabel(l, draft.regionCode);

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
    var imported = false;
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
        imported = true;
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
    if (imported &&
        mounted &&
        ref.read(setupSessionProvider).step == SetupStep.profile) {
      await _transition(() => _session.next(SetupStep.coverage));
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

  Future<void> _pasteLink() async {
    try {
      final text = (await Clipboard.getData(Clipboard.kTextPlain))?.text;
      if (text == null || !mounted) return;
      _linkController.text = text.trim();
      setState(() => _importError = null);
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

  SetupStep? _previous(SetupSessionState state) => switch (state.step) {
    SetupStep.language => null,
    SetupStep.agreement || SetupStep.profile => SetupStep.language,
    SetupStep.coverage => SetupStep.profile,
    SetupStep.region => SetupStep.coverage,
    SetupStep.checking => SetupStep.region,
    SetupStep.result =>
      state.draft.profileId == null ? SetupStep.profile : SetupStep.region,
  };

  void _goTo(SetupStep target) {
    final state = ref.read(setupSessionProvider);
    if (state.checking) {
      _session.cancelCheck();
    } else if (_locked) {
      return;
    }
    unawaited(_transition(() => _session.next(target)));
  }

  void _back() {
    final previous = _previous(ref.read(setupSessionProvider));
    if (previous != null) _goTo(previous);
  }

  Future<void> _leave({bool confirm = true}) async {
    if (_locked) return;
    if (confirm) {
      final l = context.appLocalizations;
      final leave = await dialogs.showMessage(
        context: sheetNavigatorOf(context).context,
        title: l.setupLeaveTitle,
        message: TextSpan(text: l.setupLeaveMessage),
        confirmText: l.exit,
        destructive: true,
      );
      if (leave != true || !mounted || _locked) return;
    }
    if (await _session.persist() && mounted) {
      await ref.read(systemActionProvider.notifier).handleExit();
    }
  }

  Future<void> _check() async {
    if (_locked) return;
    if (ref.read(setupSessionProvider).needsVpnRestart) {
      final consent = await dialogs.showMessage(
        context: sheetNavigatorOf(context).context,
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
        if (!didPop && (state.checking || !locked)) _back();
      },
      child: Scaffold(
        backgroundColor: SurfaceLevel.page.colorOf(context.colorScheme),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final scale =
                  MediaQuery.textScalerOf(
                    context,
                  ).scale(AppTextStyle.subheadline.size) /
                  AppTextStyle.subheadline.size;
              final journey = _journeyIndex(state.step) != null;
              final wide =
                  journey &&
                  constraints.maxWidth >= 940 &&
                  constraints.maxHeight >= 520 * scale;
              final contentWidth = wide
                  ? 1100.0
                  : state.step == SetupStep.language
                  ? 640.0
                  : 760.0;
              return Column(
                children: [
                  _header(state, l, locked, stepBar: journey && !wide),
                  AnimatedReveal(
                    visible: error != null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ErrorBanner(message: error ?? ''),
                    ),
                  ),
                  Expanded(
                    child: state.step == SetupStep.agreement
                        ? DisclaimerView(
                            key: ValueKey(
                              ref.watch(
                                appSettingProvider.select(
                                  (value) => value.locale,
                                ),
                              ),
                            ),
                            requireConsent: true,
                            onAgree: () => unawaited(
                              _transition(_session.acceptAgreement),
                            ),
                            onDecline: () => unawaited(_leave(confirm: false)),
                          )
                        : wide
                        ? _wideBody(state, l, locked)
                        : SingleChildScrollView(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: contentWidth,
                                ),
                                child: _body(state, l, locked),
                              ),
                            ),
                          ),
                  ),
                  if (state.step != SetupStep.agreement)
                    _actions(state, l, locked, maxWidth: contentWidth),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _wideBody(SetupSessionState state, AppLocalizations l, bool locked) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1164),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 28,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: _body(state, l, locked),
                ),
              ),
              SizedBox(
                width: 300,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: _SetupReceipt(
                    state: state,
                    onStep: locked && !state.checking ? null : _goTo,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(
    SetupSessionState state,
    AppLocalizations l,
    bool locked, {
    required bool stepBar,
  }) {
    final canGoBack = state.step != SetupStep.language;
    final backEnabled = state.checking || !locked;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          Row(
            spacing: 12,
            children: [
              if (canGoBack)
                IconButton(
                  tooltip: l.back,
                  onPressed: backEnabled ? _back : null,
                  icon: const GlyphIcon(AppGlyphs.chevronBack),
                )
              else
                Image.asset('assets/images/icon.png', width: 28, height: 28),
              Expanded(
                child: Text(
                  l.setupTitle,
                  style: AppTextStyle.headline.of(context),
                ),
              ),
              if (stepBar)
                IconButton(
                  tooltip: l.setupReceipt,
                  onPressed: _showReceipt,
                  icon: const GlyphIcon(AppGlyphs.link),
                ),
              IconButton(
                tooltip: l.exit,
                onPressed: locked ? null : () => unawaited(_leave()),
                icon: const GlyphIcon(AppGlyphs.close),
              ),
            ],
          ),
          if (stepBar)
            _StepBar(
              current: _journeyIndex(state.step)!,
              onStep: locked && !state.checking ? null : _goTo,
            ),
        ],
      ),
    );
  }

  void _showReceipt() => unawaited(
    showSheet<void>(
      context: context,
      builder: (sheetContext) => Consumer(
        builder: (context, ref, _) {
          final state = ref.watch(setupSessionProvider);
          final locked = _importing || _saving || state.busy;
          return CommonScaffold(
            title: context.appLocalizations.setupReceipt,
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ).copyWith(top: context.appBarInset, bottom: 20),
              child: _SetupReceipt(
                state: state,
                onStep: locked && !state.checking
                    ? null
                    : (step) {
                        Navigator.of(sheetContext).pop();
                        _goTo(step);
                      },
              ),
            ),
          );
        },
      ),
    ),
  );

  Widget _hero({
    required Glyph glyph,
    required String title,
    required String description,
    Color? color,
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
                color: color ?? context.colorScheme.primary,
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

  Widget _note(String text) => Text(
    text,
    style: AppTextStyle.footnote
        .of(context)
        .copyWith(color: context.colorScheme.onSurfaceVariant),
  );

  Widget _optionTitle(String title, {bool recommended = false}) {
    if (!recommended) return Text(title);
    return Wrap(
      spacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(title),
        Text(
          context.appLocalizations.setupRecommended,
          style: AppTextStyle.caption1
              .of(context, emphasized: true)
              .copyWith(color: context.colorScheme.primary),
        ),
      ],
    );
  }

  Widget _body(SetupSessionState state, AppLocalizations l, bool locked) {
    return switch (state.step) {
      SetupStep.language => _language(l, locked),
      SetupStep.profile => _profile(state, l, locked),
      SetupStep.coverage => _coverage(state, l, locked),
      SetupStep.region => _region(state, l, locked),
      SetupStep.checking => _checking(state, l),
      SetupStep.result => _result(state, l, locked),
      SetupStep.agreement => const SizedBox.shrink(),
    };
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AnimatedReveal(
              visible: _importError != null,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: ErrorBanner(message: _importError ?? ''),
              ),
            ),
            CommonCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      Text(
                        profiles.isEmpty
                            ? l.setupProfileImport
                            : l.setupProfileImportAnother,
                        style: AppTextStyle.headline.of(context),
                      ),
                      _note(l.setupProfileImportHint),
                    ],
                  ),
                  FilledInputTheme(
                    child: TextField(
                      controller: _linkController,
                      enabled: !locked,
                      autocorrect: false,
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.go,
                      onSubmitted: (_) => _importLink(),
                      decoration: InputDecoration(
                        hintText: l.setupProfileLinkHint,
                        suffixIcon: IconButton(
                          tooltip: l.paste,
                          onPressed: locked
                              ? null
                              : () => unawaited(_pasteLink()),
                          icon: const GlyphIcon(AppGlyphs.paste, size: 20),
                        ),
                      ),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      OverflowBar(
                        alignment: MainAxisAlignment.start,
                        spacing: 12,
                        overflowSpacing: 8,
                        children: [
                          FilledButton.icon(
                            onPressed: locked ? null : _importLink,
                            icon: _importing
                                ? const CommonCircleLoading(size: 18)
                                : const GlyphIcon(
                                    AppGlyphs.link,
                                    fill: 1,
                                    size: 18,
                                  ),
                            label: Text(l.import),
                          ),
                          TextButton.icon(
                            onPressed: locked ? null : _importFile,
                            icon: const GlyphIcon(
                              AppGlyphs.importFile,
                              size: 18,
                            ),
                            label: Text(l.file),
                          ),
                          TextButton.icon(
                            onPressed: locked ? null : _importQr,
                            icon: const GlyphIcon(AppGlyphs.qrCode, size: 18),
                            label: Text(l.qrcode),
                          ),
                          if (_importing)
                            TextButton(
                              onPressed: _cancelImport,
                              child: Text(l.cancel),
                            ),
                        ],
                      ),
                      AnimatedReveal(
                        visible: _encryptedImport != null,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            spacing: 16,
                            children: [
                              Text(
                                l.setupAgeKeyDescription,
                                style: AppTextStyle.subheadline.of(context),
                              ),
                              FilledInputTheme(
                                child: SecretTextFormField(
                                  controller: _keyController,
                                  decoration: InputDecoration(
                                    hintText: l.ageSecretKey,
                                  ),
                                ),
                              ),
                              FilledButton(
                                onPressed: locked || _encryptedImport == null
                                    ? null
                                    : () =>
                                          unawaited(_import(_encryptedImport!)),
                                child: Text(l.setupLanguageContinue),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _coverage(SetupSessionState state, AppLocalizations l, bool locked) {
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            generateGroup([
              for (final coverage in options)
                DecorationListItem(
                  leading: GlyphIcon(switch (coverage) {
                    SetupCoverage.tun => AppGlyphs.vpn,
                    SetupCoverage.system => AppGlyphs.devices,
                    SetupCoverage.local => AppGlyphs.link,
                  }),
                  title: _optionTitle(
                    _coverageLabel(l, coverage),
                    recommended: coverage == SetupCoverage.tun,
                  ),
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
            ]),
            ListFooter(text: l.setupCoverageNote),
          ],
        ),
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
    final directApps =
        _isAndroid && draft.coverage == SetupCoverage.tun && draft.directRoutes;
    DecorationListItem option({
      required Widget leading,
      required String title,
      String? subtitle,
      required bool isSelected,
      required String? code,
    }) => DecorationListItem(
      isSelected: isSelected,
      leading: leading,
      title: _optionTitle(title, recommended: code != null && code == detected),
      subtitle: subtitle == null ? null : Text(subtitle),
      trailing: isSelected ? const SelectionCheck() : null,
      onPressed: locked ? null : () => _session.selectRegion(code),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 24,
      children: [
        _hero(
          glyph: AppGlyphs.locate,
          title: l.setupRegionTitle,
          description: l.setupRegionStepDescription,
        ),
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
                leading: const GlyphIcon(AppGlyphs.block),
                title: l.setupRegionNeutral,
                subtitle: l.setupRegionNeutralDescription,
                isSelected: draft.regionChosen && draft.regionCode == null,
                code: null,
              ),
            ]),
            ListFooter(
              text: draft.regionChosen
                  ? l.regionCustomPreserved
                  : l.setupRegionUnchosen,
            ),
          ],
        ),
        if (directRules.isNotEmpty)
          generateGroup([
            DecorationListItem(
              leading: const GlyphIcon(AppGlyphs.split),
              title: _optionTitle(l.setupDirectTitle, recommended: true),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  Text(l.setupDirectDescription),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [for (final rule in directRules) CodeLabel(rule)],
                  ),
                ],
              ),
              trailing: Switch(
                value: draft.directRoutes,
                onChanged: locked ? null : _session.selectDirectRoutes,
              ),
              onPressed: locked
                  ? null
                  : () => _session.selectDirectRoutes(!draft.directRoutes),
            ),
            if (directApps)
              DecorationListItem(
                leading: const GlyphIcon(AppGlyphs.appsList),
                title: Text(
                  state.scanningApps || draft.directApps == null
                      ? l.setupDirectAppsScanning
                      : l.setupDirectApps(draft.directApps!.length),
                ),
                subtitle: state.scanningApps || draft.directApps == null
                    ? null
                    : Text(
                        draft.directApps!.isEmpty
                            ? l.setupDirectAppsNone
                            : l.setupDirectAppsReview,
                      ),
                trailing: state.scanningApps
                    ? const CommonCircleLoading(size: 20)
                    : null,
              ),
          ]),
        if (changes.isNotEmpty)
          generateSection(
            title: l.regionChangesTitle,
            items: [
              for (final (glyph, label) in changes)
                DecorationListItem(
                  leading: GlyphIcon(glyph),
                  title: Text(label),
                ),
            ],
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
        if (state.path case final path?) _SetupPath(path: path),
        _note(l.setupCheckLimit),
      ],
    );
  }

  Widget _result(SetupSessionState state, AppLocalizations l, bool locked) {
    final outcome =
        state.outcome ?? const SetupOutcome(verdict: SetupVerdict.unconfirmed);
    final verdict = outcome.verdict;
    final node = outcome.path?.stepOf(PathStep.server)?.detail;
    final delay = outcome.path?.stepOf(PathStep.internet)?.duration;
    final title = switch (verdict) {
      SetupVerdict.connected => l.setupConnectedTitle,
      SetupVerdict.partial => l.setupPartialTitle,
      SetupVerdict.local => l.setupLocalTitle,
      SetupVerdict.saved || SetupVerdict.safeMode => l.setupSavedTitle,
      SetupVerdict.stopped => l.setupStoppedTitle,
      SetupVerdict.permission => l.setupPermissionTitle,
      SetupVerdict.stale || SetupVerdict.unconfirmed => l.setupUnconfirmedTitle,
      SetupVerdict.failed => l.setupFailedTitle,
    };
    final description = switch (verdict) {
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
    final troubled = switch (verdict) {
      SetupVerdict.failed ||
      SetupVerdict.unconfirmed ||
      SetupVerdict.stale => true,
      _ => false,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 24,
      children: [
        _hero(
          glyph: outcome.confirmed
              ? AppGlyphs.checkCircle
              : switch (verdict) {
                  SetupVerdict.saved ||
                  SetupVerdict.safeMode ||
                  SetupVerdict.stopped => AppGlyphs.clock,
                  SetupVerdict.permission => AppGlyphs.vpn,
                  SetupVerdict.failed => AppGlyphs.error,
                  _ => AppGlyphs.warning,
                },
          color: outcome.confirmed
              ? context.colorScheme.success
              : switch (verdict) {
                  SetupVerdict.failed => context.colorScheme.error,
                  SetupVerdict.permission ||
                  SetupVerdict.unconfirmed ||
                  SetupVerdict.stale => context.colorScheme.warning,
                  _ => null,
                },
          title: title,
          description: description,
        ),
        if (outcome.confirmed && (node != null || delay != null))
          CommonCard(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                GlyphIcon(
                  AppGlyphs.target,
                  size: 24,
                  color: context.colorScheme.success,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      if (node != null)
                        Text(node, style: AppTextStyle.headline.of(context)),
                      if (delay != null)
                        Text(
                          '${delay.inMilliseconds} ms',
                          style: AppTextStyle.title2.of(context),
                        ),
                      _note(l.setupCheckLimit),
                    ],
                  ),
                ),
              ],
            ),
          ),
        if (verdict == SetupVerdict.local) _localProxy(l),
        if (outcome.confirmed)
          generateGroup([
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
          ]),
        if (outcome.path case final path?) _SetupPath(path: path),
        if (outcome.error != null)
          CommonCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
              children: [
                Text(
                  l.setupErrorDetails,
                  style: AppTextStyle.headline.of(context),
                ),
                SelectableText(
                  outcome.error!,
                  style: AppTextStyle.footnote.of(context),
                ),
              ],
            ),
          ),
        if (troubled)
          generateSection(
            title: l.setupTipsTitle,
            items: [
              for (final (glyph, tip) in [
                (AppGlyphs.wifi, l.setupTipNetwork),
                (AppGlyphs.profiles, l.setupTipProfile),
                (AppGlyphs.devices, l.setupTipCoverage),
              ])
                DecorationListItem(leading: GlyphIcon(glyph), title: Text(tip)),
            ],
          ),
        _note(l.setupFinishDescription),
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

  Widget _actions(
    SetupSessionState state,
    AppLocalizations l,
    bool locked, {
    required double maxWidth,
  }) {
    final outcome = state.outcome;
    final verdict = outcome?.verdict;
    final finishes =
        state.step == SetupStep.result &&
        (outcome?.confirmed == true || verdict == SetupVerdict.saved);
    final saveInstead =
        state.step == SetupStep.result && verdict == SetupVerdict.safeMode;
    void saveWithoutConnection() =>
        unawaited(_transition(_session.saveWithoutConnection));
    final (label, glyph, onPressed) = switch (state.step) {
      SetupStep.language => (
        l.setupLanguageContinue,
        AppGlyphs.chevronForward,
        _continueFromLanguage,
      ),
      SetupStep.profile => (
        l.setupLanguageContinue,
        AppGlyphs.chevronForward,
        state.draft.profileId == null ? null : () => _goTo(SetupStep.coverage),
      ),
      SetupStep.coverage => (
        l.setupLanguageContinue,
        AppGlyphs.chevronForward,
        () => _goTo(SetupStep.region),
      ),
      SetupStep.region => (
        l.setupCheckAction,
        AppGlyphs.target,
        () => unawaited(_check()),
      ),
      SetupStep.checking => (l.cancel, AppGlyphs.close, _session.cancelCheck),
      SetupStep.result when finishes => (
        l.done,
        AppGlyphs.check,
        () => unawaited(_transition(() => _session.finish(autoRun: _autoRun))),
      ),
      SetupStep.result when saveInstead => (
        l.setupSaveWithoutConnection,
        AppGlyphs.check,
        saveWithoutConnection,
      ),
      SetupStep.result => (
        l.setupRepeat,
        AppGlyphs.refresh,
        () => unawaited(_check()),
      ),
      SetupStep.agreement => (l.agree, AppGlyphs.check, null),
    };
    final enabled = state.step == SetupStep.checking || !locked;
    final secondaryActions = <Widget>[
      if (state.step == SetupStep.profile)
        TextButton(
          onPressed: locked ? null : saveWithoutConnection,
          child: Text(l.setupProfileSkip),
        ),
      if (state.step == SetupStep.region ||
          (state.step == SetupStep.result && !finishes && !saveInstead))
        TextButton(
          onPressed: locked ? null : saveWithoutConnection,
          child: Text(l.setupSaveWithoutConnection),
        ),
      if (state.step == SetupStep.result && !finishes)
        TextButton(
          onPressed: locked ? null : () => _goTo(_previous(state)!),
          child: Text(l.setupChangeSettings),
        ),
      if (state.step == SetupStep.result && outcome?.confirmed == true)
        TextButton(
          onPressed: locked ? null : () => unawaited(_check()),
          child: Text(l.setupRepeat),
        ),
    ];
    final icon = _saving
        ? const CommonCircleLoading(size: 18)
        : GlyphIcon(glyph, size: 18, fill: 1);
    final iconAlignment = glyph == AppGlyphs.chevronForward
        ? IconAlignment.end
        : IconAlignment.start;
    final primaryAction = state.step == SetupStep.checking
        ? FilledButton.tonalIcon(
            onPressed: onPressed,
            icon: icon,
            label: Text(label),
          )
        : FilledButton.icon(
            onPressed: enabled ? onPressed : null,
            icon: icon,
            iconAlignment: iconAlignment,
            label: Text(label),
          );
    final hint =
        state.step == SetupStep.profile && state.draft.profileId == null
        ? l.setupProfileContinueHint
        : null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: LayoutBuilder(
                builder: (context, constraints) => constraints.maxWidth < 600
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: 8,
                        children: [
                          if (hint != null)
                            Text(
                              hint,
                              textAlign: TextAlign.center,
                              style: AppTextStyle.footnote
                                  .of(context)
                                  .copyWith(
                                    color: context.colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          primaryAction,
                          if (secondaryActions.isNotEmpty)
                            Row(
                              spacing: 8,
                              children: [
                                for (final action in secondaryActions)
                                  Expanded(child: action),
                              ],
                            ),
                        ],
                      )
                    : Row(
                        spacing: 12,
                        children: [
                          Expanded(
                            child: hint == null
                                ? const SizedBox.shrink()
                                : _note(hint),
                          ),
                          ...secondaryActions,
                          primaryAction,
                        ],
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StepBar extends StatelessWidget {
  const _StepBar({required this.current, this.onStep});

  final int current;
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
              enabled: index < current && onStep != null,
              onTap: () => onStep?.call(step),
              label: _journeyLabel(l, step),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 6,
                  children: [
                    DecoratedBox(
                      decoration: ShapeDecoration(
                        shape: AppShape.full,
                        color: index <= current
                            ? colors.primary
                            : colors.secondaryContainer,
                      ),
                      child: const SizedBox(height: 4),
                    ),
                    Text(
                      _journeyLabel(l, step),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.caption1
                          .of(context, emphasized: index == current)
                          .copyWith(
                            color: index == current
                                ? colors.onSurface
                                : colors.onSurfaceVariant,
                          ),
                    ),
                  ],
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
        child: InkWell(
          customBorder: AppShape.sm,
          onTap: enabled ? onTap : null,
          child: child,
        ),
      ),
    );
  }
}

class _SetupPath extends StatelessWidget {
  const _SetupPath({required this.path});

  final PathResult path;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final completed = path.steps.where((step) => step.settled).length;
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
              l.setupStepStatus(completed, path.steps.length),
              style: AppTextStyle.caption1
                  .of(context)
                  .copyWith(color: context.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        LinearProgressIndicator(
          value: completed / path.steps.length,
          minHeight: 4,
        ),
        PathStepList(path: path),
      ],
    );
  }
}

class _SetupReceipt extends ConsumerWidget {
  const _SetupReceipt({required this.state, this.onStep});

  final SetupSessionState state;
  final ValueChanged<SetupStep>? onStep;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    final draft = state.draft;
    final profile = ref
        .watch(profilesProvider)
        .getProfile(draft.profileId ?? -1);
    final outcome = state.outcome;
    final node = outcome?.path?.stepOf(PathStep.server)?.detail;
    final current = _journeyIndex(state.step) ?? 0;
    final checkValue = state.checking
        ? l.connecting
        : switch (outcome?.verdict) {
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
    final checkColor = outcome?.confirmed == true
        ? context.colorScheme.success
        : switch (outcome?.verdict) {
            SetupVerdict.failed => context.colorScheme.error,
            SetupVerdict.permission ||
            SetupVerdict.unconfirmed ||
            SetupVerdict.stale => context.colorScheme.warning,
            _ => null,
          };
    final values = [
      profile?.realLabel ?? l.none,
      _coverageLabel(l, draft.coverage),
      _regionChoiceLabel(l, draft),
      checkValue,
    ];
    return CommonCard(
      shape: AppShape.xl,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          Row(
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
                l.setupStepStatus(current + 1, _journey.length),
                style: AppTextStyle.caption1
                    .of(context)
                    .copyWith(color: context.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 4,
            children: [
              for (final (index, step) in _journey.indexed)
                _step(
                  context,
                  number: index + 1,
                  label: _journeyLabel(l, step),
                  value: values[index],
                  current: index == current,
                  done: index == _journey.length - 1
                      ? outcome?.confirmed == true
                      : index < current ||
                            (index == 0 && profile != null) ||
                            (step == SetupStep.region && draft.regionChosen),
                  running: index == _journey.length - 1 && state.checking,
                  statusColor: index == _journey.length - 1 ? checkColor : null,
                  onTap: index < current && onStep != null
                      ? () => onStep!(step)
                      : null,
                ),
              if (outcome?.confirmed == true && node != null) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
                _fact(context, AppGlyphs.target, l.server, node),
              ],
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
          ),
        ],
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
    VoidCallback? onTap,
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
                    ? CommonCircleLoading(
                        size: 18,
                        color: statusColor == null
                            ? context.colorScheme.onPrimary
                            : null,
                      )
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
          if (onTap != null)
            GlyphIcon(
              AppGlyphs.chevronForward,
              size: 16,
              color: context.colorScheme.onSurfaceVariant,
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
        : _StepTap(
            enabled: onTap != null,
            onTap: () => onTap?.call(),
            label: '$label: $value',
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: content(context),
            ),
          );
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
