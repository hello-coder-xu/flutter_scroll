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

  final String image =
      'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Farticle-fd.zol-img.com.cn%2Ft_s998x562c5%2Fg5%2FM00%2F0A%2F02%2FChMkJltpVKGIQENcAAKaC93UFtUAAqi5QPdcOwAApoj403.jpg&refer=http%3A%2F%2Farticle-fd.zol-img.com.cn&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=auto?sec=1657797160&t=b0d3ce684c3467dc7b03a2eb5c752d5e';

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
              child: Stack(
                children: [
                  Container(
                    height: 200.w,
                    width: 1.sw,
                    color: Colors.green,
                    child: Image.network(
                      image,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      color: Colors.green.withOpacity(0.3),
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Text(
                        '1,顶部图片跟随滚动'
                        '\n2,tab栏滚动到顶部时顶在最上面'
                        '\n3,tabView第一次左右切换时，下一个页面处于最顶部位置'
                        '\n4,tabView保存上次滚动位置',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverPersistentHeader(
                pinned: true,
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
    return Builder(
      builder: (BuildContext context) => CustomScrollView(
        key: PageStorageKey<int>(index),
        slivers: [
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, position) => Container(
                height: 100.w,
                alignment: Alignment.center,
                color: Colors.primaries[position % 17],
                child: Text('$index' '_$position'),
              ),
              childCount: index + 5,
            ),
          ),
        ],
      ),
    );
  }
}
