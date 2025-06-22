// features/home/views/search_screen.dart
// 智慧搜尋畫面 - 實作新流程
// 功能：提供統一搜尋入口，並允許使用者點擊「建立卡片」後，立即將結果加入儀表板並返回主畫面。

import 'package:flutter/material.dart' hide SearchController;
import 'package:get/get.dart';
import 'package:tell_me/core/theme/app_theme.dart';
import 'package:tell_me/features/home/controllers/app_controller.dart';
import 'package:tell_me/features/home/controllers/search_controller.dart';
import 'package:tell_me/shared/models/search_models.dart';
import 'package:tell_me/shared/widgets/feed/weather_post_card.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SearchController searchController = Get.put(SearchController());
    final AppController appController = Get.find<AppController>();
    final TextEditingController textEditingController = TextEditingController();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppTheme.white,
            pinned: true,
            title: TextField(
              controller: textEditingController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: '搜尋天氣、股票、新聞...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: AppTheme.grey.withOpacity(0.8)),
              ),
              onSubmitted: (value) => searchController.performSearch(value),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.clear, color: AppTheme.grey),
                onPressed: () {
                  textEditingController.clear();
                  searchController.clearSearch();
                },
              )
            ],
          ),
          Obx(() {
            if (searchController.isLoading.value) {
              return _buildLoadingView();
            } else if (searchController.searchResults.isEmpty) {
              return _buildSuggestionsView(searchController, textEditingController);
            } else {
              return _buildResultsView(searchController, appController);
            }
          }),
        ],
      ),
    );
  }

  Widget _buildLoadingView() => const SliverFillRemaining(
      child: Center(child: CircularProgressIndicator()));

  Widget _buildSuggestionsView(
      SearchController controller, TextEditingController textController) {
    return SliverPadding(
      padding: const EdgeInsets.all(16.0),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          const Text('熱門搜尋', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: controller.searchSuggestions
                .map((suggestion) => ActionChip(
                      label: Text(suggestion),
                      onPressed: () {
                        textController.text = suggestion;
                        controller.performSearch(suggestion);
                      },
                      backgroundColor: AppTheme.white,
                    ))
                .toList(),
          ),
        ]),
      ),
    );
  }

  Widget _buildResultsView(SearchController searchController, AppController appController) {
    final groupedResults = <SearchResultType, List<UniversalSearchResult>>{};
    for (var result in searchController.searchResults) {
      (groupedResults[result.type] ??= []).add(result);
    }
    
    final sortedKeys = groupedResults.keys.toList()
      ..sort((a, b) => (groupedResults[b]!.first.relevance)
          .compareTo(groupedResults[a]!.first.relevance));

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final type = sortedKeys[index];
          final items = groupedResults[type]!;
          return _buildResultGroup(type, items, appController);
        },
        childCount: sortedKeys.length,
      ),
    );
  }

  Widget _buildResultGroup(SearchResultType type,
      List<UniversalSearchResult> items, AppController appController) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(_getGroupTitle(type), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          ...items.map((item) => _buildResultCard(item, appController)).toList(),
        ],
      ),
    );
  }

  /// [修改] 處理建立卡片的邏輯
  void _handleCreateCard(AppController appController, UniversalSearchResult result) {
    appController.addTrackedItem(result);
    Get.back(); // 返回主畫面
  }

  Widget _buildResultCard(UniversalSearchResult result, AppController appController) {
    switch (result.type) {
      case SearchResultType.weather:
        return WeatherPostCard(
          weatherData: result.data,
          onCreateCard: () => _handleCreateCard(appController, result),
        );
      case SearchResultType.stock:
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: const Icon(Icons.show_chart, color: AppTheme.nearlyBlue),
            title: Text(result.title),
            subtitle: Text(result.subtitle),
            trailing: OutlinedButton(
              onPressed: () => _handleCreateCard(appController, result),
              child: const Text('建立卡片'), // [修改] 按鈕文字
            ),
          ),
        );
      case SearchResultType.news:
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: const Icon(Icons.article, color: AppTheme.nearlyDarkBlue),
            title: Text(result.title),
            subtitle: Text(result.subtitle),
             trailing: OutlinedButton(
              onPressed: () => _handleCreateCard(appController, result),
              child: const Text('建立卡片'), // [修改] 按鈕文字
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  String _getGroupTitle(SearchResultType type) {
    switch (type) {
      case SearchResultType.weather: return '天氣資訊';
      case SearchResultType.stock: return '股市行情';
      case SearchResultType.news: return '相關新聞';
      default: return '搜尋結果';
    }
  }
}
