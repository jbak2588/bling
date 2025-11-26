// ===================== DocHeader =====================
// [기획 요약]
// - 부동산(월세/하숙) 매물 카드. 대표 이미지, 제목, 가격, 위치, 편의시설 등 요약 정보 표시, 상세 화면 연동.
//
// [실제 구현 비교]
// - 대표 이미지, 제목, 가격, 위치, 편의시설 등 모든 정보 정상 표시. 상세 화면 연동 및 UI/UX 완비.
//
// [개선 제안]
// - KPI/통계/프리미엄 기능 실제 구현 필요(조회수, 부스트 등).
// - 신뢰 등급/차단/신고 UI 노출 및 기능 강화, 카드 UX 개선.
// =====================================================
// [작업 이력 (2025-11-02)]
// 1. (Task 23) '직방' 모델 도입 (Gap 1, 3, 5).
// 2. [Gap 1] '직방' 스타일 UI: '방/욕실/면적' 등 핵심 정보를 카드 상단에 표시.
// 3. [Gap 3] '찜하기' 버튼: 'ImageCarouselCard'의 'topRightWidget'에 찜하기 토글 버튼 추가 (StreamBuilder 연동).
// 4. [Gap 5] '광고/인증' 배지: 'topLeftWidget'에 'isSponsored'(광고) 및 'isVerified'(인증) 배지 표시.
// 5. 'StatelessWidget' -> 'StatefulWidget'으로 변경 (찜하기 상태 관리를 위함).
// 6. [수정] (Task 14): 'room.type'에 따라 'Kos' 전용 핵심 정보(욕실, 가구)를 표시하도록 `_buildKeyInfoRow` 수정.
// =====================================================
// [V2.0 작업 이력 (2025-11-05)]
// 1. (Task 17) `_buildKeyInfoRow` 로직 수정.
// 2. (Task 17) `room.type == 'kos'`일 경우:
//    - 기존 '방/욕실/면적' 대신 '욕실 타입'(예: 방 내부 욕실)과 '가구 상태'(예: 가구 완비)를 표시.
// 3. (Task 17) 'Kos' 외 다른 타입은 기존 '방/욕실/면적' 정보 표시 유지.
// 4. (기존) '직방' 모델(Task 23)의 '찜하기', '광고/인증' 배지 기능 유지.
// =====================================================
// lib/features/real_estate/widgets/room_card.dart

import 'package:bling_app/features/real_estate/data/room_repository.dart';
import 'package:bling_app/features/real_estate/models/room_listing_model.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:bling_app/features/real_estate/screens/room_detail_screen.dart';
import 'package:bling_app/features/shared/widgets/image_carousel_card.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ✅ StatelessWidget을 StatefulWidget으로 변경
class RoomCard extends StatefulWidget {
  final RoomListingModel room;
  final void Function(Widget, String)? onIconTap;
  const RoomCard({super.key, required this.room, this.onIconTap});

  @override
  State<RoomCard> createState() => _RoomCardState();
}

