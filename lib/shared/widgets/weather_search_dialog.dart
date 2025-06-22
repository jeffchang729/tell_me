// shared/widgets/weather_search_dialog.dart
// 天氣搜尋對話框
// 功能：讓用戶輸入城市名稱並搜尋天氣

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../services/weather_service.dart';
import '../models/weather_models.dart';

/// 天氣搜尋對話框
class WeatherSearchDialog extends StatefulWidget {
  final Function(List<WeatherCardData>) onSearchResults;

  const WeatherSearchDialog({
    Key? key,
    required this.onSearchResults,
  }) : super(key: key);

  @override
  _WeatherSearchDialogState createState() => _WeatherSearchDialogState();
}

class _WeatherSearchDialogState extends State<WeatherSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  final WeatherService _weatherService = WeatherService();
  
  bool _isSearching = false;
  List<WeatherSearchResult> _searchResults = [];
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// 執行搜尋
  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final locations = await _weatherService.searchLocations(query);
      setState(() {
        _searchResults = locations;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      
      Get.snackbar(
        '搜尋失敗',
        '無法搜尋天氣資料，請稍後再試',
        backgroundColor: AppTheme.nearlyDarkBlue.withOpacity(0.8),
        colorText: AppTheme.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  /// 選擇搜尋結果並取得天氣資料
  Future<void> _selectLocation(WeatherSearchResult location) async {
    setState(() {
      _isSearching = true;
    });

    try {
      final weatherData = await _weatherService.getCompleteWeatherData(location);
      
      if (weatherData != null) {
        Navigator.of(context).pop();
        widget.onSearchResults([weatherData]);
      } else {
        Get.snackbar(
          '取得天氣失敗',
          '無法取得 ${location.locationName} 的天氣資料',
          backgroundColor: AppTheme.nearlyDarkBlue.withOpacity(0.8),
          colorText: AppTheme.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar(
        '載入失敗',
        '無法載入天氣資料，請稍後再試',
        backgroundColor: AppTheme.nearlyDarkBlue.withOpacity(0.8),
        colorText: AppTheme.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: AppTheme.cardDecoration(radius: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 標題列
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.nearlyDarkBlue,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    color: AppTheme.white,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '搜尋天氣',
                      style: AppTheme.headline.copyWith(
                        color: AppTheme.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: AppTheme.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            
            // 搜尋輸入框
            Padding(
              padding: EdgeInsets.all(20),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: '輸入城市名稱，例如：台北、高雄',
                  prefixIcon: Icon(Icons.location_on, color: AppTheme.grey),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchResults = [];
                            });
                          },
                          icon: Icon(Icons.clear, color: AppTheme.grey),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.grey.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.nearlyDarkBlue),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                onChanged: (value) {
                  setState(() {});
                  Future.delayed(Duration(milliseconds: 500), () {
                    if (_searchController.text == value) {
                      _performSearch(value);
                    }
                  });
                },
                onSubmitted: _performSearch,
              ),
            ),
            
            // 搜尋結果
            Flexible(
              child: _buildSearchContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchContent() {
    if (_isSearching) {
      return Container(
        height: 150,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.nearlyDarkBlue),
              ),
              SizedBox(height: 16),
              Text(
                '搜尋中...',
                style: AppTheme.body1.copyWith(color: AppTheme.grey),
              ),
            ],
          ),
        ),
      );
    }

    if (_searchController.text.isEmpty) {
      return Container(
        height: 150,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud,
                size: 48,
                color: AppTheme.grey.withOpacity(0.5),
              ),
              SizedBox(height: 16),
              Text(
                '輸入城市名稱開始搜尋',
                style: AppTheme.body1.copyWith(color: AppTheme.grey),
              ),
              SizedBox(height: 8),
              Text(
                '支援台灣所有縣市',
                style: AppTheme.caption.copyWith(color: AppTheme.grey),
              ),
            ],
          ),
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Container(
        height: 150,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 48,
                color: AppTheme.grey.withOpacity(0.5),
              ),
              SizedBox(height: 16),
              Text(
                '找不到相關城市',
                style: AppTheme.body1.copyWith(color: AppTheme.grey),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(horizontal: 20),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final location = _searchResults[index];
        return Container(
          margin: EdgeInsets.only(bottom: 8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _selectLocation(location),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppTheme.grey.withOpacity(0.2),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.nearlyDarkBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.location_city,
                        color: AppTheme.nearlyDarkBlue,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            location.locationName,
                            style: AppTheme.title.copyWith(fontSize: 16),
                          ),
                          if (location.fullLocationName != location.locationName)
                            Text(
                              location.fullLocationName,
                              style: AppTheme.caption.copyWith(color: AppTheme.grey),
                            ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppTheme.grey,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 顯示天氣搜尋對話框
void showWeatherSearchDialog(
  BuildContext context, {
  required Function(List<WeatherCardData>) onSearchResults,
}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => WeatherSearchDialog(
      onSearchResults: onSearchResults,
    ),
  );
}