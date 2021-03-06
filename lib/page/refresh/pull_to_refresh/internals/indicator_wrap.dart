import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_scroll/common/logger/logger_utils.dart';
import '../smart_refresher.dart';
import 'slivers.dart';

typedef VoidFutureCallBack = Future<void> Function();

typedef OffsetCallBack = void Function(double offset);

typedef ModeChangeCallBack<T> = void Function(T? mode);

/// 下拉刷新
abstract class RefreshIndicator extends StatefulWidget {
  /// 刷新显示样式
  final RefreshStyle? refreshStyle;

  /// 视觉范围指示器
  final double height;

  ///布局偏移
  final double offset;

  /// 刷新完成或失败的停止时间
  final Duration completeDuration;

  const RefreshIndicator({
    Key? key,
    this.height = 60.0,
    this.offset = 0.0,
    this.completeDuration = const Duration(milliseconds: 500),
    this.refreshStyle = RefreshStyle.follow,
  }) : super(key: key);
}

abstract class RefreshIndicatorState<T extends RefreshIndicator>
    extends State<T>
    with IndicatorStateMixin<T, RefreshStatus>, RefreshProcessor {
  ///是否在视窗内
  bool _inVisual() {
    Logger.write('test RefreshIndicatorState _inVisual');
    return _position!.pixels < 0.0;
  }

  ///计算越界距离
  @override
  double _calculateScrollOffset() {
    Logger.write('test RefreshIndicatorState _calculateScrollOffset');
    return (floating ? widget.height : 0.0) - (_position?.pixels as num);
  }

  @override
  void _handleOffsetChange() {
    Logger.write('test RefreshIndicatorState _handleOffsetChange');
    super._handleOffsetChange();
    final double overscrollPast = _calculateScrollOffset();
    onOffsetChange(overscrollPast);
  }

  ///根据越界距离更新头部状态
  @override
  void _dispatchModeByOffset(double offset) {
    Logger.write('test RefreshIndicatorState _dispatchModeByOffset');
    if (floating) return;
    // no matter what activity is done, when offset ==0.0 and !floating,it should be set to idle for setting if CanDrag
    if (offset == 0.0) {
      mode = RefreshStatus.idle;
    }

    // 有时不同的设备返回速度不同，因此无法从速度判断用户是否已调用 animateTo (0.0) 或用户正在拖动视图。
    // 有时 animateTo (0.0) 不返回速度 = 0.0
    if ((activity!.velocity < 0.0) ||
        activity is DragScrollActivity ||
        activity is DrivenScrollActivity) {
      //是否达到设定的刷新距离
      if (offset >= configuration!.headerTriggerDistance) {
        //是否跳过刷新等待
        if (!configuration!.skipCanRefresh) {
          mode = RefreshStatus.canRefresh;
        } else {
          floating = true;
          update();
          readyToRefresh().then((_) {
            if (!mounted) return;
            mode = RefreshStatus.refreshing;
          });
        }
      } else {
        mode = RefreshStatus.idle;
      }
    } else if (activity is BallisticScrollActivity) {
      //主要用于回弹
      if (RefreshStatus.canRefresh == mode) {
        // refreshing
        floating = true;
        update();
        readyToRefresh().then((_) {
          if (!mounted) return;
          mode = RefreshStatus.refreshing;
        });
      }
    }
  }

  @override
  void _handleModeChange() {
    Logger.write('test RefreshIndicatorState _handleModeChange');
    if (!mounted) {
      return;
    }
    update();
    if (mode == RefreshStatus.idle || mode == RefreshStatus.canRefresh) {
      floating = false;

      resetValue();

      if (mode == RefreshStatus.idle) refresherState!.setCanDrag(true);
    }
    if (mode == RefreshStatus.completed || mode == RefreshStatus.failed) {
      endRefresh().then((_) {
        if (!mounted) return;
        floating = false;
        if (mode == RefreshStatus.completed || mode == RefreshStatus.failed) {
          refresherState!
              .setCanDrag(configuration!.enableScrollWhenRefreshCompleted);
        }
        update();
        /*
          处理两种情况：
           1.当用户拖动到刷新时，用户向下滚动看不到指示器，则不会弹回，
           _onOffsetChange 没有回调，它将保持失败或成功状态。
           2. 作为FrontStyle，当用户在刷新状态下拖动0~100时，需要在状态改变后重新设置
          */
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }
          if (!_inVisual()) {
            mode = RefreshStatus.idle;
          } else {
            activity!.delegate.goBallistic(0.0);
          }
        });
      });
    } else if (mode == RefreshStatus.refreshing) {
      if (!floating) {
        floating = true;
        readyToRefresh();
      }
      if (configuration!.enableRefreshVibrate) {
        HapticFeedback.vibrate();
      }
      if (refresher!.onRefresh != null) refresher!.onRefresh!();
    }
    onModeChange(mode);
  }

  //该方法可以提供一个回调来实现一些动画
  @override
  Future<void> readyToRefresh() {
    Logger.write('test RefreshIndicatorState readyToRefresh');
    return Future.value();
  }

  // 这意味着状态将进入成功或失败
  @override
  Future<void> endRefresh() {
    Logger.write('test RefreshIndicatorState endRefresh');
    return Future.delayed(widget.completeDuration);
  }

  bool needReverseAll() {
    Logger.write('test RefreshIndicatorState needReverseAll');
    return true;
  }

  @override
  void resetValue() {}

  @override
  Widget build(BuildContext context) {
    Logger.write('test RefreshIndicatorState build');
    return SliverRefresh(
      paintOffsetY: widget.offset,
      child: RotatedBox(
        child: buildContent(context, mode),
        quarterTurns: needReverseAll() &&
                Scrollable.of(context)!.axisDirection == AxisDirection.up
            ? 10
            : 0,
      ),
      floating: floating,
      refreshIndicatorLayoutExtent: widget.height,
      refreshStyle: widget.refreshStyle,
    );
  }
}

