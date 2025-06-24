// shared/models/search_models.dart
// 通用搜尋結果模型 - [最終修正]
// 功能：引入 UnsupportedSearchResultItem 來優雅地處理未知或損毀的資料類型，
//       徹底解決 UnimplementedError 的問題，並提升系統的健壯性。

import 'package:tell_me/shared/models/feed_models.dart';
import 'package:tell_me/shared/models/weather_models.dart';

enum SearchResultType {
  weather,
  stock,
  news,
  event,
  unsupported,
}

abstract class UniversalSearchResult {
  String get id;
  SearchResultType get type;
  String get title;
  String get subtitle;
  dynamic get data;
  int get relevance;

  const UniversalSearchResult();

  Map<String, dynamic> toJson();

  /// [重大修改] fromJson 工廠
  /// 現在可以安全地處理無法識別的類型，將其轉換為 UnsupportedSearchResultItem。
  factory UniversalSearchResult.fromJson(Map<String, dynamic> json) {
    final typeString = json['type'] as String?;
    final type = SearchResultType.values.firstWhere(
      (e) => e.toString() == typeString,
      orElse: () => SearchResultType.unsupported,
    );

    try {
      switch (type) {
        case SearchResultType.weather:
          return WeatherSearchResultItem.fromJson(json);
        case SearchResultType.stock:
          return StockSearchResultItem.fromJson(json);
        case SearchResultType.news:
          return NewsSearchResultItem.fromJson(json);
        case SearchResultType.event:
        case SearchResultType.unsupported:
        default:
          return UnsupportedSearchResultItem.fromJson(json);
      }
    } catch (e) {
      print('== ❌ [Deserialization Error] 解析 JSON 時發生錯誤，將其視為不支援的項目: $e');
      return UnsupportedSearchResultItem.fromJson(json);
    }
  }
}

// [新增] 一個專門用來表示未知或損毀資料的類別
class UnsupportedSearchResultItem extends UniversalSearchResult {
  @override
  final String id;
  @override
  final SearchResultType type = SearchResultType.unsupported;
  @override
  final String title;
  @override
  final String subtitle;
  @override
  final Map<String, dynamic> data;
  @override
  final int relevance;

  const UnsupportedSearchResultItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.data,
    this.relevance = 0,
  });
  
  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.toString(),
    'title': title,
    'subtitle': subtitle,
    'data': data,
    'relevance': relevance,
  };

  factory UnsupportedSearchResultItem.fromJson(Map<String, dynamic> json) {
    return UnsupportedSearchResultItem(
      id: json['id'] ?? 'unknown_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title'] ?? '未知卡片',
      subtitle: json['subtitle'] ?? '此資料已損毀或不支援',
      data: const {},
    );
  }
}


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
  });

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
      relevance: json['relevance'] ?? 90,
    );
  }
}

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
  final Map<String, dynamic> data;
  @override
  final int relevance;

  const StockSearchResultItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.data,
    this.relevance = 100,
  });

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
      data: Map<String, dynamic>.from(json['data']),
      relevance: json['relevance'] ?? 100,
    );
  }
}

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
  final PostData data;
  @override
  final int relevance;
  
  const NewsSearchResultItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.data,
    this.relevance = 80,
  });
  
  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.toString(),
        'title': title,
        'subtitle': subtitle,
        'data': data.toJson(),
        'relevance': relevance,
      };

  factory NewsSearchResultItem.fromJson(Map<String, dynamic> json) {
    return NewsSearchResultItem(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      data: PostData.fromJson(json['data']),
      relevance: json['relevance'] ?? 80,
    );
  }
}
