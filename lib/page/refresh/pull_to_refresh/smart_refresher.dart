/*
    Author: Jpeng
    Email: peng8350@gmail.com
    createTime:2018-05-01 11:39
*/

import 'package:flutter/gestures.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_scroll/page/refresh/pull_to_refresh/indicator/classic_indicator.dart';
import 'package:flutter_scroll/page/refresh/pull_to_refresh/internals/indicator_wrap.dart';
import 'package:flutter_scroll/page/refresh/pull_to_refresh/internals/refresh_physics.dart';
import 'package:flutter_scroll/page/refresh/pull_to_refresh/internals/slivers.dart';

// ignore_for_file: INVALID_USE_OF_PROTECTED_MEMBER
// ignore_for_file: INVALID_USE_OF_VISIBLE_FOR_TESTING_MEMBER
// ignore_for_file: DEPRECATED_MEMBER_USE

/// global default indicator builder
typedef IndicatorBuilder = Widget Function();

/// 用于将刷新功能与物理连接的构建器
typedef RefresherBuilder = Widget Function(
    BuildContext context, RefreshPhysics physics);

/// 标题状态
enum RefreshStatus {
  /// 初始状态，当没有被过度滚动时，或在过度滚动之后
  /// 被取消或完成后，条子缩回。
  idle,

  /// 拖得足够远以至于 onRefresh 回调将回调
  canRefresh,

  /// 指标正在刷新，等待完成回调
  refreshing,

  /// 指标刷新完成
  completed,

  /// 指标刷新失败
  failed,
}

/// 标题指示器显示样式
enum RefreshStyle {
  /// 指示框始终跟随内容
  follow,

  /// 指示框跟随内容，当框到达顶部并且完全可见时，它不跟随内容。
  unfollow,
}

class SmartRefresher extends StatefulWidget {
  final Widget? child;

  final Widget? header;

  final VoidCallback? onRefresh;

  /// 控制内部状态
  final RefreshController controller;

  /// 子内容构建器
  final RefresherBuilder? builder;

  final Axis? scrollDirection;

  final bool? reverse;

  final ScrollController? scrollController;

  final bool? primary;

  final ScrollPhysics? physics;

  /// 从 ScrollView 复制，用于在 SingleChildView 中设置，而不是 ScrollView
  final double? cacheExtent;

  /// 从 ScrollView 复制，用于在 SingleChildView 中设置，而不是 ScrollView
  final DragStartBehavior? dragStartBehavior;

  const SmartRefresher(
      {Key? key,
      required this.controller,
      this.child,
      this.header,
      this.onRefresh,
      this.dragStartBehavior,
      this.primary,
      this.cacheExtent,
      this.reverse,
      this.physics,
      this.scrollDirection,
      this.scrollController})
      : builder = null,
        super(key: key);

  const SmartRefresher.builder({
    Key? key,
    required this.controller,
    required this.builder,
    this.onRefresh,
  })  : header = null,
        child = null,
        scrollController = null,
        scrollDirection = null,
        physics = null,
        reverse = null,
        dragStartBehavior = null,
        cacheExtent = null,
        primary = null,
        super(key: key);

  static SmartRefresher? of(BuildContext? context) {
    return context!.findAncestorWidgetOfExactType<SmartRefresher>();
  }

  static SmartRefresherState? ofState(BuildContext? context) {
    return context!.findAncestorStateOfType<SmartRefresherState>();
  }

  @override
  State<StatefulWidget> createState() {
    return SmartRefresherState();
  }
}

class SmartRefresherState extends State<SmartRefresher> {
  RefreshPhysics? _physics;
  bool _updatePhysics = false;
  double viewportExtent = 0;
  bool _canDrag = true;

  final RefreshIndicator defaultHeader = const ClassicHeader();

  //从子小部件构建Sliver
  List<Widget>? _buildSliversByChild(BuildContext context, Widget? child,
      RefreshConfiguration? configuration) {
    List<Widget>? slivers;
    if (child is ScrollView) {
      if (child is BoxScrollView) {
        //avoid system inject padding when own indicator top or bottom
        Widget sliver = child.buildChildLayout(context);
        if (child.padding != null) {
          slivers = [SliverPadding(sliver: sliver, padding: child.padding!)];
        } else {
          slivers = [sliver];
        }
      } else {
        slivers = List.from(child.buildSlivers(context), growable: true);
      }
    } else if (child is! Scrollable) {
      slivers = [
        SliverRefreshBody(
          child: child ?? Container(),
        )
      ];
    }
    slivers?.insert(
      0,
      widget.header ??
          (configuration?.headerBuilder != null
              ? configuration?.headerBuilder!()
              : null) ??
          defaultHeader,
    );
    return slivers;
  }

