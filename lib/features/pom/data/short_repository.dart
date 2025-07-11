// lib/features/pom/data/short_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/models/short_model.dart';
import '../../../core/models/short_comment_model.dart';

/// Firestore repository handling CRUD operations for shorts and their comments.
/// This powers the POM (Piece of Moment) short-video hub.
class ShortRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _shortsCollection =>
      _firestore.collection('shorts');

  Future<String> createShort(ShortModel short) async {
    final doc = await _shortsCollection.add(short.toJson());
    return doc.id;
  }

  Future<void> updateShort(ShortModel short) async {
    await _shortsCollection.doc(short.id).update(short.toJson());
  }

  Future<void> deleteShort(String shortId) async {
    await _shortsCollection.doc(shortId).delete();
  }

  Future<ShortModel> fetchShort(String shortId) async {
    final doc = await _shortsCollection.doc(shortId).get();
    return ShortModel.fromFirestore(doc);
  }

  Stream<List<ShortModel>> fetchShorts() {
    return _shortsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map(ShortModel.fromFirestore).toList());
  }

  Future<String> addComment(String shortId, ShortCommentModel comment) async {
    final doc = await _shortsCollection
        .doc(shortId)
        .collection('comments')
        .add(comment.toJson());
    return doc.id;
  }

  Future<void> updateComment(String shortId, ShortCommentModel comment) async {
    await _shortsCollection
        .doc(shortId)
        .collection('comments')
        .doc(comment.id)
        .update(comment.toJson());
  }

  Future<void> deleteComment(String shortId, String commentId) async {
    await _shortsCollection
        .doc(shortId)
        .collection('comments')
        .doc(commentId)
        .delete();
  }

  Stream<List<ShortCommentModel>> fetchComments(String shortId) {
    return _shortsCollection
        .doc(shortId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map(ShortCommentModel.fromFirestore).toList());
  }
}

