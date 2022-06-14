import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'logic.dart';

class RefreshPage extends StatelessWidget {
  final logic = Get.put(RefreshLogic());
  final state = Get.find<RefreshLogic>().state;

  RefreshPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(toString()),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('功能待开发'),
      ),
    );
  }
}