  ScrollPhysics _getScrollPhysics(
      RefreshConfiguration? conf, ScrollPhysics physics) {
    final bool isBouncingPhysics = physics is BouncingScrollPhysics ||
        (physics is AlwaysScrollableScrollPhysics &&
            ScrollConfiguration.of(context)
                    .getScrollPhysics(context)
                    .runtimeType ==
                BouncingScrollPhysics);
    return _physics = RefreshPhysics(
      dragSpeedRatio: conf?.dragSpeedRatio ?? 1,
      springDescription: conf?.springDescription ??
          const SpringDescription(
            mass: 2.2,
            stiffness: 150,
            damping: 16,
          ),
      controller: widget.controller,
      updateFlag: _updatePhysics ? 0 : 1,
      maxOverScrollExtent: conf?.maxOverScrollExtent ??
          (isBouncingPhysics ? double.infinity : 60.0),
      topHitBoundary:
          conf?.topHitBoundary ?? (isBouncingPhysics ? double.infinity : 0.0),
    ).applyTo(!_canDrag ? const NeverScrollableScrollPhysics() : physics);
  }

  // 构建 customScrollView
  Widget? _buildBodyBySlivers(
      Widget? childView, List<Widget>? slivers, RefreshConfiguration? conf) {
    Widget? body;
    if (childView is! Scrollable) {
      bool? primary = widget.primary;
      Key? key;
      double? cacheExtent = widget.cacheExtent;

      Axis? scrollDirection = widget.scrollDirection;
      bool? reverse = widget.reverse;
      ScrollController? scrollController = widget.scrollController;
      DragStartBehavior? dragStartBehavior = widget.dragStartBehavior;
      ScrollPhysics? physics = widget.physics;
      Key? center;
      double? anchor;
      ScrollViewKeyboardDismissBehavior? keyboardDismissBehavior;
      String? restorationId;
      Clip? clipBehavior;

      if (childView is ScrollView) {
        primary = primary ?? childView.primary;
        cacheExtent = cacheExtent ?? childView.cacheExtent;
        key = key ?? childView.key;
        reverse = reverse ?? childView.reverse;
        dragStartBehavior = dragStartBehavior ?? childView.dragStartBehavior;
        scrollDirection = scrollDirection ?? childView.scrollDirection;
        physics = physics ?? childView.physics;
        center = center ?? childView.center;
        anchor = anchor ?? childView.anchor;
        keyboardDismissBehavior =
            keyboardDismissBehavior ?? childView.keyboardDismissBehavior;
        restorationId = restorationId ?? childView.restorationId;
        clipBehavior = clipBehavior ?? childView.clipBehavior;
        scrollController = scrollController ?? childView.controller;
      }
      body = CustomScrollView(
        // ignore: DEPRECATED_MEMBER_USE_FROM_SAME_PACKAGE
        controller: scrollController,
        cacheExtent: cacheExtent,
        key: key,
        scrollDirection: scrollDirection ?? Axis.vertical,
        primary: primary,
        clipBehavior: clipBehavior ?? Clip.hardEdge,
        keyboardDismissBehavior:
            keyboardDismissBehavior ?? ScrollViewKeyboardDismissBehavior.manual,
        anchor: anchor ?? 0.0,
        restorationId: restorationId,
        center: center,
        physics: _getScrollPhysics(
            conf, physics ?? const AlwaysScrollableScrollPhysics()),
        slivers: slivers!,
        dragStartBehavior: dragStartBehavior ?? DragStartBehavior.start,
        reverse: reverse ?? false,
      );
    } else {
      body = Scrollable(
        physics: _getScrollPhysics(
            conf, childView.physics ?? const AlwaysScrollableScrollPhysics()),
        controller: childView.controller,
        axisDirection: childView.axisDirection,
        semanticChildCount: childView.semanticChildCount,
        dragStartBehavior: childView.dragStartBehavior,
        viewportBuilder: (context, offset) {
          Viewport viewport =
              childView.viewportBuilder(context, offset) as Viewport;
          viewport.children.insert(
              0,
              widget.header ??
                  (conf?.headerBuilder != null
                      ? conf?.headerBuilder!()
                      : null) ??
                  defaultHeader);
          return viewport;
        },
      );
    }
    return body;
  }

