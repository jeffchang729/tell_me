// shared/services/fake_data_service.dart
// 假資料服務 - 完全修正版本
// 功能：提供天氣、新聞、股市的假資料，方便開發和測試

import 'dart:math';
import '../models/weather_models.dart';
import '../models/feed_models.dart';

class FakeDataService {
  static final FakeDataService _instance = FakeDataService._internal();
  factory FakeDataService() => _instance;
  FakeDataService._internal();

  final Random _random = Random();

  // ==================== 天氣假資料 ====================
  
  /// 取得假的天氣資料清單
  List<WeatherCardData> getFakeWeatherData() {
    return [
      WeatherCardData(
        id: 'taipei_weather',
        locationName: '台北市',
        cardColor: '#5C9DFF',
        currentWeather: CurrentWeather(
          temperature: 25.0 + _random.nextDouble() * 10,
          description: _getRandomWeatherDescription(),
          humidity: 50 + _random.nextInt(40),
          pressure: 1020.0 + _random.nextDouble() * 20,
          windSpeed: 2.0 + _random.nextDouble() * 8,
          updateTime: DateTime.now(),
        ),
        forecast: WeatherForecast(
          dailyForecasts: _generateDailyForecasts(),
        ),
      ),
      WeatherCardData(
        id: 'kaohsiung_weather',
        locationName: '高雄市',
        cardColor: '#FF6B6B',
        currentWeather: CurrentWeather(
          temperature: 28.0 + _random.nextDouble() * 8,
          description: _getRandomWeatherDescription(),
          humidity: 45 + _random.nextInt(35),
          pressure: 1015.0 + _random.nextDouble() * 25,
          windSpeed: 3.0 + _random.nextDouble() * 6,
          updateTime: DateTime.now(),
        ),
        forecast: WeatherForecast(
          dailyForecasts: _generateDailyForecasts(),
        ),
      ),
      WeatherCardData(
        id: 'taichung_weather',
        locationName: '台中市',
        cardColor: '#4ECDC4',
        currentWeather: CurrentWeather(
          temperature: 26.0 + _random.nextDouble() * 9,
          description: _getRandomWeatherDescription(),
          humidity: 55 + _random.nextInt(30),
          pressure: 1025.0 + _random.nextDouble() * 15,
          windSpeed: 2.5 + _random.nextDouble() * 7,
          updateTime: DateTime.now(),
        ),
        forecast: WeatherForecast(
          dailyForecasts: _generateDailyForecasts(),
        ),
      ),
    ];
  }

  /// 隨機天氣描述
  String _getRandomWeatherDescription() {
    final descriptions = [
      '晴朗', '多雲', '陰天', '小雨', '陣雨', 
      '晴時多雲', '多雲時晴', '陰時多雲', '雷陣雨'
    ];
    return descriptions[_random.nextInt(descriptions.length)];
  }

  /// 產生每日預報資料
  List<DailyForecast> _generateDailyForecasts() {
    return List.generate(7, (index) {
      final date = DateTime.now().add(Duration(days: index));
      final maxTemp = 20 + _random.nextInt(15);
      final minTemp = maxTemp - 5 - _random.nextInt(8);
      
      return DailyForecast(
        date: date,
        description: _getRandomWeatherDescription(),
        maxTemperature: maxTemp.toDouble(),
        minTemperature: minTemp.toDouble(),
        rainProbability: _random.nextInt(100),
      );
    });
  }

  // ==================== 新聞假資料 ====================
  
  /// 取得假的新聞資料清單
  List<PostData> getFakeNewsData() {
    return [
      PostData(
        userName: 'TechNews Taiwan',
        cardTitle: '科技新聞',
        cardSubtitle: 'AI技術突破',
        cardGradientStart: '#FF6B6B',
        cardGradientEnd: '#FF8E53',
        caption: '人工智慧技術在醫療領域取得重大突破，新的AI診斷系統準確率達到95%以上。',
        likesCount: 1250 + _random.nextInt(2000),
        comments: [],
        timeAgo: '${1 + _random.nextInt(12)}小時前',
        location: '台灣',
      ),
      PostData(
        userName: 'Global News',
        cardTitle: '國際要聞',
        cardSubtitle: '經濟動向',
        cardGradientStart: '#4ECDC4',
        cardGradientEnd: '#44A08D',
        caption: '全球經濟復甦跡象明顯，多國央行調整貨幣政策應對通膨壓力。',
        likesCount: 890 + _random.nextInt(1500),
        comments: [],
        timeAgo: '${2 + _random.nextInt(8)}小時前',
        location: '國際',
      ),
      PostData(
        userName: 'Sports Daily',
        cardTitle: '體育新聞',
        cardSubtitle: '賽事報導',
        cardGradientStart: '#A8EDEA',
        cardGradientEnd: '#FED6E3',
        caption: '台灣選手在國際賽事中表現優異，為國爭光獲得多面金牌。',
        likesCount: 2100 + _random.nextInt(3000),
        comments: [],
        timeAgo: '${3 + _random.nextInt(6)}小時前',
        location: '體育',
      ),
    ];
  }

  // ==================== 股市假資料 ====================
  
  /// 取得假的股市資料清單
  List<Map<String, dynamic>> getFakeStockData() {
    return [
      {
        'symbol': '2330',
        'name': '台積電',
        'price': 580.0 + _random.nextDouble() * 100,
        'change': (-20 + _random.nextDouble() * 40),
        'changePercent': (-3.0 + _random.nextDouble() * 6),
        'volume': '${(10000 + _random.nextInt(50000))}張',
        'marketCap': '15.2兆',
        'cardColor': '#FF6B6B',
      },
      {
        'symbol': '2317',
        'name': '鴻海',
        'price': 120.0 + _random.nextDouble() * 50,
        'change': (-10 + _random.nextDouble() * 20),
        'changePercent': (-2.0 + _random.nextDouble() * 4),
        'volume': '${(8000 + _random.nextInt(30000))}張',
        'marketCap': '1.7兆',
        'cardColor': '#4ECDC4',
      },
      {
        'symbol': '2454',
        'name': '聯發科',
        'price': 800.0 + _random.nextDouble() * 200,
        'change': (-30 + _random.nextDouble() * 60),
        'changePercent': (-4.0 + _random.nextDouble() * 8),
        'volume': '${(5000 + _random.nextInt(25000))}張',
        'marketCap': '1.3兆',
        'cardColor': '#FFD93D',
      },
    ];
  }

  // ==================== 混合資料 ====================
  
  /// 取得混合的首頁內容
  List<dynamic> getMixedHomeContent() {
    final content = <dynamic>[];
    
    // 添加天氣資料
    content.addAll(getFakeWeatherData());
    
    // 添加新聞資料
    content.addAll(getFakeNewsData());
    
    // 添加股市資料
    content.addAll(getFakeStockData());
    
    // 隨機排序
    content.shuffle(_random);
    
    return content;
  }

  /// 根據類型取得特定資料
  List<dynamic> getDataByType(String type) {
    switch (type.toLowerCase()) {
      case 'weather':
      case '天氣':
        return getFakeWeatherData();
      case 'news':
      case '新聞':
        return getFakeNewsData();
      case 'stock':
      case '股市':
        return getFakeStockData();
      default:
        return getMixedHomeContent();
    }
  }

  /// 模擬網路延遲
  Future<List<dynamic>> getDataWithDelay(String type, {int delayMs = 500}) async {
    await Future.delayed(Duration(milliseconds: delayMs));
    return getDataByType(type);
  }
}