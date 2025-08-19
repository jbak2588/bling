// lib/features/real_estate/data/room_repository.dart

import 'package:bling_app/features/real_estate/models/room_listing_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoomRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // V V V --- [추가] 컬렉션 참조를 위한 getter를 정의하여 코드 일관성을 유지합니다 --- V V V
  CollectionReference<Map<String, dynamic>> get _roomsCollection =>
      _firestore.collection('room_listings');
  // ^ ^ ^ --- 여기까지 추가 --- ^ ^ ^

  /// 'room_listings' 컬렉션의 모든 매물 목록을 실시간으로 가져옵니다.
  Stream<List<RoomListingModel>> fetchRooms() {
    return _roomsCollection // [수정] getter 사용
        .where('isAvailable', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => RoomListingModel.fromFirestore(doc))
          .toList();
    });
  }

  /// 새로운 부동산 매물을 생성하는 함수
  Future<void> createRoomListing(RoomListingModel room) async {
    await _roomsCollection.add(room.toJson()); // [수정] getter 사용
  }

  /// 매물 정보를 수정하는 함수
  Future<void> updateRoomListing(RoomListingModel room) async {
    await _roomsCollection.doc(room.id).update(room.toJson());
  }

  /// 매물 정보를 삭제하는 함수
  Future<void> deleteRoomListing(String roomId) async {
    // TODO: Storage에 업로드된 관련 이미지도 함께 삭제하는 로직 추가 필요
    await _roomsCollection.doc(roomId).delete();
  }

  // V V V --- [추가] 특정 매물 하나의 정보를 실시간으로 가져오는 Stream 함수 --- V V V
  Stream<RoomListingModel> getRoomStream(String roomId) {
    return _roomsCollection
        .doc(roomId)
        .snapshots()
        .map((snapshot) => RoomListingModel.fromFirestore(snapshot));
  }
  
}