  bool _ifNeedUpdatePhysics() {
    RefreshConfiguration? conf = RefreshConfiguration.of(context);
    if (conf == null || _physics == null) {
      return false;
    }

    if (conf.topHitBoundary != _physics!.topHitBoundary ||
        conf.maxOverScrollExtent != _physics!.maxOverScrollExtent ||
        _physics!.dragSpeedRatio != conf.dragSpeedRatio) {
      return true;
    }
    return false;
  }

  void setCanDrag(bool canDrag) {
    if (_canDrag == canDrag) {
      return;
    }
    setState(() {
      _canDrag = canDrag;
    });
  }

  @override
  void didUpdateWidget(SmartRefresher oldWidget) {
    if (widget.controller != oldWidget.controller) {
      widget.controller.headerMode!.value =
          oldWidget.controller.headerMode!.value;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ifNeedUpdatePhysics()) {
      _updatePhysics = !_updatePhysics;
    }
  }

  @override
  void initState() {
    if (widget.controller.initialRefresh) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        // 如果已安装，则避免一种情况：初始化完成后，然后在构建之前处理小部件。
        // 这种情况多为 TabBarView
        if (mounted) widget.controller.requestRefresh();
      });
    }
    widget.controller._bindState(this);
    super.initState();
  }

  @override
  void dispose() {
    widget.controller._detachPosition();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final RefreshConfiguration? configuration =
        RefreshConfiguration.of(context);
    Widget? body;
    if (widget.builder != null) {
      body = widget.builder!(
          context,
          _getScrollPhysics(
                  configuration, const AlwaysScrollableScrollPhysics())
              as RefreshPhysics);
    } else {
      List<Widget>? slivers =
          _buildSliversByChild(context, widget.child, configuration);
      body = _buildBodyBySlivers(widget.child, slivers, configuration);
    }
    if (configuration == null) {
      body = RefreshConfiguration(child: body!);
    }
    return LayoutBuilder(
      builder: (c2, cons) {
        viewportExtent = cons.biggest.height;
        return body!;
      },
    );
  }
}

/// 控制器控制页眉和页脚状态，
/// 它可以触发驱动请求刷新，如果需要设置初始刷新，状态
/// 也可以看看：
/// * [SmartRefresher]，一个帮助您轻松附加刷新和加载更多功能的小部件
class RefreshController {
  SmartRefresherState? _refresherState;

  /// 标头状态模式控制
  RefreshNotifier<RefreshStatus>? headerMode;

  /// 可滚动内部的位置
  /// 请注意：在构建之前位置为空，
  /// 该值是在页眉或页脚回调 onPositionUpdated 时获取的
  ScrollPosition? position;

  RefreshStatus? get headerStatus => headerMode?.value;

  bool get isRefresh => headerMode?.value == RefreshStatus.refreshing;

  final bool initialRefresh;

  /// initialRefresh：SmartRefresher 初始化时，会立即调用 requestRefresh
  /// initialRefreshStatus：headerMode 默认值
  /// initialLoadStatus：footerMode 默认值
  RefreshController({
    this.initialRefresh = false,
    RefreshStatus? initialRefreshStatus,
  }) {
    headerMode = RefreshNotifier(initialRefreshStatus ?? RefreshStatus.idle);
  }

  void _bindState(SmartRefresherState state) {
    assert(_refresherState == null,
        "Don't use one refreshController to multiple SmartRefresher,It will cause some unexpected bugs mostly in TabBarView");
    _refresherState = state;
  }

  /// 建立指标时回调，并捕获可滚动的内部位置
  void onPositionUpdated(ScrollPosition newPosition) {
    position?.isScrollingNotifier.removeListener(_listenScrollEnd);
    position = newPosition;
    position!.isScrollingNotifier.addListener(_listenScrollEnd);
  }

  void _detachPosition() {
    _refresherState = null;
    position?.isScrollingNotifier.removeListener(_listenScrollEnd);
  }

