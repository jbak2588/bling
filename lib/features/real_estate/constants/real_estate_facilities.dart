// ===================== DocHeader =====================
// [기획 요약]
// - V2.0: 'rumah123' 벤치마킹. 기존의 범용 'amenities'를 대체하기 위해
// - 'Kos'(방/공용), 'Apartment', 'House', 'Commercial'(상업용) 타입별로
// - 시설(Facility) 목록을 정의하는 상수 클래스.
//
// [V2.0 작업 이력 (2025-11-05)]
// 1. (Task 6) 신규 파일 생성.
// 2. (Task 16) 이 파일의 모든 키에 대한 다국어(id/en/ko) 작업 완료.
// =====================================================
// lib/features/real_estate/constants/real_estate_facilities.dart

class RealEstateFacilities {
  // 'Kos' (방 임대) 전용 시설
  static const List<String> kosRoomFacilities = [
    'ac',
    'bed',
    'closet',
    'desk',
    'wifi',
  ];

  static const List<String> kosPublicFacilities = [
    'kitchen',
    'living_room',
    'refrigerator',
    'parking_motorcycle',
    'parking_car',
  ];

  // 'Apartment' (아파트) 전용 시설
  static const List<String> apartmentFacilities = [
    'pool',
    'gym',
    'security_24h',
    'atm_center',
    'minimarket',
    'mall_access',
    'playground',
  ];

  // 'Rumah' (주택) 전용 시설
  static const List<String> houseFacilities = [
    'carport',
    'garden',
    'pam', // 시수도
    'telephone',
    'water_heater',
  ];

  // 'Ruko', 'Kantor', 'Gudang' (상업용) 공통 시설
  static const List<String> commercialFacilities = [
    'parking_area',
    'security_24h',
    'telephone',
    'electricity', // Daya Listrik (전력)
    'container_access', // (Gudang)
  ];
}
