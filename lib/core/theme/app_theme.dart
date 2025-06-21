// lib/config/app_theme.dart
// 應用程式主題配置檔案
// 功能：統一管理應用程式的視覺主題和樣式

import 'package:flutter/material.dart';

/// 統一的應用程式主題配置類別
/// 
/// 整合並管理應用程式的所有視覺元素，包括：
/// - 顏色定義
/// - 文字樣式
/// - 主題配置
/// - 裝飾樣式等
class AppTheme {
  AppTheme._(); // 私有建構函數，防止實例化

  // ==================== 顏色定義 ====================
  
  /// 背景色系
  static const Color background = Color(0xFFF2F3F8);
  static const Color nearlyWhite = Color(0xFFFAFAFA);
  static const Color notWhite = Color(0xFFEDF0F2);
  static const Color white = Color(0xFFFFFFFF);
  
  /// 主色系
  static const Color nearlyDarkBlue = Color(0xFF2633C5);
  static const Color nearlyBlue = Color(0xFF00B6F0);
  
  /// 中性色系
  static const Color nearlyBlack = Color(0xFF213333);
  static const Color grey = Color(0xFF3A5160);
  static const Color dark_grey = Color(0xFF313A44);
  
  /// 文字色系
  static const Color darkText = Color(0xFF253840);
  static const Color darkerText = Color(0xFF17262A);
  static const Color lightText = Color(0xFF4A6572);
  static const Color deactivatedText = Color(0xFF767676);
  
  /// 功能色系
  static const Color dismissibleBackground = Color(0xFF364A54);
  static const Color chipBackground = Color(0xFFEEF1F3);
  static const Color spacer = Color(0xFFF2F2F2);

  // ==================== 字型定義 ====================
  static const String fontName = 'Roboto';

  // ==================== 主題配置 ====================
  
  /// 明亮主題配置
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.blue,
      primaryColor: nearlyDarkBlue,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      fontFamily: fontName,
    );
  }

  // ==================== 文字樣式定義 ====================
  static const TextTheme textTheme = TextTheme(
    headlineMedium: display1,
    headlineSmall: headline,
    titleLarge: title,
    titleSmall: subtitle,
    bodyMedium: body2,
    bodyLarge: body1,
    bodySmall: caption,
  );

  static const TextStyle display1 = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 36,
    letterSpacing: 0.4,
    height: 0.9,
    color: darkerText,
  );

  static const TextStyle headline = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 24,
    letterSpacing: 0.27,
    color: darkerText,
  );

  static const TextStyle title = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 16,
    letterSpacing: 0.18,
    color: darkerText,
  );

  static const TextStyle subtitle = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: -0.04,
    color: darkText,
  );

  static const TextStyle body2 = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: 0.2,
    color: darkText,
  );

  static const TextStyle body1 = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    letterSpacing: -0.05,
    color: darkText,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    letterSpacing: 0.2,
    color: lightText,
  );

  // ==================== 實用裝飾方法 ====================
  
  /// 建立標準卡片裝飾
  /// 
  /// [color] 卡片背景色，預設為白色
  /// [radius] 圓角半徑，預設為 8.0
  /// [withShadow] 是否包含陰影，預設為 true
  static BoxDecoration cardDecoration({
    Color? color,
    double radius = 8.0,
    bool withShadow = true,
  }) {
    return BoxDecoration(
      color: color ?? white,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: withShadow ? [
        BoxShadow(
          color: grey.withOpacity(0.2),
          offset: const Offset(1.1, 1.1),
          blurRadius: 10.0,
        ),
      ] : null,
    );
  }

  /// 建立特殊卡片裝飾（健康APP樣式）
  /// 
  /// 右上角有特殊圓角的卡片設計
  static BoxDecoration specialCardDecoration({
    Color? color,
    double radius = 8.0,
  }) {
    return BoxDecoration(
      color: color ?? white,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(radius),
        bottomLeft: Radius.circular(radius),
        bottomRight: Radius.circular(radius),
        topRight: Radius.circular(radius * 8.5), // 特殊的右上角圓角 (68.0)
      ),
      boxShadow: [
        BoxShadow(
          color: grey.withOpacity(0.2),
          offset: const Offset(1.1, 1.1),
          blurRadius: 10.0,
        ),
      ],
    );
  }

  /// 建立漸層裝飾
  /// 
  /// [colors] 漸層顏色清單
  /// [begin] 漸層開始位置
  /// [end] 漸層結束位置
  /// [radius] 圓角半徑
  static BoxDecoration gradientDecoration({
    required List<Color> colors,
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
    double radius = 8.0,
    bool withShadow = true,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: colors,
        begin: begin,
        end: end,
      ),
      borderRadius: BorderRadius.circular(radius),
      boxShadow: withShadow ? [
        BoxShadow(
          color: colors.first.withOpacity(0.4),
          offset: const Offset(1.1, 4.0),
          blurRadius: 8.0,
        ),
      ] : null,
    );
  }

  /// 取得標準陰影清單
  static List<BoxShadow> get standardShadow => [
    BoxShadow(
      color: grey.withOpacity(0.2),
      offset: const Offset(1.1, 1.1),
      blurRadius: 10.0,
    ),
  ];

  /// 取得大陰影清單
  static List<BoxShadow> get largeShadow => [
    BoxShadow(
      color: nearlyDarkBlue.withOpacity(0.4),
      offset: const Offset(8.0, 16.0),
      blurRadius: 16.0,
    ),
  ];
}
