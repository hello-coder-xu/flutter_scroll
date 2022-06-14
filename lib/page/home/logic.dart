import 'package:flutter_scroll/page/home/model/home_model.dart';
import 'package:get/get.dart';

import 'state.dart';

class HomeLogic extends GetxController {
  final HomeState state = HomeState();

  @override
  void onInit() {
    super.onInit();

    updateList();
  }

  ///更新列表数据
  void updateList() {
    state.list.clear();
    state.list
      ..add(HomeModel(name: '自定义下拉刷新', path: ''))
      ..add(HomeModel(name: 'viewPage加载更多', path: ''));
  }

  ///item 点击
  void onItemTap(HomeModel bean) {
    Get.toNamed(bean.path);
  }
}
