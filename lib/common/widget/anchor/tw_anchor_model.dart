///滚动与tab联动模型
class TwAnchorModel {
  /// 对应tab的下标
  int tabIndex;

  /// 当前标签
  String tag;

  /// tab联动列表滚动位置(考虑:滚动后是否会回弹问题)
  double scrollOffset;

  /// 用于计算-列表联动tab位置
  double start;
  double end;

  TwAnchorModel({
    required this.tabIndex,
    required this.tag,
    this.scrollOffset = 0,
    this.start = 0,
    this.end = 0,
  });

  @override
  String toString() {
    return 'tabIndex=$tabIndex tag=$tag start=$start end=$end scrollOffset=$scrollOffset';
  }
}
