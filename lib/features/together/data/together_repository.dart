// lib/features/together/data/together_repository.dart

import 'dart:io';

import 'package:bling_app/features/together/models/together_post_model.dart';
import 'package:bling_app/features/together/models/together_ticket_model.dart'; // ✅ 추가
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class TogetherRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // '함께 해요' 게시글 컬렉션 참조
  CollectionReference<Map<String, dynamic>> get _postsCollection =>
      _firestore.collection('together_posts');

  // 유저별 '내 티켓(입장권)' 서브 컬렉션 참조
  CollectionReference<Map<String, dynamic>> _userTicketsCollection(
          String uid) =>
      _firestore.collection('users').doc(uid).collection('my_tickets');

  /// 1. [Create] 새로운 모임(전단지) 생성
  Future<void> createPost(TogetherPostModel post) async {
    // 문서 ID는 모델 생성 시 이미 할당되었다고 가정 (UUID 등 사용)
    await _postsCollection.doc(post.id).set(post.toJson());
  }

  /// 2. [Read] 유효한 모임 목록 불러오기 (실시간 스트림)
  /// 조건: 모임 시간이 현재보다 미래이고, 상태가 'open'인 것만 조회
  /// [추가] locationFilter를 지원해 LocationProvider 설정을 반영합니다.
  Stream<List<TogetherPostModel>> fetchActivePosts({
    Map<String, String?>? locationFilter,
  }) {
    final now = Timestamp.now();
    Query<Map<String, dynamic>> query = _postsCollection
        .where('meetTime', isGreaterThan: now) // 시간이 지나지 않은 모임
        .where('status', isEqualTo: 'open'); // 모집 중인 모임

    if (locationFilter != null) {
      if (locationFilter['kel'] != null && locationFilter['kel']!.isNotEmpty) {
        query =
            query.where('locationParts.kel', isEqualTo: locationFilter['kel']);
      } else if (locationFilter['kec'] != null &&
          locationFilter['kec']!.isNotEmpty) {
        query =
            query.where('locationParts.kec', isEqualTo: locationFilter['kec']);
      } else if (locationFilter['kab'] != null &&
          locationFilter['kab']!.isNotEmpty) {
        query =
            query.where('locationParts.kab', isEqualTo: locationFilter['kab']);
      } else if (locationFilter['prov'] != null &&
          locationFilter['prov']!.isNotEmpty) {
        query = query.where('locationParts.prov',
            isEqualTo: locationFilter['prov']);
      }
    }

    return query
        .orderBy('meetTime', descending: false) // 임박한 순서대로 정렬
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TogetherPostModel.fromFirestore(doc))
          .toList();
    });
  }

  /// 3. [Update/Transaction] 모임 참여하기 + 티켓 발급
  /// - 최대 인원 체크 및 중복 참여 방지
  /// - 성공 시 유저에게 'QR Ticket' 발급
  Future<void> joinPost(
      {required String postId, required String userId}) async {
    final postRef = _postsCollection.doc(postId);
    final ticketRef = _userTicketsCollection(userId).doc(postId);

    await _firestore.runTransaction((transaction) async {
      final postSnapshot = await transaction.get(postRef);

      if (!postSnapshot.exists) {
        throw Exception("Post does not exist"); // "존재하지 않는 모임입니다."
      }

      final post = TogetherPostModel.fromFirestore(postSnapshot);

      // A. 유효성 검사 (Validation)
      if (post.status != 'open') {
        throw Exception("This hangout is closed."); // "이미 마감된 모임입니다."
      }
      if (post.isExpired) {
        throw Exception("This hangout has expired."); // "시간이 지난 모임입니다."
      }
      if (post.participants.length >= post.maxParticipants) {
        throw Exception("This hangout is full."); // "정원이 초과되었습니다."
      }
      if (post.participants.contains(userId)) {
        throw Exception("You have already joined."); // "이미 참여한 모임입니다."
      }

      // B. 모임 데이터 업데이트 (참여자 추가)
      final newParticipants = List<String>.from(post.participants)..add(userId);

      // (옵션) 만약 정원이 꽉 찼다면 상태를 'closed'로 변경할 수도 있음
      // 여기서는 일단 참여자 명단만 업데이트
      transaction.update(postRef, {
        'participants': newParticipants,
      });

      // C. 유저에게 'Together Pass' (티켓) 발급
      // 내 티켓함에 저장하여, 오프라인 현장 인증 시 사용
      transaction.set(ticketRef, {
        'postId': post.id,
        'title': post.title,
        'description': post.description,
        'meetTime': post.meetTime,
        'location': post.location,
        'qrCodeString': post.qrCodeString, // ✅ 핵심: 입장권 코드 복사
        'hostId': post.hostId,
        'designTheme': post.designTheme, // 티켓 디자인용 테마
        'joinedAt': FieldValue.serverTimestamp(),
        'isUsed': false, // 사용(인증) 여부
      });
    });
  }

  /// 4. [Read] 내 티켓 목록 불러오기
  Stream<List<TogetherTicketModel>> fetchMyTickets(String userId) {
    // ✅ 타입 변경
    return _userTicketsCollection(userId)
        .orderBy('meetTime', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TogetherTicketModel.fromMap(doc.data())) // ✅ 모델 변환
          .toList();
    });
  }

  /// 5. [Update] 게시글 수정
  Future<void> updatePost(TogetherPostModel post) async {
    await _postsCollection.doc(post.id).update(post.toJson());
  }

  /// 6. [Delete] 게시글 삭제
  Future<void> deletePost(String postId) async {
    await _postsCollection.doc(postId).delete();
  }

  /// 이미지 업로드 함수
  Future<String> uploadImage(File imageFile) async {
    final fileName = '${const Uuid().v4()}.jpg';
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    final uid = user.uid;
    final ref = FirebaseStorage.instance
        .ref()
        .child('together_images')
        .child(uid)
        .child(fileName);

    final task = ref.putFile(imageFile);
    await task;
    return await ref.getDownloadURL();
  }

  /// 이미지 업로드를 시작하는 UploadTask를 반환합니다.
  /// UI에서 업로드 진행률/취소 등을 제어하려면 이 메서드를 사용하세요.
  UploadTask uploadImageAsTask(File imageFile) {
    final fileName = '${const Uuid().v4()}.jpg';
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    final uid = user.uid;
    final ref = FirebaseStorage.instance
        .ref()
        .child('together_images')
        .child(uid)
        .child(fileName);
    return ref.putFile(imageFile);
  }
}
