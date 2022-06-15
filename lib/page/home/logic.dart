import 'package:flutter_scroll/common/router/app_pages.dart';
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
      ..add(HomeModel(name: '锚点', path: AppPaths.anchor))
      ..add(HomeModel(name: '下拉刷新', path: AppPaths.refresh))
      ..add(HomeModel(name: '多类型List', path: AppPaths.moreTypeList))
      ..add(HomeModel(name: 'Tab+PageView', path: AppPaths.tabAndPageView))
      ..add(HomeModel(name: 'PageView加载更多', path: AppPaths.pageViewLoadMore))
      ..add(HomeModel(name: '滚动时新增阴影', path: AppPaths.elevationByScroll));
    update();
  }

  ///item 点击
  void onItemTap(HomeModel bean) {
    Get.toNamed(bean.path);
  }
}
