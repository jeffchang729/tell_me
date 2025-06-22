// shared/services/storage_service.dart
// 本地儲存服務 - 修正版
// 功能：管理應用程式的本地資料儲存和讀取，並調整初始化方法以便依賴注入。

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tell_me/core/config/app_config.dart';
import 'package:tell_me/shared/models/health_models.dart';
import 'package:tell_me/shared/models/measurement_models.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  // 這些變數不應為私有，以便依賴注入時可以存取
  @visibleForTesting
  SharedPreferences? prefs;
  
  @visibleForTesting
  bool isInitialized = false;

  /// [修正] 初始化儲存服務，並回傳 Future<StorageService> 以符合 Get.putAsync 的要求
  Future<StorageService> init() async {
    if (isInitialized) return this;
    
    try {
      prefs = await SharedPreferences.getInstance();
      isInitialized = true;
      print('本地儲存服務已初始化');
    } catch (e) {
      print('初始化儲存服務失敗: $e');
      rethrow;
    }
    // 回傳自身實例
    return this; 
  }

  /// 確保服務已初始化
  void _ensureInitialized() {
    if (!isInitialized || prefs == null) {
      throw Exception('StorageService 尚未初始化，請先呼叫 init() 方法');
    }
  }

  // --- 其他所有讀寫方法保持不變 ---

  /// 儲存字串資料
  Future<bool> setString(String key, String value) async {
    _ensureInitialized();
    return await prefs!.setString(key, value);
  }

  /// 讀取字串資料
  String? getString(String key, {String? defaultValue}) {
    _ensureInitialized();
    return prefs!.getString(key) ?? defaultValue;
  }
  
  /// 儲存布林值資料
  Future<bool> setBool(String key, bool value) async {
    _ensureInitialized();
    return await prefs!.setBool(key, value);
  }

  /// 讀取布林值資料
  bool getBool(String key, {bool defaultValue = false}) {
    _ensureInitialized();
    return prefs!.getBool(key) ?? defaultValue;
  }

  // ... 您可以繼續加入 getInt, setInt, getJson 等其他方法 ...
}
