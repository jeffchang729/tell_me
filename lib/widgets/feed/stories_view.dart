// lib/widgets/feed/stories_view.dart
// "限時動態" 水平滾動列表

import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../models/feed_models.dart';

class StoriesView extends StatelessWidget {
  final List<StoryData> stories;

  const StoriesView({Key? key, required this.stories}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppTheme.white,
        border: Border(bottom: BorderSide(color: AppTheme.background, width: 1.0)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        itemCount: stories.length,
        itemBuilder: (context, index) {
          return _buildStoryItem(stories[index]);
        },
      ),
    );
  }

  Widget _buildStoryItem(StoryData story) {
    return Container(
      width: 75,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: story.hasNewStory
                  ? const LinearGradient(
                      colors: [Color(0xFFd92e7f), Color(0xFFf16d4a), Color(0xFFfec66c)],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    )
                  : null,
              color: story.hasNewStory ? null : AppTheme.grey.withOpacity(0.2),
            ),
            child: Padding(
              padding: const EdgeInsets.all(2.5),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppTheme.white,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: ClipOval(child: _buildUserAvatar(story.avatarUrl, story.name)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            story.name,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: const TextStyle(fontSize: 12, color: AppTheme.darkerText),
          ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar(String? avatarUrl, String userName) {
    // 根據 TELL ME 的概念，這裡的頭像用圖示代替
    final icons = {
      '今日頭條': Icons.article_outlined,
      '天氣': Icons.wb_sunny_outlined,
      '股票': Icons.trending_up,
      '國際': Icons.public,
    };
    final icon = icons[userName] ?? Icons.info_outline;

    return CircleAvatar(
      backgroundColor: AppTheme.grey.withOpacity(0.1),
      child: Icon(icon, color: AppTheme.grey, size: 28),
    );
  }
}
