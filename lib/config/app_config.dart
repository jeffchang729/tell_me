// lib/config/app_config.dart
// 應用程式配置檔案
// 功能：統一管理應用程式的全域設定參數

import 'package:flutter/material.dart';

/// 應用程式全域配置類別
/// 
/// 集中管理應用程式的各種配置參數，包括：
/// - 應用程式基本資訊
/// - 動畫時間設定
/// - API 設定
/// - 快取設定等
class AppConfig {
  AppConfig._(); // 私有建構函數，防止實例化

  // ==================== 應用程式基本資訊 ====================
  
  /// 應用程式名稱
  static const String appName = '健康追蹤';
  
  /// 應用程式版本
  static const String appVersion = '1.0.0';
  
  /// 建置版本號
  static const int buildNumber = 1;

  // ==================== 動畫設定 ====================
  
  /// 預設動畫持續時間
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  
  /// 快速動畫持續時間
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);
  
  /// 慢速動畫持續時間
  static const Duration slowAnimationDuration = Duration(milliseconds: 600);
  
  /// 頁面轉場動畫持續時間
  static const Duration pageTransitionDuration = Duration(milliseconds: 400);

  // ==================== UI 設定 ====================
  
  /// 預設頁面內邊距
  static const EdgeInsets defaultPadding = EdgeInsets.all(16.0);
  
  /// 小邊距
  static const EdgeInsets smallPadding = EdgeInsets.all(8.0);
  
  /// 大邊距
  static const EdgeInsets largePadding = EdgeInsets.all(24.0);
  
  /// 預設圓角半徑
  static const double defaultBorderRadius = 8.0;
  
  /// 大圓角半徑
  static const double largeBorderRadius = 16.0;
  
  /// 卡片陰影模糊半徑
  static const double defaultShadowBlur = 10.0;

  // ==================== 資料設定 ====================
  
  /// 預設每日飲水目標（毫升）
  static const int defaultWaterGoal = 3500;
  
  /// 預設每日卡路里目標
  static const int defaultCalorieGoal = 2500;
  
  /// 資料自動儲存間隔
  static const Duration autoSaveInterval = Duration(minutes: 5);

  // ==================== 本地儲存鍵值 ====================
  
  /// 使用者偏好設定鍵值
  static const String userPreferencesKey = 'user_preferences';
  
  /// 健康資料鍵值
  static const String healthDataKey = 'health_data';
  
  /// 飲食記錄鍵值
  static const String mealDataKey = 'meal_data';
  
  /// 運動記錄鍵值
  static const String workoutDataKey = 'workout_data';

  // ==================== 實用方法 ====================
  
  /// 檢查是否為除錯模式
  static bool get isDebugMode {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }
  
  /// 取得格式化的應用程式版本資訊
  static String get formattedVersion => '$appVersion ($buildNumber)';
  
  /// 取得預設的載入延遲時間（模擬網路請求）
  static Duration get mockLoadingDelay => 
      isDebugMode ? const Duration(milliseconds: 500) : Duration.zero;
}