// ignore_for_file: invalid_use_of_visible_for_testing_member
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
    this.enableEnd = false,
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
    final ScrollPosition scrollPosition = position as ScrollPosition;

    print(
        'test value=$value pixels=${position.pixels} activity=${scrollPosition.activity.runtimeType}');

    //用户手离开屏幕还带有速度(快速拖动离开屏幕)
    // ignore: invalid_use_of_protected_member
    if (scrollPosition.activity is BallisticScrollActivity) {
      //滚动距离未越界，或者不能下拉刷新，交给系统处理
    }

    // 命中-顶部边界
    if ((value < position.minScrollExtent &&
        position.minScrollExtent >= position.pixels)) {
      if (!enableStart) {
        //不再继续越界滚动
        return value - position.pixels;
      }
      double topExtra = childExtent - maxStartScrollExtent;
      //是否超过最大滚动距离
      bool overMaxStartScrollExtent =
          value < topExtra && topExtra < position.pixels;
      if (overMaxStartScrollExtent) {
        //不再继续越界滚动
        return value - position.pixels;
      }
    }

    // 命中-底部边界
    if (position.maxScrollExtent < value) {
      if (!enableEnd) {
        //不再继续越界滚动
        return value - position.pixels;
      }
      double endExtent = position.maxScrollExtent + maxEndScrollExtent;

      //是否超过最大滚动距离
      bool overMaxScrollExtent =
          value > endExtent && endExtent > position.pixels;
      if (overMaxScrollExtent) {
        //不再继续越界滚动
        return value - position.pixels;
      }
    }

    return 0.0;
  }
}
