// lib/screens/app_container.dart
// 應用程式主容器
// 功能：管理主要的頁面切換和底部導航

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/app_theme.dart';
import '../controllers/app_controller.dart';
import '../widgets/navigation_widgets.dart';
import '../models/tab_icon_data.dart';
import 'home_screen.dart'; // [2024-06-18] 將 diary_screen 改為 home_screen
import 'training_screen.dart';

/// 應用程式主容器
///
/// 負責管理整個應用程式的主要結構，包括：
/// - 底部導航列
/// - 頁面切換
/// - 全域動畫控制
/// - 狀態管理
class AppContainer extends StatefulWidget {
  const AppContainer({Key? key}) : super(key: key);

  @override
  _AppContainerState createState() => _AppContainerState();
}

class _AppContainerState extends State<AppContainer>
    with TickerProviderStateMixin {
  // ==================== 控制器和變數 ====================

  /// 應用程式控制器
  final AppController appController = Get.find<AppController>();

  /// 主要動畫控制器
  AnimationController? animationController;

  /// 目前顯示的頁面內容
  Widget tabBody = Container(
    color: AppTheme.background,
  );

  /// 底部導航圖示清單
  List<TabIconData> tabIconsList = TabIconData.tabIconsList;

  // ==================== 生命週期方法 ====================

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _initializeTabIcons();
    _setInitialPage();
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  // ==================== 初始化方法 ====================

  /// 初始化動畫控制器
  void _initializeAnimation() {
    animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  /// 初始化底部導航圖示
  void _initializeTabIcons() {
    // 重設所有選擇狀態
    for (TabIconData tab in tabIconsList) {
      tab.isSelected = false;
    }

    // 設定第一個分頁為選中狀態
    tabIconsList[0].isSelected = true;
  }

  /// 設定初始頁面
  void _setInitialPage() {
    // 根據控制器中的當前分頁索引設定初始頁面
    final currentIndex = appController.currentTabIndex.value;
    _setPageByIndex(currentIndex);
  }

  // ==================== 頁面切換方法 ====================

  /// 根據索引設定頁面
  void _setPageByIndex(int index) {
    setState(() {
      switch (index) {
        case 0:
        case 2:
          // [2024-06-18] 將 DiaryScreen 改為 HomeScreen
          tabBody = HomeScreen(animationController: animationController);
          break;
        case 1:
        case 3:
          // 訓練頁面（索引1和3都顯示訓練頁面）
          tabBody = TrainingScreen(animationController: animationController);
          break;
        default:
          // [2024-06-18] 將 DiaryScreen 改為 HomeScreen
          tabBody = HomeScreen(animationController: animationController);
      }
    });
  }

  /// 處理分頁切換
  void _handleTabChange(int index) {
    // 更新控制器狀態
    appController.changeTabIndex(index);

    // 播放切換動畫
    animationController?.reverse().then<dynamic>((data) {
      if (!mounted) return;

      // 設定新頁面
      _setPageByIndex(index);

      // 啟動新頁面動畫
      animationController?.forward();
    });
  }

  /// 處理中央加號按鈕點擊
  void _handleAddClick() {
    // 可以在這裡實現添加新記錄的功能
    // 例如：顯示添加餐點、運動記錄的對話框
    _showAddDialog();
  }

  /// 顯示添加選項對話框
  void _showAddDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 標題
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    '新增記錄',
                    style: AppTheme.headline,
                  ),
                ),
                // 選項清單
                _buildAddOption(
                  icon: Icons.restaurant,
                  title: '新增餐點',
                  subtitle: '記錄您的飲食',
                  onTap: () {
                    Navigator.pop(context);
                    _addMealRecord();
                  },
                ),
                _buildAddOption(
                  icon: Icons.fitness_center,
                  title: '新增運動',
                  subtitle: '記錄您的訓練',
                  onTap: () {
                    Navigator.pop(context);
                    _addWorkoutRecord();
                  },
                ),
                _buildAddOption(
                  icon: Icons.local_drink,
                  title: '記錄飲水',
                  subtitle: '增加飲水量',
                  onTap: () {
                    Navigator.pop(context);
                    _addWaterRecord();
                  },
                ),
                _buildAddOption(
                  icon: Icons.monitor_weight,
                  title: '測量體重',
                  subtitle: '記錄身體數據',
                  onTap: () {
                    Navigator.pop(context);
                    _addMeasurementRecord();
                  },
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 建立添加選項項目
  Widget _buildAddOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: AppTheme.nearlyDarkBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: AppTheme.nearlyDarkBlue,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: AppTheme.title,
      ),
      subtitle: Text(
        subtitle,
        style: AppTheme.caption,
      ),
      onTap: onTap,
    );
  }

  // ==================== 添加記錄方法 ====================

  /// 添加餐點記錄
  void _addMealRecord() {
    Get.snackbar(
      '新增餐點',
      '餐點記錄功能開發中...',
      backgroundColor: AppTheme.nearlyDarkBlue.withOpacity(0.8),
      colorText: AppTheme.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  /// 添加運動記錄
  void _addWorkoutRecord() {
    Get.snackbar(
      '新增運動',
      '運動記錄功能開發中...',
      backgroundColor: AppTheme.nearlyDarkBlue.withOpacity(0.8),
      colorText: AppTheme.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  /// 添加飲水記錄
  void _addWaterRecord() {
    Get.snackbar(
      '記錄飲水',
      '已增加 250ml 飲水量',
      backgroundColor: AppTheme.nearlyBlue.withOpacity(0.8),
      colorText: AppTheme.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  /// 添加測量記錄
  void _addMeasurementRecord() {
    Get.snackbar(
      '測量體重',
      '身體測量功能開發中...',
      backgroundColor: AppTheme.nearlyDarkBlue.withOpacity(0.8),
      colorText: AppTheme.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  // ==================== 資料載入方法 ====================

  /// 載入頁面資料
  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    return true;
  }

  // ==================== UI 建構方法 ====================

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: FutureBuilder<bool>(
          future: getData(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (!snapshot.hasData) {
              return _buildLoadingView();
            } else {
              return Stack(
                children: <Widget>[
                  // 主要內容區域
                  tabBody,
                  // 底部導航列
                  _buildBottomBar(),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  /// 建立載入視圖
  Widget _buildLoadingView() {
    return Center(
      child: Container(
        width: 50,
        height: 50,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.nearlyDarkBlue),
          strokeWidth: 3,
        ),
      ),
    );
  }

  /// 建立底部導航列
  Widget _buildBottomBar() {
    return Column(
      children: <Widget>[
        const Expanded(
          child: SizedBox(),
        ),
        BottomBarView(
          tabIconsList: tabIconsList,
          addClick: _handleAddClick,
          changeIndex: _handleTabChange,
        ),
      ],
    );
  }

  // ==================== 偵錯方法 ====================

  /// 列印當前狀態（僅用於偵錯）
  void _debugPrintState() {
    if (appController.isDebugMode) {
      print('=== AppContainer 狀態 ===');
      print('當前分頁索引: ${appController.currentTabIndex.value}');
      print('動畫控制器狀態: ${animationController?.status}');
      print('已載入頁面: ${tabBody.runtimeType}');
      print('========================');
    }
  }
}