class _RoomCardState extends State<RoomCard>
    with AutomaticKeepAliveClientMixin {
  final NumberFormat currencyFormat =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  // [추가] Gap 3: 찜하기
  final RoomRepository _repository = RoomRepository();
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;

  @override
  bool get wantKeepAlive => true; // ✅ 상태 유지

  @override
  Widget build(BuildContext context) {
    super.build(context); // ✅ KeepAlive를 위해 호출
    final room = widget.room; // ✅ room 참조 방식 변경

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        // [수정] 클릭 시 상세 화면으로 이동 (onIconTap 우선 호출)
        onTap: () {
          final detail = RoomDetailScreen(room: widget.room);
          if (widget.onIconTap != null) {
            widget.onIconTap!(detail, 'main.tabs.realEstate');
            return;
          }
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => detail,
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ 이미지 캐러셀 + 오버레이 (찜 버튼 / 스폰서 배지)
            if (room.imageUrls.isNotEmpty)
              Stack(
                children: [
                  ImageCarouselCard(
                    storageId: room.id,
                    imageUrls: room.imageUrls,
                    height: 200,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _currentUserId == null
                        ? const SizedBox
                            .shrink() // Return an empty widget instead of null
                        : StreamBuilder<bool>(
                            stream: _repository.isBookmarkedStream(
                                _currentUserId!, room.id),
                            builder: (context, snapshot) {
                              final isBookmarked = snapshot.data ?? false;
                              return IconButton(
                                icon: Icon(
                                  isBookmarked
                                      ? Icons.bookmark
                                      : Icons.bookmark_border,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  _repository.toggleBookmark(
                                      _currentUserId!, room.id, isBookmarked);
                                },
                              );
                            },
                          ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Wrap(
                      spacing: 4.0,
                      children: [
                        if (room.isSponsored)
                          _buildBadge(context, 'common.sponsored'.tr(),
                              Theme.of(context).primaryColor),
                        if (room.isVerified)
                          _buildBadge(context, 'common.verified'.tr(),
                              Colors.blue.shade700),
                      ],
                    ),
                  ),
                ],
              )
            else
              Stack(
                children: [
                  Container(
                    height: 200,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.house_outlined,
                        size: 60, color: Colors.grey),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.bookmark_border,
                          color: Colors.white),
                      onPressed: () {},
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Wrap(
                      spacing: 4.0,
                      children: [
                        if (room.isSponsored)
                          _buildBadge(context, 'common.sponsored'.tr(),
                              Theme.of(context).primaryColor),
                        if (room.isVerified)
                          _buildBadge(context, 'common.verified'.tr(),
                              Colors.blue.shade700),
                      ],
                    ),
                  ),
                ],
              ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // [수정] (Task 14): 타입에 따른 핵심 정보 표시 (Kos: 욕실/가구, 기타: 면적/방/욕실)
                  _buildKeyInfoRow(context, room),
                  const SizedBox(height: 4),
                  Text(
                    room.title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${currencyFormat.format(room.price)} / ${'realEstate.priceUnits.${room.priceUnit}'.tr()}',
                    style: TextStyle(
                        fontSize: 17,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          room.locationName ??
                              'realEstate.locationUnknown'.tr(),
                          style:
                              TextStyle(fontSize: 13, color: Colors.grey[700]),
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
    );
  }

  // [추가] Gap 5: 배지 UI 빌더
  Widget _buildBadge(BuildContext context, String label, Color color) {
    return Card(
      color: color,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Text(label,
            style: const TextStyle(color: Colors.white, fontSize: 12)),
      ),
    );
  }

  /// [추가] Gap 1: '직방' 모델의 핵심 정보 (방/욕실/면적) 표시줄
  /// [수정] (Task 14): 'room.type'에 따라 'Kos' 전용 정보(욕실 타입/가구 상태) 또는 기본 정보(면적/방/욕실)를 표시
  Widget _buildKeyInfoRow(BuildContext context, RoomListingModel room) {
    // 'Kos' 타입일 경우, "욕실 타입"과 "가구 상태"를 표시
    if (room.type == 'kos') {
      // 욕실 타입 텍스트
      final bathroomText = room.kosBathroomType == 'in_room'
          ? 'realEstate.filter.kos.bathroomTypes.in_room'.tr()
          : (room.kosBathroomType == 'out_room'
              ? 'realEstate.filter.kos.bathroomTypes.out_room'.tr()
              // 예외 처리 기본값
              : 'Info Kamar Mandi');

      // 가구 상태 텍스트
      final furnishedText = room.furnishedStatus != null
          ? 'realEstate.filter.furnishedTypes.${room.furnishedStatus!}'.tr()
          : 'Info Furnitur';

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildRoomInfoItem(
            context,
            icon: Icons.bathtub_outlined,
            label: bathroomText,
          ),
          _buildRoomInfoItem(
            context,
            icon: Icons.chair_outlined,
            label: furnishedText,
          ),
        ],
      );
    }

    // 기타 타입: 면적/방/욕실 표시
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildRoomInfoItem(
          context,
          icon: Icons.fullscreen_outlined,
          label: '${room.area.toStringAsFixed(0)} m²',
        ),
        _buildRoomInfoItem(
          context,
          icon: Icons.king_bed_outlined,
          label: 'realEstate.form.rooms'
              .tr(namedArgs: {'count': '${room.roomCount}'}),
        ),
        _buildRoomInfoItem(
          context,
          icon: Icons.bathtub_outlined,
          label: 'realEstate.form.bathrooms'
              .tr(namedArgs: {'count': '${room.bathroomCount}'}),
        ),
      ],
    );
  }

  /// 아이콘 + 라벨로 구성된 핵심 정보 아이템 위젯
  Widget _buildRoomInfoItem(BuildContext context,
      {required IconData icon, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Theme.of(context).primaryColor),
        const SizedBox(width: 6),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 120),
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
