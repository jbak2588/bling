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
        title: Text('admin.deletionRequests.confirmTitle'.tr()),
        content: Text('admin.deletionRequests.confirmBody'
            .tr(namedArgs: {'nickname': nickname})),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('common.cancel'.tr())),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('admin.deletionRequests.confirmPermanent'.tr()),
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
          SnackBar(content: Text('admin.deletionRequests.deletedSuccess'.tr())),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('admin.deletionRequests.deletedFailed'
                  .tr(namedArgs: {'error': e.toString()}))),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('admin.deletionRequests.title'.tr())),
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
                return Center(child: Text('admin.deletionRequests.empty'.tr()));
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
                    subtitle: Text(
                        '${'admin.deletionRequests.email'.tr()}: ${user.email}\n${'admin.deletionRequests.requestedAt'.tr()}: $dateStr'),
                    isThreeLine: true,
                    trailing: ElevatedButton.icon(
                      onPressed: _isProcessing
                          ? null
                          : () => _confirmDeletion(user.uid, user.nickname),
                      icon: const Icon(Icons.delete_forever, size: 18),
                      label: Text('admin.deletionRequests.approve'.tr()),
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
