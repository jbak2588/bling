// lib/features/local_stores/widgets/shop_card.dart

import 'package:bling_app/core/models/shop_model.dart';
import 'package:bling_app/features/local_stores/screens/shop_detail_screen.dart'; // [추가] 상세 화면 임포트
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ShopCard extends StatelessWidget {
  final ShopModel shop;
  const ShopCard({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      clipBehavior: Clip.antiAlias, // InkWell 효과가 Card 모서리를 따르도록 함
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      // V V V --- [수정] Card 전체를 탭할 수 있도록 InkWell로 감싸줍니다 --- V V V
      child: InkWell(
        onTap: () {
          // 탭하면 ShopDetailScreen으로 이동하며, 선택된 shop 정보를 전달합니다.
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ShopDetailScreen(shop: shop)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (shop.imageUrl != null && shop.imageUrl!.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    shop.imageUrl!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Text(
                shop.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                shop.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[700]),
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      shop.locationName ?? '위치 정보 없음'.tr(),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.watch_later_outlined, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(shop.openHours),
                ],
              )
            ],
          ),
        ),
      ),
      // ^ ^ ^ --- 여기까지 수정 --- ^ ^ ^
    );
  }
}