  StatefulElement? _findIndicator(BuildContext context, Type elementType) {
    StatefulElement? result;
    context.visitChildElements((Element e) {
      if (elementType == RefreshIndicator) {
        if (e.widget is RefreshIndicator) {
          result = e as StatefulElement?;
        }
      }
      result ??= _findIndicator(e, elementType);
    });
    return result;
  }

  /// 当跳出边缘并被 overScroll 或 underScroll 停止时，它应该是 SpringBack 到 0.0
  /// 但是 ScrollPhysics 没有提供一种在 outOfEdge 时回弹的方法（由 applyBouncingCondition 停止返回！= 0.0）
  /// 所以要让它回弹，应该触发 goBallistic 让它回弹
  void _listenScrollEnd() {
    if (position != null && position!.outOfRange) {
      position?.activity?.applyNewDimensions();
    }
  }

  /// make the header enter refreshing state,and callback onRefresh
  Future<void>? requestRefresh({
    bool needMove = true,
    bool needCallback = true,
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.linear,
  }) {
    assert(position != null,
        'Try not to call requestRefresh() before build,please call after the ui was rendered');
    if (isRefresh) return Future.value();
    StatefulElement? indicatorElement =
        _findIndicator(position!.context.storageContext, RefreshIndicator);

    if (indicatorElement == null || _refresherState == null) return null;
    (indicatorElement.state as RefreshIndicatorState).floating = true;

    if (needMove && _refresherState!.mounted) {
      _refresherState!.setCanDrag(false);
    }
    if (needMove) {
      return Future.delayed(const Duration(milliseconds: 50)).then((_) async {
        // - 0.0001 is for NestedScrollView.
        await position
            ?.animateTo(position!.minScrollExtent - 0.0001,
                duration: duration, curve: curve)
            .then((_) {
          if (_refresherState != null && _refresherState!.mounted) {
            _refresherState!.setCanDrag(true);
            if (needCallback) {
              headerMode!.value = RefreshStatus.refreshing;
            } else {
              headerMode!.setValueWithNoNotify(RefreshStatus.refreshing);
              if (indicatorElement.state.mounted) {
                (indicatorElement.state as RefreshIndicatorState)
                    .setState(() {});
              }
            }
          }
        });
      });
    } else {
      Future.value().then((_) {
        headerMode!.value = RefreshStatus.refreshing;
      });
    }
    return null;
  }

  /// 请求完成，标头将进入完成状态
  void refreshCompleted({bool resetFooterState = false}) {
    headerMode?.value = RefreshStatus.completed;
  }

  /// 请求失败，头部显示失败状态
  void refreshFailed() {
    headerMode?.value = RefreshStatus.failed;
  }

  /// 不显示成功或失败，它会将标头状态设置为空闲并立即弹回
  void refreshToIdle() {
    headerMode?.value = RefreshStatus.idle;
  }

  /// 对于某些特殊情况，您应该调用 dispose() 以确保安全，它可能会在父窗口小部件 dispose 后抛出错误
  void dispose() {
    headerMode!.dispose();
    headerMode = null;
  }
}

///   控制 SmartRefresher 小部件在子树中的行为方式。用法类似于 [ScrollConfiguration]
///   刷新配置决定了smartRefresher的一些行为，全局设置默认指标
///   也可以看看：
///   * [SmartRefresher]，一个帮助附加刷新和加载更多功能的小部件
class RefreshConfiguration extends InheritedWidget {
  final Widget child;

  /// 全局默认标头构建器
  final IndicatorBuilder? headerBuilder;

  /// 自定义弹簧动画
  final SpringDescription springDescription;

  /// 是否需要在到达 triggerDistance 时立即刷新
  final bool skipCanRefresh;

  /// 刷新完成后用户是否可以拖动视口并回弹
  final bool enableScrollWhenRefreshCompleted;

  /// 触发刷新的overScroll距离
  final double headerTriggerDistance;

  /// 拖动滚动时的速度比，compute=origin物理拖动速度*dragSpeedRatio
  final double dragSpeedRatio;

  /// 超出上边缘时的最大滚动距离
  final double? maxOverScrollExtent;

  /// 边界位于顶部边缘，当惯性滚动超过边界距离时停止
  final double? topHitBoundary;

  /// 刷新振动的切换
  final bool enableRefreshVibrate;

