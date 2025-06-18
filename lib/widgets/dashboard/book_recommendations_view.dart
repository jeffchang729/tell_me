// lib/widgets/dashboard/book_recommendations_view.dart
// (從 BOOK ME 移植) 推薦內容橫向滾動視圖
import 'package:flutter/material.dart';
// [2024-06-18] 修正 import 路徑
import '../../config/app_theme.dart';
import '../../models/recommendations_data.dart';
import '../../utils/app_utils.dart';


class BookRecommendationsView extends StatefulWidget {
  const BookRecommendationsView(
      {Key? key, this.mainScreenAnimationController, this.mainScreenAnimation})
      : super(key: key);

  final AnimationController? mainScreenAnimationController;
  final Animation<double>? mainScreenAnimation;

  @override
  _BookRecommendationsViewState createState() =>
      _BookRecommendationsViewState();
}

class _BookRecommendationsViewState extends State<BookRecommendationsView>
    with TickerProviderStateMixin {
  AnimationController? animationController;
  List<RecommendationsData> recommendationsData =
      RecommendationsData.recommendationsList;

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
            child: SizedBox(
              height: 216,
              width: double.infinity,
              child: ListView.builder(
                padding: const EdgeInsets.only(
                    top: 0, bottom: 0, right: 16, left: 16),
                itemCount: recommendationsData.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int index) {
                  final int count = recommendationsData.length;
                  final Animation<double> animation =
                      Tween<double>(begin: 0.0, end: 1.0).animate(
                          CurvedAnimation(
                              parent: animationController!,
                              curve: Interval((1 / count) * index, 1.0,
                                  curve: Curves.fastOutSlowIn)));
                  animationController?.forward();

                  return RecommendationCard(
                    recommendationData: recommendationsData[index],
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

class RecommendationCard extends StatelessWidget {
  const RecommendationCard(
      {Key? key,
      this.recommendationData,
      this.animationController,
      this.animation})
      : super(key: key);

  final RecommendationsData? recommendationData;
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
                              color: HexColor(recommendationData!.endColor)
                                  .withOpacity(0.6),
                              offset: const Offset(1.1, 4.0),
                              blurRadius: 8.0),
                        ],
                        gradient: LinearGradient(
                          colors: <Color>[
                            HexColor(recommendationData!.startColor),
                            HexColor(recommendationData!.endColor),
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
                              recommendationData!.titleTxt,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: AppTheme.fontName,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppTheme.white,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8, bottom: 8),
                                child: Text(
                                  recommendationData!.items!.join('\n'),
                                  style: const TextStyle(
                                    fontFamily: AppTheme.fontName,
                                    fontSize: 10,
                                    color: AppTheme.white,
                                  ),
                                ),
                              ),
                            ),
                            if (recommendationData?.rating != 0.0)
                              Row(
                                children: <Widget>[
                                  Text(
                                    '★${recommendationData!.rating.toString()}',
                                    style: const TextStyle(
                                      fontFamily: AppTheme.fontName,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      color: AppTheme.white,
                                    ),
                                  ),
                                ],
                              )
                            else
                              Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.nearlyWhite,
                                  shape: BoxShape.circle,
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                        color: AppTheme.nearlyBlack.withOpacity(0.4),
                                        offset: const Offset(8.0, 8.0),
                                        blurRadius: 8.0),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: Icon(
                                    Icons.add,
                                    color: HexColor(recommendationData!.endColor),
                                    size: 24,
                                  ),
                                ),
                              ),
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
                  Positioned(
                    top: 0,
                    left: 8,
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: Image.asset(recommendationData!.imagePath),
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
