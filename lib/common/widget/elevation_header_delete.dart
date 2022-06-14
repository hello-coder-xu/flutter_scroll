import 'package:flutter/material.dart';

///滚动时动态新增阴影效果
class ElevationSliverPersistentHeaderDelegate
    extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double maxHeight;
  final double minHeight;
  final bool reBuild;
  final double maxElevation;

  ElevationSliverPersistentHeaderDelegate({
    required this.child,
    this.maxHeight = 48,
    this.minHeight = 48,
    this.reBuild = false,
    this.maxElevation = 5,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      elevation: shrinkOffset.clamp(0, maxElevation),
      child: child,
    );
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => maxHeight;

  @override
  bool shouldRebuild(covariant oldDelegate) => reBuild;
}
