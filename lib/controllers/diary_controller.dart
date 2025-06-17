// lib/controllers/diary_controller.dart
// 日記頁面控制器
// 功能：管理日記頁面的所有業務邏輯和狀態

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../services/health_data_service.dart';
import '../services/storage_service.dart';
import '../models/health_models.dart';
import '../models/measurement_models.dart';
import '../config/app_config.dart';

/// 日記頁面控制器
/// 
/// 負責管理日記頁面的所有功能，包括：
/// - 飲食記錄管理
/// - 飲水追蹤
/// - 身體測量資料
/// - 營養統計等
class DiaryController extends GetxController with GetTickerProviderStateMixin {
  
  // ==================== 服務注入 ====================
  final HealthDataService _healthDataService = HealthDataService();
  final StorageService _storageService = Get.find<StorageService>();

  // ==================== 響應式變數 ====================
  
  /// 餐點資料清單
  final RxList<MealData> meals = <MealData>[].obs;
  
  /// 目前飲水記錄
  final Rx<WaterIntake?> currentWaterIntake = Rx<WaterIntake?>(null);
  
  /// 目前身體測量資料
  final Rx<BodyMeasurement?> currentMeasurement = Rx<BodyMeasurement?>(null);
  
  /// 目前營養攝取資料
  final Rx<NutritionIntake?> currentNutrition = Rx<NutritionIntake?>(null);
  
  /// 頁面載入狀態
  final RxBool isLoading = true.obs;
  
  /// 滾動控制器透明度
  final RxDouble scrollOpacity = 0.0.obs;
  
  /// 選中的日期
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  
  /// 是否顯示詳細資訊
  final RxBool showDetailedInfo = false.obs;

  // ==================== 動畫控制器 ====================
  
  /// 主要動畫控制器
  late AnimationController animationController;
  
  /// 上方標題列動畫
  late Animation<double> topBarAnimation;
  
  /// 滾動控制器
  late ScrollController scrollController;

  // ==================== 生命週期方法 ====================
  
  @override
  void onInit() {
    super.onInit();
    _initializeAnimationControllers();
    _initializeScrollController();
    _loadDiaryData();
    _setupDataStreams();
  }

  @override
  void onReady() {
    super.onReady();
    _startInitialAnimation();
  }

