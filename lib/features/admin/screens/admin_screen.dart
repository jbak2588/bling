// lib/features/admin/screens/admin_screen.dart

import 'package:bling_app/features/admin/screens/admin_product_detail_screen.dart'; // ✅ 상세 화면 import
import 'package:bling_app/features/marketplace/models/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 검수 승인 관리'),
      ),
      // ✅ [핵심 수정] StreamBuilder를 사용하여 'pending' 상태의 상품 목록을 실시간으로 가져옵니다.
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .where('aiVerificationStatus', isEqualTo: 'pending')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('승인 대기 중인 상품이 없습니다.'));
          }
          if (snapshot.hasError) {
            return const Center(child: Text('데이터를 불러오는 중 오류가 발생했습니다.'));
          }

          final pendingProducts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: pendingProducts.length,
            itemBuilder: (context, index) {
              final product = ProductModel.fromFirestore(pendingProducts[index] as DocumentSnapshot<Map<String, dynamic>>);
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(product.imageUrls.first),
                ),
                title: Text(product.title),
                subtitle: Text('요청 시간: ${product.createdAt.toDate()}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // ✅ 상세 승인 화면으로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminProductDetailScreen(product: product),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}