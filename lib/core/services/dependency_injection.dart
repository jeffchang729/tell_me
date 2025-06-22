// lib/core/services/dependency_injection.dart
// GetX 依賴注入管理 - 修正版
// 功能：集中初始化並註冊所有全域服務和控制器。

import 'package:get/get.dart';
import 'package:tell_me/features/home/controllers/app_controller.dart';
import 'package:tell_me/features/home/controllers/search_controller.dart';
import 'package:tell_me/shared/services/storage_service.dart';
import 'package:tell_me/shared/services/weather_service.dart';

class DependencyInjection {
  static Future<void> init() async {
    
    // [修正] 確保傳遞給 putAsync 的函式回傳 Future<StorageService>
    await Get.putAsync<StorageService>(() async {
      final storageService = StorageService();
      await storageService.init();
      return storageService;
    });
    
    Get.lazyPut<WeatherService>(() => WeatherService(), fenix: true);
    Get.lazyPut<AppController>(() => AppController(), fenix: true);
    Get.lazyPut<SearchController>(() => SearchController(), fenix: true);
    
    print("所有依賴注入完成。");
  }
}
