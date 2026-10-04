import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A column where one designated child — the announcement tile — takes whatever
/// vertical room the fixed cards leave over, clamped to a floor. When the fixed
/// cards alone outgrow the viewport the flow reports the taller height instead
/// of overflowing, so the scroll view around it moves the whole column.
///
/// It mirrors the orb column's elastic flow so the desktop split's two columns
/// fill the same height: the left column grows the orb, the right one grows the
/// announcement.
class DetailsElasticFlow extends MultiChildRenderObjectWidget {
  const DetailsElasticFlow({
    super.key,
    required this.viewportHeight,
    required this.flexIndex,
    required this.flexMin,
    required super.children,
  });

  final double viewportHeight;

  /// Index of the child that absorbs the slack; the rest keep their own height.
  final int flexIndex;

  /// The flex child never shrinks below this, so a short announcement keeps the
  /// deck-row look and an overflowing column scrolls instead of crushing it.
  final double flexMin;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderDetailsElasticFlow(
        viewportHeight: viewportHeight,
        flexIndex: flexIndex,
        flexMin: flexMin,
      );

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderDetailsElasticFlow renderObject,
  ) {
    renderObject
      ..viewportHeight = viewportHeight
      ..flexIndex = flexIndex
      ..flexMin = flexMin;
  }
}

class _DetailsElasticFlowParentData extends ContainerBoxParentData<RenderBox> {}

class RenderDetailsElasticFlow extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _DetailsElasticFlowParentData>,
        RenderBoxContainerDefaultsMixin<
          RenderBox,
          _DetailsElasticFlowParentData
        > {
  RenderDetailsElasticFlow({
    required double viewportHeight,
    required int flexIndex,
    required double flexMin,
  }) : _viewportHeight = viewportHeight,
       _flexIndex = flexIndex,
       _flexMin = flexMin;

  double _viewportHeight;
  int _flexIndex;
  double _flexMin;

  double get viewportHeight => _viewportHeight;
  set viewportHeight(double value) {
    if (_viewportHeight == value) return;
    _viewportHeight = value;
    markNeedsLayout();
  }

  int get flexIndex => _flexIndex;
  set flexIndex(int value) {
    if (_flexIndex == value) return;
    _flexIndex = value;
    markNeedsLayout();
  }

  double get flexMin => _flexMin;
  set flexMin(double value) {
    if (_flexMin == value) return;
    _flexMin = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! _DetailsElasticFlowParentData) {
      child.parentData = _DetailsElasticFlowParentData();
    }
  }

  double _widthFor(BoxConstraints constraints) =>
      constraints.hasBoundedWidth ? constraints.maxWidth : constraints.minWidth;

  double _flexHeight(double restHeight) =>
      math.max(flexMin, viewportHeight - restHeight);

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final width = _widthFor(constraints);
    final tailConstraints = BoxConstraints(minWidth: width, maxWidth: width);
    var restHeight = 0.0;
    var index = 0;
    var child = firstChild;
    while (child != null) {
      if (index != flexIndex) {
        restHeight += child.getDryLayout(tailConstraints).height;
      }
      index++;
      child = childAfter(child);
    }
    final content = restHeight + _flexHeight(restHeight);
    return constraints.constrain(
      Size(width, math.max(viewportHeight, content)),
    );
  }

  @override
  void performLayout() {
    final width = _widthFor(constraints);
    final tailConstraints = BoxConstraints(minWidth: width, maxWidth: width);
    var restHeight = 0.0;
    var index = 0;
    var child = firstChild;
    while (child != null) {
      if (index != flexIndex) {
        child.layout(tailConstraints, parentUsesSize: true);
        restHeight += child.size.height;
      }
      index++;
      child = childAfter(child);
    }

    final flexHeight = _flexHeight(restHeight);
    index = 0;
    child = firstChild;
    while (child != null) {
      if (index == flexIndex) {
        child.layout(
          BoxConstraints.tightFor(width: width, height: flexHeight),
          parentUsesSize: true,
        );
      }
      index++;
      child = childAfter(child);
    }

    final content = restHeight + flexHeight;
    size = constraints.constrain(
      Size(width, math.max(viewportHeight, content)),
    );

    var offset = 0.0;
    child = firstChild;
    while (child != null) {
      _dataOf(child).offset = Offset(0, offset);
      offset += child.size.height;
      child = childAfter(child);
    }
  }

  _DetailsElasticFlowParentData _dataOf(RenderBox child) =>
      child.parentData! as _DetailsElasticFlowParentData;

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}
