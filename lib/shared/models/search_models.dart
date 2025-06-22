// lib/shared/models/search_models.dart
// 通用搜尋結果模型 - 最終修正版
// 功能：定義一個可以容納多種類型資訊的通用搜尋結果結構，並使其可以被儲存和讀取。

import 'package:tell_me/shared/models/weather_models.dart';

// ------------------- 枚舉：搜尋結果類型 -------------------
enum SearchResultType {
  weather,
  stock,
  news,
  event,
  unsupported,
}

// ------------------- 基礎類別：通用搜尋結果 -------------------
abstract class UniversalSearchResult {
  String get id;
  SearchResultType get type;
  String get title;
  String get subtitle;
  dynamic get data;
  int get relevance;

  // 新增一個 const 建構子，讓子類別可以呼叫。
  const UniversalSearchResult();

  /// 將物件轉換為可儲存的 JSON Map
  Map<String, dynamic> toJson();

  /// 從 JSON Map 建立對應的物件實例
  factory UniversalSearchResult.fromJson(Map<String, dynamic> json) {
    final type = SearchResultType.values.firstWhere(
      (e) => e.toString() == json['type'],
      orElse: () => SearchResultType.unsupported,
    );

    switch (type) {
      case SearchResultType.weather:
        return WeatherSearchResultItem.fromJson(json);
      case SearchResultType.stock:
        return StockSearchResultItem.fromJson(json);
      case SearchResultType.news:
        return NewsSearchResultItem.fromJson(json);
      default:
        throw Exception('不支援的搜尋結果類型: $type');
    }
  }
}

// ------------------- 實作：天氣搜尋結果 -------------------
class WeatherSearchResultItem extends UniversalSearchResult {
  @override
  final String id;
  @override
  final SearchResultType type = SearchResultType.weather;
  @override
  final String title;
  @override
  final String subtitle;
  @override
  final WeatherCardData data;
  @override
  final int relevance;

  const WeatherSearchResultItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.data,
    this.relevance = 90,
  }) : super();

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.toString(),
        'title': title,
        'subtitle': subtitle,
        'data': data.toJson(),
        'relevance': relevance,
      };

  factory WeatherSearchResultItem.fromJson(Map<String, dynamic> json) {
    return WeatherSearchResultItem(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      data: WeatherCardData.fromJson(json['data']),
      relevance: json['relevance'],
    );
  }
}

// ------------------- 佔位符：股票搜尋結果 -------------------
class StockSearchResultItem extends UniversalSearchResult {
  @override
  final String id;
  @override
  final SearchResultType type = SearchResultType.stock;
  @override
  final String title;
  @override
  final String subtitle;
  @override
  final dynamic data;
  @override
  final int relevance;

  const StockSearchResultItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.data,
    this.relevance = 100,
  }) : super();

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.toString(),
        'title': title,
        'subtitle': subtitle,
        'data': data,
        'relevance': relevance,
      };

  factory StockSearchResultItem.fromJson(Map<String, dynamic> json) {
    return StockSearchResultItem(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      data: json['data'],
      relevance: json['relevance'],
    );
  }
}

// ------------------- 佔位符：新聞搜尋結果 -------------------
class NewsSearchResultItem extends UniversalSearchResult {
  @override
  final String id;
  @override
  final SearchResultType type = SearchResultType.news;
  @override
  final String title;
  @override
  final String subtitle;
  @override
  final dynamic data;
  @override
  final int relevance;
  
  const NewsSearchResultItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.data,
    this.relevance = 80,
  }) : super();
  
  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.toString(),
        'title': title,
        'subtitle': subtitle,
        'data': data,
        'relevance': relevance,
      };

  factory NewsSearchResultItem.fromJson(Map<String, dynamic> json) {
    return NewsSearchResultItem(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      data: json['data'],
      relevance: json['relevance'],
    );
  }
}
