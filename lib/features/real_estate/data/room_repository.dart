// lib/features/real_estate/data/room_repository.dart

import 'package:bling_app/features/real_estate/models/room_listing_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoomRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _roomsCollection =>
      _firestore.collection('room_listings');

  // V V V --- [수정] locationFilter를 적용한 최종 fetchRooms 함수 --- V V V
  Stream<List<RoomListingModel>> fetchRooms({Map<String, String?>? locationFilter}) {
    // 1. 기본 쿼리를 생성합니다.
    Query query = _roomsCollection
        .where('isAvailable', isEqualTo: true)
        .orderBy('createdAt', descending: true);

    // 2. 사용자가 지역 필터를 설정한 경우, 해당 지역으로 쿼리 조건을 추가합니다.
    if (locationFilter != null) {
      final kab = locationFilter['kab'];
      if (kab != null && kab.isNotEmpty) {
        query = query.where('locationParts.kab', isEqualTo: kab);
      }
      // 다른 지역 단위(kec, kel)에 대한 필터가 필요하면 여기에 추가합니다.
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => RoomListingModel.fromFirestore(doc as QueryDocumentSnapshot<Map<String, dynamic>>))
          .toList();
    });
  }
  // ^ ^ ^ --- 여기까지 수정 --- ^ ^ ^

  Future<void> createRoomListing(RoomListingModel room) async {
    await _roomsCollection.add(room.toJson());
  }

  Future<void> updateRoomListing(RoomListingModel room) async {
    await _roomsCollection.doc(room.id).update(room.toJson());
  }

  Future<void> deleteRoomListing(String roomId) async {
    await _roomsCollection.doc(roomId).delete();
  }

  Stream<RoomListingModel> getRoomStream(String roomId) {
    return _roomsCollection
        .doc(roomId)
        .snapshots()
        .map((snapshot) => RoomListingModel.fromFirestore(snapshot));
  }
}