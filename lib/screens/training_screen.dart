// lib/screens/training_screen.dart
// 訓練頁面
// 功能：顯示運動計劃、訓練記錄、焦點區域等訓練相關資料

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/app_theme.dart';
import '../controllers/training_controller.dart';
import '../widgets/common_widgets.dart';
import '../widgets/training/area_list_view.dart';
import 'dart:async';

/// 訓練頁面
/// 
/// 顯示用戶的訓練記錄，包括：
/// - 運動計劃
/// - 訓練進度
/// - 激勵資訊
/// - 運動焦點區域
/// - 訓練統計等
class TrainingScreen extends StatefulWidget {
  const TrainingScreen({Key? key, this.animationController}) : super(key: key);

  final AnimationController? animationController;

  @override
  _TrainingScreenState createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen>
    with TickerProviderStateMixin {
  
  // ==================== 控制器和變數 ====================
  
  /// 訓練頁面控制器
  final TrainingController trainingController = Get.put(TrainingController());
  
  /// 頂部標題列動畫
  Animation<double>? topBarAnimation;
  
  /// 頁面元件清單
  List<Widget> listViews = <Widget>[];
  
  /// 滾動控制器
  late ScrollController scrollController;
  
  /// 頂部標題列透明度
  double topBarOpacity = 0.0;

  // ==================== 生命週期方法 ====================
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeScrollController();
    _buildAllListData();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  // ==================== 初始化方法 ====================
  
  /// 初始化動畫
  void _initializeAnimations() {
    topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: widget.animationController!,
            curve: Interval(0, 0.5, curve: Curves.fastOutSlowIn)));
  }

  /// 初始化滾動控制器
  void _initializeScrollController() {
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);
  }

  /// 滾動監聽器
  void _onScroll() {
    if (scrollController.offset >= 24) {
      if (topBarOpacity != 1.0) {
        setState(() {
          topBarOpacity = 1.0;
        });
      }
    } else if (scrollController.offset <= 24 &&
        scrollController.offset >= 0) {
      if (topBarOpacity != scrollController.offset / 24) {
        setState(() {
          topBarOpacity = scrollController.offset / 24;
        });
      }
    } else if (scrollController.offset <= 0) {
      if (topBarOpacity != 0.0) {
        setState(() {
          topBarOpacity = 0.0;
        });
      }
    }
  }

  // ==================== 建立頁面內容 ====================
  
  /// 建立所有清單資料
  void _buildAllListData() {
    const int count = 5;

    listViews.clear();

    // 運動計劃標題
    listViews.add(
      TitleView(
        titleTxt: 'Your program',
        subTxt: 'Details',
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController!,
            curve:
                Interval((1 / count) * 0, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController!,
      ),
    );

    // 運動計劃卡片
    listViews.add(
      WorkoutView(
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController!,
            curve:
                Interval((1 / count) * 2, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController!,
      ),
    );

    // 激勵資訊卡片
    listViews.add(
      RunningView(
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController!,
            curve:
                Interval((1 / count) * 3, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController!,
      ),
    );

    // 焦點區域標題
    listViews.add(
      TitleView(
        titleTxt: 'Area of focus',
        subTxt: 'more',
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController!,
            curve:
                Interval((1 / count) * 4, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController!,
      ),
    );

    // 焦點區域網格
    listViews.add(
      AreaListView(
        mainScreenAnimation: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
                parent: widget.animationController!,
                curve: Interval((1 / count) * 5, 1.0,
                    curve: Curves.fastOutSlowIn))),
        mainScreenAnimationController: widget.animationController!,
      ),
    );
  }

  // ==================== 資料載入方法 ====================
  
  /// 載入頁面資料
  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 50));
    return true;
  }

  // ==================== UI 建構方法 ====================
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: <Widget>[
            // 主要內容清單
            _buildMainListView(),
            // 頂部標題列
            _buildAppBar(),
            // 底部安全區域
            SizedBox(
              height: MediaQuery.of(context).padding.bottom,
            )
          ],
        ),
      ),
    );
  }

  /// 建立主要清單視圖
  Widget _buildMainListView() {
    return FutureBuilder<bool>(
      future: getData(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (!snapshot.hasData) {
          return _buildLoadingView();
        } else {
          return ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.only(
              top: AppBar().preferredSize.height +
                  MediaQuery.of(context).padding.top +
                  24,
              bottom: 62 + MediaQuery.of(context).padding.bottom,
            ),
            itemCount: listViews.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, int index) {
              widget.animationController?.forward();
              return listViews[index];
            },
          );
        }
      },
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

  /// 建立頂部標題列
  Widget _buildAppBar() {
    return Column(
      children: <Widget>[
        AnimatedBuilder(
          animation: widget.animationController!,
          builder: (BuildContext context, Widget? child) {
            return FadeTransition(
              opacity: topBarAnimation!,
              child: Transform(
                transform: Matrix4.translationValues(
                    0.0, 30 * (1.0 - topBarAnimation!.value), 0.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.white.withOpacity(topBarOpacity),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32.0),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: AppTheme.grey.withOpacity(0.4 * topBarOpacity),
                          offset: const Offset(1.1, 1.1),
                          blurRadius: 10.0),
                    ],
                  ),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).padding.top,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 16 - 8.0 * topBarOpacity,
                            bottom: 12 - 8.0 * topBarOpacity),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            // 標題
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Training',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontFamily: AppTheme.fontName,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 22 + 6 - 6 * topBarOpacity,
                                    letterSpacing: 1.2,
                                    color: AppTheme.darkerText,
                                  ),
                                ),
                              ),
                            ),
                            // 左箭頭按鈕
                            _buildNavigationButton(
                              icon: Icons.keyboard_arrow_left,
                              onTap: () => _handlePreviousDay(),
                            ),
                            // 日期顯示
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 8,
                                right: 8,
                              ),
                              child: Row(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Icon(
                                      Icons.calendar_today,
                                      color: AppTheme.grey,
                                      size: 18,
                                    ),
                                  ),
                                  Text(
                                    '15 May',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontFamily: AppTheme.fontName,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 18,
                                      letterSpacing: -0.2,
                                      color: AppTheme.darkerText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // 右箭頭按鈕
                            _buildNavigationButton(
                              icon: Icons.keyboard_arrow_right,
                              onTap: () => _handleNextDay(),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        )
      ],
    );
  }

  /// 建立導航按鈕
  Widget _buildNavigationButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 38,
      width: 38,
      child: InkWell(
        highlightColor: Colors.transparent,
        borderRadius: const BorderRadius.all(Radius.circular(32.0)),
        onTap: onTap,
        child: Center(
          child: Icon(
            icon,
            color: AppTheme.grey,
          ),
        ),
      ),
    );
  }

  // ==================== 互動處理方法 ====================
  
  /// 處理上一天
  void _handlePreviousDay() {
    // 實現上一天的邏輯
    Get.snackbar(
      '日期切換',
      '切換到上一天',
      backgroundColor: AppTheme.nearlyDarkBlue.withOpacity(0.8),
      colorText: AppTheme.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.all(16),
      borderRadius: 8,
      duration: Duration(seconds: 1),
    );
  }

  /// 處理下一天
  void _handleNextDay() {
    // 實現下一天的邏輯
    Get.snackbar(
      '日期切換',
      '切換到下一天',
      backgroundColor: AppTheme.nearlyDarkBlue.withOpacity(0.8),
      colorText: AppTheme.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.all(16),
      borderRadius: 8,
      duration: Duration(seconds: 1),
    );
  }

  /// 處理刷新操作
  Future<void> _handleRefresh() async {
    await trainingController.refreshData();
    _buildAllListData();
    setState(() {});
  }

  /// 處理運動計劃點擊
  void _handleWorkoutPlanTap() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // 標題列
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.nearlyDarkBlue,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '運動計劃詳情',
                        style: AppTheme.headline.copyWith(
                          color: AppTheme.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: AppTheme.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // 內容區域
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Legs Toning and Glutes Workout at Home',
                        style: AppTheme.title,
                      ),
                      SizedBox(height: 16),
                      _buildWorkoutDetail('時間', '68 分鐘'),
                      _buildWorkoutDetail('難度', '中等'),
                      _buildWorkoutDetail('類型', '肌力訓練'),
                      _buildWorkoutDetail('器材', '無需器材'),
                      SizedBox(height: 24),
                      Text(
                        '運動內容：',
                        style: AppTheme.subtitle,
                      ),
                      SizedBox(height: 8),
                      Text(
                        '• 深蹲 - 3組 x 15次\n'
                        '• 臀橋 - 3組 x 20次\n'
                        '• 弓箭步 - 3組 x 12次 (每邊)\n'
                        '• 側躺抬腿 - 3組 x 15次 (每邊)\n'
                        '• 平板支撐 - 3組 x 30秒',
                        style: AppTheme.body1,
                      ),
                      Spacer(),
                      // 開始運動按鈕
                      Container(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            trainingController.startWorkout();
                            _showWorkoutTimer();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.nearlyDarkBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            '開始運動',
                            style: TextStyle(
                              color: AppTheme.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 建立運動詳情項目
  Widget _buildWorkoutDetail(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 80,
            child: Text(
              '$label：',
              style: AppTheme.body2.copyWith(
                color: AppTheme.grey,
              ),
            ),
          ),
          Text(
            value,
            style: AppTheme.body1,
          ),
        ],
      ),
    );
  }

  /// 顯示運動計時器
  void _showWorkoutTimer() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('運動中'),
          content: Obx(() => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                trainingController.getFormattedWorkoutTime(),
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.nearlyDarkBlue,
                ),
              ),
              SizedBox(height: 16),
              Text(
                trainingController.getWorkoutStatusText(),
                style: AppTheme.body1,
              ),
            ],
          )),
          actions: [
            TextButton(
              onPressed: () {
                trainingController.pauseWorkout();
              },
              child: Text('暫停'),
            ),
            TextButton(
              onPressed: () {
                trainingController.stopWorkout();
                Navigator.pop(context);
                Get.snackbar(
                  '運動完成',
                  '太棒了！您已完成今天的運動',
                  backgroundColor: AppTheme.nearlyDarkBlue.withOpacity(0.8),
                  colorText: AppTheme.white,
                  snackPosition: SnackPosition.BOTTOM,
                  margin: EdgeInsets.all(16),
                  borderRadius: 8,
                );
              },
              child: Text('結束'),
            ),
          ],
        );
      },
    );
  }

  // ==================== 偵錯方法 ====================
  
  /// 列印當前狀態（僅用於偵錯）
  void _debugPrintState() {
    print('=== TrainingScreen 狀態 ===');
    print('滾動位置: ${scrollController.offset}');
    print('頂部透明度: $topBarOpacity');
    print('動畫控制器狀態: ${widget.animationController?.status}');
    print('==========================');
  }
}