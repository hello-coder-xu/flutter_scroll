import 'package:flutter/material.dart';

class TabAndPageViewState {
  List<String> tabList = List.generate(5, (index) => '$index');
  late TabController controller;
}
