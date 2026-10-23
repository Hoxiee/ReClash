import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/subscriptions/compatibility/client_picker.dart';
import 'package:reclash/subscriptions/compatibility/clients.dart';
import 'package:reclash/subscriptions/identity/device_identity.dart';
import 'package:reclash/features/form/form.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';

class SubscriptionClientSettingsSection extends StatefulWidget {
  const SubscriptionClientSettingsSection({
    super.key,
    required this.initial,
    required this.onChanged,
    required this.onFormChanged,
  });

  final SubscriptionClientSettings initial;
  final ValueChanged<SubscriptionClientSettings> onChanged;
  final VoidCallback onFormChanged;

  @override
  State<SubscriptionClientSettingsSection> createState() =>
      _SubscriptionClientSettingsSectionState();
}

class _SubscriptionClientSettingsSectionState
    extends State<SubscriptionClientSettingsSection> {
  late final TextEditingController _userAgentController;
  late SubscriptionClientPreset _preset;

  SubscriptionClientSettings get _value => widget.initial.copyWith(
    preset: _preset,
    customUserAgent: _userAgentController.text,
  );

  @override
  void initState() {
    super.initState();
    _preset = widget.initial.preset;
    _userAgentController = TextEditingController(
      text: widget.initial.customUserAgent,
    );
  }

  @override
  void dispose() {
    _userAgentController.dispose();
    super.dispose();
  }

  void _changed() {
    widget.onChanged(_value);
    widget.onFormChanged();
  }

  @override
  Widget build(BuildContext context) {
    return generateSection(
      items: [
        SubscriptionClientPresetRow(
          value: _preset,
          onChanged: (value) => setState(() {
            _preset = value;
            _changed();
          }),
        ),
        if (_preset == SubscriptionClientPreset.custom)
          SubscriptionCustomUserAgentRow(
            controller: _userAgentController,
            invalid: !_value.isValid,
            onChanged: (_) => _changed(),
          ),
      ],
    );
  }
}

Future<bool> confirmDeviceIdentityOff(
  BuildContext context,
  String? regionCode,
) async {
  if (!sendsDeviceIdentityByDefault(regionCode)) return true;
  final l10n = context.appLocalizations;
  return await dialogs.showMessage(
        title: l10n.subscriptionIdentityTitle,
        context: context,
        message: TextSpan(text: l10n.subscriptionIdentityRegionWarning),
      ) ==
      true;
}

class SubscriptionSendHwidRow extends ConsumerStatefulWidget {
  const SubscriptionSendHwidRow({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool? value;
  final ValueChanged<bool> onChanged;

  @override
  ConsumerState<SubscriptionSendHwidRow> createState() =>
      _SubscriptionSendHwidRowState();
}

class _SubscriptionSendHwidRowState
    extends ConsumerState<SubscriptionSendHwidRow> {
  bool _global = false;

  bool get _enabled => widget.value ?? _global;

  @override
  void initState() {
    super.initState();
    unawaited(_loadGlobal());
  }

  Future<void> _loadGlobal() async {
    final store = await DeviceIdentityStore.create();
    final enabled = await store.globalSendEnabled(
      byDefault: sendsDeviceIdentityByDefault(
        ref.read(appSettingProvider).regionCode,
      ),
    );
    if (mounted) setState(() => _global = enabled);
  }

  Future<void> _toggle(bool value) async {
    if (value && !_enabled) {
      final l10n = context.appLocalizations;
      final accepted = await dialogs.showMessage(
        title: l10n.subscriptionIdentityTitle,
        context: context,
        message: TextSpan(text: l10n.subscriptionIdentityDisclosure),
      );
      if (accepted != true) return;
    }
    if (!value && _enabled) {
      final confirmed = await confirmDeviceIdentityOff(
        context,
        ref.read(appSettingProvider).regionCode,
      );
      if (!confirmed) return;
    }
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return FormRow(
      title: context.appLocalizations.subscriptionIdentityTitle,
      onPressed: () => unawaited(_toggle(!_enabled)),
      trailing: Switch(
        value: _enabled,
        onChanged: (value) => unawaited(_toggle(value)),
      ),
    );
  }
}
