part of 'list.dart';

class CommonSelectedListItem extends StatelessWidget {
  final bool isSelected;
  final bool isEditing;
  final Widget title;
  final VoidCallback onSelected;
  final VoidCallback onPressed;

  const CommonSelectedListItem({
    super.key,
    required this.isSelected,
    required this.onSelected,
    this.isEditing = false,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        color: Colors.transparent,
        child: CommonCard(
          radius: AppCorner.xl,
          type: CommonCardType.filled,
          isSelected: isSelected,
          onPressed: () {
            if (isEditing) {
              onSelected();
              return;
            }
            onPressed();
          },
          child: ListTile(
            minTileHeight: 32 + globalState.measure.bodyMediumHeight,
            minVerticalPadding: 12,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            trailing: SizedBox(
              width: 24,
              height: 24,
              child: CommonCheckBox(
                value: isSelected,
                isCircle: true,
                onChanged: (_) {
                  onSelected();
                },
              ),
            ),
            title: title,
          ),
        ),
      ),
    );
  }
}

class DecorationListItem extends StatelessWidget {
  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final bool? isSelected;
  final double? horizontalTitleGap;
  final EdgeInsetsGeometry? contentPadding;
  final VoidCallback? onPressed;
  final double? minVerticalPadding;
  final bool invalid;
  final _ListItemAction? _action;

  const DecorationListItem({
    super.key,
    this.contentPadding,
    required this.title,
    this.leading,
    this.trailing,
    this.subtitle,
    this.isSelected,
    this.onPressed,
    this.horizontalTitleGap,
    this.minVerticalPadding,
    this.invalid = false,
  }) : _action = null;

  DecorationListItem.toggle({
    super.key,
    this.contentPadding,
    this.leading,
    required this.title,
    this.subtitle,
    required bool value,
    ValueChanged<bool>? onChanged,
    this.isSelected,
    this.horizontalTitleGap,
    this.minVerticalPadding = 8,
    this.invalid = false,
  }) : trailing = null,
       onPressed = null,
       _action = _ToggleAction(value: value, onChanged: onChanged);

  DecorationListItem.options({
    super.key,
    this.contentPadding,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    required String dialogTitle,
    required List<Object?> options,
    required Object? value,
    required String Function(Object? value) textBuilder,
    String Function(Object? value)? subtitleBuilder,
    required ValueChanged<Object?> onChanged,
    this.isSelected,
    this.horizontalTitleGap,
    this.minVerticalPadding = 8,
    this.invalid = false,
  }) : onPressed = null,
       _action = _OptionsAction<Object?>(
         title: dialogTitle,
         options: options,
         value: value,
         textBuilder: textBuilder,
         subtitleBuilder: subtitleBuilder,
         onChanged: onChanged,
       );

  DecorationListItem.input({
    super.key,
    this.contentPadding,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    required String dialogTitle,
    required String value,
    String? suffixText,
    required ValueChanged<String?> onChanged,
    FormFieldValidator<String>? validator,
    int? maxLength,
    TextInputType? keyboardType,
    String? resetValue,
    this.isSelected,
    this.horizontalTitleGap,
    this.minVerticalPadding = 8,
    this.invalid = false,
  }) : onPressed = null,
       _action = _InputAction(
         title: dialogTitle,
         value: value,
         suffixText: suffixText,
         onChanged: onChanged,
         validator: validator,
         maxLength: maxLength,
         keyboardType: keyboardType,
         resetValue: resetValue,
       );

  DecorationListItem.open({
    super.key,
    this.contentPadding,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    required Widget widget,
    double? maxWidth,
    bool blur = true,
    bool forceFull = true,
    ValueChanged<dynamic>? onChanged,
    this.isSelected,
    this.horizontalTitleGap,
    this.minVerticalPadding = 8,
    this.invalid = false,
  }) : onPressed = null,
       _action = _OpenAction(
         widget: widget,
         maxWidth: maxWidth,
         blur: blur,
         forceFull: forceFull,
         onChanged: onChanged,
       );

  DecorationListItem.checkbox({
    super.key,
    this.contentPadding,
    this.leading,
    required this.title,
    this.subtitle,
    bool value = false,
    ValueChanged<bool?>? onChanged,
    this.isSelected,
    this.horizontalTitleGap,
    this.minVerticalPadding = 8,
    this.invalid = false,
  }) : trailing = null,
       onPressed = null,
       _action = _CheckboxAction(value: value, onChanged: onChanged);

