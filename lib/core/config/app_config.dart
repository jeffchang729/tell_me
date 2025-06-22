// core/config/app_config.dart
// 應用程式配置檔案 - 新增天氣API設定
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
  static const String appName = 'TELL ME';
  
  /// 應用程式版本
  static const String appVersion = '1.0.0';
  
  /// 建置版本號
  static const int buildNumber = 1;

  // ==================== API 設定 ====================
  
  /// 台灣氣象署API基礎URL
  static const String cwaApiBaseUrl = 'https://opendata.cwa.gov.tw/api';
  
  /// 台灣氣象署API版本
  static const String cwaApiVersion = 'v1';
  
  /// 台灣氣象署API金鑰
  static const String cwaApiKey = 'CWA-735C81D7-6FD6-403D-AC00-C960BFCDF72F';
  
  /// API請求超時時間
  static const Duration apiTimeout = Duration(seconds: 30);
  
  /// API重試次數
  static const int apiRetryCount = 3;
  
  /// 快取過期時間（天氣資料）
  static const Duration weatherCacheExpiry = Duration(minutes: 30);

  // ==================== 天氣API端點 ====================
  
  /// 取得目前天氣觀測資料的API端點
  static String get currentWeatherEndpoint => 
      '$cwaApiBaseUrl/$cwaApiVersion/rest/datastore/O-A0003-001';
  
  /// 取得36小時天氣預報的API端點  
  static String get forecastEndpoint => 
      '$cwaApiBaseUrl/$cwaApiVersion/rest/datastore/F-C0032-001';
  
  /// 取得一週天氣預報的API端點
  static String get weeklyForecastEndpoint => 
      '$cwaApiBaseUrl/$cwaApiVersion/rest/datastore/F-C0007-001';

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
  
  /// 天氣卡片資料鍵值
  static const String weatherCardsKey = 'weather_cards';
  
  /// 天氣快取資料鍵值
  static const String weatherCacheKey = 'weather_cache';

  // ==================== 天氣設定 ====================
  
  /// 預設天氣卡片顏色清單
  static const List<String> weatherCardColors = [
    '#4A90E2', // 藍色
    '#50C878', // 綠色  
    '#FFB347', // 橙色
    '#DDA0DD', // 紫色
    '#87CEEB', // 天藍色
    '#F0E68C', // 卡其色
  ];
  
  /// 台灣主要城市列表（快速搜尋用）
  static const List<Map<String, String>> taiwanCities = [
    {'name': '台北市', 'code': '63'},
    {'name': '新北市', 'code': '65'}, 
    {'name': '桃園市', 'code': '68'},
    {'name': '台中市', 'code': '66'},
    {'name': '台南市', 'code': '67'},
    {'name': '高雄市', 'code': '64'},
    {'name': '基隆市', 'code': '10017'},
    {'name': '新竹市', 'code': '10018'},
    {'name': '嘉義市', 'code': '10020'},
    {'name': '新竹縣', 'code': '10004'},
    {'name': '苗栗縣', 'code': '10005'},
    {'name': '彰化縣', 'code': '10007'},
    {'name': '南投縣', 'code': '10008'},
    {'name': '雲林縣', 'code': '10009'},
    {'name': '嘉義縣', 'code': '10010'},
    {'name': '屏東縣', 'code': '10013'},
    {'name': '宜蘭縣', 'code': '10002'},
    {'name': '花蓮縣', 'code': '10015'},
    {'name': '台東縣', 'code': '10014'},
    {'name': '澎湖縣', 'code': '10016'},
    {'name': '金門縣', 'code': '09020'},
    {'name': '連江縣', 'code': '09007'},
  ];

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
  
  /// 根據索引取得天氣卡片顏色
  static String getWeatherCardColor(int index) {
    return weatherCardColors[index % weatherCardColors.length];
  }
  
  /// 根據城市名稱取得城市代碼
  static String? getCityCode(String cityName) {
    final city = taiwanCities.firstWhere(
      (city) => city['name'] == cityName,
      orElse: () => <String, String>{},
    );
    return city['code'];
  }
  
  /// 建立完整的API URL
  static String buildApiUrl(String endpoint, Map<String, String> parameters) {
    final uri = Uri.parse(endpoint);
    final newParams = Map<String, String>.from(uri.queryParameters);
    newParams.addAll(parameters);
    newParams['Authorization'] = cwaApiKey;
    
    return uri.replace(queryParameters: newParams).toString();
  }
}