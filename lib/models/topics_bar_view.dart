// lib/widgets/feed/topics_bar_view.dart
// 頂部資訊主題頁籤列 (仿 IG Story 樣式)

import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../models/topic_data.dart';

class TopicsBarView extends StatefulWidget {
  const TopicsBarView({Key? key, required this.topics}) : super(key: key);

  final List<TopicData> topics;

  @override
  _TopicsBarViewState createState() => _TopicsBarViewState();
}

class _TopicsBarViewState extends State<TopicsBarView> {
  late List<TopicData> _topics;

  @override
  void initState() {
    super.initState();
    _topics = widget.topics;
  }

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
        itemCount: _topics.length,
        itemBuilder: (context, index) {
          return _buildTopicItem(_topics[index], index);
        },
      ),
    );
  }

  // 建立單個主題頁籤
  Widget _buildTopicItem(TopicData topic, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          for (var t in _topics) {
            t.isSelected = false;
          }
          topic.isSelected = true;
        });
        // 之後可以在這裡觸發點擊事件，例如更新下方的資訊流
      },
      child: Container(
        width: 75,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 圓形圖示區
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: topic.isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFFd92e7f), Color(0xFFf16d4a), Color(0xFFfec66c)],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      )
                    : null,
                border: !topic.isSelected
                    ? Border.all(color: AppTheme.grey.withOpacity(0.2), width: 2)
                    : null,
              ),
              child: Padding(
                padding: const EdgeInsets.all(2.5),
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      topic.title.substring(0, 1), // 取得主題的第一個字
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: topic.isSelected ? AppTheme.nearlyDarkBlue : AppTheme.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            // 主題文字
            Text(
              topic.title,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                fontSize: 12,
                color: topic.isSelected ? AppTheme.darkerText : AppTheme.grey,
                fontWeight: topic.isSelected ? FontWeight.bold : FontWeight.normal
              ),
            ),
          ],
        ),
      ),
    );
  }
}
