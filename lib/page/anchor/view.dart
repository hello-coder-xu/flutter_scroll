import 'package:flutter/material.dart';
import 'package:flutter_scroll/common/widget/anchor/tw_anchor_item_view.dart';
import 'package:flutter_scroll/common/widget/anchor/tw_anchor_view.dart';
import 'package:get/get.dart';
import 'package:collection/collection.dart';
import 'logic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 锚点视图
class AnchorPage extends StatelessWidget {
  final logic = Get.put(AnchorLogic());
  final state = Get.find<AnchorLogic>().state;

  AnchorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AnchorLogic>(
      assignId: true,
      builder: (GetxController controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text(toString()),
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(48.w),
              child: SizedBox(
                height: 48.w,
                child: TabBar(
                  isScrollable: true,
                  controller: state.tabController,
                  tabs: state.tabs.map((e) => Tab(text: e)).toList(),
                ),
              ),
            ),
          ),
          body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return TwAnchorView(
                controller: state.anchorController,
                tabChanged: logic.tabChange,
                children: state.tabs
                    .mapIndexed(
                      (index, element) => TwAnchorItemView(
                        tabIndex: index,
                        tag: element,
                        child: Container(
                          height: constraints.maxHeight + 100,
                          color: Colors.primaries[index % 17],
                          alignment: Alignment.center,
                          child: Text(
                            element,
                            style: TextStyle(
                              fontSize: 30.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        );
      },
    );
  }
}
