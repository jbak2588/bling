// [v2.1 리팩토링 이력: Job 6-25, 45]
// - (Job 6) 'isDatingProfile' 필터를 쿼리에서 제거.
// - (Job 6, 7, 8) 'friend_requests' 관련 로직(sendFriendRequest, getRequestStatus 등) 전체 삭제.
// - (Job 20, 22, 24, 25) 'getFindFriendListStream'에 클라이언트 측 정렬 로직 추가.
//   (정렬 순서: neighborhoodVerified -> trustLevel -> interests -> lastActiveAt)
// lib/features/find_friends/data/find_friend_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// [v2.1] '친구 요청' 모델 삭제 (컴파일 에러 1번 원인)
// import '../models/friend_request_model.dart';
import '../../../core/models/user_model.dart';

// import 'package:firebase_auth/firebase_auth.dart';

/// Firestore helper for FindFriend features.
class FindFriendRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updateUserProfile(
      String userId, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(userId).update(data);
  }

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  // [v2.1] '친구 요청' 컬렉션 참조 삭제
  // CollectionReference<Map<String, dynamic>> get _requests =>
  //     _firestore.collection('friend_requests');

  Future<void> saveProfile(String uid, Map<String, dynamic> data) async {
    await _users.doc(uid).set(data, SetOptions(merge: true));
  }

  Stream<List<UserModel>> getNearbyFriends(String kab) {
    return _users
        // [v2.1] isDatingProfile 필터 삭제
        .where('isVisibleInList', isEqualTo: true)
        .where('locationParts.kab', isEqualTo: kab)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    });
  }

  /// Fetches a stream of users based on location filters.
  ///
  /// [v2.1] Removed 'isDatingProfile' filter.
  /// TODO: Implement v2.1 sorting (trustLevel, interests)
  Stream<List<UserModel>> getFindFriendListStream({
    Map<String, String?>? locationFilter,
    // [v2.1] 클라이언트 측 정렬을 위해 현재 유저 정보 추가
    required UserModel currentUser,
    // [v2.1] isDatingProfile 파라미터 삭제
    // required bool isDatingProfile,
  }) {
    Query query = _users
        // [v2.2] 노출 조건: 리스트 노출 허용 및 프로필 완성된 사용자만
        .where('isVisibleInList', isEqualTo: true)
        .where('profileCompleted', isEqualTo: true);

    // Marketplace-style administrative filter: prefer the most-specific part provided.
    // Priority: kel -> kec -> kab -> prov
    if (locationFilter != null) {
      if (locationFilter['kel'] != null) {
        query =
            query.where('locationParts.kel', isEqualTo: locationFilter['kel']);
      } else if (locationFilter['kec'] != null) {
        query =
            query.where('locationParts.kec', isEqualTo: locationFilter['kec']);
      } else if (locationFilter['kab'] != null) {
        query =
            query.where('locationParts.kab', isEqualTo: locationFilter['kab']);
      } else if (locationFilter['prov'] != null) {
        query = query.where('locationParts.prov',
            isEqualTo: locationFilter['prov']);
      }
    }

    return query.snapshots().map((snapshot) {
      // [v2.1] 정렬 로직 (Job 20)
      // 1. Firestore에서 문서를 UserModel로 변환
      List<UserModel> users = snapshot.docs.map((doc) {
        return UserModel.fromFirestore(
            doc as QueryDocumentSnapshot<Map<String, dynamic>>);
      }).toList();

      // 2. 자기 자신은 리스트에서 제거
      users.removeWhere((user) => user.uid == currentUser.uid);

      // 3. 클라이언트(Dart) 측에서 정렬 수행
      // 안전한 비교를 위해 문자열 trustLevel을 숫자 순위로 매핑하고,
      // neighborhoodVerified는 bool->int로 변환해 비교합니다.
      int trustLevelRank(dynamic level) {
        // Accept String labels like 'unverified','normal','verified','trusted'
        // Also accept numeric values stored as num or numeric string.
        if (level == null) return 1; // default 'normal'
        if (level is int) return level;
        if (level is num) return level.toInt();
        if (level is String) {
          final l = level.toLowerCase();
          if (l == 'unverified') return 0;
          if (l == 'normal' || l == 'norm') return 1;
          if (l == 'verified') return 2;
          if (l == 'trusted' || l == 'trust') return 3;
          // try parse numeric string
          final n = int.tryParse(level);
          if (n != null) return n;
        }
        return 1;
      }

      users.sort((a, b) {
        // [v2.1] 1순위: 동네 인증 (neighborhoodVerified) (true가 먼저 오도록)
        // (내림차순: b.compareTo(a))
        int verifiedA = (a.neighborhoodVerified ?? false) ? 1 : 0;
        int verifiedB = (b.neighborhoodVerified ?? false) ? 1 : 0;
        int verifiedCompare = verifiedB.compareTo(verifiedA);
        if (verifiedCompare != 0) return verifiedCompare;

        // [v2.1] 2순위: 신뢰 등급 (trustLevel) 높은 순 (내림차순)
        // (내림차순: b.compareTo(a))
        int aTrustRank = trustLevelRank(a.trustLevel);
        int bTrustRank = trustLevelRank(b.trustLevel);
        int trustCompare = bTrustRank.compareTo(aTrustRank);
        if (trustCompare != 0) return trustCompare;

        // [v2.1] 3순위: 공통 관심사 (interests) 많은 순 (내림차순)
        final currentUserInterests = currentUser.interests?.toSet() ?? {};
        if (currentUserInterests.isNotEmpty) {
          final aInterests = a.interests?.toSet() ?? {};
          final bInterests = b.interests?.toSet() ?? {};

          int aCommon = aInterests.intersection(currentUserInterests).length;
          int bCommon = bInterests.intersection(currentUserInterests).length;

          int interestCompare = bCommon.compareTo(aCommon);
          if (interestCompare != 0) return interestCompare;
        }

        // [v2.1] 4순위 (동점일 경우): 최근 접속일 (lastActiveAt) 최신 순 (내림차순)
        // (내림차순: b.compareTo(a))
        return (b.lastActiveAt ?? Timestamp(0, 0))
            .compareTo(a.lastActiveAt ?? Timestamp(0, 0));
      });

      return users;
    });
  }

  // [v2.1] '친구 요청' 관련 메서드 전체 삭제 (sendFriendRequest, getRequestStatus, respondRequest, getReceivedRequests, getSentRequests)
  // (컴파일 에러 2번 원인 - 이 함수들이 삭제되지 않거나,
  // 이 함수들을 삭제하면서 클래스의 마지막 '}'가 함께 삭제되어 syntax error 발생)
} // [Task 16] 문법 오류 수정: 클래스 닫는 괄호 복구 및 확인 완료
