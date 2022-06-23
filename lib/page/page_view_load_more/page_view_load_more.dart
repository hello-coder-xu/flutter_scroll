import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_scroll/page/page_view_load_more/page_view_footer.dart';
import 'package:flutter_scroll/page/page_view_load_more/page_view_header.dart';
import 'package:flutter_scroll/common/widget/limit_scroll_physics.dart';

final PageController _defaultPageController = PageController();

class PageViewLoadMore extends StatefulWidget {
  final Axis scrollDirection;
  final PageController controller;
  final ValueChanged<int>? onPageChanged;
  final SliverChildDelegate childrenDelegate;

  PageViewLoadMore({
    Key? key,
    this.scrollDirection = Axis.horizontal,
    PageController? controller,
    this.onPageChanged,
    List<Widget> children = const <Widget>[],
  })
      : controller = controller ?? _defaultPageController,
        childrenDelegate = SliverChildListDelegate(children),
        super(key: key);

  PageViewLoadMore.builder({
    Key? key,
    this.scrollDirection = Axis.horizontal,
    PageController? controller,
    this.onPageChanged,
    required IndexedWidgetBuilder itemBuilder,
    int? itemCount,
  })
      : controller = controller ?? _defaultPageController,
        childrenDelegate =
        SliverChildBuilderDelegate(itemBuilder, childCount: itemCount),
        super(key: key);

  @override
  State<PageViewLoadMore> createState() => _PageViewLoadMoreState();
}

class _PageViewLoadMoreState extends State<PageViewLoadMore> {
  int _lastReportedPage = 0;

  @override
  void initState() {
    super.initState();
    _lastReportedPage = widget.controller.initialPage;
  }

  AxisDirection _getDirection(BuildContext context) {
    switch (widget.scrollDirection) {
      case Axis.horizontal:
        assert(debugCheckHasDirectionality(context));
        final TextDirection textDirection = Directionality.of(context);
        final AxisDirection axisDirection =
        textDirectionToAxisDirection(textDirection);
        return axisDirection;
      case Axis.vertical:
        return AxisDirection.down;
    }
  }

  double _getItemExtent(BoxConstraints constraints) {
    switch (widget.scrollDirection) {
      case Axis.horizontal:
        return constraints.biggest.width;
      case Axis.vertical:
        return constraints.biggest.height;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AxisDirection axisDirection = _getDirection(context);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double itemExtent = _getItemExtent(constraints);
        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification notification) {
            if (notification.depth == 0 &&
                widget.onPageChanged != null &&
                notification is ScrollUpdateNotification) {
              final PageMetrics metrics = notification.metrics as PageMetrics;
              final int currentPage = metrics.page!.round();
              if (currentPage != _lastReportedPage) {
                _lastReportedPage = currentPage;
                widget.onPageChanged!(currentPage);
              }
            }
            return false;
          },
          child: Scrollable(
            dragStartBehavior: DragStartBehavior.start,
            axisDirection: axisDirection,
            controller: widget.controller,
            physics: const PageScrollPhysics()
                .applyTo(const LimitScrollPhysics(enableEnd: true)),
            viewportBuilder: (BuildContext context, ViewportOffset position) {
              return Viewport(
                cacheExtent: 1,
                cacheExtentStyle: CacheExtentStyle.viewport,
                axisDirection: axisDirection,
                offset: position,
                slivers: <Widget>[
                  PageViewHeader(
                    child: Container(
                      alignment: Alignment.center,
                      width: 50,
                      color: Colors.black,
                      child: const Text(
                        'header',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  SliverFixedExtentList(
                    delegate: widget.childrenDelegate,
                    itemExtent: itemExtent,
                  ),
                  PageViewFooter(
                    child: Container(
                      alignment: Alignment.center,
                      width: 50,
                      color: Colors.black,
                      child: const Text(
                        'footer',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description
        .add(EnumProperty<Axis>('scrollDirection', widget.scrollDirection));

    description.add(DiagnosticsProperty<PageController>(
        'controller', widget.controller,
        showName: false));
  }
}
