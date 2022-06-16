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
    return SmartRefresher(
      controller: controller,
      scrollDirection: Axis.horizontal,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const PageScrollPhysics(),
        itemBuilder: (context, index) => Container(
          width: 1.sw,
          height: 200.w,
          color: Colors.primaries[index],
          alignment: Alignment.center,
          child: Text('$index'),
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
