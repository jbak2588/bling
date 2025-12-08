// lib/features/find_friends/data/friend_post_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bling_app/features/find_friends/models/friend_post_model.dart';

class FriendPostRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 게시글 목록 가져오기 (최신순)
  // 실제 서비스 시에는 GeoFlutterFire 등을 이용해 주변 게시글만 쿼리해야 합니다.
  Stream<List<FriendPostModel>> getPostsStream(
      {Map<String, String?>? locationFilter}) {
    Query query = _firestore
        .collection('friend_posts')
        .orderBy('createdAt', descending: true);

    // 간단한 위치 필터링 (동 단위)
    if (locationFilter != null && locationFilter['kel'] != null) {
      query =
          query.where('locationParts.kel', isEqualTo: locationFilter['kel']);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => FriendPostModel.fromFirestore(doc))
          .toList();
    });
  }

  // 게시글 작성
  Future<void> createPost(FriendPostModel post) async {
    await _firestore.collection('friend_posts').add(post.toJson());
  }

  // (추후 구현) 게시글 삭제, 신고, 참여 요청 등
}
