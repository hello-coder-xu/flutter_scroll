import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class ListViewHeader extends SingleChildRenderObjectWidget {
  const ListViewHeader({
    Key? key,
    Widget? child,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderListViewHeader();
  }
}

class RenderListViewHeader extends RenderSliverSingleBoxAdapter {
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
    final bool active = constraints.overlap < 0.0;
    //滚动时重合大小
    final double overScrolledExtent =
        constraints.overlap < 0.0 ? constraints.overlap.abs() : 0.0;
    if (active) {
      print("active "
          "overlap=${constraints.overlap}  "
          "overScrolledExtent=$overScrolledExtent  "
          "layoutExtent=$childExtent  "
          "diff=${overScrolledExtent - childExtent}  "
          "scrollExtent=$childExtent  "
          "paintOrigin=${min(overScrolledExtent - childExtent, 0)}  "
          "paintExtent=${max(max(child!.size.height, childExtent), 0.0)}  "
          "maxPaintExtent=${max(max(child!.size.height, childExtent), 0.0)}  "
          "layoutExtent=${min(overScrolledExtent, childExtent)}  "
          "");
      geometry = SliverGeometry(
        // sliver 可以滚动的范围
        scrollExtent: childExtent,
        // 绘制起始位置 (不会影响下一个sliver的layoutExtent,但是会影响下一个sliver的paintExtent)
        paintOrigin: min(overScrolledExtent - childExtent, 0),
        // 绘制范围
        paintExtent: max(max(child!.size.height, childExtent), 0.0),
        // 最大绘制大小
        maxPaintExtent: max(max(child!.size.height, childExtent), 0.0),
        // 布局占位(当前sliver的top到下一个silver的top位置，默认是paintExtent,会影响下一个Sliver的layout位置)
        layoutExtent: min(overScrolledExtent, childExtent),
      );
    } else {
      /// 如果不想显示可以直接设置为 zero
      geometry = SliverGeometry.zero;
    }
    setChildParentData(child!, constraints, geometry!);
  }
}
