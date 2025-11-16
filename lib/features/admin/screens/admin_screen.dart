// lib/features/admin/screens/admin_screen.dart

import 'package:bling_app/features/admin/screens/admin_product_detail_screen.dart'; // ✅ 상세 화면 import
import 'package:bling_app/features/marketplace/models/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart'; // 다국어 사용 위해 추가
import 'package:flutter/material.dart';

// ✅ [신고 관리] 신고 목록 화면 import
import 'report_list_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ [신고 관리] 관리 메뉴 목록 UI로 변경
    return Scaffold(
      appBar: AppBar(
        title: Text('admin.screen.title'.tr()), // 예: '관리자 메뉴'
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.playlist_add_check_circle_outlined),
            title: Text('admin.menu.aiApproval'.tr()),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AiApprovalScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.report_gmailerrorred_outlined),
            title: Text('admin.menu.reportManagement'.tr()),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ReportListScreen()),
              );
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}

// ✅ 임시: AI 검수 화면 위젯 (기존 AdminScreen 목록 기능 분리)
class AiApprovalScreen extends StatelessWidget {
  const AiApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('admin.menu.aiApproval'.tr())),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .where('status',
                isEqualTo:
                    'pending') // [V3 PENDING FIX] Task 79에서 저장한 'status' 필드 쿼리
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('admin.aiApproval.error'.tr()));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('admin.aiApproval.empty'.tr()));
          }

          final pendingProducts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: pendingProducts.length,
            itemBuilder: (context, index) {
              final product = ProductModel.fromFirestore(
                pendingProducts[index]
                    as DocumentSnapshot<Map<String, dynamic>>,
              );
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: (product.imageUrls.isNotEmpty)
                      ? NetworkImage(product.imageUrls.first)
                      : null,
                  child: (product.imageUrls.isEmpty)
                      ? const Icon(Icons.image)
                      : null,
                ),
                title: Text(product.title),
                subtitle: Text(
                  // 날짜 포맷 적용
                  '${'admin.aiApproval.requestedAt'.tr()}: ${DateFormat('yyyy-MM-dd HH:mm').format(product.createdAt.toDate())}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AdminProductDetailScreen(product: product),
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
