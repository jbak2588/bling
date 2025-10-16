// lib/features/marketplace/screens/ai_guided_camera_screen.dart

import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:bling_app/features/marketplace/models/ai_verification_rule_model.dart';
import 'package:bling_app/features/marketplace/screens/ai_final_report_screen.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart'; // [추가] 사용자 ID를 가져오기 위해 import
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';

class AiGuidedCameraScreen extends StatefulWidget {
  final AiVerificationRule rule;
  final List<XFile> initialImages;
  final String confirmedProductName;

  const AiGuidedCameraScreen({
    super.key,
    required this.rule,
    required this.initialImages,
    required this.confirmedProductName,
  });

  @override
  State<AiGuidedCameraScreen> createState() => _AiGuidedCameraScreenState();
}

class _AiGuidedCameraScreenState extends State<AiGuidedCameraScreen> {
  final ImagePicker _picker = ImagePicker();
  final Map<String, XFile> _takenShots = {};
  bool _isLoading = false;

  bool get _allShotsTaken =>
      _takenShots.length == widget.rule.requiredShots.length;

  Future<void> _takePicture(String shotKey) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxWidth: 1024,
    );
    if (image == null) return;
    setState(() {
      _takenShots[shotKey] = image;
    });
  }

  // ==================== [최종 수정 부분 시작] ====================
  Future<void> _requestFinalAnalysis() async {
    setState(() => _isLoading = true);
    try {
      final imageUrls = await _uploadAllImages();
      final report = await _callGenerateFinalReport(imageUrls);

      debugPrint("✅✅✅ Server Response Received ✅✅✅");
      debugPrint(report.toString());

      if (mounted) {
        // [최종 복원] 진단용 팝업 코드를 삭제하고,
        // 성공적으로 받은 report 데이터를 AiFinalReportScreen으로 전달하여 화면을 이동시킵니다.
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AiFinalReportScreen(
              finalReport: report,
              rule: widget.rule,
              initialImages: widget.initialImages,
              takenShots: _takenShots,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("❌❌❌ Function Call Failed ❌❌❌");
      debugPrint(e.toString());
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("서버 응답 결과 (실패)"),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("닫기"),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // [핵심] 서버에서 받은 Map을 안전하게 Map<String, dynamic>으로 변환하는 재귀 함수
  Map<String, dynamic> _deepCastMap(Map<dynamic, dynamic> originalMap) {
    final newMap = <String, dynamic>{};
    originalMap.forEach((key, value) {
      var newKey = key.toString();
      dynamic newValue = value;
      if (value is Map) {
        newValue = _deepCastMap(value);
      } else if (value is List) {
        newValue = value.map((item) {
          if (item is Map) {
            return _deepCastMap(item);
          }
          return item;
        }).toList();
      }
      newMap[newKey] = newValue;
    });
    return newMap;
  }

  Future<Map<String, dynamic>> _callGenerateFinalReport(
      Map<String, dynamic> imageUrls) async {
    final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
    final callable = functions.httpsCallable('generatefinalreport');
    final response = await callable.call<Map<String, dynamic>>({
      'ruleId': widget.rule.id,
      'confirmedProductName':
          widget.confirmedProductName, // [추가] 사용자가 수정한 최종 상품명 전달
      'imageUrls': imageUrls,
      // TODO: 추후 사용자에게 가격/설명 입력받는 UI 추가 시, 아래 값 전달
      'userPrice': null,
      'userDescription': null,
    });

    final data = response.data;
    if (data['success'] != true) {
      throw StateError(data['error'] ?? 'Unknown error from function');
    }
    // [핵심 수정] 불안정한 자동 형변환(as) 대신, 안전한 수동 변환 함수를 사용합니다.
    final reportMap = data['report'] as Map;
    return _deepCastMap(reportMap);
  }
  // ==================== [최종 수정 부분 끝] ====================

  // [추가] 모든 이미지를 Storage에 업로드하고 구조화된 URL 맵을 반환합니다.
  Future<Map<String, dynamic>> _uploadAllImages() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User is not logged in.");
    }
    final storage = FirebaseStorage.instance;

    // 초기 갤러리 이미지 업로드
    final initialUploads = widget.initialImages.map((file) async {
      // [수정] 보안 규칙에 맞게 userId를 경로에 포함시킵니다.
      final ref = storage.ref(
        'ai_uploads/${user.uid}/${DateTime.now().millisecondsSinceEpoch}-${p.basename(file.path)}',
      );
      await ref.putFile(File(file.path));
      return ref.getDownloadURL();
    });
    final initialUrls = await Future.wait(initialUploads);

    // 가이드 촬영 이미지 업로드
    final guidedUploads = _takenShots.entries.map((entry) async {
      final file = entry.value;
      final key = entry.key;
      // [수정] 보안 규칙에 맞게 userId를 경로에 포함시킵니다.
      final ref = storage.ref(
        'ai_uploads/${user.uid}/${DateTime.now().millisecondsSinceEpoch}-guided-$key-${p.basename(file.path)}',
      );
      await ref.putFile(File(file.path));
      final url = await ref.getDownloadURL();
      return MapEntry(key, url);
    });
    final guidedUrls = Map.fromEntries(await Future.wait(guidedUploads));

    return {
      'initial': initialUrls,
      'guided': guidedUrls,
    };
  }

  // ... (build 메소드 등 나머지 코드는 동일) ...
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ai_flow.guided_camera.title'.tr())),
      body: ListView.builder(
        itemCount: widget.rule.requiredShots.length,
        itemBuilder: (context, index) {
          final shotKey = widget.rule.requiredShots.keys.elementAt(index);
          final shotRule = widget.rule.requiredShots[shotKey]!;
          final takenImage = _takenShots[shotKey];
          final isCompleted = takenImage != null;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: isCompleted ? 1 : 4,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    isCompleted ? Colors.green : Theme.of(context).primaryColor,
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white)
                    : Text('${index + 1}',
                        style: const TextStyle(color: Colors.white)),
              ),
              title: Text(context.locale.languageCode == 'ko'
                  ? shotRule.nameKo
                  : shotRule.nameKo),
              subtitle: Text(context.locale.languageCode == 'ko'
                  ? shotRule.descKo
                  : shotRule.descKo),
              trailing: takenImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(4.0),
                      child: Image.file(File(takenImage.path),
                          width: 50, height: 50, fit: BoxFit.cover),
                    )
                  : const Icon(Icons.camera_alt_outlined),
              onTap: () => _takePicture(shotKey),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed:
              _allShotsTaken && !_isLoading ? _requestFinalAnalysis : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text('ai_flow.guided_camera.next_button'.tr()),
        ),
      ),
    );
  }
}
