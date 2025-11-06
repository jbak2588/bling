// ===================== DocHeader =====================
// [기획 요약]
// - V2.0: 'rumah123' 벤치마킹. 'room_listing_model.dart'와 1:1로 매칭되는 필터 모델.
// - 'roomType'별 상세 필터링(Kos, Apartment 등)을 지원하기 위한 모든 필드 포함.
//
// [V2.0 작업 이력 (2025-11-05)]
// 1. (Task 6) 'amenities' 필드 제거.
// 2. (Task 6, 13) 'Kos' 전용, 'Apartment' 전용 등 타입별 상세 필드 추가.
// 3. (Task 20) maxPrice, maxArea, depositMax의 기본값을 'Kos' 기준이 아닌
//    절대 최대 한도(예: 100억)로 대폭 상향 조정.
// =====================================================
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
  double minArea; // 건물 면적 (Luas Bangunan)
  double maxArea;
  int? roomCount; // 침실 수 (Kamar Tidur)
  int? bathroomCount; // 욕실 수 (Kamar Mandi)
  double minLandArea; // 토지 면적 (Luas Tanah)
  double maxLandArea;

  // [수정] Task 38: 주거용 공통 필드
  String? furnishedStatus; // 'furnished', 'semi_furnished', 'unfurnished'
  String? rentPeriod; // 'daily', 'monthly', 'yearly'
  String? propertyCondition; // 'new', 'used' (Baru, Bekas)

  // [수정] Task 40: 상업용 공통 필터
  double depositMin;
  double depositMax;
  String? floorInfoFilter; // 층수/층 정보 텍스트 포함 검색

  // [신규] 'Kos' (Sewa Kamar) 전용 필터
  String? kosBathroomType; // 'in_room', 'out_room' (Kamar mandi di dalam/luar)
  bool? isElectricityIncluded; // Termasuk Listrik
  int? maxOccupants; // Maks. Penghuni
  Set<String> kosRoomFacilities; // Fasilitas Kamar (ac, bed, closet)
  Set<String> kosPublicFacilities; // Fasilitas Umum (kitchen, living_room)

  // [신규] 'Apartment' 전용 필터
  Set<String> apartmentFacilities; // Fasilitas Apartemen (pool, gym, security)

  // [신규] 'Rumah' (주택) 전용 필터
  Set<String> houseFacilities; // Fasilitas Rumah (carport, garden, pam)

  // [신규] 'Ruko', 'Kantor', 'Gudang' (상업용) 전용 필터
  Set<String>
      commercialFacilities; // Fasilitas Komersial (parking, security, telephone)

  RoomFilters({
    this.listingType,
    this.roomType,
    this.minPrice = 0,
    this.maxPrice = 10000000000, // [수정] 10 Miliar (100억)
    this.minArea = 0,
    this.maxArea = 10000, // [수정] 10,000 m²
    this.roomCount,
    this.bathroomCount,
    this.minLandArea = 0,
    this.maxLandArea = 1000, // 1000 m²

    // [추가] Task 38
    this.furnishedStatus,
    this.rentPeriod,
    this.propertyCondition,
    this.kosBathroomType,
    this.isElectricityIncluded,
    this.maxOccupants,
    // [추가] Task 40 기본값
    this.depositMin = 0,
    this.depositMax = 1000000000, // [수정] 1 Miliar (10억)
    this.floorInfoFilter,

    // [신규] 타입별 Set 초기화
    Set<String>? kosRoomFacilities,
    Set<String>? kosPublicFacilities,
    Set<String>? apartmentFacilities,
    Set<String>? houseFacilities,
    Set<String>? commercialFacilities,
  })  : kosRoomFacilities = kosRoomFacilities ?? <String>{},
        kosPublicFacilities = kosPublicFacilities ?? <String>{},
        apartmentFacilities = apartmentFacilities ?? <String>{},
        houseFacilities = houseFacilities ?? <String>{},
        commercialFacilities = commercialFacilities ?? <String>{}; // Set 초기화

  // 필터 초기화
  void clear() {
    listingType = null;
    roomType = null; // (참고: room_list_screen에서 이 값은 리셋하면 안됨)
    minPrice = 0;
    maxPrice = 10000000000; // [수정]
    minArea = 0;
    maxArea = 10000; // [수정]
    roomCount = null;
    bathroomCount = null;
    minLandArea = 0;
    maxLandArea = 1000;

    // [추가] Task 38
    furnishedStatus = null;
    rentPeriod = null;
    propertyCondition = null;

    // [추가] Task 40
    depositMin = 0;
    depositMax = 1000000000; // [수정]
    floorInfoFilter = null;

    // [신규]
    kosBathroomType = null;
    isElectricityIncluded = null;
    maxOccupants = null;
    kosRoomFacilities.clear();
    kosPublicFacilities.clear();
    apartmentFacilities.clear();
    houseFacilities.clear();
    commercialFacilities.clear();
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
      bathroomCount: bathroomCount,
      minLandArea: minLandArea,
      maxLandArea: maxLandArea,

      // [추가] Task 38
      furnishedStatus: furnishedStatus,
      rentPeriod: rentPeriod,
      propertyCondition: propertyCondition,
      // [추가] Task 40
      depositMin: depositMin,
      depositMax: depositMax,
      floorInfoFilter: floorInfoFilter,

      // [신규]
      kosBathroomType: kosBathroomType,
      isElectricityIncluded: isElectricityIncluded,
      maxOccupants: maxOccupants,
      kosRoomFacilities: Set<String>.from(kosRoomFacilities),
      kosPublicFacilities: Set<String>.from(kosPublicFacilities),
      apartmentFacilities: Set<String>.from(apartmentFacilities),
      houseFacilities: Set<String>.from(houseFacilities),
      commercialFacilities: Set<String>.from(commercialFacilities),
    );
  }
}
