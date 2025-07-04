// lib/core/models/user_model.dart
// Bling App v0.4
// 새로운 구조의 작동 방식
// 초기 상태: 모든 사용자는 matchProfile 필드 없이 가입합니다.
// 기능 활성화: 사용자가 'Find Friend' 탭에서 데이팅 기능을 사용하기로 **동의(Opt-in)**하면, 앱은 성별, 연령대 등을 입력받아 matchProfile 맵을 생성하고, privacySettings에 { 'isDatingProfileActive': true } 와 같은 플래그를 저장합니다.
// 공개/비공개 제어: privacySettings의 플래그 값에 따라 데이팅 프로필의 노출 여부를 완벽하게 제어할 수 있습니다.
// 이처럼 UserModel을 수정하면, 보스께서 기획하신 유연한 프로필 공개/비공개 정책을 완벽하게 구현할 수 있습니다. 

// lib/core/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String nickname;
  final String email;
  final String? photoUrl;
  final String? bio;
  final String trustLevel;
  final String? locationName;
  final Map<String, dynamic>? locationParts;
  final GeoPoint? geoPoint;
  final List<String>? interests;
  final Map<String, dynamic>? privacySettings;
  final List<String>? postIds;
  final List<String>? productIds;
  final List<String>? bookmarkedPostIds;
  // ▼▼▼▼▼ 찜한 상품 ID 목록을 저장할 필드 추가 ▼▼▼▼▼
  final List<String>? bookmarkedProductIds;
  final int thanksReceived;
  final int reportCount;
  final bool isBanned;
  final List<String>? blockedUsers;
  final bool profileCompleted;
  final Timestamp createdAt;
  final Map<String, dynamic>? matchProfile;

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
    this.bookmarkedPostIds,
    this.bookmarkedProductIds, // 생성자에 추가
    this.thanksReceived = 0,
    this.reportCount = 0,
    this.isBanned = false,
    this.blockedUsers,
    this.profileCompleted = false,
    required this.createdAt,
    this.matchProfile,
  });

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
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
      bookmarkedPostIds: data['bookmarkedPostIds'] != null
          ? List<String>.from(data['bookmarkedPostIds'])
          : null,
      bookmarkedProductIds: data['bookmarkedProductIds'] != null
          ? List<String>.from(data['bookmarkedProductIds'])
          : null, // 데이터 변환 로직 추가
      thanksReceived: data['thanksReceived'] ?? 0,
      reportCount: data['reportCount'] ?? 0,
      isBanned: data['isBanned'] ?? false,
      blockedUsers: data['blockedUsers'] != null
          ? List<String>.from(data['blockedUsers'])
          : null,
      profileCompleted: data['profileCompleted'] ?? false,
      createdAt: data['createdAt'] ?? Timestamp.now(),
      matchProfile: data['matchProfile'] != null
          ? Map<String, dynamic>.from(data['matchProfile'])
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
      'bookmarkedPostIds': bookmarkedPostIds,
      'bookmarkedProductIds': bookmarkedProductIds, // 직렬화에 추가
      'thanksReceived': thanksReceived,
      'reportCount': reportCount,
      'isBanned': isBanned,
      'blockedUsers': blockedUsers,
      'profileCompleted': profileCompleted,
      'createdAt': createdAt,
      'matchProfile': matchProfile,
    };
  }
}
