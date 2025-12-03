// lib/features/real_estate/screens/room_detail_screen.dart
// 주의: 공유/딥링크를 만들 때 호스트를 직접 하드코딩하지 마세요.
// 대신 `lib/core/constants/app_links.dart`의 `kHostingBaseUrl`을 사용하세요.
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
// [작업 이력 (2025-11-02)]
// 1. (Task 23) '직방' 모델 도입 (Gap 1, 3, 5).
// 2. [수정] (Task 23) 'amenities' 제거, 'roomType'별 상세 시설(Fasilitas) 표시 로직 추가.
// 2. [Gap 5] 'initState': 조회수 증가를 위해 'repository.incrementViewCount' 호출.
// 3. [Gap 3] '찜하기' 버튼: 'AppBar'에 'isBookmarkedStream'과 연동된 찜하기 아이콘 버튼 추가.
// 4. [Gap 1] 핵심 정보 UI: '면적', '방 수', '욕실 수', '입주 가능일'을 표시하는 그리드 UI 추가.
// 5. [Gap 5] '인증' 배지: 'isVerified'가 true일 때 게시자 정보란에 '인증된 게시자' 배지 표시.
// =====================================================
// - 부동산 매물 상세 화면.
// - V2.0: 'roomType'에 따라 현지화된 상세 시설 정보를 동적으로 표시.
//
// [V2.0 작업 이력 (2025-11-05)]
// 1. (Task 8) `_buildDynamicFacilityLists` 헬퍼 함수 신규 추가.
// 2. (Task 8) `room.type`을 `switch`하여 'Kos'의 경우 '방 시설', '공용 시설'을,
//    'Apartment'의 경우 '아파트 시설'을 구분하여 칩(Chip) 목록으로 표시.
// 3. (기존) '직방' 모델(Task 23)의 '조회수 증가', '찜하기', '핵심 정보 그리드' 기능 유지.
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
// [추가]
// import 'package:photo_view/photo_view.dart';
// import 'package:photo_view/photo_view_gallery.dart';

import 'package:bling_app/features/shared/widgets/author_profile_tile.dart';
import 'package:bling_app/features/shared/widgets/clickable_tag_list.dart';
import 'package:bling_app/features/shared/widgets/mini_map_view.dart';
import 'package:bling_app/features/shared/screens/image_gallery_screen.dart';
import 'package:bling_app/features/shared/widgets/image_carousel_card.dart';
import 'package:bling_app/features/shared/widgets/app_bar_icon.dart';
import 'package:share_plus/share_plus.dart';
import 'package:bling_app/core/constants/app_links.dart';

