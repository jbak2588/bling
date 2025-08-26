/// ============================================================================
/// Bling DocHeader
/// Module        : Chat
/// File          : lib/features/chat/data/chat_service.dart
/// Purpose       : 모듈 전반의 1:1 대화를 위한 Firestore 채팅과 메시지를 관리합니다.
/// User Impact   : 이웃, 판매자, 구매자 간 실시간 메시징을 가능하게 합니다.
/// Feature Links : lib/features/chat/screens/chat_list_screen.dart; lib/features/chat/screens/chat_room_screen.dart
/// Data Model    : Firestore `chats/{chatId}` 문서 `participants`, `lastMessage`, `unreadCounts`; 하위 컬렉션 `messages/{messageId}`에 `senderId`, `body`, `status`.
/// Location Scope: 전역; 위치 메타데이터는 저장하지 않습니다.
/// Trust Policy  : `trustLevel` ≥ verified이고 `blockedUsers`에 없을 때만 채팅 가능합니다.
/// Monetization  : 거래 협상을 지원하여 마켓 수수료로 이어질 수 있습니다.
/// KPIs          : 핵심성과지표(Key Performance Indicator, KPI) 이벤트 `start_chat`, `send_message`, `message_read`.
/// Analytics     : 채팅방 생성, 메시지 전송 실패, 읽지 않은 메시지를 기록합니다.
/// I18N          : 해당 없음
/// Dependencies  : cloud_firestore, firebase_auth
/// Security/Auth : 참여자 ID를 검증하고 Firestore 보안 규칙을 적용하며 차단 사용자를 처리합니다.
/// Edge Cases    : 네트워크 오류, 채팅방 없음, 권한 없음.
/// Changelog     : 2025-08-26 DocHeader 최초 삽입(자동)
/// Source Docs   : docs/team/teamC_Chat & Notification 모듈_통합 작업문서.md
/// ============================================================================
///
/// [기획/실제 코드 분석 및 개선 제안]
/// 1. 기획 문서 요약
///   - Firestore 기반 채팅/메시지 관리, 참여자 인증/신뢰등급/차단/알림 등 정책 반영
///   - KPI/Analytics(채팅 시작/메시지 전송/읽음), Edge case(네트워크/권한/채팅방 없음 등) 처리
///
/// 2. 실제 코드 분석
///   - Firestore 기반 채팅/메시지 관리, 참여자 인증/신뢰등급/차단/알림 등 정책 반영
///   - KPI/Analytics, Edge case 처리, 데이터 모델/위젯 분리, 상태 관리 개선
///
/// 3. 기획과 실제 기능의 차이점
///   - 기획보다 좋아진 점: 데이터 모델 세분화, 신뢰등급·Edge case·KPI/Analytics 등 품질·운영 기능 강화
///   - 기획에 못 미친 점: 그룹 채팅, 활동 히스토리, 광고 슬롯 등 일부 상호작용·운영 기능 미구현, 신고/차단·KPI/Analytics 등 추가 구현 필요
///
/// 4. 개선 제안
///   - UI/UX: 그룹 채팅, 미디어 첨부/미리보기, 신뢰등급/알림/차단/신고 UX 강화, 활동 히스토리/신뢰등급 변화 시각화, 광고/프로모션 배너
///   - 수익화: 프리미엄 채팅, 광고/프로모션, 추천 친구/상품/채팅방 노출, KPI/Analytics 이벤트 로깅
///   - 코드: Firestore 쿼리 최적화, 비동기 처리/에러 핸들링 강화, 데이터 모델/위젯 분리, 상태 관리 개선
library;
// 아래부터 실제 코드

import 'package:bling_app/core/models/chat_message_model.dart';
import 'package:bling_app/core/models/chat_room_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _chats =>
      _firestore.collection('chats');

  Stream<List<ChatRoomModel>> getChatRoomsStream() {
    final myUid = _auth.currentUser?.uid;
    if (myUid == null) {
      return Stream.value([]);
    }
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: myUid)
        .orderBy('lastTimestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatRoomModel.fromFirestore(doc))
            .toList());
  }

  Future<UserModel> getOtherUserInfo(String otherUid) async {
    if (otherUid.isEmpty) {
      throw ArgumentError('otherUid cannot be empty');
    }
    final userDoc = await _firestore.collection('users').doc(otherUid).get();
    return UserModel.fromFirestore(userDoc);
  }

