// lib/main.dart
// [命名重構 V4.4]
// 功能：更新 import 路徑與類別引用。

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tell_me/core/services/dependency_injection.dart';
import 'package:tell_me/core/theme/app_theme.dart';
import 'package:tell_me/app/app_container.dart';
import 'package:tell_me/features/home/home_controller.dart'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DependencyInjection.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HomeController homeController = Get.find<HomeController>();
    return Obx(() => GetMaterialApp(
          title: 'TELL ME',
          theme: AppTheme.getThemeData(homeController.currentThemeStyle.value),
          debugShowCheckedModeBanner: false,
          home: const AppContainer(),
        ));
  }
}
