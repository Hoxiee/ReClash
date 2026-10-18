import 'package:reclash/common/common.dart';
import 'package:reclash/subscriptions/compatibility/client_picker.dart';
import 'package:reclash/subscriptions/compatibility/clients.dart';
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
    final l10n = context.appLocalizations;
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
      footer:
          '${l10n.subscriptionClientUrlOnly} ${l10n.subscriptionClientDeviceDataHint}',
    );
  }
}
