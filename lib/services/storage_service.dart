// lib/services/storage_service.dart
// 本地儲存服務
// 功能：管理應用程式的本地資料儲存和讀取

import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/health_models.dart';
import '../models/measurement_models.dart';

/// 本地儲存服務類別
/// 
/// 負責管理所有本地資料的儲存和讀取，包括：
/// - 使用者偏好設定
/// - 健康資料持久化
/// - 應用程式狀態儲存
/// - 快取管理等
class StorageService {
  // 單例模式
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;
  bool _isInitialized = false;

  // ==================== 初始化方法 ====================
  
  /// 初始化儲存服務
  Future<void> init() async {
    if (_isInitialized) return;
    
    try {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
      print('本地儲存服務已初始化');
    } catch (e) {
      print('初始化儲存服務失敗: $e');
      rethrow;
    }
  }

  /// 確保服務已初始化
  void _ensureInitialized() {
    if (!_isInitialized || _prefs == null) {
      throw Exception('StorageService 尚未初始化，請先呼叫 init() 方法');
    }
  }

  // ==================== 基本讀寫方法 ====================
  
  /// 儲存字串資料
  Future<bool> setString(String key, String value) async {
    _ensureInitialized();
    try {
      return await _prefs!.setString(key, value);
    } catch (e) {
      print('儲存字串失敗 [$key]: $e');
      return false;
    }
  }

  /// 讀取字串資料
  String? getString(String key, {String? defaultValue}) {
    _ensureInitialized();
    try {
      return _prefs!.getString(key) ?? defaultValue;
    } catch (e) {
      print('讀取字串失敗 [$key]: $e');
      return defaultValue;
    }
  }

  /// 儲存整數資料
  Future<bool> setInt(String key, int value) async {
    _ensureInitialized();
    try {
      return await _prefs!.setInt(key, value);
    } catch (e) {
      print('儲存整數失敗 [$key]: $e');
      return false;
    }
  }

  /// 讀取整數資料
  int getInt(String key, {int defaultValue = 0}) {
    _ensureInitialized();
    try {
      return _prefs!.getInt(key) ?? defaultValue;
    } catch (e) {
      print('讀取整數失敗 [$key]: $e');
      return defaultValue;
    }
  }

  /// 儲存布林值資料
  Future<bool> setBool(String key, bool value) async {
    _ensureInitialized();
    try {
      return await _prefs!.setBool(key, value);
    } catch (e) {
      print('儲存布林值失敗 [$key]: $e');
      return false;
    }
  }

  /// 讀取布林值資料
  bool getBool(String key, {bool defaultValue = false}) {
    _ensureInitialized();
    try {
      return _prefs!.getBool(key) ?? defaultValue;
    } catch (e) {
      print('讀取布林值失敗 [$key]: $e');
      return defaultValue;
    }
  }

  /// 儲存雙精度浮點數資料
  Future<bool> setDouble(String key, double value) async {
    _ensureInitialized();
    try {
      return await _prefs!.setDouble(key, value);
    } catch (e) {
      print('儲存浮點數失敗 [$key]: $e');
      return false;
    }
  }

  /// 讀取雙精度浮點數資料
  double getDouble(String key, {double defaultValue = 0.0}) {
    _ensureInitialized();
    try {
      return _prefs!.getDouble(key) ?? defaultValue;
    } catch (e) {
      print('讀取浮點數失敗 [$key]: $e');
      return defaultValue;
    }
  }

  // ==================== JSON 物件儲存方法 ====================
  
