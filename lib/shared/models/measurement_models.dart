// lib/models/measurement_models.dart
// 測量和健康數據模型
// 功能：定義各種健康測量數據的結構

/// 營養素攝取模型
/// 
/// 用於追蹤每日營養素攝取狀況
class NutritionIntake {
  NutritionIntake({
    this.carbs = 0,
    this.protein = 0,
    this.fat = 0,
    this.calories = 0,
    this.caloriesBurned = 0,
  });

  /// 碳水化合物攝取量（克）
  int carbs;
  
  /// 蛋白質攝取量（克）
  int protein;
  
  /// 脂肪攝取量（克）
  int fat;
  
  /// 總卡路里攝取量
  int calories;
  
  /// 消耗卡路里
  int caloriesBurned;

  /// 取得預設營養素資料
  static NutritionIntake get defaultNutrition => NutritionIntake(
    carbs: 120,
    protein: 85,
    fat: 45,
    calories: 1127,
    caloriesBurned: 102,
  );

  /// 計算總卡路里（根據營養素計算）
  int get calculatedCalories {
    return (carbs * 4) + (protein * 4) + (fat * 9);
  }

  /// 計算剩餘卡路里目標
  int get remainingCalories {
    const dailyGoal = 2630; // 預設每日目標
    return dailyGoal - calories + caloriesBurned;
  }

  /// 計算各營養素剩餘量
  Map<String, String> get remainingNutrients => {
    'carbs': '12g left',
    'protein': '30g left', 
    'fat': '10g left',
  };
}

/// 每日健康統計模型
/// 
/// 整合一天的健康數據
class DailyHealthStats {
  DailyHealthStats({
    this.date,
    this.nutritionIntake,
    this.waterIntake,
    this.bodyMeasurement,
  });

  /// 統計日期
  DateTime? date;
  
  /// 營養攝取資料
  NutritionIntake? nutritionIntake;
  
  /// 飲水記錄 (從 health_models.dart 引用)
  dynamic waterIntake;
  
  /// 身體測量資料 (從 health_models.dart 引用)
  dynamic bodyMeasurement;

  /// 取得今日預設統計資料
  static DailyHealthStats get todayStats => DailyHealthStats(
    date: DateTime.now(),
    nutritionIntake: NutritionIntake.defaultNutrition,
  );

  /// 計算淨卡路里（攝取 - 消耗）
  int get netCalories {
    final intake = nutritionIntake?.calories ?? 0;
    final burned = nutritionIntake?.caloriesBurned ?? 0;
    return intake - burned;
  }
}

/// 體重變化記錄模型
/// 
/// 用於追蹤體重變化趨勢
class WeightRecord {
  WeightRecord({
    this.weight = 0.0,
    this.date,
    this.note = '',
  });

  /// 體重值（磅或公斤）
  double weight;
  
  /// 記錄日期
  DateTime? date;
  
  /// 備註
  String note;

  /// 預設體重記錄清單
  static List<WeightRecord> get defaultRecords => [
    WeightRecord(
      weight: 206.8,
      date: DateTime.now(),
      note: 'Morning measurement',
    ),
    WeightRecord(
      weight: 207.2,
      date: DateTime.now().subtract(Duration(days: 1)),
      note: 'After workout',
    ),
    WeightRecord(
      weight: 206.5,
      date: DateTime.now().subtract(Duration(days: 2)),
      note: 'Regular check',
    ),
  ];
}

/// 運動歷史記錄模型
/// 
/// 用於記錄運動歷史和統計
class ExerciseHistory {
  ExerciseHistory({
    this.exerciseName = '',
    this.duration = 0,
    this.caloriesBurned = 0,
    this.date,
    this.intensity = ExerciseIntensity.medium,
  });

  /// 運動名稱
  String exerciseName;
  
  /// 運動時長（分鐘）
  int duration;
  
  /// 消耗卡路里
  int caloriesBurned;
  
  /// 運動日期
  DateTime? date;
  
  /// 運動強度
  ExerciseIntensity intensity;

  /// 預設運動歷史記錄
  static List<ExerciseHistory> get defaultHistory => [
    ExerciseHistory(
      exerciseName: 'Morning Run',
      duration: 30,
      caloriesBurned: 250,
      date: DateTime.now(),
      intensity: ExerciseIntensity.high,
    ),
    ExerciseHistory(
      exerciseName: 'Yoga Session',
      duration: 45,
      caloriesBurned: 120,
      date: DateTime.now().subtract(Duration(days: 1)),
      intensity: ExerciseIntensity.low,
    ),
  ];
}

/// 運動強度列舉
enum ExerciseIntensity {
  low,     // 低強度
  medium,  // 中強度
  high,    // 高強度
}

/// 心率監測模型
/// 
/// 用於記錄心率數據
class HeartRateData {
  HeartRateData({
    this.heartRate = 0,
    this.timestamp,
    this.activity = 'Resting',
  });

  /// 心率值（每分鐘次數）
  int heartRate;
  
  /// 記錄時間
  DateTime? timestamp;
  
  /// 活動狀態
  String activity;

  /// 預設心率數據
  static List<HeartRateData> get defaultData => [
    HeartRateData(
      heartRate: 72,
      timestamp: DateTime.now(),
      activity: 'Resting',
    ),
    HeartRateData(
      heartRate: 145,
      timestamp: DateTime.now().subtract(Duration(hours: 2)),
      activity: 'Running',
    ),
  ];

  /// 取得心率區間描述
  String get heartRateZone {
    if (heartRate < 60) return 'Very Low';
    if (heartRate < 100) return 'Normal';
    if (heartRate < 140) return 'Elevated';
    if (heartRate < 180) return 'High';
    return 'Very High';
  }
}