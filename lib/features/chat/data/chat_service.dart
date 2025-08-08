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

  // ⭐️ [수정] 구버전의 파라미터 방식을 그대로 사용하여 에러 원천 차단
  Future<String> createOrGetChatRoom(String otherUserId, String productId,
      String productTitle, String productImage) async {
    final myUid = _auth.currentUser?.uid;
    if (myUid == null) {
      throw Exception('User not logged in');
    }

    List<String> participants = [myUid, otherUserId];
    participants.sort();

    String chatId = '${productId}_${participants.join('_')}';
    final chatDocRef = _firestore.collection('chats').doc(chatId);
    final chatDoc = await chatDocRef.get();

    if (!chatDoc.exists) {
      await chatDocRef.set({
        'participants': participants,
        'productId': productId, // 이전 필드명 사용
        'productTitle': productTitle,
        'productImage': productImage,
        'lastMessage': '',
        'lastTimestamp': FieldValue.serverTimestamp(),
        'unreadCounts': {myUid: 0, otherUserId: 0},
      });
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

  Future<void> markMessagesAsRead(String chatId, String otherUserId) async {
    final myUid = _auth.currentUser?.uid;
    if (myUid == null || otherUserId.isEmpty) return;

    await _firestore
        .collection('chats')
        .doc(chatId)
        .update({'unreadCounts.$myUid': 0});

    final messagesQuery = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('senderId', isEqualTo: otherUserId);

    final unreadMessages = await messagesQuery.get();

    WriteBatch batch = _firestore.batch();
    for (var doc in unreadMessages.docs) {
      final message = ChatMessageModel.fromFirestore(doc);
      if (!message.readBy.contains(myUid)) {
        batch.update(doc.reference, {
          'readBy': FieldValue.arrayUnion([myUid])
        });
      }
    }
    await batch.commit();
  }
}
