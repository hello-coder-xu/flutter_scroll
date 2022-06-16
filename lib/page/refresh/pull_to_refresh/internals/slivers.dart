import 'package:flutter/widgets.dart';
import 'dart:math' as math;
import 'package:flutter/rendering.dart';
import '../smart_refresher.dart';

/// 渲染标题条小部件
class SliverRefresh extends SingleChildRenderObjectWidget {
  const SliverRefresh({
    Key? key,
    this.paintOffsetY,
    this.refreshIndicatorLayoutExtent = 0.0,
    this.floating = false,
    Widget? child,
    this.refreshStyle,
  })  : assert(refreshIndicatorLayoutExtent >= 0.0),
        super(key: key, child: child);

  /// 指标应在条子中占据的空间量
  /// 处于刷新模式时的静止状态。
  final double refreshIndicatorLayoutExtent;

  /// _RenderSliverRefresh 将在可用的
  /// 无论哪种方式都有空间，但这会指示 _RenderSliverRefresh
  /// 关于是否也占用任何 layoutExtent 空间。
  final bool floating;

  /// 标题指示器显示样式
  final RefreshStyle? refreshStyle;

  /// headerOffset 头部指示器布局偏差 Y 坐标，多为 FrontStyle
  final double? paintOffsetY;

  @override
  RenderSliverRefresh createRenderObject(BuildContext context) {
    return RenderSliverRefresh(
      refreshIndicatorExtent: refreshIndicatorLayoutExtent,
      hasLayoutExtent: floating,
      paintOffsetY: paintOffsetY,
      refreshStyle: refreshStyle,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderSliverRefresh renderObject) {
    final RefreshStatus mode =
        SmartRefresher.of(context)!.controller.headerMode!.value;
    renderObject
      ..refreshIndicatorLayoutExtent = refreshIndicatorLayoutExtent
      ..hasLayoutExtent = floating
      ..context = context
      ..refreshStyle = refreshStyle
      ..updateFlag = mode == RefreshStatus.idle
      ..paintOffsetY = paintOffsetY;
  }
}

class RenderSliverRefresh extends RenderSliverSingleBoxAdapter {
  RenderSliverRefresh({
    required double refreshIndicatorExtent,
    required bool hasLayoutExtent,
    RenderBox? child,
    this.paintOffsetY,
    this.refreshStyle,
  })  : assert(refreshIndicatorExtent >= 0.0),
        _refreshIndicatorExtent = refreshIndicatorExtent,
        _hasLayoutExtent = hasLayoutExtent {
    this.child = child;
  }

  RefreshStyle? refreshStyle;
  late BuildContext context;

  // 指示器应在条子中占据的布局空间量
  // 处于刷新模式时的静止状态。
  double get refreshIndicatorLayoutExtent => _refreshIndicatorExtent;
  double _refreshIndicatorExtent;
  double? paintOffsetY;

  // 需要触发shouldAceppty用户偏移，否则进入二级或退出时不限制滚动
  // 如果您在状态更改时调用 applyNewDimession，它也会崩溃
  // 不知道为什么flutter会限制它，别无选择
  bool _updateFlag = false;

  set refreshIndicatorLayoutExtent(double value) {
    assert(value >= 0.0);
    if (value == _refreshIndicatorExtent) return;
    _refreshIndicatorExtent = value;
    markNeedsLayout();
  }

  // 子框将在可用空间中进行布局和绘制
  // 方式，但这决定了是否也占用任何
  // [SliverGeometry.layoutExtent] 空间与否。
  bool get hasLayoutExtent => _hasLayoutExtent;
  bool _hasLayoutExtent;

  set hasLayoutExtent(bool value) {
    if (value == _hasLayoutExtent) return;
    if (!value) {
      _updateFlag = true;
    }
    _hasLayoutExtent = value;
    markNeedsLayout();
  }

  // 这将跟踪先前应用的滚动偏移量到可滚动
  // 这样当 [refreshIndicatorLayoutExtent] 或 [hasLayoutExtent] 发生变化时，
  // 可以应用适当的增量来将所有内容保持在同一个地方
  // 视觉上。
  double layoutExtentOffsetCompensation = 0.0;

  @override
  double get centerOffsetAdjustment {
    return 0.0;
  }

  set updateFlag(u) {
    _updateFlag = u;
    markNeedsLayout();
  }

