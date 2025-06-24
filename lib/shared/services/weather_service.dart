// shared/services/weather_service.dart
// 天氣 API 服務 - [偵錯強化]
// 功能：遵循使用者規範，將所有自訂日誌以 "==" 開頭，並提供更詳細的 API 請求資訊，方便追蹤與除錯。

import 'dart:convert';
import 'dart:async';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../../core/config/app_config.dart';
import '../models/weather_models.dart';

class WeatherService {
  static final WeatherService _instance = WeatherService._internal();
  factory WeatherService() => _instance;
  WeatherService._internal();

  final http.Client _httpClient = http.Client();
  final Map<String, dynamic> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};

  Future<List<WeatherSearchResult>> searchLocations(String query) async {
    final cleanQuery = query.trim().replaceAll('台', '臺');
    if (cleanQuery.isEmpty) return [];
    
    return AppConfig.taiwanCities
        .where((city) => city['name']!.contains(cleanQuery))
        .map((city) => WeatherSearchResult(
              locationName: city['name']!,
              fullLocationName: city['name']!,
              locationCode: city['code']!,
            ))
        .toList();
  }

  Future<WeatherCardData?> getCompleteWeatherData(WeatherSearchResult searchResult) async {
    try {
      print('== [WeatherService] 🔄 開始取得 ${searchResult.locationName} 的完整天氣資料...');
      
      final futures = await Future.wait([
        getCurrentWeather(searchResult.locationName),
        getWeatherForecast(searchResult.locationName),
      ]);

      final currentWeather = futures[0] as CurrentWeather?;
      final forecast = futures[1] as WeatherForecast?;

      if (currentWeather != null) {
        print('== [WeatherService] ✅ 成功建立天氣卡片資料: ${searchResult.locationName}');
        return WeatherCardData(
          id: _generateCardId(searchResult.locationCode),
          locationName: searchResult.locationName,
          currentWeather: currentWeather,
          forecast: forecast,
          cardColor: AppConfig.getWeatherCardColor(searchResult.locationCode.hashCode).value.toString(),
          createdAt: DateTime.now(),
        );
      }
      return null;
    } catch (e) {
      print('== [WeatherService] ❌ 取得完整天氣資料時發生未預期錯誤: $e');
      return null;
    }
  }

  Future<CurrentWeather?> getCurrentWeather(String locationName) async {
    final cacheKey = 'current_$locationName';
    if (_isValidCache(cacheKey)) {
      print('== [WeatherService] ✅ 從快取讀取目前天氣: $locationName');
      return CurrentWeather.fromJson(_cache[cacheKey]);
    }
    
    print('== [WeatherService] 🔄 [API] 正在取得 $locationName 的即時天氣...');
    final uri = Uri.parse(AppConfig.currentDetailedEndpoint).replace(queryParameters: {
      'Authorization': AppConfig.cwaApiKey,
      'locationName': locationName,
      'elementName': 'TEMP,HUMD,Weather',
    });

    try {
      if (kIsWeb) {
        print('== [WeatherService] 🌐 Web 環境，啟用後備方案。');
        throw Exception("Web environment, using mock data.");
      }

      print('== [WeatherService] 📡 [REQUEST] GET: $uri');

      final response = await _httpClient.get(uri).timeout(AppConfig.apiTimeout);

      print('== [WeatherService] 📥 [RESPONSE] Status: ${response.statusCode}');
      // 只印出前 300 個字元，避免 Log 過長
      final responseBody = utf8.decode(response.bodyBytes);
      print('== [WeatherService] 📦 [RESPONSE] Body: ${responseBody.substring(0, math.min(300, responseBody.length))}...');

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        final currentWeather = _parseCurrentWeatherResponse(data, locationName);
        if (currentWeather != null) {
          _cache[cacheKey] = currentWeather.toJson();
          _cacheTimestamps[cacheKey] = DateTime.now();
          print('== [WeatherService] ☀️ [API] 成功取得目前天氣: $locationName');
          return currentWeather;
        }
      }
      throw Exception('API 請求失敗，狀態碼: ${response.statusCode}');
    } catch (e) {
      print('== [WeatherService] ⚠️ [API] 真實天氣 API 失敗 ($e)，啟用後備方案 (Fallback)...');
      return _generateSmartMockWeather(locationName);
    }
  }

  Future<WeatherForecast?> getWeatherForecast(String locationName) async {
    final cacheKey = 'forecast_$locationName';
    if (_isValidCache(cacheKey)) {
      print('== [WeatherService] ✅ 從快取讀取預報資料: $locationName');
      return WeatherForecast.fromJson(_cache[cacheKey]);
    }

    print('== [WeatherService] 🔄 [API] 正在取得 $locationName 的天氣預報...');
     final uri = Uri.parse(AppConfig.forecastEndpoint).replace(queryParameters: {
        'Authorization': AppConfig.cwaApiKey,
        'locationName': locationName,
        'elementName': 'Wx,PoP,MinT,MaxT',
      });

    try {
      if (kIsWeb) {
        print('== [WeatherService] 🌐 Web 環境，啟用後備方案。');
        throw Exception("Web environment, using mock data.");
      }
      
      print('== [WeatherService] 📡 [REQUEST] GET: $uri');
      final response = await _httpClient.get(uri).timeout(AppConfig.apiTimeout);
      print('== [WeatherService] 📥 [RESPONSE] Status: ${response.statusCode}');
      final responseBody = utf8.decode(response.bodyBytes);
      print('== [WeatherService] 📦 [RESPONSE] Body: ${responseBody.substring(0, math.min(300, responseBody.length))}...');

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        final forecast = _parseForecastResponse(data, locationName);
        if (forecast != null) {
          _cache[cacheKey] = forecast.toJson();
          _cacheTimestamps[cacheKey] = DateTime.now();
          print('== [WeatherService] 📅 [API] 成功取得預報: $locationName');
          return forecast;
        }
      }
       throw Exception('API 請求失敗，狀態碼: ${response.statusCode}');
    } catch (e) {
      print('== [WeatherService] ⚠️ [API] 真實預報 API 失敗 ($e)，啟用後備方案 (Fallback)...');
      return _generateSmartMockForecast(locationName);
    }
  }

  CurrentWeather? _parseCurrentWeatherResponse(Map<String, dynamic> data, String locationName) {
    try {
      final records = data['records']['location'] as List;
      if (records.isEmpty) {
        print('== [WeatherService] ⚠️ [Parse] API 回應中找不到地點資料。');
        return null;
      }
      final locationData = records.first;
      final elements = locationData['weatherElement'] as List;
      double getElementValue(String name, {double defaultValue = -99.0}) {
        final element = elements.firstWhere((e) => e['elementName'] == name, orElse: () => null);
        final value = double.tryParse(element?['elementValue'] ?? '$defaultValue') ?? defaultValue;
        return value <= -90.0 ? defaultValue : value;
      }
      String getWeatherDesc() {
        final element = elements.firstWhere((e) => e['elementName'] == 'Weather', orElse: () => null);
        return element?['elementValue'] ?? '無資料';
      }
      final temp = getElementValue('TEMP');
      final humidity = getElementValue('HUMD');
      if (temp == -99.0) return null;
      return CurrentWeather(
        temperature: temp,
        description: getWeatherDesc(),
        humidity: (humidity * 100).toInt(),
        pressure: 1013.25,
        updateTime: DateTime.now(),
      );
    } catch (e) {
      print('== [WeatherService] ❌ [Parse Error] 解析目前天氣資料失敗: $e');
      return null;
    }
  }
  
  WeatherForecast? _parseForecastResponse(Map<String, dynamic> data, String locationName) {
    try {
      final locationData = (data['records']['location'] as List).first;
      final weatherElements = locationData['weatherElement'] as List;
      final wx = weatherElements.firstWhere((e) => e['elementName'] == 'Wx')['time'] as List;
      final pop = weatherElements.firstWhere((e) => e['elementName'] == 'PoP')['time'] as List;
      final minT = weatherElements.firstWhere((e) => e['elementName'] == 'MinT')['time'] as List;
      final maxT = weatherElements.firstWhere((e) => e['elementName'] == 'MaxT')['time'] as List;
      final dailyForecasts = <DailyForecast>[];
      for (int i = 0; i < 3 && i < wx.length; i++) {
        dailyForecasts.add(DailyForecast(
          date: DateTime.parse(wx[i]['startTime']),
          maxTemperature: double.parse(maxT[i]['parameter']['parameterName']),
          minTemperature: double.parse(minT[i]['parameter']['parameterName']),
          description: wx[i]['parameter']['parameterName'],
          rainProbability: int.parse(pop[i]['parameter']['parameterName']),
          weatherIconCode: wx[i]['parameter']['parameterValue'],
        ));
      }
      return WeatherForecast(dailyForecasts: dailyForecasts, updateTime: DateTime.now());
    } catch (e) {
      print('== [WeatherService] ❌ [Parse Error] 解析預報資料失敗: $e');
      return null;
    }
  }

  CurrentWeather _generateSmartMockWeather(String locationName) {
     print('== [WeatherService] 🏭 產生模擬天氣資料 for $locationName');
    final random = math.Random();
    return CurrentWeather(
      temperature: 25.0 + random.nextDouble() * 10,
      description: ['晴時多雲', '午後雷陣雨', '陰天'][random.nextInt(3)],
      humidity: 60 + random.nextInt(30),
      pressure: 1010.0 + random.nextDouble() * 10,
      updateTime: DateTime.now(),
    );
  }

  WeatherForecast _generateSmartMockForecast(String locationName) {
    print('== [WeatherService] 🏭 產生模擬預報資料 for $locationName');
    final random = math.Random();
    return WeatherForecast(
      dailyForecasts: List.generate(3, (index) {
        final maxTemp = 28.0 + random.nextDouble() * 5;
        return DailyForecast(
          date: DateTime.now().add(Duration(days: index)),
          maxTemperature: maxTemp,
          minTemperature: maxTemp - (5 + random.nextDouble() * 3),
          description: ['晴時多雲', '午後雷陣雨', '陰天'][random.nextInt(3)],
          rainProbability: random.nextInt(8) * 10,
        );
      }),
      updateTime: DateTime.now(),
    );
  }

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

  void dispose() {
    _httpClient.close();
    _cache.clear();
    _cacheTimestamps.clear();
  }
}
