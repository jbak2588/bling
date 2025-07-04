// lib/features/admin/screens/data_uploader_screen.dart
// Bling App v0.4
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';

class DataUploaderScreen extends StatefulWidget {
  const DataUploaderScreen({super.key});

  @override
  State<DataUploaderScreen> createState() => _DataUploaderScreenState();
}

class _DataUploaderScreenState extends State<DataUploaderScreen> {
  bool _isLoading = false;
  final List<String> _logs = [];

  void _addLog(String log) {
    setState(() {
      _logs.add(log);
    });
  }

  Future<void> _uploadData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _logs.clear();
    });

    try {
      final firestore = FirebaseFirestore.instance;

      _addLog('1. 모든 사용자 정보를 가져오는 중...');
      final usersSnapshot = await firestore.collection('users').get();
      final userIds = usersSnapshot.docs.map((doc) => doc.id).toList();

      if (userIds.isEmpty) {
        throw Exception('오류: Firestore에 등록된 사용자가 없습니다.');
      }
      _addLog('-> ${userIds.length}명의 사용자 정보를 찾았습니다.');

      _addLog('2. sample_posts.json 파일을 읽는 중...');
      // [수정] 이제 앱 내부의 애셋(asset)에서 파일을 읽어옵니다.
      final jsonString =
          await rootBundle.loadString('assets/data/sample_posts.json');
      final List<dynamic> posts = jsonDecode(jsonString);
      _addLog('-> ${posts.length}개의 게시물 데이터를 찾았습니다.');

      _addLog('3. Firestore에 데이터 업로드를 시작합니다...');
      final batch = firestore.batch();
      int count = 0;

      for (var postData in posts) {
        if (postData is Map<String, dynamic>) {
          final randomUserId = (userIds..shuffle()).first;
          postData['userId'] = randomUserId;
          postData['createdAt'] = FieldValue.serverTimestamp();

          final postRef = firestore.collection('posts').doc();
          batch.set(postRef, postData);
          count++;
        }
      }

      await batch.commit();
      _addLog('🎉 성공! 총 $count 개의 샘플 게시물이 Firestore에 업로드되었습니다.');
    } catch (e) {
      _addLog('❌ 에러 발생: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('샘플 데이터 업로더')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _uploadData,
              icon: const Icon(Icons.upload_file),
              label: const Text('게시물 샘플 데이터 업로드 시작'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 20),
            const Text('작업 로그:', style: TextStyle(fontWeight: FontWeight.bold)),
            const Divider(),
            Expanded(
              child: Container(
                color: Colors.grey[200],
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  itemCount: _logs.length,
                  itemBuilder: (context, index) {
                    return Text(_logs[index]);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
