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
// lib/features/jobs/screens/job_detail_screen.dart

import 'package:bling_app/features/jobs/models/job_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/chat/data/chat_service.dart';
import 'package:bling_app/features/chat/screens/chat_room_screen.dart';
import 'package:bling_app/features/jobs/data/job_repository.dart';
import 'package:bling_app/features/jobs/screens/create_job_screen.dart';
import 'package:bling_app/features/jobs/screens/create_quick_gig_screen.dart';
import 'package:bling_app/features/jobs/constants/job_categories.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bling_app/i18n/strings.g.dart';
import 'package:bling_app/features/shared/widgets/app_bar_icon.dart';

// ✅ [공용 위젯 Import]
import 'package:bling_app/features/shared/widgets/author_profile_tile.dart';
import 'package:bling_app/features/shared/widgets/clickable_tag_list.dart';
import 'package:bling_app/features/shared/widgets/image_carousel_card.dart';
import 'package:bling_app/features/shared/widgets/mini_map_view.dart';
import 'package:bling_app/features/shared/screens/image_gallery_screen.dart';

class JobDetailScreen extends StatelessWidget {
  final JobModel job;
  const JobDetailScreen({super.key, required this.job});

  // [기존 로직 유지] 채팅 시작
  void _startChat(BuildContext context) async {
    final chatService = ChatService();
    try {
      final chatId = await chatService.createOrGetChatRoom(
        otherUserId: job.userId,
        jobId: job.id,
        jobTitle: job.title,
      );

      final otherUser = await chatService.getOtherUserInfo(job.userId);

      if (!context.mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ChatRoomScreen(
            chatId: chatId,
            otherUserName: otherUser.nickname,
            otherUserId: otherUser.uid,
            productTitle: job.title,
          ),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(t.jobs.detail.chatError
                  .replaceAll('{error}', e.toString())),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  // [기존 로직 유지] 삭제 다이얼로그
  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t['jobs.dialog.deleteTitle'] ?? ''),
        content: Text(t['jobs.dialog.deleteContent'] ?? ''),
        actions: [
          TextButton(
            child: Text(t['jobs.dialog.cancel'] ?? ''),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: Text(t['jobs.dialog.deleteConfirm'] ?? '',
                style: const TextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                final repo = JobRepository();
                await repo.deleteJob(job.id, job.userId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(t['jobs.dialog.deleteSuccess'] ?? '')));
                  Navigator.of(context).pop();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(t['jobs.errors.deleteError'] ?? ''
                          .replaceAll('{error}', e.toString()))));
                }
              }
            },
          ),
        ],
      ),
    );
  }

  // [기존 로직 유지] 수정 화면 이동
  Future<void> _navigateToEdit(BuildContext context) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
    if (!userDoc.exists || !context.mounted) return;

    final userModel = UserModel.fromFirestore(userDoc);

    if (job.jobType == JobType.quickGig.name) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => CreateQuickGigScreen(
          userModel: userModel,
          jobToEdit: job,
        ),
      ));
    } else {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => CreateJobScreen(
          userModel: userModel,
          jobType: JobType.regular,
          jobToEdit: job,
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

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
          // ✅ 1. [공용 위젯 적용] 이미지 캐러셀
          if (job.imageUrls != null && job.imageUrls!.isNotEmpty)
            GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ImageGalleryScreen(imageUrls: job.imageUrls!),
              )),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: ImageCarouselCard(
                  imageUrls: job.imageUrls!,
                  storageId: job.id, // [중요] 상태 유지를 위한 ID
                  height: 250,
                ),
              ),
            ),
          if (job.imageUrls != null && job.imageUrls!.isNotEmpty)
            const SizedBox(height: 16),

          // --- 2. 제목 및 기본 정보 ---
          Text(job.title,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            '${t['jobs.salaryTypes.${job.salaryType ?? 'etc'}']}: ${currencyFormat.format(job.salaryAmount ?? 0)}'
            '${job.isSalaryNegotiable ? ' (Nego)' : ''}',
            style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
              '${t['jobs.workPeriods.${job.workPeriod ?? 'etc'}']} / ${job.workHours ?? ''}'),
          const Divider(height: 32),

          // --- 3. 상세 설명 ---
          Text(t.jobs.detail.infoTitle,
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(job.description,
              style: const TextStyle(fontSize: 16, height: 1.5)),

          // ✅ 2. [공용 위젯 적용] 태그 리스트
          if (job.tags.isNotEmpty) ...[
            const SizedBox(height: 24),
            ClickableTagList(tags: job.tags),
          ],

          const Divider(height: 32),

          // ✅ 3. [공용 위젯 적용] 미니맵
          if (job.geoPoint != null) ...[
            Text(t.jobs.detail.locationTitle,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            MiniMapView(
              location: job.geoPoint!,
              markerId: job.id,
              myLocationEnabled: false,
            ),
            const Divider(height: 32),
          ],

          // ✅ 4. [공용 위젯 적용] 작성자 프로필 타일
          Text(t.jobs.detail.authorTitle,
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          AuthorProfileTile(userId: job.userId),

          const SizedBox(height: 80),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () => _startChat(context),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(t.jobs.detail.apply),
        ),
      ),
    );
  }
}
