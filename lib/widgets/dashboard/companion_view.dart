// lib/widgets/dashboard/companion_view.dart
// (從 BOOK ME 移植) AI助手陪伴視圖
import 'package:flutter/material.dart';
// [2024-06-18] 修正 import 路徑
import '../../config/app_theme.dart';
import '../chart_widgets.dart'; // WaveView 在此檔案中

class CompanionView extends StatelessWidget {
  final AnimationController? mainScreenAnimationController;
  final Animation<double>? mainScreenAnimation;

  const CompanionView(
      {Key? key, this.mainScreenAnimationController, this.mainScreenAnimation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: mainScreenAnimationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: mainScreenAnimation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 30 * (1.0 - mainScreenAnimation!.value), 0.0),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 24, right: 24, top: 16, bottom: 18),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8.0),
                      bottomLeft: Radius.circular(8.0),
                      bottomRight: Radius.circular(8.0),
                      topRight: Radius.circular(68.0)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: AppTheme.grey.withOpacity(0.2),
                        offset: const Offset(1.1, 1.1),
                        blurRadius: 10.0),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                             const Text(
                              'AI 智慧助理',
                              style: TextStyle(
                                fontFamily: AppTheme.fontName,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: AppTheme.darkerText,
                              ),
                            ),
                             const SizedBox(height: 8),
                            Text(
                              '我可以為您摘要新聞、分析股價，有什麼想知道的嗎？',
                              style: TextStyle(
                                fontFamily: AppTheme.fontName,
                                fontSize: 14,
                                color: AppTheme.grey,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                                onPressed: () {},
                                child: const Text('開始對話'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.nearlyDarkBlue,
                                  foregroundColor: AppTheme.white,
                                ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 80,
                        height: 80,
                        child: const WaveView(percentageValue: 85.0),
                      )
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
