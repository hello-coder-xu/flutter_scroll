import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'state.dart';

class TabAndPageViewLogic extends GetxController
    with GetSingleTickerProviderStateMixin {
  final TabAndPageViewState state = TabAndPageViewState();

  @override
  void onInit() {
    super.onInit();
    state.controller = TabController(
      length: state.tabList.length,
      vsync: this,
    );
  }

  @override
  void onClose() {
    state.controller.dispose();
    super.onClose();
  }
}
