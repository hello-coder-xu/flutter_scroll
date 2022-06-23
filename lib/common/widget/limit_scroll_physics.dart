import 'package:flutter/material.dart';

///限制物理滚动
class LimitScrollPhysics extends BouncingScrollPhysics {
  /// 能否越界-开始位置
  final bool enableStart;

  /// 能否越界-结束位置
  final bool enableEnd;

  /// 子视图的距离(宽度或高度)
  final double childExtent;

  /// 最大滚动距离-开始位置-(包括子视图距离)
  final double maxStartScrollExtent;

  /// 最大滚动距离-结束位置-(包括子视图距离)
  final double maxEndScrollExtent;

  const LimitScrollPhysics({
    this.enableStart = true,
    this.enableEnd = true,
    this.childExtent = 50,
    this.maxStartScrollExtent = 100,
    this.maxEndScrollExtent = 100,
    ScrollPhysics? parent,
  })  : assert(
          maxStartScrollExtent >= childExtent ||
              maxEndScrollExtent >= childExtent,
          '最大滚动距离需要大于登录子视图距离',
        ),
        super(parent: parent);

  @override
  LimitScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return LimitScrollPhysics(
      parent: buildParent(ancestor),
      enableStart: enableStart,
      enableEnd: enableEnd,
      childExtent: childExtent,
      maxStartScrollExtent: maxStartScrollExtent,
      maxEndScrollExtent: maxEndScrollExtent,
    );
  }

  /// 参数说明
  /// position ： 上次位移信息
  /// value    :  本次位移
  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    print(
        'test enableStart=$enableStart value=$value minScrollExtent=${position.minScrollExtent} pixels=${position.pixels} result=${value - position.pixels}');

    // 命中-顶部边界
    if (value < position.minScrollExtent &&
        position.minScrollExtent >= position.pixels) {
      if (!enableStart) {
        //不再继续越界滚动
        return value - position.pixels;
      }
      double topExtra = childExtent - maxStartScrollExtent;
      //是否超过最大滚动距离
      bool overMaxScrollExtent = value < topExtra && topExtra < position.pixels;
      if (overMaxScrollExtent) {
        //不再继续越界滚动
        return value - position.pixels;
      }
    }

    // 命中-底部边界
    if (position.pixels < position.maxScrollExtent &&
        position.maxScrollExtent < value &&
        enableEnd) {
      return value - position.pixels;
    }

    return 0.0;
  }
}
