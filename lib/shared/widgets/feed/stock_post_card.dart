// shared/widgets/feed/stock_post_card.dart
// 股票資訊貼文卡片
// 功能：在主畫面上顯示單一股票的即時資訊。

import 'package:flutter/material.dart';
import 'package:tell_me/core/theme/app_theme.dart';
import 'package:tell_me/shared/models/search_models.dart';

class StockPostCard extends StatelessWidget {
  final StockSearchResultItem stockData;
  final VoidCallback? onRemove;

  const StockPostCard({
    Key? key,
    required this.stockData,
    this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 從 data 中安全地獲取資料
    final price = stockData.data['price'] ?? 0.0;
    final change = stockData.data['change'] ?? 0.0;
    final changePercent = stockData.data['changePercent'] ?? 0.0;
    final isPositive = change >= 0;

    final Color changeColor = isPositive ? const Color(0xFF26A69A) : const Color(0xFFEF5350);
    final IconData changeIcon = isPositive ? Icons.arrow_upward : Icons.arrow_downward;

    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 卡片標頭
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: changeColor.withOpacity(0.1),
                  child: Icon(Icons.show_chart, color: changeColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    stockData.title,
                    style: AppTheme.title.copyWith(fontSize: 18),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppTheme.grey, size: 20),
                  onPressed: onRemove,
                  tooltip: '移除卡片',
                ),
              ],
            ),
            const Divider(height: 24),
            // 主要價格資訊
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '\$${price.toStringAsFixed(2)}',
                  style: AppTheme.headline.copyWith(
                    color: AppTheme.darkerText,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: changeColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(changeIcon, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${change.toStringAsFixed(2)} (${changePercent.toStringAsFixed(2)}%)',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 其他詳細資訊
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoDetail('成交量', stockData.data['volume'] ?? 'N/A'),
                _buildInfoDetail('市值', stockData.data['marketCap'] ?? 'N/A'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 建立詳細資訊的小元件
  Widget _buildInfoDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.caption.copyWith(color: AppTheme.grey),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTheme.body1.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
