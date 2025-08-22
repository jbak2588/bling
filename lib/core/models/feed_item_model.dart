// 파일 경로: lib/core/models/feed_item_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

// [수정] 통합 피드에서 사용할 모든 기능의 타입을 정의합니다.
enum FeedItemType {
  post,
  product,
  job,
  club,
  auction,
  lostAndFound,
  pom,
  realEstate,
  localStores,
  findFriends, // '친구찾기'도 나중에 피드에 표시될 수 있으므로 추가
  unknown
}

class FeedItemModel {
  final String id;
  final String userId;
  final FeedItemType type;
  final String title;
  final String? content;
  final String? imageUrl;
  final Timestamp createdAt;
  final DocumentSnapshot originalDoc;

  FeedItemModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    this.content,
    this.imageUrl,
    required this.createdAt,
    required this.originalDoc,
  });
}