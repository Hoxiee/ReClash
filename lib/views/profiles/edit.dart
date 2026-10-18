import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/form/form.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/pages/editor.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/subscriptions/compatibility/client_labels.dart';
import 'package:reclash/subscriptions/compatibility/editor_section.dart';
import 'package:reclash/subscriptions/compatibility/import_policy.dart';
import 'package:reclash/subscriptions/compatibility/import_review.dart';
import 'package:reclash/subscriptions/compatibility/preview.dart';
import 'package:reclash/subscriptions/compatibility/settings_form.dart';
import 'package:reclash/subscriptions/compatibility/clients.dart';
import 'package:reclash/subscriptions/identity/device_identity.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _ProfileField { label, url, autoUpdateInterval, client }

class EditProfileView extends ConsumerStatefulWidget {
  final Profile profile;

  const EditProfileView({super.key, required this.profile});

  @override
  ConsumerState<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends ConsumerState<EditProfileView> {
  late final TextEditingController _labelController;
  late final TextEditingController _urlController;
  late final TextEditingController _ageSecretKeyController;
  late final TextEditingController _autoUpdateDurationController;
  late final TextEditingController _customUserAgentController;
  late SubscriptionClientPreset _clientPreset;
  late bool _intervalOverride;
  late SubscriptionImportPolicy _importPolicy;
  late final SubscriptionClientPreview _preview;
  final _compatibilityTick = ValueNotifier<int>(0);
  bool _compatibilityPageOpen = false;
  SubscriptionClientPreset? _lastSuccessful;
  var _compatibilityRevision = 0;
  bool _profileChanged = false;
  bool _saving = false;
  String? _compatibilityError;
  bool _showUrl = false;
  bool _globalSendDeviceIdentity = false;
  bool? _sendDeviceIdentityOverride;
  bool _identityConsentLoading = true;
  late bool _autoUpdate;
  Uint8List? _editedData;
  bool _attempted = false;
  final _fileInfoNotifier = ValueNotifier<FileInfo?>(null);
  late SetupAction _setupAction;
  Uint8List? _fileData;

  bool get _sendDeviceIdentity =>
      _sendDeviceIdentityOverride ?? _globalSendDeviceIdentity;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.profile.label);
    _urlController = TextEditingController(text: widget.profile.url);
    _ageSecretKeyController = TextEditingController(
      text: widget.profile.ageSecretKey,
    );
    _autoUpdate = widget.profile.autoUpdate;
    _autoUpdateDurationController = TextEditingController(
      text: widget.profile.autoUpdateDuration.inMinutes.toString(),
    );
    final client = widget.profile.subscriptionPreferences.client;
    _clientPreset = client.preset;
    _intervalOverride = widget.profile.subscriptionPreferences.intervalOverride;
    _customUserAgentController = TextEditingController(
      text: client.customUserAgent,
    );
    _importPolicy = client.importPolicy;
    _preview = SubscriptionClientPreview(
      prepare: (candidate, cancellation) => ref
          .read(profilesActionProvider.notifier)
          .prepareProfileCompatibility(candidate, cancellation: cancellation),
    )..addListener(_previewChanged);
    for (final controller in [
      _urlController,
      _ageSecretKeyController,
      _customUserAgentController,
    ]) {
      controller.addListener(_invalidateCompatibility);
    }
    _setupAction = ref.read(setupActionProvider.notifier);
    _updateFileInfo();
    unawaited(_loadDeviceIdentityConsent());
    unawaited(_loadLastSuccessful());
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    _compatibilityTick.value++;
  }

  void _previewChanged() {
    if (mounted) setState(() {});
  }

  void _invalidateCompatibility() {
    _compatibilityRevision++;
    _compatibilityError = null;
    _profileChanged = false;
    _lastSuccessful = null;
    _preview.invalidate();
  }

  Profile _candidate(Profile current) {
    final interval = int.tryParse(_autoUpdateDurationController.text);
    final url = _urlController.text;
    final key = _ageSecretKeyController.text.trim();
    final policy = _importPolicy.scope == subscriptionImportScope(url, key)
        ? _importPolicy
        : const SubscriptionImportPolicy();
    return current.copyWith(
      url: url,
      ageSecretKey: key,
      label: _labelController.text,
      autoUpdate: _autoUpdate,
      autoUpdateDuration: interval != null && interval > 0
          ? Duration(minutes: interval)
          : current.autoUpdateDuration,
      subscriptionPreferences: current.subscriptionPreferences.copyWith(
        intervalOverride: _intervalOverride,
        client: current.subscriptionPreferences.client.copyWith(
          preset: _clientPreset,
          customUserAgent: _customUserAgentController.text,
          importPolicy: policy,
        ),
      ),
    );
  }

  Future<void> _loadLastSuccessful() async {
    if (widget.profile.type != ProfileType.url) return;
    final revision = _compatibilityRevision;
    final candidate = _candidate(widget.profile);
    final client = await ref
        .read(profilesActionProvider.notifier)
        .lastSuccessfulProfileClient(candidate);
    if (!mounted ||
        revision != _compatibilityRevision ||
        _preview.checking ||
        jsonEncode(
              _candidate(widget.profile).subscriptionPreferences.toJson(),
            ) !=
            jsonEncode(candidate.subscriptionPreferences.toJson()) ||
        _urlController.text != candidate.url ||
        _ageSecretKeyController.text.trim() != candidate.ageSecretKey) {
      return;
    }
    setState(() => _lastSuccessful = client);
  }

  Future<void> _checkCompatibility() async {
    if (_saving ||
        _preview.checking ||
        _identityConsentLoading ||
        _fileData != null) {
      return;
    }
    if (_issue(context.appLocalizations) != null) {
      setState(() => _attempted = true);
      return;
    }
    final current = ref.read(profilesProvider).getProfile(widget.profile.id);
    if (current == null) {
      setState(
        () => _compatibilityError =
            context.appLocalizations.subscriptionCompatibilitySuperseded,
      );
      return;
    }
    _compatibilityError = null;
    _profileChanged = false;
    await _preview.check(_candidate(current), source: current);
  }

  void _setClientPreset(SubscriptionClientPreset value) {
    if (_saving || _clientPreset == value) return;
    _clientPreset = value;
    _invalidateCompatibility();
    unawaited(_loadLastSuccessful());
  }

  String? _bannerMessage(({_ProfileField field, String message})? issue) =>
      issue?.message ??
      _compatibilityError ??
      _preview.failure?.label ??
      (_profileChanged
          ? context.appLocalizations.subscriptionCompatibilitySuperseded
          : null);

  SubscriptionCompatibilityView _compatibilityView() {
    final issue = _attempted ? _issue(context.appLocalizations) : null;
    return SubscriptionCompatibilityView(
      preset: _clientPreset,
      error: _bannerMessage(issue),
      lastSuccessful: _lastSuccessful,
      prepared: _preview.prepared,
      checking: _preview.checking,
      saving: _saving,
      invalid: issue?.field == _ProfileField.client,
      hasConsent: !_candidate(
        widget.profile,
      ).subscriptionPreferences.client.importPolicy.isEmpty,
      canCheck: _fileData == null && !_identityConsentLoading,
    );
  }

  Future<void> _openCompatibility() async {
    _compatibilityPageOpen = true;
    try {
      await BaseNavigator.push<void>(
        context,
        SubscriptionCompatibilityPage(
          listenable: _compatibilityTick,
          read: _compatibilityView,
          userAgentController: _customUserAgentController,
          onPresetChanged: _setClientPreset,
          onUserAgentChanged: _handleChanged,
          onCheck: _checkCompatibility,
          onCancel: _preview.invalidate,
          onApply: _applyCompatibility,
          onForgetConsent: _forgetImportConsent,
        ),
      );
    } finally {
      _compatibilityPageOpen = false;
    }
  }

  void _forgetImportConsent() {
    if (_saving) return;
    _importPolicy = const SubscriptionImportPolicy();
    _invalidateCompatibility();
  }

  Future<void> _applyCompatibility() async {
    if (_saving || _preview.checking) return;
    final prepared = _preview.prepared;
    final current = ref.read(profilesProvider).getProfile(widget.profile.id);
    if (prepared == null ||
        current == null ||
        current != _preview.source ||
        !_preview.matches(_candidate(current))) {
      _preview.invalidate();
      setState(
        () => _compatibilityError =
            context.appLocalizations.subscriptionCompatibilitySuperseded,
      );
      return;
    }
    if (_issue(context.appLocalizations) != null) {
      setState(() => _attempted = true);
      return;
    }
    final profile = _candidate(current);
    final route = SubscriptionImportReviewRoute.fromContext(context);
    final reviewContext = route.navigator.context;
    final profilesAction = ref.read(profilesActionProvider.notifier);
    setState(() => _saving = true);
    try {
      SubscriptionImportApproval? approval = const SubscriptionImportApproval();
      if (!profile.subscriptionPreferences.client.importPolicy.allows(
        prepared.payload.format,
        prepared.summary,
        sourceScope: subscriptionImportScope(profile.url, profile.ageSecretKey),
      )) {
        approval = await approveSubscriptionImportAt(
          route,
          format: prepared.payload.format,
          summary: prepared.summary,
          sourceScope: subscriptionImportScope(
            profile.url,
            profile.ageSecretKey,
          ),
        );
      }
      if (approval == null || !mounted) return;
      if (ref.read(profilesProvider).getProfile(profile.id) != current ||
          !_preview.matches(_candidate(current))) {
        _preview.invalidate();
        setState(
          () => _compatibilityError =
              context.appLocalizations.subscriptionCompatibilitySuperseded,
        );
        return;
      }
      final rememberedPolicy = approval.rememberedPolicy;
      final saved = await globalState.safeRun(
        () => profilesAction.updateProfile(
          profile,
          preparedUpdate: prepared,
          acceptLosses: true,
          importPolicy: rememberedPolicy,
          persistProfileSettings: true,
          reviewContext: reviewContext,
        ),
      );
      if (!mounted) return;
      if (saved != null) {
        if (_compatibilityPageOpen) Navigator.of(context).pop();
        if (!mounted) return;
        Navigator.of(context).pop();
      } else {
        _preview.invalidate();
        setState(
          () => _compatibilityError =
              context.appLocalizations.subscriptionCompatibilitySuperseded,
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _updateFileInfo() async {
    final file = await widget.profile.file;
    final fileInfo = await file.getFileInfo();
    if (!mounted) {
      return;
    }
    _fileInfoNotifier.value = fileInfo;
  }

  ({_ProfileField field, String message})? _issue(
    AppLocalizations appLocalizations,
  ) {
    final labelError = validateProfileName(
      appLocalizations,
      _labelController.text,
    );
    if (labelError != null) {
      return (field: _ProfileField.label, message: labelError);
    }
    if (widget.profile.type != ProfileType.url) {
      return null;
    }
    final url = _urlController.text;
    if (url.isEmpty) {
      return (
        field: _ProfileField.url,
        message: appLocalizations.profileUrlNullValidationDesc,
      );
    }
    if (!url.isUrl) {
      return (
        field: _ProfileField.url,
        message: appLocalizations.profileUrlInvalidValidationDesc,
      );
    }
    if (_clientPreset == SubscriptionClientPreset.custom &&
        validateCustomSubscriptionUserAgent(_customUserAgentController.text) !=
            null) {
      return (
        field: _ProfileField.client,
        message: appLocalizations.subscriptionClientCustomUserAgentInvalid,
      );
    }
    if (!_autoUpdate) {
      return null;
    }
    final interval = _autoUpdateDurationController.text;
    if (interval.isEmpty) {
      return (
        field: _ProfileField.autoUpdateInterval,
        message: appLocalizations.profileAutoUpdateIntervalNullValidationDesc,
      );
    }
    if ((int.tryParse(interval) ?? 0) <= 0) {
      return (
        field: _ProfileField.autoUpdateInterval,
        message:
            appLocalizations.profileAutoUpdateIntervalInvalidValidationDesc,
      );
    }
    return null;
  }

  Future<void> _loadDeviceIdentityConsent() async {
    try {
      final store = await DeviceIdentityStore.create();
      final globalEnabled = await store.globalSendEnabled(
        byDefault: sendsDeviceIdentityByDefault(
          ref.read(appSettingProvider).regionCode,
        ),
      );
      final override = await store.profileSendOverride(widget.profile.id);
      if (!mounted) return;
      setState(() {
        _globalSendDeviceIdentity = globalEnabled;
        _sendDeviceIdentityOverride = override;
        _identityConsentLoading = false;
      });
    } on Object {
      if (mounted) setState(() => _identityConsentLoading = false);
    }
  }

  Future<void> _setDeviceIdentityOverride(bool? value) async {
    if (_saving || _identityConsentLoading) return;
    if (value == true && !_sendDeviceIdentity) {
      final l10n = context.appLocalizations;
      final accepted = await dialogs.showMessage(
        title: l10n.subscriptionIdentityTitle,
        context: context,
        message: TextSpan(text: l10n.subscriptionIdentityDisclosure),
      );
      if (!mounted || accepted != true) return;
    }
    if (value == false && _sendDeviceIdentity) {
      final confirmed = await confirmDeviceIdentityOff(
        context,
        ref.read(appSettingProvider).regionCode,
      );
      if (!mounted || !confirmed) return;
    }
    if (!mounted) return;
    _invalidateCompatibility();
    setState(() => _identityConsentLoading = true);
    try {
      final store = await DeviceIdentityStore.create();
      await store.setProfileSendOverride(widget.profile.id, value);
      if (!mounted) return;
      setState(() => _sendDeviceIdentityOverride = value);
    } on Object catch (error, stack) {
      await globalState.safeRun<void>(
        () => Error.throwWithStackTrace(error, stack),
      );
    } finally {
      if (mounted) {
        setState(() => _identityConsentLoading = false);
        unawaited(_loadLastSuccessful());
      }
    }
  }

  void _handleChanged(String _) {
    if (_attempted) {
      setState(() {});
    }
  }

  Future<void> _handleConfirm() async {
    if (_saving || _preview.checking) return;
    if (_preview.prepared != null) {
      await _applyCompatibility();
      return;
    }
    final reviewRoute = SubscriptionImportReviewRoute.fromContext(context);
    final reviewContext = reviewRoute.navigator.context;
    if (_issue(context.appLocalizations) != null) {
      setState(() {
        _attempted = true;
      });
      return;
    }
    final current = ref.read(profilesProvider).getProfile(widget.profile.id);
    if (current == null) {
      setState(
        () => _compatibilityError =
            context.appLocalizations.subscriptionCompatibilitySuperseded,
      );
      return;
    }
    var profile = _candidate(current);
    final profilesAction = ref.read(profilesActionProvider.notifier);
    final appLocalizations = context.appLocalizations;
    final hasUpdate =
        current.url != profile.url ||
        current.ageSecretKey != profile.ageSecretKey;
    if (_fileData != null) {
      if (profile.type == ProfileType.url && _autoUpdate) {
        final res = await dialogs.showMessage(
          title: appLocalizations.tip,
          message: TextSpan(text: appLocalizations.profileHasUpdate),
        );
        if (res == true) {
          profile = profile.copyWith(autoUpdate: false);
        }
      }
      final savedProfile = await globalState.safeRun(
        () => profilesAction.saveImportedProfileFile(
          profile,
          _fileData!,
          reviewContext: reviewContext,
        ),
      );
      if (savedProfile == null) {
        return;
      }
      profilesAction.putProfile(savedProfile);
    } else if (!hasUpdate) {
      profilesAction.putProfile(profile);
    } else {
      unawaited(
        globalState.safeRun(() async {
          await Future.delayed(commonDuration);
          if (hasUpdate && reviewContext.mounted) {
            await profilesAction.updateProfile(
              profile,
              allowLossReview: true,
              persistProfileSettings: true,
              reviewContext: reviewContext,
            );
          }
        }),
      );
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _setAutoUpdate(bool value) {
    if (_autoUpdate == value) return;
    setState(() {
      _autoUpdate = value;
    });
  }

  Future<void> _handleSaveEdit(BuildContext context, Uint8List data) async {
    final message = await globalState.safeRun<String>(() async {
      final message = await ref
          .read(profilesActionProvider.notifier)
          .validateConfigWithData(data);
      return message;
    }, silence: false);
    if (message?.isNotEmpty == true) {
      unawaited(
        dialogs.showAlert(
          title: currentAppLocalizations.tip,
          message: TextSpan(text: message),
        ),
      );
      return;
    }
    if (context.mounted) {
      Navigator.of(context).pop(data);
    }
  }

  Future<void> _editProfileFile() async {
    final title = widget.profile.label.takeFirstValid([
      widget.profile.id.toString(),
    ]);
    final editedData = _editedData;
    final editorPage = EditorPage(
      title: title,
      load: () async => editedData != null
          ? CodeForgeDocument.fromUtf8(editedData)
          : openEditorFile(
              await appPath.getProfilePath(widget.profile.id.toString()),
            ),
      onSave: (context, _, content) async {
        final data = await content.readBytes();
        if (context.mounted) {
          await _handleSaveEdit(context, data);
        }
      },
      onPop: (context, _, content) async {
        final res = await dialogs.showMessage(
          title: title,
          message: TextSpan(text: context.appLocalizations.hasCacheChange),
        );
        if (res != true || !context.mounted) {
          return true;
        }
        final data = await content.readBytes();
        if (context.mounted) {
          unawaited(_handleSaveEdit(context, data));
        }
        return false;
      },
    );
    final data = await BaseNavigator.push<Uint8List>(context, editorPage);
    if (data == null || !mounted) {
      return;
    }
    _invalidateCompatibility();
    _editedData = data;
    setState(() {
      _fileData = data;
    });
    _fileInfoNotifier.value = _fileInfoNotifier.value?.copyWith(
      size: _fileData?.length ?? 0,
      lastModified: DateTime.now(),
    );
  }

  Future<void> _uploadProfileFile() async {
    final platformFile = await globalState.safeRun(picker.pickerFile);
    if (platformFile == null) return;
    _invalidateCompatibility();
    final fileData = await platformFile.readBytes();
    if (!mounted) {
      return;
    }
    setState(() {
      _fileData = fileData;
    });
    _fileInfoNotifier.value = _fileInfoNotifier.value?.copyWith(
      size: _fileData?.length ?? 0,
      lastModified: DateTime.now(),
    );
  }

  Future<void> _handleBack() async {
    final appLocalizations = context.appLocalizations;
    final res = await dialogs.showMessage(
      title: appLocalizations.tip,
      message: TextSpan(text: appLocalizations.fileIsUpdate),
    );
    if (res == true) {
      unawaited(_handleConfirm());
    } else {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void dispose() {
    for (final controller in [
      _urlController,
      _ageSecretKeyController,
      _customUserAgentController,
    ]) {
      controller.removeListener(_invalidateCompatibility);
    }
    _preview.removeListener(_previewChanged);
    _preview.dispose();
    _compatibilityTick.dispose();
    _labelController.dispose();
    _urlController.dispose();
    _ageSecretKeyController.dispose();
    _fileInfoNotifier.dispose();
    _autoUpdateDurationController.dispose();
    _customUserAgentController.dispose();
    super.dispose();
    _setupAction.autoApplyProfile();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final isUrl = widget.profile.type == ProfileType.url;
    final hideUrl =
        widget.profile.subscriptionSnapshot?.metadata.hideUrl ?? false;
    ref.listen(profilesProvider, (previous, next) {
      final source = _preview.source;
      if (!_saving && source != null && next.getProfile(source.id) != source) {
        _invalidateCompatibility();
        _profileChanged = true;
      }
    });
    final issue = _attempted ? _issue(appLocalizations) : null;
    final sections = [
      generateSection(
        items: [
          _ProfileNameField(
            controller: _labelController,
            invalid: issue?.field == _ProfileField.label,
            onChanged: _handleChanged,
          ),
          if (isUrl)
            _ProfileUrlField(
              controller: _urlController,
              invalid: issue?.field == _ProfileField.url,
              obscure: hideUrl && !_showUrl,
              onToggleVisibility: hideUrl
                  ? () => setState(() => _showUrl = !_showUrl)
                  : null,
              onChanged: _handleChanged,
            ),
          _AgeSecretKeyField(controller: _ageSecretKeyController),
        ],
      ),
      if (isUrl)
        generateSection(
          items: [
            FormRow(
              title: appLocalizations.autoUpdate,
              onPressed: () => _setAutoUpdate(!_autoUpdate),
              trailing: CommonSwitch(
                value: _autoUpdate,
                onChanged: _setAutoUpdate,
              ),
            ),
            if (_autoUpdate)
              _AutoUpdateIntervalField(
                controller: _autoUpdateDurationController,
                invalid: issue?.field == _ProfileField.autoUpdateInterval,
                onChanged: _handleChanged,
              ),
            FormRow(
              title: appLocalizations.subscriptionUseProviderInterval,
              onPressed: () => setState(() {
                _intervalOverride = !_intervalOverride;
                _invalidateCompatibility();
              }),
              trailing: Switch(
                value: !_intervalOverride,
                onChanged: (value) => setState(() {
                  _intervalOverride = !value;
                  _invalidateCompatibility();
                }),
              ),
            ),
            ListItem<bool?>.options(
              title: Text(appLocalizations.subscriptionIdentityTitle),
              options: const [null, true, false],
              value: _sendDeviceIdentityOverride,
              textBuilder: (value) => switch (value) {
                null => appLocalizations.subscriptionIdentityUseGlobal,
                true => appLocalizations.enabled,
                false => appLocalizations.disabled,
              },
              onChanged: (value) =>
                  unawaited(_setDeviceIdentityOverride(value)),
            ),
          ],
        ),
      if (isUrl)
        generateSection(
          items: [
            SubscriptionCompatibilityEntryRow(
              preset: _clientPreset,
              onPressed: _openCompatibility,
            ),
          ],
        ),
      _ProfileFileItem(
        fileInfoNotifier: _fileInfoNotifier,
        onEdit: _editProfileFile,
        onUpload: _uploadProfileFile,
      ),
    ];
    return FocusTraversalGroup(
      policy: PageTraversalPolicy(),
      child: PageFocusScope(
        child: CommonPopScope(
          onPop: (context) {
            if (_saving) return false;
            if (_fileData == null) {
              return true;
            }
            _handleBack();
            return false;
          },
          child: CommonScaffold(
            title: appLocalizations.edit,
            confirmationAction: IconButtonData(
              glyph: AppGlyphs.check,
              onPressed: _saving || _preview.checking ? null : _handleConfirm,
              isLoading: _saving,
              tooltip: appLocalizations.save,
            ),
            body: Builder(
              builder: (context) => ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(
                  top: context.sectionsTopPadding,
                  bottom: context.bottomInset + 16,
                ),
                children: [
                  ErrorBanner(message: _bannerMessage(issue)),
                  ...sections.separated(const SizedBox(height: 24)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String? validateProfileName(AppLocalizations appLocalizations, String? value) {
  if (value == null || value.isEmpty) {
    return appLocalizations.profileNameNullValidationDesc;
  }
  return null;
}

Future<void> renameProfile(
  BuildContext context,
  WidgetRef ref,
  Profile profile, {
  bool selectAll = false,
}) async {
  final appLocalizations = context.appLocalizations;
  final profilesAction = ref.read(profilesActionProvider.notifier);
  final label = await dialogs.showCommonDialog<String>(
    child: InputDialog(
      title: appLocalizations.rename,
      labelText: appLocalizations.name,
      value: profile.label,
      selectAll: selectAll,
      inputFormatters: TextInputLimits.limit(TextInputLimits.name),
      validator: (value) => validateProfileName(appLocalizations, value),
    ),
  );
  if (label == null || label == profile.label) {
    return;
  }
  profilesAction.putProfile(profile.copyWith(label: label));
}

class _ProfileNameField extends StatelessWidget {
  const _ProfileNameField({
    required this.controller,
    required this.invalid,
    required this.onChanged,
  });

  final TextEditingController controller;
  final bool invalid;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return FormRow(
      title: appLocalizations.name,
      invalid: invalid,
      trailing: FormRowTextField(
        controller: controller,
        hintText: appLocalizations.required,
        textInputAction: TextInputAction.next,
        inputFormatters: TextInputLimits.limit(TextInputLimits.name),
        onChanged: onChanged,
      ),
    );
  }
}

class _ProfileUrlField extends StatelessWidget {
  const _ProfileUrlField({
    required this.controller,
    required this.invalid,
    required this.onChanged,
    this.obscure = false,
    this.onToggleVisibility,
  });

  final TextEditingController controller;
  final bool invalid;
  final ValueChanged<String> onChanged;
  final bool obscure;
  final VoidCallback? onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final field = FormRowTextField(
      controller: controller,
      hintText: appLocalizations.required,
      keyboardType: TextInputType.url,
      textInputAction: TextInputAction.next,
      obscureText: obscure,
      autocorrect: false,
      inputFormatters: TextInputLimits.limit(TextInputLimits.url),
      onChanged: onChanged,
    );
    return FormRow(
      title: appLocalizations.url,
      invalid: invalid,
      trailing: onToggleVisibility == null
          ? field
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(child: field),
                CommonMinIconButtonTheme(
                  child: IconButton(
                    tooltip: obscure
                        ? appLocalizations.subscriptionCompatibilityShowUrl
                        : appLocalizations.subscriptionCompatibilityHideUrl,
                    onPressed: onToggleVisibility,
                    icon: GlyphIcon(obscure ? AppGlyphs.eye : AppGlyphs.eyeOff),
                  ),
                ),
              ],
            ),
    );
  }
}

class _AgeSecretKeyField extends StatelessWidget {
  const _AgeSecretKeyField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return FormRow(
      title: appLocalizations.ageSecretKey,
      trailing: FormRowSecretTextField(
        controller: controller,
        hintText: appLocalizations.optional,
        textInputAction: TextInputAction.next,
      ),
    );
  }
}

class _AutoUpdateIntervalField extends StatelessWidget {
  const _AutoUpdateIntervalField({
    required this.controller,
    required this.invalid,
    required this.onChanged,
  });

  final TextEditingController controller;
  final bool invalid;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return FormRow(
      title: appLocalizations.autoUpdateInterval,
      invalid: invalid,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          Flexible(
            child: FormRowTextField(
              controller: controller,
              hintText: appLocalizations.required,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              inputFormatters: TextInputLimits.digitsOnly(
                TextInputLimits.interval,
              ),
              onChanged: onChanged,
            ),
          ),
          Text(
            appLocalizations.minutes,
            style: AppTextStyle.subheadline.of(context),
          ),
        ],
      ),
    );
  }
}

class _ProfileFileItem extends StatelessWidget {
  const _ProfileFileItem({
    required this.fileInfoNotifier,
    required this.onEdit,
    required this.onUpload,
  });

  final ValueNotifier<FileInfo?> fileInfoNotifier;
  final VoidCallback onEdit;
  final VoidCallback onUpload;

  Widget _buildSubtitle(BuildContext context, FileInfo fileInfo) {
    final style = context.listCaptionStyle;
    final lastModified = fileInfo.lastModified;
    if (lastModified == null) {
      return Text(context.appLocalizations.unknown, style: style);
    }
    return LastUpdateTimeText(lastUpdateDate: lastModified, style: style);
  }

  List<CommonPopupMenuItem> _menuItems(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return [
      CommonPopupMenuItem(
        glyph: AppGlyphs.edit,
        label: appLocalizations.edit,
        onPressed: onEdit,
      ),
      CommonPopupMenuItem(
        glyph: AppGlyphs.upload,
        label: appLocalizations.upload,
        onPressed: onUpload,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return ValueListenableBuilder<FileInfo?>(
      valueListenable: fileInfoNotifier,
      builder: (context, fileInfo, _) {
        return FadeThroughBox(
          alignment: Alignment.centerLeft,
          child: fileInfo == null
              ? Container()
              : ContextMenuRegion(
                  menuItems: _menuItems(context),
                  child: DecorationListItem(
                    contentPadding: const EdgeInsets.only(left: 16),
                    title: Text(appLocalizations.profile),
                    subtitle: _buildSubtitle(context, fileInfo),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          fileInfo.size.traffic.show,
                          style: context.listCaptionStyle,
                        ),
                        const DisclosureIndicator(),
                      ],
                    ),
                    onPressed: onEdit,
                  ),
                ),
        );
      },
    );
  }
}
