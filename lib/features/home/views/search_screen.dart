// features/home/views/search_screen.dart
// 智慧搜尋畫面 - [修正] 修正控制器取得方式
// 功能：提供統一搜尋入口，並允許使用者點擊「建立卡片」後，立即將結果加入儀表板並返回主畫面。

import 'package:flutter/material.dart' hide SearchController;
import 'package:get/get.dart';
import 'package:tell_me/core/theme/app_theme.dart';
import 'package:tell_me/features/home/controllers/app_controller.dart';
import 'package:tell_me/features/home/controllers/search_controller.dart';
import 'package:tell_me/shared/models/feed_models.dart';
import 'package:tell_me/shared/models/search_models.dart';
import 'package:tell_me/shared/widgets/feed/info_post_card.dart';
import 'package:tell_me/shared/widgets/feed/stock_post_card.dart';
import 'package:tell_me/shared/widgets/feed/weather_post_card.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // [修正] 控制器取得方式
    // SearchController 已在 dependency_injection.dart 中被註冊為 lazySingleton。
    // 在這裡我們應該使用 Get.find() 來取得它的實例，而不是重新註冊。
    final SearchController searchController = Get.find<SearchController>();
    final AppController appController = Get.find<AppController>();
    final TextEditingController textEditingController = TextEditingController();

    // 在頁面初次 build 時清空上一次的搜尋結果
    // 使用 addPostFrameCallback 確保在 build 結束後執行
    WidgetsBinding.instance.addPostFrameCallback((_) {
        searchController.clearSearch();
    });

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
              return _buildSuggestionsView(
                  searchController, textEditingController);
            } else {
              return _buildResultsView(searchController, appController);
            }
          }),
        ],
      ),
    );
  }

  Widget _buildLoadingView() =>
      const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));

  Widget _buildSuggestionsView(
      SearchController controller, TextEditingController textController) {
    return SliverPadding(
      padding: const EdgeInsets.all(16.0),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          const Text('熱門搜尋',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: controller.searchSuggestions
                .map((suggestion) => ActionChip(
                      label: Text(suggestion),
                      onPressed: () {
                        textController.text = suggestion;
                        textController.selection = TextSelection.fromPosition(
                            TextPosition(offset: textController.text.length));
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

  Widget _buildResultsView(
      SearchController searchController, AppController appController) {
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
            child: Text(_getGroupTitle(type),
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          ...items.map((item) => _buildResultCard(item, appController)).toList(),
        ],
      ),
    );
  }

  void _handleCreateCard(
      AppController appController, UniversalSearchResult result) {
    appController.addTrackedItem(result);
    Get.back(); // 新增卡片後，自動返回主畫面
  }

  Widget _buildResultCard(
      UniversalSearchResult result, AppController appController) {
    final button = OutlinedButton.icon(
      onPressed: () => _handleCreateCard(appController, result),
      icon: const Icon(Icons.add, size: 18),
      label: const Text('建立卡片'),
    );

    switch (result.type) {
      case SearchResultType.weather:
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: const Icon(Icons.wb_cloudy_outlined,
                color: AppTheme.nearlyBlue),
            title: Text(result.title),
            subtitle: Text(result.subtitle),
            trailing: button,
          ),
        );
      case SearchResultType.stock:
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading:
                const Icon(Icons.show_chart, color: AppTheme.nearlyDarkBlue),
            title: Text(result.title),
            subtitle: Text(result.subtitle),
            trailing: button,
          ),
        );
      case SearchResultType.news:
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: const Icon(Icons.article, color: Colors.orange),
            title: Text(result.title),
            subtitle: Text(result.subtitle),
            trailing: button,
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  String _getGroupTitle(SearchResultType type) {
    switch (type) {
      case SearchResultType.weather:
        return '天氣資訊';
      case SearchResultType.stock:
        return '股市行情';
      case SearchResultType.news:
        return '相關新聞';
      default:
        return '搜尋結果';
    }
  }
}
