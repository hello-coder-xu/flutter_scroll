import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 标题滚动渐变
/// header跟随滚动
/// tab吸顶
/// listview
class TitleHeaderTabListViewPage extends StatefulWidget {
  const TitleHeaderTabListViewPage({Key? key}) : super(key: key);

  @override
  State<TitleHeaderTabListViewPage> createState() =>
      _TitleHeaderTabListViewPageState();
}

class _TitleHeaderTabListViewPageState
    extends State<TitleHeaderTabListViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: contentView(),
    );
  }

  Widget contentView() {
    return Stack(
      children: [
        bodyView2(),
        Container(
          padding: EdgeInsets.only(top: ScreenUtil().statusBarHeight),
          height: 50 + ScreenUtil().statusBarHeight,
          alignment: Alignment.center,
          color: Colors.black.withOpacity(0.2),
          child: const Text('title'),
        ),
      ],
    );
  }

  Widget bodyView() {
    return CustomScrollView(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: TwSliverPersistentHeaderDelegate(
            backgroundHeight: 200,
            bottomHeight: 48,
            offset: 50 + ScreenUtil().statusBarHeight,
            bottom: Container(
              height: 48,
              width: 1.sw,
              alignment: Alignment.center,
              color: Colors.blue,
              child: const Text('tab'),
            ),
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    Colors.green,
                  ],
                ),
              ),
              alignment: Alignment.center,
              child: Column(
                children: List.generate(
                  4,
                  (index) => Container(
                    color: Colors.primaries[index],
                    alignment: Alignment.center,
                    height: 50,
                    width: 1.sw,
                    child: Text('$index'),
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => ListTile(title: Text('Item #$index')),
            // Builds 1000 ListTiles
            childCount: 1000,
          ),
        ),
      ],
    );
  }

  Widget bodyView2() {
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: SliverPersistentHeader(
              pinned: true,
              delegate: TwSliverPersistentHeaderDelegate(
                backgroundHeight: 200,
                bottomHeight: 48,
                offset: 50 + ScreenUtil().statusBarHeight,
                bottom: Container(
                  height: 48,
                  width: 1.sw,
                  alignment: Alignment.center,
                  color: Colors.blue,
                  child: const Text('tab'),
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white,
                        Colors.green,
                      ],
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    children: List.generate(
                      4,
                      (index) => Container(
                        color: Colors.primaries[index],
                        alignment: Alignment.center,
                        height: 50,
                        width: 1.sw,
                        child: Text('$index'),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ];
      },
      body: Builder(
        builder: (BuildContext context) => CustomScrollView(
          // key: PageStorageKey<int>(1),
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
                  child: Text('1' '_$position'),
                ),
                childCount: 100,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget bodyView3() {
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: SliverToBoxAdapter(
              child: Container(
                height: 100,
                color: Colors.green,
              ),
            ),
          ),
        ];
      },
      body: Builder(
        builder: (BuildContext context) => CustomScrollView(
          // key: PageStorageKey<int>(1),
          slivers: [
            SliverOverlapInjector(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: TwSliverPersistentHeaderDelegate(
                backgroundHeight: 200,
                bottomHeight: 48,
                offset: 50 + ScreenUtil().statusBarHeight,
                bottom: Container(
                  height: 48,
                  width: 1.sw,
                  alignment: Alignment.center,
                  color: Colors.blue,
                  child: const Text('tab'),
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white,
                        Colors.green,
                      ],
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    children: List.generate(
                      4,
                      (index) => Container(
                        color: Colors.primaries[index],
                        alignment: Alignment.center,
                        height: 50,
                        width: 1.sw,
                        child: Text('$index'),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, position) => Container(
                  height: 100.w,
                  alignment: Alignment.center,
                  color: Colors.primaries[position % 17],
                  child: Text('1' '_$position'),
                ),
                childCount: 100,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TwSliverPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget background;
  final Widget bottom;
  final double backgroundHeight;
  final double bottomHeight;
  final double offset;

  TwSliverPersistentHeaderDelegate({
    required this.bottom,
    required this.background,
    required this.backgroundHeight,
    required this.bottomHeight,
    this.offset = 0,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        Positioned(
          // top: math.max(minExtent - maxExtent, -shrinkOffset),
          top: -shrinkOffset,
          left: 0,
          right: 0,
          child: background,
        ),
        Positioned(
          bottom: 0,
          child: bottom,
        )
      ],
    );
  }

  @override
  double get maxExtent => bottomHeight + backgroundHeight;

  @override
  double get minExtent => bottomHeight + offset;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
