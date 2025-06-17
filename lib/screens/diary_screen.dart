// lib/screens/diary_screen.dart
// 日記頁面
// 功能：顯示飲食記錄、身體測量、飲水追蹤等健康資料

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/app_theme.dart';
import '../controllers/diary_controller.dart';
import '../widgets/common_widgets.dart';
import '../widgets/chart_widgets.dart';
import '../widgets/diary/water_view.dart';
import '../widgets/diary/meals_list_view.dart';

/// 日記頁面
/// 
/// 顯示用戶的健康日記，包括：
/// - 地中海飲食統計
/// - 今日餐點記錄
/// - 身體測量數據
/// - 飲水追蹤
/// - 健康提醒等
class DiaryScreen extends StatefulWidget {
  const DiaryScreen({Key? key, this.animationController}) : super(key: key);

  final AnimationController? animationController;

  @override
  _DiaryScreenState createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen>
    with TickerProviderStateMixin {
  
  // ==================== 控制器和變數 ====================
  
  /// 日記頁面控制器
  final DiaryController diaryController = Get.put(DiaryController());
  
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
    const int count = 9;

    listViews.clear();

    // 地中海飲食標題
    listViews.add(
      TitleView(
        titleTxt: 'Mediterranean diet',
        subTxt: 'Details',
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController!,
            curve:
                Interval((1 / count) * 0, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController!,
      ),
    );

    // 地中海飲食圖表
    listViews.add(
      MediterraneanDietView(
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController!,
            curve:
                Interval((1 / count) * 1, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController!,
      ),
    );

    // 今日餐點標題
    listViews.add(
      TitleView(
        titleTxt: 'Meals today',
        subTxt: 'Customize',
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController!,
            curve:
                Interval((1 / count) * 2, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController!,
      ),
    );

    // 餐點清單
    listViews.add(
      MealsListView(
        mainScreenAnimation: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
                parent: widget.animationController!,
                curve: Interval((1 / count) * 3, 1.0,
                    curve: Curves.fastOutSlowIn))),
        mainScreenAnimationController: widget.animationController,
      ),
    );

    // 身體測量標題
    listViews.add(
      TitleView(
        titleTxt: 'Body measurement',
        subTxt: 'Today',
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController!,
            curve:
                Interval((1 / count) * 4, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController!,
      ),
    );

    // 身體測量視圖
    listViews.add(
      BodyMeasurementView(
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController!,
            curve:
                Interval((1 / count) * 5, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController!,
      ),
    );

    // 飲水標題
    listViews.add(
      TitleView(
        titleTxt: 'Water',
        subTxt: 'Aqua SmartBottle',
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController!,
            curve:
                Interval((1 / count) * 6, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController!,
      ),
    );

    // 飲水視圖
    listViews.add(
      WaterView(
        mainScreenAnimation: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
                parent: widget.animationController!,
                curve: Interval((1 / count) * 7, 1.0,
                    curve: Curves.fastOutSlowIn))),
        mainScreenAnimationController: widget.animationController!,
      ),
    );

    // 玻璃杯提醒
    listViews.add(
      GlassView(
          animation: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                  parent: widget.animationController!,
                  curve: Interval((1 / count) * 8, 1.0,
                      curve: Curves.fastOutSlowIn))),
          animationController: widget.animationController!),
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
                                  'My Diary',
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
                              onTap: () => diaryController.goToPreviousDay(),
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
                                  Obx(() => Text(
                                    diaryController.getFormattedDate(),
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontFamily: AppTheme.fontName,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 18,
                                      letterSpacing: -0.2,
                                      color: AppTheme.darkerText,
                                    ),
                                  )),
                                ],
                              ),
                            ),
                            // 右箭頭按鈕
                            _buildNavigationButton(
                              icon: Icons.keyboard_arrow_right,
                              onTap: () => diaryController.goToNextDay(),
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
  
  /// 處理刷新操作
  Future<void> _handleRefresh() async {
    await diaryController.refreshData();
    _buildAllListData();
    setState(() {});
  }

  /// 處理日期選擇
  void _handleDateSelection() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: diaryController.selectedDate.value,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.nearlyDarkBlue,
              onPrimary: AppTheme.white,
              surface: AppTheme.white,
              onSurface: AppTheme.darkerText,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != diaryController.selectedDate.value) {
      diaryController.selectDate(picked);
      _buildAllListData();
      setState(() {});
    }
  }
}