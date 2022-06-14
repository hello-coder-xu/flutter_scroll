import 'package:flutter/material.dart';
import 'package:flutter_scroll/page/home/model/home_model.dart';
import 'package:get/get.dart';

import 'logic.dart';

///首页
class HomePage extends StatelessWidget {
  final logic = Get.put(HomeLogic());
  final state = Get.find<HomeLogic>().state;

  HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('滚动相关功能'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: logic.updateList,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: GetBuilder<HomeLogic>(
        assignId: true,
        builder: (logic) {
          return ListView.separated(
            itemBuilder: (context, index) {
              HomeModel bean = state.list[index];
              return ListTile(
                title: Text(bean.name),
                subtitle: Text(bean.path),
                onTap: () => logic.onItemTap(bean),
              );
            },
            separatorBuilder: (context, _) => const Divider(height: 1),
            itemCount: state.list.length,
          );
        },
      ),
    );
  }
}
