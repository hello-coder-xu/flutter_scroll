import 'package:flutter/material.dart'
    hide RefreshIndicator, RefreshIndicatorState;
import 'package:flutter_scroll/page/refresh/pull_to_refresh/internals/refresh_string.dart';
import '../internals/indicator_wrap.dart';
import '../smart_refresher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class ClassicHeader extends RefreshIndicator {
  final Widget? releaseIcon, idleIcon, completeIcon, failedIcon;

  final TextStyle textStyle;

  const ClassicHeader({
    Key? key,
    RefreshStyle refreshStyle = RefreshStyle.follow,
    double height = 60.0,
    Duration completeDuration = const Duration(milliseconds: 600),
    this.textStyle = const TextStyle(color: Colors.grey),
    this.failedIcon = const Icon(Icons.error, color: Colors.grey),
    this.completeIcon = const Icon(Icons.done, color: Colors.grey),
    this.idleIcon = const Icon(Icons.arrow_downward, color: Colors.grey),
    this.releaseIcon = const Icon(Icons.refresh, color: Colors.grey),
  }) : super(
          key: key,
          refreshStyle: refreshStyle,
          completeDuration: completeDuration,
          height: height,
        );

  @override
  State createState() => _ClassicHeaderState();
}

class _ClassicHeaderState extends RefreshIndicatorState<ClassicHeader> {

  ///文本视图
  Widget _buildText(mode) {
    RefreshString strings = RefreshString();
    return Text(
      mode == RefreshStatus.canRefresh
          ? strings.canRefreshText
          : mode == RefreshStatus.completed
              ? strings.refreshCompleteText
              : mode == RefreshStatus.failed
                  ? strings.refreshFailedText
                  : mode == RefreshStatus.refreshing
                      ? strings.refreshingText
                      : mode == RefreshStatus.idle
                          ? strings.idleRefreshText
                          : "",
      style: widget.textStyle,
    );
  }

  ///图标视图
  Widget _buildIcon(mode) {
    Widget? icon = mode == RefreshStatus.canRefresh
        ? widget.releaseIcon
        : mode == RefreshStatus.idle
            ? widget.idleIcon
            : mode == RefreshStatus.completed
                ? widget.completeIcon
                : mode == RefreshStatus.failed
                    ? widget.failedIcon
                    : SizedBox(
                        width: 25.0,
                        height: 25.0,
                        child: defaultTargetPlatform == TargetPlatform.iOS
                            ? const CupertinoActivityIndicator()
                            : const CircularProgressIndicator(strokeWidth: 2.0),
                      );
    return icon ?? Container();
  }

  @override
  bool needReverseAll() {
    return false;
  }

  @override
  Widget buildContent(BuildContext context, RefreshStatus? mode) {
    Widget textWidget = _buildText(mode);
    Widget iconWidget = _buildIcon(mode);
    List<Widget> children = <Widget>[iconWidget, textWidget];
    final Widget container = Wrap(
      alignment: WrapAlignment.center,
      children: children,
    );
    return SizedBox(
      child: Center(child: container),
      height: widget.height,
    );
  }
}