  const RefreshConfiguration({
    Key? key,
    required this.child,
    this.headerBuilder,
    this.dragSpeedRatio = 1.0,
    this.springDescription = const SpringDescription(
      mass: 2.2,
      stiffness: 150,
      damping: 16,
    ),
    this.enableScrollWhenRefreshCompleted = false,
    this.skipCanRefresh = false,
    this.maxOverScrollExtent,
    this.headerTriggerDistance = 80.0,
    this.enableRefreshVibrate = false,
    this.topHitBoundary,
  })  : assert(headerTriggerDistance > 0),
        assert(dragSpeedRatio > 0),
        super(key: key, child: child);

  /// 构造 RefreshConfiguration 以从祖先节点复制属性
  /// 如果该参数为空，它会自动帮你吸收你祖先刷新配置的属性，而不必自己手动复制它们。
  /// 它主要在某些情况下使用，与 App 中的其他 SmartRefresher 不同
  RefreshConfiguration.copyAncestor({
    Key? key,
    required BuildContext context,
    required this.child,
    IndicatorBuilder? headerBuilder,
    IndicatorBuilder? footerBuilder,
    double? dragSpeedRatio,
    bool? enableScrollWhenTwoLevel,
    bool? enableBallisticRefresh,
    bool? enableBallisticLoad,
    bool? enableLoadingWhenNoData,
    SpringDescription? springDescription,
    bool? enableScrollWhenRefreshCompleted,
    bool? enableLoadingWhenFailed,
    double? twiceTriggerDistance,
    double? closeTwoLevelDistance,
    bool? skipCanRefresh,
    double? maxOverScrollExtent,
    double? maxUnderScrollExtent,
    double? topHitBoundary,
    double? bottomHitBoundary,
    double? headerTriggerDistance,
    double? footerTriggerDistance,
    bool? enableRefreshVibrate,
    bool? enableLoadMoreVibrate,
    bool? hideFooterWhenNotFull,
  })  : assert(RefreshConfiguration.of(context) != null,
            "search RefreshConfiguration anscestor return null,please  Make sure that RefreshConfiguration is the ancestor of that element"),
        headerBuilder =
            headerBuilder ?? RefreshConfiguration.of(context)!.headerBuilder,
        dragSpeedRatio =
            dragSpeedRatio ?? RefreshConfiguration.of(context)!.dragSpeedRatio,
        headerTriggerDistance = headerTriggerDistance ??
            RefreshConfiguration.of(context)!.headerTriggerDistance,
        springDescription = springDescription ??
            RefreshConfiguration.of(context)!.springDescription,
        maxOverScrollExtent = maxOverScrollExtent ??
            RefreshConfiguration.of(context)!.maxOverScrollExtent,
        topHitBoundary =
            topHitBoundary ?? RefreshConfiguration.of(context)!.topHitBoundary,
        skipCanRefresh =
            skipCanRefresh ?? RefreshConfiguration.of(context)!.skipCanRefresh,
        enableScrollWhenRefreshCompleted = enableScrollWhenRefreshCompleted ??
            RefreshConfiguration.of(context)!.enableScrollWhenRefreshCompleted,
        enableRefreshVibrate = enableRefreshVibrate ??
            RefreshConfiguration.of(context)!.enableRefreshVibrate,
        super(key: key, child: child);

  static RefreshConfiguration? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<RefreshConfiguration>();
  }

  @override
  bool updateShouldNotify(RefreshConfiguration oldWidget) {
    return skipCanRefresh != oldWidget.skipCanRefresh ||
        dragSpeedRatio != oldWidget.dragSpeedRatio ||
        enableScrollWhenRefreshCompleted !=
            oldWidget.enableScrollWhenRefreshCompleted ||
        headerTriggerDistance != oldWidget.headerTriggerDistance ||
        oldWidget.maxOverScrollExtent != maxOverScrollExtent ||
        topHitBoundary != oldWidget.topHitBoundary ||
        enableRefreshVibrate != oldWidget.enableRefreshVibrate;
  }
}

class RefreshNotifier<T> extends ChangeNotifier implements ValueListenable<T> {
  RefreshNotifier(this._value);

  T _value;

  @override
  T get value => _value;

  set value(T newValue) {
    if (_value == newValue) return;
    _value = newValue;
    notifyListeners();
  }

  void setValueWithNoNotify(T newValue) {
    if (_value == newValue) return;
    _value = newValue;
  }

  @override
  String toString() => '${describeIdentity(this)}($value)';
}
