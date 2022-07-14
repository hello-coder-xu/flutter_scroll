import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:collection/collection.dart';
import 'package:flutter_scroll/common/widget/anchor/tw_anchor_item_view.dart';
import 'package:flutter_scroll/common/widget/anchor/tw_anchor_model.dart';

typedef AnchorScrollTo = Function(String tag);

typedef AnchorTabChanged = Function(int index);

class TwAnchorController {
  AnchorScrollTo? scrollTo;
}

/// 锚点视图
class TwAnchorView extends StatefulWidget {
  final List<Widget> children;
  final ScrollController? scrollController;
  final TwAnchorController? controller;
  final AnchorTabChanged? tabChanged;
  final NotificationListenerCallback<ScrollNotification>? onNotification;

  const TwAnchorView({
    Key? key,
    required this.children,
    this.scrollController,
    this.controller,
    this.tabChanged,
    this.onNotification,
  }) : super(key: key);

  @override
  State<TwAnchorView> createState() => _TwAnchorViewState();
}

class _TwAnchorViewState extends State<TwAnchorView> {
  late ScrollController scrollController =
      widget.scrollController ?? ScrollController();
  List<TwAnchorModel> anchors = [];
  bool lock = false;

  /// 滚动列表总长度
  double scrollTotalExtent = 0;

  /// 滚动视窗长度
  double viewPartExtent = 0;

  /// 滚动视图中，定住的高度
  double pinnedHeight = 0;

  /// 当前对象
  TwAnchorModel? current;

  @override
  void initState() {
    super.initState();
    widget.controller?.scrollTo = scrollTo;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      onNotification: (ScrollNotification notification) {
        widget.onNotification?.call(notification);
        onNotification(notification);
        return false;
      },
      child: CustomScrollView(
        slivers: widget.children,
        controller: scrollController,
      ),
    );
  }

  /// 滚动监听
  void onNotification(ScrollNotification notification) {
    if (notification.depth != 0 || lock) return;
    if (notification is ScrollStartNotification) {
      dealWithSlivers();
    } else if (notification is ScrollUpdateNotification) {
      int tabIndex = tabIndexByScroll(scrollController.position.pixels);
      tabTo(tabIndex);
    }
  }

  /// 查找滑动视窗
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

  /// 处理每个视图
  void dealWithSlivers() {
    RenderViewport? renderViewport =
        findViewport(scrollController.position.context.storageContext);
    if (renderViewport == null) return;
    RenderSliver? sliver = renderViewport.firstChild;
    scrollTotalExtent = 0;
    anchors.clear();
    pinnedHeight = 0;
    viewPartExtent = renderViewport.constraints.biggest.height;
    while (sliver != null) {
      double currentHeight = sliver.geometry!.scrollExtent;
      if (sliver is RenderSliverPinnedPersistentHeader) {
        pinnedHeight += currentHeight;
      }
      if (sliver is RenderTwAnchorItemView) {
        anchors.add(TwAnchorModel(
          tabIndex: sliver.tabIndex,
          start: scrollTotalExtent,
          end: scrollTotalExtent + currentHeight,
          tag: sliver.tag,
        ));
        scrollTotalExtent += currentHeight;
      }
      sliver = renderViewport.childAfter(sliver);
    }
  }

  /// 滚动到tab对应位置
  void tabTo(int index) {
    widget.tabChanged?.call(index);
  }

  /// tab滚动 -> scroll 对应位置
  void scrollTo(String tag) {
    if (lock) return;
    lock = true;
    dealWithSlivers();
    if (current?.tag != tag) {
      current = anchors.firstWhereOrNull((element) => element.tag == tag);
    }
    if (current == null) return;
    double scrollOffset = 0;
    double toEndExtent = scrollTotalExtent - current!.start;
    if (toEndExtent >= viewPartExtent || current!.start <= viewPartExtent) {
      scrollOffset = current!.start;
    } else {
      double extent = current!.end - current!.start;
      double diff = viewPartExtent - pinnedHeight - extent;
      scrollOffset = current!.start - diff;
    }
    scrollController.jumpTo(scrollOffset);
    lock = false;
  }

  /// scroll滚动 -> tab 对应位置
  int tabIndexByScroll(double offset) {
    if (current != null && offset > current!.start && offset <= current!.end) {
      return current!.tabIndex;
    } else {
      for (int i = 0; i < anchors.length; i++) {
        TwAnchorModel element = anchors[i];
        if (offset > element.start && offset <= element.end) {
          current = element;
          break;
        }
      }
      return current!.tabIndex;
    }
  }
}
