// shared/widgets/feed/weather_post_card.dart
// 天氣資訊貼文卡片 - 更新漸層效果
// 功能：在貼文流中顯示豐富的天氣資訊，並提供「建立卡片」按鈕。

import 'package:flutter/material.dart';
import 'package:tell_me/core/theme/app_theme.dart';
import 'package:tell_me/core/utils/app_utils.dart';
import 'package:tell_me/shared/models/weather_models.dart';

class WeatherPostCard extends StatelessWidget {
  final WeatherCardData weatherData;
  final VoidCallback? onCreateCard;
  final bool showCreateButton;

  const WeatherPostCard({
    Key? key,
    required this.weatherData,
    this.onCreateCard,
    this.showCreateButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: const BoxDecoration(
        color: AppTheme.white,
        border: Border(bottom: BorderSide(color: AppTheme.background, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPostHeader(),
          _buildMainWeatherCard(),
          _buildHourlyForecast(),
          if (weatherData.forecast != null) _buildDailyForecast(),
          if (showCreateButton) _buildActionButtons(),
          _buildPostFooter(),
        ],
      ),
    );
  }

  Widget _buildPostHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: HexColor(weatherData.cardColor).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.cloud_outlined,
              color: HexColor(weatherData.cardColor),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '天氣預報',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppTheme.darkerText,
                  ),
                ),
                Text(
                  weatherData.locationName,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.grey,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.more_horiz,
            color: AppTheme.grey,
            size: 20,
          ),
        ],
      ),
    );
  }

  /// [美化] 建立主要天氣卡片
  /// 更新漸層效果，使其更豐富、更有層次感。
  Widget _buildMainWeatherCard() {
    final currentWeather = weatherData.currentWeather;
    // 定義一組漂亮的藍色漸層
    final List<Color> gradientColors = [
      const Color(0xFF4A90E2),
      const Color(0xFF50C9C3)
    ];

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withOpacity(0.4),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${currentWeather.temperature.round()}°',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.white,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentWeather.description,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppTheme.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      currentWeather.comfortLevel,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Icon(
                      _getWeatherIcon(currentWeather.temperature),
                      size: 64,
                      color: AppTheme.white,
                    ),
                    const SizedBox(height: 8),
                    if (weatherData.forecast?.dailyForecasts.isNotEmpty ==
                        true)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          weatherData.forecast!.dailyForecasts.first.temperatureRange,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWeatherDetail(
                  Icons.water_drop_outlined,
                  '濕度',
                  '${currentWeather.humidity}%',
                ),
                _buildWeatherDetail(
                  Icons.air,
                  '風速',
                  currentWeather.windSpeed != null
                      ? '${currentWeather.windSpeed!.toStringAsFixed(1)} m/s'
                      : '無資料',
                ),
                _buildWeatherDetail(
                  Icons.compress,
                  '氣壓',
                  '${currentWeather.pressure.toStringAsFixed(0)} hPa',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDetail(IconData icon, String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: AppTheme.white.withOpacity(0.8),
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.white,
          ),
        ),
      ],
    );
  }

  Widget _buildHourlyForecast() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(radius: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.schedule,
                color: AppTheme.nearlyDarkBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '24小時預報',
                style: AppTheme.title.copyWith(
                  fontSize: 16,
                  color: AppTheme.darkerText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 8, // 顯示8個時段（24小時，每3小時一個）
              itemBuilder: (context, index) {
                final hour = DateTime.now().add(Duration(hours: index * 3));
                final temp = weatherData.currentWeather.temperature +
                    (index % 2 == 0 ? -1 : 1) * (index * 0.5);

                return Container(
                  width: 60,
                  margin: const EdgeInsets.only(right: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        index == 0
                            ? '現在'
                            : AppUtils.formatTime(hour, format: 'HH:mm'),
                        style: AppTheme.caption.copyWith(
                          color: AppTheme.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(
                        _getWeatherIcon(temp),
                        color: AppTheme.nearlyDarkBlue,
                        size: 28,
                      ),
                      Text(
                        '${temp.round()}°',
                        style: AppTheme.body1.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.darkerText,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyForecast() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(radius: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                color: AppTheme.nearlyDarkBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '7天預報',
                style: AppTheme.title.copyWith(
                  fontSize: 16,
                  color: AppTheme.darkerText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...weatherData.forecast!.dailyForecasts.take(7).map(
                (forecast) => _buildDailyForecastItem(forecast),
              ),
        ],
      ),
    );
  }

  Widget _buildDailyForecastItem(DailyForecast forecast) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              forecast.dateText,
              style: AppTheme.body1.copyWith(
                color: AppTheme.darkText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(
            _getWeatherIcon(forecast.maxTemperature.toDouble()),
            color: AppTheme.nearlyDarkBlue,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              forecast.description,
              style: AppTheme.body2.copyWith(
                color: AppTheme.grey,
              ),
            ),
          ),
          if (forecast.rainProbability != null && forecast.rainProbability! > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: AppTheme.nearlyBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.water_drop,
                    size: 12,
                    color: AppTheme.nearlyBlue,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${forecast.rainProbability}%',
                    style: AppTheme.caption.copyWith(
                      color: AppTheme.nearlyBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(
            width: 70,
            child: Text(
              forecast.temperatureRange,
              textAlign: TextAlign.right,
              style: AppTheme.body1.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.darkerText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: onCreateCard,
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: const Text('建立卡片'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.nearlyDarkBlue,
                foregroundColor: AppTheme.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 1,
            child: OutlinedButton.icon(
              onPressed: () {
                print('分享天氣資訊: ${weatherData.locationName}');
              },
              icon: const Icon(Icons.share, size: 18),
              label: const Text('分享'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.nearlyDarkBlue,
                side: const BorderSide(color: AppTheme.nearlyDarkBlue),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                size: 14,
                color: AppTheme.grey,
              ),
              const SizedBox(width: 4),
              Text(
                '資料來源：中央氣象署',
                style: AppTheme.caption.copyWith(
                  color: AppTheme.grey,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (weatherData.currentWeather.updateTime != null)
            Row(
              children: [
                const Icon(
                  Icons.schedule,
                  size: 14,
                  color: AppTheme.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  '更新：${AppUtils.formatTime(weatherData.currentWeather.updateTime!)}',
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.grey,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  IconData _getWeatherIcon(double temperature) {
    if (temperature >= 30) {
      return Icons.wb_sunny; // 炎熱 - 太陽
    } else if (temperature >= 25) {
      return Icons.wb_sunny_outlined; // 溫暖 - 太陽輪廓
    } else if (temperature >= 20) {
      return Icons.wb_cloudy; // 舒適 - 多雲
    } else if (temperature >= 15) {
      return Icons.cloud; // 涼爽 - 雲朵
    } else {
      return Icons.ac_unit; // 寒冷 - 雪花
    }
  }
}
