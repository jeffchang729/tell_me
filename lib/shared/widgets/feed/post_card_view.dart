// shared/widgets/feed/post_card_view.dart
// [修改] 水平滾動的 "主題資訊卡片" 列表

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../models/meal_card_data.dart';
import '../../../core/utils/app_utils.dart';

class PostCardView extends StatefulWidget {
  const PostCardView({Key? key, required this.meals}) : super(key: key);

  // 雖然變數名是 meals，但我們將它視為 "主題卡片" 的資料來源
  final List<MealCardData> meals;

  @override
  _PostCardViewState createState() => _PostCardViewState();
}

class _PostCardViewState extends State<PostCardView> with TickerProviderStateMixin {
  AnimationController? animationController;

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
    return SizedBox(
      height: 180, // [美化] 稍微降低高度，讓版面更緊湊
      width: double.infinity,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 0, bottom: 0, right: 16, left: 16),
        itemCount: widget.meals.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          final int count = widget.meals.length;
          final Animation<double> animation =
              Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
                  parent: animationController!,
                  curve: Interval((1 / count) * index, 1.0,
                      curve: Curves.fastOutSlowIn)));
          animationController?.forward();

          return MealCard(
            mealData: widget.meals[index],
            animation: animation,
            animationController: animationController,
          );
        },
      ),
    );
  }
}

// [修改] 單一 "主題資訊卡片"
class MealCard extends StatelessWidget {
  const MealCard({
    Key? key,
    this.mealData,
    this.animationController,
    this.animation,
  }) : super(key: key);

  final MealCardData? mealData;
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
              // [美化] 設定固定寬度，確保所有卡片大小一致
              width: 120,
              child: Stack(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 32, left: 8, right: 8, bottom: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              color: HexColor(mealData!.endColor).withOpacity(0.6),
                              offset: const Offset(1.1, 4.0),
                              blurRadius: 8.0),
                        ],
                        gradient: LinearGradient(
                          colors: <Color>[
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
                            // 顯示主題名稱，例如 "股票"
                            const Spacer(), // 使用 Spacer 將文字推到卡片底部
                            Text(
                              mealData!.title,
                              textAlign: TextAlign.left, // 文字靠左
                              style: const TextStyle(
                                fontFamily: AppTheme.fontName,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                letterSpacing: 0.2,
                                color: AppTheme.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // 將圖片替換為主題的第一個字
                  Positioned(
                    top: -10,
                    left: -8,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2), // 稍微調亮背景圓圈
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: Center(
                        child: Text(
                          mealData!.title.substring(0, 1),
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            // [美化] 將文字顏色改為深灰色，並調整陰影
                            color: AppTheme.darkerText,
                            shadows: [
                              Shadow(
                                blurRadius: 2.0,
                                color: Colors.black.withOpacity(0.1),
                                offset: const Offset(1.0, 1.0),
                              ),
                            ]
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}