// lib/shared/widgets/topic_card.dart
// 主題卡片 UI 元件 - [修正]
// 功能：處理 subtitle 為可選（nullable）的情況，避免編譯錯誤。

import 'package:flutter/material.dart';
import 'package:tell_me/shared/models/topic_model.dart';

class TopicCard extends StatelessWidget {
  final TopicCardData data;
  final VoidCallback? onTap;

  const TopicCard({
    Key? key,
    required this.data,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [data.startColor, data.endColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24.0),
          boxShadow: [
            BoxShadow(
              color: data.startColor.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // 垂直居中
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(data.icon, color: Colors.white, size: 32),
                  const Spacer(),
                  Text(
                    data.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  // [修正] 只有在 data.subtitle 不是 null 且不是空字串時，才建立 Text 元件
                  if (data.subtitle != null && data.subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      // 因為已經檢查過不為 null，所以這裡可以使用 ! 安全地斷言它有值
                      data.subtitle!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
