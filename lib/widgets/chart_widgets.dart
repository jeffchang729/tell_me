// lib/widgets/chart_widgets.dart
// 圖表元件集合
// 功能：包含各種圖表和資料視覺化元件

import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../config/app_theme.dart';
import '../utils/app_utils.dart';

/// 地中海飲食統計圖表元件
/// 
/// 顯示卡路里攝取、消耗和營養素分布的圓形圖表
class MediterraneanDietView extends StatelessWidget {
  final AnimationController? animationController;
  final Animation<double>? animation;

  const MediterraneanDietView({
    Key? key,
    this.animationController,
    this.animation,
  }) : super(key: key);

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
                decoration: AppTheme.specialCardDecoration(),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 16, left: 16, right: 16),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 8, right: 8, top: 4),
                              child: Column(
                                children: <Widget>[
                                  _buildCalorieItem(
                                    title: 'Eaten',
                                    value: (1127 * animation!.value).toInt(),
                                    unit: 'Kcal',
                                    icon: 'assets/fitness_app/eaten.png',
                                    color: HexColor('#87A0E5'),
                                  ),
                                  SizedBox(height: 8),
                                  _buildCalorieItem(
                                    title: 'Burned',
                                    value: (102 * animation!.value).toInt(),
                                    unit: 'Kcal',
                                    icon: 'assets/fitness_app/burned.png',
                                    color: HexColor('#F56E98'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // 圓形進度圖表
                          Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: Center(
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: AppTheme.white,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(100.0),
                                        ),
                                        border: Border.all(
                                            width: 4,
                                            color: AppTheme.nearlyDarkBlue
                                                .withOpacity(0.2)),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            '${(1503 * animation!.value).toInt()}',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: AppTheme.fontName,
                                              fontWeight: FontWeight.normal,
                                              fontSize: 24,
                                              letterSpacing: 0.0,
                                              color: AppTheme.nearlyDarkBlue,
                                            ),
                                          ),
                                          Text(
                                            'Kcal left',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: AppTheme.fontName,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              letterSpacing: 0.0,
                                              color: AppTheme.grey
                                                  .withOpacity(0.5),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: CustomPaint(
                                      painter: CurvePainter(
                                          colors: [
                                            AppTheme.nearlyDarkBlue,
                                            HexColor("#8A98E8"),
                                            HexColor("#8A98E8")
                                          ],
                                          angle: 140 +
                                              (360 - 140) *
                                                  (1.0 - animation!.value)),
                                      child: SizedBox(
                                        width: 108,
                                        height: 108,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    // 分隔線
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 24, right: 24, top: 8, bottom: 8),
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          color: AppTheme.background,
                          borderRadius: BorderRadius.all(Radius.circular(4.0)),
                        ),
                      ),
                    ),
                    // 營養素進度條
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 24, right: 24, top: 8, bottom: 16),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: _buildNutrientProgress(
                              title: 'Carbs',
                              progress: 70 / 1.2 * animation!.value,
                              remaining: '12g left',
                              color: HexColor('#87A0E5'),
                            ),
                          ),
                          Expanded(
                            child: _buildNutrientProgress(
                              title: 'Protein',
                              progress: 70 / 2 * animationController!.value,
                              remaining: '30g left',
                              color: HexColor('#F56E98'),
                            ),
                          ),
                          Expanded(
                            child: _buildNutrientProgress(
                              title: 'Fat',
                              progress: 70 / 2.5 * animationController!.value,
                              remaining: '10g left',
                              color: HexColor('#F1B440'),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 建立卡路里項目
  Widget _buildCalorieItem({
    required String title,
    required int value,
    required String unit,
    required String icon,
    required Color color,
  }) {
    return Row(
      children: <Widget>[
        Container(
          height: 48,
          width: 2,
          decoration: BoxDecoration(
            color: color.withOpacity(0.5),
            borderRadius: BorderRadius.all(Radius.circular(4.0)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 2),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTheme.fontName,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    letterSpacing: -0.1,
                    color: AppTheme.grey.withOpacity(0.5),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: Image.asset(icon),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 3),
                    child: Text(
                      '$value',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTheme.fontName,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: AppTheme.darkerText,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 3),
                    child: Text(
                      unit,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTheme.fontName,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        letterSpacing: -0.2,
                        color: AppTheme.grey.withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        )
      ],
    );
  }

  /// 建立營養素進度條
  Widget _buildNutrientProgress({
    required String title,
    required double progress,
    required String remaining,
    required Color color,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTheme.fontName,
            fontWeight: FontWeight.w500,
            fontSize: 16,
            letterSpacing: -0.2,
            color: AppTheme.darkText,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Container(
            height: 4,
            width: 70,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.all(Radius.circular(4.0)),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: progress,
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      color.withOpacity(0.1),
                      color,
                    ]),
                    borderRadius: BorderRadius.all(Radius.circular(4.0)),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            remaining,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: AppTheme.grey.withOpacity(0.5),
            ),
          ),
        ),
      ],
    );
  }
}