  @override
  Widget build(BuildContext context) {
    final proxyDecorator =
        ProxyDecoratorProvider.of(context)?.isProxyDecorator ?? false;
    final position = ItemPositionProvider.of(context)?.position;
    final isStart = [
      ItemPosition.start,
      ItemPosition.startAndEnd,
    ].contains(position);
    final isEnd = [
      ItemPosition.end,
      ItemPosition.startAndEnd,
    ].contains(position);
    final borderRadius = AppRadius.vertical(
      top: isStart ? AppCorner.xl : AppCorner.none,
      bottom: isEnd ? AppCorner.xl : AppCorner.none,
    );
    Widget? effectiveTrailing = trailing;
    VoidCallback? effectiveOnPressed = onPressed;
    switch (_action) {
      case null:
        break;
      case final _ToggleAction toggleAction:
        effectiveOnPressed = toggleAction.onChanged == null
            ? null
            : () {
                toggleAction.onChanged!(!toggleAction.value);
              };
        effectiveTrailing = _tappableTrailing(
          context,
          Switch(value: toggleAction.value, onChanged: toggleAction.onChanged),
        );
      case final _OptionsAction<Object?> options:
        effectiveOnPressed = () async {
          final value = await dialogs.showCommonDialog<Object?>(
            child: OptionsDialog<Object?>(
              title: options.title,
              options: options.options,
              textBuilder: options.textBuilder,
              subtitleBuilder: options.subtitleBuilder,
              value: options.value,
            ),
          );
          options.onChanged(value);
        };
      case final _InputAction inputDelegate:
        effectiveOnPressed = () async {
          final value = await dialogs.showCommonDialog<String>(
            child: InputDialog(
              title: inputDelegate.title,
              value: inputDelegate.value,
              suffixText: inputDelegate.suffixText,
              resetValue: inputDelegate.resetValue,
              inputFormatters: inputDelegate.maxLength == null
                  ? null
                  : TextInputLimits.limit(inputDelegate.maxLength!),
              keyboardType: inputDelegate.keyboardType,
              validator: inputDelegate.validator,
            ),
          );
          inputDelegate.onChanged(value);
        };
      case final _OpenAction openDelegate:
        final child = openDelegate.widget;
        final onChanged = openDelegate.onChanged;
        return OpenContainer<dynamic>(
          transitionDuration: context.motionDuration(commonDuration),
          closedBuilder: (context, action) {
            Future<void> openAction() async {
              final isMobile = context.isMobileView;
              if (!isMobile || kDebugMode) {
                final res = await showExtend(
                  context,
                  props: ExtendProps(
                    blur: openDelegate.blur,
                    maxWidth: openDelegate.maxWidth,
                    forceFull: openDelegate.forceFull,
                  ),
                  builder: (_) {
                    return child;
                  },
                );
                if (onChanged != null) {
                  onChanged(res);
                }
                return;
              }
              action();
            }

            return _buildActionCard(
              proxyDecorator: proxyDecorator,
              borderRadius: borderRadius,
              isEnd: isEnd,
              onTap: openAction,
              trailing: effectiveTrailing,
            );
          },
          onClosed: onChanged,
          openBuilder: (_, action) {
            return child;
          },
        );
      case final _CheckboxAction checkboxDelegate:
        effectiveOnPressed = checkboxDelegate.onChanged == null
            ? null
            : () {
                checkboxDelegate.onChanged!(!checkboxDelegate.value);
              };
        effectiveTrailing = _tappableTrailing(
          context,
          CommonCheckBox(
            value: checkboxDelegate.value,
            onChanged: checkboxDelegate.onChanged,
          ),
        );
      case _RadioAction():
      case _NextAction():
      case _DefaultAction():
        break;
    }
    return _buildActionCard(
      proxyDecorator: proxyDecorator,
      borderRadius: borderRadius,
      isEnd: isEnd,
      trailing: effectiveTrailing,
      onTap: effectiveOnPressed,
    );
  }

  Widget _tappableTrailing(BuildContext context, Widget trailing) {
    return ExcludeFocus(
      child: ExcludeSemantics(child: IgnorePointer(child: trailing)),
    );
  }

  Widget _buildActionCard({
    required bool proxyDecorator,
    required BorderRadius borderRadius,
    required bool isEnd,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return CommonCard(
      shape: proxyDecorator == true
          ? LinearBorder.none
          : AppShape.of(borderRadius),
      isError: invalid,
      isSelected: isSelected,
      padding: EdgeInsets.zero,
      type: CommonCardType.filled,
      onPressed: proxyDecorator ? null : onTap,
      child: LayoutBuilder(
        builder: (_, constraints) {
          final isInfinite = constraints.maxHeight >= double.infinity;
          final tile = ListTile(
            leading: leading,
            contentPadding:
                contentPadding ?? const EdgeInsets.only(right: 16, left: 16),
            title: title,
            subtitle: subtitle,
            minVerticalPadding: minVerticalPadding ?? 6,
            minTileHeight: 54,
            horizontalTitleGap: horizontalTitleGap,
            trailing: trailing,
          );
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                fit: isInfinite ? FlexFit.loose : FlexFit.tight,
                child: tile,
              ),
              if (!invalid && proxyDecorator != true && !isEnd)
                const Divider(height: 0, indent: 14, endIndent: 14),
            ],
          );
        },
      ),
    );
  }
}

class SelectedDecorationListItem extends StatelessWidget {
  final bool isSelected;
  final bool isEditing;
  final Widget title;
  final Widget? subtitle;
  final VoidCallback onSelected;
  final VoidCallback onPressed;
  final double? horizontalTitleGap;
  final Widget? leading;
  final bool invalid;
  final double? minVerticalPadding;
  final Widget? trailing;

  const SelectedDecorationListItem({
    super.key,
    required this.isSelected,
    required this.onSelected,
    this.horizontalTitleGap,
    this.isEditing = false,
    this.invalid = false,
    required this.title,
    required this.onPressed,
    this.minVerticalPadding,
    this.subtitle,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return DecorationListItem(
      title: title,
      minVerticalPadding: minVerticalPadding,
      contentPadding: const EdgeInsets.only(left: 16, right: 0),
      isSelected: isSelected,
      invalid: invalid,
      leading: leading,
      horizontalTitleGap: horizontalTitleGap,
      onPressed: () {
        if (isEditing) {
          onSelected();
          return;
        }
        onPressed();
      },
      subtitle: subtitle,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ignore: use_null_aware_elements
          if (trailing != null) trailing!,
          CommonCheckBox(
            value: isSelected,
            isCircle: true,
            onChanged: (_) {
              onSelected();
            },
          ),
        ],
      ),
    );
  }
}
