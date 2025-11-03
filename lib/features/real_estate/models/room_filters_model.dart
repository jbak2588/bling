// lib/features/real_estate/models/room_filters_model.dart
// [추가] NumberFormat을 위해
// ignore: unused_import
import 'package:intl/intl.dart';

/// [수정] '직방' 상세 필터를 관리하는 클래스 (Task 38)
class RoomFilters {
  String? listingType; // 'rent', 'sale'
  String? roomType; // 'kos', 'kontrakan', 'sewa'
  double minPrice;
  double maxPrice;
  double minArea;
  double maxArea;
  int? roomCount; // 1, 2, 3, 4 (4는 4+ 의미)

  // [추가] Task 38: 카테고리별 상세 필드
  String? furnishedStatus; // 'furnished', 'semi_furnished', 'unfurnished'
  String? rentPeriod; // 'daily', 'monthly', 'yearly'
  Set<String> amenities; // 'ac', 'wifi' 등

  // [추가] Task 40: 상업용 전용 필터
  double depositMin;
  double depositMax;
  String? floorInfoFilter; // 층수/층 정보 텍스트 포함 검색

  RoomFilters({
    this.listingType,
    this.roomType,
    this.minPrice = 0,
    this.maxPrice = 50000000, // 50 Juta (5천만)
    this.minArea = 0,
    this.maxArea = 100, // 100 m²
    this.roomCount,

    // [추가] Task 38
    this.furnishedStatus,
    this.rentPeriod,
    Set<String>? amenities,
    // [추가] Task 40 기본값
    this.depositMin = 0,
    this.depositMax = 50000000,
    this.floorInfoFilter,
  }) : amenities = amenities ?? <String>{}; // Set 초기화

  // 필터 초기화
  void clear() {
    listingType = null;
    roomType = null; // (참고: room_list_screen에서 이 값은 리셋하면 안됨)
    minPrice = 0;
    maxPrice = 50000000;
    minArea = 0;
    maxArea = 100;
    roomCount = null;

    // [추가] Task 38
    furnishedStatus = null;
    rentPeriod = null;
    amenities.clear();

    // [추가] Task 40
    depositMin = 0;
    depositMax = 50000000;
    floorInfoFilter = null;
  }

  // 복사본 생성
  RoomFilters copy() {
    return RoomFilters(
      listingType: listingType,
      roomType: roomType,
      minPrice: minPrice,
      maxPrice: maxPrice,
      minArea: minArea,
      maxArea: maxArea,
      roomCount: roomCount,

      // [추가] Task 38
      furnishedStatus: furnishedStatus,
      rentPeriod: rentPeriod,
      amenities: Set<String>.from(amenities),
      // [추가] Task 40
      depositMin: depositMin,
      depositMax: depositMax,
      floorInfoFilter: floorInfoFilter,
    );
  }
}
