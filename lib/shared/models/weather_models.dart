// shared/models/weather_models.dart
// 天氣資料模型
// 功能：定義天氣相關的資料結構

/// 天氣卡片資料模型
/// 
/// 用於表示搜尋結果和儀表板上的天氣資訊卡片
class WeatherCardData {
  WeatherCardData({
    required this.id,
    required this.locationName,
    required this.currentWeather,
    this.forecast,
    this.cardColor = '#4A90E2',
    this.createdAt,
  });

  /// 卡片唯一識別碼
  final String id;
  
  /// 地點名稱（如：台北市）
  final String locationName;
  
  /// 目前天氣狀況
  final CurrentWeather currentWeather;
  
  /// 預報資料（可選）
  final WeatherForecast? forecast;
  
  /// 卡片顏色
  final String cardColor;
  
  /// 建立時間
  final DateTime? createdAt;

  /// 複製並修改天氣卡片資料
  WeatherCardData copyWith({
    String? id,
    String? locationName,
    CurrentWeather? currentWeather,
    WeatherForecast? forecast,
    String? cardColor,
    DateTime? createdAt,
  }) {
    return WeatherCardData(
      id: id ?? this.id,
      locationName: locationName ?? this.locationName,
      currentWeather: currentWeather ?? this.currentWeather,
      forecast: forecast ?? this.forecast,
      cardColor: cardColor ?? this.cardColor,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// 轉換為JSON格式
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'locationName': locationName,
      'currentWeather': currentWeather.toJson(),
      'forecast': forecast?.toJson(),
      'cardColor': cardColor,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  /// 從JSON建立物件
  factory WeatherCardData.fromJson(Map<String, dynamic> json) {
    return WeatherCardData(
      id: json['id'],
      locationName: json['locationName'],
      currentWeather: CurrentWeather.fromJson(json['currentWeather']),
      forecast: json['forecast'] != null 
          ? WeatherForecast.fromJson(json['forecast'])
          : null,
      cardColor: json['cardColor'] ?? '#4A90E2',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }
}

/// 目前天氣資料模型
/// 
/// 包含當前的天氣狀況資訊
class CurrentWeather {
  CurrentWeather({
    required this.temperature,
    required this.description,
    required this.humidity,
    required this.pressure,
    this.windSpeed,
    this.windDirection,
    this.visibility,
    this.weatherIcon,
    this.updateTime,
  });

  /// 溫度（攝氏度）
  final double temperature;
  
  /// 天氣描述（如：晴時多雲）
  final String description;
  
  /// 相對濕度（%）
  final int humidity;
  
  /// 氣壓（百帕）
  final double pressure;
  
  /// 風速（公尺/秒）
  final double? windSpeed;
  
  /// 風向（度）
  final int? windDirection;
  
  /// 能見度（公里）
  final double? visibility;
  
  /// 天氣圖示代碼
  final String? weatherIcon;
  
  /// 資料更新時間
  final DateTime? updateTime;

  /// 取得風向文字描述
  String get windDirectionText {
    if (windDirection == null) return '無資料';
    
    const directions = [
      '北', '北北東', '東北', '東北東',
      '東', '東南東', '東南', '南南東',
      '南', '南南西', '西南', '西南西',
      '西', '西北西', '西北', '北北西'
    ];
    
    final index = ((windDirection! + 11.25) / 22.5).floor() % 16;
    return directions[index];
  }

  /// 取得體感描述
  String get comfortLevel {
    if (temperature >= 30) return '炎熱';
    if (temperature >= 25) return '溫暖';
    if (temperature >= 20) return '舒適';
    if (temperature >= 15) return '涼爽';
    if (temperature >= 10) return '寒冷';
    return '非常寒冷';
  }

  /// 轉換為JSON格式
  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'description': description,
      'humidity': humidity,
      'pressure': pressure,
      'windSpeed': windSpeed,
      'windDirection': windDirection,
      'visibility': visibility,
      'weatherIcon': weatherIcon,
      'updateTime': updateTime?.toIso8601String(),
    };
  }

  /// 從JSON建立物件
  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temperature: json['temperature'].toDouble(),
      description: json['description'],
      humidity: json['humidity'],
      pressure: json['pressure'].toDouble(),
      windSpeed: json['windSpeed']?.toDouble(),
      windDirection: json['windDirection'],
      visibility: json['visibility']?.toDouble(),
      weatherIcon: json['weatherIcon'],
      updateTime: json['updateTime'] != null 
          ? DateTime.parse(json['updateTime'])
          : null,
    );
  }
}

/// 天氣預報資料模型
/// 
/// 包含未來幾天的天氣預報
class WeatherForecast {
  WeatherForecast({
    required this.dailyForecasts,
    this.updateTime,
  });

