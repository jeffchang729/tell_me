// shared/widgets/feed/info_post_card.dart
// 單一資訊貼文卡片 (社群動態) - [新增] 移除按鈕
// 功能：提供更柔和、美觀的漸層背景，並加入移除功能。

import 'package:flutter/material.dart';
import 'package:tell_me/core/theme/app_theme.dart';
import 'package:tell_me/shared/models/feed_models.dart';
import 'package:tell_me/core/utils/app_utils.dart';

class InfoPostCard extends StatelessWidget {
  final PostData post;
  final VoidCallback? onRemove; // [新增] 移除回呼函式

  const InfoPostCard({Key? key, required this.post, this.onRemove}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: const BoxDecoration(
        color: AppTheme.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPostHeader(),
          _buildInfoCard(),
          _buildInteractionButtons(),
          _buildLikesCount(),
          _buildPostContent(),
          _buildCommentsPreview(),
          _buildPostTime(),
          const Divider(height: 1, color: AppTheme.background),
        ],
      ),
    );
  }

  // [修改] 貼文頂部的使用者資訊，加入移除按鈕
  Widget _buildPostHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.orange.withOpacity(0.2),
            child: const Icon(Icons.article, size: 20, color: Colors.orange),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.userName,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                if (post.location != null)
                  Text(post.location!,
                      style: const TextStyle(fontSize: 12, color: AppTheme.grey)),
              ],
            ),
          ),
          if (onRemove != null)
            IconButton(
              icon: const Icon(Icons.close, color: AppTheme.grey, size: 20),
              onPressed: onRemove,
              tooltip: '移除卡片',
            )
          else
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_horiz, color: AppTheme.darkerText),
            ),
        ],
      ),
    );
  }
  
  // 其他方法保持不變...
  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [HexColor(post.cardGradientStart), HexColor(post.cardGradientEnd)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -30,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), shape: BoxShape.circle),
            ),
          ),
          Center(
            child: Container(
              width: 160,
              height: 220,
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), offset: const Offset(4, 8), blurRadius: 16)],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.article_outlined, size: 40, color: HexColor(post.cardGradientStart)),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(post.cardTitle, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.darkerText)),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(post.cardSubtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: AppTheme.grey)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border, size: 28)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.chat_bubble_outline, size: 28)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.send_outlined, size: 28)),
          const Spacer(),
          IconButton(onPressed: () {}, icon: const Icon(Icons.bookmark_border, size: 28)),
        ],
      ),
    );
  }

  Widget _buildLikesCount() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text('${post.likesCount} 個讚', style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildPostContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 14, color: AppTheme.darkerText),
          children: [
            TextSpan(text: post.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: ' ${post.caption}'),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsPreview() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Text('查看全部 ${post.comments.length} 則留言',
          style: const TextStyle(color: AppTheme.grey)),
    );
  }

  Widget _buildPostTime() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Text(post.timeAgo,
          style: const TextStyle(fontSize: 12, color: AppTheme.grey)),
    );
  }
}
