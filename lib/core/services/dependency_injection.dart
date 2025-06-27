// lib/core/services/dependency_injection.dart
// [API串接 V6.2 - 更新]
// 功能：新增 StockService 的依賴注入。

import 'package:get/get.dart';
import 'package:tell_me/core/services/fake_data_service.dart';
import 'package:tell_me/features/home/home_controller.dart';
import 'package:tell_me/features/search/search_controller.dart';
import 'package:tell_me/core/services/storage_service.dart';
import 'package:tell_me/features/stock/stock_service.dart'; // [新增] 導入新的 StockService
import 'package:tell_me/features/weather/weather_service.dart'; 

class DependencyInjection {
  static Future<void> init() async {
    
    // // 異步初始化本地儲存服務
    await Get.putAsync<StorageService>(() async {
      final storageService = StorageService();
      await storageService.init();
      return storageService;
    });

    // // 使用 lazyPut 延遲加載服務，在第一次使用時才建立實例
    Get.lazyPut<FakeDataService>(() => FakeDataService(), fenix: true);
    Get.lazyPut<WeatherService>(() => WeatherService(), fenix: true);
    Get.lazyPut<StockService>(() => StockService(), fenix: true); // [新增] 註冊 StockService
    
    // // 延遲加載核心的 Controllers
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<SearchController>(() => SearchController(), fenix: true);
    
    print("所有核心依賴注入完成 (包含 StockService)。");
  }
}
