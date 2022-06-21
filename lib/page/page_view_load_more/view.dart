import 'package:flutter/material.dart';
import 'package:flutter_scroll/page/page_view_load_more/my_header_view.dart';
import 'package:get/get.dart';

import 'logic.dart';

class PageViewLoadMorePage extends StatefulWidget {
  const PageViewLoadMorePage({Key? key}) : super(key: key);

  @override
  State<PageViewLoadMorePage> createState() => _PageViewLoadMorePageState();
}

class _PageViewLoadMorePageState extends State<PageViewLoadMorePage> {
  final logic = Get.put(PageViewLoadMoreLogic());

  final state = Get.find<PageViewLoadMoreLogic>().state;

  int itemCount = 13;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(toString()),
        centerTitle: true,
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          MyHeaderView(
            child: Container(
              height: 100,
              alignment: Alignment.center,
              color: Colors.black,
              child: const Text(
                'header',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Container(
                height: 200,
                child: Text('$index'),
                alignment: Alignment.center,
                color: Colors.primaries[index % 17],
              ),
              childCount: itemCount,
            ),
          )
        ],
      ),
    );
  }
}
