// features/diary/widgets/meals_list_view.dart
// 餐點清單檢視元件 - 已整合 Canvas 繪製圖示
// 功能：顯示每日餐點記錄，早餐圖示使用 CustomPaint 繪製

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/health_models.dart';
import '../../../core/utils/app_utils.dart';

/// 餐點清單檢視元件 - 主要容器
class MealsListView extends StatefulWidget {
  const MealsListView({
    Key? key,
    this.mainScreenAnimationController,
    this.mainScreenAnimation,
  }) : super(key: key);

  final AnimationController? mainScreenAnimationController;
  final Animation<double>? mainScreenAnimation;

  @override
  _MealsListViewState createState() => _MealsListViewState();
}

class _MealsListViewState extends State<MealsListView>
    with TickerProviderStateMixin {
  AnimationController? animationController;
  List<MealData> mealsListData = MealData.defaultMeals;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
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
            child: Container(
              height: 216,
              width: double.infinity,
              child: ListView.builder(
                padding: const EdgeInsets.only(
                    top: 0, bottom: 0, right: 16, left: 16),
                itemCount: mealsListData.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int index) {
                  final int count = mealsListData.length;
                  final Animation<double> animation =
                      Tween<double>(begin: 0.0, end: 1.0).animate(
                          CurvedAnimation(
                              parent: animationController!,
                              curve: Interval((1 / count) * index, 1.0,
                                  curve: Curves.fastOutSlowIn)));
                  animationController?.forward();

                  return MealsView(
                    mealData: mealsListData[index],
                    animation: animation,
                    animationController: animationController!,
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 單個餐點的卡片元件
class MealsView extends StatelessWidget {
  const MealsView({
    Key? key,
    this.mealData,
    this.animationController,
    this.animation,
  }) : super(key: key);

  final MealData? mealData;
  final AnimationController? animationController;
  final Animation<double>? animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation!,
          child: Transform(
            transform: Matrix4.translationValues(
                100 * (1.0 - animation!.value), 0.0, 0.0),
            child: SizedBox(
              width: 130,
              child: Stack(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 32, left: 8, right: 8, bottom: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              color: HexColor(mealData!.endColor)
                                  .withOpacity(0.6),
                              offset: const Offset(1.1, 4.0),
                              blurRadius: 8.0),
                        ],
                        gradient: LinearGradient(
                          colors: <HexColor>[
                            HexColor(mealData!.startColor),
                            HexColor(mealData!.endColor),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(8.0),
                          bottomLeft: Radius.circular(8.0),
                          topLeft: Radius.circular(8.0),
                          topRight: Radius.circular(54.0),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 54, left: 16, right: 16, bottom: 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              mealData!.titleTxt,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: AppTheme.fontName,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 0.2,
                                color: AppTheme.white,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(top: 8, bottom: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      mealData!.meals!.join('\n'),
                                      style: TextStyle(
                                        fontFamily: AppTheme.fontName,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 10,
                                        letterSpacing: 0.2,
                                        color: AppTheme.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            _buildBottomSection(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: AppTheme.nearlyWhite.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // 這部分決定圖示的顯示方式
                  Positioned(
                    top: 4,  // 微調位置以達到最佳視覺效果
                    left: 12, // 微調位置以達到最佳視覺效果
                    child: _getMealIcon(), // 使用一個方法來決定顯示哪個圖示
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 根據餐點類型返回對應的圖示 Widget
  Widget _getMealIcon() {
    final String title = mealData!.titleTxt.toLowerCase();
    
    // 如果是早餐，使用我們自訂的 Canvas Painter
    if (title.contains('breakfast')) {
      return CustomPaint(
        size: const Size(60, 60), // 給定一個固定尺寸
        painter: BreakfastIconPainter(),
      );
    } 
    // 其他餐點圖示暫時使用圖片
    else {
       return SizedBox(
            width: 80,
            height: 80,
            child: Image.asset(mealData!.imagePath),
        );
    }
  }


  /// 建立底部區域（卡路里顯示或新增按鈕）
  Widget _buildBottomSection() {
    if (mealData?.kacl != 0) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(
            mealData!.kacl.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              fontWeight: FontWeight.w500,
              fontSize: 24,
              letterSpacing: 0.2,
              color: AppTheme.white,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 3),
            child: Text(
              'kcal',
              style: TextStyle(
                fontFamily: AppTheme.fontName,
                fontWeight: FontWeight.w500,
                fontSize: 10,
                letterSpacing: 0.2,
                color: AppTheme.white,
              ),
            ),
          ),
        ],
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          color: AppTheme.nearlyWhite,
          shape: BoxShape.circle,
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: AppTheme.nearlyBlack.withOpacity(0.4),
                offset: Offset(8.0, 8.0),
                blurRadius: 8.0),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Icon(
            Icons.add,
            color: HexColor(mealData!.endColor),
            size: 24,
          ),
        ),
      );
    }
  }
}

/// 使用 Canvas 繪製早餐圖示的自訂畫筆
class BreakfastIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 取得畫布的寬高，方便計算相對位置
    final double w = size.width;
    final double h = size.height;

    // 定義各種畫筆 (Paint)
    final toastPaint = Paint()..color = Color(0xFFE8B17A);
    final toastBorderPaint = Paint()
      ..color = Color(0xFFD4985C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final eggWhitePaint = Paint()..color = Colors.white;
    final eggYolkPaint = Paint()..color = Color(0xFFFFC107);
    
    // 繪製吐司陰影 (稍微偏移)
    final shadowRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.12, h * 0.32, w * 0.8, h * 0.6), 
        Radius.circular(8)
    );
    canvas.drawRRect(shadowRRect, Paint()..color = Colors.black.withOpacity(0.15));

    // 繪製吐司主體 (使用圓角矩形 RRect)
    final toastRect = Rect.fromLTWH(w * 0.1, h * 0.3, w * 0.8, h * 0.6);
    final toastRRect = RRect.fromRectAndRadius(toastRect, Radius.circular(8));
    canvas.drawRRect(toastRRect, toastPaint);
    canvas.drawRRect(toastRRect, toastBorderPaint);

    // 繪製煎蛋白 (使用另一個不規則圓角矩形)
    final eggWhiteRect = Rect.fromLTWH(w * 0.25, h * 0.15, w * 0.5, h * 0.5);
    final eggWhiteRRect = RRect.fromRectAndCorners(
      eggWhiteRect,
      topLeft: Radius.circular(20),
      topRight: Radius.circular(15),
      bottomLeft: Radius.circular(18),
      bottomRight: Radius.circular(22),
    );
    canvas.drawRRect(eggWhiteRRect, eggWhitePaint);

    // 繪製蛋黃 (圓形)
    canvas.drawCircle(Offset(w * 0.5, h * 0.4), w * 0.15, eggYolkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // 因為圖示是靜態的，所以不需要重繪
    return false;
  }
}