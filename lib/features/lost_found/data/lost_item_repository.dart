// lib/features/lost_found/data/lost_item_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/models/lost_item_model.dart';

/// Provides CRUD operations for lost & found items and removes expired posts.
class LostItemRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _itemsCollection =>
      _firestore.collection('lost_items');

  Future<String> createLostItem(LostItemModel item) async {
    final doc = await _itemsCollection.add(item.toJson());
    return doc.id;
  }

  Future<void> updateLostItem(LostItemModel item) async {
    await _itemsCollection.doc(item.id).update(item.toJson());
  }

  Future<void> deleteLostItem(String id) async {
    await _itemsCollection.doc(id).delete();
  }

  Future<LostItemModel> fetchLostItem(String id) async {
    final doc = await _itemsCollection.doc(id).get();
    return LostItemModel.fromFirestore(doc);
  }

  Stream<List<LostItemModel>> fetchLostItems() {
    return _itemsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(LostItemModel.fromFirestore).toList());
  }

  Future<void> removeExpiredItems() async {
    final expired = await _itemsCollection
        .where('expiresAt', isLessThan: Timestamp.now())
        .get();
    final batch = _firestore.batch();
    for (final doc in expired.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
