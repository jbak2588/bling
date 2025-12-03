// [Bling] Location refactor Step 5 (Real Estate):
// - Adds BlingLocation-based propertyLocation
// - Uses AddressMapPicker for property location selection
// - Preserves writer neighborhood and radius logic unchanged
// ===================== DocHeader =====================
// [작업 이력 (2025-11-02)]
// 1. (Task 23) '직방' 모델 도입 (Gap 3, 5).
// 2. [Gap 5] 'fetchRooms': 'isSponsored'(광고) 매물을 최상단에 노출하도록 쿼리 수정.
// 3. [Gap 5] 'incrementViewCount': 상세 페이지 조회 시 조회수(KPI)를 1 증가시키는 함수 추가.
// 4. [Gap 3] '찜하기' 기능: 'isBookmarkedStream' (찜 상태 스트림), 'toggleBookmark' (찜 토글) 함수 추가.
// 5. (Task 22) 'fetchRooms': 'RoomFilters' 객체를 파라미터로 받아 가격(서버), 면적/방 개수(클라이언트) 등 상세 필터링 로직 추가.
// 6. (Task 24) [버그 수정] 순환 참조 해결을 위해 'room_filters_model.dart'를 import 하도록 수정.
// 7. [수정] (Task 9) 'fetchRooms', 'getRoomsStream': 성능 최적화를 위해 대부분의 필터를 서버 사이드(Query 'where')로 이동.
// 8. [수정] (Task 12) 'fetchRooms', 'getRoomsStream': 'isSponsored' 우선 정렬 및 Firestore 'price' 범위 필터 제약 동시 충족을 위해 "Two-Query" 접근 방식 적용.
// =====================================================
// - 부동산 매물 CRUD 및 '찜하기', '조회수' 관리.
// - V2.0: 'rumah123' 벤치마킹 및 Firestore 제약사항 해결.
// - '광고 우선 정렬'과 '가격 범위 필터'를 동시에 지원하기 위해 "Two-Query" 로직 도입.
// - `firestore.indexes.json` 파일과 쿼리를 일치시켜 복합 인덱스 문제 해결.
//
// [V2.0 작업 이력 (2025-11-05)]
// 1. (Task 7) 'amenities' 필터링 로직을 `_filterByFacilities` 헬퍼로 분리하고,
//    'roomType'별 신규 시설 필드(예: kosRoomFacilities)를 비교하도록 수정.
// 2. (Task 9, 11) Firestore의 '범위/정렬' 제약(orderBy 'price' first) 발견.
// 3. (Task 12) 'fetchRooms'/'getRoomsStream'을 "Two-Query" 방식으로 전면 수정.
//    - `_buildFilteredQuery`: `isSponsoredQuery` 파라미터를 받아 쿼리 분리. `orderBy('price')`를 우선 정렬.
//    - `StreamZip`을 사용해 (광고 스트림 + 일반 스트림)을 클라이언트에서 병합.
// 4. (Task 12-fix) `_buildFilteredQuery`: `where('isAvailable', isEqualTo: true)`를 추가하여
//    `firestore.indexes.json`의 복합 인덱스와 쿼리를 일치시킴.
// 5. (Task 12-fix) `_applyClientFilters`: 인덱스 조합 폭발을 막기 위해 `bathroomCount`,
//    `furnishedStatus` 등 일부 공통 필터를 클라이언트 필터로 재이동. (성능/유연성 트레이드오프)
// =====================================================

// lib/features/real_estate/data/room_repository.dart