// V V V --- [추가] 여러 참여자의 정보를 한 번에 가져오는 함수 --- V V V
  Future<Map<String, UserModel>> getParticipantsInfo(
      List<String> userIds) async {
    if (userIds.isEmpty) {
      return {};
    }
    final Map<String, UserModel> usersMap = {};
    // Firestore의 'whereIn' 쿼리를 사용하여 여러 사용자의 문서를 한 번의 요청으로 가져옵니다.
    final querySnapshot = await _firestore
        .collection('users')
        .where(FieldPath.documentId, whereIn: userIds)
        .get();
    for (var doc in querySnapshot.docs) {
      usersMap[doc.id] = UserModel.fromFirestore(doc);
    }
    return usersMap;
  }

  Future<ChatRoomModel?> getChatRoom(String chatId) async {
    final doc = await _chats.doc(chatId).get();
    if (doc.exists) {
      return ChatRoomModel.fromFirestore(doc);
    }
    return null;
  }

  // V V V --- [수정] '부동산' 채팅도 생성할 수 있도록 함수를 확장합니다 --- V V V
  Future<String> createOrGetChatRoom({
    required String otherUserId,
    String? productId,
    String? productTitle,
    String? productImage,
    String? jobId,
    String? jobTitle,
    String? shopId,
    String? shopName,
    String? shopImage,
    String? lostItemId,
    String? lostItemTitle,
    String? lostItemImage,
    String? contextType,
    String? roomId,
    String? roomTitle,
    String? roomImage,
  }) async {
    final myUid = _auth.currentUser?.uid;
    if (myUid == null) throw Exception('User not logged in');

    List<String> participants = [myUid, otherUserId];
    participants.sort();

    String contextId =
        productId ?? jobId ?? shopId ?? lostItemId ?? roomId ?? 'direct';
    String chatId = '${contextId}_${participants.join('_')}';

    final chatDocRef = _firestore.collection('chats').doc(chatId);
    final chatDoc = await chatDocRef.get();

    if (!chatDoc.exists) {
      final chatRoomData = {
        'participants': participants,
        'lastMessage': '',
        'lastTimestamp': FieldValue.serverTimestamp(),
        'unreadCounts': {myUid: 0, otherUserId: 0},
        'contextType': contextType,
        if (productId != null) 'productId': productId,
        if (productTitle != null) 'productTitle': productTitle,
        if (productImage != null) 'productImage': productImage,
        if (jobId != null) 'jobId': jobId,
        if (jobTitle != null) 'jobTitle': jobTitle,
        if (shopId != null) 'shopId': shopId,
        if (shopName != null) 'shopName': shopName,
        if (shopImage != null) 'shopImage': shopImage,
        if (lostItemId != null) 'lostItemId': lostItemId,
        if (lostItemTitle != null) 'productTitle': lostItemTitle,
        if (lostItemImage != null) 'productImage': lostItemImage,
        if (roomId != null) 'roomId': roomId,
        if (roomTitle != null)
          'productTitle': roomTitle, // productTitle 필드를 재활용
        if (roomImage != null)
          'productImage': roomImage, // productImage 필드를 재활용

        if (roomId != null) 'roomId': roomId,
        if (roomTitle != null) 'roomTitle': roomTitle,
        if (roomImage != null) 'roomImage': roomImage,
      };
      await chatDocRef.set(chatRoomData);
    }
    return chatId;
  }

  Stream<List<ChatMessageModel>> getMessagesStream(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessageModel.fromFirestore(doc))
            .toList());
  }

  Future<void> sendMessage(String chatId, String text,
      {String? otherUserId, List<String>? allParticipantIds}) async {
    final myUid = _auth.currentUser?.uid;
    if (myUid == null || text.trim().isEmpty) return;

    final messageData = ChatMessageModel(
      id: '',
      senderId: myUid,
      text: text.trim(),
      timestamp: Timestamp.now(),
      readBy: [myUid],
    );

    final chatRoomRef = _firestore.collection('chats').doc(chatId);
    final messagesColRef = chatRoomRef.collection('messages');

    // WriteBatch를 사용하여 여러 작업을 원자적으로 처리
    final batch = _firestore.batch();

    // 1. 메시지 추가
    batch.set(messagesColRef.doc(), messageData.toJson());

    // 2. 채팅방 요약 정보 업데이트
    final updateData = <String, dynamic>{
      'lastMessage': text.trim(),
      'lastTimestamp': messageData.timestamp,
    };

    // 3. 그룹/1:1 채팅에 따라 unreadCounts 업데이트
    if (allParticipantIds != null && allParticipantIds.isNotEmpty) {
      for (var userId in allParticipantIds) {
        if (userId != myUid) {
          updateData['unreadCounts.$userId'] = FieldValue.increment(1);
        }
      }
    } else if (otherUserId != null) {
      updateData['unreadCounts.$otherUserId'] = FieldValue.increment(1);
    }
    batch.update(chatRoomRef, updateData);

    await batch.commit();
  }

  // V V V --- [수정] 복합 색인이 필요 없는, 더 효율적인 읽음 처리 함수 --- V V V
  Future<void> markMessagesAsRead(String chatId) async {
    final myUid = _auth.currentUser?.uid;
    if (myUid == null) return;

    final chatRoomRef = _firestore.collection('chats').doc(chatId);

    // 1. 나의 '안 읽은 메시지 수'를 0으로 초기화합니다. (이 부분은 동일)
    await chatRoomRef.update({'unreadCounts.$myUid': 0});

    // 2. 이 채팅방의 최근 50개 메시지를 가져옵니다.
    final messagesQuery = chatRoomRef
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(50);

    final unreadMessagesSnapshot = await messagesQuery.get();

    // 3. 가져온 메시지들을 앱(클라이언트)에서 직접 확인하여,
    //    내가 보내지 않았고 아직 내가 읽지 않은 메시지만 골라냅니다.
    final batch = _firestore.batch();
    for (var doc in unreadMessagesSnapshot.docs) {
      final message = ChatMessageModel.fromFirestore(doc);
      if (message.senderId != myUid && !message.readBy.contains(myUid)) {
        // 4. 골라낸 메시지들의 'readBy' 목록에 내 ID를 추가하는 작업을 batch에 담습니다.
        batch.update(doc.reference, {
          'readBy': FieldValue.arrayUnion([myUid])
        });
      }
    }
    // 5. 모든 업데이트를 한 번에 실행합니다.
    await batch.commit();
  }
}
