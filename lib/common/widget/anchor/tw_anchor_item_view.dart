import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class TwAnchorItemView extends SingleChildRenderObjectWidget {
  final String tag;
  final int tabIndex;

  const TwAnchorItemView({
    Key? key,
    required Widget child,
    this.tag = '',
    this.tabIndex = 0,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) => RenderTwAnchorItemView(
        tag: tag,
        tabIndex: tabIndex,
      );
}

class RenderTwAnchorItemView extends RenderSliverToBoxAdapter {
  final String tag;
  final int tabIndex;

  RenderTwAnchorItemView({
    RenderBox? child,
    this.tag = '',
    this.tabIndex = 0,
  }) : super(child: child);
}
