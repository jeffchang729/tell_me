// lib/models/feed_models.dart
// 社群動態相關的資料模型 - [修正] 新增 JSON 序列化功能

import 'dart:convert';

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

  // [新增] 將 PostData 物件轉換為 JSON Map
  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'userAvatarUrl': userAvatarUrl,
      'location': location,
      'cardTitle': cardTitle,
      'cardSubtitle': cardSubtitle,
      'cardGradientStart': cardGradientStart,
      'cardGradientEnd': cardGradientEnd,
      'caption': caption,
      'likesCount': likesCount,
      'timeAgo': timeAgo,
      'comments': jsonEncode(comments.map((c) => c.toJson()).toList()),
      'isLiked': isLiked,
      'isSaved': isSaved,
    };
  }

  // [新增] 從 JSON Map 建立 PostData 物件
  factory PostData.fromJson(Map<String, dynamic> json) {
    // 解碼 comments
    var commentsList = <Comment>[];
    if (json['comments'] != null) {
      var decodedComments = jsonDecode(json['comments']) as List;
      commentsList = decodedComments.map((c) => Comment.fromJson(c)).toList();
    }

    return PostData(
      userName: json['userName'],
      userAvatarUrl: json['userAvatarUrl'],
      location: json['location'],
      cardTitle: json['cardTitle'],
      cardSubtitle: json['cardSubtitle'],
      cardGradientStart: json['cardGradientStart'],
      cardGradientEnd: json['cardGradientEnd'],
      caption: json['caption'],
      likesCount: json['likesCount'],
      timeAgo: json['timeAgo'],
      comments: commentsList,
      isLiked: json['isLiked'] ?? false,
      isSaved: json['isSaved'] ?? false,
    );
  }
}

/// "留言" (Comment) 的資料模型
class Comment {
  final String userName;
  final String text;

  Comment({
    required this.userName,
    required this.text,
  });

  // [新增] 將 Comment 物件轉換為 JSON Map
  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'text': text,
    };
  }

  // [新增] 從 JSON Map 建立 Comment 物件
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      userName: json['userName'],
      text: json['text'],
    );
  }
}
