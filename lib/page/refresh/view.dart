import 'package:flutter/material.dart';
import 'package:flutter_scroll/page/refresh/widget/list_view_footer.dart';
import 'package:flutter_scroll/page/refresh/widget/list_view_header.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
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
    // return SmartRefresher(
    //   controller: controller,
    //   child: ListView.builder(
    //     itemBuilder: (context, index) => Container(
    //       height: 50,
    //       child: Text('$index'),
    //       alignment: Alignment.center,
    //       color: Colors.primaries[index % 17],
    //     ),
    //     itemCount: 23,
    //   ),
    // );

    return CustomScrollView(
      physics:
          const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        ListViewHeader(
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
              height: 50,
              child: Text('$index'),
              alignment: Alignment.center,
              color: Colors.primaries[index % 17],
            ),
            childCount: 23,
          ),
        ),
        ListViewFooter(
          child: Container(
            height: 50,
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
      ],
    );
  }
}
