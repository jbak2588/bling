// lib/features/real_estate/widgets/room_card.dart

import 'package:bling_app/core/models/room_listing_model.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:bling_app/features/real_estate/screens/room_detail_screen.dart';

class RoomCard extends StatelessWidget {
  final RoomListingModel room;
  const RoomCard({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
      // V V V --- [수정] onTap에 상세 화면으로 이동하는 로직을 추가합니다 --- V V V
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => RoomDetailScreen(room: room),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (room.imageUrls.isNotEmpty)
              Image.network(
                room.imageUrls.first,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                    height: 200,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.house_outlined,
                        size: 60, color: Colors.grey)),
              )
            else
              Container(
                  height: 200,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.house_outlined,
                      size: 60, color: Colors.grey)),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
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
}
