// lib/features/real_estate/screens/room_detail_screen.dart
// ===================== DocHeader =====================
// [기획 요약]
// - 부동산(월세/하숙) 매물 상세 정보, 이미지 갤러리, 채팅 연동, 가격, 편의시설 등 다양한 필드 지원.
//
// [실제 구현 비교]
// - 상세 정보, 이미지 갤러리, 채팅 연동, 가격, 편의시설 등 모든 주요 기능 정상 동작.
// - UI/UX 완비, 채팅방 생성 및 임대인 정보 연동 구현됨.
//
// [개선 제안]
// - KPI/통계/프리미엄 기능 실제 구현 필요(조회수, 부스트 등).
// - 신고/차단/신뢰 등급 UI 노출 및 기능 강화, 알림/편의시설 UX 개선.
// =====================================================

import 'package:bling_app/features/real_estate/models/room_listing_model.dart';
// import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/chat/data/chat_service.dart';
import 'package:bling_app/features/chat/screens/chat_room_screen.dart';
import 'package:bling_app/features/real_estate/data/room_repository.dart';
import 'package:bling_app/features/real_estate/screens/edit_room_listing_screen.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
// import 'package:photo_view/photo_view.dart';
// import 'package:photo_view/photo_view_gallery.dart';

import 'package:bling_app/features/shared/widgets/author_profile_tile.dart';
import 'package:bling_app/features/shared/widgets/clickable_tag_list.dart';
import 'package:bling_app/features/shared/widgets/mini_map_view.dart';
import 'package:bling_app/features/shared/screens/image_gallery_screen.dart';
import 'package:bling_app/features/shared/widgets/image_carousel_card.dart';

class RoomDetailScreen extends StatefulWidget {
  final RoomListingModel room;
  const RoomDetailScreen({super.key, required this.room});

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  final RoomRepository _repository = RoomRepository();
  final ChatService _chatService = ChatService();
  // int _currentImageIndex = 0;

  void _startChat(BuildContext context, String ownerId) async {
    try {
      final chatId = await _chatService.createOrGetChatRoom(
        otherUserId: ownerId,
        roomId: widget.room.id,
        roomTitle: widget.room.title,
        roomImage: widget.room.imageUrls.isNotEmpty ? widget.room.imageUrls.first : null,
      );
      
      final otherUser = await _chatService.getOtherUserInfo(ownerId);

      if (!context.mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ChatRoomScreen(
            chatId: chatId,
            otherUserName: otherUser.nickname,
            otherUserId: otherUser.uid,
            productTitle: widget.room.title,
          ),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('채팅을 시작할 수 없습니다: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteListing() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('매물 삭제'),
        content: Text('정말로 이 매물을 삭제하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text('취소')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text('삭제', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _repository.deleteRoomListing(widget.room.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('매물이 삭제되었습니다.'), backgroundColor: Colors.green));
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('삭제에 실패했습니다: $e'), backgroundColor: Colors.red));
        }
      }
    }
  }

  
  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final NumberFormat currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return StreamBuilder<RoomListingModel>(
      stream: _repository.getRoomStream(widget.room.id), // Repository에 getRoomStream 필요
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final room = snapshot.data!;
        final isOwner = room.userId == currentUserId;

        return Scaffold(
          appBar: AppBar(
            title: Text(room.title),
            actions: [
              if (isOwner)
                IconButton(
                  icon: const Icon(Icons.edit_note_outlined),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => EditRoomListingScreen(room: room)),
                    );
                  },
                ),
              if (isOwner)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: _deleteListing,
                ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 100.0),
            children: [
             // ✅ 기존 이미지 슬라이더를 공용 위젯으로 교체
              if (room.imageUrls.isNotEmpty)
                GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => ImageGalleryScreen(imageUrls: room.imageUrls),
                  )),
                  child: ImageCarouselCard(
                    storageId: room.id,
                    imageUrls: room.imageUrls,
                    height: 250,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(room.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      '${currencyFormat.format(room.price)} / ${'realEstate.priceUnits.${room.priceUnit}'.tr()}',
                      style: TextStyle(fontSize: 20, color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                    ),
                    const Divider(height: 32),
                    Text('상세 정보', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(room.description, style: const TextStyle(fontSize: 16, height: 1.5)),
const SizedBox(height: 16),

                    // ✅ 태그, 지도, 작성자 정보 공용 위젯 추가
                    ClickableTagList(tags: room.tags),
                    if (room.geoPoint != null) ...[
                      const Divider(height: 32),
                      Text('위치', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 12),
                      MiniMapView(location: room.geoPoint!, markerId: room.id),
                    ],
 const Divider(height: 32),

                    Text('게시자 정보', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    // ✅ 기존 _buildOwnerInfo를 공용 AuthorProfileTile로 교체
                    AuthorProfileTile(userId: room.userId),
                  ],
                ),
              )
            ],
          ),
          bottomNavigationBar: isOwner ? null : Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () => _startChat(context, room.userId),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text('문의하기'),
            ),
          ),
        );
      },
    );
  }


}



