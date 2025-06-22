// lib/features/home/controllers/app_controller.dart
// 應用程式主控制器 - 修復版
// 功能：管理應用程式的全域狀態，並加回 changeTabIndex 方法。

import 'package:get/get.dart';
import 'package:tell_me/shared/models/search_models.dart';
import 'package:tell_me/shared/services/storage_service.dart';

class AppController extends GetxController {
  
  final StorageService _storageService = Get.find<StorageService>();
  static const String _trackedItemsKey = 'tracked_items';

  final RxInt currentTabIndex = 0.obs;
  final RxList<UniversalSearchResult> trackedItems = <UniversalSearchResult>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    _loadTrackedItems();
  }

  /// 從本地儲存載入已追蹤的項目
  void _loadTrackedItems() {
    try {
      final savedData = _storageService.getJsonList(_trackedItemsKey);
      if (savedData != null) {
        final items = savedData
            .map((d) => UniversalSearchResult.fromJson(d))
            .toList();
        trackedItems.assignAll(items);
        print('✅ 成功載入 ${items.length} 個已追蹤項目。');
      }
    } catch (e) {
      print('❌ 載入已追蹤項目失敗: $e');
      _storageService.remove(_trackedItemsKey);
    }
  }

  /// 新增一個項目到儀表板並儲存
  Future<void> addTrackedItem(UniversalSearchResult item) async {
    if (trackedItems.any((element) => element.id == item.id)) {
      Get.snackbar('重複項目', '${item.title} 已經在您的儀表板上。');
      return;
    }
    trackedItems.insert(0, item);
    await _saveTrackedItems();
    Get.snackbar('已加入儀表板', '${item.title} 已成功加入您的追蹤清單。');
  }

  /// [新增] 從儀表板移除一個項目
  Future<void> removeTrackedItem(String itemId) async {
    trackedItems.removeWhere((item) => item.id == itemId);
    await _saveTrackedItems();
    Get.snackbar('已移除', '卡片已從您的儀表板移除。');
  }

  /// 將目前的追蹤項目列表寫入手機儲存空間
  Future<void> _saveTrackedItems() async {
    try {
      final dataToSave = trackedItems.map((item) => item.toJson()).toList();
      await _storageService.setJsonList(_trackedItemsKey, dataToSave);
      print('✅ 已成功儲存 ${dataToSave.length} 個追蹤項目。');
    } catch (e) {
      print('❌ 儲存追蹤項目失敗: $e');
    }
  }
  
  /// [修正] 加回切換底部導航分頁的方法
  void changeTabIndex(int index) {
    if (index == currentTabIndex.value) return;
    currentTabIndex.value = index;
    // 這裡只更新狀態，動畫等 UI 反應由 View 層處理
  }

  /// [新增] 清除所有已追蹤的項目 (用於開發測試)
  Future<void> clearAllTrackedItems() async {
    trackedItems.clear();
    await _storageService.remove(_trackedItemsKey);
    print('🗑️ 已清除所有已追蹤的項目。');
  }
}
