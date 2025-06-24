// core/config/app_config.dart
// 應用程式設定檔 - [最終修正]
// 功能：修正 API 金鑰的存取權限問題。

import 'dart:ui';
import 'package:flutter/material.dart';

class AppConfig {
  // --- API 設定 ---

  /// [修正] 中央氣象署 (CWA) 開放資料平台授權碼
  /// 移除變數名前的底線，使其成為公開 (public) 變數。
  static const String cwaApiKey = 'CWA-735C81D7-6FD6-403D-AC00-C960BFCDF72F';

  /// CWA API 端點 - 一般天氣預報 (未來1週)
  static const String forecastEndpoint =
      'https://opendata.cwa.gov.tw/api/v1/rest/datastore/F-C0032-001';
      
  /// CWA API 端點 - 局屬氣象站觀測資料 (更詳細的目前天氣)
  static const String currentDetailedEndpoint =
      'https://opendata.cwa.gov.tw/api/v1/rest/datastore/O-A0003-001';

  /// API 請求超時設定
  static const Duration apiTimeout = Duration(seconds: 10);

  // --- 快取設定 ---
  static const Duration weatherCacheExpiry = Duration(minutes: 15);

  // --- 台灣城市列表 ---
  static const List<Map<String, String>> taiwanCities = [
    {'name': '基隆市', 'code': 'KEE'},
    {'name': '臺北市', 'code': 'TPE'},
    {'name': '新北市', 'code': 'NWT'},
    {'name': '桃園市', 'code': 'TAO'},
    {'name': '新竹市', 'code': 'HSZ'},
    {'name': '新竹縣', 'code': 'HSQ'},
    {'name': '苗栗縣', 'code': 'MIA'},
    {'name': '臺中市', 'code': 'TXG'},
    {'name': '彰化縣', 'code': 'CHA'},
    {'name': '南投縣', 'code': 'NAN'},
    {'name': '雲林縣', 'code': 'YUN'},
    {'name': '嘉義市', 'code': 'CYI'},
    {'name': '嘉義縣', 'code': 'CYQ'},
    {'name': '臺南市', 'code': 'TNN'},
    {'name': '高雄市', 'code': 'KHH'},
    {'name': '屏東縣', 'code': 'PIF'},
    {'name': '宜蘭縣', 'code': 'ILA'},
    {'name': '花蓮縣', 'code': 'HUA'},
    {'name': '臺東縣', 'code': 'TTT'},
    {'name': '澎湖縣', 'code': 'PEN'},
    {'name': '金門縣', 'code': 'KIN'},
    {'name': '連江縣', 'code': 'LIE'},
  ];

  static Color getWeatherCardColor(int id) {
    final List<Color> colors = [
      const Color(0xFF5C9DFF), const Color(0xFF6A88E5),
      const Color(0xFF42E695), const Color(0xFF36A45C),
      const Color(0xFFFFB25E), const Color(0xFFF9812B),
    ];
    return colors[id % colors.length];
  }
}