  @override
  void onClose() {
    animationController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  // ==================== 初始化方法 ====================
  
  /// 初始化動畫控制器
  void _initializeAnimationControllers() {
    animationController = AnimationController(
      duration: AppConfig.slowAnimationDuration,
      vsync: this,
    );
    
    topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0, 0.5, curve: Curves.fastOutSlowIn),
      ),
    );
  }

  /// 初始化滾動控制器
  void _initializeScrollController() {
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);
  }

  /// 載入日記資料
  Future<void> _loadDiaryData() async {
    try {
      isLoading.value = true;
      
      // 載入餐點資料
      meals.value = _healthDataService.getMeals();
      
      // 載入飲水記錄
      currentWaterIntake.value = _healthDataService.getCurrentWaterIntake();
      
      // 載入身體測量資料
      currentMeasurement.value = _healthDataService.getCurrentMeasurement();
      
      // 載入營養資料
      currentNutrition.value = _healthDataService.getCurrentNutrition();
      
      print('日記資料載入完成');
    } catch (e) {
      print('載入日記資料失敗: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 設定資料流監聽
  void _setupDataStreams() {
    // 監聽餐點資料變化
    _healthDataService.mealsStream.listen((mealList) {
      meals.value = mealList;
    });
    
    // 監聽飲水記錄變化
    _healthDataService.waterStream.listen((waterIntake) {
      currentWaterIntake.value = waterIntake;
    });
    
    // 監聽身體測量資料變化
    _healthDataService.measurementStream.listen((measurement) {
      currentMeasurement.value = measurement;
    });
  }

  /// 開始初始動畫
  void _startInitialAnimation() {
    animationController.forward();
  }

  // ==================== 滾動處理方法 ====================
  
  /// 滾動事件處理
  void _onScroll() {
    final offset = scrollController.offset;
    if (offset >= 24) {
      if (scrollOpacity.value != 1.0) {
        scrollOpacity.value = 1.0;
      }
    } else if (offset <= 24 && offset >= 0) {
      if (scrollOpacity.value != offset / 24) {
        scrollOpacity.value = offset / 24;
      }
    } else if (offset <= 0) {
      if (scrollOpacity.value != 0.0) {
        scrollOpacity.value = 0.0;
      }
    }
  }

  // ==================== 飲食管理方法 ====================
  
  /// 更新餐點卡路里
  Future<void> updateMealCalories(String mealType, int calories) async {
    try {
      await _healthDataService.updateMealCalories(mealType, calories);
      
      // 更新本地資料
      final mealIndex = meals.indexWhere(
        (meal) => meal.titleTxt.toLowerCase() == mealType.toLowerCase()
      );
      
      if (mealIndex != -1) {
        meals[mealIndex] = meals[mealIndex].copyWith(kacl: calories);
        meals.refresh();
      }
      
      print('餐點卡路里已更新: $mealType = $calories');
    } catch (e) {
      print('更新餐點卡路里失敗: $e');
    }
  }

  /// 新增自訂餐點
  Future<void> addCustomMeal(MealData meal) async {
    try {
      await _healthDataService.addCustomMeal(meal);
      print('自訂餐點已新增: ${meal.titleTxt}');
    } catch (e) {
      print('新增自訂餐點失敗: $e');
    }
  }

  /// 取得今日總卡路里
  int getTotalCalories() {
    return meals.where((meal) => meal.kacl > 0)
        .fold(0, (total, meal) => total + meal.kacl);
  }

  /// 取得餐點完成百分比
  double getMealCompletionPercentage() {
    final totalActual = getTotalCalories();
    const targetCalories = 2000; // 預設目標
    return (totalActual / targetCalories * 100).clamp(0.0, 100.0);
  }

  // ==================== 飲水管理方法 ====================
  
  /// 增加飲水量
  Future<void> addWaterIntake(int amount) async {
    try {
      await _healthDataService.addWaterIntake(amount);
      print('飲水量已增加: ${amount}ml');
    } catch (e) {
      print('增加飲水量失敗: $e');
    }
  }

  /// 減少飲水量
  Future<void> reduceWaterIntake(int amount) async {
    try {
      await _healthDataService.reduceWaterIntake(amount);
      print('飲水量已減少: ${amount}ml');
    } catch (e) {
      print('減少飲水量失敗: $e');
    }
  }

  /// 設定飲水目標
  Future<void> setWaterGoal(int goal) async {
    try {
      await _healthDataService.setWaterGoal(goal);
      print('飲水目標已設定為: ${goal}ml');
    } catch (e) {
      print('設定飲水目標失敗: $e');
    }
  }

  /// 取得飲水完成百分比
  double getWaterCompletionPercentage() {
    final water = currentWaterIntake.value;
    if (water == null) return 0.0;
    return water.completionPercentage;
  }

  // ==================== 身體測量方法 ====================
  
  /// 更新體重
  Future<void> updateWeight(double weight) async {
    try {
      await _healthDataService.updateMeasurement(weight: weight);
      print('體重已更新為: ${weight}磅');
    } catch (e) {
      print('更新體重失敗: $e');
    }
  }

  /// 更新身高
  Future<void> updateHeight(double height) async {
    try {
      await _healthDataService.updateMeasurement(height: height);
      print('身高已更新為: ${height}公分');
    } catch (e) {
      print('更新身高失敗: $e');
    }
  }

  /// 更新體脂率
  Future<void> updateBodyFat(double bodyFat) async {
    try {
      await _healthDataService.updateMeasurement(bodyFatPercentage: bodyFat);
      print('體脂率已更新為: $bodyFat%');
    } catch (e) {
      print('更新體脂率失敗: $e');
    }
  }

  /// 取得 BMI 值
  double getBMI() {
    final measurement = currentMeasurement.value;
    return measurement?.bmi ?? 0.0;
  }

  /// 取得 BMI 狀態
  String getBMIStatus() {
    final measurement = currentMeasurement.value;
    return measurement?.bmiStatus ?? 'Unknown';
  }

  // ==================== 營養統計方法 ====================
  
  /// 取得營養進度
  Map<String, double> getNutritionProgress() {
    final nutrition = currentNutrition.value;
    if (nutrition == null) {
      return {'carbs': 0.0, 'protein': 0.0, 'fat': 0.0};
    }
    
    // 假設的每日目標值
    const carbsGoal = 250;
    const proteinGoal = 150;
    const fatGoal = 80;
    
    return {
      'carbs': (nutrition.carbs / carbsGoal * 100).clamp(0.0, 100.0),
      'protein': (nutrition.protein / proteinGoal * 100).clamp(0.0, 100.0),
      'fat': (nutrition.fat / fatGoal * 100).clamp(0.0, 100.0),
    };
  }

  /// 取得剩餘卡路里
  int getRemainingCalories() {
    final nutrition = currentNutrition.value;
    return nutrition?.remainingCalories ?? 0;
  }

  // ==================== 日期管理方法 ====================
  
  /// 選擇日期
  void selectDate(DateTime date) {
    selectedDate.value = date;
    _loadDataForDate(date);
  }

  /// 切換到前一天
  void goToPreviousDay() {
    final previousDay = selectedDate.value.subtract(const Duration(days: 1));
    selectDate(previousDay);
  }

  /// 切換到下一天
  void goToNextDay() {
    final nextDay = selectedDate.value.add(const Duration(days: 1));
    selectDate(nextDay);
  }

  /// 回到今天
  void goToToday() {
    selectDate(DateTime.now());
  }

  /// 載入指定日期的資料
  Future<void> _loadDataForDate(DateTime date) async {
    // 這裡可以根據日期載入不同的資料
    // 目前使用模擬資料
    await _loadDiaryData();
  }

  /// 取得格式化的日期字串
  String getFormattedDate() {
    final date = selectedDate.value;
    final now = DateTime.now();
    
    if (date.year == now.year && 
        date.month == now.month && 
        date.day == now.day) {
      return 'Today';
    }
    
    return '${date.day} ${_getMonthName(date.month)}';
  }

  /// 取得月份名稱
  String _getMonthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }

  // ==================== UI 控制方法 ====================
  
  /// 切換詳細資訊顯示
  void toggleDetailedInfo() {
    showDetailedInfo.value = !showDetailedInfo.value;
  }

  /// 重新整理資料
  Future<void> refreshData() async {
    await _loadDiaryData();
  }

  /// 取得今日統計摘要
  Map<String, dynamic> getTodaySummary() {
    return {
      'totalCalories': getTotalCalories(),
      'waterIntake': currentWaterIntake.value?.currentIntake ?? 0,
      'waterGoal': currentWaterIntake.value?.dailyGoal ?? 0,
      'weight': currentMeasurement.value?.weight ?? 0.0,
      'bmi': getBMI(),
      'caloriesRemaining': getRemainingCalories(),
    };
  }

  // ==================== 動畫控制方法 ====================
  
  /// 取得動畫控制器
  AnimationController get getAnimationController => animationController;
  
  /// 取得頂部標題列動畫
  Animation<double> get getTopBarAnimation => topBarAnimation;
  
  /// 取得滾動控制器
  ScrollController get getScrollController => scrollController;
  
  /// 播放刷新動畫
  Future<void> playRefreshAnimation() async {
    await animationController.reverse();
    await animationController.forward();
  }
}