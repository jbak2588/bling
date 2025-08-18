// lib/features/auction/widgets/auction_card.dart

import 'dart:async';
import 'package:bling_app/core/models/auction_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/auction/screens/auction_detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

// [수정] StatelessWidget -> StatefulWidget으로 변경하여 Timer를 관리
class AuctionCard extends StatefulWidget {
  final AuctionModel auction;
  const AuctionCard({super.key, required this.auction});

  @override
  State<AuctionCard> createState() => _AuctionCardState();
}

class _AuctionCardState extends State<AuctionCard> {
  Timer? _timer;
  Duration _timeLeft = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateTimeLeft();
    // 1초마다 남은 시간을 다시 계산하여 UI를 업데이트합니다.
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTimeLeft();
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // 위젯이 화면에서 사라질 때 타이머를 반드시 취소합니다.
    super.dispose();
  }

  void _updateTimeLeft() {
    if (!mounted) return;
    final now = DateTime.now();
    final endTime = widget.auction.endAt.toDate();
    final timeLeft = endTime.difference(now);
    setState(() {
      _timeLeft = timeLeft.isNegative ? Duration.zero : timeLeft;
    });
  }

  // [추가] Duration을 "1일 2:30:15 남음" 형태의 문자열로 변환하는 함수
  String _formatDuration(Duration d) {
    if (d.inSeconds <= 0) {
      return 'auctions.card.ended'.tr();
    }
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String days = d.inDays > 0 ? '${d.inDays}일 ' : '';
    String twoDigitHours = twoDigits(d.inHours.remainder(24));
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return '$days$twoDigitHours:$twoDigitMinutes:$twoDigitSeconds 남음'; // TODO: 다국어
  }

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    
    final bool isEnded = _timeLeft.inSeconds <= 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isEnded ? 1 : 3,
      color: isEnded ? Colors.grey.shade100 : Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AuctionDetailScreen(auction: widget.auction),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                if (widget.auction.images.isNotEmpty)
                  Image.network(
                    widget.auction.images.first,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                        height: 200,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.error)),
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
                  Text(
                    widget.auction.title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  
                  // V V V --- [통합] 경매 상태에 따라 다른 정보를 표시합니다 --- V V V
                  if (isEnded) ...[
                    // --- 경매 종료 시 ---
                    _buildInfoRow('auctions.card.winningBid'.tr(),
                        currencyFormat.format(widget.auction.currentBid),
                        isPrice: true),
                    const SizedBox(height: 4),
                    _buildWinnerInfo(widget.auction),
                  ] else ...[
                    // --- 경매 진행 중 ---
                    _buildInfoRow('auctions.card.currentBid'.tr(),
                        currencyFormat.format(widget.auction.currentBid),
                        isPrice: true),
                    const SizedBox(height: 4),
                    _buildInfoRow(
                      'auctions.card.endTime'.tr(),
                      _formatDuration(_timeLeft), // 실시간 타이머 표시
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
  Widget _buildInfoRow(String label, String value, {bool isPrice = false, bool isTime = false}) {
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
              color: isPrice ? Colors.deepPurple : (isTime ? Colors.redAccent : Colors.black),
              fontWeight: isPrice ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWinnerInfo(AuctionModel auction) {
    if (auction.bidHistory.isEmpty) {
      return _buildInfoRow('auctions.card.winner'.tr(), 'auctions.card.noBidders'.tr());
    }

    final winnerId = auction.bidHistory.last['userId'];

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(winnerId).get(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          return _buildInfoRow('auctions.card.winner'.tr(), 'auctions.card.unknownBidder'.tr());
        }
        final winner = UserModel.fromFirestore(userSnapshot.data! as DocumentSnapshot<Map<String, dynamic>>);
        return _buildInfoRow('auctions.card.winner'.tr(), winner.nickname);
      },
    );
  }
}