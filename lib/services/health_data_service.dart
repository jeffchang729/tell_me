// lib/services/health_data_service.dart
// 健康資料服務
// 功能：提供健康相關資料的存取和管理服務

import 'dart:async';
import 'dart:math';
import '../models/health_models.dart';
import '../models/measurement_models.dart';
import '../config/app_config.dart';

/// 健康資料服務類別
/// 
/// 負責管理所有健康相關的資料操作，包括：
/// - 飲食記錄管理
/// - 運動資料管理
/// - 身體測量資料
/// - 飲水記錄等
class HealthDataService {
  // 單例模式
  static final HealthDataService _instance = HealthDataService._internal();
  factory HealthDataService() => _instance;
  HealthDataService._internal();

  // 內部資料儲存
  List<MealData> _meals = [];
  List<WorkoutData> _workouts = [];
  List<FocusArea> _focusAreas = [];
  BodyMeasurement? _currentMeasurement;
  WaterIntake? _currentWaterIntake;
  NutritionIntake? _currentNutrition;
  List<ExerciseHistory> _exerciseHistory = [];

  // 資料流控制器
  final StreamController<List<MealData>> _mealsController = 
      StreamController<List<MealData>>.broadcast();
  final StreamController<WaterIntake> _waterController = 
      StreamController<WaterIntake>.broadcast();
  final StreamController<BodyMeasurement> _measurementController = 
      StreamController<BodyMeasurement>.broadcast();

  // ==================== 初始化方法 ====================
  
  /// 初始化服務並載入預設資料
  Future<void> initialize() async {
    await _loadDefaultData();
    print('健康資料服務已初始化');
  }

  /// 載入預設資料
  Future<void> _loadDefaultData() async {
    // 模擬載入延遲
    await Future.delayed(AppConfig.mockLoadingDelay);
    
    _meals = List.from(MealData.defaultMeals);
    _focusAreas = List.from(FocusArea.defaultAreas);
    _currentMeasurement = BodyMeasurement.defaultMeasurement;
    _currentWaterIntake = WaterIntake.defaultIntake;
    _currentNutrition = NutritionIntake.defaultNutrition;
    _exerciseHistory = List.from(ExerciseHistory.defaultHistory);
    
    // 通知監聽者
    _notifyDataChanged();
  }

  // ==================== 飲食相關方法 ====================
  
  /// 取得所有餐點資料
  List<MealData> getMeals() => List.unmodifiable(_meals);
  
  /// 取得餐點資料流
  Stream<List<MealData>> get mealsStream => _mealsController.stream;
  
  /// 根據類型取得特定餐點
  MealData? getMealByType(String mealType) {
    return MealData.getMealByType(mealType);
  }
  
  /// 更新餐點卡路里
  Future<void> updateMealCalories(String mealType, int calories) async {
    final mealIndex = _meals.indexWhere(
      (meal) => meal.titleTxt.toLowerCase() == mealType.toLowerCase()
    );
    
    if (mealIndex != -1) {
      _meals[mealIndex] = _meals[mealIndex].copyWith(kacl: calories);
      _mealsController.add(_meals);
      
      // 更新營養資料
      await _updateNutritionFromMeals();
    }
  }
  
  /// 新增自訂餐點
  Future<void> addCustomMeal(MealData meal) async {
    _meals.add(meal);
    _mealsController.add(_meals);
    await _updateNutritionFromMeals();
  }
  
  /// 計算今日總卡路里
  int getTotalCalories() => MealData.getTotalCalories();

  // ==================== 運動相關方法 ====================
  
  /// 取得預設運動資料
  WorkoutData getDefaultWorkout() => WorkoutData.defaultWorkout;
  
  /// 取得運動焦點區域
  List<FocusArea> getFocusAreas() => List.unmodifiable(_focusAreas);
  
  /// 切換焦點區域選擇狀態
  Future<void> toggleFocusArea(int index) async {
    if (index >= 0 && index < _focusAreas.length) {
      _focusAreas[index].isSelected = !_focusAreas[index].isSelected;
    }
  }
  
  /// 取得運動歷史記錄
  List<ExerciseHistory> getExerciseHistory() => List.unmodifiable(_exerciseHistory);
  
  /// 新增運動記錄
  Future<void> addExerciseRecord(ExerciseHistory exercise) async {
    _exerciseHistory.insert(0, exercise); // 最新的在前面
    
    // 更新營養資料中的消耗卡路里
    if (_currentNutrition != null) {
      _currentNutrition!.caloriesBurned += exercise.caloriesBurned;
    }
  }

