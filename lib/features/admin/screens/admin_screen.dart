// lib/features/admin/screens/admin_screen.dart
// (기존 파일 상단에 추가)
/// [V3.1 Update] AI Audit Log 메뉴 추가 (AI 검수 이력 관리)
library;

import 'package:bling_app/features/admin/screens/admin_product_detail_screen.dart'; // ✅ 상세 화면 import
import 'package:bling_app/features/admin/screens/ai_audit_screen.dart'; // [New] AI 감사 화면 import
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
          // [V3.1 New] AI 감사 로그 메뉴 추가
          ListTile(
            leading: const Icon(Icons.history_edu_outlined),
            title: Text('admin.menu.aiAudit'.tr()),
            subtitle: Text('admin.menu.aiAuditSubtitle'.tr()),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AiAuditScreen()),
              );
            },
          ),
          const Divider(),

          // [추가] 유령 채팅방 정리 기능
          ListTile(
            leading:
                const Icon(Icons.cleaning_services_outlined, color: Colors.red),
            title: const Text('유령 채팅방 정리 (참여자 0명)'),
            subtitle: const Text('참여자가 없는 방을 일괄 삭제합니다.'),
            onTap: () => _cleanupGhostChatRooms(context),
          ),
        ],
      ),
    );
  }

  // [추가] 유령 채팅방 삭제 로직
  Future<void> _cleanupGhostChatRooms(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('데이터 정리'),
        content: const Text('참여자가 없는 모든 채팅방을 영구 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('common.cancel'.tr())),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('common.delete'.tr(),
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      // Collections to check — codebase uses both `chatRooms` and `chats` in places.
      final collectionsToCheck = ['chatRooms', 'chats'];
      int totalDeleted = 0;
      final List<String> processedCollections = [];

      for (final colName in collectionsToCheck) {
        debugPrint('[Admin] Checking collection: $colName');
        final snapshot =
            await FirebaseFirestore.instance.collection(colName).get();

        if (snapshot.docs.isEmpty) {
          debugPrint('[Admin] No documents found in $colName');
          continue;
        }

        final batch = FirebaseFirestore.instance.batch();
        int deletedInThisCollection = 0;

        for (var doc in snapshot.docs) {
          final data = doc.data();

          // 1. participants 필드 존재 여부 및 타입 확인
          var participants = [];
          if (data.containsKey('participants') &&
              data['participants'] != null) {
            try {
              if (data['participants'] is List) {
                participants = List<dynamic>.from(data['participants']);
              }
            } catch (e) {
              participants = [];
            }
          }

          // 2. 삭제 조건: 참여자가 0명이거나, 필드가 없었거나, 비정상 데이터인 경우
          if (participants.isEmpty) {
            batch.delete(doc.reference);
            deletedInThisCollection++;
            debugPrint('[Admin] Deleting ghost chat from $colName: ${doc.id}');
          }
        }

        if (deletedInThisCollection > 0) {
          await batch.commit();
          totalDeleted += deletedInThisCollection;
          processedCollections.add('$colName($deletedInThisCollection)');
        } else {
          processedCollections.add('$colName(0)');
        }
      }

      if (context.mounted) {
        if (totalDeleted > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    '${totalDeleted}개의 유령 채팅방이 삭제되었습니다. (${processedCollections.join(', ')})')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    '정리할 채팅방이 없습니다. 확인한 컬렉션: ${processedCollections.join(', ')}')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류 발생: $e')),
        );
      }
    }
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
