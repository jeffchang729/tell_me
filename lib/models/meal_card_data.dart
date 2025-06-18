// lib/models/meal_card_data.dart
// 餐點資訊卡片的資料模型

class MealCardData {
  MealCardData({
    required this.title,
    required this.imagePath,
    required this.calories,
    required this.items,
    required this.startColor,
    required this.endColor,
    this.isRecommendation = false,
  });

  final String title;
  final String imagePath;
  final int calories;
  final List<String> items;
  final String startColor;
  final String endColor;
  final bool isRecommendation;

  // 靜態資料列表，模擬從後端獲取的餐點內容
  static List<MealCardData> mealCards = [
    MealCardData(
      title: 'Breakfast',
      imagePath: 'assets/fitness_app/breakfast.png', // 確保這個圖片存在
      calories: 525,
      items: ['Bread,', 'Peanut butter,', 'Apple'],
      startColor: '#FA7D82',
      endColor: '#FFB295',
    ),
    MealCardData(
      title: 'Lunch',
      imagePath: 'assets/fitness_app/lunch.png', // 確保這個圖片存在
      calories: 602,
      items: ['Salmon,', 'Mixed veggies,', 'Avocado'],
      startColor: '#738AE6',
      endColor: '#5C5EDD',
    ),
    MealCardData(
      title: 'Snack',
      imagePath: 'assets/fitness_app/snack.png', // 確保這個圖片存在
      calories: 800,
      items: ['Recommend:', '800 kcal'],
      startColor: '#FE95B6',
      endColor: '#FF5287',
      isRecommendation: true,
    ),
    MealCardData(
      title: 'Dinner',
      imagePath: 'assets/fitness_app/dinner.png', // 確保這個圖片存在
      calories: 703,
      items: ['Recommend:', '703 kcal'],
      startColor: '#6F72CA',
      endColor: '#1E1466',
      isRecommendation: true,
    ),
  ];
}
