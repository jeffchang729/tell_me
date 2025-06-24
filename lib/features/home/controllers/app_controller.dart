// features/home/controllers/app_controller.dart
// 應用程式主控制器 - [重大修改] 新增主題篩選邏輯
// 功能：管理全域狀態，並根據使用者在主畫面的選擇，動態過濾顯示的資訊卡片。

import 'dart:convert';
import 'package:get/get.dart';
import 'package:tell_me/shared/models/search_models.dart';
import 'package:tell_me/shared/services/storage_service.dart';

class AppController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  static const String _trackedItemsKey = 'tracked_items';

  // --- State Variables ---
  final RxInt currentTabIndex = 0.obs;

  /// [核心] 所有使用者已追蹤的卡片原始列表
  final RxList<UniversalSearchResult> trackedItems = <UniversalSearchResult>[].obs;

  /// [新增] 當前在主畫面上選擇的主題類型
  final Rx<SearchResultType?> selectedTopicType = Rx<SearchResultType?>(null);

  /// [新增] 經過主題篩選後，真正要顯示在「即時內容區」的卡片列表
  final RxList<UniversalSearchResult> filteredTrackedItems = <UniversalSearchResult>[].obs;

  // 用於監聽 trackedItems 和 selectedTopicType 變化的監聽器
  late Worker _itemsWorker;

  @override
  void onInit() {
    super.onInit();
    _loadTrackedItems();

    // [新增] 設定一個監聽器
    // 當 `trackedItems` 或 `selectedTopicType` 發生變化時，自動觸發 `_updateFilteredItems` 方法
    _itemsWorker = everAll([trackedItems, selectedTopicType], (_) {
      _updateFilteredItems();
    }, onError: (error) {
      print("Worker 發生錯誤: $error");
    });
  }
  
  @override
  void onClose() {
    _itemsWorker.dispose(); // 頁面銷毀時，釋放監聽器
    super.onClose();
  }

  /// [新增] 當使用者點擊「卡片區」的卡片時，呼叫此方法來更新選擇
  void selectTopic(SearchResultType type) {
    if (selectedTopicType.value == type) return; // 如果點擊的是同一個，則不動作
    selectedTopicType.value = type;
    print('已選擇主題: $type');
  }

  /// [新增] 過濾 trackedItems，並更新 filteredTrackedItems
  void _updateFilteredItems() {
    if (selectedTopicType.value == null) {
      // 如果沒有選擇任何主題（例如在全部清除後），清空顯示列表
      filteredTrackedItems.clear();
    } else {
      // 否則，只顯示符合所選主題的項目
      final filtered = trackedItems.where((item) => item.type == selectedTopicType.value).toList();
      filteredTrackedItems.assignAll(filtered);
    }
     print('過濾後的項目數量: ${filteredTrackedItems.length}');
  }

  /// 從本地儲存載入已追蹤的項目
  void _loadTrackedItems() {
    try {
      final savedData = _storageService.getString(_trackedItemsKey);
      if (savedData != null && savedData.isNotEmpty) {
        final List<dynamic> decodedList = jsonDecode(savedData);
        final items = decodedList
            .map((d) => UniversalSearchResult.fromJson(d as Map<String, dynamic>))
            .toList();
        trackedItems.assignAll(items);

        // 載入後，預設選擇第一個可用的主題
        if (trackedItems.isNotEmpty) {
           final uniqueTypes = trackedItems.map((item) => item.type).toSet();
           selectTopic(uniqueTypes.first);
        }

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
    // 新增後，自動選擇剛新增的項目類型
    selectTopic(item.type);
    await _saveTrackedItems();
    Get.snackbar('已加入儀表板', '${item.title} 已成功加入您的追蹤清單。');
  }

  /// 從儀表板移除一個項目
  Future<void> removeTrackedItem(String itemId) async {
    trackedItems.removeWhere((item) => item.id == itemId);
    
    // 如果移除後，目前選中的主題類型沒有任何卡片了，就重新選擇一個預設主題
    final uniqueTypes = trackedItems.map((item) => item.type).toSet();
    if (!uniqueTypes.contains(selectedTopicType.value)) {
        selectedTopicType.value = uniqueTypes.isNotEmpty ? uniqueTypes.first : null;
    }

    await _saveTrackedItems();
    Get.snackbar('已移除', '卡片已從您的儀表板移除。');
  }

  /// 將目前的追蹤項目列表寫入手機儲存空間
  Future<void> _saveTrackedItems() async {
    try {
      final dataToSave = trackedItems.map((item) => item.toJson()).toList();
      await _storageService.setString(_trackedItemsKey, jsonEncode(dataToSave));
      print('✅ 已成功儲存 ${dataToSave.length} 個追蹤項目。');
    } catch (e) {
      print('❌ 儲存追蹤項目失敗: $e');
    }
  }

  void changeTabIndex(int index) {
    if (index == currentTabIndex.value) return;
    currentTabIndex.value = index;
  }

  Future<void> clearAllTrackedItems() async {
    trackedItems.clear();
    selectedTopicType.value = null; // 清空選擇
    await _storageService.remove(_trackedItemsKey);
    print('🗑️ 已清除所有已追蹤的項目。');
  }
}
