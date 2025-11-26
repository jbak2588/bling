// lib/features/admin/screens/deletion_requests_screen.dart

import 'package:bling_app/core/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class DeletionRequestsScreen extends StatefulWidget {
  const DeletionRequestsScreen({super.key});

  @override
  State<DeletionRequestsScreen> createState() => _DeletionRequestsScreenState();
}

class _DeletionRequestsScreenState extends State<DeletionRequestsScreen> {
  bool _isProcessing = false;

  // Cloud Function 호출
  Future<void> _confirmDeletion(String uid, String nickname) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('영구 삭제 확인'),
        content: Text(
            "'$nickname' 사용자의 모든 데이터(Auth, DB, Storage)를 영구 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('common.cancel'.tr())),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('영구 삭제'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isProcessing = true);

    try {
      final functions =
          FirebaseFunctions.instanceFor(region: 'asia-southeast2');
      final callable = functions.httpsCallable('confirmAccountDeletion');

      await callable.call({'targetUid': uid});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('사용자 계정이 안전하게 삭제되었습니다.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('삭제 실패: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('탈퇴 요청 관리')),
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('isDeletionRequested', isEqualTo: true)
                .orderBy('deletionRequestedAt', descending: false) // 오래된 요청부터
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('접수된 탈퇴 요청이 없습니다.'));
              }

              final users = snapshot.data!.docs;

              return ListView.separated(
                itemCount: users.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final doc = users[index];
                  final user = UserModel.fromFirestore(
                      doc as DocumentSnapshot<Map<String, dynamic>>);
                  final date = user.deletionRequestedAt?.toDate();
                  final dateStr = date != null
                      ? DateFormat('yyyy-MM-dd HH:mm').format(date)
                      : '-';

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: (user.photoUrl != null)
                          ? NetworkImage(user.photoUrl!)
                          : null,
                      child: (user.photoUrl == null)
                          ? const Icon(Icons.person_off)
                          : null,
                    ),
                    title: Text(user.nickname),
                    subtitle: Text('이메일: ${user.email}\n요청일: $dateStr'),
                    isThreeLine: true,
                    trailing: ElevatedButton.icon(
                      onPressed: _isProcessing
                          ? null
                          : () => _confirmDeletion(user.uid, user.nickname),
                      icon: const Icon(Icons.delete_forever, size: 18),
                      label: const Text('삭제 승인'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  );
                },
              );
            },
          ),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