  // ==================== 身體測量相關方法 ====================
  
  /// 取得目前身體測量資料
  BodyMeasurement? getCurrentMeasurement() => _currentMeasurement;
  
  /// 取得身體測量資料流
  Stream<BodyMeasurement> get measurementStream => _measurementController.stream;
  
  /// 更新身體測量資料
  Future<void> updateMeasurement({
    double? weight,
    double? height,
    double? bodyFatPercentage,
  }) async {
    if (_currentMeasurement != null) {
      _currentMeasurement = BodyMeasurement(
        weight: weight ?? _currentMeasurement!.weight,
        height: height ?? _currentMeasurement!.height,
        bodyFatPercentage: bodyFatPercentage ?? _currentMeasurement!.bodyFatPercentage,
        measurementTime: DateTime.now(),
        deviceName: _currentMeasurement!.deviceName,
      );
      
      _measurementController.add(_currentMeasurement!);
    }
  }

  // ==================== 飲水相關方法 ====================
  
  /// 取得目前飲水記錄
  WaterIntake? getCurrentWaterIntake() => _currentWaterIntake;
  
  /// 取得飲水記錄流
  Stream<WaterIntake> get waterStream => _waterController.stream;
  
  /// 增加飲水量
  Future<void> addWaterIntake(int amount) async {
    if (_currentWaterIntake != null) {
      _currentWaterIntake!.addIntake(amount);
      _waterController.add(_currentWaterIntake!);
    }
  }
  
  /// 減少飲水量
  Future<void> reduceWaterIntake(int amount) async {
    if (_currentWaterIntake != null) {
      _currentWaterIntake!.reduceIntake(amount);
      _waterController.add(_currentWaterIntake!);
    }
  }
  
  /// 設定每日飲水目標
  Future<void> setWaterGoal(int goal) async {
    if (_currentWaterIntake != null) {
      _currentWaterIntake!.dailyGoal = goal;
      _waterController.add(_currentWaterIntake!);
    }
  }

  // ==================== 營養相關方法 ====================
  
  /// 取得目前營養攝取資料
  NutritionIntake? getCurrentNutrition() => _currentNutrition;
  
  /// 取得每日健康統計
  DailyHealthStats getDailyStats() {
    return DailyHealthStats(
      date: DateTime.now(),
      nutritionIntake: _currentNutrition,
      waterIntake: _currentWaterIntake,
      bodyMeasurement: _currentMeasurement,
    );
  }

  // ==================== 內部輔助方法 ====================
  
  /// 根據餐點資料更新營養統計
  Future<void> _updateNutritionFromMeals() async {
    final totalCalories = _meals
        .where((meal) => meal.kacl > 0)
        .fold(0, (total, meal) => total + meal.kacl);
    
    if (_currentNutrition != null) {
      _currentNutrition!.calories = totalCalories;
    }
  }
  
  /// 通知所有資料變更
  void _notifyDataChanged() {
    _mealsController.add(_meals);
    if (_currentWaterIntake != null) {
      _waterController.add(_currentWaterIntake!);
    }
    if (_currentMeasurement != null) {
      _measurementController.add(_currentMeasurement!);
    }
  }

  // ==================== 模擬資料生成方法 ====================
  
  /// 生成隨機心率資料（用於演示）
  List<HeartRateData> generateRandomHeartRateData() {
    final random = Random();
    final now = DateTime.now();
    
    return List.generate(10, (index) {
      return HeartRateData(
        heartRate: 60 + random.nextInt(40), // 60-100 之間的心率
        timestamp: now.subtract(Duration(hours: index)),
        activity: ['Resting', 'Walking', 'Running'][random.nextInt(3)],
      );
    });
  }
  
  /// 生成模擬的體重變化資料
  List<WeightRecord> generateWeightTrend() {
    final random = Random();
    final now = DateTime.now();
    double baseWeight = 206.8;
    
    return List.generate(30, (index) {
      baseWeight += (random.nextDouble() - 0.5) * 2; // 隨機變化
      return WeightRecord(
        weight: double.parse(baseWeight.toStringAsFixed(1)),
        date: now.subtract(Duration(days: index)),
        note: 'Daily measurement',
      );
    });
  }

  // ==================== 清理方法 ====================
  
  /// 釋放資源
  void dispose() {
    _mealsController.close();
    _waterController.close();
    _measurementController.close();
  }
}