import 'dart:async'; // [신규] '작업 12': Stream 관련
import 'package:async/async.dart'; // [신규] '작업 12': StreamZip 사용
import 'package:bling_app/features/real_estate/models/room_listing_model.dart';
import 'package:bling_app/features/real_estate/models/room_filters_model.dart'; // [수정] 순환 참조 해결
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class RoomRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _roomsCollection =>
      _firestore.collection('room_listings');
  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  /// [신규] '작업 9': 서버 사이드 필터링 쿼리를 구축하는 헬퍼 함수
  Query<Map<String, dynamic>> _buildFilteredQuery(
      Map<String, String?>? locationFilter, RoomFilters? filters,
      {required bool isSponsoredQuery}) {
    // [신규] '작업 12': firestore.indexes.json과 일치시키기 위해 'isAvailable' 필터 추가
    // 이는 사용 가능한 매물만 보여주기 위한 필수 비즈니스 로직임.
    Query<Map<String, dynamic>> query =
        _roomsCollection.where('isAvailable', isEqualTo: true);

    // Always separate sponsored vs. normal queries to avoid returning
    // duplicate results when `filters` is null. This ensures `queryA`
    // and `queryB` differ by `isSponsored` regardless of filters.
    query = query.where('isSponsored', isEqualTo: isSponsoredQuery);

    // 1) Location (Server)
    final String? kab = locationFilter?['kab'];
    if (kab != null) {
      query = query.where('locationParts.kab', isEqualTo: kab);
    }

    if (filters != null) {
      // 2) Equality filters (Server)
      if (filters.listingType != null) {
        query = query.where('listingType', isEqualTo: filters.listingType);
      }
      if (filters.roomType != null) {
        query = query.where('type', isEqualTo: filters.roomType);
      }
      if (filters.roomCount != null) {
        query = query.where('roomCount', isEqualTo: filters.roomCount);
      }
      if (filters.bathroomCount != null) {
        query = query.where('bathroomCount', isEqualTo: filters.bathroomCount);
      }
      if (filters.furnishedStatus != null) {
        query =
            query.where('furnishedStatus', isEqualTo: filters.furnishedStatus);
      }
      if (filters.propertyCondition != null) {
        query = query.where('propertyCondition',
            isEqualTo: filters.propertyCondition);
      }

      // Kos specific
      if (filters.roomType == 'kos') {
        if (filters.kosBathroomType != null) {
          query = query.where('kosBathroomType',
              isEqualTo: filters.kosBathroomType);
        }
        if (filters.isElectricityIncluded != null) {
          query = query.where('isElectricityIncluded',
              isEqualTo: filters.isElectricityIncluded);
        }
      }

      // 3) Price range (Server) – Firestore limitation: single range field
      if (filters.minPrice > 0) {
        query = query.where('price', isGreaterThanOrEqualTo: filters.minPrice);
      }
      if (filters.maxPrice < 50000000) {
        query = query.where('price', isLessThanOrEqualTo: filters.maxPrice);
      }
    }

    // 4) Sorting (Server)
    // [수정] 지도 보기(filters == null)일 때는 'price' 정렬을 건너뛰고 'createdAt'만 사용하여
    // 복합 인덱스 문제 없이 데이터를 확실하게 가져오도록 함.
    if (filters != null) {
      // 리스트 뷰: 가격 필터/정렬이 중요하므로 price 우선
      query = query.orderBy('price').orderBy('createdAt', descending: true);
    } else {
      // 지도 뷰: 전체 매물을 최신순으로 조회 (인덱스 의존성 최소화)
      query = query.orderBy('createdAt', descending: true);
    }

    return query;
  }

  // V V V --- [수정] locationFilter를 적용한 최종 fetchRooms 함수 --- V V V
  // [수정] isSponsored (광고) 매물을 우선 정렬합니다.
  // [수정] '직방' 스타일 상세 필터(RoomFilters) 적용
  Stream<List<RoomListingModel>> fetchRooms(
      {Map<String, String?>? locationFilter, RoomFilters? filters}) {
    // [작업 12] 광고/일반 분리 쿼리 구성
    final queryA =
        _buildFilteredQuery(locationFilter, filters, isSponsoredQuery: true);
    final queryB =
        _buildFilteredQuery(locationFilter, filters, isSponsoredQuery: false);

    final streamA = queryA.snapshots().map(_mapSnapshots); // 광고 매물 목록 스트림
    final streamB = queryB.snapshots().map(_mapSnapshots); // 일반 매물 목록 스트림

    // 두 스트림을 zip 결합 후 클라이언트 필터 적용 및 병합
    return StreamZip([streamA, streamB]).map((pair) {
      final sponsored = pair[0];
      final normal = pair[1];
      final filteredA = _applyClientFilters(sponsored, filters);
      final filteredB = _applyClientFilters(normal, filters);
      return [...filteredA, ...filteredB];
    });
  }

  /// [신규] '작업 12': 쿼리 스냅샷을 모델 리스트로 매핑
  List<RoomListingModel> _mapSnapshots(
      QuerySnapshot<Map<String, dynamic>> snapshot) {
    return snapshot.docs
        .map((doc) => RoomListingModel.fromFirestore(doc))
        .toList();
  }

  /// [신규] '작업 12': 클라이언트 사이드 범위/시설 필터 적용
  List<RoomListingModel> _applyClientFilters(
      List<RoomListingModel> rooms, RoomFilters? filters) {
    if (filters == null) return rooms;
    return rooms.where((room) {
      final areaMatch =
          (filters.minArea <= 0 || room.area >= filters.minArea) &&
              (filters.maxArea >= 100 || room.area <= filters.maxArea);

      final landAreaMatch = (filters.minLandArea <= 0 ||
              (room.landArea ?? 0) >= filters.minLandArea) &&
          (filters.maxLandArea >= 1000 ||
              (room.landArea ?? 0) <= filters.maxLandArea);

      final depositMatch = (filters.depositMin <= 0 ||
              (room.deposit ?? 0) >= filters.depositMin) &&
          (filters.depositMax >= 50000000 ||
              (room.deposit ?? 0) <= filters.depositMax);

      final facilitiesMatch = _filterByFacilities(room, filters);

      return areaMatch && landAreaMatch && depositMatch && facilitiesMatch;
    }).toList();
  }

  /// [신규] '작업 7': 'amenities' 제거 후 'roomType'별 상세 시설 필터링 로직
  bool _filterByFacilities(RoomListingModel room, RoomFilters filters) {
    switch (room.type) {
      case 'kos':
        final roomFacMatch = filters.kosRoomFacilities.isEmpty ||
            room.kosRoomFacilities
                .toSet()
                .containsAll(filters.kosRoomFacilities);
        final publicFacMatch = filters.kosPublicFacilities.isEmpty ||
            room.kosPublicFacilities
                .toSet()
                .containsAll(filters.kosPublicFacilities);
        return roomFacMatch && publicFacMatch;
      case 'apartment':
        return filters.apartmentFacilities.isEmpty ||
            room.apartmentFacilities
                .toSet()
                .containsAll(filters.apartmentFacilities);
      case 'house':
      case 'kontrakan':
        return filters.houseFacilities.isEmpty ||
            room.houseFacilities.toSet().containsAll(filters.houseFacilities);
      case 'ruko':
      case 'kantor':
      case 'gudang':
        return filters.commercialFacilities.isEmpty ||
            room.commercialFacilities
                .toSet()
                .containsAll(filters.commercialFacilities);
      default:
        // 'etc' 또는 알 수 없는 타입은 필터링하지 않음
        return true;
    }
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

  // [신규] '작업 12': 실시간 리스트 스트림 API (광고/일반 병합)
  Stream<List<RoomListingModel>> getRoomsStream(
      {Map<String, String?>? locationFilter, RoomFilters? filters}) {
    final queryA =
        _buildFilteredQuery(locationFilter, filters, isSponsoredQuery: true);
    final queryB =
        _buildFilteredQuery(locationFilter, filters, isSponsoredQuery: false);

    // Attach error handlers to streams so Firestore errors (e.g. missing
    // composite index) are logged to console for debugging while
    // investigating zero-marker map issues.
    final streamA = queryA.snapshots().map(_mapSnapshots).handleError((e, st) {
      // Use debugPrint to avoid large blocking prints on Flutter
      debugPrint('RoomRepository.getRoomsStream - sponsored stream error: $e');
      debugPrint('$st');
    });

    final streamB = queryB.snapshots().map(_mapSnapshots).handleError((e, st) {
      debugPrint('RoomRepository.getRoomsStream - normal stream error: $e');
      debugPrint('$st');
    });

    // Merge and apply client filters, also log any errors occurring during
    // the merge/processing stage.
    return StreamZip([streamA, streamB]).map((pair) {
      final sponsored = pair[0];
      final normal = pair[1];
      final filteredA = _applyClientFilters(sponsored, filters);
      final filteredB = _applyClientFilters(normal, filters);
      return [...filteredA, ...filteredB];
    }).handleError((e, st) {
      debugPrint('RoomRepository.getRoomsStream - merged stream error: $e');
      debugPrint('$st');
    });
  }

  Stream<RoomListingModel> getRoomStream(String roomId) {
    return _roomsCollection
        .doc(roomId)
        .snapshots()
        .map((snapshot) => RoomListingModel.fromFirestore(snapshot));
  }
}
