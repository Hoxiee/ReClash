import 'package:reclash/common/common.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'list.dart';

class DetailRow extends StatelessWidget {
  final String title;
  final Widget? value;
  final String? copyText;

  const DetailRow({super.key, required this.title, this.value, this.copyText});

  DetailRow.text({super.key, required this.title, required String value})
    : value = Text(value),
      copyText = value;

  Future<void> _copy(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    context.showNotifier(context.appLocalizations.copySuccess);
  }

  @override
  Widget build(BuildContext context) {
    final value = this.value;
    final copyText = this.copyText;
    return DecorationListItem(
      onPressed: copyText == null ? null : () => _copy(context, copyText),
      title: value == null
          ? Text(title)
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 20,
              children: [
                Text(title),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: DefaultTextStyle.merge(
                      textAlign: TextAlign.end,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                      child: value,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