  /// 儲存 JSON 物件
  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    try {
      final jsonString = jsonEncode(value);
      return await setString(key, jsonString);
    } catch (e) {
      print('儲存 JSON 失敗 [$key]: $e');
      return false;
    }
  }

  /// 讀取 JSON 物件
  Map<String, dynamic>? getJson(String key) {
    try {
      final jsonString = getString(key);
      if (jsonString == null) return null;
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      print('讀取 JSON 失敗 [$key]: $e');
      return null;
    }
  }

  /// 儲存 JSON 陣列
  Future<bool> setJsonList(String key, List<Map<String, dynamic>> value) async {
    try {
      final jsonString = jsonEncode(value);
      return await setString(key, jsonString);
    } catch (e) {
      print('儲存 JSON 陣列失敗 [$key]: $e');
      return false;
    }
  }

  /// 讀取 JSON 陣列
  List<Map<String, dynamic>>? getJsonList(String key) {
    try {
      final jsonString = getString(key);
      if (jsonString == null) return null;
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      print('讀取 JSON 陣列失敗 [$key]: $e');
      return null;
    }
  }

  // ==================== 健康資料專用方法 ====================
  
  /// 儲存身體測量資料
  Future<bool> saveBodyMeasurement(BodyMeasurement measurement) async {
    final data = {
      'weight': measurement.weight,
      'height': measurement.height,
      'bodyFatPercentage': measurement.bodyFatPercentage,
      'measurementTime': measurement.measurementTime?.millisecondsSinceEpoch,
      'deviceName': measurement.deviceName,
    };
    return await setJson('${AppConfig.healthDataKey}_body_measurement', data);
  }

  /// 讀取身體測量資料
  BodyMeasurement? loadBodyMeasurement() {
    final data = getJson('${AppConfig.healthDataKey}_body_measurement');
    if (data == null) return null;

    return BodyMeasurement(
      weight: data['weight']?.toDouble() ?? 0.0,
      height: data['height']?.toDouble() ?? 0.0,
      bodyFatPercentage: data['bodyFatPercentage']?.toDouble() ?? 0.0,
      measurementTime: data['measurementTime'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(data['measurementTime'])
          : null,
      deviceName: data['deviceName'] ?? '',
    );
  }

  /// 儲存飲水記錄
  Future<bool> saveWaterIntake(WaterIntake waterIntake) async {
    final data = {
      'currentIntake': waterIntake.currentIntake,
      'dailyGoal': waterIntake.dailyGoal,
      'lastDrinkTime': waterIntake.lastDrinkTime?.millisecondsSinceEpoch,
    };
    return await setJson('${AppConfig.healthDataKey}_water_intake', data);
  }

  /// 讀取飲水記錄
  WaterIntake? loadWaterIntake() {
    final data = getJson('${AppConfig.healthDataKey}_water_intake');
    if (data == null) return null;

    return WaterIntake(
      currentIntake: data['currentIntake'] ?? 0,
      dailyGoal: data['dailyGoal'] ?? AppConfig.defaultWaterGoal,
      lastDrinkTime: data['lastDrinkTime'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(data['lastDrinkTime'])
          : null,
    );
  }

  /// 儲存營養攝取資料
  Future<bool> saveNutritionIntake(NutritionIntake nutrition) async {
    final data = {
      'carbs': nutrition.carbs,
      'protein': nutrition.protein,
      'fat': nutrition.fat,
      'calories': nutrition.calories,
      'caloriesBurned': nutrition.caloriesBurned,
    };
    return await setJson('${AppConfig.healthDataKey}_nutrition', data);
  }

  /// 讀取營養攝取資料
  NutritionIntake? loadNutritionIntake() {
    final data = getJson('${AppConfig.healthDataKey}_nutrition');
    if (data == null) return null;

    return NutritionIntake(
      carbs: data['carbs'] ?? 0,
      protein: data['protein'] ?? 0,
      fat: data['fat'] ?? 0,
      calories: data['calories'] ?? 0,
      caloriesBurned: data['caloriesBurned'] ?? 0,
    );
  }

  // ==================== 使用者偏好設定方法 ====================
  
  /// 儲存使用者偏好設定
  Future<bool> saveUserPreferences(Map<String, dynamic> preferences) async {
    return await setJson(AppConfig.userPreferencesKey, preferences);
  }

  /// 讀取使用者偏好設定
  Map<String, dynamic> loadUserPreferences() {
    return getJson(AppConfig.userPreferencesKey) ?? <String, dynamic>{};
  }

  /// 儲存主題偏好
  Future<bool> saveThemeMode(String themeMode) async {
    return await setString('theme_mode', themeMode);
  }

  /// 讀取主題偏好
  String getThemeMode() {
    return getString('theme_mode', defaultValue: 'light') ?? 'light';
  }

  /// 儲存語言偏好
  Future<bool> saveLanguage(String languageCode) async {
    return await setString('language_code', languageCode);
  }

  /// 讀取語言偏好
  String getLanguage() {
    return getString('language_code', defaultValue: 'zh') ?? 'zh';
  }

  // ==================== 應用程式狀態方法 ====================
  
  /// 儲存上次使用的分頁索引
  Future<bool> saveLastTabIndex(int tabIndex) async {
    return await setInt('last_tab_index', tabIndex);
  }

  /// 讀取上次使用的分頁索引
  int getLastTabIndex() {
    return getInt('last_tab_index', defaultValue: 0);
  }

  /// 儲存應用程式首次啟動標記
  Future<bool> setFirstLaunch(bool isFirstLaunch) async {
    return await setBool('is_first_launch', isFirstLaunch);
  }

  /// 檢查是否為首次啟動
  bool isFirstLaunch() {
    return getBool('is_first_launch', defaultValue: true);
  }

  /// 儲存最後同步時間
  Future<bool> saveLastSyncTime(DateTime time) async {
    return await setInt('last_sync_time', time.millisecondsSinceEpoch);
  }

  /// 讀取最後同步時間
  DateTime? getLastSyncTime() {
    final timestamp = getInt('last_sync_time');
    return timestamp > 0 ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
  }

  // ==================== 快取管理方法 ====================
  
  /// 清除特定鍵值的資料
  Future<bool> remove(String key) async {
    _ensureInitialized();
    try {
      return await _prefs!.remove(key);
    } catch (e) {
      print('移除資料失敗 [$key]: $e');
      return false;
    }
  }

  /// 清除所有快取資料
  Future<bool> clearAll() async {
    _ensureInitialized();
    try {
      return await _prefs!.clear();
    } catch (e) {
      print('清除所有資料失敗: $e');
      return false;
    }
  }

  /// 清除健康相關資料
  Future<bool> clearHealthData() async {
    final keys = [
      '${AppConfig.healthDataKey}_body_measurement',
      '${AppConfig.healthDataKey}_water_intake',
      '${AppConfig.healthDataKey}_nutrition',
      AppConfig.mealDataKey,
      AppConfig.workoutDataKey,
    ];

    bool success = true;
    for (String key in keys) {
      final result = await remove(key);
      if (!result) success = false;
    }
    
    return success;
  }

  /// 取得所有儲存的鍵值清單
  Set<String> getAllKeys() {
    _ensureInitialized();
    return _prefs!.getKeys();
  }

  /// 檢查某個鍵值是否存在
  bool containsKey(String key) {
    _ensureInitialized();
    return _prefs!.containsKey(key);
  }

  // ==================== 資料匯出/匯入方法 ====================
  
  /// 匯出所有健康資料為 JSON
  Map<String, dynamic> exportHealthData() {
    final healthData = <String, dynamic>{};
    
    // 匯出身體測量資料
    final bodyMeasurement = loadBodyMeasurement();
    if (bodyMeasurement != null) {
      healthData['bodyMeasurement'] = {
        'weight': bodyMeasurement.weight,
        'height': bodyMeasurement.height,
        'bodyFatPercentage': bodyMeasurement.bodyFatPercentage,
        'measurementTime': bodyMeasurement.measurementTime?.toIso8601String(),
        'deviceName': bodyMeasurement.deviceName,
      };
    }

    // 匯出飲水記錄
    final waterIntake = loadWaterIntake();
    if (waterIntake != null) {
      healthData['waterIntake'] = {
        'currentIntake': waterIntake.currentIntake,
        'dailyGoal': waterIntake.dailyGoal,
        'lastDrinkTime': waterIntake.lastDrinkTime?.toIso8601String(),
      };
    }

    // 匯出營養資料
    final nutrition = loadNutritionIntake();
    if (nutrition != null) {
      healthData['nutrition'] = {
        'carbs': nutrition.carbs,
        'protein': nutrition.protein,
        'fat': nutrition.fat,
        'calories': nutrition.calories,
        'caloriesBurned': nutrition.caloriesBurned,
      };
    }

    // 加入匯出時間戳記
    healthData['exportTime'] = DateTime.now().toIso8601String();
    healthData['appVersion'] = AppConfig.appVersion;
    
    return healthData;
  }

  /// 從 JSON 匯入健康資料
  Future<bool> importHealthData(Map<String, dynamic> data) async {
    try {
      // 匯入身體測量資料
      if (data.containsKey('bodyMeasurement')) {
        final bodyData = data['bodyMeasurement'] as Map<String, dynamic>;
        final measurement = BodyMeasurement(
          weight: bodyData['weight']?.toDouble() ?? 0.0,
          height: bodyData['height']?.toDouble() ?? 0.0,
          bodyFatPercentage: bodyData['bodyFatPercentage']?.toDouble() ?? 0.0,
          measurementTime: bodyData['measurementTime'] != null 
              ? DateTime.parse(bodyData['measurementTime'])
              : null,
          deviceName: bodyData['deviceName'] ?? '',
        );
        await saveBodyMeasurement(measurement);
      }

      // 匯入飲水記錄
      if (data.containsKey('waterIntake')) {
        final waterData = data['waterIntake'] as Map<String, dynamic>;
        final waterIntake = WaterIntake(
          currentIntake: waterData['currentIntake'] ?? 0,
          dailyGoal: waterData['dailyGoal'] ?? AppConfig.defaultWaterGoal,
          lastDrinkTime: waterData['lastDrinkTime'] != null 
              ? DateTime.parse(waterData['lastDrinkTime'])
              : null,
        );
        await saveWaterIntake(waterIntake);
      }

      // 匯入營養資料
      if (data.containsKey('nutrition')) {
        final nutritionData = data['nutrition'] as Map<String, dynamic>;
        final nutrition = NutritionIntake(
          carbs: nutritionData['carbs'] ?? 0,
          protein: nutritionData['protein'] ?? 0,
          fat: nutritionData['fat'] ?? 0,
          calories: nutritionData['calories'] ?? 0,
          caloriesBurned: nutritionData['caloriesBurned'] ?? 0,
        );
        await saveNutritionIntake(nutrition);
      }

      print('健康資料匯入成功');
      return true;
    } catch (e) {
      print('健康資料匯入失敗: $e');
      return false;
    }
  }

  // ==================== 偵錯和統計方法 ====================
  
  /// 取得儲存空間使用統計
  Map<String, dynamic> getStorageStats() {
    _ensureInitialized();
    final keys = _prefs!.getKeys();
    int totalSize = 0;
    
    for (String key in keys) {
      final value = _prefs!.get(key);
      if (value is String) {
        totalSize += value.length;
      }
    }
    
    return {
      'totalKeys': keys.length,
      'estimatedSizeBytes': totalSize,
      'estimatedSizeKB': (totalSize / 1024).toStringAsFixed(2),
    };
  }

  /// 列印所有儲存的資料（僅用於偵錯）
  void debugPrintAllData() {
    if (!AppConfig.isDebugMode) return;
    
    _ensureInitialized();
    final keys = _prefs!.getKeys();
    
    print('=== 儲存服務偵錯資訊 ===');
    print('總計鍵值數量: ${keys.length}');
    
    for (String key in keys) {
      final value = _prefs!.get(key);
      print('$key: $value');
    }
    print('========================');
  }

  /// 驗證資料完整性
  bool validateDataIntegrity() {
    try {
      // 檢查重要的設定是否存在且有效
      final themeMode = getThemeMode();
      final language = getLanguage();
      final tabIndex = getLastTabIndex();
      
      // 基本驗證
      if (!['light', 'dark', 'system'].contains(themeMode)) {
        print('主題模式設定無效: $themeMode');
        return false;
      }
      
      if (tabIndex < 0 || tabIndex > 3) {
        print('分頁索引無效: $tabIndex');
        return false;
      }
      
      return true;
    } catch (e) {
      print('資料完整性驗證失敗: $e');
      return false;
    }
  }

  // ==================== 釋放資源 ====================
  
  /// 釋放服務資源
  void dispose() {
    // SharedPreferences 不需要手動釋放
    _isInitialized = false;
    print('儲存服務已釋放');
  }
}