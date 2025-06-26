// lib/features/search/search_controller.dart
// [錯誤修正 V5.5]
// 功能：恢復此檔案的正確內容，只定義 SearchController 類別，解決命名衝突。

import 'package:get/get.dart';
import 'package:tell_me/core/services/fake_data_service.dart';
import 'package:tell_me/features/search/search_models.dart';
import 'package:tell_me/features/weather/weather_service.dart';
import 'package:tell_me/features/news/news_models.dart';

class SearchController extends GetxController {
  final WeatherService _weatherService = Get.find<WeatherService>();
  final FakeDataService _fakeDataService = Get.find<FakeDataService>();

  final RxBool isLoading = false.obs;
  final RxMap<String, List<UniversalSearchResult>> searchResults = <String, List<UniversalSearchResult>>{}.obs;

  final RxList<String> searchSuggestions = <String>[
    '今日頭條',
    '所有股票',
    '台北 天氣',
    '台中天氣',
    '台南天氣',
    'Nvidia',
    '伊朗',
  ].obs;

  void clearSearch() {
    searchResults.clear();
  }
  
  Future<void> performSearch(String keyword) async {
    if (keyword.trim().isEmpty) return;
    isLoading.value = true;
    searchResults.clear();
    
    await Future.delayed(const Duration(milliseconds: 700));

    final Map<String, List<UniversalSearchResult>> results = {};
    final String cleanedKeyword = keyword.trim();

    if (cleanedKeyword.contains('所有股票')) {
      final fakeStocks = _fakeDataService.getFakeStockListData();
      results['股市'] = fakeStocks.map((stock) => 
        StockSearchResultItem(
          id: 'stock_${stock['symbol']}',
          title: stock['name']!,
          subtitle: stock['symbol']!,
          data: stock,
        )
      ).toList();
    }
    
    if (cleanedKeyword.contains('天氣')) {
      final locationName = cleanedKeyword.replaceAll('天氣', '').trim();
      final weatherLocations = await _weatherService.searchLocations(locationName.isEmpty ? '臺北' : locationName);
      
      final List<UniversalSearchResult> weatherItems = [];
      for (final loc in weatherLocations) {
        final weatherData = await _weatherService.getCompleteWeatherData(loc);
        if (weatherData != null) {
          weatherItems.add(WeatherSearchResultItem(
            id: weatherData.id,
            title: weatherData.locationName,
            subtitle: '${weatherData.currentWeather.temperature.round()}°C，${weatherData.currentWeather.description}',
            data: weatherData,
          ));
        }
      }
      if (weatherItems.isNotEmpty) {
        results['天氣'] = weatherItems;
      }
    }
    
    final List<PostData> fakeNews = _fakeDataService.getFakeNewsListData(cleanedKeyword);
    results['新聞: "$cleanedKeyword"'] = fakeNews.map((news) => 
      NewsSearchResultItem(
        id: 'news_${cleanedKeyword.hashCode}_${news.caption.hashCode}',
        title: news.caption,
        subtitle: news.userName,
        data: news,
        topic: cleanedKeyword,
      )
    ).toList();
    
    searchResults.assignAll(results);
    isLoading.value = false;
  }
}
