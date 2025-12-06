/// ============================================================================
/// Bling DocHeader
/// Module        : User & Trust
/// File          : lib/core/models/user_model.dart
/// Purpose       : Firestore 사용자 스키마를 정의하며 신뢰와 프로필 제한을 포함합니다.
/// User Impact   : 계정 데이터를 중앙에서 관리하여 모듈별 신뢰 기반 접근을 가능하게 합니다.
/// Feature Links : lib/features/auth/screens/signup_screen.dart; lib/features/find_friends/screens/find_friends_screen.dart; lib/features/marketplace/screens/product_registration_screen.dart
/// Data Model    : Firestore `users/{uid}` 컬렉션; 필드 `trustLevel`, `locationParts`, `geoPoint`, `thanksReceived`, `reportCount`, `blockedUsers`, `profileCompleted`, `isDatingProfile`.
/// Location Scope:
///   - locationName: 전체 주소 문자열 (예: "Jl. Raya No.1, Kel. A, Kec. B...")
///   - locationParts: {
///       prov, kab, kec, kel: 행정구역 명칭 (정규화됨, Prefix/Suffix 제거)
///       street: 상세 주소 (도로명 등),
///       rt, rw: (선택) 통/반 정보
///     }
///   - geoPoint: 위도/경도 (거리 계산용)
/// Privacy Note : 피드(목록/카드) 화면에는 `locationParts['street']`이나 전체 `locationName`을 사용자 동의 없이 표시하지 마세요. 피드에 표시되는 행정구역은 약어(`kel.`, `kec.`, `kab.`, `prov.`)로 간략 표기하세요.
/// Trust Policy  : TrustLevel은 normal→verified→trusted로 상승하며 신고는 점수를 낮춥니다; 차단된 사용자는 채팅 불가.
/// Monetization  : 판매자 신뢰도에 따라 개인화 프로모션과 마켓 수수료가 적용됩니다.
/// KPIs          : 핵심성과지표(Key Performance Indicator, KPI) 이벤트 `signup_complete`, `profile_completed`, `trust_upgrade`.
/// Analytics     : 프로필 완성과 신뢰도 변화를 기록합니다.
/// I18N          : 해당 없음
/// Dependencies  : cloud_firestore
/// Security/Auth : Firestore 규칙이 소유자만 수정하도록 제한하며 인증 세션을 요구합니다.
/// Edge Cases    : 위치 필드 누락 또는 차단된 계정.
/// Changelog     : 2025-08-26 DocHeader 최초 삽입(자동)
/// Source Docs   : docs/index/03  User 필드 & TrustLever & 프로필정책.md; docs/team/TeamA_Auth_Trust_module_통합 작업문서.md
/// 2025-10-30 (작업 3, 7):
///   - '하이브리드 기획안' 3) 푸시 구독 스키마 구현을 위해 'push_prefs_model.dart' import.
///   - 'pushPrefs' (PushPrefsModel?) 필드 추가.
///   - fromFirestore/toJson 로직에 'pushPrefs' 맵 변환 로직 추가.
/// ============================================================================
/// /// 2025-10-31 (작업 3, 7):
///   - '하이브리드 기획안' 3) 푸시 구독 스키마 구현을 위해 'push_prefs_model.dart' import.
///   - 'pushPrefs' (PushPrefsModel?) 필드 추가.
///   - fromFirestore/toJson 로직에 'pushPrefs' 맵 변환 로직 추가.
/// ============================================================================
library;
// 아래부터 실제 코드

import 'package:cloud_firestore/cloud_firestore.dart';
// ✅ [푸시 스키마] 1. 별도 파일로 분리된 PushPrefsModel을 import 합니다.
import 'push_prefs_model.dart';

class UserModel {
  final String uid; // 유저 고유 ID (Firestore 문서 ID)
  final String nickname; // 유저 닉네임
  final String email; // 이메일 주소
  final String? photoUrl; // 대표 프로필 사진 URL
  final String? bio; // 자기소개
  final String trustLevel; // 사용자 신뢰등급 (unverified, verified 등)
  final String? locationName; // 간략 주소명 (예: "Tangerang, Banten")
  final Map<String, dynamic>? locationParts; // 주소 분리 (prov, kab, kec, kel)

//  final String? rt;
//   final String? rw;

