// lib/widgets/dashboard/info_topics_bar.dart
// 儀表板的資訊主題頁籤列 (仿IG Story樣式)
// 功能: 提供一個水平滾動的圓形頁籤列，讓使用者可以快速切換感興趣的資訊主題。

import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

/// 資訊主題頁籤的資料模型
class Topic {
  final String title;
  final IconData icon;

  Topic({required this.title, required this.icon});
}

/// 資訊主題頁籤列主元件
class InfoTopicsBar extends StatefulWidget {
  const InfoTopicsBar({
    Key? key,
    required this.onTopicSelected,
  }) : super(key: key);

  // 當使用者點擊一個主題時的回呼函式
  final Function(String topicTitle) onTopicSelected;

  @override
  _InfoTopicsBarState createState() => _InfoTopicsBarState();
}

class _InfoTopicsBarState extends State<InfoTopicsBar> {
  // ==================== 狀態變數 ====================

  /// 模擬的使用者自訂主題清單
  final List<Topic> _topics = [
    Topic(title: '今日頭條', icon: Icons.article_outlined),
    Topic(title: '天氣', icon: Icons.wb_sunny_outlined),
    Topic(title: '股票', icon: Icons.trending_up),
    Topic(title: '國際', icon: Icons.public),
    Topic(title: '科技', icon: Icons.memory),
    Topic(title: '運動', icon: Icons.sports_basketball_outlined),
    Topic(title: '娛樂', icon: Icons.movie_filter_outlined),
  ];

  /// 目前選中的主題索引
  int _selectedIndex = 0;

  // ==================== UI 建構方法 ====================
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110, // 給予固定的高度
      decoration: const BoxDecoration(
        color: AppTheme.white,
        border: Border(
          bottom: BorderSide(color: AppTheme.background, width: 1),
        ),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        scrollDirection: Axis.horizontal,
        itemCount: _topics.length,
        itemBuilder: (context, index) {
          final topic = _topics[index];
          final isSelected = _selectedIndex == index;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: _TopicBubble(
              topic: topic,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  _selectedIndex = index;
                });
                // 觸發回呼，將選中的主題名稱傳遞出去
                widget.onTopicSelected(topic.title);
              },
            ),
          );
        },
      ),
    );
  }
}

/// 單一圓形頁籤元件
class _TopicBubble extends StatelessWidget {
  const _TopicBubble({
    Key? key,
    required this.topic,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  final Topic topic;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 圓形外框和圖示
          Container(
            width: 68,
            height: 68,
            padding: const EdgeInsets.all(3.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // 根據是否選中，顯示不同的漸層或灰色外框
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [
                        Color(0xFFd92e7f),
                        Color(0xFFf16d4a),
                        Color(0xFFfec66c),
                      ],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    )
                  : null,
              border: !isSelected
                  ? Border.all(color: Colors.grey.shade300, width: 2)
                  : null,
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.white,
                border: Border.all(color: AppTheme.white, width: 2),
              ),
              child: Icon(
                topic.icon,
                color: isSelected ? AppTheme.nearlyDarkBlue : AppTheme.grey,
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: 6),
          // 主題標題
          Text(
            topic.title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? AppTheme.darkerText : AppTheme.grey,
            ),
          ),
        ],
      ),
    );
  }
}
