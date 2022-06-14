import 'package:flutter_scroll/page/anchor/view.dart';
import 'package:flutter_scroll/page/home/view.dart';
import 'package:flutter_scroll/page/more_type_list/view.dart';
import 'package:flutter_scroll/page/page_view_load_more/view.dart';
import 'package:flutter_scroll/page/refresh/view.dart';
import 'package:get/get.dart';

abstract class AppPaths {
  static const home = '/home';
  static const anchor = '/anchor';
  static const moreTypeList = '/moreTypeList';
  static const pageViewLoadMore = '/pageViewLoadMore';
  static const refresh = '/refresh';
}

class AppPages {
  AppPages._();

  static const initial = AppPaths.home;

  static final routes = [
    GetPage(
      name: AppPaths.home,
      page: () => HomePage(),
    ),
    GetPage(
      name: AppPaths.anchor,
      page: () => AnchorPage(),
    ),
    GetPage(
      name: AppPaths.moreTypeList,
      page: () => MoreTypeListPage(),
    ),
    GetPage(
      name: AppPaths.pageViewLoadMore,
      page: () => PageViewLoadMorePage(),
    ),
    GetPage(
      name: AppPaths.refresh,
      page: () => RefreshPage(),
    ),
  ];
}
