// lib/widgets/dashboard/suggestion_view.dart
// (從 BOOK ME 移植) AI建議提示視圖
import 'package:flutter/material.dart';
// [2024-06-18] 修正 import 路徑
import '../../config/app_theme.dart';
import '../../utils/app_utils.dart';

class SuggestionView extends StatelessWidget {
  final AnimationController? animationController;
  final Animation<double>? animation;

  const SuggestionView({Key? key, this.animationController, this.animation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 30 * (1.0 - animation!.value), 0.0),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 24, right: 24, top: 16, bottom: 24),
              child: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.only(
                        top: 16, bottom: 16, left: 16, right: 100),
                    decoration: BoxDecoration(
                      color: HexColor("#D7E0F9"),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(16.0)),
                    ),
                    child: Text(
                      'AI 發現您最近關注許多科技股，是否要為您建立「半導體」的追蹤卡片？',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontFamily: AppTheme.fontName,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        letterSpacing: 0.0,
                        color: AppTheme.nearlyDarkBlue.withOpacity(0.8),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -12,
                    right: -4,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.nearlyDarkBlue.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 8,
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: Icon(
                        Icons.lightbulb_outline,
                        color: AppTheme.white,
                        size: 40,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
