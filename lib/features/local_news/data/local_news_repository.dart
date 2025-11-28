import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:bling_app/features/local_news/models/post_model.dart';

class LocalNewsRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  LocalNewsRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  /// 1) 이미지 업로드: post_images/{userId}/{uuid}.jpg 경로에 저장하고 URL 리스트 반환
  Future<List<String>> uploadImages(List<File> images, String userId) async {
    final List<String> urls = [];
    final storageRef = _storage.ref();

    for (final image in images) {
      try {
        final fileId = const Uuid().v4();
        final ref = storageRef.child('post_images/$userId/$fileId.jpg');
        final uploadTask = await ref.putFile(image);
        final downloadUrl = await uploadTask.ref.getDownloadURL();
        urls.add(downloadUrl);
      } catch (e) {
        // 업로드 실패한 이미지는 건너뜁니다.
        // 필요시 에러 로깅 추가 가능
      }
    }
    return urls;
  }

  /// 2) 게시글 생성 (toJson 사용). 생성된 문서 ID를 반환합니다.
  Future<String> createPost(PostModel post) async {
    final docRef = await _firestore.collection('posts').add(post.toJson());
    return docRef.id;
  }

  /// 3) 게시글 수정. updatedAt은 서버 타임스탬프로 덮어씁니다.
  Future<void> updatePost(String postId, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.collection('posts').doc(postId).update(data);
  }

  /// 4) 게시글 삭제 (Firestore 문서 삭제).
  Future<void> deletePost(String postId) async {
    final docRef = _firestore.collection('posts').doc(postId);
    final snap = await docRef.get();
    if (snap.exists) {
      final data = snap.data();
      if (data != null) {
        // mediaUrl may be stored as List or single String
        final media = data['mediaUrl'];
        if (media is List) {
          for (final item in media) {
            if (item is String && item.isNotEmpty) {
              try {
                final ref = _storage.refFromURL(item);
                await ref.delete();
              } catch (e) {
                // ignore individual delete errors (could log)
              }
            }
          }
        } else if (media is String && media.isNotEmpty) {
          try {
            final ref = _storage.refFromURL(media);
            await ref.delete();
          } catch (e) {
            // ignore
          }
        }
      }

      // Finally remove the Firestore document
      await docRef.delete();

      // 게시글 삭제 후 소유자 users.{uid}.postIds에서 ID 제거 시도
      try {
        final ownerId = data != null ? data['userId'] as String? : null;
        if (ownerId != null && ownerId.isNotEmpty) {
          await _firestore.collection('users').doc(ownerId).update({
            'postIds': FieldValue.arrayRemove([postId])
          });
        }
      } catch (e) {
        // ignore errors removing id from user doc
      }
    }
  }
}
