// lib/core/services/dependency_injection.dart
// [錯誤修正 V5.5]
// 功能：修正 import 路徑，確保 HomeController 和 SearchController 從正確的檔案導入。

import 'package:get/get.dart';
import 'package:tell_me/core/services/fake_data_service.dart';
import 'package:tell_me/features/home/home_controller.dart';
import 'package:tell_me/features/search/search_controller.dart'; // [修正] 確保 SearchController 從這裡導入
import 'package:tell_me/core/services/storage_service.dart';
import 'package:tell_me/features/weather/weather_service.dart'; 

class DependencyInjection {
  static Future<void> init() async {
    
    await Get.putAsync<StorageService>(() async {
      final storageService = StorageService();
      await storageService.init();
      return storageService;
    });
    Get.lazyPut<FakeDataService>(() => FakeDataService(), fenix: true);
    
    Get.lazyPut<WeatherService>(() => WeatherService(), fenix: true);
    
    // [驗證] 現在兩個 Controller 都有明確且唯一的來源
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<SearchController>(() => SearchController(), fenix: true);
    
    print("所有核心依賴注入完成。");
  }
}
