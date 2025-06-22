// shared/services/weather_service.dart
// 天氣API服務 - 最終版（智慧模擬資料 + 真實API解析）
// 功能：在瀏覽器環境使用模擬資料，移動設備使用真實API並解析回傳資料

import 'dart:convert';
import 'dart:async';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../../core/config/app_config.dart';
import '../models/weather_models.dart';

/// 天氣API服務類別
class WeatherService {
  static final WeatherService _instance = WeatherService._internal();
  factory WeatherService() => _instance;
  WeatherService._internal();

  final http.Client _httpClient = http.Client();
  final Map<String, dynamic> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};

  // 台灣城市真實天氣模擬資料
  final Map<String, Map<String, dynamic>> _cityWeatherData = {
    '台北市': {
      'baseTemp': 28.5,
      'climate': '亞熱帶',
      'humidity': 65,
      'descriptions': ['晴時多雲', '多雲時晴', '陰時多雲', '晴朗']
    },
    '新北市': {
      'baseTemp': 27.8,
      'climate': '亞熱帶',
      'humidity': 68,
      'descriptions': ['多雲', '晴時多雲', '陰天', '小雨']
    },
    '桃園市': {
      'baseTemp': 29.2,
      'climate': '亞熱帶',
      'humidity': 62,
      'descriptions': ['晴天', '多雲時晴', '晴時多雲', '午後雷陣雨']
    },
    '台中市': {
      'baseTemp': 30.1,
      'climate': '副熱帶',
      'humidity': 58,
      'descriptions': ['晴天', '晴朗', '多雲時晴', '晴時多雲']
    },
    '台南市': {
      'baseTemp': 31.5,
      'climate': '熱帶',
      'humidity': 55,
      'descriptions': ['晴天', '炎熱', '多雲時晴', '午後雷陣雨']
    },
    '高雄市': {
      'baseTemp': 32.0,
      'climate': '熱帶',
      'humidity': 60,
      'descriptions': ['晴天', '炎熱', '多雲', '午後雷陣雨']
    },
    '基隆市': {
      'baseTemp': 25.8,
      'climate': '海洋性',
      'humidity': 75,
      'descriptions': ['多雲', '陰雨', '小雨', '陰天']
    },
    '新竹市': {
      'baseTemp': 28.9,
      'climate': '亞熱帶',
      'humidity': 64,
      'descriptions': ['多雲時晴', '晴時多雲', '風大', '晴天']
    },
    '嘉義市': {
      'baseTemp': 30.8,
      'climate': '副熱帶',
      'humidity': 59,
      'descriptions': ['晴天', '多雲時晴', '晴朗', '午後雷陣雨']
    }
  };

  // ==================== 公開方法 ====================

  /// 檢查是否為Web環境
  bool get _isWebEnvironment => kIsWeb;

  /// 搜尋台灣地點
  Future<List<WeatherSearchResult>> searchLocations(String query) async {
    try {
      final cleanQuery = query.trim();
      if (cleanQuery.isEmpty) return [];

      final results = <WeatherSearchResult>[];

      for (final city in AppConfig.taiwanCities) {
        final cityName = city['name']!;
        final cityCode = city['code']!;

        if (cityName.contains(cleanQuery) ||
            cleanQuery.contains(cityName.replaceAll('市', '').replaceAll('縣', ''))) {
          results.add(WeatherSearchResult(
            locationName: cityName,
            fullLocationName: cityName,
            locationCode: cityCode,
          ));
        }
      }

      return results;
    } catch (e) {
      print('搜尋地點失敗: $e');
      return [];
    }
  }

  /// 取得目前天氣資料
  Future<CurrentWeather?> getCurrentWeather(String locationCode, String locationName) async {
    try {
      // 檢查快取
      final cacheKey = 'current_$locationCode';
      if (_isValidCache(cacheKey)) {
        return CurrentWeather.fromJson(_cache[cacheKey]);
      }

      CurrentWeather? currentWeather;

      if (_isWebEnvironment) {
        // Web環境：使用智慧模擬資料
        print('Web環境：使用模擬天氣資料 for $locationName');
        currentWeather = _generateSmartMockWeather(locationName);
      } else {
        // 移動設備：嘗試真實API
        currentWeather = await _fetchRealCurrentWeather(locationCode, locationName);
        // 如果API失敗，降級使用模擬資料
        currentWeather ??= _generateSmartMockWeather(locationName);
      }

      // 儲存到快取
      if (currentWeather != null) {
        _cache[cacheKey] = currentWeather.toJson();
        _cacheTimestamps[cacheKey] = DateTime.now();
      }

      return currentWeather;
    } catch (e) {
      print('取得目前天氣失敗: $e');
      return _generateSmartMockWeather(locationName);
    }
  }

  /// 取得天氣預報資料
  Future<WeatherForecast?> getWeatherForecast(String locationCode, String locationName) async {
    try {
      // 檢查快取
      final cacheKey = 'forecast_$locationCode';
      if (_isValidCache(cacheKey)) {
        return WeatherForecast.fromJson(_cache[cacheKey]);
      }

      WeatherForecast? forecast;

      if (_isWebEnvironment) {
        // Web環境：使用智慧模擬資料
        print('Web環境：使用模擬預報資料 for $locationName');
        forecast = _generateSmartMockForecast(locationName);
      } else {
        // 移動設備：嘗試真實API
        forecast = await _fetchRealForecast(locationCode, locationName);
        // 如果API失敗，降級使用模擬資料
        forecast ??= _generateSmartMockForecast(locationName);
      }

      // 儲存到快取
      if (forecast != null) {
        _cache[cacheKey] = forecast.toJson();
        _cacheTimestamps[cacheKey] = DateTime.now();
      }

      return forecast;
    } catch (e) {
      print('取得天氣預報失敗: $e');
      return _generateSmartMockForecast(locationName);
    }
  }

  /// 取得完整天氣資料
  Future<WeatherCardData?> getCompleteWeatherData(WeatherSearchResult searchResult) async {
    try {
      print('開始取得完整天氣資料: ${searchResult.locationName}');
      
      final futures = await Future.wait([
        getCurrentWeather(searchResult.locationCode, searchResult.locationName),
        getWeatherForecast(searchResult.locationCode, searchResult.locationName),
      ]);

      final currentWeather = futures[0] as CurrentWeather?;
      final forecast = futures[1] as WeatherForecast?;

      if (currentWeather != null) {
        print('✅ 成功建立天氣卡片資料: ${searchResult.locationName}');
        return WeatherCardData(
          id: _generateCardId(searchResult.locationCode),
          locationName: searchResult.locationName,
          currentWeather: currentWeather,
          forecast: forecast,
          cardColor: AppConfig.getWeatherCardColor(
            searchResult.locationCode.hashCode,
          ),

          createdAt: DateTime.now(),
        );
      }

      return null;
    } catch (e) {
      print('取得完整天氣資料失敗: $e');
      return null;
    }
  }

  /// 清除所有快取
  void clearAllCache() {
    _cache.clear();
    _cacheTimestamps.clear();
  }

  /// 釋放資源
  void dispose() {
    _httpClient.close();
    clearAllCache();
  }
  
  // ==================== 私有API呼叫方法 ====================

  /// 真實API呼叫 - 目前天氣 (O-A0003-001)
  Future<CurrentWeather?> _fetchRealCurrentWeather(String locationCode, String locationName) async {
    try {
      print('呼叫真實API (目前天氣) for $locationName');
      final uri = Uri.parse(AppConfig.currentWeatherEndpoint).replace(queryParameters: {
        'Authorization': AppConfig.cwaApiKey,
        'locationName': locationName,
        'elementName': 'TEMP,HUMD,PRES,WDSD,WDIR,Weather', // WDIR:風向, WDSD:風速, Weather:天氣現象
      });

      final response = await _httpClient.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      ).timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _parseCurrentWeatherResponse(data, locationName);
      }
      print('真實API (目前天氣) 呼叫失敗: statusCode=${response.statusCode}');
      return null;
    } catch (e) {
      print('真實API (目前天氣) 呼叫失敗: $e');
      return null;
    }
  }

  /// 真實API呼叫 - 天氣預報 (F-C0032-001)
  Future<WeatherForecast?> _fetchRealForecast(String locationCode, String locationName) async {
    try {
      print('呼叫真實API (預報) for $locationName');
      final uri = Uri.parse(AppConfig.forecastEndpoint).replace(queryParameters: {
        'Authorization': AppConfig.cwaApiKey,
        'locationName': locationName,
        'elementName': 'Wx,PoP,MinT,MaxT',
      });

      final response = await _httpClient.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      ).timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _parseForecastResponse(data, locationName);
      }
      print('真實API (預報) 呼叫失敗: statusCode=${response.statusCode}');
      return null;
    } catch (e) {
      print('真實預報API呼叫失敗: $e');
      return null;
    }
  }

  // ==================== 真實API解析邏輯 ====================

  /// 解析目前天氣的API回應 (O-A0003-001)
  CurrentWeather? _parseCurrentWeatherResponse(Map<String, dynamic> data, String locationName) {
    try {
      if (data['records'] == null || data['records']['location'] == null) {
        print('API回應缺少 records 或 location 欄位');
        return null;
      }

      final locations = data['records']['location'] as List;
      if (locations.isEmpty) {
        print('API回應的 location 陣列為空');
        return null;
      }

      final locationData = locations.firstWhere(
        (loc) => loc['locationName'] == locationName,
        orElse: () => locations.first,
      );

      final elements = locationData['weatherElement'] as List;
      final time = locationData['time']?['obsTime'] != null 
          ? DateTime.parse(locationData['time']['obsTime']) 
          : DateTime.now();

      // 安全地提取數值，並處理無效值(-99)
      double getElementValue(String name) {
        final element = elements.firstWhere((e) => e['elementName'] == name, orElse: () => null);
        final value = double.tryParse(element?['elementValue'] ?? '-99') ?? -99;
        return value == -99.0 ? 0.0 : value;
      }
      
      String getWeatherDesc() {
        final element = elements.firstWhere((e) => e['elementName'] == 'Weather', orElse: () => null);
        return element?['elementValue'] ?? '無資料';
      }

      return CurrentWeather(
        temperature: getElementValue('TEMP'),
        description: getWeatherDesc(),
        humidity: (getElementValue('HUMD') * 100).toInt(), // API回傳值為 0-1
        pressure: getElementValue('PRES'),
        windSpeed: getElementValue('WDSD'),
        windDirection: getElementValue('WDIR').toInt(),
        updateTime: time,
      );
    } catch (e) {
      print('解析目前天氣資料失敗: $e');
      // 解析失敗時，回退到模擬資料
      return _generateSmartMockWeather(locationName);
    }
  }

  /// 解析天氣預報的API回應 (F-C0032-001)
  WeatherForecast? _parseForecastResponse(Map<String, dynamic> data, String locationName) {
    try {
      if (data['records'] == null || data['records']['location'] == null) {
        print('API回應缺少 records 或 location 欄位');
        return null;
      }

      final locations = data['records']['location'] as List;
      final locationData = locations.firstWhere(
        (loc) => loc['locationName'] == locationName,
        orElse: () => null,
      );

      if (locationData == null) {
        print('在預報資料中找不到地點: $locationName');
        return null;
      }
      
      // 提取所有天氣元素
      final weatherElements = locationData['weatherElement'] as List;
      final wx = weatherElements.firstWhere((e) => e['elementName'] == 'Wx')['time'] as List;
      final pop = weatherElements.firstWhere((e) => e['elementName'] == 'PoP')['time'] as List;
      final minT = weatherElements.firstWhere((e) => e['elementName'] == 'MinT')['time'] as List;
      final maxT = weatherElements.firstWhere((e) => e['elementName'] == 'MaxT')['time'] as List;
      
      final dailyForecastsMap = <String, DailyForecast>{};

      // 由於API是36小時預報，包含3個時段，我們將其組合為每日預報
      for (int i = 0; i < minT.length; i++) {
        final date = DateTime.parse(minT[i]['startTime']);
        final dateKey = '${date.year}-${date.month}-${date.day}';

        final currentMinT = double.parse(minT[i]['parameter']['parameterName']);
        final currentMaxT = double.parse(maxT[i]['parameter']['parameterName']);
        
        if (dailyForecastsMap.containsKey(dateKey)) {
          // 如果日期已存在，更新最高/最低溫
          final existing = dailyForecastsMap[dateKey]!;
          dailyForecastsMap[dateKey] = existing.copyWith(
            maxTemperature: math.max(existing.maxTemperature, currentMaxT),
            minTemperature: math.min(existing.minTemperature, currentMinT),
          );
        } else {
          // 建立新的每日預報
          dailyForecastsMap[dateKey] = DailyForecast(
            date: date,
            maxTemperature: currentMaxT,
            minTemperature: currentMinT,
            description: wx[i]['parameter']['parameterName'],
            rainProbability: int.parse(pop[i]['parameter']['parameterName']),
            weatherIcon: wx[i]['parameter']['parameterValue'],
          );
        }
      }
      
      final dailyForecasts = dailyForecastsMap.values.toList();
      // 按日期排序
      dailyForecasts.sort((a, b) => a.date.compareTo(b.date));

      return WeatherForecast(
        dailyForecasts: dailyForecasts,
        updateTime: DateTime.now(),
      );

    } catch (e) {
      print('解析預報資料失敗: $e');
      // 解析失敗時，回退到模擬資料
      return _generateSmartMockForecast(locationName);
    }
  }

  // ==================== 模擬資料產生方法 ====================

  /// 產生智慧模擬目前天氣
  CurrentWeather _generateSmartMockWeather(String locationName) {
    final cityData = _cityWeatherData[locationName] ?? _cityWeatherData['台北市']!;
    final random = math.Random();
    final now = DateTime.now();
    
    double baseTemp = cityData['baseTemp'].toDouble();
    final hour = now.hour;
    
    if (hour >= 6 && hour < 12) {
      baseTemp += (hour - 6) * 0.8;
    } else if (hour >= 12 && hour < 18) {
      baseTemp += 3.0 + random.nextDouble() * 2;
    } else if (hour >= 18 && hour < 22) {
      baseTemp += 1.0 - (hour - 18) * 0.5;
    } else {
      baseTemp -= 2.0 + random.nextDouble() * 2;
    }
    
    baseTemp += (random.nextDouble() - 0.5) * 3;
    
    final descriptions = List<String>.from(cityData['descriptions']);
    final description = descriptions[random.nextInt(descriptions.length)];
    
    return CurrentWeather(
      temperature: double.parse(baseTemp.toStringAsFixed(1)),
      description: description,
      humidity: cityData['humidity'] + random.nextInt(20) - 10,
      pressure: 1010.0 + random.nextDouble() * 20,
      windSpeed: 1.0 + random.nextDouble() * 5,
      windDirection: random.nextInt(360),
      updateTime: DateTime.now(),
    );
  }

  /// 產生智慧模擬預報
  WeatherForecast _generateSmartMockForecast(String locationName) {
    final cityData = _cityWeatherData[locationName] ?? _cityWeatherData['台北市']!;
    final random = math.Random();
    final baseTemp = cityData['baseTemp'].toDouble();
    final descriptions = List<String>.from(cityData['descriptions']);
    
    final dailyForecasts = List.generate(7, (index) {
      final date = DateTime.now().add(Duration(days: index));
      
      double maxTemp = baseTemp + random.nextDouble() * 4 - 1;
      double minTemp = maxTemp - 6 - random.nextDouble() * 3;
      
      if (locationName.contains('高雄') || locationName.contains('台南')) {
        maxTemp += 2;
        minTemp += 1;
      } else if (locationName.contains('基隆')) {
        maxTemp -= 2;
        minTemp -= 2;
      }
      
      if (date.weekday == 6 || date.weekday == 7) {
        if (random.nextBool()) maxTemp += random.nextDouble() * 2;
      }
      
      final description = descriptions[random.nextInt(descriptions.length)];
      int? rainProbability;
      
      if (description.contains('雨')) {
        rainProbability = 60 + random.nextInt(30);
      } else if (description.contains('雷陣雨')) {
        rainProbability = 40 + random.nextInt(40);
      } else if (description.contains('陰')) {
        rainProbability = random.nextInt(30);
      }
      
      return DailyForecast(
        date: date,
        maxTemperature: double.parse(maxTemp.toStringAsFixed(1)),
        minTemperature: double.parse(minTemp.toStringAsFixed(1)),
        description: description,
        rainProbability: rainProbability,
      );
    });

    return WeatherForecast(
      dailyForecasts: dailyForecasts,
      updateTime: DateTime.now(),
    );
  }

  // ==================== 私有輔助方法 ====================

  bool _isValidCache(String key) {
    if (!_cache.containsKey(key) || !_cacheTimestamps.containsKey(key)) {
      return false;
    }
    
    final cacheTime = _cacheTimestamps[key]!;
    final now = DateTime.now();
    return now.difference(cacheTime) < AppConfig.weatherCacheExpiry;
  }

  String _generateCardId(String locationCode) {
    return 'weather_${locationCode}_${DateTime.now().millisecondsSinceEpoch}';
  }
}

/// [新增] DailyForecast 的輔助 copyWith 方法
extension DailyForecastExtension on DailyForecast {
  DailyForecast copyWith({
    DateTime? date,
    double? maxTemperature,
    double? minTemperature,
    String? description,
    int? rainProbability,
    String? weatherIcon,
  }) {
    return DailyForecast(
      date: date ?? this.date,
      maxTemperature: maxTemperature ?? this.maxTemperature,
      minTemperature: minTemperature ?? this.minTemperature,
      description: description ?? this.description,
      rainProbability: rainProbability ?? this.rainProbability,
      weatherIcon: weatherIcon ?? this.weatherIcon,
    );
  }
}
