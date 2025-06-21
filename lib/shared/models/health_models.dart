// lib/models/health_models.dart
// 健康資料模型集合
// 功能：定義飲食、測量、運動等相關的資料結構

import 'package:flutter/material.dart';

/// 飲食資料模型
/// 
/// 用於表示一餐的完整資訊，包含：
/// - 圖片路徑和顯示名稱
/// - 漸層顏色配置
/// - 食物清單和卡路里計算
class MealData {
  MealData({
    this.imagePath = '',
    this.titleTxt = '',
    this.startColor = '',
    this.endColor = '',
    this.meals,
    this.kacl = 0,
  });

  /// 餐點圖片檔案路徑
  String imagePath;
  
  /// 餐點顯示名稱（早餐、午餐、晚餐等）
  String titleTxt;
  
  /// 漸層開始顏色（十六進位格式）
  String startColor;
  
  /// 漸層結束顏色（十六進位格式）
  String endColor;
  
  /// 食物項目清單
  List<String>? meals;
  
  /// 卡路里數值
  int kacl;

  /// 預設餐點資料清單
  /// 
  /// 包含四種餐點類型的預設配置：
  /// - 早餐：麵包、花生醬、蘋果 (525大卡)
  /// - 午餐：鮭魚、綜合蔬菜、酪梨 (602大卡)
  /// - 點心：建議攝取800大卡
  /// - 晚餐：建議攝取703大卡
  static List<MealData> defaultMeals = <MealData>[
    // 早餐配置
    MealData(
      imagePath: 'assets/fitness_app/breakfast.png',
      titleTxt: 'Breakfast',
      kacl: 525,
      meals: <String>['Bread,', 'Peanut butter,', 'Apple'],
      startColor: '#FA7D82',
      endColor: '#FFB295',
    ),
    
    // 午餐配置
    MealData(
      imagePath: 'assets/fitness_app/lunch.png',
      titleTxt: 'Lunch',
      kacl: 602,
      meals: <String>['Salmon,', 'Mixed veggies,', 'Avocado'],
      startColor: '#738AE6',
      endColor: '#5C5EDD',
    ),
    
    // 點心配置
    MealData(
      imagePath: 'assets/fitness_app/snack.png',
      titleTxt: 'Snack',
      kacl: 0, // 0 表示顯示建議攝取量而非實際數值
      meals: <String>['Recommend:', '800 kcal'],
      startColor: '#FE95B6',
      endColor: '#FF5287',
    ),
    
    // 晚餐配置
    MealData(
      imagePath: 'assets/fitness_app/dinner.png',
      titleTxt: 'Dinner',
      kacl: 0, // 0 表示顯示建議攝取量而非實際數值
      meals: <String>['Recommend:', '703 kcal'],
      startColor: '#6F72CA',
      endColor: '#1E1466',
    ),
  ];

  /// 取得特定餐點類型的資料
  static MealData? getMealByType(String mealType) {
    try {
      return defaultMeals.firstWhere(
        (meal) => meal.titleTxt.toLowerCase() == mealType.toLowerCase(),
      );
    } catch (e) {
      return null; // 找不到對應的餐點類型
    }
  }

  /// 計算總卡路里（僅計算有實際數值的餐點）
  static int getTotalCalories() {
    return defaultMeals
        .where((meal) => meal.kacl > 0)
        .fold(0, (total, meal) => total + meal.kacl);
  }

  /// 檢查是否為建議餐點（顯示建議攝取量而非實際攝取）
  bool get isRecommendation => kacl == 0;

  /// 取得格式化的食物清單字串
  String get formattedMeals => meals?.join('\n') ?? '';

  /// 複製並修改餐點資料
  MealData copyWith({
    String? imagePath,
    String? titleTxt,
    String? startColor,
    String? endColor,
    List<String>? meals,
    int? kacl,
  }) {
    return MealData(
      imagePath: imagePath ?? this.imagePath,
      titleTxt: titleTxt ?? this.titleTxt,
      startColor: startColor ?? this.startColor,
      endColor: endColor ?? this.endColor,
      meals: meals ?? this.meals,
      kacl: kacl ?? this.kacl,
    );
  }
}

/// 身體測量資料模型
/// 
/// 用於記錄和顯示身體各項測量數據
class BodyMeasurement {
  BodyMeasurement({
    this.weight = 0.0,
    this.height = 0.0,
    this.bodyFatPercentage = 0.0,
    this.measurementTime,
    this.deviceName = '',
  });

  /// 體重（磅）
  double weight;
  
