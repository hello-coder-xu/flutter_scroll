import 'package:flutter/material.dart'
    hide RefreshIndicator, RefreshIndicatorState;
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TwPageViewFooter extends LoadIndicator {
  final String? idleText;
  final String? refreshText;
  final TextStyle? textStyle;
  final Widget? icon;

  const TwPageViewFooter({
    Key? key,
    LoadStyle refreshStyle = LoadStyle.HideAlways,
    double height = 120.0,
    Duration completeDuration = Duration.zero,
    this.idleText,
    this.refreshText,
    this.textStyle,
    this.icon,
  }) : super(
          key: key,
          loadStyle: refreshStyle,
          height: height,
        );

  @override
  State createState() => _ClassicHeaderState();
}

class _ClassicHeaderState extends LoadIndicatorState<TwPageViewFooter> {
  bool status = true;

  Widget _buildText(mode) {
    String value = "";
    if (status) {
      value = widget.refreshText ?? '释放查看更多';
    } else {
      value = widget.idleText ?? '滑动查看更多';
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: value
          .split('')
          .map(
            (e) => Text(e, style: widget.textStyle),
          )
          .toList(),
    );
  }

  Widget _buildIcon(mode) {
    double turns = 0;
    if (status) {
      turns = 0;
    } else {
      turns = -0.5;
    }
    return AnimatedRotation(
      duration: const Duration(milliseconds: 300),
      turns: turns,
      child: widget.icon ?? const Icon(Icons.arrow_back_ios_rounded),
    );
  }

  @override
  void onOffsetChange(double offset) {
    super.onOffsetChange(offset);
    bool temp = offset < 80;
    if (status != temp) {
      status = temp;
      setState(() {});
    }
  }

  @override
  Widget buildContent(BuildContext context, LoadStatus? mode) {
    Widget textWidget = _buildText(mode);
    Widget iconWidget = _buildIcon(mode);

    Widget container = Column(
      mainAxisSize: MainAxisSize.min,
      children: [textWidget, iconWidget],
    );
    return SizedBox(
      width: 80.0,
      height: widget.height,
      child: Center(
        child: container,
      ),
    );
  }
}