  /// 每日預報清單
  final List<DailyForecast> dailyForecasts;
  
  /// 預報資料更新時間
  final DateTime? updateTime;

  /// 取得今天的預報
  DailyForecast? get todayForecast {
    final today = DateTime.now();
    return dailyForecasts.cast<DailyForecast?>().firstWhere(
      (forecast) => forecast != null && 
          forecast.date.year == today.year &&
          forecast.date.month == today.month &&
          forecast.date.day == today.day,
      orElse: () => null,
    );
  }

  /// 取得明天的預報
  DailyForecast? get tomorrowForecast {
    final tomorrow = DateTime.now().add(Duration(days: 1));
    return dailyForecasts.cast<DailyForecast?>().firstWhere(
      (forecast) => forecast != null &&
          forecast.date.year == tomorrow.year &&
          forecast.date.month == tomorrow.month &&
          forecast.date.day == tomorrow.day,
      orElse: () => null,
    );
  }

  /// 轉換為JSON格式
  Map<String, dynamic> toJson() {
    return {
      'dailyForecasts': dailyForecasts.map((f) => f.toJson()).toList(),
      'updateTime': updateTime?.toIso8601String(),
    };
  }

  /// 從JSON建立物件
  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    return WeatherForecast(
      dailyForecasts: (json['dailyForecasts'] as List)
          .map((item) => DailyForecast.fromJson(item))
          .toList(),
      updateTime: json['updateTime'] != null 
          ? DateTime.parse(json['updateTime'])
          : null,
    );
  }
}

/// 每日天氣預報模型
/// 
/// 表示單一天的天氣預報資訊
class DailyForecast {
  DailyForecast({
    required this.date,
    required this.maxTemperature,
    required this.minTemperature,
    required this.description,
    this.rainProbability,
    this.weatherIcon,
  });

  /// 預報日期
  final DateTime date;
  
  /// 最高溫度
  final double maxTemperature;
  
  /// 最低溫度
  final double minTemperature;
  
  /// 天氣描述
  final String description;
  
  /// 降雨機率（%）
  final int? rainProbability;
  
  /// 天氣圖示代碼
  final String? weatherIcon;

  /// 取得日期顯示文字
  String get dateText {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final forecastDate = DateTime(date.year, date.month, date.day);
    
    final difference = forecastDate.difference(today).inDays;
    
    switch (difference) {
      case 0:
        return '今天';
      case 1:
        return '明天';
      case 2:
        return '後天';
      default:
        return '${date.month}/${date.day}';
    }
  }

  /// 取得溫度範圍文字
  String get temperatureRange => '${minTemperature.round()}° - ${maxTemperature.round()}°';

  /// 轉換為JSON格式
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'maxTemperature': maxTemperature,
      'minTemperature': minTemperature,
      'description': description,
      'rainProbability': rainProbability,
      'weatherIcon': weatherIcon,
    };
  }

  /// 從JSON建立物件
  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      date: DateTime.parse(json['date']),
      maxTemperature: json['maxTemperature'].toDouble(),
      minTemperature: json['minTemperature'].toDouble(),
      description: json['description'],
      rainProbability: json['rainProbability'],
      weatherIcon: json['weatherIcon'],
    );
  }
}

/// 天氣搜尋結果模型
/// 
/// 表示搜尋API返回的結果
class WeatherSearchResult {
  WeatherSearchResult({
    required this.locationName,
    required this.fullLocationName,
    required this.locationCode,
    this.latitude,
    this.longitude,
  });

  /// 地點名稱（簡短）
  final String locationName;
  
  /// 完整地點名稱
  final String fullLocationName;
  
  /// 地點代碼（用於API查詢）
  final String locationCode;
  
  /// 緯度
  final double? latitude;
  
  /// 經度
  final double? longitude;

  /// 轉換為JSON格式
  Map<String, dynamic> toJson() {
    return {
      'locationName': locationName,
      'fullLocationName': fullLocationName,
      'locationCode': locationCode,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  /// 從JSON建立物件
  factory WeatherSearchResult.fromJson(Map<String, dynamic> json) {
    return WeatherSearchResult(
      locationName: json['locationName'],
      fullLocationName: json['fullLocationName'],
      locationCode: json['locationCode'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }
}

/// 天氣API回應狀態列舉
enum WeatherApiStatus {
  loading,    // 載入中
  success,    // 成功
  error,      // 錯誤
  noData,     // 無資料
}

/// 天氣資料來源列舉
enum WeatherDataSource {
  cwa,           // 台灣氣象署
  openWeather,   // OpenWeatherMap
  cache,         // 快取資料
}

/// 天氣卡片類型列舉
enum WeatherCardType {
  current,    // 目前天氣
  forecast,   // 預報天氣
  combined,   // 綜合資訊
}