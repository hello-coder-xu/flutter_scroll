import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_scroll/common/logger/logger_utils.dart';
import 'package:flutter_scroll/page/refresh/pull_to_refresh/smart_refresher.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'logic.dart';

class RefreshPage extends StatefulWidget {
  const RefreshPage({Key? key}) : super(key: key);

  @override
  State<RefreshPage> createState() => _RefreshPageState();
}

class _RefreshPageState extends State<RefreshPage> {
  final logic = Get.put(RefreshLogic());

  final state = Get.find<RefreshLogic>().state;

  RefreshController controller = RefreshController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.toString()),
        centerTitle: true,
      ),
      body: pullToRefreshView(),
    );
  }

  ///模仿改造
  Widget pullToRefreshView() {
    // return CustomScrollView(
    //   physics: BouncingScrollPhysics(),
    //   slivers: [
    //     MyHeaderView(
    //       child: Container(
    //         height: 100,
    //         color: Colors.black,
    //         alignment: Alignment.center,
    //         child: Text('header'),
    //       ),
    //     ),
    //     SliverList(
    //       delegate: SliverChildBuilderDelegate(
    //         (context, index) => ListTile(
    //           title: Text('$index'),
    //         ),
    //         childCount: 20,
    //       ),
    //     ),
    //   ],
    // );
    return SmartRefresher(
      controller: controller,
      scrollDirection: Axis.horizontal,
      reverse: true,
      // child: ListView.builder(
      //   scrollDirection: Axis.horizontal,
      //   reverse: true,
      //   physics: const PageScrollPhysics(),
      //   itemBuilder: (context, index) => Container(
      //     width: 1.sw,
      //     height: 200.w,
      //     color: Colors.primaries[(index + Random().nextInt(17)) % 17],
      //     alignment: Alignment.center,
      //     child: Text(
      //       '第${index + 1}页：'
      //       '\n实现下拉刷新：'
      //       '\n1，给列表新增刷新头部'
      //       '\n2，给头部新增滚动监听，并根据滚动显示对应视图'
      //       '\n3，添加自定义物理动画',
      //       style: const TextStyle(
      //         fontSize: 16,
      //         color: Colors.white,
      //       ),
      //     ),
      //   ),
      //   itemCount: 3,
      // ),

      child: PageView.builder(
        reverse: true,
        itemBuilder: (context, index) => Container(
          width: 1.sw,
          height: 200.w,
          color: Colors.primaries[(index + Random().nextInt(17)) % 17],
          alignment: Alignment.center,
          child: Text(
            '第${index + 1}页：'
            '\n实现下拉刷新：'
            '\n1，给列表新增刷新头部'
            '\n2，给头部新增滚动监听，并根据滚动显示对应视图'
            '\n3，添加自定义物理动画',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
        itemCount: 3,
      ),
    );
  }

  ///刷新头部
  Widget headerView() {
    return Container(
      height: 50,
      color: Colors.red,
      alignment: Alignment.center,
      child: Text(
        '我是刷新内容',
        style: TextStyle(
          fontSize: 16.sp,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget customBodyView() {
    return buildBodyBySlivers(
      context: context,
      childView: ListView.builder(
        itemBuilder: (context, index) => ListTile(
          title: Text('$index'),
        ),
        itemCount: 100,
      ),
    );
  }

  ///list转List<Sliver>,并且插入刷新头
  buildSliverByChild({required BuildContext context, required Widget child}) {
    List<Widget> slivers = [];
    if (child is ScrollView) {
      Logger.write('test child is ScrollView');
      if (child is BoxScrollView) {
        Logger.write('test child is BoxScrollView');
        // ignore: invalid_use_of_protected_member
        Widget sliver = child.buildChildLayout(context);
        slivers = [sliver];
      }
    }
    print('test slivers runType=${slivers.runtimeType}');
    slivers.insert(
        0,
        SliverToBoxAdapter(
          child: headerView(),
        ));
    return slivers;
  }

  ///整体List<Sliver>嵌入到custom中
  Widget buildBodyBySlivers({
    required BuildContext context,
    required Widget childView,
  }) {
    Widget body = CustomScrollView(
      slivers: buildSliverByChild(
        context: context,
        child: childView,
      ),
    );
    return body;
  }
}
