import 'package:flutter/material.dart';
import 'package:flutter_scroll/common/widget/elevation_header_delete.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'logic.dart';
import 'package:collection/collection.dart';

class TabAndPageViewPage extends StatelessWidget {
  TabAndPageViewPage({Key? key}) : super(key: key);

  final logic = Get.put(TabAndPageViewLogic());

  final state = Get.find<TabAndPageViewLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(toString()),
        centerTitle: true,
      ),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Container(
                height: 100.w,
                color: Colors.green,
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              floating: true,
              delegate: ElevationSliverPersistentHeaderDelegate(
                child: Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: state.controller,
                    unselectedLabelColor: Colors.black,
                    labelColor: Colors.red,
                    tabs: state.tabList.map((e) => Tab(text: e)).toList(),
                  ),
                ),
              ),
            ),
          ];
        },
        body: Container(
          color: Colors.black.withOpacity(0.4),
          alignment: Alignment.topCenter,
          child: TabBarView(
            controller: state.controller,
            children: state.tabList.mapIndexed(itemView).toList(),
          ),
        ),
      ),
    );
  }

  ///列表视图
  Widget itemView(int index, String value) {
    return ListView.builder(
      itemBuilder: (context, position) => Container(
        height: 100.w,
        alignment: Alignment.center,
        color: Colors.primaries[position % 17],
        child: Text('$index' '_$position'),
      ),
      itemCount: index + 5,
    );
  }
}
