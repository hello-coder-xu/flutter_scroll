import 'package:flutter/material.dart';
import 'package:flutter_scroll/page/elevation_by_scroll/widget/elevation_by_custom.dart';
import 'package:flutter_scroll/page/elevation_by_scroll/widget/elevation_by_nested.dart';
import 'package:get/get.dart';
import 'logic.dart';

///滚动时新增阴影
class ElevationByScrollPage extends StatelessWidget {
  final logic = Get.put(ElevationByScrollLogic());
  final state = Get.find<ElevationByScrollLogic>().state;

  ElevationByScrollPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(toString()),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 1),
              ),
              margin: const EdgeInsets.all(16),
              child: const ElevationNestedScrollView(),
            ),
            Container(
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 1),
              ),
              margin: const EdgeInsets.all(16),
              child: const ElevationCustomView(),
            ),
          ],
        ),
      ),
    );
  }
}
