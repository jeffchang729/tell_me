// lib/models/tab_icon_data.dart
// 底部導航列圖示資料模型
// 功能：管理底部導航列的圖示狀態、動畫和選擇邏輯

import 'package:flutter/material.dart';

/// 底部導航列圖示資料模型
/// 
/// 管理底部導航列的圖示狀態、動畫和選擇邏輯
class TabIconData {
  TabIconData({
    this.imagePath = '',
    this.index = 0,
    this.selectedImagePath = '',
    this.isSelected = false,
    this.animationController,
  });

  /// 未選中狀態的圖示路徑
  String imagePath;
  
  /// 選中狀態的圖示路徑
  String selectedImagePath;
  
  /// 是否為目前選中的分頁
  bool isSelected;
  
  /// 分頁索引（0-3）
  int index;

  /// 動畫控制器（用於點擊動畫效果）
  AnimationController? animationController;

  /// 預設分頁圖示清單
  /// 
  /// 包含四個主要功能分頁：
  /// - 索引 0：我的日記（預設選中）
  /// - 索引 1：訓練記錄
  /// - 索引 2：健康數據
  /// - 索引 3：設定選項
  static List<TabIconData> tabIconsList = <TabIconData>[
    // 我的日記分頁
    TabIconData(
      imagePath: 'assets/fitness_app/tab_1.png',
      selectedImagePath: 'assets/fitness_app/tab_1s.png',
      index: 0,
      isSelected: true, // 預設選中第一個分頁
      animationController: null,
    ),
    
    // 訓練記錄分頁
    TabIconData(
      imagePath: 'assets/fitness_app/tab_2.png',
      selectedImagePath: 'assets/fitness_app/tab_2s.png',
      index: 1,
      isSelected: false,
      animationController: null,
    ),
    
    // 健康數據分頁
    TabIconData(
      imagePath: 'assets/fitness_app/tab_3.png',
      selectedImagePath: 'assets/fitness_app/tab_3s.png',
      index: 2,
      isSelected: false,
      animationController: null,
    ),
    
    // 設定選項分頁
    TabIconData(
      imagePath: 'assets/fitness_app/tab_4.png',
      selectedImagePath: 'assets/fitness_app/tab_4s.png',
      index: 3,
      isSelected: false,
      animationController: null,
    ),
  ];

  /// 重設所有分頁的選中狀態
  static void resetAllSelection() {
    for (TabIconData tab in tabIconsList) {
      tab.isSelected = false;
    }
  }

  /// 設定指定索引的分頁為選中狀態
  static void setSelectedByIndex(int index) {
    resetAllSelection();
    if (index >= 0 && index < tabIconsList.length) {
      tabIconsList[index].isSelected = true;
    }
  }

  /// 取得目前選中的分頁索引
  static int getCurrentSelectedIndex() {
    for (int i = 0; i < tabIconsList.length; i++) {
      if (tabIconsList[i].isSelected) {
        return i;
      }
    }
    return 0; // 預設返回第一個分頁
  }

  /// 取得指定索引的分頁資料
  static TabIconData? getTabByIndex(int index) {
    if (index >= 0 && index < tabIconsList.length) {
      return tabIconsList[index];
    }
    return null;
  }

  /// 清理所有動畫控制器
  static void disposeAllAnimations() {
    for (TabIconData tab in tabIconsList) {
      tab.animationController?.dispose();
      tab.animationController = null;
    }
  }

  /// 複製並修改分頁資料
  TabIconData copyWith({
    String? imagePath,
    String? selectedImagePath,
    bool? isSelected,
    int? index,
    AnimationController? animationController,
  }) {
    return TabIconData(
      imagePath: imagePath ?? this.imagePath,
      selectedImagePath: selectedImagePath ?? this.selectedImagePath,
      isSelected: isSelected ?? this.isSelected,
      index: index ?? this.index,
      animationController: animationController ?? this.animationController,
    );
  }

  /// 取得目前應該顯示的圖示路徑
  String get currentImagePath => isSelected ? selectedImagePath : imagePath;
}