  final GeoPoint? geoPoint; // 좌표 (지도 표시 및 거리 계산용)
  final List<String>? interests; // 관심사 리스트 (hobby 등)

  final Map<String, dynamic>? privacySettings; // 공개 범위 설정
  final List<String>? postIds; // 작성한 피드 ID 목록
  final List<String>? productIds; // 등록한 마켓 상품 ID 목록
  final List<String>? jobIds;
  final List<String>? bookmarkedPostIds; // 북마크한 피드 ID 목록
  final List<String>? bookmarkedProductIds; // 북마크한 마켓 상품 ID 목록

  // [Task 21] 누락된 북마크 필드 추가
  final List<String>? bookmarkedRoomIds; // [신규] 북마크한 부동산 ID 목록
  final List<String>? bookmarkedUserIds; // [신규] 관심 이웃(찜한 유저) ID 목록

  // V V V --- [추가] 동호회 게시글 좋아요 목록 --- V V V
  final List<String>? bookmarkedClubPostIds;
  final List<String>? likedPomIds;
  // ^ ^ ^ --- 여기까지 추가 --- ^ ^ ^

  // --- Trust System Fields ---
  final int trustScore; // 신뢰 점수 (0-500, 기본 0)
  final String? phoneNumber; // 전화번호 (인증 시 높은 신뢰 점수 획득)
  final int feedThanksReceived;
  final int marketThanksReceived;
  final int thanksReceived;
  final int reportCount;

  // ✅ [푸시 스키마] 2. 기획안 3) 푸시 알림 구독 설정 필드 추가
  final PushPrefsModel? pushPrefs;

  // [V3 NOTIFICATION] Task 79/82: 알림 수신을 위한 FCM 기기 토큰 목록
  final List<String>? fcmTokens;

  final bool isBanned; // 차단 여부 (true 시 계정 제한)
  final List<String>? blockedUsers; // 차단 유저 목록 (uid 리스트)
  final bool profileCompleted; // 기본 프로필 완성 여부
  // [v2.2] 약관 동의 필드 추가 (필수/선택)
  final bool? termsAgreed; // 이용약관 (필수)
  final bool? privacyAgreed; // 개인정보 처리방침 (필수)
  final bool? marketingAgreed; // 마케팅 수신 동의 (선택)
  final Timestamp createdAt; // 가입 시각 (Firestore Timestamp)

  // ✅ [작업 14] 계정 탈퇴 요청 플래그
  final bool isDeletionRequested;
  final Timestamp? deletionRequestedAt;

  // [친구찾기/데이팅]
  // [관리자/운영]
  final bool isAdmin; // [추가]
  // [추가] 검색용 역색인 (닉네임 + 관심사)
  final List<String> searchIndex;
  // [v2.1] 데이팅 관련 필드 삭제
  // final bool isDatingProfile; // 친구찾기 기능 활성화 여부 (ON/OFF)
  // final int? age; // 실제 나이
  // final String? ageRange; // 허용 나이대 범위
  // final String? gender; // 성별
  // final List<String>? findfriendProfileImages; // 친구찾기용 추가 이미지
  final bool? isVisibleInList; // 내 프로필 노출 여부
  final List<String>? likesGiven; // 내가 좋아요 누른 유저 ID
  final List<String>? likesReceived; // 나를 좋아요한 유저 ID
  final List<Map<String, dynamic>>? friendRequests; // 친구 요청 상태
  final List<String>? friends; // 수락된 친구 ID
  final int likeCount; // 받은 좋아요 수
  final List<String>? rejectedUsers;
  final List<String>? clubs; // [추가] 가입한 동호회 목록
  final bool? neighborhoodVerified; // 동네 인증 여부
  final Timestamp? lastActiveAt; // 최근 활동 타임스탬프

