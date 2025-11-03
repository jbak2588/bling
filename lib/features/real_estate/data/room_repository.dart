// ===================== DocHeader =====================
// [작업 이력 (2025-11-02)]
// 1. (Task 23) '직방' 모델 도입 (Gap 3, 5).
// 2. [Gap 5] 'fetchRooms': 'isSponsored'(광고) 매물을 최상단에 노출하도록 쿼리 수정.
// 3. [Gap 5] 'incrementViewCount': 상세 페이지 조회 시 조회수(KPI)를 1 증가시키는 함수 추가.
// 4. [Gap 3] '찜하기' 기능: 'isBookmarkedStream' (찜 상태 스트림), 'toggleBookmark' (찜 토글) 함수 추가.
// 5. (Task 22) 'fetchRooms': 'RoomFilters' 객체를 파라미터로 받아 가격(서버), 면적/방 개수(클라이언트) 등 상세 필터링 로직 추가.
// 6. (Task 24) [버그 수정] 순환 참조 해결을 위해 'room_filters_model.dart'를 import 하도록 수정.
// =====================================================
// lib/features/real_estate/data/room_repository.dart

import 'package:bling_app/features/real_estate/models/room_listing_model.dart';
import 'package:bling_app/features/real_estate/models/room_filters_model.dart'; // [수정] 순환 참조 해결
import 'package:cloud_firestore/cloud_firestore.dart';

class RoomRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _roomsCollection =>
      _firestore.collection('room_listings');
  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  // V V V --- [수정] locationFilter를 적용한 최종 fetchRooms 함수 --- V V V
  // [수정] isSponsored (광고) 매물을 우선 정렬합니다.
  // [수정] '직방' 스타일 상세 필터(RoomFilters) 적용
  Stream<List<RoomListingModel>> fetchRooms(
      {Map<String, String?>? locationFilter, RoomFilters? filters}) {
    Query<Map<String, dynamic>> query = _roomsCollection
        .where('isAvailable', isEqualTo: true)
        .orderBy('isSponsored', descending: true) // [추가] 광고 매물 우선
        .orderBy('createdAt', descending: true);

    final String? kab = locationFilter?['kab'];
    if (kab != null && kab.isNotEmpty) {
      query = query.where('locationParts.kab', isEqualTo: kab);
    }

    // --- [추가] 1. Firestore(서버) 필터 적용 ---
    if (filters != null) {
      // 매물 유형 (임대/매매)
      if (filters.listingType != null) {
        query = query.where('listingType', isEqualTo: filters.listingType);
      }
      // 방 유형 (Kos/Kontrakan/Sewa)
      if (filters.roomType != null) {
        query = query.where('type', isEqualTo: filters.roomType);
      }
      // 가격 범위 (Firestore의 유일한 범위 필터)
      if (filters.minPrice > 0) {
        query = query.where('price', isGreaterThanOrEqualTo: filters.minPrice);
      }
      if (filters.maxPrice < 50000000) {
        // 50Juta (최대값) 이하일 때만 적용
        query = query.where('price', isLessThanOrEqualTo: filters.maxPrice);
      }
    }

    return query.snapshots().asyncMap((snapshot) async {
      // --- [추가] 2. 클라이언트(앱) 필터 적용 (면적, 방 개수) ---
      List<RoomListingModel> rooms = snapshot.docs
          .map((doc) => RoomListingModel.fromFirestore(doc))
          .toList();

      if (filters != null) {
        rooms = rooms.where((room) {
          final areaMatch =
              room.area >= filters.minArea && room.area <= filters.maxArea;
          final roomCountMatch = filters.roomCount == null ||
              room.roomCount == filters.roomCount ||
              (filters.roomCount == 4 && room.roomCount >= 4);
          return areaMatch && roomCountMatch;
        }).toList();
      }

      if (snapshot.docs.isEmpty && kab != null && kab != 'Tangerang') {
        final fallbackSnapshot = await _roomsCollection
            .where('isAvailable', isEqualTo: true)
            .where('locationParts.kab', isEqualTo: 'Tangerang')
            .orderBy('isSponsored', descending: true) // [추가]
            .orderBy('createdAt', descending: true)
            .get();

        // [수정] Fallback에도 클라이언트 필터 적용
        return fallbackSnapshot.docs
            .map((doc) => RoomListingModel.fromFirestore(doc))
            .where((room) {
          if (filters == null) return true;
          final areaMatch =
              room.area >= filters.minArea && room.area <= filters.maxArea;
          final roomCountMatch = filters.roomCount == null ||
              room.roomCount == filters.roomCount ||
              (filters.roomCount == 4 && room.roomCount >= 4);
          return areaMatch && roomCountMatch;
        }).toList();
      }

      return rooms; // 최종 필터된 목록 반환
    });
  }
  // ^ ^ ^ --- 여기까지 수정 --- ^ ^ ^

  // [추가] 상세 페이지 조회 시 조회수 1 증가 (KPI)
  Future<void> incrementViewCount(String roomId) async {
    await _roomsCollection.doc(roomId).update({
      'viewCount': FieldValue.increment(1),
    });
  }

  Stream<bool> isBookmarkedStream(String userId, String roomId) {
    return _usersCollection.doc(userId).snapshots().map((snapshot) {
      if (!snapshot.exists) return false;
      final List<String> bookmarks =
          List<String>.from(snapshot.data()?['bookmarkedRooms'] ?? []);
      return bookmarks.contains(roomId);
    });
  }

  Future<void> toggleBookmark(
      String userId, String roomId, bool isBookmarked) async {
    final userDocRef = _usersCollection.doc(userId);
    if (isBookmarked) {
      await userDocRef.update({
        'bookmarkedRooms': FieldValue.arrayRemove([roomId])
      });
    } else {
      await userDocRef.update({
        'bookmarkedRooms': FieldValue.arrayUnion([roomId])
      });
    }
  }

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
