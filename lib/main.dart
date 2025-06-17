// lib/main.dart
// 應用程式入口點
// 功能：初始化應用程式並啟動主畫面

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'config/app_config.dart';
import 'config/app_theme.dart';
import 'controllers/app_controller.dart';
import 'services/storage_service.dart';
import 'screens/app_container.dart';

void main() async {
  // 確保 Flutter 綁定已初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  // 設定系統狀態列樣式
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  
  // 設定螢幕方向為直向
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) async {
    // 初始化本地儲存服務
    await StorageService().init();
    
    // 啟動應用程式
    runApp(MyApp());
  });
}

/// 應用程式主類別
/// 
/// 負責配置應用程式的基本設定，包括主題、路由、國際化等
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // 應用程式標題
      title: AppConfig.appName,
      
      // 除錯模式標誌
      debugShowCheckedModeBanner: false,
      
      // 主題配置
      theme: AppTheme.lightTheme,
      
      // 主頁面
      home: const AppContainer(),
      
      // 依賴注入綁定
      initialBinding: AppBinding(),
      
      // 預設過渡動畫
      defaultTransition: Transition.fade,
      transitionDuration: AppConfig.defaultAnimationDuration,
      
      // 本地化設定
      locale: const Locale('zh', 'TW'),
      fallbackLocale: const Locale('en', 'US'),
      
      // 全域建構器（可用於載入狀態等）
      builder: (context, child) {
        return MediaQuery(
          // 確保文字不會因為系統設定而縮放
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
    );
  }
}

/// 全域依賴注入綁定
/// 
/// 負責註冊所有需要全域存取的服務和控制器
class AppBinding extends Bindings {
  @override
  void dependencies() {
    // 註冊服務（單例模式）
    Get.put<StorageService>(StorageService(), permanent: true);
    
    // 註冊控制器（延遲載入）
    Get.lazyPut<AppController>(() => AppController());
    
    // 其他控制器將在各自的頁面中按需載入
  }
}