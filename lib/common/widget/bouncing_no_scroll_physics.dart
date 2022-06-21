import 'package:flutter/material.dart';

///控制越界不可继续拖动
class BouncingNoScrollPhysics extends BouncingScrollPhysics {
  final bool top;
  final bool bottom;

  const BouncingNoScrollPhysics({
    this.top = false,
    this.bottom = false,
    ScrollPhysics? parent,
  }) : super(parent: parent);

  @override
  BouncingNoScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return BouncingNoScrollPhysics(
      parent: buildParent(ancestor),
      top: top,
      bottom: bottom,
    );
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    // hit top edge
    if (value < position.minScrollExtent &&
        position.minScrollExtent < position.pixels &&
        top) {
      return value - position.pixels;
    }

    // hit bottom edge
    if (position.pixels < position.maxScrollExtent &&
        position.maxScrollExtent < value &&
        bottom) {
      return value - position.pixels;
    }
    return 0.0;
  }
}
