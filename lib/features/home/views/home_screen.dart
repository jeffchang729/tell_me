// features/home/views/home_screen.dart
// 主畫面 - [重大修改] 動態載入使用者自訂卡片
// 功能：此版本將清空預設內容，改為監聽 AppController 中的 trackedItems 列表，
//       並動態渲染使用者從搜尋頁建立的卡片。如果列表為空，則顯示引導提示。

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tell_me/core/theme/app_theme.dart';
import 'package:tell_me/features/home/controllers/app_controller.dart';
import 'package:tell_me/shared/models/search_models.dart';
import 'package:tell_me/shared/widgets/feed/info_post_card.dart';
import 'package:tell_me/shared/widgets/feed/stock_post_card.dart';
import 'package:tell_me/shared/widgets/feed/weather_post_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, this.animationController}) : super(key: key);
  final AnimationController? animationController;
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final AppController appController = Get.find<AppController>();
  final ScrollController scrollController = ScrollController();

  Animation<double>? topBarAnimation;
  double topBarOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: widget.animationController!,
            curve: const Interval(0, 0.5, curve: Curves.fastOutSlowIn)));

    scrollController.addListener(() {
      if (scrollController.offset >= 24) {
        if (topBarOpacity != 1.0) setState(() => topBarOpacity = 1.0);
      } else if (scrollController.offset > 0 && scrollController.offset < 24) {
        setState(() => topBarOpacity = scrollController.offset / 24);
      } else if (scrollController.offset <= 0) {
        if (topBarOpacity != 0.0) setState(() => topBarOpacity = 0.0);
      }
    });
    
    widget.animationController?.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: <Widget>[
            // 主內容區域，現在由 Obx 包裹以實現響應式更新
            Obx(() {
              // 檢查是否有已追蹤的卡片
              if (appController.trackedItems.isEmpty) {
                // 如果沒有，顯示引導畫面
                return _buildEmptyState();
              } else {
                // 如果有，建立卡片列表
                return _buildTrackedItemsList();
              }
            }),
            _buildAppBar(),
          ],
        ),
      ),
    );
  }
  
  /// 建立使用者已追蹤卡片的列表
  Widget _buildTrackedItemsList() {
    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.only(
        top: AppBar().preferredSize.height +
            MediaQuery.of(context).padding.top +
            16, // 稍微縮小頂部間距
        bottom: 62 + MediaQuery.of(context).padding.bottom,
      ),
      itemCount: appController.trackedItems.length,
      itemBuilder: (BuildContext context, int index) {
        final item = appController.trackedItems[index];
        
        // 使用動畫讓卡片出現更流暢
        final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: widget.animationController!,
            curve: Interval(
                (1 / appController.trackedItems.length) * index, 1.0,
                curve: Curves.fastOutSlowIn),
          ),
        );

        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) => FadeTransition(
            opacity: animation,
            child: Transform(
              transform: Matrix4.translationValues(
                  0.0, 30 * (1.0 - animation.value), 0.0),
              child: _buildCardForItem(item), // 根據項目類型建立對應卡片
            ),
          ),
        );
      },
    );
  }

  /// 根據項目類型建立對應的卡片 Widget
  Widget _buildCardForItem(UniversalSearchResult item) {
    switch (item.type) {
      case SearchResultType.weather:
        return WeatherPostCard(
          weatherData: item.data, 
          showCreateButton: false, // 在主畫面不需要「建立卡片」按鈕
        );
      case SearchResultType.stock:
        return StockPostCard(
          stockData: item as StockSearchResultItem,
          onRemove: () => appController.removeTrackedItem(item.id),
        );
      case SearchResultType.news:
        // 這裡可以建立一個更詳細的新聞卡片，暫時使用 InfoPostCard
        return InfoPostCard(
          post: item.data, // 假設 item.data 可以轉換為 PostData
        );
      default:
        return Card(
          child: ListTile(
            title: Text('不支援的卡片類型'),
            subtitle: Text(item.title),
          ),
        );
    }
  }

  /// 建立空狀態下的引導畫面
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_outlined,
              size: 80,
              color: AppTheme.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            const Text(
              '您的資訊中心是空的',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkerText,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '點擊下方的 🔍 按鈕，\n開始搜尋您感興趣的天氣、股票或新聞，並建立您的第一張資訊卡片！',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.grey,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 建立 AppBar
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
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'TELL ME',
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
                            IconButton(
                              icon: const Icon(Icons.delete_sweep_outlined,
                                  color: AppTheme.grey),
                              onPressed: () => appController.clearAllTrackedItems(),
                              tooltip: '清除所有卡片 (測試用)',
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
}