  /// 身高（公分）
  double height;
  
  /// 體脂肪百分比
  double bodyFatPercentage;
  
  /// 測量時間
  DateTime? measurementTime;
  
  /// 測量設備名稱
  String deviceName;

  /// 計算 BMI 值
  double get bmi {
    if (height <= 0) return 0.0;
    final heightInMeters = height / 100;
    final weightInKg = weight * 0.453592; // 磅轉公斤
    return weightInKg / (heightInMeters * heightInMeters);
  }

  /// 取得 BMI 狀態描述
  String get bmiStatus {
    final bmiValue = bmi;
    if (bmiValue < 18.5) return 'Underweight';
    if (bmiValue < 25) return 'Normal';
    if (bmiValue < 30) return 'Overweight';
    return 'Obese';
  }

  /// 取得預設測量資料
  static BodyMeasurement get defaultMeasurement => BodyMeasurement(
    weight: 206.8,
    height: 185,
    bodyFatPercentage: 20.0,
    measurementTime: DateTime.now(),
    deviceName: 'InBody SmartScale',
  );
}

/// 運動資料模型
/// 
/// 用於記錄和管理運動訓練資料
class WorkoutData {
  WorkoutData({
    this.title = '',
    this.description = '',
    this.duration = 0,
    this.imagePath = '',
    this.workoutType = WorkoutType.strength,
  });

  /// 運動標題
  String title;
  
  /// 運動描述
  String description;
  
  /// 運動時長（分鐘）
  int duration;
  
  /// 運動圖片路徑
  String imagePath;
  
  /// 運動類型
  WorkoutType workoutType;

  /// 取得預設運動資料
  static WorkoutData get defaultWorkout => WorkoutData(
    title: 'Legs Toning and\nGlutes Workout at Home',
    description: 'Next workout',
    duration: 68,
    imagePath: 'assets/fitness_app/workout.png',
    workoutType: WorkoutType.strength,
  );
}

/// 運動類型列舉
enum WorkoutType {
  strength,   // 肌力訓練
  cardio,     // 有氧運動
  flexibility, // 柔軟度訓練
  balance,    // 平衡訓練
}

/// 飲水記錄模型
/// 
/// 用於追蹤每日飲水量
class WaterIntake {
  WaterIntake({
    this.currentIntake = 0,
    this.dailyGoal = 3500,
    this.lastDrinkTime,
  });

  /// 目前攝取量（毫升）
  int currentIntake;
  
  /// 每日目標（毫升）
  int dailyGoal;
  
  /// 最後飲水時間
  DateTime? lastDrinkTime;

  /// 計算完成百分比
  double get completionPercentage {
    if (dailyGoal <= 0) return 0.0;
    return (currentIntake / dailyGoal * 100).clamp(0.0, 100.0);
  }

  /// 檢查是否達成目標
  bool get isGoalAchieved => currentIntake >= dailyGoal;

  /// 取得剩餘需要攝取的水量
  int get remainingIntake => (dailyGoal - currentIntake).clamp(0, dailyGoal);

  /// 取得預設飲水資料
  static WaterIntake get defaultIntake => WaterIntake(
    currentIntake: 2100,
    dailyGoal: 3500,
    lastDrinkTime: DateTime.now().subtract(Duration(hours: 2)),
  );

  /// 增加飲水量
  void addIntake(int amount) {
    currentIntake += amount;
    lastDrinkTime = DateTime.now();
  }

  /// 減少飲水量
  void reduceIntake(int amount) {
    currentIntake = (currentIntake - amount).clamp(0, currentIntake);
  }
}

/// 運動焦點區域模型
/// 
/// 用於表示不同的運動焦點部位
class FocusArea {
  FocusArea({
    this.imagePath = '',
    this.title = '',
    this.isSelected = false,
  });

  /// 區域圖片路徑
  String imagePath;
  
  /// 區域標題
  String title;
  
  /// 是否被選中
  bool isSelected;

  /// 預設焦點區域清單
  static List<FocusArea> defaultAreas = [
    FocusArea(
      imagePath: 'assets/fitness_app/area1.png',
      title: 'Upper Body',
    ),
    FocusArea(
      imagePath: 'assets/fitness_app/area2.png',
      title: 'Core',
    ),
    FocusArea(
      imagePath: 'assets/fitness_app/area3.png',
      title: 'Lower Body',
    ),
    FocusArea(
      imagePath: 'assets/fitness_app/area1.png',
      title: 'Full Body',
    ),
  ];
}