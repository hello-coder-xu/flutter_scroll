import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class PageViewFooter extends SingleChildRenderObjectWidget {
  const PageViewFooter({
    Key? key,
    Widget? child,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderPageViewFooter();
  }
}

class RenderPageViewFooter extends RenderSliverSingleBoxAdapter {

  ///是否到到底部
  bool _computeIfFull(SliverConstraints cons) {
    final RenderViewport viewport = parent as RenderViewport;
    RenderSliver? sliverP = viewport.firstChild;
    double totalScrollExtent = cons.precedingScrollExtent;
    while (sliverP != this) {
      if (sliverP is RenderPageViewFooter) {
        totalScrollExtent -= sliverP.geometry!.scrollExtent;
        break;
      }
      sliverP = viewport.childAfter(sliverP!);
    }
    // consider about footer layoutExtent,it should be subtracted it's height
    return totalScrollExtent > cons.viewportMainAxisExtent;
  }



  @override
  void performLayout() {
    if (child == null) {
      geometry = SliverGeometry.zero;
      return;
    }
    //向下传递布局约束
    child!.layout(constraints.asBoxConstraints(), parentUsesSize: true);
    //获取控件正常显示大小
    double childExtent;
    switch (constraints.axis) {
      case Axis.horizontal:
        childExtent = child!.size.width;
        break;
      case Axis.vertical:
        childExtent = child!.size.height;
        break;
    }

    //获取控件正常显示的绘制大小
    final double paintedChildSize =
    calculatePaintOffset(constraints, from: 0.0, to: childExtent);

    assert(paintedChildSize.isFinite);
    assert(paintedChildSize >= 0.0);
    //是否为活动的，overlap：当前控件与顶部控件重合距离
    final bool active = _computeIfFull(constraints);
    if (active) {
      print("active "
          "overlap=${constraints.overlap}  "
          "layoutExtent=$childExtent  "
          "scrollExtent=$childExtent  "
          "paintOrigin=0"
          "paintExtent=$childExtent  "
          "maxPaintExtent=$childExtent  "
          "remainingPaintExtent=${constraints.remainingPaintExtent}  "
          "");
      geometry = SliverGeometry(
        // sliver 可以滚动的范围
        scrollExtent: childExtent,
        paintOrigin: 0,
        // 绘制范围
        paintExtent: childExtent,
        // 最大绘制大小
        maxPaintExtent: childExtent,
        // 布局占位(当前sliver的top到下一个silver的top位置，默认是paintExtent,会影响下一个Sliver的layout位置)
        layoutExtent: 0,
      );

    } else {
      /// 如果不想显示可以直接设置为 zero
      geometry = SliverGeometry.zero;
    }
    setChildParentData(child!, constraints, geometry!);
  }
}
