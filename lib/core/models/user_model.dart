/// ============================================================================
/// Bling DocHeader
/// Module        : User & Trust
/// File          : lib/core/models/user_model.dart
/// Purpose       : Firestore 사용자 스키마를 정의하며 신뢰와 프로필 제한을 포함합니다.
/// User Impact   : 계정 데이터를 중앙에서 관리하여 모듈별 신뢰 기반 접근을 가능하게 합니다.
/// Feature Links : lib/features/auth/screens/signup_screen.dart; lib/features/find_friends/screens/find_friends_screen.dart; lib/features/marketplace/screens/product_registration_screen.dart
/// Data Model    : Firestore `users/{uid}` 컬렉션; 필드 `trustLevel`, `locationParts{kabupaten,kecamatan,kelurahan,rt,rw}`, `thanksReceived`, `reportCount`, `blockedUsers`, `profileCompleted`, `isDatingProfile`.
/// Location Scope: Kelurahan·Kecamatan을 저장하며 RT/RW는 선택 사항; 없으면 `locationName`을 사용합니다.
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
/// ============================================================================
library;
// 아래부터 실제 코드

import 'package:cloud_firestore/cloud_firestore.dart';

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

  // V V V --- [추가] 동호회 게시글 좋아요 목록 --- V V V
  final List<String>? bookmarkedClubPostIds;
  final List<String>? likedShortIds;
  // ^ ^ ^ --- 여기까지 추가 --- ^ ^ ^

  // --- Trust System Fields ---
  final int trustScore; // 신뢰 점수 (0-500, 기본 0)
  final String? phoneNumber; // 전화번호 (인증 시 높은 신뢰 점수 획득)
  final int feedThanksReceived;
  final int marketThanksReceived;
  final int thanksReceived;
  final int reportCount;

// ✅ [신규] 관리자 여부를 나타내는 isAdmin 필드를 추가합니다.
  final bool isAdmin;

  final bool isBanned; // 차단 여부 (true 시 계정 제한)
  final List<String>? blockedUsers; // 차단 유저 목록 (uid 리스트)
  final bool profileCompleted; // 기본 프로필 완성 여부
  final Timestamp createdAt; // 가입 시각 (Firestore Timestamp)
  final bool isDatingProfile; // 친구찾기 기능 활성화 여부 (ON/OFF)
  final int? age; // 실제 나이
  final String? ageRange; // 허용 나이대 범위
  final String? gender; // 성별
  final List<String>? findfriendProfileImages; // 친구찾기용 추가 이미지
  final bool isVisibleInList; // 내 프로필 노출 여부
  final List<String>? likesGiven; // 내가 좋아요 누른 유저 ID
  final List<String>? likesReceived; // 나를 좋아요한 유저 ID
  final List<Map<String, dynamic>>? friendRequests; // 친구 요청 상태
  final List<String>? friends; // 수락된 친구 ID
  final int likeCount; // 받은 좋아요 수
  final List<String>? rejectedUsers;
  final List<String>? clubs; // [추가] 가입한 동호회 목록

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
    this.bookmarkedClubPostIds, // [추가]
    // this.rt,
    // this.rw,
    this.likedShortIds, // [추가]
    this.trustScore = 0,
    this.phoneNumber,
    this.feedThanksReceived = 0,
    this.marketThanksReceived = 0,
    this.thanksReceived = 0,
    this.reportCount = 0,

    // ✅ 생성자에 isAdmin을 추가하고, 기본값은 false로 설정합니다.
    this.isAdmin = false,
    this.isBanned = false,
    this.blockedUsers,
    this.profileCompleted = false,
    required this.createdAt,
    required this.isDatingProfile,
    this.age,
    this.ageRange,
    this.gender,
    this.findfriendProfileImages,
    this.isVisibleInList = true,
    this.likesGiven,
    this.likesReceived,
    this.friendRequests,
    this.friends,
    this.likeCount = 0,
    this.rejectedUsers,
    this.clubs, // [추가]
  });

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
      bookmarkedClubPostIds: data['bookmarkedClubPostIds'] != null
          ? List<String>.from(data['bookmarkedClubPostIds'])
          : null, // [추가]
      likedShortIds: data['likedShortIds'] != null
          ? List<String>.from(data['likedShortIds'])
          : null, // [추가]
      trustScore: data['trustScore'] ?? 0,
      phoneNumber: data['phoneNumber'],
      feedThanksReceived: data['feedThanksReceived'] ?? 0,
      marketThanksReceived: data['marketThanksReceived'] ?? 0,
      thanksReceived: data['thanksReceived'] ?? 0,
      reportCount: data['reportCount'] ?? 0,

      // ✅ Firestore 문서에서 isAdmin 필드를 읽어옵니다.
      isAdmin: data['isAdmin'] ?? false,

      isBanned: data['isBanned'] ?? false,
      blockedUsers: data['blockedUsers'] != null
          ? List<String>.from(data['blockedUsers'])
          : null,
      profileCompleted: data['profileCompleted'] ?? false,
      age: data['age'],
      ageRange: data['ageRange'],
      gender: data['gender'],
      findfriendProfileImages: data['findfriend_profileImages'] != null
          ? List<String>.from(data['findfriend_profileImages'])
          : null,
      isVisibleInList: data['isVisibleInList'] ?? true,
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
      isDatingProfile: data['isDatingProfile'] ?? false,
      rejectedUsers: data['rejectedUsers'] != null
          ? List<String>.from(data['rejectedUsers'])
          : null,
      clubs: data['clubs'] != null
          ? List<String>.from(data['clubs'])
          : null, // [추가]
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
      'bookmarkedClubPostIds': bookmarkedClubPostIds, // [추가]
      // 'rt': rt,
      // 'rw': rw,
      'likedShortIds': likedShortIds, // [추가]
      'trustScore': trustScore,
      'phoneNumber': phoneNumber,
      'feedThanksReceived': feedThanksReceived,
      'marketThanksReceived': marketThanksReceived,
      'thanksReceived': thanksReceived,
      'reportCount': reportCount,

      // ✅ toJson 맵에 isAdmin 필드를 추가합니다.
      'isAdmin': isAdmin,

      'isBanned': isBanned,
      'blockedUsers': blockedUsers,
      'profileCompleted': profileCompleted,
      'createdAt': createdAt,
      'isDatingProfile': isDatingProfile,
      'age': age,
      'ageRange': ageRange,
      'gender': gender,
      'findfriend_profileImages': findfriendProfileImages,
      'isVisibleInList': isVisibleInList,
      'likesGiven': likesGiven,
      'likesReceived': likesReceived,
      'friendRequests': friendRequests,
      'friends': friends,
      'likeCount': likeCount,
      'rejectedUsers': rejectedUsers,
      'clubs': clubs, // [추가]
    };
  }
}
