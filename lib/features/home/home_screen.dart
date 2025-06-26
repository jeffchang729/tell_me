// lib/features/home/home_screen.dart
// [體驗重構 V5.4]
// 功能：
// 1. 摘要區恢復為單一的「天氣總覽」卡片。
// 2. 內容區的天氣部分，改為可垂直滾動的區塊列表，每個城市一個區塊。

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide SearchController;
import 'package:get/get.dart';
import 'package:tell_me/core/theme/app_theme.dart';
import 'package:tell_me/features/home/home_controller.dart';
import 'package:tell_me/features/home/home_summary_card.dart';
import 'package:tell_me/features/search/search_controller.dart';
import 'package:tell_me/features/search/search_models.dart';

import 'package:tell_me/features/news/news_post_card.dart';
import 'package:tell_me/features/stock/stock_grid_item.dart';
import 'package:tell_me/features/weather/weather_post_card.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HomeController homeController = Get.find<HomeController>();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('TELL ME', style: Theme.of(context).textTheme.headlineMedium),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Obx(() {
        if (homeController.trackedItems.isEmpty) {
          return _buildSimplifiedEmptyState(context);
        } else {
          return Column(
            children: [
              _buildSummarySection(context, homeController),
              _buildDetailSection(context, homeController),
            ],
          );
        }
      }),
    );
  }

  Widget _buildSummarySection(BuildContext context, HomeController controller) {
    return ScrollConfiguration(
      behavior: MyCustomScrollBehavior(),
      child: SizedBox(
        height: 180,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          children: [
            // [修改] 恢復為單一的天氣總覽卡片
            if (controller.trackedWeathers.isNotEmpty)
              Obx(() => HomeSummaryCard(
                itemType: SearchResultType.weather,
                isSelected: controller.selectedType.value == SearchResultType.weather,
                onTap: () => controller.selectContent(type: SearchResultType.weather),
              )),
            
            // 股市總覽卡
            if (controller.trackedStocks.isNotEmpty)
              Obx(() => HomeSummaryCard(
                itemType: SearchResultType.stock,
                isSelected: controller.selectedType.value == SearchResultType.stock,
                onTap: () => controller.selectContent(type: SearchResultType.stock),
              )),
          
            // 新聞主題卡
            ...controller.trackedNewsTopics.map((topic) {
              return Obx(() => HomeSummaryCard(
                newsTopic: topic,
                isSelected: controller.selectedType.value == SearchResultType.news &&
                              controller.selectedNewsTopic.value == topic,
                onTap: () => controller.selectContent(
                  type: SearchResultType.news,
                  newsTopic: topic,
                ),
              ));
            }).toList(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailSection(BuildContext context, HomeController controller) {
    return Expanded(
      child: Obx(() {
        final type = controller.selectedType.value;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
          child: _buildDetailContent(context, controller, type),
        );
      }),
    );
  }

  Widget _buildDetailContent(BuildContext context, HomeController controller, SearchResultType? type) {
    switch (type) {
      case SearchResultType.weather:
        // [重大修改] 改為可垂直滾動的 ListView，每個城市一個區塊
        return ListView.builder(
          padding: const EdgeInsets.only(top: 16, bottom: 80), // 增加上下邊距
          itemCount: controller.trackedWeathers.length,
          itemBuilder: (context, index) {
            final weatherItem = controller.trackedWeathers[index];
            return WeatherPostCard(
              key: ValueKey(weatherItem.id),
              weatherData: weatherItem.data,
            );
          },
        );

      case SearchResultType.stock:
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.9,
          ),
          itemCount: controller.trackedStocks.length,
          itemBuilder: (context, index) {
            final stockItem = controller.trackedStocks[index] as StockSearchResultItem;
            return StockGridItem(stockData: stockItem);
          },
        );

      case SearchResultType.news:
        final selectedTopic = controller.selectedNewsTopic.value;
        if (selectedTopic == null) return const SizedBox.shrink();
        final relevantNews = controller.trackedNews.where((item) => (item as NewsSearchResultItem).topic == selectedTopic).toList();
        if (relevantNews.isEmpty) return const SizedBox.shrink();
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: relevantNews.length,
          itemBuilder: (context, index) {
            final newsItem = relevantNews[index];
            return NewsPostCard(key: ValueKey(newsItem.id), post: newsItem.data);
          },
        );
        
      default:
        return const SizedBox.shrink();
    }
  }
  
  Widget _buildSimplifiedEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: AppTheme.smartHomeNeumorphic(isConcave: true, radius: 80),
              child: Icon(
                Icons.add_chart_rounded,
                size: 80,
                color: (theme.iconTheme.color ?? AppTheme.smarthome_secondary_text).withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              '您的儀表板是空的',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.textTheme.headlineMedium?.color
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '點擊下方的「搜尋」按鈕\n開始建立您的第一張資訊卡片',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.textTheme.bodyMedium?.color,
                height: 1.7,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => { PointerDeviceKind.touch, PointerDeviceKind.mouse };
}
