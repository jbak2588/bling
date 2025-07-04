// lib/features/marketplace/screens/marketplace_screen.dart
// Bling App v0.4
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../domain/product_model.dart';
import 'product_detail_screen.dart';

class MarketplaceScreen extends StatefulWidget {
  final String currentAddress;
  const MarketplaceScreen({super.key, required this.currentAddress});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  String _formatTimestamp(Timestamp timestamp) {
    // ... (내용 변경 없음)
    final now = DateTime.now();
    final dt = timestamp.toDate();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) {
      return 'time_ago_now'.tr();
    } else if (diff.inHours < 1) {
      return 'time_ago_min'.tr(args: [diff.inMinutes.toString()]);
    } else if (diff.inDays < 1) {
      return 'time_ago_hour'.tr(args: [diff.inHours.toString()]);
    } else if (diff.inDays < 7) {
      return 'time_ago_day'.tr(args: [diff.inDays.toString()]);
    } else {
      return DateFormat('yy.MM.dd').format(dt);
    }
  }

  @override
  Widget build(BuildContext context) {
    Query<Map<String, dynamic>> query;
    if (widget.currentAddress.isNotEmpty &&
        !widget.currentAddress.startsWith('main.appBar')) {
      query = FirebaseFirestore.instance
          .collection('products')
          .where('address', isEqualTo: widget.currentAddress)
          .orderBy('createdAt', descending: true);
    } else {
      query = FirebaseFirestore.instance
          .collection('products')
          .orderBy('createdAt', descending: true)
          .limit(20);
    }

    return Scaffold(
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('marketplace.error'
                    .tr(namedArgs: {'error': snapshot.error.toString()})));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child:
                  Text('marketplace.empty'.tr(), textAlign: TextAlign.center),
            );
          }

          final productsDocs = snapshot.data!.docs;
          return ListView.separated(
            itemCount: productsDocs.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              thickness: 1,
              indent: 16,
              endIndent: 16,
            ),
            itemBuilder: (context, index) {
              final product = Product.fromFirestore(productsDocs[index]);
              final String registeredAt = _formatTimestamp(product.createdAt);

              return InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          ProductDetailScreen(product: product),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Row(
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
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey[200],
                                child: Icon(Icons.broken_image,
                                    color: Colors.grey[400]),
                              );
                            },
                          ),
                        ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.title,
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
                              '${product.address} • $registeredAt',
                              style: TextStyle(
                                  fontSize: 12.0, color: Colors.grey[600]),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8.0),
                            Row(
                              children: [
                                Text(
                                  NumberFormat.currency(
                                    locale: 'id_ID',
                                    symbol: 'Rp ',
                                    decimalDigits: 0,
                                  ).format(product.price),
                                  style: const TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold),
                                ),
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
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
