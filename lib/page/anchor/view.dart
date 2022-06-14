import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'logic.dart';

class AnchorPage extends StatelessWidget {
  final logic = Get.put(AnchorLogic());
  final state = Get.find<AnchorLogic>().state;

  AnchorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(toString()),
        centerTitle: true,
      ),
    );
  }
}
