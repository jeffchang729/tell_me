// features/home/controllers/search_controller.dart
// 智慧搜尋控制器 - [修正] 修正新聞搜尋結果的資料型別問題

import 'dart:math';
import 'package:get/get.dart';
import 'package:tell_me/core/config/app_config.dart';
import 'package:tell_me/shared/models/feed_models.dart';
import 'package:tell_me/shared/models/search_models.dart';
import 'package:tell_me/shared/models/weather_models.dart';
import 'package:tell_me/shared/services/fake_data_service.dart';
import 'package:tell_me/shared/services/weather_service.dart';

class SearchController extends GetxController {
  final WeatherService _weatherService = Get.find<WeatherService>();
  final FakeDataService _fakeDataService = FakeDataService();
  final Random _random = Random();

  final RxString keyword = ''.obs;
  final RxBool isLoading = false.obs;
  final RxList<String> searchSuggestions = <String>[
    '台北 天氣', '台積電', 'AI 新聞', 'Nvidia 股價', '颱風動態'
  ].obs;
  final RxList<UniversalSearchResult> searchResults =
      <UniversalSearchResult>[].obs;

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
    if (!query.contains('天氣') &&
        !AppConfig.taiwanCities.any((city) => query.contains(city['name']!))) {
      return [];
    }
    try {
      if (_random.nextDouble() < 0.2) {
        throw Exception("模擬天氣 API 網路連線失敗");
      }
      print("天氣：嘗試呼叫真實 API...");
      final locations = await _weatherService.searchLocations(query);
      if (locations.isEmpty) return [];
      final weatherData =
          await _weatherService.getCompleteWeatherData(locations.first);
      if (weatherData != null) {
        return [
          WeatherSearchResultItem(
            id: weatherData.id,
            title: '${weatherData.locationName} 天氣預報',
            subtitle:
                '目前溫度: ${weatherData.currentWeather.temperature.round()}°C，${weatherData.currentWeather.description}',
            data: weatherData,
          )
        ];
      }
      return [];
    } catch (e) {
      print("天氣：真實 API 失敗，啟用後備方案...");
      final fakeWeather = _fakeDataService.getFakeWeatherData().first;
      return [
        WeatherSearchResultItem(
          id: fakeWeather.id,
          title: '${fakeWeather.locationName} 天氣預報 (假資料)',
          subtitle:
              '目前溫度: ${fakeWeather.currentWeather.temperature.round()}°C，${fakeWeather.currentWeather.description}',
          data: fakeWeather,
        )
      ];
    }
  }

  Future<List<UniversalSearchResult>> _searchStocks(String query) async {
    if (!query.contains('台積電') &&
        !query.toLowerCase().contains('tsmc') &&
        !query.contains('2330')) {
      return [];
    }
    try {
      await Future.delayed(Duration(milliseconds: 300 + _random.nextInt(500)));
      if (_random.nextDouble() < 0.2) throw Exception("模擬股票 API 驗證失敗");
      print("股票：嘗試呼叫真實 API...");
      final stockData = _fakeDataService.getFakeStockData().first;
      return [
        StockSearchResultItem(
          id: 'stock_${stockData['symbol']}',
          title: '${stockData['name']} (${stockData['symbol']})',
          subtitle: '股價: \$${stockData['price']} TWD',
          data: stockData,
        )
      ];
    } catch (e) {
      print("股票：真實 API 失敗，啟用後備方案...");
      final fakeStock = _fakeDataService.getFakeStockData().first;
      return [
        StockSearchResultItem(
          id: 'stock_${fakeStock['symbol']}_fake',
          title: '${fakeStock['name']} (${fakeStock['symbol']}) (假資料)',
          subtitle: '股價: \$${fakeStock['price']} TWD',
          data: fakeStock,
        )
      ];
    }
  }

  /// [修正] 搜尋新聞
  /// 將 data 欄位從簡單的 Map 改為傳入一個完整的 PostData 物件，以符合 NewsSearchResultItem 的型別要求。
  Future<List<UniversalSearchResult>> _searchNews(String query) async {
    if (!query.contains('新聞') && !query.contains('AI')) {
      return [];
    }
    try {
      await Future.delayed(Duration(milliseconds: 400 + _random.nextInt(600)));
      if (_random.nextDouble() < 0.2) throw Exception("模擬新聞 API 超時");

      print("新聞：嘗試呼叫真實 API...");
      final newsData = _fakeDataService.getFakeNewsData().first;
      return [
        NewsSearchResultItem(
          id: 'news_ai_1',
          title: newsData.caption,
          subtitle: '來源: ${newsData.userName} - ${newsData.timeAgo}',
          data: newsData, // 直接傳入 PostData 物件
        )
      ];
    } catch (e) {
      print("新聞：真實 API 失敗，啟用後備方案...");
      final fakeNews = _fakeDataService.getFakeNewsData().first;
      return [
        NewsSearchResultItem(
          id: 'news_ai_1_fake',
          title: '${fakeNews.caption} (假資料)',
          subtitle: '來源: ${fakeNews.userName} - ${fakeNews.timeAgo}',
          data: fakeNews, // 直接傳入 PostData 物件
        )
      ];
    }
  }
}
