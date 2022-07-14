import 'package:flutter/material.dart';
import 'package:flutter_scroll/common/widget/anchor/tw_anchor_view.dart';
import 'package:get/get.dart';

import 'state.dart';

class AnchorLogic extends GetxController with GetTickerProviderStateMixin {
  final AnchorState state = AnchorState();

  @override
  void onInit() {
    super.onInit();
    init();
  }

  /// 初始化
  void init() {
    state.anchorController = TwAnchorController();
    state.tabs = List.generate(8, (index) => 'index_${index + 1}');
    state.tabController = TabController(
      length: state.tabs.length,
      vsync: this,
    );
    state.tabController.addListener(() {
      if (state.tabController.indexIsChanging) {
        state.anchorController.scrollTo
            ?.call('index_${state.tabController.index + 1}');
      }
    });
  }

  /// 滚动改变tab
  void tabChange(int index) {
    if (state.tabController.index != index) {
      state.tabController.index = index;
    }
  }
}
