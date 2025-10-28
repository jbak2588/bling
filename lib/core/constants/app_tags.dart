// lib/core/constants/app_tags.dart

// 태그 정보 구조체 (대답:85 에서 정의)
class TagInfo {
  final String tagId; // 태그 고유 ID (예: 'power_outage') - Firestore 저장 값
  final String nameKey; // 다국어 이름 키 (예: 'tags.local_news.power_outage.name')
  final String descriptionKey; // 다국어 설명 키 (옵션, 태그 선택 UI용)
  final List<String> synonyms; // 동의어/약칭 목록 (자동 완성용)
  final List<String>? guidedFields; // 이 태그 선택 시 필요한 추가 필드 목록 (옵션)
  final String? emoji; // 태그 옆에 표시할 이모지 (옵션)
  final String? group; // 태그 그룹 (옵션, UI 분류용)

  const TagInfo({
    required this.tagId,
    required this.nameKey,
    required this.descriptionKey,
    this.synonyms = const [],
    this.guidedFields,
    this.emoji,
    this.group,
  });
}

// 앱 전체 또는 Local News에서 사용할 태그 사전
class AppTags {
  static final List<TagInfo> localNewsTags = [
    // --- 공공 · 행정 ---
    const TagInfo(
      tagId: 'kelurahan_notice', // 동/리 공지
      nameKey: 'tags.local_news.kelurahan_notice.name',
      descriptionKey: 'tags.local_news.kelurahan_notice.desc',
      synonyms: ['pengumuman kelurahan', 'info desa', 'RT RW notice', '동네 공지'],
      emoji: '📢',
      group: 'public',
    ),
    const TagInfo(
      tagId: 'kecamatan_notice', // 구/면 공지
      nameKey: 'tags.local_news.kecamatan_notice.name',
      descriptionKey: 'tags.local_news.kecamatan_notice.desc',
      synonyms: ['pengumuman kecamatan', 'info kecamatan', '구청 공지'],
      emoji: '🏛️',
      group: 'public',
    ),
    const TagInfo(
      tagId: 'public_campaign', // 공공 캠페인
      nameKey: 'tags.local_news.public_campaign.name',
      descriptionKey: 'tags.local_news.public_campaign.desc',
      synonyms: [
        'kampanye publik',
        'sosialisasi',
        'program pemerintah',
        '공공 캠페인'
      ],
      emoji: '🗣️',
      group: 'public',
    ),
    const TagInfo(
      tagId: 'siskamling', // 지역 방범 활동
      nameKey: 'tags.local_news.siskamling.name',
      descriptionKey: 'tags.local_news.siskamling.desc',
      synonyms: ['ronda malam', 'keamanan lingkungan', '자율방범'],
      emoji: '🛡️',
      group: 'public',
    ),

    // --- 생활 인프라 ---
    const TagInfo(
      tagId: 'power_outage', // 정전
      nameKey: 'tags.local_news.power_outage.name',
      descriptionKey: 'tags.local_news.power_outage.desc',
      synonyms: [
        'mati lampu',
        'listrik padam',
        'pemadaman listrik',
        'PLN',
        '정전'
      ],
      guidedFields: ['eventTime', 'eventLocation'], // 시간, 장소 추가 필드
      emoji: '💡',
      group: 'infra',
    ),
    const TagInfo(
      tagId: 'water_outage', // 단수
      nameKey: 'tags.local_news.water_outage.name',
      descriptionKey: 'tags.local_news.water_outage.desc',
      synonyms: ['air mati', 'pam mati', 'gangguan air', '단수'],
      guidedFields: ['eventTime', 'eventLocation'], // 시간, 장소 추가 필드
      emoji: '💧',
      group: 'infra',
    ),
    const TagInfo(
      tagId: 'waste_collection', // 쓰레기 수거
      nameKey: 'tags.local_news.waste_collection.name',
      descriptionKey: 'tags.local_news.waste_collection.desc',
      synonyms: ['sampah', 'pengangkutan sampah', 'jadwal sampah', '쓰레기 수거'],
      emoji: '🗑️',
      group: 'infra',
    ),
    const TagInfo(
      tagId: 'road_works', // 도로 공사
      nameKey: 'tags.local_news.road_works.name',
      descriptionKey: 'tags.local_news.road_works.desc',
      synonyms: ['perbaikan jalan', 'pembangunan jalan', 'galian', '도로 공사'],
      guidedFields: ['eventTime', 'eventLocation'],
      emoji: '🛠️',
      group: 'infra',
    ),
    const TagInfo(
      tagId: 'public_facility', // 공공 시설
      nameKey: 'tags.local_news.public_facility.name',
      descriptionKey: 'tags.local_news.public_facility.desc',
      synonyms: ['fasilitas umum', 'taman', 'lapangan', '공원', '놀이터', '공공시설'],
      emoji: '🌳',
      group: 'infra',
    ),

    // --- 재난 · 안전 ---
    const TagInfo(
      tagId: 'weather_warning', // 기상 특보
      nameKey: 'tags.local_news.weather_warning.name',
      descriptionKey: 'tags.local_news.weather_warning.desc',
      synonyms: [
        'cuaca buruk',
        'peringatan dini',
        'hujan deras',
        'angin kencang',
        '기상특보',
        '악천후'
      ],
      emoji: '⚠️',
      group: 'safety',
    ),
    const TagInfo(
      tagId: 'flood_alert', // 홍수 알림
      nameKey: 'tags.local_news.flood_alert.name',
      descriptionKey: 'tags.local_news.flood_alert.desc',
      synonyms: ['banjir', 'genangan air', 'siaga banjir', '홍수'],
      guidedFields: ['eventLocation'],
      emoji: '🌊',
      group: 'safety',
    ),
    const TagInfo(
      tagId: 'air_quality', // 대기 질
      nameKey: 'tags.local_news.air_quality.name',
      descriptionKey: 'tags.local_news.air_quality.desc',
      synonyms: ['polusi udara', 'kabut asap', 'AQI', 'PM2.5', '미세먼지', '대기오염'],
      emoji: '💨',
      group: 'safety',
    ),
    const TagInfo(
      tagId: 'disease_alert', // 질병 알림
      nameKey: 'tags.local_news.disease_alert.name',
      descriptionKey: 'tags.local_news.disease_alert.desc',
      synonyms: ['wabah', 'penyakit menular', 'DBD', 'COVID', '질병', '전염병'],
      emoji: '🦠',
      group: 'safety',
    ),
    // (기존) 사건/사고
    const TagInfo(
      tagId: 'incident_report',
      nameKey: 'categories.post.incident_report.name', // 기존 키 재사용 가능
      descriptionKey: 'categories.post.incident_report.description',
      synonyms: ['kecelakaan', 'kebakaran', 'kriminalitas', '사건사고', '화재', '범죄'],
      emoji: '🚨',
      group: 'safety',
    ),

    // --- 교육 · 보건 ---
    const TagInfo(
      tagId: 'school_notice', // 학교 공지
      nameKey: 'tags.local_news.school_notice.name',
      descriptionKey: 'tags.local_news.school_notice.desc',
      synonyms: [
        'info sekolah',
        'pengumuman sekolah',
        'PPDB',
        'ujian',
        '학교 공지',
        '입학'
      ],
      emoji: '🎒',
      group: 'edu_health',
    ),
    const TagInfo(
      tagId: 'posyandu', // 포샨두 (지역 보건소)
      nameKey: 'tags.local_news.posyandu.name',
      descriptionKey: 'tags.local_news.posyandu.desc',
      synonyms: [
        'imunisasi',
        'vaksin',
        'kesehatan anak',
        'ibu hamil',
        '예방접종',
        '영유아검진'
      ],
      emoji: '🩺',
      group: 'edu_health',
    ),
    const TagInfo(
      tagId: 'health_campaign', // 건강 캠페인
      nameKey: 'tags.local_news.health_campaign.name',
      descriptionKey: 'tags.local_news.health_campaign.desc',
      synonyms: [
        'kampanye kesehatan',
        'penyuluhan',
        'cek kesehatan gratis',
        '건강 캠페인'
      ],
      emoji: '❤️‍🩹', // or '🏥'
      group: 'edu_health',
    ),

    // --- 교통 · 운영 ---
    const TagInfo(
      tagId: 'traffic_control', // 교통 통제/정보 (기존 traffic_diversion 통합)
      nameKey: 'tags.local_news.traffic_control.name',
      descriptionKey: 'tags.local_news.traffic_control.desc',
      synonyms: [
        'macet',
        'pengalihan arus',
        'jalan ditutup',
        'rekayasa lalin',
        'one way',
        '교통 통제',
        '도로 폐쇄',
        '교통정보'
      ],
      guidedFields: ['eventTime', 'eventLocation'],
      emoji: '🚦', // or '🚧'
      group: 'traffic',
    ),
    const TagInfo(
      tagId: 'public_transport', // 대중교통 정보
      nameKey: 'tags.local_news.public_transport.name',
      descriptionKey: 'tags.local_news.public_transport.desc',
      synonyms: [
        'bus',
        'angkot',
        'KRL',
        'MRT',
        'LRT',
        'transportasi umum',
        '대중교통'
      ],
      emoji: '🚌',
      group: 'traffic',
    ),
    const TagInfo(
      tagId: 'parking_policy', // 주차 정보/정책
      nameKey: 'tags.local_news.parking_policy.name',
      descriptionKey: 'tags.local_news.parking_policy.desc',
      synonyms: ['parkir', 'kebijakan parkir', 'zona parkir', '주차'],
      emoji: '🅿️',
      group: 'traffic',
    ),

    // --- 행사 · 문화 ---
    const TagInfo(
      tagId: 'community_event', // 동네 행사 (기존 neighborhood_event 통합)
      nameKey: 'tags.local_news.community_event.name',
      descriptionKey: 'tags.local_news.community_event.desc',
      synonyms: [
        'acara warga',
        'festival',
        'lomba',
        'kegiatan RT RW',
        '동네 행사',
        '축제',
        '모임'
      ],
      guidedFields: ['eventTime', 'eventLocation'],
      emoji: '🎉', // or '🎪'
      group: 'event_culture',
    ),
    const TagInfo(
      tagId: 'worship_event', // 종교 행사
      nameKey: 'tags.local_news.worship_event.name',
      descriptionKey: 'tags.local_news.worship_event.desc',
      synonyms: [
        'masjid',
        'gereja',
        'vihara',
        'pura',
        'misa',
        'jumatan',
        'pengajian',
        'ibadah',
        '종교행사'
      ],
      guidedFields: ['eventTime', 'eventLocation'],
      emoji: '🕌', // or '⛪️', '🕍', '⛩️'
      group: 'event_culture',
    ),

    // --- 질문 · 도움 (기존 카테고리 활용) ---
    const TagInfo(
      tagId: 'question', // 질문있어요 (daily_question 대체)
      nameKey: 'categories.post.daily_question.name', // 기존 키 재사용
      descriptionKey: 'categories.post.daily_question.description',
      synonyms: ['tanya', 'mau tanya', 'info dong', '질문', '궁금해요'],
      emoji: '❓',
      group: 'qna_help',
    ),
    const TagInfo(
      tagId: 'help_share', // 도움/나눔 (기존 카테고리 유지)
      nameKey: 'categories.post.help_share.name', // 기존 키 재사용
      descriptionKey: 'categories.post.help_share.description',
      synonyms: [
        'minta tolong',
        'butuh bantuan',
        'berbagi',
        'sumbangan',
        '도움 요청',
        '나눔'
      ],
      emoji: '🤝',
      group: 'qna_help',
    ),

    // --- 가게 · 홍보 (기존 카테고리 유지) ---
    const TagInfo(
      tagId: 'store_promo',
      nameKey: 'categories.post.store_promo.name', // 기존 키 재사용
      descriptionKey: 'categories.post.store_promo.description',
      synonyms: ['promosi toko', 'diskon', 'event toko', '가게 홍보', '할인'],
      emoji: '🛍️', // emoji 변경 제안
      group: 'promo',
    ),

    // --- 기타 (기존 카테고리 유지) ---
    const TagInfo(
      tagId: 'etc',
      nameKey: 'categories.post.etc.name', // 기존 키 재사용
      descriptionKey: 'categories.post.etc.description',
      synonyms: ['lain-lain', 'obrolan bebas', '잡담', '기타'],
      emoji: '💬',
      group: 'misc',
    ),
  ];
}
