// lib/features/home/views/home_screen.dart
// 主畫面 - 使用假資料服務並修正滾動問題
// 功能：採用與training相同的滾動模式，使用假資料服務

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tell_me/core/theme/app_theme.dart';
import 'package:tell_me/core/utils/app_utils.dart';
import 'package:tell_me/features/home/controllers/app_controller.dart';
import 'package:tell_me/shared/services/fake_data_service.dart';
import 'package:tell_me/shared/models/search_models.dart';
import 'package:tell_me/shared/models/topic_model.dart';
import 'package:tell_me/shared/models/weather_models.dart';
import 'package:tell_me/shared/models/feed_models.dart';
import 'package:tell_me/shared/widgets/topic_card.dart';
import 'package:tell_me/shared/widgets/feed/weather_post_card.dart';
import 'package:tell_me/shared/widgets/feed/info_post_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, this.animationController}) : super(key: key);
  final AnimationController? animationController;
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AppController appController = Get.find<AppController>();
  final FakeDataService fakeDataService = FakeDataService();
  final ScrollController scrollController = ScrollController();
  
  double topBarOpacity = 0.0;
  Animation<double>? topBarAnimation;
  List<Widget> listViews = <Widget>[];

  // 主題卡片資料
  final List<TopicCardData> topicCards = [
    const TopicCardData(
      icon: Icons.wb_cloudy_outlined,
      title: '天氣',
      subtitle: '即時氣象預報',
      startColor: Color(0xFF5C9DFF),
      endColor: Color(0xFF4A90E2),
    ),
    const TopicCardData(
      icon: Icons.show_chart,
      title: '股市',
      subtitle: '台美股指追蹤',
      startColor: Color(0xFF50C878),
      endColor: Color(0xFF36A45C),
    ),
    const TopicCardData(
      icon: Icons.article_outlined,
      title: '新聞',
      subtitle: '今日熱門頭條',
      startColor: Color(0xFFFFAA5C),
      endColor: Color(0xFFF9812B),
    ),
  ];

  @override
  void initState() {
    topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: widget.animationController!, curve: const Interval(0, 0.5, curve: Curves.fastOutSlowIn)));
    
    scrollController.addListener(() {
      if (scrollController.offset >= 24) {
        if (topBarOpacity != 1.0) setState(() => topBarOpacity = 1.0);
      } else if (scrollController.offset > 0 && scrollController.offset < 24) {
        setState(() => topBarOpacity = scrollController.offset / 24);
      } else if (scrollController.offset <= 0) {
        if (topBarOpacity != 0.0) setState(() => topBarOpacity = 0.0);
      }
    });
    
    // 建立視圖列表
    _buildAllListData();
    widget.animationController?.forward();
    super.initState();
  }

  /// 建立所有視圖列表（模仿training_screen.dart的模式）
  void _buildAllListData() {
    listViews.clear();
    const int count = 8;

    // 主題儀表板標題
    listViews.add(_buildTitleView('主題儀表板', '', 0, count));
    
    // 主題卡片區域
    listViews.add(_buildTopicCardsView(1, count));
    
    // 即時內容標題
    listViews.add(_buildTitleView('即時內容', '查看全部', 2, count));
    
    // 天氣卡片
    final weatherData = fakeDataService.getFakeWeatherData();
    for (int i = 0; i < weatherData.length; i++) {
      listViews.add(_buildWeatherCardView(weatherData[i], 3 + i, count));
    }
    
    // 新聞卡片  
    final newsData = fakeDataService.getFakeNewsData();
    for (int i = 0; i < newsData.length && i < 2; i++) { // 只顯示前2個新聞
      listViews.add(_buildNewsCardView(newsData[i], 6 + i, count));
    }
    
    // 底部提示
    listViews.add(_buildBottomIndicator(7, count));
  }

  /// 載入資料（模仿training_screen.dart）
  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 50));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: <Widget>[
            // 使用與training相同的主內容結構
            _buildMainListView(),
            _buildAppBar(),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  /// 建立主要清單視圖（完全模仿training_screen.dart）
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
              top: AppBar().preferredSize.height + MediaQuery.of(context).padding.top + 24,
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

  /// 建立標題視圖
  Widget _buildTitleView(String title, String subTitle, int index, int count) {
    final Animation<double> animation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: widget.animationController!, curve: Interval((1 / count) * index, 1.0, curve: Curves.fastOutSlowIn)));
    
    return AnimatedBuilder(
      animation: widget.animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation,
          child: Transform(
            transform: Matrix4.translationValues(0.0, 30 * (1.0 - animation.value), 0.0),
            child: Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 8),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontFamily: AppTheme.fontName,
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        letterSpacing: 0.5,
                        color: AppTheme.lightText,
                      ),
                    ),
                  ),
                  if (subTitle.isNotEmpty)
                    InkWell(
                      highlightColor: Colors.transparent,
                      borderRadius: BorderRadius.all(Radius.circular(4.0)),
                      onTap: () {
                        print('查看全部被點擊');
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Row(
                          children: <Widget>[
                            Text(
                              subTitle,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontFamily: AppTheme.fontName,
                                fontWeight: FontWeight.normal,
                                fontSize: 16,
                                letterSpacing: 0.5,
                                color: AppTheme.nearlyDarkBlue,
                              ),
                            ),
                            SizedBox(
                              height: 38,
                              width: 26,
                              child: Icon(
                                Icons.arrow_forward,
                                color: AppTheme.darkText,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 建立主題卡片視圖
  Widget _buildTopicCardsView(int index, int count) {
    final Animation<double> animation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: widget.animationController!, curve: Interval((1 / count) * index, 1.0, curve: Curves.fastOutSlowIn)));
    
    return AnimatedBuilder(
      animation: widget.animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation,
          child: Transform(
            transform: Matrix4.translationValues(0.0, 30 * (1.0 - animation.value), 0.0),
            child: Container(
              height: 140,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                itemCount: topicCards.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 120,
                    margin: const EdgeInsets.only(right: 16),
                    child: TopicCard(
                      data: topicCards[index],
                      onTap: () => _handleTopicCardTap(topicCards[index]),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  /// 建立天氣卡片視圖
  Widget _buildWeatherCardView(WeatherCardData weatherData, int index, int count) {
    final Animation<double> animation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: widget.animationController!, curve: Interval((1 / count) * index, 1.0, curve: Curves.fastOutSlowIn)));
    
    return AnimatedBuilder(
      animation: widget.animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation,
          child: Transform(
            transform: Matrix4.translationValues(0.0, 30 * (1.0 - animation.value), 0.0),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: WeatherPostCard(
                weatherData: weatherData,
                showCreateButton: true,
                onCreateCard: () => _handleCreateWeatherCard(weatherData),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 建立新聞卡片視圖
  Widget _buildNewsCardView(PostData newsData, int index, int count) {
    final Animation<double> animation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: widget.animationController!, curve: Interval((1 / count) * index, 1.0, curve: Curves.fastOutSlowIn)));
    
    return AnimatedBuilder(
      animation: widget.animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation,
          child: Transform(
            transform: Matrix4.translationValues(0.0, 30 * (1.0 - animation.value), 0.0),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: InfoPostCard(post: newsData),
            ),
          ),
        );
      },
    );
  }

  /// 建立底部指示器
  Widget _buildBottomIndicator(int index, int count) {
    final Animation<double> animation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: widget.animationController!, curve: Interval((1 / count) * index, 1.0, curve: Curves.fastOutSlowIn)));
    
    return AnimatedBuilder(
      animation: widget.animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation,
          child: Transform(
            transform: Matrix4.translationValues(0.0, 30 * (1.0 - animation.value), 0.0),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: AppTheme.nearlyDarkBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.nearlyDarkBlue.withOpacity(0.3)),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: AppTheme.nearlyDarkBlue,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '已到達底部',
                      style: TextStyle(
                        color: AppTheme.nearlyDarkBlue,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '滾動功能正常！',
                      style: TextStyle(
                        color: AppTheme.nearlyDarkBlue.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 處理主題卡片點擊
  void _handleTopicCardTap(TopicCardData topic) {
    Get.snackbar(
      '主題選擇',
      '您選擇了 ${topic.title}，相關內容將優先顯示',
      backgroundColor: AppTheme.nearlyDarkBlue.withOpacity(0.8),
      colorText: AppTheme.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 2),
    );
  }

  /// 處理建立天氣卡片
  void _handleCreateWeatherCard(WeatherCardData weatherData) {
    Get.snackbar(
      '建立成功',
      '已將 ${weatherData.locationName} 天氣加入您的儀表板',
      backgroundColor: AppTheme.nearlyDarkBlue.withOpacity(0.8),
      colorText: AppTheme.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 2),
    );
  }

  /// 建立頂部標題列
  Widget _buildAppBar() {
    return AnimatedBuilder(
      animation: widget.animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: topBarAnimation!,
          child: Transform(
            transform: Matrix4.translationValues(0.0, 30 * (1.0 - topBarAnimation!.value), 0.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.white.withOpacity(topBarOpacity),
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(32.0)),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: AppTheme.grey.withOpacity(0.4 * topBarOpacity),
                      offset: const Offset(1.1, 1.1),
                      blurRadius: 10.0)
                ],
              ),
              child: Column(
                children: <Widget>[
                  SizedBox(height: MediaQuery.of(context).padding.top),
                  Padding(
                    padding: EdgeInsets.only(
                        left: 16, right: 16, top: 16 - 8.0 * topBarOpacity, bottom: 12 - 8.0 * topBarOpacity),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('TELL ME',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontFamily: AppTheme.fontName,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 22 + 6 - 6 * topBarOpacity,
                                    letterSpacing: 1.2,
                                    color: AppTheme.darkerText)),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.notifications_none, color: AppTheme.grey),
                          onPressed: () {
                            // 測試滾動到底部
                            scrollController.animateTo(
                              scrollController.position.maxScrollExtent,
                              duration: const Duration(seconds: 1),
                              curve: Curves.easeInOut,
                            );
                          },
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
    );
  }
}