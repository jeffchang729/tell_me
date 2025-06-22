// features/home/controllers/search_controller.dart
// 智慧搜尋控制器 - 修正版
// 功能：作為統一搜尋入口的大腦，負責接收關鍵字、調度多個服務、整合並分類搜尋結果。

import 'package:get/get.dart';
import 'package:tell_me/core/config/app_config.dart';
import 'package:tell_me/shared/models/search_models.dart';
import 'package:tell_me/shared/services/weather_service.dart';

class SearchController extends GetxController {
  final WeatherService _weatherService = Get.find<WeatherService>();

  final RxString keyword = ''.obs;
  final RxBool isLoading = false.obs;
  final RxList<String> searchSuggestions = <String>[
    '台北 天氣', '台積電', 'AI 新聞', 'Nvidia 股價', '颱風動態'
  ].obs;
  final RxList<UniversalSearchResult> searchResults = <UniversalSearchResult>[].obs;

  Future<void> performSearch(String query) async {
    if (query.trim().isEmpty) {
      clearSearch();
      return;
    }

    keyword.value = query;
    isLoading.value = true;
    searchResults.clear();

    try {
      final results = await Future.wait([
        _searchWeather(query),
        _searchStocks(query),
        _searchNews(query),
      ]);
      
      final allResults = results.expand((list) => list).toList();
      allResults.sort((a, b) => b.relevance.compareTo(a.relevance));
      searchResults.assignAll(allResults);

    } catch (e) {
      print('執行搜尋時發生錯誤: $e');
      Get.snackbar('搜尋失敗', '無法完成搜尋，請稍後再試。');
    } finally {
      isLoading.value = false;
    }
  }

  void clearSearch() {
    keyword.value = '';
    searchResults.clear();
    isLoading.value = false;
  }

  Future<List<UniversalSearchResult>> _searchWeather(String query) async {
    final List<UniversalSearchResult> results = [];
    if (query.contains('天氣') || AppConfig.taiwanCities.any((city) => query.contains(city['name']!))) {
      final locations = await _weatherService.searchLocations(query);
      for (final location in locations) {
        final weatherData = await _weatherService.getCompleteWeatherData(location);
        if (weatherData != null) {
          results.add(
            WeatherSearchResultItem(
              id: weatherData.id,
              title: '${weatherData.locationName} 天氣預報',
              subtitle: '目前溫度: ${weatherData.currentWeather.temperature}°C，${weatherData.currentWeather.description}',
              data: weatherData,
            )
          );
        }
      }
    }
    return results;
  }
  
  Future<List<UniversalSearchResult>> _searchStocks(String query) async {
    final List<UniversalSearchResult> results = [];
    if (query.contains('台積電') || query.toLowerCase().contains('tsmc') || query.contains('2330')) {
      results.add(
        StockSearchResultItem(
          id: 'stock_2330',
          title: '台積電 (2330)',
          subtitle: '股價: \$920.0 TWD (+2.5%)',
          data: {'ticker': '2330', 'price': 920.0},
        )
      );
    }
    return Future.value(results);
  }
  
  Future<List<UniversalSearchResult>> _searchNews(String query) async {
    final List<UniversalSearchResult> results = [];
    if (query.contains('新聞') || query.contains('AI')) {
       results.add(
        NewsSearchResultItem(
          id: 'news_ai_1',
          title: 'AI 趨勢分析：大型語言模型的未來發展',
          subtitle: '來源: 科技新報 - 2 小時前',
          data: {'url': '...'},
        )
      );
    }
    return Future.value(results);
  }
}
