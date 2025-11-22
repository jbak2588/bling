// ===================== DocHeader =====================
// [기획 요약]
// - 구인/구직 게시글 상세 정보, 채팅 연동, 신뢰 등급, 급여/근무기간/이미지 등 다양한 필드 지원.
//
// [실제 구현 비교]
// - 상세 정보, 채팅 연동, 신뢰 등급, 급여/근무기간/이미지 등 모든 주요 기능 정상 동작.
// - UI/UX 완비, 채팅방 생성 및 지원자 정보 연동 구현됨.
//
// [개선 제안]
// - KPI/통계/프리미엄 기능 실제 구현 필요(조회수, 지원수, 부스트 등).
// - 신고/차단/신뢰 등급 UI 노출 및 기능 강화, 알림/지원 UX 개선.
// =====================================================
// lib/features/jobs/screens/job_detail_screen.dart
// ===================== DocHeader =====================
// [기획 요약]
// - 구인/구직 게시글 상세 정보, 채팅 연동, 신뢰 등급, 급여/근무기간/이미지 등 다양한 필드 지원.
//
// [실제 구현 비교]
// - 상세 정보, 채팅 연동, 신뢰 등급, 급여/근무기간/이미지 등 모든 주요 기능 정상 동작.
// - UI/UX 완비, 채팅방 생성 및 지원자 정보 연동 구현됨.
//
// [개선 제안]
// - KPI/통계/프리미엄 기능 실제 구현 필요(조회수, 지원수, 부스트 등).
// - 신고/차단/신뢰 등급 UI 노출 및 기능 강화, 알림/지원 UX 개선.
// =====================================================

import 'package:bling_app/features/jobs/models/job_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/chat/data/chat_service.dart';
import 'package:bling_app/features/chat/screens/chat_room_screen.dart';
import 'package:bling_app/features/jobs/data/job_repository.dart'; // [추가]
import 'package:bling_app/features/jobs/screens/create_job_screen.dart'; // [추가]
import 'package:bling_app/features/jobs/screens/create_quick_gig_screen.dart'; // [추가]
import 'package:bling_app/features/jobs/constants/job_categories.dart'; // [추가]
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // [추가]
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:bling_app/features/shared/widgets/app_bar_icon.dart';

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

  // V V V --- [추가] 구인글 삭제 다이얼로그 --- V V V
  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('jobs.dialog.deleteTitle'.tr()), // '삭제 하시겠습니까?'
        content:
            Text('jobs.dialog.deleteContent'.tr()), // '삭제된 게시글은 복구할 수 없습니다.'
        actions: [
          TextButton(
            child: Text('jobs.dialog.cancel'.tr()),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: Text('jobs.dialog.deleteConfirm'.tr(),
                style: const TextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.of(ctx).pop(); // 닫기
              try {
                final repo = JobRepository();
                await repo.deleteJob(job.id, job.userId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('jobs.dialog.deleteSuccess'.tr())));
                  Navigator.of(context).pop(); // 상세 화면 닫기
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('jobs.errors.deleteError'
                          .tr(namedArgs: {'error': e.toString()}))));
                }
              }
            },
          ),
        ],
      ),
    );
  }

  // V V V --- [추가] 구인글 수정 화면 이동 --- V V V
  Future<void> _navigateToEdit(BuildContext context) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // UserModel을 가져오기 위한 간단한 fetch (CreateScreen에 필요함)
    // 실제로는 Provider나 캐시된 유저 정보를 쓰는 것이 좋음.
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
    if (!userDoc.exists || !context.mounted) return;

    final userModel = UserModel.fromFirestore(userDoc);

    // JobType에 따라 적절한 수정 화면으로 이동
    if (job.jobType == JobType.quickGig.name) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => CreateQuickGigScreen(
          userModel: userModel,
          jobToEdit: job, // 기존 job 정보 전달
        ),
      ));
    } else {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => CreateJobScreen(
          userModel: userModel,
          jobType: JobType.regular,
          jobToEdit: job, // 기존 job 정보 전달
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    // [추가] 본인 글인지 확인
    final isMyJob = FirebaseAuth.instance.currentUser?.uid == job.userId;

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: AppBarIcon(
            icon: Icons.arrow_back,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Text(job.title),
// V V V --- [추가] actions에 수정/삭제 버튼 추가 --- V V V
        actions: [
          if (isMyJob) ...[
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: AppBarIcon(
                icon: Icons.edit,
                onPressed: () => _navigateToEdit(context),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: AppBarIcon(
                icon: Icons.delete,
                onPressed: () => _showDeleteDialog(context),
              ),
            ),
          ]
        ],
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
