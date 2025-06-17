// lib/utils/app_utils.dart
// 工具函數集合
// 功能：提供應用程式中常用的工具函數和實用方法

import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 十六進位顏色轉換工具類別
/// 
/// 將十六進位字串轉換為 Flutter Color 物件
class HexColor extends Color {
  /// 從十六進位字串建立顏色
  /// 
  /// 支援格式：
  /// - "#RRGGBB" (如: "#FF0000")
  /// - "#AARRGGBB" (如: "#80FF0000")
  /// - "RRGGBB" (如: "FF0000")
  /// - "AARRGGBB" (如: "80FF0000")
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  /// 將十六進位字串轉換為顏色值
  static int _getColorFromHex(String hexColor) {
    // 移除 # 符號（如果存在）
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    
    // 如果只有 6 位數，自動加上 FF 作為 alpha 值
    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor;
    }
    
    // 轉換為整數並返回
    return int.parse(hexColor, radix: 16);
  }

  /// 建立帶有指定透明度的顏色
  /// 
  /// [opacity] 透明度值，範圍 0.0-1.0
  HexColor withOpacity(double opacity) {
    return HexColor('#${(opacity * 255).toInt().toRadixString(16).padLeft(2, '0')}${value.toRadixString(16).substring(2)}');
  }

  /// 將顏色轉換為十六進位字串
  String toHexString({bool includeAlpha = true}) {
    if (includeAlpha) {
      return '#${value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
    } else {
      return '#${value.toRadixString(16).substring(2).padLeft(6, '0').toUpperCase()}';
    }
  }
}

/// 應用程式工具函數類別
/// 
/// 包含各種常用的工具方法和實用函數
class AppUtils {
  AppUtils._(); // 私有建構函數，防止實例化

  // ==================== 日期時間工具方法 ====================
  
  /// 格式化日期顯示
  /// 
  /// [date] 要格式化的日期
  /// [format] 日期格式，預設為 'dd MMM'
  static String formatDate(DateTime date, {String format = 'dd MMM'}) {
    final now = DateTime.now();
    
    // 檢查是否為今天
    if (date.year == now.year && 
        date.month == now.month && 
        date.day == now.day) {
      return 'Today';
    }
    
    // 檢查是否為昨天
    final yesterday = now.subtract(Duration(days: 1));
    if (date.year == yesterday.year && 
        date.month == yesterday.month && 
        date.day == yesterday.day) {
      return 'Yesterday';
    }
    
    // 檢查是否為明天
    final tomorrow = now.add(Duration(days: 1));
    if (date.year == tomorrow.year && 
        date.month == tomorrow.month && 
        date.day == tomorrow.day) {
      return 'Tomorrow';
    }
    
    // 使用指定格式
    return DateFormat(format).format(date);
  }

  /// 格式化時間顯示
  /// 
  /// [time] 要格式化的時間
  /// [format] 時間格式，預設為 'HH:mm'
  static String formatTime(DateTime time, {String format = 'HH:mm'}) {
    return DateFormat(format).format(time);
  }

  /// 計算兩個日期之間的天數差異
  /// 
  /// [startDate] 開始日期
  /// [endDate] 結束日期
  static int daysBetween(DateTime startDate, DateTime endDate) {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    return end.difference(start).inDays;
  }

  /// 取得本週的開始日期（週一）
  static DateTime getWeekStart(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }

  /// 取得本週的結束日期（週日）
  static DateTime getWeekEnd(DateTime date) {
    final weekday = date.weekday;
    return date.add(Duration(days: 7 - weekday));
  }

  /// 取得本月的開始日期
  static DateTime getMonthStart(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// 取得本月的結束日期
  static DateTime getMonthEnd(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  // ==================== 數字格式化工具方法 ====================
  
  /// 格式化數字顯示（加入千分位逗號）
  /// 
  /// [number] 要格式化的數字
  /// [decimalPlaces] 小數位數，預設為0
  static String formatNumber(num number, {int decimalPlaces = 0}) {
    final formatter = NumberFormat('#,##0.${'0' * decimalPlaces}');
    return formatter.format(number);
  }

  /// 格式化百分比顯示
  /// 
  /// [value] 百分比值（0.0 - 1.0）
  /// [decimalPlaces] 小數位數，預設為1
  static String formatPercentage(double value, {int decimalPlaces = 1}) {
    final percentage = value * 100;
    return '${percentage.toStringAsFixed(decimalPlaces)}%';
  }

  /// 格式化卡路里顯示
  /// 
  /// [calories] 卡路里數值
  static String formatCalories(int calories) {
    if (calories >= 1000) {
      return '${(calories / 1000).toStringAsFixed(1)}k';
    }
    return calories.toString();
  }

  /// 格式化體重顯示
  /// 
  /// [weight] 體重值
  /// [unit] 單位（'kg' 或 'lbs'）
  static String formatWeight(double weight, {String unit = 'kg'}) {
    return '${weight.toStringAsFixed(1)} $unit';
  }

  /// 格式化距離顯示
  /// 
  /// [distance] 距離值（公尺）
  static String formatDistance(double distance) {
    if (distance >= 1000) {
      return '${(distance / 1000).toStringAsFixed(1)} km';
    }
    return '${distance.toStringAsFixed(0)} m';
  }

  // ==================== 時間長度工具方法 ====================
  
  /// 格式化運動時間顯示
  /// 
  /// [seconds] 總秒數
  static String formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
             '${minutes.toString().padLeft(2, '0')}:'
             '${remainingSeconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:'
             '${remainingSeconds.toString().padLeft(2, '0')}';
    }
  }

