import 'package:flutter/services.dart'
    show FilteringTextInputFormatter, LengthLimitingTextInputFormatter;
import 'package:reclash/common/common.dart';
import 'package:reclash/features/form/form.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';

import 'client_labels.dart';
import 'clients.dart';

class SubscriptionClientPresetRow extends StatelessWidget {
  const SubscriptionClientPresetRow({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final SubscriptionClientPreset value;
  final ValueChanged<SubscriptionClientPreset> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListItem<SubscriptionClientPreset>.options(
      title: Text(context.appLocalizations.subscriptionClientRequestAs),
      options: SubscriptionClientPreset.values,
      value: value,
      textBuilder: (preset) => preset.label,
      onChanged: onChanged,
    );
  }
}

class SubscriptionCustomUserAgentRow extends StatelessWidget {
  const SubscriptionCustomUserAgentRow({
    super.key,
    required this.controller,
    required this.onChanged,
    this.invalid = false,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool invalid;

  @override
  Widget build(BuildContext context) {
    return FormRow(
      title: context.appLocalizations.subscriptionClientCustomUserAgent,
      invalid: invalid,
      trailing: FormRowTextField(
        controller: controller,
        autocorrect: false,
        inputFormatters: [
          FilteringTextInputFormatter.deny(RegExp(r'[\x00-\x1f\x7f]')),
          LengthLimitingTextInputFormatter(512),
        ],
        onChanged: onChanged,
      ),
    );
  }
}
