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

  // [AI 인수] 1단계: 상품 예약 (10% 예약금 결제)
  // 백서 10.2: "구매자는 AI 검수 등록 상품에 10% 예약금 결제 후 거래 신청"
  Future<void> reserveProduct({
    required String productId,
    required String buyerId,
    // required int depositAmount, // TODO: 향후 결제 모듈(PG) 연동 시
  }) async {
    final productRef = _firestore.collection('products').doc(productId);

    try {
      await _firestore.runTransaction((transaction) async {
        final productDoc = await transaction.get(productRef);

        if (!productDoc.exists) {
          throw Exception('Product not found.');
        }

        final productData = productDoc.data();
        if (productData == null) {
          throw Exception('Product data is invalid.');
        }

        final currentStatus = productData['status'];
        if (currentStatus != 'selling') {
          throw Exception('This item is no longer available for reservation.');
        }

        // TODO: 10% 예약금 결제 (PG사 API 연동)
        // (결제 성공 시)

        transaction.update(productRef, {
          'status': 'reserved', // 상태를 '예약중'으로 변경
          'buyerId': buyerId, // 구매자 ID 기록
          'updatedAt': Timestamp.now(),
        });
      });
    } catch (e) {
      debugPrint('상품 예약 트랜잭션 에러: $e');
      rethrow;
    }
  }

  // [AI 인수 3단계-A] 최종 인수 확정 (구매자가 검증 성공 후 호출)
  Future<void> completeTakeover({
    required String productId,
  }) async {
    final productRef = _firestore.collection('products').doc(productId);

    try {
      // TODO: 에스크로된 90% 잔금 판매자에게 지급 (PG사 API)
      // (성공 시)

      await productRef.update({
        'status': 'sold', // 상태를 '판매완료'로 변경
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      debugPrint('최종 인수 확정 에러: $e');
      rethrow;
    }
  }

  // [AI 인수 3단계-B] 예약 취소 (구매자가 검증 실패 후 호출)
  Future<void> cancelReservation({
    required String productId,
  }) async {
    final productRef = _firestore.collection('products').doc(productId);

    try {
      // TODO: 10% 예약금 구매자에게 환불 (PG사 API)
      // (성공 시)

      await productRef.update({
        'status': 'selling', // 상태를 다시 '판매중'으로 변경
        'buyerId': FieldValue.delete(), // 구매자 ID 제거
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      debugPrint('예약 취소 에러: $e');
      rethrow;
    }
  }

  // [Fix] ID로 단일 상품 조회 (Admin/AI Detail 화면용)
  Future<ProductModel?> fetchProductById(String productId) async {
    try {
      final doc = await _firestore.collection('products').doc(productId).get();
      if (doc.exists) {
        return ProductModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching product by ID: $e');
      return null;
    }
  }
}
