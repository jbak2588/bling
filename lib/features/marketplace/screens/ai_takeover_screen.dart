/// ============================================================================
/// Bling DocHeader
/// Module        : Marketplace (AI 인수 V2.2)
/// File          : lib/features/marketplace/screens/ai_takeover_screen.dart
/// Purpose       : AI 인수 2단계: '현장 동일성 검증' UI
///
/// [기능 요약 (Job 5, 6)]
/// 1. 이 화면은 'AI 안심 예약'을 완료한 구매자만 진입할 수 있습니다.
/// 2. `AiReportViewer`를 통해 판매자가 등록한 '원본 AI 보고서'를 표시합니다.
/// 3. 구매자는 현장에서 실제 상품의 사진을 촬영합니다 (`_pickPhotos`).
/// 4. 'AI 동일성 검증 시작' 버튼을 누르면:
///    - 현장 사진을 업로드하고 (`_startOnSiteVerification`)
///    - 백엔드 `verifyProductOnSite` 함수를 호출합니다.
/// 5. AI의 `match: true/false` 결과에 따라 다이얼로그를 표시합니다.
///    - [Match] -> `_finalizeTakeover` (product_repository.completeTakeover 호출)
///    - [No Match] -> `_cancelReservation` (product_repository.cancelReservation 호출)
/// ============================================================================
/// ============================================================================
/// Bling DocHeader (V3.1 Takeover UI Stabilization, 2025-11-18)
/// Module        : Marketplace (AI 인수)
/// File          : lib/features/marketplace/screens/ai_takeover_screen.dart
/// Purpose       : 구매자 현장 인수 검증 화면.
///
/// [Major Fixes & Improvements]
/// 1. [Bug Fix] Android Image Picker Duplication:
///    - image_picker의 내부 압축을 끄고, 'flutter_image_compress' 패키지를 도입하여
///      파일명 중복(scaled_0.png) 문제와 고용량 전송 오류(resource-exhausted) 동시 해결.
/// 2. [Performance] OOM(Out of Memory) Prevention:
///    - 고화질 원본 사진을 메모리(Bytes)에 적재하지 않고 File 경로로 관리하여 앱 튕김 방지.
/// 3. [UX] Checklist-Based Capture:
///    - 기존 스크롤 방식에서 '체크리스트 항목별 카드형 촬영 UI'로 개편하여
///      사용자가 직관적으로 필요한 증거를 매핑할 수 있도록 개선.
/// 4. [Architecture] Repository Pattern 적용 (AiCaseRepository 사용).
/// ============================================================================
// lib/features/marketplace/screens/ai_takeover_screen.dart
library;

import 'dart:io';
import 'package:bling_app/features/marketplace/data/ai_case_repository.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart'; // [Fix] 압축 패키지 추가
import 'package:bling_app/features/marketplace/data/product_repository.dart';
import 'package:bling_app/features/marketplace/models/product_model.dart';
import 'package:bling_app/features/marketplace/widgets/ai_report_viewer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// removed heavy imports: using file-based image handling instead of raw bytes
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
// [Task 107] BArtSnackBar, Logger 임포트
import 'package:bling_app/core/utils/popups/snackbars.dart';
import 'package:bling_app/core/utils/logging/logger.dart';
// import 'package:get/get.dart'; // Get.to 사용을 위해

// [Task 99] V3 체크리스트 항목을 파싱하기 위한 간단한 헬퍼 클래스
class _ChecklistItem {
  final String checkPoint;
  final String instruction;
  _ChecklistItem({required this.checkPoint, required this.instruction});
}

/// AI 인수 2단계: 현장 동일성 검증 화면
class AiTakeoverScreen extends StatefulWidget {
  final ProductModel product;
  const AiTakeoverScreen({super.key, required this.product});

  @override
  State<AiTakeoverScreen> createState() => _AiTakeoverScreenState();
}

class _AiTakeoverScreenState extends State<AiTakeoverScreen> {
  final ImagePicker _picker = ImagePicker();
  // [변경 1] 체크리스트 인덱스 -> 사진 매핑
  final Map<int, XFile> _checklistPhotos = {};
  // [Fix] OOM 방지: 이미지를 바이트로 메모리에 들고 있지 않고, 파일 경로로만 관리함.
  // final List<Uint8List> _newPhotoBytes = [];
  bool _isVerifying = false;
  List<_ChecklistItem> _checklistItems = []; // [Task 99] V3 체크리스트 상태 변수