  @override
  void debugAssertDoesMeetConstraints() {
    assert(geometry!.debugAssertIsValid(informationCollector: () sync* {
      yield describeForError(
          'The RenderSliver that returned the offending geometry was');
    }));
    assert(() {
      if (geometry!.paintExtent > constraints.remainingPaintExtent) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
              'SliverGeometry has a paintOffset that exceeds the remainingPaintExtent from the constraints.'),
          describeForError(
              'The render object whose geometry violates the constraints is the following'),
          ErrorDescription(
            'The paintExtent must cause the child sliver to paint within the viewport, and so '
            'cannot exceed the remainingPaintExtent.',
          ),
        ]);
      }
      return true;
    }());
  }

  @override
  void performLayout() {
    if (_updateFlag) {
      // ignore_for_file: INVALID_USE_OF_PROTECTED_MEMBER
      // ignore_for_file: INVALID_USE_OF_VISIBLE_FOR_TESTING_MEMBER
      Scrollable.of(context)!.position.activity!.applyNewDimensions();
      _updateFlag = false;
    }
    // 该条子现在应该具有的新布局范围。
    final double layoutExtent =
        (_hasLayoutExtent ? 1.0 : 0.0) * _refreshIndicatorExtent;
    // 如果新的 layoutExtent 指令改变了，SliverGeometry 的
    // layoutExtent 将采用该值（在下一次 performLayout 运行时）。 转移
    // 首先滚动偏移，因此它不会使滚动位置突然跳跃。
    if (layoutExtent != layoutExtentOffsetCompensation) {
      geometry = SliverGeometry(
        scrollOffsetCorrection: layoutExtent - layoutExtentOffsetCompensation,
      );

      layoutExtentOffsetCompensation = layoutExtent;
      return;
    }
    bool active = constraints.overlap < 0.0 || layoutExtent > 0.0;
    final double overScrolledExtent =
        -(parent as RenderViewportBase).offset.pixels;
    child!.layout(
      constraints.asBoxConstraints(),
      parentUsesSize: true,
    );
    final double boxExtent = (constraints.axisDirection == AxisDirection.up ||
            constraints.axisDirection == AxisDirection.down)
        ? child!.size.height
        : child!.size.width;

    if (active) {
      final double needPaintExtent = math.min(
          math.max(
            math.max(
                    (constraints.axisDirection == AxisDirection.up ||
                            constraints.axisDirection == AxisDirection.down)
                        ? child!.size.height
                        : child!.size.width,
                    layoutExtent) -
                constraints.scrollOffset,
            0.0,
          ),
          constraints.remainingPaintExtent);
      switch (refreshStyle) {
        case RefreshStyle.follow:
          geometry = SliverGeometry(
            scrollExtent: layoutExtent,
            paintOrigin: -boxExtent - constraints.scrollOffset + layoutExtent,
            paintExtent: needPaintExtent,
            hitTestExtent: needPaintExtent,
            hasVisualOverflow: overScrolledExtent < boxExtent,
            maxPaintExtent: needPaintExtent,
            layoutExtent: math.min(needPaintExtent,
                math.max(layoutExtent - constraints.scrollOffset, 0.0)),
          );

          break;
        case RefreshStyle.unfollow:
          geometry = SliverGeometry(
            scrollExtent: layoutExtent,
            paintOrigin: math.min(
                -overScrolledExtent - constraints.scrollOffset,
                -boxExtent - constraints.scrollOffset + layoutExtent),
            paintExtent: needPaintExtent,
            hasVisualOverflow: overScrolledExtent < boxExtent,
            maxPaintExtent: needPaintExtent,
            layoutExtent: math.min(needPaintExtent,
                math.max(layoutExtent - constraints.scrollOffset, 0.0)),
          );

          break;
        case null:
          break;
      }
      setChildParentData(child!, constraints, geometry!);
    } else {
      geometry = SliverGeometry.zero;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.paintChild(child!, Offset(offset.dx, offset.dy + paintOffsetY!));
  }

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {}
}


class SliverRefreshBody extends SingleChildRenderObjectWidget {
  /// 创建一个包含单个框小部件的条子。
  const SliverRefreshBody({
    Key? key,
    Widget? child,
  }) : super(key: key, child: child);

  @override
  RenderSliverRefreshBody createRenderObject(BuildContext context) =>
      RenderSliverRefreshBody();
}

class RenderSliverRefreshBody extends RenderSliverSingleBoxAdapter {
  /// 创建一个包装 [RenderBox] 的 [RenderSliver]。
  RenderSliverRefreshBody({
    RenderBox? child,
  }) : super(child: child);

  @override
  void performLayout() {
    if (child == null) {
      geometry = SliverGeometry.zero;
      return;
    }
    child!.layout(constraints.asBoxConstraints(maxExtent: 1111111),
        parentUsesSize: true);
    double? childExtent;
    switch (constraints.axis) {
      case Axis.horizontal:
        childExtent = child!.size.width;
        break;
      case Axis.vertical:
        childExtent = child!.size.height;
        break;
    }
    if (childExtent == 1111111) {
      child!.layout(
          constraints.asBoxConstraints(
              maxExtent: constraints.viewportMainAxisExtent),
          parentUsesSize: true);
    }
    switch (constraints.axis) {
      case Axis.horizontal:
        childExtent = child!.size.width;
        break;
      case Axis.vertical:
        childExtent = child!.size.height;
        break;
    }
    final double paintedChildSize =
        calculatePaintOffset(constraints, from: 0.0, to: childExtent);
    final double cacheExtent =
        calculateCacheOffset(constraints, from: 0.0, to: childExtent);

    assert(paintedChildSize.isFinite);
    assert(paintedChildSize >= 0.0);
    geometry = SliverGeometry(
      scrollExtent: childExtent,
      paintExtent: paintedChildSize,
      cacheExtent: cacheExtent,
      maxPaintExtent: childExtent,
      hitTestExtent: paintedChildSize,
      hasVisualOverflow: childExtent > constraints.remainingPaintExtent ||
          constraints.scrollOffset > 0.0,
    );
    setChildParentData(child!, constraints, geometry!);
  }
}
