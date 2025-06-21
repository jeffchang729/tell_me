// features/home/controllers/app_controller.dart
// 應用程式主控制器
// 功能：管理應用程式的全域狀態和業務邏輯

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../shared/services/storage_service.dart';
import '../../../shared/services/health_data_service.dart';
import '../../../shared/models/tab_icon_data.dart';
import '../../../core/config/app_config.dart';

/// 應用程式主控制器
/// 
/// 負責管理應用程式的全域狀態，包括：
/// - 底部導航管理
/// - 主題切換
/// - 語言設定
/// - 全域載入狀態
/// - 使用者偏好設定等
class AppController extends GetxController with GetTickerProviderStateMixin {
  
  // ==================== 服務注入 ====================
  final StorageService _storageService = Get.find<StorageService>();
  final HealthDataService _healthDataService = HealthDataService();

  // ==================== 響應式變數 ====================
  
  /// 目前選中的底部導航索引
  final RxInt currentTabIndex = 0.obs;
  
  /// 應用程式載入狀態
  final RxBool isLoading = true.obs;
  
  /// 主題模式（light/dark/system）
  final RxString themeMode = 'light'.obs;
  
  /// 語言代碼
  final RxString languageCode = 'zh'.obs;
  
  /// 是否為首次啟動
  final RxBool isFirstLaunch = true.obs;
  
  /// 底部導航圖示資料清單
  final RxList<TabIconData> tabIconsList = <TabIconData>[].obs;
  
  /// 網路連線狀態
  final RxBool isConnected = true.obs;

  // ==================== 動畫控制器 ====================
  
  /// 主要動畫控制器
  late AnimationController mainAnimationController;
  
  /// 底部導航動畫控制器
  late AnimationController bottomBarAnimationController;

  // ==================== 生命週期方法 ====================
  
  @override
  void onInit() {
    super.onInit();
    _initializeAnimationControllers();
    _initializeTabIcons();
    _loadUserPreferences();
    _initializeServices();
  }

  @override
  void onReady() {
    super.onReady();
    _startInitialAnimation();
  }

  @override
  void onClose() {
    mainAnimationController.dispose();
    bottomBarAnimationController.dispose();
    _healthDataService.dispose();
    super.onClose();
  }

  // ==================== 初始化方法 ====================
  
  /// 初始化動畫控制器
  void _initializeAnimationControllers() {
    mainAnimationController = AnimationController(
      duration: AppConfig.slowAnimationDuration,
      vsync: this,
    );
    
    bottomBarAnimationController = AnimationController(
      duration: AppConfig.defaultAnimationDuration,
      vsync: this,
    );
  }