  @override
  void initState() {
    super.initState();
    _parseChecklist(); // [Task 99] 위젯이 로드될 때 V3 체크리스트를 파싱합니다.
  }

  /// [Task 99] V3 AI 리포트에서 현장 검증 체크리스트를 파싱합니다.
  void _parseChecklist() {
    try {
      final report =
          widget.product.aiReport ?? widget.product.aiVerificationData;
      if (report == null) return;

      final dynamic checklist = report['onSiteVerificationChecklist'];
      if (checklist is Map) {
        final dynamic checks = checklist['checks'];
        if (checks is List) {
          final List<_ChecklistItem> items = [];
          for (var item in checks) {
            if (item is Map) {
              items.add(_ChecklistItem(
                checkPoint: item['checkPoint']?.toString() ?? 'N/A',
                instruction: item['instruction']?.toString() ?? '...',
              ));
            }
          }
          if (mounted) {
            setState(() {
              _checklistItems = items;
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error parsing AI checklist: $e");
    }
  }

  // [Fix] 이미지 안전 압축 헬퍼 함수
  Future<File?> _compressImage(File file) async {
    try {
      final String targetPath = '${file.path}_compressed.jpg';
      final XFile? result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path, targetPath,
        quality: 80, // 품질 80% (용량 대폭 감소)
        rotate: 0, // 자동 회전 방지
      );
      return result != null ? File(result.path) : file;
    } catch (e) {
      return file; // 압축 실패 시 원본 반환
    }
  }

  /// 현장에서 새 사진 촬영
  // [변경 2] 특정 체크리스트 항목(index)에 사진을 촬영/선택하여 매핑합니다.
  Future<void> _pickPhotoForIndex(int index, ImageSource source) async {
    try {
      final XFile? img = await _picker.pickImage(source: source);

      if (img != null && mounted) {
        final compressedFile = await _compressImage(File(img.path));
        final tempDir = await getTemporaryDirectory();
        final ext = p.extension(img.path);
        final destPath = p.join(tempDir.path, '${const Uuid().v4()}$ext');
        await compressedFile?.copy(destPath);

        if (mounted) {
          setState(() {
            _checklistPhotos[index] = XFile(destPath);
          });
        }
      }
    } catch (e) {
      debugPrint('Error picking photo for index $index: $e');
      BArtSnackBar.showErrorSnackBar(
          title: '오류', message: '이미지 선택 중 오류가 발생했습니다.');
    }
  }

  /// AI 동일성 검증 시작
  Future<void> _startOnSiteVerification() async {
    // [변경 3] 체크리스트 기반 사진 사용: Map -> List 변환
    if (_checklistPhotos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              StringTranslateExtension('marketplace.takeover.errors.noPhoto')
                  .tr())));
      return;
    }

    final List<XFile> photosToSend = _checklistPhotos.values.toList();

    setState(() => _isVerifying = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isVerifying = false);
      return;
    }

    try {
      final repository = AiCaseRepository();

      final List<String> newImageUrls = await repository.uploadEvidenceImages(
        images: photosToSend,
        folderName: 'takeover',
      );

      final result = await repository.requestTakeoverVerification(
        productId: widget.product.id,
        newImageUrls: newImageUrls,
      );

      final dynamic verificationData = result['verification'];
      if (verificationData is Map) {
        _showVerificationResult(Map<String, dynamic>.from(verificationData));
      } else {
        throw Exception('AI가 유효한 검증 결과(JSON)를 반환하지 못했습니다.');
      }
    } catch (e, stackTrace) {
      BArtSnackBar.showErrorSnackBar(
          title: '오류 발생', message: e.toString().replaceAll('Exception: ', ''));
      Logger.error('AI Takeover Error (Generic)',
          error: e, stackTrace: stackTrace);
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  /// AI 검증 결과 다이얼로그 표시
  void _showVerificationResult(Map<String, dynamic> result) {
    // [Task 110/111] 3-Way-Logic: match는 true, false, 또는 null(AI 실패)일 수 있음
    final bool? match = result['match'] as bool?; // null을 허용하는 bool?로 받음
    final String reason = result['reason'] ?? 'No reason provided.';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        // [Task 110/111] 3가지 상태(true, false, null)에 따라 아이콘과 제목 변경
        icon: Icon(
          match == true
              ? Icons.check_circle_outline
              : (match == false
                  ? Icons.error_outline
                  : Icons.wifi_tethering_error_rounded),
          color: match == true ? Colors.green : Colors.red,
          size: 48,
        ),
        title: Text(match == true
            ? 'marketplace.takeover.dialog.matchTitle'.tr()
            : (match == false
                ? 'marketplace.takeover.dialog.noMatchTitle'.tr()
                : 'marketplace.takeover.dialog.failTitle'.tr())),
        content: Text(reason),
        actions: [
          if (match == true) ...[
            // [Case 1: Match] - 거래 확정
            FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _finalizeTakeover(); // [3단계] 최종 인수 확정
              },
              child: Text('marketplace.takeover.dialog.finalize'.tr()),
            ),
          ] else if (match == false) ...[
            // [Case 2: No Match] - 거래 취소
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _cancelReservation(); // [3단계] 거래 취소 (환불)
                  },
                  child: Text('marketplace.takeover.dialog.cancelDeal'.tr()),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text('marketplace.dialog.close'.tr()),
                ),
              ],
            ),
          ] else ...[
            // [Case 3: AI Failure (match == null)] - 재시도 옵션 제공
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('marketplace.dialog.close'.tr()),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _startOnSiteVerification(); // [Task 110] AI 검증 재시도
              },
              child: Text('marketplace.takeover.dialog.retry'.tr()),
            ),
          ],
        ],
      ),
    );
  }

  /// [3단계-A] 최종 인수 확정 (Repository 호출)
  Future<void> _finalizeTakeover() async {
    setState(() => _isVerifying = true);
    try {
      final productRepository = ProductRepository();
      await productRepository.completeTakeover(productId: widget.product.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(StringTranslateExtension(
                    'marketplace.takeover.success.finalized')
                .tr())));
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  /// [3단계-B] 예약 취소 및 환불 (Repository 호출)
  Future<void> _cancelReservation() async {
    setState(() => _isVerifying = true);
    try {
      // TODO: PG사 환불 API 호출
      // (환불 성공 시)
      final productRepository = ProductRepository();
      await productRepository.cancelReservation(productId: widget.product.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(StringTranslateExtension(
                    'marketplace.takeover.success.cancelled')
                .tr())));
        Navigator.of(context).pop(); // 상세 화면으로 복귀
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(StringTranslateExtension('marketplace.takeover.title').tr()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              StringTranslateExtension('marketplace.takeover.guide.title').tr(),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(StringTranslateExtension('marketplace.takeover.guide.subtitle')
                .tr()),
            const SizedBox(height: 16),
            // [AI 리팩토링] 공용 위젯을 사용하여 원본 리포트 표시
            AiReportViewer(
              aiReport: Map<String, dynamic>.from(widget.product.aiReport ??
                  widget.product.aiVerificationData ??
                  {}),
            ),

            // [변경 4] 체크리스트 항목별 촬영 UI
            if (_checklistItems.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                StringTranslateExtension('marketplace.takeover.checklistTitle')
                    .tr(),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),

              // 체크리스트 항목별 카드(사진 슬롯 포함)
              ..._checklistItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final hasPhoto = _checklistPhotos.containsKey(index);

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.check_circle_outline,
                                color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.checkPoint,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.instruction,
                          style:
                              TextStyle(color: Colors.grey[700], fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        hasPhoto
                            ? _buildPhotoPreview(index)
                            : _buildCameraButtons(index),
                      ],
                    ),
                  ),
                );
              }),
            ],

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isVerifying ? null : _startOnSiteVerification,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isVerifying
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    )
                  : Text(StringTranslateExtension(
                          'marketplace.takeover.buttonVerify')
                      .tr()),
            ),
          ],
        ),
      ),
    );
  }

  // [신규 위젯] 사진이 없을 때: 카메라/갤러리 버튼
  Widget _buildCameraButtons(int index) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _pickPhotoForIndex(index, ImageSource.camera),
            icon: const Icon(Icons.camera_alt),
            label: Text('marketplace.takeover.camera'.tr()),
            style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _pickPhotoForIndex(index, ImageSource.gallery),
            icon: const Icon(Icons.photo_library),
            label: Text('marketplace.takeover.gallery'.tr()),
            style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12)),
          ),
        ),
      ],
    );
  }

  // [신규 위젯] 사진이 있을 때: 미리보기 및 재촬영/삭제 버튼
  Widget _buildPhotoPreview(int index) {
    final file = _checklistPhotos[index];
    if (file == null) return const SizedBox.shrink();
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(file.path),
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _checklistPhotos.remove(index);
              });
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }
}
