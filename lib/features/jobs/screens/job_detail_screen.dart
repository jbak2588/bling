// lib/features/jobs/screens/job_detail_screen.dart

import 'package:bling_app/features/jobs/models/job_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/chat/data/chat_service.dart'; // [추가]
import 'package:bling_app/features/chat/screens/chat_room_screen.dart'; // [추가]
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class JobDetailScreen extends StatelessWidget {
  final JobModel job;
  const JobDetailScreen({super.key, required this.job});

  // [추가] '지원하기' 버튼을 눌렀을 때 실행될 함수
  void _startChat(BuildContext context) async {
    // ChatService 인스턴스를 생성합니다.
    final chatService = ChatService();
    try {
      // 1. 채팅방을 생성하거나, 기존 채팅방 ID를 가져옵니다.
      final chatId = await chatService.createOrGetChatRoom(
        otherUserId: job.userId,
        jobId: job.id,
        jobTitle: job.title,
      );

      // 2. 채팅 상대방(구인자)의 정보를 가져옵니다.
      final otherUser = await chatService.getOtherUserInfo(job.userId);

      if (!context.mounted) return;

      // 3. 채팅방으로 이동합니다.
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ChatRoomScreen(
            chatId: chatId,
            otherUserName: otherUser.nickname,
            otherUserId: otherUser.uid,
            // [수정] 상품 제목 대신 구인글 제목을 전달 (필드명은 재활용)
            productTitle: job.title,
          ),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('jobs.detail.chatError'
                  .tr(namedArgs: {'error': e.toString()})),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: Text(job.title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- 1. 대표 이미지 ---
          if (job.imageUrls != null && job.imageUrls!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.network(
                job.imageUrls!.first,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 16),

          // --- 2. 제목 및 기본 정보 ---
          Text(job.title,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            '${'jobs.salaryTypes.${job.salaryType ?? 'etc'}'.tr()}: ${currencyFormat.format(job.salaryAmount ?? 0)}'
            '${job.isSalaryNegotiable ? ' (Nego)' : ''}',
            style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
              '${'jobs.workPeriods.${job.workPeriod ?? 'etc'}'.tr()} / ${job.workHours ?? ''}'),
          const Divider(height: 32),

          // --- 3. 상세 설명 ---
          Text('jobs.detail.infoTitle'.tr(),
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(job.description,
              style: const TextStyle(fontSize: 16, height: 1.5)),
          const Divider(height: 32),

          // --- 4. 작성자 정보 ---
          _buildSellerInfo(job.userId),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          // V V V --- [수정] onPressed에 _startChat 함수를 연결합니다 --- V V V
          onPressed: () => _startChat(context),
          // ^ ^ ^ --- 여기까지 수정 --- ^ ^ ^
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text('jobs.detail.apply'.tr()),
        ),
      ),
    );
  }

  // 작성자 정보 위젯
  Widget _buildSellerInfo(String userId) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return ListTile(title: Text('jobs.detail.noAuthor'.tr()));
        }
        final user = UserModel.fromFirestore(snapshot.data!);
        return Card(
          elevation: 0,
          color: Colors.grey.shade100,
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  (user.photoUrl != null && user.photoUrl!.isNotEmpty)
                      ? NetworkImage(user.photoUrl!)
                      : null,
            ),
            title: Text(user.nickname,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(user.locationName ?? ''),
          ),
        );
      },
    );
  }
}