  UserModel({
    required this.uid,
    required this.nickname,
    required this.email,
    this.photoUrl,
    this.bio,
    this.trustLevel = 'normal',
    this.locationName,
    this.locationParts,
    this.geoPoint,
    this.interests,
    this.privacySettings,
    this.postIds,
    this.productIds,
    this.jobIds,
    this.bookmarkedPostIds,
    this.bookmarkedProductIds,
    this.bookmarkedRoomIds, // [Task 21]
    this.bookmarkedUserIds, // [Task 21]
    this.bookmarkedClubPostIds, // [추가]
    // this.rt,
    // this.rw,
    this.likedPomIds, // [추가]
    this.trustScore = 0,
    this.phoneNumber,
    this.feedThanksReceived = 0,
    this.marketThanksReceived = 0,
    this.thanksReceived = 0,
    this.reportCount = 0,
    this.pushPrefs, // ✅ [푸시 스키마] 3. 생성자에 추가
    this.fcmTokens, // [V3 NOTIFICATION]

    this.isAdmin = false,
    this.isBanned = false,
    this.blockedUsers,
    this.profileCompleted = false,
    this.termsAgreed,
    this.privacyAgreed,
    this.marketingAgreed,
    required this.createdAt,
    this.neighborhoodVerified,
    this.lastActiveAt,
    this.isVisibleInList = true,
    this.likesGiven,
    this.likesReceived,
    this.friendRequests,
    this.friends,
    this.likeCount = 0,
    this.rejectedUsers,
    this.clubs, // [추가]
    this.searchIndex = const [],
    // ✅ [작업 14] 생성자 추가
    this.isDeletionRequested = false,
    this.deletionRequestedAt,
  });