/// 自訂圓形進度畫筆
/// 
/// 用於繪製圓形進度條的自訂畫筆
class CurvePainter extends CustomPainter {
  final double? angle;
  final List<Color>? colors;

  CurvePainter({this.colors, this.angle = 140});

  @override
  void paint(Canvas canvas, Size size) {
    List<Color> colorsList = [];
    if (colors != null) {
      colorsList = colors ?? [];
    } else {
      colorsList.addAll([Colors.white, Colors.white]);
    }

    final shdowPaint = Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;
    final shdowPaintCenter = Offset(size.width / 2, size.height / 2);
    final shdowPaintRadius =
        math.min(size.width / 2, size.height / 2) - (14 / 2);
    canvas.drawArc(
        Rect.fromCircle(center: shdowPaintCenter, radius: shdowPaintRadius),
        degreeToRadians(278),
        degreeToRadians(360 - (365 - angle!)),
        false,
        shdowPaint);

    shdowPaint.color = Colors.grey.withOpacity(0.3);
    shdowPaint.strokeWidth = 16;
    canvas.drawArc(
        Rect.fromCircle(center: shdowPaintCenter, radius: shdowPaintRadius),
        degreeToRadians(278),
        degreeToRadians(360 - (365 - angle!)),
        false,
        shdowPaint);

    shdowPaint.color = Colors.grey.withOpacity(0.2);
    shdowPaint.strokeWidth = 20;
    canvas.drawArc(
        Rect.fromCircle(center: shdowPaintCenter, radius: shdowPaintRadius),
        degreeToRadians(278),
        degreeToRadians(360 - (365 - angle!)),
        false,
        shdowPaint);

    shdowPaint.color = Colors.grey.withOpacity(0.1);
    shdowPaint.strokeWidth = 22;
    canvas.drawArc(
        Rect.fromCircle(center: shdowPaintCenter, radius: shdowPaintRadius),
        degreeToRadians(278),
        degreeToRadians(360 - (365 - angle!)),
        false,
        shdowPaint);

    final rect = Rect.fromLTWH(0.0, 0.0, size.width, size.width);
    final gradient = SweepGradient(
      startAngle: degreeToRadians(268),
      endAngle: degreeToRadians(270.0 + 360),
      tileMode: TileMode.repeated,
      colors: colorsList,
    );
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - (14 / 2);

    canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        degreeToRadians(278),
        degreeToRadians(360 - (365 - angle!)),
        false,
        paint);

    final gradient1 = SweepGradient(
      tileMode: TileMode.repeated,
      colors: [Colors.white, Colors.white],
    );

    var cPaint = Paint();
    cPaint..shader = gradient1.createShader(rect);
    cPaint..color = Colors.white;
    cPaint..strokeWidth = 14 / 2;
    canvas.save();

    final centerToCircle = size.width / 2;
    canvas.save();

    canvas.translate(centerToCircle, centerToCircle);
    canvas.rotate(degreeToRadians(angle! + 2));

    canvas.save();
    canvas.translate(0.0, -centerToCircle + 14 / 2);
    canvas.drawCircle(Offset(0, 0), 14 / 5, cPaint);

    canvas.restore();
    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  double degreeToRadians(double degree) {
    var redian = (math.pi / 180) * degree;
    return redian;
  }
}

/// 水波動畫視圖
/// 
/// 顯示帶有水波動畫效果的圓形進度指示器
class WaveView extends StatefulWidget {
  final double percentageValue;

  const WaveView({Key? key, this.percentageValue = 100.0}) : super(key: key);

  @override
  _WaveViewState createState() => _WaveViewState();
}

class _WaveViewState extends State<WaveView> with TickerProviderStateMixin {
  AnimationController? animationController;
  AnimationController? waveAnimationController;
  Offset bottleOffset1 = Offset(0, 0);
  List<Offset> animList1 = [];
  Offset bottleOffset2 = Offset(60, 0);
  List<Offset> animList2 = [];

