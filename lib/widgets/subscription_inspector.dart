import 'package:reclash/common/common.dart';
import 'package:reclash/subscriptions/metadata/metadata.dart';
import 'package:reclash/subscriptions/protocol/registry.dart';
import 'package:reclash/ui/code_label.dart';
import 'package:reclash/ui/ui.dart';
import 'package:material_ui/material_ui.dart';

/// What a dev subscription's last response set, in protocol terms, so a
/// panel author can check their headers without a proxy log.
class SubscriptionInspectorSheet extends StatelessWidget {
  const SubscriptionInspectorSheet({super.key, required this.snapshot});

  final SubscriptionSnapshot snapshot;

  static String _value(Object? value) => switch (value) {
    final List<Object?> list => list.join(', '),
    final Map<Object?, Object?> map => [
      for (final MapEntry(:key, :value) in map.entries) '$key: $value',
    ].join('\n'),
    _ => '$value',
  };

  Widget _row(String title, String value, {Widget? trailing}) {
    return DecorationListItem(
      title: Text(title),
      subtitle: Text(value),
      trailing: trailing,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final fields = snapshot.metadata.fields;
    final known = {for (final field in subscriptionFields) field.path: field};
    final paths = [
      for (final field in subscriptionFields)
        if (fields.containsKey(field.path)) field.path,
      ...fields.keys.where((path) => !known.containsKey(path)),
    ];
    final stale = snapshot.stale
        ? fields.keys.toSet()
        : snapshot.staleFields.toSet();
    return CommonScaffold(
      title: appLocalizations.subscriptionInspector,
      body: SelectionArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(
            top: context.contentTopPadding,
            bottom: 20 + context.bottomInset,
          ),
          children: [
            generateSection(
              items: [
                _row(appLocalizations.source, snapshot.source.name),
                _row(
                  appLocalizations.subscriptionReceivedAt,
                  snapshot.receivedAt.showFull,
                ),
                if (snapshot.deviceStatus case final status?)
                  _row(appLocalizations.subscriptionDeviceStatus, status.name),
              ],
            ),
            generateSection(
              title: appLocalizations.rcxWarnings,
              items: [
                for (final warning in snapshot.warnings)
                  DecorationListItem(title: Text(warning)),
              ],
            ),
            generateSection(
              title: appLocalizations.subscriptionFields,
              items: [
                for (final path in paths)
                  _row(
                    known[path]?.header ?? path,
                    _value(fields[path]),
                    trailing: switch ([
                      ?known[path]?.trust.name,
                      if (stale.contains(path)) 'stale',
                    ]) {
                      [] => null,
                      final tags => CodeLabel(tags.join(' · ')),
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
