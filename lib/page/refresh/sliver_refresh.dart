import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';

class SliverRefresh extends SingleChildRenderObjectWidget {
  final double refreshIndicatorLayoutExtent;

  const SliverRefresh({
    Key? key,
    required Widget child,
    this.refreshIndicatorLayoutExtent = 0.0,
  }) : super(
          key: key,
          child: child,
        );

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderSliverRefresh(
      refreshIndicatorExtent: refreshIndicatorLayoutExtent,
    );
  }
}

class RenderSliverRefresh extends RenderSliverSingleBoxAdapter {
  RenderSliverRefresh({
    RenderBox? child,
    required double refreshIndicatorExtent,
  }) : _refreshIndicatorExtent = refreshIndicatorExtent {
    this.child = child;
  }

  double layoutExtentOffsetCompensation = 0.0;

  double get refreshIndicatorLayoutExtent => _refreshIndicatorExtent;
  final double _refreshIndicatorExtent;

  @override
  void performLayout() {
    const double layoutExtent = 0;
    if (layoutExtent != layoutExtentOffsetCompensation) {
      geometry = SliverGeometry(
        scrollOffsetCorrection: layoutExtent - layoutExtentOffsetCompensation,
      );

      layoutExtentOffsetCompensation = layoutExtent;
      return;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.paintChild(child!, Offset(offset.dx, offset.dy));
  }
}
