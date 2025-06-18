// lib/widgets/dashboard/progress_view.dart
// (從 BOOK ME 移植) 進度追蹤視圖
import 'package:flutter/material.dart';
// [2024-06-18] 修正 import 路徑
import '../../config/app_theme.dart';

class ProgressView extends StatelessWidget {
  final AnimationController? animationController;
  final Animation<double>? animation;

  const ProgressView({Key? key, this.animationController, this.animation})
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
                  child: Column(
                    children: <Widget>[
                      const Text(
                        '本月進度達成率',
                        style: TextStyle(
                            fontFamily: AppTheme.fontName,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: AppTheme.darkText),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildProgressItem('已完成', '78%', AppTheme.nearlyDarkBlue),
                          _buildProgressItem('平均評分', '4.5 ★', AppTheme.nearlyBlue),
                          _buildProgressItem('進行中', '5 項', Colors.orange),
                        ],
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

  Widget _buildProgressItem(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: AppTheme.fontName,
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontFamily: AppTheme.fontName,
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: AppTheme.grey.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}
