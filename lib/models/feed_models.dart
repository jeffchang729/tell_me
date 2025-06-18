// lib/models/feed_models.dart
// 社群動態相關的資料模型

/// "限時動態" (Story) 的資料模型
class StoryData {
  final String name;
  final bool hasNewStory;
  final String? avatarUrl;

  StoryData({
    required this.name,
    required this.hasNewStory,
    this.avatarUrl,
  });
}

/// "貼文" (Post) 的資料模型
class PostData {
  final String userName;
  final String? userAvatarUrl;
  final String? location;
  final String cardTitle;
  final String cardSubtitle;
  final String cardGradientStart;
  final String cardGradientEnd;
  final String caption;
  int likesCount;
  final String timeAgo;
  final List<Comment> comments;
  bool isLiked;
  bool isSaved;

  PostData({
    required this.userName,
    this.userAvatarUrl,
    this.location,
    required this.cardTitle,
    required this.cardSubtitle,
    required this.cardGradientStart,
    required this.cardGradientEnd,
    required this.caption,
    required this.likesCount,
    required this.timeAgo,
    required this.comments,
    this.isLiked = false,
    this.isSaved = false,
  });
}

/// "留言" (Comment) 的資料模型
class Comment {
  final String userName;
  final String text;

  Comment({
    required this.userName,
    required this.text,
  });
}
