part of 'list.dart';

typedef DecorationListItem = prism.DecorationListItem;

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
      trailing: CommonCheckBox(
        value: isSelected,
        isCircle: true,
        onChanged: (_) {
          onSelected();
        },
      ),
    );
  }
}
