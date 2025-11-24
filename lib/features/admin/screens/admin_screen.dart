// lib/features/admin/screens/admin_screen.dart
// (기존 파일 상단에 추가)
/// [V3.1 Update] AI Audit Log 메뉴 추가 (AI 검수 이력 관리)
library;

import 'package:bling_app/features/admin/screens/admin_product_detail_screen.dart'; // ✅ 상세 화면 import
import 'package:bling_app/features/admin/screens/ai_audit_screen.dart'; // [New] AI 감사 화면 import
import 'package:bling_app/features/marketplace/models/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bling_app/i18n/strings.g.dart'; // Slang strings
import 'package:intl/intl.dart';
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
        title: Text(t.admin.screen.title), // 예: '관리자 메뉴'
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.playlist_add_check_circle_outlined),
            title: Text(t.admin.menu.aiApproval),
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
            title: Text(t.admin.menu.reportManagement),
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
          // [V3.1 New] AI 감사 로그 메뉴 추가
          ListTile(
            leading: const Icon(Icons.history_edu_outlined),
            title: Text(t.admin.menu.aiAudit),
            subtitle: Text(t.admin.menu.aiAuditSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AiAuditScreen()),
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
      appBar: AppBar(title: Text(t.admin.menu.aiApproval)),
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
            return Center(child: Text(t.admin.aiApproval.error));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text(t.admin.aiApproval.empty));
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
                  '${t.admin.aiApproval.requestedAt}: ${DateFormat('yyyy-MM-dd HH:mm').format(product.createdAt.toDate())}',
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
