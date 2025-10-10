// lib/features/marketplace/data/product_repository.dart

import 'dart:io';
import 'package:bling_app/features/marketplace/models/product_model.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // 여러 이미지를 Firebase Storage에 업로드하고 URL 리스트를 반환하는 함수
  Future<List<String>> uploadImages(
      {required String userId, required List<XFile> images}) async {
    final List<String> imageUrls = [];
    for (final image in images) {
      final fileName = const Uuid().v4();
      final reference =
          _storage.ref().child('product_images').child(userId).child(fileName);
      final uploadTask = await reference.putFile(File(image.path));
      final url = await uploadTask.ref.getDownloadURL();
      imageUrls.add(url);
    }
    return imageUrls;
  }

  // 상품 정보를 Firestore에 추가하는 함수
  Future<void> addProduct(ProductModel product) async {
    try {
      await _firestore.collection('products').add(product.toJson());
    } catch (e) {
      // 에러 처리
      debugPrint('Firestore 상품 추가 에러: $e');
      rethrow;
    }
  }

// ✅ [신규] 상품의 검증 상태를 업데이트하는 함수
  Future<void> updateProductStatus({
    required String productId,
    required String status,
    String? rejectionReason,
  }) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        'aiVerificationStatus': status,
        if (rejectionReason != null) 'rejectionReason': rejectionReason,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      debugPrint('상품 상태 업데이트 에러: $e');
      rethrow;
    }
  }
}
