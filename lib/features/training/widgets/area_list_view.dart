// features/training/widgets/area_list_view.dart
// 運動焦點區域元件
// 功能：顯示運動焦點區域的網格清單

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// 運動焦點區域清單視圖
/// 
/// 顯示運動焦點區域的網格清單，包含：
/// - 2x2 網格佈局
/// - 每個區域的圖片和互動效果
/// - 點擊選擇功能
class AreaListView extends StatefulWidget {
  const AreaListView({
    Key? key,
    this.mainScreenAnimationController,
    this.mainScreenAnimation,
  }) : super(key: key);

  final AnimationController? mainScreenAnimationController;
  final Animation<double>? mainScreenAnimation;

  @override
  _AreaListViewState createState() => _AreaListViewState();
}

class _AreaListViewState extends State<AreaListView>
    with TickerProviderStateMixin {
  
  /// 內部動畫控制器
  AnimationController? animationController;
  
  /// 焦點區域圖片清單
  List<String> areaListData = <String>[
    'assets/fitness_app/area1.png',
    'assets/fitness_app/area2.png',
    'assets/fitness_app/area3.png',
    'assets/fitness_app/area1.png',
  ];

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.mainScreenAnimationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: widget.mainScreenAnimation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 30 * (1.0 - widget.mainScreenAnimation!.value), 0.0),
            child: AspectRatio(
              aspectRatio: 1.0,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8),
                child: GridView(
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, top: 16, bottom: 16),
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  children: List<Widget>.generate(
                    areaListData.length,
                    (int index) {
                      final int count = areaListData.length;
                      final Animation<double> animation =
                          Tween<double>(begin: 0.0, end: 1.0).animate(
                        CurvedAnimation(
                          parent: animationController!,
                          curve: Interval((1 / count) * index, 1.0,
                              curve: Curves.fastOutSlowIn),
                        ),
                      );
                      animationController?.forward();
                      return AreaView(
                        imagepath: areaListData[index],
                        animation: animation,
                        animationController: animationController!,
                        onTap: () => _handleAreaTap(index),
                      );
                    },
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 24.0,
                    crossAxisSpacing: 24.0,
                    childAspectRatio: 1.0,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 處理區域點擊
  void _handleAreaTap(int index) {
    // 實現區域選擇邏輯
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('選擇了運動區域 ${index + 1}'),
        backgroundColor: AppTheme.nearlyDarkBlue,
        duration: Duration(seconds: 1),
      ),
    );
  }
}

/// 單個運動區域視圖
/// 
/// 顯示單個運動焦點區域的卡片
class AreaView extends StatelessWidget {
  const AreaView({
    Key? key,
    this.imagepath,
    this.animationController,
    this.animation,
    this.onTap,
  }) : super(key: key);

  final String? imagepath;
  final AnimationController? animationController;
  final Animation<double>? animation;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 50 * (1.0 - animation!.value), 0.0),
            child: Container(
              decoration: AppTheme.cardDecoration(),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  focusColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                  splashColor: AppTheme.nearlyDarkBlue.withOpacity(0.2),
                  onTap: onTap,
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Image.asset(
                            imagepath!,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}