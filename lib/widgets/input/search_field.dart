import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/state.dart';
import 'package:reclash/widgets/base/inherited.dart';
import 'package:reclash/widgets/feedback/tooltip.dart';

/// Below this many items a sheet is short enough to scan without a search.
const sheetSearchMinItemCount = 10;

/// A regex toggle that rides inside the search field's trailing edge rather
/// than the app bar, so the control sits over the field it filters.
class RegexSearchToggle extends StatelessWidget {
  const RegexSearchToggle({
    super.key,
    required this.active,
    required this.onChanged,
  });

  final bool active;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return IconButton(
      isSelected: active,
      tooltip: context.appLocalizations.regexSearch,
      onPressed: () => onChanged(!active),
      icon: GlyphIcon(
        AppGlyphs.code,
        size: 20,
        color: active ? colorScheme.primary : null,
      ),
    ).withAppTooltip();
  }
}

class SearchField extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool useRegex;
  final ValueChanged<bool>? onRegexChange;

  const SearchField({
    super.key,
    required this.onChanged,
    this.onSubmitted,
    this.controller,
    this.focusNode,
    this.useRegex = false,
    this.onRegexChange,
  });

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  TextEditingController? _ownedController;
  FocusNode? _ownedFocusNode;

  TextEditingController get _controller =>
      widget.controller ?? (_ownedController ??= TextEditingController());

  FocusNode get _focusNode =>
      widget.focusNode ?? (_ownedFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(SearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.focusNode, widget.focusNode)) {
      (oldWidget.focusNode ?? _ownedFocusNode)?.removeListener(
        _handleFocusChange,
      );
      _focusNode.addListener(_handleFocusChange);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _ownedController?.dispose();
    _ownedFocusNode?.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() {});
    }
  }

  void _handleClear() {
    _controller.clear();
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final onRegexChange = widget.onRegexChange;
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _controller,
      builder: (_, value, _) {
        // The toggle surfaces while the field drives the search: on focus, with
        // a live query, or while regex stays on so the user can switch it off.
        final showRegex =
            onRegexChange != null &&
            (_focusNode.hasFocus || widget.useRegex || value.text.isNotEmpty);
        final clear = value.text.isEmpty
            ? null
            : IconButton(
                tooltip: appLocalizations.clearSearch,
                onPressed: _handleClear,
                icon: const GlyphIcon(AppGlyphs.close, size: 20),
              ).withAppTooltip();
        final trailing = <Widget>[
          if (showRegex)
            RegexSearchToggle(active: widget.useRegex, onChanged: onRegexChange),
          ?clear,
        ];
        return TextField(
          controller: _controller,
          focusNode: _focusNode,
          textInputAction: TextInputAction.search,
          inputFormatters: TextInputLimits.limit(TextInputLimits.search),
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          decoration: InputDecoration(
            hintText: appLocalizations.search,
            prefixIcon: const GlyphIcon(AppGlyphs.search, size: 20),
            suffixIcon: trailing.isEmpty
                ? null
                : Row(mainAxisSize: MainAxisSize.min, children: trailing),
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
  final bool useRegex;
  final ValueChanged<bool>? onRegexChange;

  const DockedSearchBar({
    super.key,
    required this.onChanged,
    this.controller,
    this.focusNode,
    this.useRegex = false,
    this.onRegexChange,
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
          useRegex: useRegex,
          onRegexChange: onRegexChange,
        ),
      ),
    );
  }
}
