import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

import 'package:bling_app/features/jobs/models/talent_model.dart';
import 'package:bling_app/features/jobs/data/talent_repository.dart';
import 'package:bling_app/features/jobs/screens/edit_talent_screen.dart';
import 'package:bling_app/core/utils/popups/snackbars.dart';
import 'package:bling_app/features/chat/data/chat_service.dart'; // [추가]
import 'package:bling_app/features/chat/screens/chat_room_screen.dart'; // [추가]
import 'package:share_plus/share_plus.dart';
import 'package:bling_app/core/constants/app_links.dart';
import 'package:bling_app/features/shared/screens/image_gallery_screen.dart';
import 'package:bling_app/core/utils/address_formatter.dart';
import 'package:bling_app/features/location/providers/location_provider.dart';

class TalentDetailScreen extends StatefulWidget {
  // [수정] StatelessWidget -> StatefulWidget (로딩 상태 관리)
  final TalentModel talent;

  const TalentDetailScreen({super.key, required this.talent});

  @override
  State<TalentDetailScreen> createState() => _TalentDetailScreenState();
}

class _TalentDetailScreenState extends State<TalentDetailScreen> {
  bool _isChatLoading = false; // [추가] 로딩 상태

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isOwner = user != null && user.uid == widget.talent.userId;
    final repo = TalentRepository();

    final adminFilter = context.watch<LocationProvider>().adminFilter;
    final displayAddress = AddressFormatter.dynamicAdministrativeAddress(
      locationParts: widget.talent.locationParts,
      adminFilter: adminFilter,
      fallbackFullAddress: widget.talent.locationName,
    );

    // [유지] 삭제 로직 (widget.talent로 접근)
    void deletePost() async {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('jobs.talent.delete.confirmTitle'.tr()),
          content: Text('jobs.talent.delete.confirmBody'.tr()),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('jobs.talent.delete.cancel'.tr())),
            TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text('jobs.talent.delete.confirm'.tr(),
                    style: const TextStyle(color: Colors.red))),
          ],
        ),
      );

      if (confirm == true) {
        await repo.deleteTalent(widget.talent.id);
        if (mounted) {
          Navigator.pop(context);
          BArtSnackBar.showSuccessSnackBar(
              title: 'jobs.talent.messages.deletedSuccessTitle'.tr(),
              message: 'jobs.talent.messages.deletedSuccessBody'.tr());
        }
      }
    }

    // [추가] 채팅 시작 로직 (JobDetailScreen 참조)
    Future<void> startChat() async {
      if (user == null) {
        BArtSnackBar.showErrorSnackBar(
            title: 'jobs.talent.messages.loginRequiredTitle'.tr(),
            message: 'jobs.talent.messages.loginRequiredBody'.tr());
        return;
      }

      setState(() => _isChatLoading = true);

      try {
        final chatService = ChatService();
        // 채팅방 생성 또는 가져오기
        final chatId = await chatService.createOrGetChatRoom(
          otherUserId: widget.talent.userId,
          // 재능 마켓 관련 정보로 전달
          talentId: widget.talent.id,
          talentTitle: widget.talent.title,
          // [추가] 이미지 URL 전달 (있을 경우만)
          talentImage: widget.talent.portfolioUrls.isNotEmpty
              ? widget.talent.portfolioUrls.first
              : null,
          contextType: 'talent', // [중요] 포스트 타입 구분
        );

        // 다른 사용자 정보도 가져와서 ChatRoomScreen에 전달 (JobDetailScreen 방식과 동일)
        final otherUser =
            await chatService.getOtherUserInfo(widget.talent.userId);

        if (!mounted) return;

        // 채팅방으로 이동 (productTitle에 재능 제목 전달)
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatRoomScreen(
              chatId: chatId,
              otherUserName: otherUser.nickname,
              otherUserId: otherUser.uid,
              productTitle: widget.talent.title,
            ),
          ),
        );
      } catch (e) {
        if (mounted) {
          BArtSnackBar.showErrorSnackBar(
              title: 'jobs.talent.messages.chatErrorTitle'.tr(),
              message: 'jobs.talent.messages.chatErrorBody'
                  .tr(namedArgs: {'error': e.toString()}));
        }
      } finally {
        if (mounted) setState(() => _isChatLoading = false);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('jobs.talent.detail.title'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => SharePlus.instance.share(
              ShareParams(
                  text:
                      '${widget.talent.title}\n$kHostingBaseUrl/talent/${widget.talent.id}'),
            ),
          ),
          if (isOwner) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => EditTalentScreen(talent: widget.talent)),
                );
                // 수정 후 복귀 시 화면 갱신이 필요하다면 여기서 처리 (현재는 StatelessWidget이라 제약 있음)
                // 필요 시 setState(() {}) 호출
                if (result == true && mounted) setState(() {});
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: deletePost,
            ),
          ]
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // [유지] 이미지 슬라이더
            if (widget.talent.portfolioUrls.isNotEmpty)
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ImageGalleryScreen(
                        imageUrls: widget.talent.portfolioUrls,
                        initialIndex: 0,
                      ),
                    ),
                  );
                },
                child: SizedBox(
                  height: 250,
                  child: Image.network(widget.talent.portfolioUrls.first,
                      fit: BoxFit.cover, width: double.infinity),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.talent.title,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    'Rp ${widget.talent.price} / ${widget.talent.priceUnit}', // 포맷터 적용 필요 시 수정
                    style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  Text('jobs.talent.detail.descriptionTitle'.tr(),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(widget.talent.description),
                  const SizedBox(height: 24),
                  // 위치 정보
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          displayAddress.isNotEmpty
                              ? displayAddress
                              : (widget.talent.locationName ??
                                  'jobs.talent.detail.locationUnknown'.tr()),
                          style: const TextStyle(color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: (isOwner || _isChatLoading) ? null : startChat,
            style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16)),
            child: _isChatLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : Text('jobs.talent.action.contact'.tr()),
          ),
        ),
      ),
    );
  }
}