class RoomDetailScreen extends StatefulWidget {
  final RoomListingModel room;
  final bool embedded;
  final VoidCallback? onClose;
  const RoomDetailScreen(
      {super.key, required this.room, this.embedded = false, this.onClose});

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
        roomImage: widget.room.imageUrls.isNotEmpty
            ? widget.room.imageUrls.first
            : null,
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
          SnackBar(
              content: Text('realEstate.detail.chatError'
                  .tr(namedArgs: {'error': e.toString()})),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteListing() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('realEstate.detail.deleteTitle'.tr()),
        content: Text('realEstate.detail.deleteContent'.tr()),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('realEstate.detail.cancel'.tr())),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('realEstate.detail.deleteConfirm'.tr(),
                  style: const TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _repository.deleteRoomListing(widget.room.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('realEstate.detail.deleteSuccess'.tr()),
              backgroundColor: Colors.green));
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('realEstate.detail.deleteFail'
                  .tr(namedArgs: {'error': e.toString()})),
              backgroundColor: Colors.red));
        }
      }
    }
  }

  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;
  final NumberFormat currencyFormat =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    // [추가] Gap 5: 조회수 1 증가
    if (widget.room.userId != _currentUserId) {
      _repository.incrementViewCount(widget.room.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final NumberFormat currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return StreamBuilder<RoomListingModel>(
      stream: _repository
          .getRoomStream(widget.room.id), // Repository에 getRoomStream 필요
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          if (widget.embedded) {
            return const Center(child: CircularProgressIndicator());
          }
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        final room = snapshot.data!;
        final isOwner = room.userId == currentUserId;

        final body = ListView(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 100.0),
          children: [
            // ✅ 기존 이미지 슬라이더를 공용 위젯으로 교체
            if (room.imageUrls.isNotEmpty)
              GestureDetector(
                onTap: () {
                  if (widget.embedded && widget.onClose != null) {
                    widget.onClose!();
                  }
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) =>
                        ImageGalleryScreen(imageUrls: room.imageUrls),
                  ));
                },
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
                  Text(room.title,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  // [추가] Gap 1: '직방' 스타일 핵심 정보
                  Text(
                    '${'realEstate.form.roomTypes.${room.type}'.tr()} · ${'realEstate.form.listingTypes.${room.listingType}'.tr()}',
                    style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${currencyFormat.format(room.price)} / ${'realEstate.priceUnits.${room.priceUnit}'.tr()}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold),
                  ),
                  const Divider(height: 32),

                  // [추가] Gap 1: 방/욕실/면적/입주
                  _buildInfoGrid(room),

                  // [신규] '작업 8': 'amenities' 대신 'roomType'별 시설 목록 표시
                  _buildDynamicFacilityLists(context, room),
                  const Divider(height: 32),
                  Text('realEstate.form.details'.tr(),
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(room.description,
                      style: const TextStyle(fontSize: 16, height: 1.5)),
                  const SizedBox(height: 16),

                  // ✅ 태그, 지도, 작성자 정보 공용 위젯 추가
                  ClickableTagList(tags: room.tags),
                  if (room.geoPoint != null) ...[
                    const Divider(height: 32),
                    Text('realEstate.detail.location'.tr(),
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    MiniMapView(location: room.geoPoint!, markerId: room.id),
                  ],
                  const Divider(height: 32),

                  Text('realEstate.detail.publisherInfo'.tr(),
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  AuthorProfileTile(userId: room.userId),
                  if (room.isVerified)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          Icon(Icons.verified,
                              color: Colors.blue.shade700, size: 18),
                          const SizedBox(width: 8),
                          Text('realEstate.info.verifiedPublisher'.tr(),
                              style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                ],
              ),
            )
          ],
        );

        if (widget.embedded) {
          return Container(color: Colors.white, child: body);
        }

        return Scaffold(
          appBar: AppBar(
            leading: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: AppBarIcon(
                icon: Icons.arrow_back,
                onPressed: () {
                  if (widget.embedded && widget.onClose != null) {
                    widget.onClose!();
                    return;
                  }
                  Navigator.of(context).pop();
                },
              ),
            ),
            title: Text(room.title),
            actions: [
              // [추가] Gap 3: 찜하기 버튼
              if (_currentUserId != null && !isOwner)
                StreamBuilder<bool>(
                  stream:
                      _repository.isBookmarkedStream(_currentUserId!, room.id),
                  builder: (context, snapshot) {
                    final isBookmarked = snapshot.data ?? false;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: AppBarIcon(
                        icon: isBookmarked
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        onPressed: () {
                          _repository.toggleBookmark(
                              _currentUserId!, room.id, isBookmarked);
                        },
                      ),
                    );
                  },
                ),
              if (isOwner)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: AppBarIcon(
                    icon: Icons.edit,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EditRoomListingScreen(room: room),
                        ),
                      );
                    },
                  ),
                ),
              if (isOwner)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: _deleteListing,
                ),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: AppBarIcon(
                  icon: Icons.share,
                  onPressed: () => SharePlus.instance.share(
                    ShareParams(
                        text:
                            '${room.title}\n$kHostingBaseUrl/rooms/${room.id}'),
                  ),
                ),
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
                    builder: (_) =>
                        ImageGalleryScreen(imageUrls: room.imageUrls),
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
                    Text(room.title,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    // [추가] Gap 1: '직방' 스타일 핵심 정보
                    Text(
                      '${'realEstate.form.roomTypes.${room.type}'.tr()} · ${'realEstate.form.listingTypes.${room.listingType}'.tr()}',
                      style: TextStyle(
                          fontSize: 15,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${currencyFormat.format(room.price)} / ${'realEstate.priceUnits.${room.priceUnit}'.tr()}',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold),
                    ),
                    const Divider(height: 32),

                    // [추가] Gap 1: 방/욕실/면적/입주
                    _buildInfoGrid(room),

                    // [신규] '작업 8': 'amenities' 대신 'roomType'별 시설 목록 표시
                    _buildDynamicFacilityLists(context, room),
                    const Divider(height: 32),
                    Text('realEstate.form.details'.tr(),
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(room.description,
                        style: const TextStyle(fontSize: 16, height: 1.5)),
                    const SizedBox(height: 16),

                    // ✅ 태그, 지도, 작성자 정보 공용 위젯 추가
                    ClickableTagList(tags: room.tags),
                    if (room.geoPoint != null) ...[
                      const Divider(height: 32),
                      Text('realEstate.detail.location'.tr(),
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 12),
                      MiniMapView(location: room.geoPoint!, markerId: room.id),
                    ],
                    const Divider(height: 32),

                    Text('realEstate.detail.publisherInfo'.tr(),
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    // ✅ 기존 _buildOwnerInfo를 공용 AuthorProfileTile로 교체
                    AuthorProfileTile(userId: room.userId),
                    // [추가] Gap 5: 인증 배지
                    if (room.isVerified)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            Icon(Icons.verified,
                                color: Colors.blue.shade700, size: 18),
                            const SizedBox(width: 8),
                            Text('realEstate.info.verifiedPublisher'.tr(),
                                style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                  ],
                ),
              )
            ],
          ),
          bottomNavigationBar: isOwner
              ? null
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () => _startChat(context, room.userId),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text('realEstate.detail.contact'.tr()),
                  ),
                ),
        );
      },
    );
  }

  // [신규] '작업 8': 'roomType'에 따라 동적 시설 목록 UI 빌드
  Widget _buildDynamicFacilityLists(
      BuildContext context, RoomListingModel room) {
    switch (room.type) {
      case 'kos':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFacilityList(
              context,
              'realEstate.filter.kos.roomFacilities'.tr(),
              room.kosRoomFacilities,
            ),
            _buildFacilityList(
              context,
              'realEstate.filter.kos.publicFacilities'.tr(),
              room.kosPublicFacilities,
            ),
          ],
        );
      case 'apartment':
        return _buildFacilityList(
          context,
          'realEstate.filter.apartment.facilities'.tr(),
          room.apartmentFacilities,
        );
      case 'house':
      case 'kontrakan':
        return _buildFacilityList(
          context,
          'realEstate.filter.house.facilities'.tr(),
          room.houseFacilities,
        );
      case 'ruko':
      case 'kantor':
      case 'gudang':
        return _buildFacilityList(
          context,
          'realEstate.filter.commercial.facilities'.tr(),
          room.commercialFacilities,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  /// [신규] '작업 8': 시설 목록 UI를 그리는 헬퍼
  Widget _buildFacilityList(
      BuildContext context, String title, List<String> facilityKeys) {
    if (facilityKeys.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: facilityKeys.map((key) {
              return Chip(label: Text('realEstate.filter.amenities.$key').tr());
            }).toList(),
          ),
        ],
      ),
    );
  }

  // [추가] Gap 1: 핵심 정보 그리드
  Widget _buildInfoGrid(RoomListingModel room) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      // Increase vertical space for each grid tile to avoid overflow on
      // smaller devices or when text sizes are large.
      childAspectRatio: 3.2, // was 5
      children: [
        _buildInfoTile(
          Icons.fullscreen_outlined,
          'realEstate.form.area'.tr(),
          '${room.area.toStringAsFixed(0)} m²',
        ),
        _buildInfoTile(
          Icons.king_bed_outlined,
          'realEstate.form.rooms'.tr(),
          '${room.roomCount}',
        ),
        _buildInfoTile(
          Icons.bathtub_outlined,
          'realEstate.form.bathrooms'.tr(),
          '${room.bathroomCount}',
        ),
        _buildInfoTile(
          Icons.calendar_today_outlined,
          'realEstate.form.moveInDate'.tr(),
          room.moveInDate == null
              ? 'realEstate.info.anytime'.tr()
              : DateFormat('yyyy-MM-dd').format(room.moveInDate!.toDate()),
        ),
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.grey[700], size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 2),
              Text(value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        )
      ],
    );
  }
}
