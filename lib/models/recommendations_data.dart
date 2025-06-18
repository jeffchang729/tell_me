// lib/models/recommendations_data.dart
// 推薦內容資料模型 (源自 BOOK ME)
// 功能: 定義推薦卡片所需的資料結構。

class RecommendationsData {
  RecommendationsData({
    this.imagePath = '',
    this.titleTxt = '',
    this.startColor = '',
    this.endColor = '',
    this.items,
    this.rating = 0.0,
    this.status = '',
    this.statusColor = '',
  });

  String imagePath;
  String titleTxt;
  String startColor;
  String endColor;
  List<String>? items;
  double rating;
  String status;
  String statusColor;

  // 靜態資料列表，模擬從後端獲取的推薦內容
  static List<RecommendationsData> recommendationsList = <RecommendationsData>[
    RecommendationsData(
      imagePath: 'assets/fitness_app/breakfast.png', // 暫用舊圖示
      titleTxt: '財經新聞',
      items: <String>['台股焦點', '國際匯率', '加密貨幣'],
      startColor: '#738AE6',
      endColor: '#5C5EDD',
      rating: 4.5,
      status: '熱門',
      statusColor: '#d92e7f',
    ),
    RecommendationsData(
      imagePath: 'assets/fitness_app/lunch.png', // 暫用舊圖示
      titleTxt: '科技趨勢',
      items: <String>['AI 新知', '晶片大戰', '元宇宙'],
      startColor: '#FE95B6',
      endColor: '#FF5287',
      rating: 4.8,
      status: '最新',
      statusColor: '#f16d4a',
    ),
    RecommendationsData(
      imagePath: 'assets/fitness_app/snack.png', // 暫用舊圖示
      titleTxt: '天氣資訊',
      items: <String>['目前天氣', '一週預報', '空氣品質'],
      startColor: '#FA7D82',
      endColor: '#FFB295',
      rating: 0.0, // 0.0 表示顯示按鈕而非評分
      status: '即時',
      statusColor: '#6C7CE7',
    ),
  ];
}
