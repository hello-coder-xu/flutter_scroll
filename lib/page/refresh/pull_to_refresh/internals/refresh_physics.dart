// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_scroll/common/logger/logger_utils.dart';
import 'package:flutter_scroll/page/refresh/pull_to_refresh/internals/slivers.dart';
import 'package:flutter_scroll/page/refresh/pull_to_refresh/smart_refresher.dart';
import 'dart:math' as math;

// ignore: MUST_BE_IMMUTABLE
class RefreshPhysics extends ScrollPhysics {
  //最大滚动越界距离
  final double? maxOverScrollExtent;

  //定命中边界
  final double? topHitBoundary;

  //弹簧说明
  final SpringDescription? springDescription;

  //刷新控制器
  final RefreshController? controller;

  //更新标签
  final int? updateFlag;

  /// 弹跳时找出视口，用于计算页眉和页脚中的 layoutExtent
  /// 这对性能没有任何影响。 它只执行一次
  RenderViewport? viewportRender;

  /// 创建从边缘反弹回来的滚动物理。
  RefreshPhysics({
    ScrollPhysics? parent,
    this.updateFlag,
    this.springDescription,
    this.controller,
    this.topHitBoundary,
    this.maxOverScrollExtent,
  }) : super(parent: parent);

  ///提供给外部混入
  @override
  RefreshPhysics applyTo(ScrollPhysics? ancestor) {
    return RefreshPhysics(
      parent: buildParent(ancestor),
      updateFlag: updateFlag,
      springDescription: springDescription,
      topHitBoundary: topHitBoundary,
      controller: controller,
      maxOverScrollExtent: maxOverScrollExtent,
    );
  }

  RenderViewport? findViewport(BuildContext? context) {
    if (context == null) {
      return null;
    }
    RenderViewport? result;
    context.visitChildElements((Element e) {
      final RenderObject? renderObject = e.findRenderObject();
      if (renderObject is RenderViewport) {
        assert(result == null);
        result = renderObject;
      } else {
        result = findViewport(e);
      }
    });
    return result;
  }

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) {
    Logger.write('test RefreshPhysics shouldAcceptUserOffset');
    if (parent is NeverScrollableScrollPhysics) {
      return false;
    }
    return true;
  }

  // 这样做似乎很奇怪，但我没有选择这样做来更新状态值（enablePullDown 和 enablePullUp），
  // 在 Scrollable.dart _shouldUpdatePosition 方法中，它使用physics.runtimeType 来检查两个物理是否相同，这个
  // 会导致newPhysics是否应该替换oldPhysics，如果flutter可以提供“shouldUpdate”等方法，
  // 它可以完美地工作。
  @override
  Type get runtimeType {
    Logger.write('test RefreshPhysics runtimeType=$updateFlag');
    if (updateFlag == 0) {
      return RefreshPhysics;
    } else {
      return BouncingScrollPhysics;
    }
  }

  ///将物理应用到用户偏移
  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    Logger.write('test RefreshPhysics applyPhysicsToUserOffset');
    viewportRender ??=
        findViewport(controller!.position?.context.storageContext);
    if (offset > 0.0 && viewportRender?.firstChild is! RenderSliverRefresh) {
      return parent!.applyPhysicsToUserOffset(position, offset);
    }
    //如果越界
    if (position.outOfRange) {
      final double overscrollPastStart =
          math.max(position.minScrollExtent - position.pixels, 0.0);
      final double overscrollPastEnd =
          math.max(position.pixels - position.maxScrollExtent, 0.0);
      final double overscrollPast =
          math.max(overscrollPastStart, overscrollPastEnd);
      final bool easing = (overscrollPastStart > 0.0 && offset < 0.0) ||
          (overscrollPastEnd > 0.0 && offset > 0.0);

      final double friction = easing
          // 在缓解过度滚动与张紧时施加较小的阻力。
          ? frictionFactor(
              (overscrollPast - offset.abs()) / position.viewportDimension)
          : frictionFactor(overscrollPast / position.viewportDimension);
      final double direction = offset.sign;
      return direction * _applyFriction(overscrollPast, offset.abs(), friction);
    }
    return super.applyPhysicsToUserOffset(position, offset);
  }

  ///施加摩擦
  static double _applyFriction(
      double extentOutside, double absDelta, double gamma) {
    Logger.write('test RefreshPhysics _applyFriction');
    assert(absDelta > 0);
    double total = 0.0;
    if (extentOutside > 0) {
      final double deltaToLimit = extentOutside / gamma;
      if (absDelta < deltaToLimit) return absDelta * gamma;
      total += extentOutside;
      absDelta -= deltaToLimit;
    }
    return total + absDelta;
  }

  ///摩擦系数
  double frictionFactor(double overscrollFraction) =>
      0.52 * math.pow(1 - overscrollFraction, 2);

  ///应用边界条件
  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    Logger.write('test RefreshPhysics applyBoundaryConditions');
    final ScrollPosition scrollPosition = position as ScrollPosition;
    viewportRender ??=
        findViewport(controller!.position?.context.storageContext);
    //判断能否下拉刷新
    final bool enablePullDown = viewportRender == null
        ? false
        : viewportRender!.firstChild is RenderSliverRefresh;
    //滚动距离未越界，或者不能下拉刷新，交给系统处理
    if (position.pixels - value > 0.0 && !enablePullDown) {
      return parent!.applyBoundaryConditions(position, value);
    }
    double topExtra = 0.0;
    if (enablePullDown) {
      final RenderSliverRefresh sliverHeader =
          viewportRender!.firstChild as RenderSliverRefresh;
      topExtra = sliverHeader.hasLayoutExtent
          ? 0.0
          : sliverHeader.refreshIndicatorLayoutExtent;
    }
    final double topBoundary =
        position.minScrollExtent - maxOverScrollExtent! - topExtra;

    //用户手离开屏幕还带有速度(快速拖动离开屏幕)
    // ignore: invalid_use_of_protected_member
    if (scrollPosition.activity is BallisticScrollActivity) {
      if (topHitBoundary != double.infinity) {
        if (value < -topHitBoundary! && -topHitBoundary! <= position.pixels) {
          // hit top edge
          return value + topHitBoundary!;
        }
      }
    }
    if (maxOverScrollExtent != double.infinity &&
        value < topBoundary &&
        topBoundary < position.pixels) {
      return value - topBoundary;
    }

    // 用户手在屏幕上拖动
    // ignore: invalid_use_of_protected_member
    if (scrollPosition.activity is DragScrollActivity) {
      if (maxOverScrollExtent != double.infinity &&
          value < position.pixels &&
          position.pixels <= topBoundary) {
        return value - position.pixels;
      }
    }
    return 0.0;
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    Logger.write('test RefreshPhysics createBallisticSimulation');
    viewportRender ??=
        findViewport(controller!.position?.context.storageContext);

    final bool enablePullDown = viewportRender == null
        ? false
        : viewportRender!.firstChild is RenderSliverRefresh;
    if (velocity < 0.0 && !enablePullDown) {
      return parent!.createBallisticSimulation(position, velocity);
    }
    return super.createBallisticSimulation(position, velocity);
  }
}
