// lib/features/real_estate/data/room_repository.dart

import 'package:bling_app/core/models/room_listing_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoomRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 'room_listings' 컬렉션의 모든 매물 목록을 실시간으로 가져옵니다.
  Stream<List<RoomListingModel>> fetchRooms() {
    return _firestore
        .collection('room_listings')
        .where('isAvailable', isEqualTo: true) // 거래 가능한 매물만 표시
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => RoomListingModel.fromFirestore(doc))
          .toList();
    });
  }

  // 새로운 부동산 매물을 생성하는 함수

   Future<void> createRoomListing(RoomListingModel room) async {
    await _firestore.collection('room_listings').add(room.toJson());
  }


}