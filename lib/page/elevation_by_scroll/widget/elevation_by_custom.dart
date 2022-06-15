import 'package:flutter/material.dart';
import 'package:flutter_scroll/common/widget/elevation_header_delete.dart';

class ElevationCustomView extends StatefulWidget {
  const ElevationCustomView({Key? key}) : super(key: key);

  @override
  State<ElevationCustomView> createState() => _ElevationCustomViewState();
}

class _ElevationCustomViewState extends State<ElevationCustomView> {
  bool display = false;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        if (display)
          SliverToBoxAdapter(
            child: Container(
              height: 50,
              color: Colors.green,
              alignment: Alignment.center,
              child: const Text(
                '我是头部',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        SliverPersistentHeader(
          pinned: true,
          delegate: ElevationSliverPersistentHeaderDelegate(
            child: Container(
              color: Colors.white,
              height: 48,
              alignment: Alignment.center,
              child: const Text('我是ElevationCustomView标题'),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
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
            childCount: 100,
          ),
        ),
      ],
    );
  }
}
