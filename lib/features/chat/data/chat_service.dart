// lib/features/chat/data/chat_service.dart

import 'package:bling_app/core/models/chat_message_model.dart';
import 'package:bling_app/core/models/chat_room_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
    final userDoc = await _firestore.collection('users').doc(otherUid).get();
    return UserModel.fromFirestore(userDoc);
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

  Future<void> sendMessage(
      String chatId, String text, String otherUserId) async {
    final myUid = _auth.currentUser?.uid;
    if (myUid == null || text.trim().isEmpty) return;

    final messageData = ChatMessageModel(
      id: '',
      senderId: myUid,
      text: text.trim(),
      timestamp: Timestamp.now(),
      readBy: [myUid],
    );

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(messageData.toJson());

    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': text.trim(),
      'lastTimestamp': messageData.timestamp,
      'unreadCounts.$otherUserId': FieldValue.increment(1),
    });
  }

  Future<void> markMessagesAsRead(String chatId, String otherUserId) async {
    final myUid = _auth.currentUser?.uid;
    if (myUid == null) return;

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