/// 帮助完成页眉指示器和页脚指示器需要做的工作
mixin IndicatorStateMixin<T extends StatefulWidget, V> on State<T> {
  SmartRefresher? refresher;

  RefreshConfiguration? configuration;
  SmartRefresherState? refresherState;

  bool _floating = false;

  set floating(floating) => _floating = floating;

  get floating => _floating;

  set mode(mode) => _mode?.value = mode;

  get mode => _mode?.value;

  RefreshNotifier<V?>? _mode;

  ScrollActivity? get activity => _position!.activity;

  ScrollPosition? _position;

  // update ui
  void update() {
    if (mounted) setState(() {});
  }

  ///处理滚动时的偏移量
  void _handleOffsetChange() {
    Logger.write('test IndicatorStateMixin _handleOffsetChange');
    if (!mounted) {
      return;
    }
    //计算越界距离
    final double overscrollPast = _calculateScrollOffset();
    if (overscrollPast < 0.0) {
      return;
    }
    //根据越界距离更新头部状态
    _dispatchModeByOffset(overscrollPast);
  }

  void disposeListener() {
    _mode?.removeListener(_handleModeChange);
    _position?.removeListener(_handleOffsetChange);
    _position = null;
    _mode = null;
  }

  void _updateListener() {
    Logger.write('test IndicatorStateMixin _updateListener');
    configuration = RefreshConfiguration.of(context);
    refresher = SmartRefresher.of(context);
    refresherState = SmartRefresher.ofState(context);
    RefreshNotifier<V>? newMode =
        refresher?.controller.headerMode as RefreshNotifier<V>?;
    final ScrollPosition newPosition = Scrollable.of(context)!.position;
    if (newMode != _mode) {
      _mode?.removeListener(_handleModeChange);
      _mode = newMode;
      _mode?.addListener(_handleModeChange);
    }
    if (newPosition != _position) {
      _position?.removeListener(_handleOffsetChange);
      _onPositionUpdated(newPosition);
      _position = newPosition;
      _position?.addListener(_handleOffsetChange);
    }
  }

  @override
  void initState() {
    if (V == RefreshStatus) {
      print('test ----');
      SmartRefresher.of(context)?.controller.headerMode?.value =
          RefreshStatus.idle;
    }
    super.initState();
  }

  @override
  void dispose() {
    disposeListener();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    _updateListener();
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(T oldWidget) {
    _updateListener();
    super.didUpdateWidget(oldWidget);
  }

  void _onPositionUpdated(ScrollPosition newPosition) {
    refresher?.controller.onPositionUpdated(newPosition);
  }

  void _handleModeChange();

  double _calculateScrollOffset();

  void _dispatchModeByOffset(double offset);

  Widget buildContent(BuildContext context, V mode);
}

/// 暴露给头部视图接口
abstract class RefreshProcessor {
  /// 越界回调
  void onOffsetChange(double offset) {}

  /// 模式变更回调
  void onModeChange(RefreshStatus? mode) {}

  /// 当指标准备好刷新时，它会回调并等待该函数完成，然后回调onRefresh
  Future readyToRefresh() {
    return Future.value();
  }

  /// 当指示器准备好关闭布局时，它会回调，然后在完成后弹回
  Future endRefresh() {
    return Future.value();
  }

  /// 当指示器已回弹时，需要重新设置值
  void resetValue() {}
}
