import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';

/// A single-select list that pushes as its own page instead of a centered
/// dialog, returning the tapped option through the navigator.
class OptionsPickerPage<T> extends StatefulWidget {
  const OptionsPickerPage({
    super.key,
    required this.title,
    required this.options,
    required this.value,
    required this.textBuilder,
  });

  final String title;
  final List<T> options;
  final T value;
  final String Function(T value) textBuilder;

  @override
  State<OptionsPickerPage<T>> createState() => _OptionsPickerPageState<T>();
}

class _OptionsPickerPageState<T> extends State<OptionsPickerPage<T>> {
  bool _popped = false;

  void _select(T value) {
    if (_popped) return;
    _popped = true;
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: widget.title,
      body: RadioGroup<T>(
        groupValue: widget.value,
        onChanged: (value) {
          if (value == null) return;
          _select(value);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16 + 64),
          children: [
            for (final option in widget.options)
              ListItem.radio(
                value: option,
                title: Text(widget.textBuilder(option)),
                onTap: () => _select(option),
              ),
          ],
        ),
      ),
    );
  }
}
