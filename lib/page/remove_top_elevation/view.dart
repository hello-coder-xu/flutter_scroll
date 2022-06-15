import 'package:flutter/material.dart';
import 'package:flutter_scroll/common/widget/no_scroll_behavior.dart';

class RemoveTopElevationPage extends StatelessWidget {
  const RemoveTopElevationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(toString()),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 1),
              ),
              margin: const EdgeInsets.all(16),
              child: view1(),
            ),
            Container(
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 1),
              ),
              margin: const EdgeInsets.all(16),
              child: view2(),
            ),
          ],
        ),
      ),
    );
  }

  Widget view1() {
    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (OverscrollIndicatorNotification notification) {
        notification.disallowIndicator();
        return false;
      },
      child: ListView.builder(
        itemBuilder: (context, index) {
          String value = '$index';
          if (index == 0) {
            value = '滚动到边界时，我没有阴影了';
          } else if (index == 1) {
            value = '我使用了NotificationListener';
          } else if (index == 2) {
            value = '设置了类型为：OverscrollIndicatorNotification';
          }
          return ListTile(
            title: Text(value),
          );
        },
        itemCount: 10,
      ),
    );
  }

  Widget view2() {
    return ScrollConfiguration(
      behavior: NoScrollBehavior(),
      child: ListView.builder(
        itemBuilder: (context, index) {
          String value = '$index';
          if (index == 0) {
            value = '滚动到边界时，我没有阴影了';
          } else if (index == 1) {
            value = '我使用了ScrollConfiguration';
          } else if (index == 2) {
            value = '设置了behavior: NoScrollBehavior()';
          }
          return ListTile(
            title: Text(value),
          );
        },
        itemCount: 10,
      ),
    );
  }
}
