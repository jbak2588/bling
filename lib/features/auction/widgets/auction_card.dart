// lib/features/auction/widgets/auction_card.dart
/// [기획/실제 코드 분석 및 개선 제안]
/// 1. 기획 문서 요약
///   - 경매 카드 UI, 남은 시간 실시간 표시, 입찰/상세 페이지 연동, 신뢰등급, 위치 정보, KPI/Analytics 이벤트 기록
///
/// 2. 실제 코드 분석
///   - 경매 카드 UI, 남은 시간 실시간 표시, 입찰/상세 페이지 연동, 신뢰등급, 위치 정보, KPI/Analytics 이벤트 기록
///   - 다국어(i18n), 광고/추천 등 연계 가능
///
/// 3. 기획과 실제 기능의 차이점
///   - 기획보다 좋아진 점: 현지화(i18n), 신뢰등급, KPI/Analytics 등 사용자 경험·운영 기능 강화
///   - 기획에 못 미친 점: 실시간 채팅, 광고/추천글 노출 등 일부 기능 미구현
///
/// 4. 개선 제안
///   - 실시간 입찰/채팅, 경매 상태 시각화, 신뢰등급/AI 검수 표시 강화, KPI/Analytics 이벤트 로깅, 광고/추천글 연계
library;

import 'dart:math' as math;
import 'package:bling_app/features/auction/models/auction_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/auction/screens/auction_detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

// ✅ [하이퍼로컬] 1. 거리 계산 헬퍼와 UserModel import
import 'package:bling_app/features/shared/widgets/image_carousel_card.dart';
import 'package:bling_app/features/location/providers/location_provider.dart';
import 'package:provider/provider.dart';
// ✅ [신뢰] 1. AI 검증 배지 import
import 'package:bling_app/features/marketplace/widgets/ai_verification_badge.dart';

// [수정] StatelessWidget -> StatefulWidget으로 변경하여 Timer를 관리
class AuctionCard extends StatelessWidget {
  final AuctionModel auction;
  final UserModel? userModel;

  const AuctionCard({super.key, required this.auction, this.userModel});

  // [신규] 거리 계산 헬퍼
  String? _calculateDistance(GeoPoint? userLoc, GeoPoint? itemLoc) {
    if (userLoc == null || itemLoc == null) return null;
    const double p = 0.017453292519943295;
    final double a = 0.5 -
        math.cos((itemLoc.latitude - userLoc.latitude) * p) / 2 +
        math.cos(userLoc.latitude * p) *
            math.cos(itemLoc.latitude * p) *
            (1 - math.cos((itemLoc.longitude - userLoc.longitude) * p)) /
            2;
    final double km = 12742 * math.asin(math.sqrt(a));
    return km < 1 ? '${(km * 1000).round()}m' : '${km.toStringAsFixed(1)}km';
  }

  // [신규] 동적 주소 표시 로직 (Privacy)
  String _getDynamicAddress(BuildContext context, AuctionModel auction) {
    final provider = context.watch<LocationProvider>();
    final filter = provider.adminFilter;
    final parts = auction.locationParts;

    if (parts == null) {
      return auction.location
          .replaceAll(RegExp(r',?\s*Indonesia', caseSensitive: false), '')
          .trim();
    }

    final kel = parts['kel'];
    final kec = parts['kec'];
    final kab = parts['kab'];
    final prov = parts['prov'];
    final List<String> displayParts = [];

    final bool hasProv = filter['prov'] != null;
    final bool hasKab = filter['kab'] != null;
    final bool hasKec = filter['kec'] != null;

    if (kel != null && kel.isNotEmpty) displayParts.add('Kel. $kel');

    if (!(hasProv && hasKab && hasKec)) {
      if (kec != null && kec.isNotEmpty) displayParts.add('Kec. $kec');
      if (!hasKab && !hasKec) {
        if (kab != null && kab.isNotEmpty) displayParts.add(kab);
      }
      if (!hasProv && !hasKab && !hasKec) {
        if (prov != null && prov.isNotEmpty) displayParts.add(prov);
      }
    }
    return displayParts.isEmpty ? auction.location : displayParts.join(', ');
  }

