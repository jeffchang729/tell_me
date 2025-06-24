// lib/shared/models/topic_model.dart
// 主題卡片資料模型 - [修正]
// 功能：將 subtitle 參數改為可選，以符合「卡片區」篩選器的使用情境。

import 'package:flutter/material.dart';

class TopicCardData {
  final IconData icon;
  final String title;
  final String? subtitle; // [修正] 將類型改為 String?，表示它可以是 null
  final Color startColor;
  final Color endColor;

  const TopicCardData({
    required this.icon,
    required this.title,
    this.subtitle,      // [修正] 移除 required 關鍵字，使其成為可選參數
    required this.startColor,
    required this.endColor,
  });
}
