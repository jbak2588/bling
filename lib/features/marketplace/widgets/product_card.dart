// lib/features/marketplace/widgets/product_card.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/models/product_model.dart';
import '../../../core/models/user_model.dart';
// import '../screens/product_detail_screen.dart'; // TODO: 상세 화면 연결 시 주석 해제

/// 통합 피드 등에 표시될 'Marketplace 상품' 카드 위젯입니다.
class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(product.userId)
          .snapshots(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: const SizedBox(
                height: 120, child: Center(child: CircularProgressIndicator())),
          );
        }
        final user = UserModel.fromFirestore(userSnapshot.data!);
        final priceFormatted = NumberFormat.currency(
          locale: 'id_ID',
          symbol: 'Rp ',
          decimalDigits: 0,
        ).format(product.price);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: () {
              // TODO: ProductDetailScreen으로 이동하는 로직 연결
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ▼▼▼▼▼ 이미지 URL 유효성 검사 추가 ▼▼▼▼▼
                  if (product.imageUrls.isNotEmpty &&
                      product.imageUrls.first.startsWith('http'))
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        product.imageUrls.first,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        // 로딩 및 에러 시 플레이스홀더 아이콘 표시
                        errorBuilder: (context, error, stackTrace) => Container(
                            height: 150,
                            color: Colors.grey[200],
                            child: Icon(Icons.image_not_supported_outlined,
                                color: Colors.grey[400], size: 48)),
                        loadingBuilder: (context, child, progress) =>
                            progress == null
                                ? child
                                : const SizedBox(
                                    height: 150,
                                    child: Center(
                                        child: CircularProgressIndicator())),
                      ),
                    )
                  else
                    // 이미지가 없는 경우, 기본 아이콘을 표시합니다.
                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.image_not_supported_outlined,
                          color: Colors.grey[400], size: 48),
                    ),
                  const SizedBox(height: 12),

                  Text(
                    product.title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    priceFormatted,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.locationName ?? 'Lokasi tidak diketahui',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const Divider(height: 20),

                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: (user.photoUrl != null &&
                                user.photoUrl!.startsWith('http'))
                            ? NetworkImage(user.photoUrl!)
                            : null,
                        child: (user.photoUrl == null ||
                                !user.photoUrl!.startsWith('http'))
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Text(user.nickname),
                      const Spacer(),
                      const Icon(Icons.chat_bubble_outline,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('${product.chatsCount}'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
