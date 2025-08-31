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
import 'package:bling_app/features/chat/data/chat_service.dart'; // [추가]
import 'package:bling_app/features/chat/screens/chat_room_screen.dart'; // [추가]
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:bling_app/features/shared/widgets/author_profile_tile.dart';
import 'package:bling_app/features/shared/widgets/clickable_tag_list.dart';
import 'package:bling_app/features/shared/widgets/image_carousel_card.dart';
import 'package:bling_app/features/shared/widgets/mini_map_view.dart';
import 'package:bling_app/features/shared/screens/image_gallery_screen.dart';

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
          // ✅ 1. 대표 이미지를 공용 이미지 캐러셀로 교체
         if (job.imageUrls != null && job.imageUrls!.isNotEmpty)
          GestureDetector(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => ImageGalleryScreen(imageUrls: job.imageUrls!),
            )),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: ImageCarouselCard(
                imageUrls: job.imageUrls!,
                height: 250,
              ),
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

          // ✅ 2. 공용 태그 리스트 위젯 추가
        ClickableTagList(tags: job.tags),
        const Divider(height: 32),

        // ✅ 3. 공용 미니맵 위젯 추가
        if (job.geoPoint != null) ...[
          Text('jobs.detail.locationTitle'.tr(), style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          MiniMapView(location: job.geoPoint!, markerId: job.id),
          const Divider(height: 32),
        ],

        // ✅ 4. 작성자 정보를 공용 프로필 타일로 교체
        Text('jobs.detail.authorTitle'.tr(), style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        AuthorProfileTile(userId: job.userId),
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
  
}
