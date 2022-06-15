import 'package:flutter/material.dart';

class NoScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    switch (getPlatform(context)) {
      case TargetPlatform.iOS:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return child;
      case TargetPlatform.android:
        switch (androidOverscrollIndicator) {
          case AndroidOverscrollIndicator.stretch:
            return StretchingOverscrollIndicator(
              axisDirection: AxisDirection.down,
              child: child,
            );
          case AndroidOverscrollIndicator.glow:
            continue glow;
        }
      glow:
      case TargetPlatform.fuchsia:
        return GlowingOverscrollIndicator(
          axisDirection: AxisDirection.down,
          color: Theme.of(context).colorScheme.secondaryContainer,
          showTrailing: false,
          //不显顶部示阴影
          showLeading: false,
          //不显示底部阴影
          child: child,
        );
    }
  }
}
