// lib/features/search/search_screen.dart
// [錯誤修正 V5.5]
// 功能：
// 1. 修正 import 路徑。
// 2. 透過 `hide` 關鍵字，明確消除與 Material 函式庫的命名衝突。

import 'package:flutter/material.dart' hide SearchController; // [修改] 隱藏 Material 的 SearchController
import 'package:get/get.dart';
import 'package:tell_me/core/theme/app_theme.dart';
import 'package:tell_me/features/home/home_controller.dart';
import 'package:tell_me/features/search/search_controller.dart'; // [修正] 確保 SearchController 從這裡導入
import 'package:tell_me/features/search/search_models.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // [驗證] Get.find 現在可以正確找到 SearchController 的實例
    final SearchController searchController = Get.find<SearchController>();
    final HomeController homeController = Get.find<HomeController>();
    final TextEditingController textEditingController = TextEditingController();
    final theme = Theme.of(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
        searchController.clearSearch();
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: _buildSearchBar(context, textEditingController, searchController),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Obx(() {
        if (searchController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (searchController.searchResults.isEmpty) {
          return _buildSuggestionsView(searchController, textEditingController, context);
        } else {
          return _buildResultsView(searchController, homeController, context);
        }
      }),
    );
  }

  // ... (其餘 Widget build 方法維持不變) ...
  Widget _buildSearchBar(BuildContext context, TextEditingController controller, SearchController searchController) {
    final theme = Theme.of(context);
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: AppTheme.smartHomeNeumorphic(isConcave: true, radius: 24),
      child: TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(
          hintText: '搜尋「所有股票」或「台北天氣」...',
          border: InputBorder.none,
          hintStyle: theme.textTheme.bodyMedium,
        ),
        style: theme.textTheme.bodyLarge,
        onSubmitted: (value) => searchController.performSearch(value),
      ),
    );
  }

  Widget _buildResultsView(SearchController searchController, HomeController homeController, BuildContext context) {
    final groupKeys = searchController.searchResults.keys.toList();
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: groupKeys.length,
      itemBuilder: (context, index) {
        final groupTitle = groupKeys[index];
        final items = searchController.searchResults[groupTitle]!;
        return _buildResultGroup(context, groupTitle, items, homeController);
      },
    );
  }

  Widget _buildResultGroup(BuildContext context, String title, List<UniversalSearchResult> items, HomeController homeController) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineSmall),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                  label: const Text('全部加入'),
                  onPressed: () {
                    homeController.addTrackedItems(items);
                    homeController.changeTabIndex(0);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          ...items.map((item) => _buildResultCard(context, item, homeController)).toList(),
        ],
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, UniversalSearchResult item, HomeController homeController) {
    return _SearchResultItemCard(
      item: item,
      onAdd: () {
        homeController.addTrackedItems([item]);
        Get.snackbar(
          '已加入儀表板', 
          '"${item.title}" 已成功加入。',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.primaryColor,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
          borderRadius: 12,
        );
      },
    );
  }
  
  Widget _buildSuggestionsView(SearchController controller, TextEditingController textController, BuildContext context) { 
    final theme = Theme.of(context); 
    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        Text('熱門搜尋', style: theme.textTheme.titleLarge), 
        const SizedBox(height: 16), 
        Wrap( 
          spacing: 12.0, 
          runSpacing: 12.0, 
          children: controller.searchSuggestions.map((suggestion) { 
            return GestureDetector( 
              onTap: () { 
                textController.text = suggestion; 
                textController.selection = TextSelection.fromPosition(TextPosition(offset: textController.text.length)); 
                controller.performSearch(suggestion); 
              }, 
              child: Container( 
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), 
                decoration: AppTheme.smartHomeNeumorphic(radius: 20), 
                child: Text(suggestion, style: theme.textTheme.labelLarge), 
              ), 
            ); 
          }).toList(), 
        ), 
      ],
    ); 
  }
}

class _SearchResultItemCard extends StatelessWidget {
  final UniversalSearchResult item;
  final VoidCallback onAdd;

  const _SearchResultItemCard({
    Key? key,
    required this.item,
    required this.onAdd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: AppTheme.smartHomeNeumorphic(radius: 15),
        child: Row(
          children: [
            Icon(
              _getIconForType(item.type),
              color: theme.iconTheme.color,
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onAdd,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: AppTheme.smartHomeNeumorphic(radius: 20),
                child: Icon(
                  Icons.add_rounded,
                  color: theme.primaryColor,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(SearchResultType type) {
    switch (type) {
      case SearchResultType.weather:
        return Icons.wb_cloudy_outlined;
      case SearchResultType.stock:
        return Icons.show_chart_rounded;
      case SearchResultType.news:
        return Icons.article_outlined;
      default:
        return Icons.help_outline_rounded;
    }
  }
}
