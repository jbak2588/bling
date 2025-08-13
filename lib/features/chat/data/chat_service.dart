// lib/features/chat/data/chat_service.dart

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

  

  // V V V --- [수정] '구인구직' 채팅도 생성할 수 있도록 함수를 확장합니다 --- V V V
  Future<String> createOrGetChatRoom({
    required String otherUserId,
    String? productId,
    String? productTitle,
    String? productImage,
    String? jobId,
    String? jobTitle,
  }) async {
    final myUid = _auth.currentUser?.uid;
    if (myUid == null) throw Exception('User not logged in');

    List<String> participants = [myUid, otherUserId];
    participants.sort();
    
    // [수정] 채팅방 ID 생성 규칙: 상품 ID 또는 구인글 ID를 기반으로 생성
    String contextId = productId ?? jobId ?? 'direct';
    String chatId = '${contextId}_${participants.join('_')}';

    final chatDocRef = _firestore.collection('chats').doc(chatId);
    final chatDoc = await chatDocRef.get();

    if (!chatDoc.exists) {
      // [수정] 채팅방 생성 시, 넘어온 정보를 기반으로 데이터를 구성
      final chatRoomData = {
        'participants': participants,
        'lastMessage': '',
        'lastTimestamp': FieldValue.serverTimestamp(),
        'unreadCounts': {myUid: 0, otherUserId: 0},
        if (productId != null) 'productId': productId,
        if (productTitle != null) 'productTitle': productTitle,
        if (productImage != null) 'productImage': productImage,
        if (jobId != null) 'jobId': jobId,
        if (jobTitle != null) 'jobTitle': jobTitle, // productTitle 필드를 공유해서 사용
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

Future<void> sendMessage(String chatId, String text, {String? otherUserId, List<String>? allParticipantIds}) async {
    final myUid = _auth.currentUser?.uid;
    if (myUid == null || text.trim().isEmpty) return;

    final messageData = ChatMessageModel(
      id: '', senderId: myUid, text: text.trim(),
      timestamp: Timestamp.now(), readBy: [myUid],
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
