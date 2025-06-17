// lib/controllers/training_controller.dart
// 訓練頁面控制器
// 功能：管理訓練頁面的所有業務邏輯和狀態

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:async';

/// 訓練頁面控制器
/// 
/// 負責管理訓練頁面的所有功能，包括：
/// - 運動計劃管理
/// - 訓練記錄追蹤
/// - 焦點區域選擇
/// - 運動統計等
class TrainingController extends GetxController with GetTickerProviderStateMixin {
  
  // ==================== 響應式變數 ====================
  
  /// 頁面載入狀態
  final RxBool isLoading = true.obs;
  
  /// 滾動控制器透明度
  final RxDouble scrollOpacity = 0.0.obs;
  
  /// 是否正在運動中
  final RxBool isWorkingOut = false.obs;
  
  /// 運動計時器時間（秒）
  final RxInt workoutTimer = 0.obs;
  
  /// 每週運動目標（分鐘）
  final RxInt weeklyGoal = 300.obs;
  
  /// 本週已完成時間（分鐘）
  final RxInt weeklyCompleted = 0.obs;

  // ==================== 動畫控制器 ====================
  
  /// 主要動畫控制器
  late AnimationController animationController;
  
  /// 上方標題列動畫
  late Animation<double> topBarAnimation;
  
  /// 滾動控制器
  late ScrollController scrollController;
  
  /// 運動計時器
  Timer? _workoutTimer;

  // ==================== 生命週期方法 ====================
  
  @override
  void onInit() {
    super.onInit();
    _initializeAnimationControllers();
    _initializeScrollController();
    _loadWeeklyProgress();
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
    _workoutTimer?.cancel();
    super.onClose();
  }

  // ==================== 初始化方法 ====================
  
  /// 初始化動畫控制器
  void _initializeAnimationControllers() {
    animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
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

  /// 載入每週進度
  void _loadWeeklyProgress() {
    weeklyGoal.value = 300;
    weeklyCompleted.value = _calculateWeeklyCompleted();
    isLoading.value = false;
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

  // ==================== 運動計劃管理方法 ====================
  
  /// 開始運動
  void startWorkout() {
    if (!isWorkingOut.value) {
      isWorkingOut.value = true;
      workoutTimer.value = 0;
      _startWorkoutTimer();
      print('運動已開始');
    }
  }

  /// 暫停運動
  void pauseWorkout() {
    if (isWorkingOut.value) {
      _workoutTimer?.cancel();
      print('運動已暫停');
    }
  }

  /// 恢復運動
  void resumeWorkout() {
    if (isWorkingOut.value) {
      _startWorkoutTimer();
      print('運動已恢復');
    }
  }

  /// 結束運動
  Future<void> stopWorkout() async {
    if (isWorkingOut.value) {
      _workoutTimer?.cancel();
      isWorkingOut.value = false;
      
      // 記錄運動
      await _recordWorkout();
      
      // 重設計時器
      workoutTimer.value = 0;
      
      print('運動已結束');
    }
  }

  /// 開始運動計時器
  void _startWorkoutTimer() {
    _workoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      workoutTimer.value++;
    });
  }

  /// 記錄運動
  Future<void> _recordWorkout() async {
    final duration = workoutTimer.value ~/ 60; // 轉換為分鐘
    if (duration > 0) {
      // 更新每週完成時間
      weeklyCompleted.value += duration;
      
      print('運動記錄已儲存: ${duration}分鐘');
    }
  }

  // ==================== 統計和進度方法 ====================
  
  /// 計算每週完成進度
  int _calculateWeeklyCompleted() {
    // 模擬數據，實際應該從儲存中讀取
    return 120; // 120分鐘
  }

  /// 取得每週完成百分比
  double getWeeklyCompletionPercentage() {
    if (weeklyGoal.value <= 0) return 0.0;
    return (weeklyCompleted.value / weeklyGoal.value * 100).clamp(0.0, 100.0);
  }

  /// 取得剩餘運動時間
  int getRemainingMinutes() {
    return (weeklyGoal.value - weeklyCompleted.value).clamp(0, weeklyGoal.value);
  }

  /// 設定每週目標
  Future<void> setWeeklyGoal(int minutes) async {
    weeklyGoal.value = minutes;
    print('每週目標已設定為: ${minutes}分鐘');
  }

  /// 取得本月運動統計
  Map<String, int> getMonthlyStats() {
    return {
      'totalMinutes': 480,
      'totalCalories': 2400,
      'workoutDays': 12,
      'averagePerDay': 40,
    };
  }

  // ==================== UI 控制方法 ====================
  
  /// 重新整理資料
  Future<void> refreshData() async {
    isLoading.value = true;
    await Future.delayed(Duration(milliseconds: 500));
    _loadWeeklyProgress();
  }

  /// 取得格式化的運動時間
  String getFormattedWorkoutTime() {
    final minutes = workoutTimer.value ~/ 60;
    final seconds = workoutTimer.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// 取得運動狀態文字
  String getWorkoutStatusText() {
    if (isWorkingOut.value) {
      return '運動中';
    } else if (workoutTimer.value > 0) {
      return '已暫停';
    } else {
      return '準備開始';
    }
  }

  /// 取得今日訓練摘要
  Map<String, dynamic> getTodayTrainingSummary() {
    return {
      'todayMinutes': 45,
      'todayCalories': 320,
      'workoutsCompleted': 1,
      'weeklyProgress': getWeeklyCompletionPercentage(),
      'isWorkingOut': isWorkingOut.value,
      'currentTimer': getFormattedWorkoutTime(),
    };
  }

  // ==================== 動畫控制方法 ====================
  
  /// 取得動畫控制器
  AnimationController get getAnimationController => animationController;
  
  /// 取得頂部標題列動畫
  Animation<double> get getTopBarAnimation => topBarAnimation;
  
  /// 取得滾動控制器
  ScrollController get getScrollController => scrollController;
  
  /// 播放完成動畫
  Future<void> playCompletionAnimation() async {
    await animationController.reverse();
    await animationController.forward();
  }
}