  /// 初始化底部導航圖示
  void _initializeTabIcons() {
    tabIconsList.value = List.from(TabIconData.tabIconsList);
    
    // 為每個圖示設定動畫控制器
    for (var tab in tabIconsList) {
      tab.animationController = AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      );
    }
  }

  /// 載入使用者偏好設定
  void _loadUserPreferences() {
    try {
      // 載入主題設定
      themeMode.value = _storageService.getThemeMode();
      
      // 載入語言設定
      languageCode.value = _storageService.getLanguage();
      
      // 載入最後使用的分頁
      currentTabIndex.value = _storageService.getLastTabIndex();
      
      // 檢查是否為首次啟動
      isFirstLaunch.value = _storageService.isFirstLaunch();
      
      // 更新底部導航狀態
      _updateTabSelection(currentTabIndex.value);
      
      print('使用者偏好設定載入完成');
    } catch (e) {
      print('載入使用者偏好設定失敗: $e');
    }
  }

  /// 初始化服務
  Future<void> _initializeServices() async {
    try {
      isLoading.value = true;
      
      // 初始化健康資料服務
      await _healthDataService.initialize();
      
      // 模擬載入延遲
      await Future.delayed(AppConfig.mockLoadingDelay);
      
      isLoading.value = false;
      print('所有服務初始化完成');
    } catch (e) {
      print('服務初始化失敗: $e');
      isLoading.value = false;
    }
  }

  /// 開始初始動畫
  void _startInitialAnimation() {
    mainAnimationController.forward();
    bottomBarAnimationController.forward();
  }

  // ==================== 底部導航方法 ====================
  
  /// 切換底部導航分頁
  void changeTabIndex(int index) {
    if (index == currentTabIndex.value) return;
    
    // 儲存新的分頁索引
    currentTabIndex.value = index;
    _storageService.saveLastTabIndex(index);
    
    // 更新底部導航狀態
    _updateTabSelection(index);
    
    // 觸發動畫
    _triggerTabAnimation(index);
    
    print('切換到分頁: $index');
  }

  /// 更新分頁選擇狀態
  void _updateTabSelection(int selectedIndex) {
    for (int i = 0; i < tabIconsList.length; i++) {
      tabIconsList[i].isSelected = (i == selectedIndex);
    }
    tabIconsList.refresh();
  }

  /// 觸發分頁切換動畫
  void _triggerTabAnimation(int index) {
    if (index >= 0 && index < tabIconsList.length) {
      final tabIcon = tabIconsList[index];
      tabIcon.animationController?.forward().then((_) {
        tabIcon.animationController?.reverse();
      });
    }
  }

  /// 取得目前選中的分頁資料
  TabIconData? getCurrentTab() {
    if (currentTabIndex.value >= 0 && currentTabIndex.value < tabIconsList.length) {
      return tabIconsList[currentTabIndex.value];
    }
    return null;
  }

  // ==================== 主題管理方法 ====================
  
  /// 切換主題模式
  Future<void> changeThemeMode(String mode) async {
    if (['light', 'dark', 'system'].contains(mode)) {
      themeMode.value = mode;
      await _storageService.saveThemeMode(mode);
      
      // 根據模式更新系統主題
      _applyThemeMode(mode);
      
      print('主題已切換為: $mode');
    }
  }

  /// 應用主題模式
  void _applyThemeMode(String mode) {
    switch (mode) {
      case 'light':
        Get.changeThemeMode(ThemeMode.light);
        break;
      case 'dark':
        Get.changeThemeMode(ThemeMode.dark);
        break;
      case 'system':
        Get.changeThemeMode(ThemeMode.system);
        break;
    }
  }

  /// 切換深色/淺色主題
  void toggleTheme() {
    final newMode = themeMode.value == 'light' ? 'dark' : 'light';
    changeThemeMode(newMode);
  }

  // ==================== 語言管理方法 ====================
  
  /// 切換語言
  Future<void> changeLanguage(String langCode) async {
    if (['zh', 'en'].contains(langCode)) {
      languageCode.value = langCode;
      await _storageService.saveLanguage(langCode);
      
      // 更新應用程式語言
      final locale = Locale(langCode, langCode == 'zh' ? 'TW' : 'US');
      Get.updateLocale(locale);
      
      print('語言已切換為: $langCode');
    }
  }

  // ==================== 應用程式狀態方法 ====================
  
  /// 設定載入狀態
  void setLoadingState(bool loading) {
    isLoading.value = loading;
  }

  /// 設定網路連線狀態
  void setNetworkState(bool connected) {
    isConnected.value = connected;
  }

  /// 標記首次啟動完成
  Future<void> completeFirstLaunch() async {
    isFirstLaunch.value = false;
    await _storageService.setFirstLaunch(false);
  }

  /// 重設應用程式到初始狀態
  Future<void> resetToDefault() async {
    // 重設分頁
    changeTabIndex(0);
    
    // 重設主題
    await changeThemeMode('light');
    
    // 重設語言
    await changeLanguage('zh');
    
    // 重設動畫
    mainAnimationController.reset();
    mainAnimationController.forward();
    
    print('應用程式已重設為預設狀態');
  }

  // ==================== 動畫控制方法 ====================
  
  /// 取得主要動畫控制器
  AnimationController get getMainAnimationController => mainAnimationController;
  
  /// 取得底部導航動畫控制器
  AnimationController get getBottomBarAnimationController => bottomBarAnimationController;
  
  /// 播放切換動畫
  Future<void> playTransitionAnimation() async {
    await mainAnimationController.reverse();
    await mainAnimationController.forward();
  }

  /// 暫停所有動畫
  void pauseAllAnimations() {
    mainAnimationController.stop();
    bottomBarAnimationController.stop();
    
    for (var tab in tabIconsList) {
      tab.animationController?.stop();
    }
  }

  /// 恢復所有動畫
  void resumeAllAnimations() {
    if (!mainAnimationController.isAnimating) {
      mainAnimationController.forward();
    }
    if (!bottomBarAnimationController.isAnimating) {
      bottomBarAnimationController.forward();
    }
  }

  // ==================== 實用方法 ====================
  
  /// 取得應用程式版本資訊
  String getAppVersion() => AppConfig.formattedVersion;
  
  /// 取得應用程式名稱
  String getAppName() => AppConfig.appName;
  
  /// 檢查是否為除錯模式
  bool get isDebugMode => AppConfig.isDebugMode;
  
  /// 取得當前語言的顯示名稱
  String get currentLanguageName {
    switch (languageCode.value) {
      case 'zh':
        return '繁體中文';
      case 'en':
        return 'English';
      default:
        return '繁體中文';
    }
  }
  
  /// 取得當前主題的顯示名稱
  String get currentThemeName {
    switch (themeMode.value) {
      case 'light':
        return '淺色主題';
      case 'dark':
        return '深色主題';
      case 'system':
        return '跟隨系統';
      default:
        return '淺色主題';
    }
  }

  // ==================== 偵錯方法 ====================
  
  /// 列印控制器狀態（僅用於偵錯）
  void debugPrintState() {
    if (!AppConfig.isDebugMode) return;
    
    print('=== AppController 狀態 ===');
    print('當前分頁索引: ${currentTabIndex.value}');
    print('載入狀態: ${isLoading.value}');
    print('主題模式: ${themeMode.value}');
    print('語言代碼: ${languageCode.value}');
    print('首次啟動: ${isFirstLaunch.value}');
    print('網路連線: ${isConnected.value}');
    print('==========================');
  }
}