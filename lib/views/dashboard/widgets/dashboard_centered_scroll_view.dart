import 'package:flutter/widgets.dart';

class DashboardCenteredScrollView extends StatelessWidget {
  const DashboardCenteredScrollView({
    super.key,
    required this.child,
    this.controller,
    this.alignment = Alignment.center,
  });

  final ScrollController? controller;
  final AlignmentGeometry alignment;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          controller: controller,
          primary: false,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Align(alignment: alignment, child: child),
          ),
        );
      },
    );
  }
}
