// lib/features/real_estate/data/room_repository.dart

import 'package:bling_app/features/real_estate/models/room_listing_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoomRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _roomsCollection =>
      _firestore.collection('room_listings');

  // V V V --- [수정] locationFilter를 적용한 최종 fetchRooms 함수 --- V V V
  Stream<List<RoomListingModel>> fetchRooms(
      {Map<String, String?>? locationFilter}) {
    Query<Map<String, dynamic>> query = _roomsCollection
        .where('isAvailable', isEqualTo: true)
        .orderBy('createdAt', descending: true);

    final String? kab = locationFilter?['kab'];
    if (kab != null && kab.isNotEmpty) {
      query = query.where('locationParts.kab', isEqualTo: kab);
    }

    return query.snapshots().asyncMap((snapshot) async {
      if (snapshot.docs.isEmpty && kab != null && kab != 'Tangerang') {
        final fallbackSnapshot = await _roomsCollection
            .where('isAvailable', isEqualTo: true)
            .where('locationParts.kab', isEqualTo: 'Tangerang')
            .orderBy('createdAt', descending: true)
            .get();
        return fallbackSnapshot.docs
            .map((doc) => RoomListingModel.fromFirestore(doc))
            .toList();
      }
      return snapshot.docs
          .map((doc) => RoomListingModel.fromFirestore(doc))
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
