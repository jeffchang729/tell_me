// lib/features/weather/weather_service.dart
// [架構重組 V4.3 - 步驟 2.2]
// 功能：檔案已移至最終位置，並更新 import 路徑。

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:tell_me/core/config/app_config.dart';
import 'package:tell_me/features/weather/weather_models.dart';

class WeatherService {
  late final Dio _dio;

  static final WeatherService _instance = WeatherService._internal();
  factory WeatherService() => _instance;

  WeatherService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://opendata.cwa.gov.tw/api/v1/rest/datastore',
        connectTimeout: AppConfig.apiTimeout,
        receiveTimeout: AppConfig.apiTimeout,
      ),
    );

    if (kDebugMode && !kIsWeb) {
      final adapter = _dio.httpClientAdapter as IOHttpClientAdapter;
      adapter.onHttpClientCreate = (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      };
    }
  }
  
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
      final futures = await Future.wait([
        getCurrentWeather(searchResult.locationName),
        getWeatherForecast(searchResult.locationName),
      ]);
      final currentWeather = futures[0] as CurrentWeather?;
      final forecast = futures[1] as WeatherForecast?;

      if (currentWeather != null) {
        return WeatherCardData(
          id: _generateCardId(searchResult.locationCode),
          locationName: searchResult.locationName,
          currentWeather: currentWeather,
          forecast: forecast,
          createdAt: DateTime.now(),
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  Future<CurrentWeather?> getCurrentWeather(String locationName) async {
    final cacheKey = 'current_$locationName';
    if (_isValidCache(cacheKey)) {
      return CurrentWeather.fromJson(_cache[cacheKey]);
    }
    
    try {
      final response = await _dio.get('/O-A0003-001', queryParameters: {
        'Authorization': AppConfig.cwaApiKey,
        'locationName': locationName,
        'elementName': 'TEMP,HUMD,Weather',
      });

      if (response.statusCode == 200) {
        final data = response.data;
        final currentWeather = _parseCurrentWeatherResponse(data, locationName);
        if (currentWeather != null) {
          _cache[cacheKey] = currentWeather.toJson();
          _cacheTimestamps[cacheKey] = DateTime.now();
          return currentWeather;
        }
      }
      throw Exception('API 請求失敗');
    } catch (e) {
      return _generateSmartMockWeather(locationName);
    }
  }

  Future<WeatherForecast?> getWeatherForecast(String locationName) async {
    final cacheKey = 'forecast_$locationName';
    if (_isValidCache(cacheKey)) {
      return WeatherForecast.fromJson(_cache[cacheKey]);
    }

    try {
      final response = await _dio.get('/F-C0032-001', queryParameters: {
        'Authorization': AppConfig.cwaApiKey,
        'locationName': locationName,
        'elementName': 'Wx,PoP,MinT,MaxT',
      });
       
      if (response.statusCode == 200) {
        final data = response.data;
        final forecast = _parseForecastResponse(data, locationName);
        if (forecast != null) {
          _cache[cacheKey] = forecast.toJson();
          _cacheTimestamps[cacheKey] = DateTime.now();
          return forecast;
        }
      }
       throw Exception('API 請求失敗');
    } catch(e) {
      return _generateSmartMockForecast(locationName);
    }
  }
  
  CurrentWeather? _parseCurrentWeatherResponse(Map<String, dynamic> data, String locationName) {
    try {
      final records = data['records']['location'] as List;
      if (records.isEmpty) { return null; }
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
      for (int i = 0; i < wx.length && i < 7; i++) {
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
      return null;
    }
  }

  CurrentWeather _generateSmartMockWeather(String locationName) {
    return CurrentWeather(temperature: 28, description: "晴時多雲", humidity: 75, pressure: 1012);
  }

  WeatherForecast _generateSmartMockForecast(String locationName) {
    return WeatherForecast(dailyForecasts: []);
  }

  bool _isValidCache(String key) {
    if (!_cache.containsKey(key) || !_cacheTimestamps.containsKey(key)) { return false; }
    final cacheTime = _cacheTimestamps[key]!;
    return DateTime.now().difference(cacheTime) < AppConfig.weatherCacheExpiry;
  }

  String _generateCardId(String locationCode) {
    return 'weather_${locationCode}_${DateTime.now().millisecondsSinceEpoch}';
  }

  void dispose() {
    _cache.clear();
    _cacheTimestamps.clear();
  }
}
