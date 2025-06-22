// features/home/views/app_container.dart
// 應用程式主容器 - 重構版
// 功能：管理頁面切換，並將搜尋按鈕的行為改為導航至智慧搜尋頁面。

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/app_controller.dart';
import '../../../shared/widgets/navigation_widgets.dart';
import '../../../shared/models/tab_icon_data.dart';
import 'home_screen.dart';
import 'search_screen.dart'; // [修改] 引入新的搜尋頁面
import '../../training/views/training_screen.dart';

class AppContainer extends StatefulWidget {
  const AppContainer({Key? key}) : super(key: key);

  @override
  _AppContainerState createState() => _AppContainerState();
}

class _AppContainerState extends State<AppContainer> with TickerProviderStateMixin {
  final AppController appController = Get.find<AppController>();
  AnimationController? animationController;
  Widget tabBody = Container(color: AppTheme.background);
  List<TabIconData> tabIconsList = TabIconData.tabIconsList;

  @override
  void initState() {
    animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _setInitialPage();
    super.initState();
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  void _setInitialPage() {
    _setPageByIndex(appController.currentTabIndex.value);
  }

  void _setPageByIndex(int index) {
    Widget newTabBody;
    switch (index) {
      case 0:
        newTabBody = HomeScreen(animationController: animationController);
        break;
      case 1:
        newTabBody = TrainingScreen(animationController: animationController);
        break;
      // 可以繼續擴充其他分頁
      default:
        newTabBody = HomeScreen(animationController: animationController);
    }
    if (mounted) {
      setState(() {
        tabBody = newTabBody;
      });
    }
  }

  void _handleTabChange(int index) {
    appController.changeTabIndex(index);
    animationController?.reverse().then<dynamic>((data) {
      if (!mounted) return;
      _setPageByIndex(index);
      animationController?.forward();
    });
  }

  /// [修改] 處理搜尋按鈕點擊事件
  void _handleSearchClick() {
    // 使用 GetX 導航到新的 SearchScreen
    Get.to(() => const SearchScreen(), transition: Transition.downToUp);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: <Widget>[
            tabBody,
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Column(
      children: <Widget>[
        const Expanded(child: SizedBox()),
        BottomBarView(
          tabIconsList: tabIconsList,
          addClick: _handleSearchClick, // [修改] 綁定新的導航事件
          changeIndex: _handleTabChange,
        ),
      ],
    );
  }
}