  /// 格式化運動時間顯示（分鐘）
  /// 
  /// [minutes] 總分鐘數
  static String formatMinutes(int minutes) {
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '${hours}h';
      } else {
        return '${hours}h ${remainingMinutes}m';
      }
    }
    return '${minutes}m';
  }

  // ==================== 健康計算工具方法 ====================
  
  /// 計算 BMI
  /// 
  /// [weight] 體重（公斤）
  /// [height] 身高（公分）
  static double calculateBMI(double weight, double height) {
    if (height <= 0) return 0.0;
    final heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  /// 取得 BMI 狀態描述
  /// 
  /// [bmi] BMI 值
  static String getBMIStatus(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  /// 計算基礎代謝率（BMR）
  /// 
  /// [weight] 體重（公斤）
  /// [height] 身高（公分）
  /// [age] 年齡
  /// [isMale] 是否為男性
  static double calculateBMR(double weight, double height, int age, bool isMale) {
    if (isMale) {
      return 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
    } else {
      return 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
    }
  }

  /// 計算每日消耗卡路里（TDEE）
  /// 
  /// [bmr] 基礎代謝率
  /// [activityLevel] 活動水準（1.2-1.9）
  static double calculateTDEE(double bmr, double activityLevel) {
    return bmr * activityLevel;
  }

  /// 磅轉公斤
  /// 
  /// [pounds] 磅數
  static double poundsToKilograms(double pounds) {
    return pounds * 0.453592;
  }

  /// 公斤轉磅
  /// 
  /// [kilograms] 公斤數
  static double kilogramsToPounds(double kilograms) {
    return kilograms / 0.453592;
  }

  // ==================== 顏色工具方法 ====================
  
  /// 根據進度值取得顏色
  /// 
  /// [progress] 進度值（0.0 - 1.0）
  /// [startColor] 開始顏色
  /// [endColor] 結束顏色
  static Color getProgressColor(double progress, Color startColor, Color endColor) {
    return Color.lerp(startColor, endColor, progress.clamp(0.0, 1.0))!;
  }

  /// 取得對比色（黑或白）
  /// 
  /// [color] 背景顏色
  static Color getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// 調整顏色亮度
  /// 
  /// [color] 原始顏色
  /// [factor] 亮度調整係數（-1.0 到 1.0）
  static Color adjustBrightness(Color color, double factor) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + factor).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  // ==================== 數學工具方法 ====================
  
  /// 角度轉弧度
  /// 
  /// [degrees] 角度值
  static double degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  /// 弧度轉角度
  /// 
  /// [radians] 弧度值
  static double radiansToDegrees(double radians) {
    return radians * (180 / math.pi);
  }

  /// 限制數值範圍
  /// 
  /// [value] 數值
  /// [min] 最小值
  /// [max] 最大值
  static T clamp<T extends num>(T value, T min, T max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  /// 線性插值
  /// 
  /// [start] 開始值
  /// [end] 結束值
  /// [t] 插值係數（0.0 - 1.0）
  static double lerp(double start, double end, double t) {
    return start + (end - start) * t;
  }

  // ==================== 字串工具方法 ====================
  
  /// 首字母大寫
  /// 
  /// [text] 要處理的文字
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// 截斷文字並加上省略號
  /// 
  /// [text] 要截斷的文字
  /// [maxLength] 最大長度
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - 3)}...';
  }

  /// 移除所有空格
  /// 
  /// [text] 要處理的文字
  static String removeSpaces(String text) {
    return text.replaceAll(' ', '');
  }

  /// 檢查是否為有效的電子郵件格式
  /// 
  /// [email] 電子郵件地址
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return emailRegex.hasMatch(email);
  }

  // ==================== 設備資訊工具方法 ====================
  
  /// 取得螢幕寬度
  /// 
  /// [context] BuildContext
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// 取得螢幕高度
  /// 
  /// [context] BuildContext
  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// 取得狀態列高度
  /// 
  /// [context] BuildContext
  static double getStatusBarHeight(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  /// 取得底部安全區域高度
  /// 
  /// [context] BuildContext
  static double getBottomPadding(BuildContext context) {
    return MediaQuery.of(context).padding.bottom;
  }

  /// 檢查是否為平板裝置
  /// 
  /// [context] BuildContext
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 768;
  }

  // ==================== 動畫工具方法 ====================
  
  /// 建立彈跳動畫曲線
  static Curve get bounceCurve => Curves.elasticOut;
  
  /// 建立快速進入慢速退出曲線
  static Curve get fastOutSlowInCurve => Curves.fastOutSlowIn;
  
  /// 建立緩動曲線
  static Curve get easeCurve => Curves.ease;

  // ==================== 偵錯工具方法 ====================
  
  /// 列印偵錯資訊
  /// 
  /// [message] 偵錯訊息
  /// [tag] 標籤
  static void debugPrint(String message, {String tag = 'APP'}) {
    print('[$tag] $message');
  }

  /// 列印錯誤資訊
  /// 
  /// [error] 錯誤物件
  /// [stackTrace] 堆疊追蹤
  /// [tag] 標籤
  static void debugPrintError(dynamic error, StackTrace? stackTrace, {String tag = 'ERROR'}) {
    print('[$tag] Error: $error');
    if (stackTrace != null) {
      print('StackTrace: $stackTrace');
    }
  }
}