  // Compatibility: provide a common `title` getter for UI components.
  String get title => nickname;

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return UserModel(
      uid: data['uid'] ?? '',
      nickname: data['nickname'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'],
      bio: data['bio'],
      trustLevel: data['trustLevel'] ?? 'normal',
      locationName: data['locationName'],
      locationParts: data['locationParts'] != null
          ? Map<String, dynamic>.from(data['locationParts'])
          : null,
      // rt: data['rt'],
      // rw: data['rw'],

      geoPoint: data['geoPoint'],
      interests: data['interests'] != null
          ? List<String>.from(data['interests'])
          : null,
      privacySettings: data['privacySettings'] != null
          ? Map<String, dynamic>.from(data['privacySettings'])
          : null,
      postIds:
          data['postIds'] != null ? List<String>.from(data['postIds']) : null,
      productIds: data['productIds'] != null
          ? List<String>.from(data['productIds'])
          : null,
      jobIds: data['jobIds'] != null ? List<String>.from(data['jobIds']) : null,
      bookmarkedPostIds: data['bookmarkedPostIds'] != null
          ? List<String>.from(data['bookmarkedPostIds'])
          : null,
      bookmarkedProductIds: data['bookmarkedProductIds'] != null
          ? List<String>.from(data['bookmarkedProductIds'])
          : null,
      bookmarkedRoomIds: data['bookmarkedRoomIds'] != null
          ? List<String>.from(data['bookmarkedRoomIds'])
          : null, // [Task 21]
      bookmarkedUserIds: data['bookmarkedUserIds'] != null
          ? List<String>.from(data['bookmarkedUserIds'])
          : null, // [Task 21]
      bookmarkedClubPostIds: data['bookmarkedClubPostIds'] != null
          ? List<String>.from(data['bookmarkedClubPostIds'])
          : null, // [추가]
      likedPomIds: data['likedPomIds'] != null
          ? List<String>.from(data['likedPomIds'])
          : null, // [추가]
      trustScore: data['trustScore'] ?? 0,
      phoneNumber: data['phoneNumber'],
      feedThanksReceived: data['feedThanksReceived'] ?? 0,
      marketThanksReceived: data['marketThanksReceived'] ?? 0,
      thanksReceived: data['thanksReceived'] ?? 0,
      reportCount: data['reportCount'] ?? 0,

      // ✅ [푸시 스키마] 4. Firestore에서 'pushPrefs' 맵을 읽어 PushPrefsModel 객체로 변환
      pushPrefs: data['pushPrefs'] != null && data['pushPrefs'] is Map
          ? PushPrefsModel.fromMap(Map<String, dynamic>.from(data['pushPrefs']))
          : null,

      // [V3 NOTIFICATION]
      fcmTokens: data['fcmTokens'] != null
          ? List<String>.from(data['fcmTokens'])
          : null,

      // ✅ Firestore 문서에서 isAdmin 필드를 읽어옵니다.
      isAdmin: data['isAdmin'] ?? false,

      isBanned: data['isBanned'] ?? false,
      blockedUsers: data['blockedUsers'] != null
          ? List<String>.from(data['blockedUsers'])
          : null,
      profileCompleted: data['profileCompleted'] ?? false,
      termsAgreed: data['termsAgreed'],
      privacyAgreed: data['privacyAgreed'],
      marketingAgreed: data['marketingAgreed'],
      isVisibleInList: data['isVisibleInList'],
      likesGiven: data['likesGiven'] != null
          ? List<String>.from(data['likesGiven'])
          : null,
      likesReceived: data['likesReceived'] != null
          ? List<String>.from(data['likesReceived'])
          : null,
      friendRequests: data['friendRequests'] != null
          ? List<Map<String, dynamic>>.from(data['friendRequests'])
          : null,
      friends:
          data['friends'] != null ? List<String>.from(data['friends']) : null,
      likeCount: data['likeCount'] ?? 0,
      createdAt: data['createdAt'] ?? Timestamp.now(),
      neighborhoodVerified: data['neighborhoodVerified'] ?? false,
      lastActiveAt: data['lastActiveAt'],
      rejectedUsers: data['rejectedUsers'] != null
          ? List<String>.from(data['rejectedUsers'])
          : null,
      clubs: data['clubs'] != null
          ? List<String>.from(data['clubs'])
          : null, // [추가]
      searchIndex: data['searchIndex'] != null
          ? List<String>.from(data['searchIndex'])
          : [],
      // ✅ [작업 14] 필드 로드
      isDeletionRequested: data['isDeletionRequested'] ?? false,
      deletionRequestedAt: data['deletionRequestedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'nickname': nickname,
      'email': email,
      'photoUrl': photoUrl,
      'bio': bio,
      'trustLevel': trustLevel,
      'locationName': locationName,
      'locationParts': locationParts,
      'geoPoint': geoPoint,
      'interests': interests,
      'privacySettings': privacySettings,
      'postIds': postIds,
      'productIds': productIds,
      'jobIds': jobIds, // [추가]
      'bookmarkedPostIds': bookmarkedPostIds,
      'bookmarkedProductIds': bookmarkedProductIds,
      'bookmarkedRoomIds': bookmarkedRoomIds, // [Task 21]
      'bookmarkedUserIds': bookmarkedUserIds, // [Task 21]
      'bookmarkedClubPostIds': bookmarkedClubPostIds, // [추가]
      // 'rt': rt,
      // 'rw': rw,
      'likedPomIds': likedPomIds, // [추가]
      'trustScore': trustScore,
      'phoneNumber': phoneNumber,
      'feedThanksReceived': feedThanksReceived,
      'marketThanksReceived': marketThanksReceived,
      'thanksReceived': thanksReceived,
      'reportCount': reportCount,

      // ✅ [푸시 스키마] 5. PushPrefsModel 객체를 맵으로 변환하여 저장
      'pushPrefs': pushPrefs?.toMap(),

      // [V3 NOTIFICATION]
      'fcmTokens': fcmTokens,

      // ✅ toJson 맵에 isAdmin 필드를 추가합니다.
      'isAdmin': isAdmin,

      'isBanned': isBanned,
      'blockedUsers': blockedUsers,
      'profileCompleted': profileCompleted,
      'termsAgreed': termsAgreed,
      'privacyAgreed': privacyAgreed,
      'marketingAgreed': marketingAgreed,
      'createdAt': createdAt,
      'isDatingProfile': null, // [v2.1] null로 덮어쓰기
      'age': null, // [v2.1] null로 덮어쓰기
      'ageRange': null, // [v2.1] null로 덮어쓰기
      'gender': null, // [v2.1] null로 덮어쓰기
      'findfriend_profileImages': null, // [v2.1] null로 덮어쓰기
      'isVisibleInList': isVisibleInList,
      'likesGiven': likesGiven,
      'likesReceived': likesReceived,
      'friendRequests': friendRequests,
      'friends': friends,
      'likeCount': likeCount,
      'rejectedUsers': rejectedUsers,
      'neighborhoodVerified': neighborhoodVerified,
      'lastActiveAt': lastActiveAt,
      'clubs': clubs, // [추가]
      'searchIndex': searchIndex,
      // ✅ [작업 14] 필드 저장
      'isDeletionRequested': isDeletionRequested,
      'deletionRequestedAt': deletionRequestedAt,
    };
  }

  /// Compatibility getter for the newer UI API that expects a string label
  /// property named `trustLevelLabel`. This maps existing `trustLevel` to
  /// the label used by widgets without requiring a schema migration.
  String get trustLevelLabel => trustLevel;
}
