// lib/features/admin/screens/data_fix_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/models/user_model.dart';

class DataFixScreen extends StatefulWidget {
  const DataFixScreen({super.key});

  @override
  State<DataFixScreen> createState() => _DataFixScreenState();
}

class _DataFixScreenState extends State<DataFixScreen> {
  String _log = '데이터 보정 준비 완료.\n';
  bool _isProcessing = false;

  Future<void> _runFixScript() async {
    setState(() {
      _isProcessing = true;
      _log = '데이터 보정을 시작합니다...\n';
    });

    try {
      final firestore = FirebaseFirestore.instance;

      // ✅ [추가] 위치 정보가 없는 사용자를 위한 기본 Tangerang 위치 데이터
      final Map<String, dynamic> defaultLocationParts = {
        'prov': 'Banten',
        'kab': 'Tangerang',
        'kec': 'Tangerang',
        'kel': 'Sukasari',
      };
      const String defaultLocationName =
          'Kel. Sukasari, Kec. Tangerang, Kab. Tangerang';
      final defaultGeoPoint = GeoPoint(-6.1783, 106.6319);

      // --- 1. 모든 사용자 정보 가져오기 ---
      setState(() => _log += '1. 모든 사용자 정보를 가져옵니다...\n');
      final usersSnapshot = await firestore.collection('users').get();
      final userLocationMap = <String, UserModel>{};
      for (var doc in usersSnapshot.docs) {
        userLocationMap[doc.id] = UserModel.fromFirestore(doc);
      }
      setState(
          () => _log += '  - 총 ${userLocationMap.length}명의 사용자 정보를 확인했습니다.\n');

      // --- 2. 게시물(Posts) 데이터 보정 ---
      setState(() => _log += '\n2. 게시물(posts) 데이터 보정을 시작합니다...\n');
      final postsSnapshot = await firestore.collection('posts').get();
      WriteBatch postBatch = firestore.batch();
      int postsUpdatedCount = 0;

      for (var postDoc in postsSnapshot.docs) {
        final postData = postDoc.data();
        final userId = postData['userId'];
        final user = userLocationMap[userId];

        // ✅ [수정] 사용자 정보가 있고, 위치 정보가 유효한지 확인
        if (user != null &&
            user.locationParts != null &&
            user.locationParts!.isNotEmpty) {
          final postLocationKab = postData['locationParts']?['kab'];
          if (postLocationKab != user.locationParts?['kab']) {
            postBatch.update(postDoc.reference, {
              'locationName': user.locationName,
              'locationParts': user.locationParts,
              'geoPoint': user.geoPoint,
            });
            postsUpdatedCount++;
            setState(() => _log +=
                '  - [위치 수정] post/${postDoc.id} ($postLocationKab -> ${user.locationParts?['kab']})\n');
          }
        } else {
          // ✅ [추가] 사용자 위치 정보가 없으면, 게시물에 기본 Tangerang 위치를 설정
          final postLocationKab = postData['locationParts']?['kab'];
          if (postLocationKab == null || postLocationKab == '') {
            postBatch.update(postDoc.reference, {
              'locationName': defaultLocationName,
              'locationParts': defaultLocationParts,
              'geoPoint': defaultGeoPoint,
            });
            postsUpdatedCount++;
            setState(() => _log +=
                '  - [기본값 설정] post/${postDoc.id} (위치 없음 -> Tangerang)\n');
          }
        }
      }
      if (postsUpdatedCount > 0) {
        await postBatch.commit();
      }
      setState(
          () => _log += '  - 총 $postsUpdatedCount개의 게시물 위치 정보를 업데이트했습니다.\n');

      // --- 3. 상품(Products) 데이터 보정 ---
      // 상품 보정 로직도 게시물과 동일하게 수정
      setState(() => _log += '\n3. 상품(products) 데이터 보정을 시작합니다...\n');
      final productsSnapshot = await firestore.collection('products').get();
      WriteBatch productBatch = firestore.batch();
      int productsUpdatedCount = 0;

      for (var productDoc in productsSnapshot.docs) {
        final productData = productDoc.data();
        final userId = productData['userId'];
        final user = userLocationMap[userId];

        if (user != null &&
            user.locationParts != null &&
            user.locationParts!.isNotEmpty) {
          final productLocationKab = productData['locationParts']?['kab'];
          if (productLocationKab != user.locationParts?['kab']) {
            productBatch.update(productDoc.reference, {
              'locationName': user.locationName,
              'locationParts': user.locationParts,
              'geoPoint': user.geoPoint,
            });
            productsUpdatedCount++;
            setState(() => _log +=
                '  - [위치 수정] product/${productDoc.id} ($productLocationKab -> ${user.locationParts?['kab']})\n');
          }
        } else {
          final productLocationKab = productData['locationParts']?['kab'];
          if (productLocationKab == null || productLocationKab == '') {
            productBatch.update(productDoc.reference, {
              'locationName': defaultLocationName,
              'locationParts': defaultLocationParts,
              'geoPoint': defaultGeoPoint,
            });
            productsUpdatedCount++;
            setState(() => _log +=
                '  - [기본값 설정] product/${productDoc.id} (위치 없음 -> Tangerang)\n');
          }
        }
      }
      if (productsUpdatedCount > 0) {
        await productBatch.commit();
      }
      setState(
          () => _log += '  - 총 $productsUpdatedCount개의 상품 위치 정보를 업데이트했습니다.\n');

      setState(() => _log += '\n🎉 모든 데이터 보정이 완료되었습니다!');
    } catch (e) {
      setState(() => _log += '\n❌ 에러 발생: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('데이터 보정 스크립트'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _isProcessing ? null : _runFixScript,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _isProcessing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('데이터 보정 시작 (주의: 되돌릴 수 없음)'),
            ),
            const SizedBox(height: 24),
            const Text(
              '실행 로그:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Expanded(
              child: Container(
                color: Colors.grey[200],
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Text(_log),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
