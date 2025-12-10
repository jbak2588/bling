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

// lib/core/models/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'push_prefs_model.dart';

class UserModel {
  final String uid;
  final String nickname;
  final String email;
  final String? photoUrl; // 기본 아바타 (채팅/댓글용)
  final String? bio;
  final String trustLevel;
  final String? locationName;
  final Map<String, dynamic>? locationParts;
  final GeoPoint? geoPoint;
  final List<String>? interests;

  final Map<String, dynamic>? privacySettings;
  final List<String>? postIds;
  final List<String>? productIds;
  final List<String>? jobIds;
  final List<String>? bookmarkedPostIds;
  final List<String>? bookmarkedProductIds;
  final List<String>? bookmarkedRoomIds;
  final List<String>? bookmarkedUserIds;
  final List<String>? bookmarkedClubPostIds;
  final List<String>? likedPomIds;

  final int trustScore;

  // [PhoneAuth] 추후 실제 문자 인증 연동 시, 이 필드는 인증 서버의 결과로만 업데이트되어야 합니다.
  // 마켓플레이스 판매, 옥션 입찰/생성, 프리랜서 등록 시 이 필드가 null이 아닌지 확인해야 합니다.
  final String? phoneNumber;

  final int feedThanksReceived;
  final int marketThanksReceived;
  final int thanksReceived;
  final int reportCount;

  final PushPrefsModel? pushPrefs;
  final List<String>? fcmTokens;

  final bool isBanned;
  final List<String>? blockedUsers;
  final bool profileCompleted;
  final bool? termsAgreed;
  final bool? privacyAgreed;
  final bool? marketingAgreed;
  final Timestamp createdAt;

  final bool isDeletionRequested;
  final Timestamp? deletionRequestedAt;

  final bool isAdmin;
  final List<String> searchIndex;

  // [v2.2 개선] 친구 찾기 전용 프로필 이미지 리스트 (최대 10장)
  // 기본 photoUrl과 별도로, 매칭 화면에서 슬라이더로 보여질 고화질/다양한 사진들입니다.
  final List<String>? findfriendProfileImages;

  final bool? isVisibleInList;
  final List<String>? likesGiven;
  final List<String>? likesReceived;
  final List<Map<String, dynamic>>? friendRequests;
  final List<String>? friends;
  final int likeCount;
  final List<String>? rejectedUsers;
  final List<String>? clubs;
  final bool? neighborhoodVerified;
  final Timestamp? lastActiveAt;

  bool get isProfileReadyForMatching {
    if (isVisibleInList == false) return false;
    if (photoUrl == null || photoUrl!.isEmpty) return false;
    // [v2.2] 친구 찾기 이미지가 1장 이상 등록되어야 하는지 정책 결정 필요.
    // 현재는 기본 photoUrl만 있어도 통과시키되, findfriendProfileImages가 있으면 우선 노출 권장.
    if (bio == null || bio!.trim().length < 2) return false;
    if (interests == null || interests!.isEmpty) return false;
    return true;
  }

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
    this.bookmarkedRoomIds,
    this.bookmarkedUserIds,
    this.bookmarkedClubPostIds,
    this.likedPomIds,
    this.trustScore = 0,
    this.phoneNumber,
    this.feedThanksReceived = 0,
    this.marketThanksReceived = 0,
    this.thanksReceived = 0,
    this.reportCount = 0,
    this.pushPrefs,
    this.fcmTokens,
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
    this.clubs,
    this.searchIndex = const [],
    this.isDeletionRequested = false,
    this.deletionRequestedAt,
    this.findfriendProfileImages, // [v2.2] 생성자 추가
  });

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
          : null,
      bookmarkedUserIds: data['bookmarkedUserIds'] != null
          ? List<String>.from(data['bookmarkedUserIds'])
          : null,
      bookmarkedClubPostIds: data['bookmarkedClubPostIds'] != null
          ? List<String>.from(data['bookmarkedClubPostIds'])
          : null,
      likedPomIds: data['likedPomIds'] != null
          ? List<String>.from(data['likedPomIds'])
          : null,
      trustScore: data['trustScore'] ?? 0,
      phoneNumber: data['phoneNumber'],
      feedThanksReceived: data['feedThanksReceived'] ?? 0,
      marketThanksReceived: data['marketThanksReceived'] ?? 0,
      thanksReceived: data['thanksReceived'] ?? 0,
      reportCount: data['reportCount'] ?? 0,
      pushPrefs: data['pushPrefs'] != null && data['pushPrefs'] is Map
          ? PushPrefsModel.fromMap(Map<String, dynamic>.from(data['pushPrefs']))
          : null,
      fcmTokens: data['fcmTokens'] != null
          ? List<String>.from(data['fcmTokens'])
          : null,
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
      clubs: data['clubs'] != null ? List<String>.from(data['clubs']) : null,
      searchIndex: data['searchIndex'] != null
          ? List<String>.from(data['searchIndex'])
          : [],
      isDeletionRequested: data['isDeletionRequested'] ?? false,
      deletionRequestedAt: data['deletionRequestedAt'],

      // [v2.2] 필드 복원
      findfriendProfileImages: data['findfriendProfileImages'] != null
          ? List<String>.from(data['findfriendProfileImages'])
          : null,
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
      'jobIds': jobIds,
      'bookmarkedPostIds': bookmarkedPostIds,
      'bookmarkedProductIds': bookmarkedProductIds,
      'bookmarkedRoomIds': bookmarkedRoomIds,
      'bookmarkedUserIds': bookmarkedUserIds,
      'bookmarkedClubPostIds': bookmarkedClubPostIds,
      'likedPomIds': likedPomIds,
      'trustScore': trustScore,
      'phoneNumber': phoneNumber,
      'feedThanksReceived': feedThanksReceived,
      'marketThanksReceived': marketThanksReceived,
      'thanksReceived': thanksReceived,
      'reportCount': reportCount,
      'pushPrefs': pushPrefs?.toMap(),
      'fcmTokens': fcmTokens,
      'isAdmin': isAdmin,
      'isBanned': isBanned,
      'blockedUsers': blockedUsers,
      'profileCompleted': profileCompleted,
      'termsAgreed': termsAgreed,
      'privacyAgreed': privacyAgreed,
      'marketingAgreed': marketingAgreed,
      'createdAt': createdAt,
      'isVisibleInList': isVisibleInList,
      'likesGiven': likesGiven,
      'likesReceived': likesReceived,
      'friendRequests': friendRequests,
      'friends': friends,
      'likeCount': likeCount,
      'rejectedUsers': rejectedUsers,
      'neighborhoodVerified': neighborhoodVerified,
      'lastActiveAt': lastActiveAt,
      'clubs': clubs,
      'searchIndex': searchIndex,
      'isDeletionRequested': isDeletionRequested,
      'deletionRequestedAt': deletionRequestedAt,

      // [v2.2] 필드 저장
      'findfriendProfileImages': findfriendProfileImages,

      // Deprecated Fields (Cleaning)
      'isDatingProfile': null,
      'age': null,
      'ageRange': null,
      'gender': null,
      'findfriend_profileImages':
          null, // Use findfriendProfileImages instead if legacy exists
    };
  }

  String get trustLevelLabel => trustLevel;
}
