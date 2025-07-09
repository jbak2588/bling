// lib/features/marketplace/widgets/product_card.dart

// import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

// ✅ [수정] UserModel과 최종 ProductModel을 모두 import합니다.
import '../../../core/models/user_model.dart';
import '../../../core/models/product_model.dart';
import '../screens/product_detail_screen.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  String _formatTimestamp(BuildContext context, Timestamp timestamp) {
    final now = DateTime.now();
    final dt = timestamp.toDate();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'time.now'.tr();
    if (diff.inHours < 1) {
      return 'time.minutesAgo'
          .tr(namedArgs: {'minutes': diff.inMinutes.toString()});
    }
    if (diff.inDays < 1) {
      return 'time.hoursAgo'.tr(namedArgs: {'hours': diff.inHours.toString()});
    }
    if (diff.inDays < 7) {
      return 'time.daysAgo'.tr(namedArgs: {'days': diff.inDays.toString()});
    }
    return DateFormat('time.dateFormat'.tr()).format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final String registeredAt = _formatTimestamp(context, product.createdAt);

    return InkWell(
      onTap: () {
        // ✅ ProductDetailScreen으로 ProductModel 타입의 product를 전달합니다.
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ProductDetailScreen(product: product),
        ));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        // ✅ [수정] 작성자 정보를 표시하기 위해 StreamBuilder를 다시 추가합니다.
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(product.userId)
                .snapshots(),
            builder: (context, userSnapshot) {
              if (!userSnapshot.hasData) {
                return const SizedBox(
                    height: 100,
                    child: Center(child: CircularProgressIndicator()));
              }
              final user = UserModel.fromFirestore(userSnapshot.data!);

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.imageUrls.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        product.imageUrls.first,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.title,
                            style: const TextStyle(
                                fontSize: 16.0, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          product.description,
                          style: TextStyle(
                              fontSize: 14.0, color: Colors.grey[800]),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                                
                        const SizedBox(height: 4.0),
                        Text(

                          '${product.locationParts?['kel'] ?? 'postCard.locationNotSet'.tr()} • $registeredAt',
                          style: TextStyle(
                              fontSize: 12.0, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                            NumberFormat.currency(
                            locale: 'id_ID',
                            symbol: 'Rp ',
                            decimalDigits: 0,
                          ).format(product.price),
                          style: const TextStyle(
                              fontSize: 15.0, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8.0),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundImage: user.photoUrl != null
                                  ? NetworkImage(user.photoUrl!)
                                  : null,
                              child: user.photoUrl == null
                                  ? const Icon(Icons.person, size: 12)
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Text(user.nickname,
                                style: const TextStyle(fontSize: 13)),
                            const Spacer(),
                            const Icon(Icons.chat_bubble_outline,
                                size: 16.0, color: Colors.grey),
                            const SizedBox(width: 4.0),
                            Text('${product.chatsCount}'),
                            const SizedBox(width: 12.0),
                            const Icon(Icons.favorite_outline,
                                size: 16.0, color: Colors.grey),
                            const SizedBox(width: 4.0),
                            Text('${product.likesCount}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
      ),
    );
  }
}
