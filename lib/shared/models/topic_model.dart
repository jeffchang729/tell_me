// lib/shared/models/topic_model.dart
// 主題卡片資料模型
// 功能：定義主題儀表板上卡片的資料結構。

import 'package:flutter/material.dart';

class TopicCardData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color startColor;
  final Color endColor;

  const TopicCardData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.startColor,
    required this.endColor,
  });
}