  @override
  void initState() {
    animationController = AnimationController(
        duration: Duration(milliseconds: 2000), vsync: this);
    waveAnimationController = AnimationController(
        duration: Duration(milliseconds: 2000), vsync: this);
    animationController!
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          animationController?.reverse();
        } else if (status == AnimationStatus.dismissed) {
          animationController?.forward();
        }
      });
    waveAnimationController!.addListener(() {
      animList1.clear();
      for (int i = -2 - bottleOffset1.dx.toInt(); i <= 60 + 2; i++) {
        animList1.add(
          Offset(
            i.toDouble() + bottleOffset1.dx.toInt(),
            math.sin((waveAnimationController!.value * 360 - i) %
                        360 *
                        (math.pi / 180)) *
                    4 +
                (((100 - widget.percentageValue) * 160 / 100)),
          ),
        );
      }
      animList2.clear();
      for (int i = -2 - bottleOffset2.dx.toInt(); i <= 60 + 2; i++) {
        animList2.add(
          Offset(
            i.toDouble() + bottleOffset2.dx.toInt(),
            math.sin((waveAnimationController!.value * 360 - i) %
                        360 *
                        (math.pi / 180)) *
                    4 +
                (((100 - widget.percentageValue) * 160 / 100)),
          ),
        );
      }
    });
    waveAnimationController?.repeat();
    animationController?.forward();
    super.initState();
  }

  @override
  void dispose() {
    animationController?.dispose();
    waveAnimationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: AnimatedBuilder(
        animation: CurvedAnimation(
          parent: animationController!,
          curve: Curves.easeInOut,
        ),
        builder: (context, child) => Stack(
          children: <Widget>[
            ClipPath(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.nearlyDarkBlue.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(80.0),
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.nearlyDarkBlue.withOpacity(0.2),
                      AppTheme.nearlyDarkBlue.withOpacity(0.5)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              clipper: WaveClipper(animationController!.value, animList1),
            ),
            ClipPath(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.nearlyDarkBlue,
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.nearlyDarkBlue.withOpacity(0.4),
                      AppTheme.nearlyDarkBlue
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(80.0),
                ),
              ),
              clipper: WaveClipper(animationController!.value, animList2),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 48),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.percentageValue.round().toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTheme.fontName,
                        fontWeight: FontWeight.w500,
                        fontSize: 24,
                        letterSpacing: 0.0,
                        color: AppTheme.white,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 3.0),
                      child: Text(
                        '%',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppTheme.fontName,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          letterSpacing: 0.0,
                          color: AppTheme.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 裝飾氣泡
            _buildDecorationBubbles(),
            // 瓶子圖片
            Column(
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset("assets/fitness_app/bottle.png"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  /// 建立裝飾氣泡
  Widget _buildDecorationBubbles() {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 6,
          bottom: 8,
          child: ScaleTransition(
            alignment: Alignment.center,
            scale: Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
                parent: animationController!,
                curve: Interval(0.0, 1.0, curve: Curves.fastOutSlowIn))),
            child: Container(
              width: 2,
              height: 2,
              decoration: BoxDecoration(
                color: AppTheme.white.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        Positioned(
          left: 24,
          right: 0,
          bottom: 16,
          child: ScaleTransition(
            alignment: Alignment.center,
            scale: Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
                parent: animationController!,
                curve: Interval(0.4, 1.0, curve: Curves.fastOutSlowIn))),
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.white.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 24,
          bottom: 32,
          child: ScaleTransition(
            alignment: Alignment.center,
            scale: Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
                parent: animationController!,
                curve: Interval(0.6, 0.8, curve: Curves.fastOutSlowIn))),
            child: Container(
              width: 3,
              height: 3,
              decoration: BoxDecoration(
                color: AppTheme.white.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 20,
          bottom: 0,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 16 * (1.0 - animationController!.value), 0.0),
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.white.withOpacity(
                    animationController!.status == AnimationStatus.reverse
                        ? 0.0
                        : 0.4),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 水波剪裁器
/// 
/// 用於創建水波效果的自訂剪裁器
class WaveClipper extends CustomClipper<Path> {
  final double animation;
  List<Offset> waveList1 = [];

  WaveClipper(this.animation, this.waveList1);

  @override
  Path getClip(Size size) {
    Path path = Path();
    path.addPolygon(waveList1, false);
    path.lineTo(size.width, size.height);
    path.lineTo(0.0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(WaveClipper oldClipper) =>
      animation != oldClipper.animation;
}

/// 線性進度指示器
/// 
/// 自訂的線性進度條，支援漸層色彩
class LinearProgressIndicator extends StatelessWidget {
  final double progress;
  final List<Color> colors;
  final double height;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  const LinearProgressIndicator({
    Key? key,
    required this.progress,
    required this.colors,
    this.height = 4.0,
    this.backgroundColor,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey.withOpacity(0.2),
        borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
            borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
          ),
        ),
      ),
    );
  }
}

/// 圓形進度指示器
/// 
/// 自訂的圓形進度條，支援漸層色彩和動畫
class CustomCircularProgressIndicator  extends StatelessWidget {
  final double progress;
  final List<Color> colors;
  final double strokeWidth;
  final Color? backgroundColor;
  final Widget? child;

  const CustomCircularProgressIndicator({
    Key? key,
    required this.progress,
    required this.colors,
    this.strokeWidth = 8.0,
    this.backgroundColor,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CircularProgressPainter(
        progress: progress,
        colors: colors,
        strokeWidth: strokeWidth,
        backgroundColor: backgroundColor ?? Colors.grey.withOpacity(0.2),
      ),
      child: child,
    );
  }
}

/// 圓形進度畫筆
/// 
/// 用於繪製圓形進度條的自訂畫筆
class CircularProgressPainter extends CustomPainter {
  final double progress;
  final List<Color> colors;
  final double strokeWidth;
  final Color backgroundColor;

  CircularProgressPainter({
    required this.progress,
    required this.colors,
    required this.strokeWidth,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // 背景圓圈
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // 進度圓弧
    if (progress > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      final gradient = SweepGradient(colors: colors);
      
      final progressPaint = Paint()
        ..shader = gradient.createShader(rect)
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        rect,
        -math.pi / 2, // 從頂部開始
        2 * math.pi * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}