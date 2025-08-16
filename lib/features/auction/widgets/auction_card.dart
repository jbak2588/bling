// lib/features/auction/widgets/auction_card.dart

import 'package:bling_app/core/models/auction_model.dart';
import 'package:bling_app/features/auction/screens/auction_detail_screen.dart'; // [추가] 상세 화면 임포트
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
// [추가]

class AuctionCard extends StatelessWidget {
  final AuctionModel auction;
  const AuctionCard({super.key, required this.auction});

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    // TODO: 남은 시간을 실시간으로 계산하는 로직(Timer) 추가 필요
    final String timeLeft = DateFormat('MM/dd HH:mm').format(auction.endAt.toDate());


    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        // V V V --- [수정] onTap에 상세 화면으로 이동하는 로직을 추가합니다 --- V V V
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AuctionDetailScreen(auction: auction),
            ),
          );
        },
        // ^ ^ ^ --- 여기까지 수정 --- ^ ^ ^
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (auction.images.isNotEmpty)
              Image.network(
                auction.images.first,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(height: 200, color: Colors.grey.shade200, child: const Icon(Icons.error)),
              )
            else
              Container(height: 200, color: Colors.grey.shade200, child: const Icon(Icons.gavel_outlined, size: 60, color: Colors.grey)),
            
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    auction.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('auctions.card.currentBid'.tr(), style: TextStyle(color: Colors.grey[600])),
                      Text(
                        currencyFormat.format(auction.currentBid),
                        style: const TextStyle(fontSize: 20, color: Colors.deepPurple, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('auctions.card.endTime'.tr(), style: TextStyle(color: Colors.grey[600])),
                      Text(
                        timeLeft,
                        style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.redAccent),
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
}