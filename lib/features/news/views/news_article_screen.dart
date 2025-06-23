// lib/features/news/views/news_article_screen.dart
// 新聞文章頁面 (範本)
// 功能：展示如何使用 CustomScrollView 和 Slivers 來高效處理長篇圖文內容。

import 'package:flutter/material.dart';
import 'package:tell_me/core/theme/app_theme.dart';
import 'package:tell_me/shared/models/feed_models.dart';

class NewsArticleScreen extends StatelessWidget {
  // 假設從前一頁傳入 PostData
  final PostData article;

  const NewsArticleScreen({Key? key, required this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 模擬很長的文章內容
    final List<String> longArticleContent = List.generate(
      30,
      (index) =>
          '這是文章的第 ${index + 1} 段。長內容測試，這部分會重複出現以模擬真實文章的長度。Flutter 的 CustomScrollView 非常適合這種混合內容的頁面，上方可以是固定的圖片或標題，下方則是可高效滾動的長列表，使用者體驗極佳。',
    );

    return Scaffold(
      backgroundColor: AppTheme.background,
      // 使用 CustomScrollView 來組合不同的滾動元件 (Slivers)
      body: CustomScrollView(
        slivers: <Widget>[
          // SliverAppBar 可以在滾動時產生很棒的頭部動畫效果
          SliverAppBar(
            pinned: true, // 將 AppBar 固定在頂部
            expandedHeight: 250.0, // AppBar 完全展開時的高度
            backgroundColor: AppTheme.nearlyDarkBlue,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                article.cardTitle,
                style: const TextStyle(
                  color: AppTheme.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Image.asset(
                // 假設我們有一張新聞主圖
                'assets/images/news_placeholder.png',
                fit: BoxFit.cover,
                // 優雅地處理圖片載入失敗
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppTheme.grey.withOpacity(0.2),
                    child: const Icon(
                      Icons.image_not_supported,
                      color: AppTheme.grey,
                      size: 50,
                    ),
                  );
                },
              ),
            ),
          ),

          // SliverToBoxAdapter 用於放置單一的、非滾動列表的 Widget
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.caption, // 文章主旨
                    style: AppTheme.title.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: AppTheme.grey),
                      const SizedBox(width: 4),
                      Text(
                        article.userName,
                        style: AppTheme.caption.copyWith(color: AppTheme.grey),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.access_time, size: 16, color: AppTheme.grey),
                      const SizedBox(width: 4),
                      Text(
                        article.timeAgo,
                        style: AppTheme.caption.copyWith(color: AppTheme.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                ],
              ),
            ),
          ),

          // SliverList 用於高效渲染長列表，等同於 ListView.builder
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                // 這是文章的每一段
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    longArticleContent[index],
                    style: AppTheme.body1.copyWith(
                      fontSize: 16,
                      height: 1.6, // 增加行高以提高可讀性
                    ),
                  ),
                );
              },
              childCount: longArticleContent.length, // 列表的項目總數
            ),
          ),
        ],
      ),
    );
  }
}
