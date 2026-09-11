import 'dart:math' as math;

import 'package:reclash/common/common.dart';
import 'package:reclash/views/dashboard/widgets/hero_layout.dart';
import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';

const _orbResizeDuration = Duration(milliseconds: 260);

class _HeroElasticFlowParentData extends ContainerBoxParentData<RenderBox> {}

/// A column whose first child — the orb slot — takes whatever the rest leaves
/// over, clamped to a band. When the rest alone outgrows the viewport the flow
/// reports the taller height instead of overflowing, so the scroll view around
/// it moves the whole board.
class HeroElasticFlow extends MultiChildRenderObjectWidget {
  HeroElasticFlow({
    super.key,
    required this.viewportHeight,
    required this.headMin,
    required this.headMax,
    required Widget head,
    required List<Widget> tail,
  }) : super(children: [head, ...tail]);

  final double viewportHeight;
  final double headMin;
  final double headMax;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderHeroElasticFlow(
        viewportHeight: viewportHeight,
        headMin: headMin,
        headMax: headMax,
      );

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderHeroElasticFlow renderObject,
  ) {
    renderObject
      ..viewportHeight = viewportHeight
      ..headMin = headMin
      ..headMax = headMax;
  }
}

class RenderHeroElasticFlow extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _HeroElasticFlowParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _HeroElasticFlowParentData> {
  RenderHeroElasticFlow({
    required double viewportHeight,
    required double headMin,
    required double headMax,
  }) : _viewportHeight = viewportHeight,
       _headMin = headMin,
       _headMax = headMax;

  double _viewportHeight;
  double _headMin;
  double _headMax;

  double get viewportHeight => _viewportHeight;
  set viewportHeight(double value) {
    if (_viewportHeight == value) return;
    _viewportHeight = value;
    markNeedsLayout();
  }

  double get headMin => _headMin;
  set headMin(double value) {
    if (_headMin == value) return;
    _headMin = value;
    markNeedsLayout();
  }

  double get headMax => _headMax;
  set headMax(double value) {
    if (_headMax == value) return;
    _headMax = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! _HeroElasticFlowParentData) {
      child.parentData = _HeroElasticFlowParentData();
    }
  }

  double _widthFor(BoxConstraints constraints) =>
      constraints.hasBoundedWidth ? constraints.maxWidth : constraints.minWidth;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final head = firstChild;
    if (head == null) return constraints.smallest;
    final width = _widthFor(constraints);
    final tailConstraints = BoxConstraints(minWidth: width, maxWidth: width);
    var tailHeight = 0.0;
    var child = childAfter(head);
    while (child != null) {
      tailHeight += child.getDryLayout(tailConstraints).height;
      child = childAfter(child);
    }
    final headSize = heroOrbSizeFor(
      viewportHeight - tailHeight,
      min: headMin,
      max: headMax,
    );
    return constraints.constrain(
      Size(width, math.max(viewportHeight, headSize + tailHeight)),
    );
  }

  @override
  void performLayout() {
    final head = firstChild;
    if (head == null) {
      size = constraints.smallest;
      return;
    }
    final width = _widthFor(constraints);
    final tailConstraints = BoxConstraints(minWidth: width, maxWidth: width);
    var tailHeight = 0.0;
    var child = childAfter(head);
    while (child != null) {
      child.layout(tailConstraints, parentUsesSize: true);
      tailHeight += child.size.height;
      child = childAfter(child);
    }

    final headSize = heroOrbSizeFor(
      viewportHeight - tailHeight,
      min: headMin,
      max: headMax,
    );
    head.layout(
      BoxConstraints.tightFor(
        width: math.min(headSize, width),
        height: headSize,
      ),
      parentUsesSize: true,
    );

    final content = head.size.height + tailHeight;
    final height = math.max(viewportHeight, content);
    size = constraints.constrain(Size(width, height));

    // The board centres as a whole: centring the orb alone would push the
    // cards below it off the bottom of a tall phone.
    var offset = math.max(0.0, (size.height - content) / 2);
    _dataOf(head).offset = Offset((width - head.size.width) / 2, offset);
    offset += head.size.height;
    child = childAfter(head);
    while (child != null) {
      _dataOf(child).offset = Offset(0, offset);
      offset += child.size.height;
      child = childAfter(child);
    }
  }

  _HeroElasticFlowParentData _dataOf(RenderBox child) =>
      child.parentData! as _HeroElasticFlowParentData;

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}

/// Resolves the orb's own size from the room its slot was given and animates
/// across the 8px steps, so the orb glides instead of snapping.
class HeroOrbSlot extends StatelessWidget {
  const HeroOrbSlot({
    super.key,
    required this.min,
    required this.max,
    required this.builder,
  });

  final double min;
  final double max;
  final Widget Function(BuildContext context, double size) builder;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final available = math.min(
        box.hasBoundedWidth ? box.maxWidth : max,
        box.hasBoundedHeight ? box.maxHeight : max,
      );
      final target = heroOrbSizeFor(available, min: min, max: max);
      return TweenAnimationBuilder<double>(
        tween: Tween<double>(end: target),
        duration: context.motionDuration(_orbResizeDuration),
        curve: Easing.standard,
        builder: (context, size, _) => SizedBox.square(
          dimension: size,
          child: Center(child: builder(context, size)),
        ),
      );
    },
  );
}
