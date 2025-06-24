// features/home/views/home_screen.dart
// 主畫面 - [修正] 解決 UnimplementedError
// 功能：修正 TopicCard 的建立方式，並加入更穩健的錯誤處理。

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tell_me/core/theme/app_theme.dart';
import 'package:tell_me/features/home/controllers/app_controller.dart';
import 'package:tell_me/shared/models/search_models.dart';
import 'package:tell_me/shared/widgets/feed/info_post_card.dart';
import 'package:tell_me/shared/widgets/feed/stock_post_card.dart';
import 'package:tell_me/shared/widgets/feed/weather_post_card.dart';
import 'package:tell_me/shared/widgets/topic_card.dart';
import 'package:tell_me/shared/models/topic_model.dart';


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
            Obx(() {
              if (appController.trackedItems.isEmpty) {
                return _buildEmptyState();
              } else {
                return _buildContentView();
              }
            }),
            _buildAppBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildContentView() {
    final uniqueTypes = appController.trackedItems.map((item) => item.type).toSet().toList();

    return ListView(
      controller: scrollController,
      padding: EdgeInsets.only(
        top: AppBar().preferredSize.height +
            MediaQuery.of(context).padding.top +
            16,
        bottom: 62 + MediaQuery.of(context).padding.bottom,
      ),
      children: [
        _buildTopicFilterSection(uniqueTypes),
        const SizedBox(height: 16),
        _buildLiveContentSection(),
      ],
    );
  }
  
  Widget _buildTopicFilterSection(List<SearchResultType> types) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Text('卡片區', style: AppTheme.title),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: types.length,
            itemBuilder: (context, index) {
              final type = types[index];
              return Obx(() {
                  final isSelected = appController.selectedTopicType.value == type;
                  return _buildTopicCard(type, isSelected);
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLiveContentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Text('即時內容區', style: AppTheme.title),
        ),
        Obx(() {
           return AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            child: Column(
              key: ValueKey(appController.selectedTopicType.value),
              children: appController.filteredTrackedItems.isEmpty
                  ? [
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text('此類別沒有卡片', style: TextStyle(color: AppTheme.grey)),
                        ),
                      )
                    ]
                  : appController.filteredTrackedItems.map((item) {
                      try {
                        return _buildCardForItem(item);
                      } catch (e, s) {
                        print('❌ 建構卡片時發生錯誤: $e');
                        print(s);
                        return _buildErrorCard(item.id);
                      }
                    }).toList(),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTopicCard(SearchResultType type, bool isSelected) {
    final cardData = _mapTypeToTopicCardData(type);
    
    return Container(
      width: 120,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        opacity: isSelected ? 1.0 : 0.65,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          transform: isSelected ? (Matrix4.identity()..translate(0, -5, 0)) : Matrix4.identity(),
          transformAlignment: Alignment.center,
          child: TopicCard(
            data: cardData,
            onTap: () => appController.selectTopic(type),
          ),
        ),
      ),
    );
  }

  Widget _buildCardForItem(UniversalSearchResult item) {
    final cardKey = ValueKey(item.id);
    switch (item.type) {
      case SearchResultType.weather:
        return WeatherPostCard(
          key: cardKey,
          weatherData: item.data,
          showCreateButton: false,
          onRemove: () => appController.removeTrackedItem(item.id),
        );
      case SearchResultType.stock:
        return StockPostCard(
          key: cardKey,
          stockData: item as StockSearchResultItem,
          onRemove: () => appController.removeTrackedItem(item.id),
        );
      case SearchResultType.news:
        return InfoPostCard(
          key: cardKey,
          post: item.data,
          onRemove: () => appController.removeTrackedItem(item.id),
        );
      default:
         // 直接拋出錯誤，讓我們知道有未處理的類型
        throw UnimplementedError('尚未實作此卡片類型: ${item.type}');
    }
  }

  /// 當卡片建構失敗時，顯示一個錯誤提示卡片
  Widget _buildErrorCard(String id) {
    return Card(
      key: ValueKey('error_$id'),
      color: Colors.red[100],
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(Icons.error_outline, color: Colors.red[700]),
        title: Text('卡片載入失敗', style: TextStyle(color: Colors.red[900])),
        subtitle: const Text('請嘗試移除此卡片後再重新建立'),
        trailing: IconButton(
          icon: Icon(Icons.delete_forever, color: Colors.red[700]),
          onPressed: () => appController.removeTrackedItem(id),
        ),
      ),
    );
  }

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
              style: AppTheme.headline,
            ),
            const SizedBox(height: 12),
            const Text(
              '點擊下方的 🔍 按鈕，\n開始搜尋您感興趣的天氣、股票或新聞，並建立您的第一張資訊卡片！',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16, color: AppTheme.grey, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

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

  /// [修正] 移除 subtitle，因為 TopicCard 不再需要它
  TopicCardData _mapTypeToTopicCardData(SearchResultType type) {
    switch (type) {
      case SearchResultType.weather:
        return const TopicCardData(
          icon: Icons.wb_cloudy_outlined,
          title: '天氣',
          startColor: Color(0xFF2E7CF6),
          endColor: Color(0xFF6A88E5),
        );
      case SearchResultType.stock:
        return const TopicCardData(
          icon: Icons.show_chart,
          title: '股市',
          startColor: Color(0xFF42E695),
          endColor: Color(0xFF36A45C),
        );
      case SearchResultType.news:
        return const TopicCardData(
          icon: Icons.article_outlined,
          title: '新聞',
          startColor: Color(0xFFFFB25E),
          endColor: Color(0xFFF9812B),
        );
      default:
        // 對於未知的類型，返回一個通用的樣式
        return const TopicCardData(
          icon: Icons.help_outline,
          title: '其他',
          startColor: Colors.grey,
          endColor: Colors.blueGrey,
        );
    }
  }
}
