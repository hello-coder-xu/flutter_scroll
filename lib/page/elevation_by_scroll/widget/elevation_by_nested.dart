import 'package:flutter/material.dart';
import 'package:flutter_scroll/common/widget/elevation_header_delete.dart';

class ElevationNestedScrollView extends StatefulWidget {
  const ElevationNestedScrollView({Key? key}) : super(key: key);

  @override
  State<ElevationNestedScrollView> createState() =>
      _ElevationNestedScrollViewState();
}

class _ElevationNestedScrollViewState extends State<ElevationNestedScrollView> {
  bool display = false;

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [
          if (display)
            SliverToBoxAdapter(
              child: Container(
                height: 50,
                color: Colors.green,
                alignment: Alignment.center,
                child: const Text('我是头部',style: TextStyle(color: Colors.white),),
              ),
            ),
          SliverPersistentHeader(
            pinned: true,
            delegate: ElevationSliverPersistentHeaderDelegate(
              child: Container(
                color: Colors.white,
                height: 48,
                alignment: Alignment.center,
                child: const Text('我是ElevationNestedScrollView标题'),
              ),
            ),
          ),
        ];
      },
      body: ListView.builder(
        itemBuilder: (context, index) {
          if (index == 0) {
            return ListTile(
              title: Text(display ? '点击我隐藏头部视图' : '点击我显示头部视图'),
              onTap: () {
                display = !display;
                setState(() {});
              },
            );
          } else {
            return ListTile(
              title: Text('$index'),
            );
          }
        },
        itemCount: 100,
      ),
    );
  }
}
