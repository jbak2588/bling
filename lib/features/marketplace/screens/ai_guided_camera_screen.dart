// lib/features/marketplace/screens/ai_guided_camera_screen.dart

import 'dart:io';
import 'package:bling_app/features/marketplace/models/ai_verification_rule_model.dart';
import 'package:bling_app/features/marketplace/screens/ai_final_report_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:geolocator/geolocator.dart';
import 'package:exif/exif.dart';

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
  final bool _isLoading = false; // lint fix: could be final

  // 모든 필수 샷이 촬영되었는지 확인
  bool get _allShotsTaken =>
      _takenShots.length == widget.rule.requiredShots.length;

  Future<void> _takePicture(String shotKey) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image == null) return;

    // 위치 정보 검증
    final isLocationVerified = await _verifyLocation(image);
    if (!isLocationVerified && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ai_flow.guided_camera.location_error'.tr())),
      );
      return;
    }

    setState(() {
      _takenShots[shotKey] = image;
    });
  }

  // 사진의 메타데이터 위치와 현재 위치 비교
  Future<bool> _verifyLocation(XFile image) async {
    try {
      // 1. 사진의 EXIF 데이터에서 GPS 정보 읽기
      final fileBytes = await image.readAsBytes();
      final exifData = await readExifFromBytes(fileBytes);
      final latValue = exifData['GPS GPSLatitude']?.values.toList();
      final lonValue = exifData['GPS GPSLongitude']?.values.toList();

      if (latValue == null || lonValue == null) return false; // 사진에 GPS 정보 없음

      final imageLat = latValue[0].toDouble() +
          (latValue[1].toDouble() / 60) +
          (latValue[2].toDouble() / 3600);
      final imageLon = lonValue[0].toDouble() +
          (lonValue[1].toDouble() / 60) +
          (lonValue[2].toDouble() / 3600);

      // 2. 사용자의 현재 위치 가져오기
      final position = await Geolocator.getCurrentPosition();

      // 3. 두 위치 간의 거리 계산 (500m 이내 허용)
      final distance = Geolocator.distanceBetween(
        imageLat,
        imageLon,
        position.latitude,
        position.longitude,
      );

      return distance <= 500;
    } catch (e) {
      debugPrint("Location verification failed: $e");
      return false;
    }
  }

  void _requestFinalAnalysis() {
    if (!_allShotsTaken) return;
    // 기존: ScaffoldMessenger...
    // 수정: 새로 만든 최종 보고서 화면으로 이동
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => AiFinalReportScreen(
        rule: widget.rule,
        initialImages: widget.initialImages,
        takenShots: _takenShots,
        confirmedProductName: widget.confirmedProductName,
      ),
    ));
    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(content: Text('모든 사진 촬영 완료. 최종 분석을 요청합니다.')),
    // );
  }

  @override
  Widget build(BuildContext context) {
    final requiredShots = widget.rule.requiredShots.entries.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('ai_flow.guided_camera.title'.tr()),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: requiredShots.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final shotEntry = requiredShots[index];
          final shotKey = shotEntry.key;
          final shotRule = shotEntry.value;
          final takenImage = _takenShots[shotKey];

          return Card(
            elevation: takenImage != null ? 1 : 3,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: takenImage != null
                    ? Colors.green
                    : Theme.of(context).primaryColor,
                child: takenImage != null
                    ? const Icon(Icons.check, color: Colors.white)
                    : Text('${index + 1}',
                        style: const TextStyle(color: Colors.white)),
              ),
              title: Text(context.locale.languageCode == 'ko'
                  ? shotRule.nameKo
                  : shotRule.nameKo), // 임시: 다국어 키로 변경 필요
              subtitle: Text(context.locale.languageCode == 'ko'
                  ? shotRule.descKo
                  : shotRule.descKo), // 임시: 다국어 키로 변경 필요
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
          child: Text('ai_flow.guided_camera.next_button'.tr()),
        ),
      ),
    );
  }
}
