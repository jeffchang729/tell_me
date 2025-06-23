// shared/widgets/feed/info_post_card.dart
// 單一資訊貼文卡片 (社群動態) - 美化漸層效果
// 功能：提供更柔和、美觀的漸層背景。

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../models/feed_models.dart';
import '../../../core/utils/app_utils.dart';

class InfoPostCard extends StatelessWidget {
  final PostData post;

  const InfoPostCard({Key? key, required this.post}) : super(key: key);

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
          _buildInfoCard(),
          _buildInteractionButtons(),
          _buildLikesCount(),
          _buildPostContent(),
          _buildCommentsPreview(),
          _buildPostTime(),
        ],
      ),
    );
  }

  Widget _buildPostHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppTheme.nearlyDarkBlue.withOpacity(0.2),
            child: Icon(Icons.person, size: 20, color: AppTheme.nearlyDarkBlue),
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
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_horiz, color: AppTheme.darkerText),
          ),
        ],
      ),
    );
  }

  /// [美化] 中間的資訊卡片 - 更新漸層和裝飾
  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            HexColor(post.cardGradientStart),
            HexColor(post.cardGradientEnd)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // 右上角的裝飾圓形
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // 左下角的裝飾圓形
          Positioned(
            bottom: -80,
            left: -30,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Center(
            child: Container(
              width: 160,
              height: 220,
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(4, 8),
                      blurRadius: 16),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.article_outlined,
                      size: 40, color: HexColor(post.cardGradientStart)),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(post.cardTitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppTheme.darkerText)),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(post.cardSubtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12, color: AppTheme.grey)),
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
          IconButton(
              onPressed: () {},
              icon: const Icon(Icons.favorite_border, size: 28)),
          IconButton(
              onPressed: () {},
              icon: const Icon(Icons.chat_bubble_outline, size: 28)),
          IconButton(
              onPressed: () {}, icon: const Icon(Icons.send_outlined, size: 28)),
          const Spacer(),
          IconButton(
              onPressed: () {}, icon: const Icon(Icons.bookmark_border, size: 28)),
        ],
      ),
    );
  }

  Widget _buildLikesCount() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child:
          Text('${post.likesCount} 個讚', style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildPostContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 14, color: AppTheme.darkerText),
          children: [
            TextSpan(
                text: post.userName,
                style: const TextStyle(fontWeight: FontWeight.bold)),
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
