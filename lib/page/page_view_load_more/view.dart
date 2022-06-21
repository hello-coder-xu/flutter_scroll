import 'package:flutter/material.dart';
import 'package:flutter_scroll/page/page_view_load_more/page_view_load_more.dart';
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
      body: PageViewLoadMore.builder(
        itemBuilder: (context, index) {
          return Container(
            height: 200,
            child: Text('$index'),
            alignment: Alignment.center,
            color: Colors.primaries[index % 17],
          );
        },
        itemCount: 3,
      ),
    );
  }
}
