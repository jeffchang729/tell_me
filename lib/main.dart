// main.dart
// 應用程式主入口
// 功能：初始化應用程式，設定 GetX 依賴注入，並啟動主畫面容器。

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'core/services/dependency_injection.dart';
import 'features/home/views/app_container.dart';


Future<void> main() async {
  // 確保 Flutter 小工具綁定已初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化所有服務和控制器
  await DependencyInjection.init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'TELL ME',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const AppContainer(),
    );
  }
}
