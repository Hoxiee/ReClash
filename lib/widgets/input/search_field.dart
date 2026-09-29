import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/state.dart';
import 'package:reclash/widgets/base/inherited.dart';

/// Below this many items a sheet is short enough to scan without a search.
const sheetSearchMinItemCount = 10;

class SearchField extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextEditingController? controller;
  final FocusNode? focusNode;

  const SearchField({
    super.key,
    required this.onChanged,
    this.onSubmitted,
    this.controller,
    this.focusNode,
  });

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  TextEditingController? _ownedController;

  TextEditingController get _controller =>
      widget.controller ?? (_ownedController ??= TextEditingController());

  @override
  void dispose() {
    _ownedController?.dispose();
    super.dispose();
  }

  void _handleClear() {
    _controller.clear();
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _controller,
      builder: (_, value, _) {
        return TextField(
          controller: _controller,
          focusNode: widget.focusNode,
          textInputAction: TextInputAction.search,
          inputFormatters: TextInputLimits.limit(TextInputLimits.search),
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          decoration: InputDecoration(
            hintText: appLocalizations.search,
            prefixIcon: const GlyphIcon(AppGlyphs.search, size: 20),
            suffixIcon: value.text.isEmpty
                ? null
                : IconButton(
                    tooltip: appLocalizations.clearSearch,
                    onPressed: _handleClear,
                    icon: const GlyphIcon(AppGlyphs.close, size: 20),
                  ),
          ),
        );
      },
    );
  }
}

/// A pill-shaped [SearchField] that docks to the bottom of a sheet or page, so
/// the list scrolls under it rather than under a full-width band.
class DockedSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;
  final FocusNode? focusNode;

  const DockedSearchBar({
    super.key,
    required this.onChanged,
    this.controller,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fieldPadding =
        (BottomInsetScope.dockedSearchHeight -
            globalState.measure.bodyLargeHeight) /
        2;
    return Padding(
      padding: EdgeInsets.only(
        left: BottomInsetScope.dockedSearchMargin,
        right: BottomInsetScope.dockedSearchMargin,
        bottom:
            BottomInsetScope.dockedSearchMargin +
            MediaQuery.paddingOf(context).bottom,
      ),
      child: Theme(
        data: theme.copyWith(
          inputDecorationTheme: theme.inputDecorationTheme.copyWith(
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHigh,
            border: AppShape.input.copyWith(borderRadius: AppRadius.full),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: fieldPadding,
            ),
          ),
        ),
        child: SearchField(
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
