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

/// a builder for attaching refresh function with the physics
typedef RefresherBuilder = Widget Function(
    BuildContext context, RefreshPhysics physics);

/// header state
enum RefreshStatus {
  /// Initial state, when not being overscrolled into, or after the overscroll
  /// is canceled or after done and the sliver retracted away.
  idle,

  /// Dragged far enough that the onRefresh callback will callback
  canRefresh,

  /// the indicator is refreshing,waiting for the finish callback
  refreshing,

  /// the indicator refresh completed
  completed,

  /// the indicator refresh failed
  failed,
}

/// header indicator display style
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

  /// Controll inner state
  final RefreshController controller;

  /// child content builder
  final RefresherBuilder? builder;

  /// copy from ScrollView,for setting in SingleChildView,not ScrollView
  final Axis? scrollDirection;

  /// copy from ScrollView,for setting in SingleChildView,not ScrollView
  final bool? reverse;

  /// copy from ScrollView,for setting in SingleChildView,not ScrollView
  final ScrollController? scrollController;

  /// copy from ScrollView,for setting in SingleChildView,not ScrollView
  final bool? primary;

  /// copy from ScrollView,for setting in SingleChildView,not ScrollView
  final ScrollPhysics? physics;

  /// copy from ScrollView,for setting in SingleChildView,not ScrollView
  final double? cacheExtent;

  /// copy from ScrollView,for setting in SingleChildView,not ScrollView
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

  //build slivers from child Widget
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
            maxUnderScrollExtent: conf?.maxUnderScrollExtent ??
                (isBouncingPhysics ? double.infinity : 0.0),
            maxOverScrollExtent: conf?.maxOverScrollExtent ??
                (isBouncingPhysics ? double.infinity : 60.0),
            topHitBoundary: conf?.topHitBoundary ??
                (isBouncingPhysics ? double.infinity : 0.0),
            // need to fix default value by ios or android later
            bottomHitBoundary: conf?.bottomHitBoundary ??
                (isBouncingPhysics ? double.infinity : 0.0))
        .applyTo(!_canDrag ? const NeverScrollableScrollPhysics() : physics);
  }

  // build the customScrollView
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
        _physics!.bottomHitBoundary != conf.bottomHitBoundary ||
        conf.maxOverScrollExtent != _physics!.maxOverScrollExtent ||
        _physics!.maxUnderScrollExtent != conf.maxUnderScrollExtent ||
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
        //  if mounted,it avoid one situation: when init done,then dispose the widget before build.
        //  this   situation mostly TabBarView
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

/// A controller controll header and footer state,
/// it  can trigger  driving request Refresh ,set the initalRefresh,status if needed
///
/// See also:
///
/// * [SmartRefresher],a widget help you attach refresh and load more function easily
class RefreshController {
  SmartRefresherState? _refresherState;

  /// header status mode controll
  RefreshNotifier<RefreshStatus>? headerMode;

  /// the scrollable inner's position
  ///
  /// notice that: position is null before build,
  /// the value is get when the header or footer callback onPositionUpdated
  ScrollPosition? position;

  RefreshStatus? get headerStatus => headerMode?.value;

  bool get isRefresh => headerMode?.value == RefreshStatus.refreshing;

  final bool initialRefresh;

  /// initialRefresh:When SmartRefresher is init,it will call requestRefresh at once
  ///
  /// initialRefreshStatus: headerMode default value
  ///
  /// initialLoadStatus: footerMode default value
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

  /// callback when the indicator is builded,and catch the scrollable's inner position
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

  /// when bounce out of edge and stopped by overScroll or underScroll, it should be SpringBack to 0.0
  /// but ScrollPhysics didn't provide one way to spring back when outOfEdge(stopped by applyBouncingCondition return != 0.0)
  /// so for making it spring back, it should be trigger goBallistic make it spring back
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

  /// request complete,the header will enter complete state,
  ///
  /// resetFooterState : it will set the footer state from noData to idle
  void refreshCompleted({bool resetFooterState = false}) {
    headerMode?.value = RefreshStatus.completed;
  }

  /// request failed,the header display failed state
  void refreshFailed() {
    headerMode?.value = RefreshStatus.failed;
  }

  /// not show success or failed, it will set header state to idle and spring back at once
  void refreshToIdle() {
    headerMode?.value = RefreshStatus.idle;
  }

  /// for some special situation, you should call dispose() for safe,it may throw errors after parent widget dispose
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


  /// overScroll distance of trigger refresh
  final double headerTriggerDistance;

  /// the speed ratio when dragging overscroll ,compute=origin physics dragging speed *dragSpeedRatio
  final double dragSpeedRatio;

  /// max overScroll distance when out of edge
  final double? maxOverScrollExtent;

  /// 	max underScroll distance when out of edge
  final double? maxUnderScrollExtent;

  /// The boundary is located at the top edge and stops when inertia rolls over the boundary distance
  final double? topHitBoundary;

  /// The boundary is located at the bottom edge and stops when inertia rolls under the boundary distance
  final double? bottomHitBoundary;

  /// toggle of  refresh vibrate
  final bool enableRefreshVibrate;

  const RefreshConfiguration(
      {Key? key,
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
      this.maxUnderScrollExtent,
      this.headerTriggerDistance = 80.0,
      this.enableRefreshVibrate = false,
      this.topHitBoundary,
      this.bottomHitBoundary})
      : assert(headerTriggerDistance > 0),
        assert(dragSpeedRatio > 0),
        super(key: key, child: child);

  /// Construct RefreshConfiguration to copy attributes from ancestor nodes
  /// If the parameter is null, it will automatically help you to absorb the attributes of your ancestor Refresh Configuration, instead of having to copy them manually by yourself.
  ///
  /// it mostly use in some stiuation is different the other SmartRefresher in App
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
        maxUnderScrollExtent = maxUnderScrollExtent ??
            RefreshConfiguration.of(context)!.maxUnderScrollExtent,
        topHitBoundary =
            topHitBoundary ?? RefreshConfiguration.of(context)!.topHitBoundary,
        bottomHitBoundary = bottomHitBoundary ??
            RefreshConfiguration.of(context)!.bottomHitBoundary,
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
        maxUnderScrollExtent != oldWidget.maxUnderScrollExtent ||
        oldWidget.maxOverScrollExtent != maxOverScrollExtent ||
        topHitBoundary != oldWidget.topHitBoundary ||
        enableRefreshVibrate != oldWidget.enableRefreshVibrate ||
        bottomHitBoundary != oldWidget.bottomHitBoundary;
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
