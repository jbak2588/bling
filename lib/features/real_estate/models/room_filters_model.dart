// lib/features/real_estate/models/room_filters_model.dart
// [추가] NumberFormat을 위해

/// [추가] '직방' 상세 필터를 관리하는 클래스
class RoomFilters {
  String? listingType; // 'rent', 'sale'
  String? roomType; // 'kos', 'kontrakan', 'sewa'
  double minPrice;
  double maxPrice;
  double minArea;
  double maxArea;
  int? roomCount; // 1, 2, 3, 4 (4는 4+ 의미)

  RoomFilters({
    this.listingType,
    this.roomType,
    this.minPrice = 0,
    this.maxPrice = 50000000, // 50 Juta (5천만)
    this.minArea = 0,
    this.maxArea = 100, // 100 m²
    this.roomCount,
  });

  // 필터 초기화
  void clear() {
    listingType = null;
    roomType = null;
    minPrice = 0;
    maxPrice = 50000000;
    minArea = 0;
    maxArea = 100;
    roomCount = null;
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
    );
  }
}
