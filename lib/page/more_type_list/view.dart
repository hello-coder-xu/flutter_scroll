import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'logic.dart';

class MoreTypeListPage extends StatelessWidget {
  final logic = Get.put(MoreTypeListLogic());
  final state = Get.find<MoreTypeListLogic>().state;

  MoreTypeListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(toString()),
      ),
    );
  }
}