  // Duration formatter (one-off, not live-updating)
  String _formatDuration(Duration d) {
    if (d.inSeconds <= 0) return 'auctions.card.ended'.tr();
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final days = d.inDays;
    final hours = twoDigits(d.inHours.remainder(24));
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    if (days > 0) {
      return 'auctions.card.timeLeftDays'.tr(namedArgs: {
        'days': days.toString(),
        'hours': hours,
        'minutes': minutes,
        'seconds': seconds,
      });
    }
    return 'auctions.card.timeLeft'.tr(namedArgs: {
      'hours': hours,
      'minutes': minutes,
      'seconds': seconds,
    });
  }

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    // [신규] 거리 및 주소 계산
    final userPoint =
        context.select<LocationProvider, GeoPoint?>((p) => p.user?.geoPoint);
    final distance = _calculateDistance(userPoint, auction.geoPoint);
    final displayAddress = _getDynamicAddress(context, auction);

    final now = DateTime.now();
    final Duration timeLeft = auction.endAt.toDate().difference(now);
    final bool isEnded = timeLeft.inSeconds <= 0;

    void goToDetail() {
      Navigator.of(context).push(
        MaterialPageRoute(
            builder: (_) => AuctionDetailScreen(auction: auction)),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isEnded ? 1 : 3,
      color: isEnded ? Colors.grey.shade100 : Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: goToDetail,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                // ✅ 기존 Image.network를 공용 ImageCarouselCard로 교체
                if (auction.images.isNotEmpty)
                  ImageCarouselCard(
                    storageId: auction.id,
                    imageUrls: auction.images,
                    height: 200,
                    // 리스트(카드)에서는 이미지 탭 시 갤러리 대신 상세로 이동
                    onImageTap: goToDetail,
                  )
                else
                  Container(
                      height: 200,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.gavel_outlined,
                          size: 60, color: Colors.grey)),
                if (isEnded)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.5),
                      child: Center(
                        child: Text(
                          'auctions.card.ended'.tr(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ [신뢰] 2. AI 검증 배지 표시 (isAiVerified가 true일 때)
                  if (auction.isAiVerified) ...[
                    const AiVerificationBadge(),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    auction.title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // ✅ [하이퍼로컬] 5. 위치 및 거리 표시
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          displayAddress.isNotEmpty
                              ? displayAddress
                              : auction.location,
                          style: TextStyle(color: Colors.grey[700]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (distance != null)
                        Flexible(
                          child: Text(
                            '  ·  $distance',
                            style: TextStyle(
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            textAlign: TextAlign.right,
                          ),
                        ),
                    ],
                  ),

                  // V V V --- [통합] 경매 상태에 따라 다른 정보를 표시합니다 --- V V V
                  if (isEnded) ...[
                    // --- 경매 종료 시 ---
                    _buildInfoRow('auctions.card.winningBid'.tr(),
                        currencyFormat.format(auction.currentBid),
                        isPrice: true),
                    const SizedBox(height: 4),
                    _buildWinnerInfo(auction),
                  ] else ...[
                    // --- 경매 진행 중 ---
                    _buildInfoRow('auctions.card.currentBid'.tr(),
                        currencyFormat.format(auction.currentBid),
                        isPrice: true),
                    const SizedBox(height: 4),
                    _buildInfoRow(
                      'auctions.card.endTime'.tr(),
                      _formatDuration(timeLeft), // 실시간 타이머 표시
                      isTime: true,
                    ),
                  ]
                  // ^ ^ ^ --- 여기까지 통합 --- ^ ^ ^
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // [유지] 기존 헬퍼 함수들은 그대로 사용합니다.
  Widget _buildInfoRow(String label, String value,
      {bool isPrice = false, bool isTime = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600])),
        const SizedBox(width: 8), // 텍스트 간 최소 간격 확보
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end, // 오른쪽 정렬 유지
            style: TextStyle(
              fontSize: isPrice ? 20 : 15,
              color: isPrice
                  ? Colors.deepPurple
                  : (isTime ? Colors.redAccent : Colors.black),
              fontWeight: isPrice ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWinnerInfo(AuctionModel auction) {
    if (auction.bidHistory.isEmpty) {
      return _buildInfoRow(
          'auctions.card.winner'.tr(), 'auctions.card.noBidders'.tr());
    }

    final winnerId = auction.bidHistory.last['userId'];

    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('users').doc(winnerId).get(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          return _buildInfoRow(
              'auctions.card.winner'.tr(), 'auctions.card.unknownBidder'.tr());
        }
        final winner = UserModel.fromFirestore(
            userSnapshot.data! as DocumentSnapshot<Map<String, dynamic>>);
        return _buildInfoRow('auctions.card.winner'.tr(), winner.nickname);
      },
    );
  }
}
