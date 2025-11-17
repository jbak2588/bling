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
// lib/features/marketplace/screens/ai_takeover_screen.dart
library;

import 'dart:io';
import 'package:bling_app/core/utils/upload_helpers.dart';
import 'package:bling_app/features/marketplace/data/product_repository.dart';
import 'package:bling_app/features/marketplace/models/product_model.dart';
import 'package:bling_app/features/marketplace/widgets/ai_report_viewer.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:typed_data';
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
  final List<XFile> _newPhotos = [];
  final List<Uint8List> _newPhotoBytes = [];
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

  /// 현장에서 새 사진 촬영
  Future<void> _pickPhotos() async {
    // [Task 107] 카메라/갤러리 선택 팝업 (Task 65 로직 재사용)
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: Text(
                StringTranslateExtension('ai_flow.common.take_photo').tr()),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: Text(
                StringTranslateExtension('ai_flow.common.pick_gallery_multi')
                    .tr()), // "갤러리에서 여러 장 선택"
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
        ],
      ),
    );

    if (source == ImageSource.camera) {
      final XFile? img = await _picker.pickImage(
          source: source!, imageQuality: 80, maxWidth: 1024);
      if (img != null && mounted) {
        try {
          final tempDir = await getTemporaryDirectory();
          final ext = p.extension(img.path);
          final destPath = p.join(tempDir.path, '${const Uuid().v4()}$ext');
          final bytes = await img.readAsBytes();
          await File(destPath).writeAsBytes(bytes);
          final copiedLen = File(destPath).lengthSync();
          final fingerprint = base64Encode(bytes.take(20).toList());
          debugPrint(
              'camera: original=${img.path}, copied=$destPath, exists=${File(destPath).existsSync()}, size=$copiedLen, fp=$fingerprint');
          if (mounted) {
            setState(() {
              _newPhotos.add(XFile(destPath));
              _newPhotoBytes.add(bytes);
            });
          }
        } catch (e) {
          debugPrint('Error copying camera image: $e');
          if (mounted) {
            setState(() {
              _newPhotos.add(img);
              img.readAsBytes().then((b) {
                if (mounted) {
                  setState(() {
                    _newPhotoBytes.add(b);
                  });
                }
              });
            });
          }
        }
      }
    } else if (source == ImageSource.gallery) {
      final List<XFile> picked =
          await _picker.pickMultiImage(imageQuality: 80, maxWidth: 1024);
      if (picked.isNotEmpty && mounted) {
        final tempDir = await getTemporaryDirectory();
        final List<XFile> copied = [];
        final List<Uint8List> copiedBytes = [];
        for (final x in picked) {
          final bytes = await x.readAsBytes();
          debugPrint(
              'gallery picked original=${x.path}, exists=${File(x.path).existsSync()}, size=${bytes.length}');
          try {
            final ext = p.extension(x.path);
            final destPath = p.join(tempDir.path, '${const Uuid().v4()}$ext');
            await File(destPath).writeAsBytes(bytes);
            final copiedLen = File(destPath).lengthSync();
            final fingerprint = base64Encode(bytes.take(20).toList());
            debugPrint(
                'gallery copied to=$destPath, exists=${File(destPath).existsSync()}, size=$copiedLen, fp=$fingerprint');
            copied.add(XFile(destPath));
            copiedBytes.add(bytes);
          } catch (e) {
            debugPrint('Error copying gallery image ${x.path}: $e');
            // fallback to original if copy fails
            copied.add(x);
            copiedBytes.add(bytes);
          }
        }
        if (mounted) {
          setState(() {
            _newPhotos.addAll(copied);
            _newPhotoBytes.addAll(copiedBytes);
          });
        }
      }
    }
  }

  /// AI 동일성 검증 시작
  Future<void> _startOnSiteVerification() async {
    if (_newPhotos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              StringTranslateExtension('marketplace.takeover.errors.noPhoto')
                  .tr())));
      return;
    }

    setState(() => _isVerifying = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isVerifying = false);
      return;
    }

    try {
      // 1. 현장 사진 업로드
      final List<String> newImageUrls =
          await uploadAllProductImages(_newPhotos, user.uid);

      // 2. 백엔드 'verifyProductOnSite' 함수 호출
      final callable = FirebaseFunctions.instanceFor(region: 'asia-southeast2')
          .httpsCallable('verifyProductOnSite');
      final result = await callable.call(<String, dynamic>{
        'productId': widget.product.id,
        'newImageUrls': newImageUrls,
        'locale': context.locale.languageCode,
      });

      // [Task 116] Cloud Functions v2 응답은 보통 Map<dynamic, dynamic>으로 역직렬화되므로
      //            바로 Map<String, dynamic>으로 타입 체크하면 실패할 수 있습니다.
      //            → 먼저 dynamic으로 받은 뒤, 실제 Map인지 여부만 확인하고
      //              Map<String, dynamic>.from(...)으로 안전하게 캐스팅합니다.
      final dynamic data = result.data;
      final dynamic verificationData =
          (data is Map) ? data['verification'] : null;

      if (verificationData is Map) {
        // V3: match가 true, false, null(AI 실패)인 경우 모두 _showVerificationResult가 처리
        _showVerificationResult(
          Map<String, dynamic>.from(verificationData),
        );
      } else {
        // 'verification' 키 자체가 없거나 Map이 아닌 경우 (예: HttpsError가 아닌 다른 이유로 실패)
        throw Exception('AI가 유효한 검증 결과(JSON)를 반환하지 못했습니다.');
      }
    } on FirebaseFunctionsException catch (e) {
      // [Task 107 HOTFIX] 백엔드가 'data-loss', 'internal' 등 HttpsError를 던진 경우
      BArtSnackBar.showErrorSnackBar(
          title: 'AI 검증 실패', message: e.message ?? '알 수 없는 서버 오류가 발생했습니다.');
      Logger.error('AI Takeover Error (Firebase)',
          error: e, stackTrace: e.stackTrace);
    } catch (e, stackTrace) {
      // [Task 107 HOTFIX] 앱 내부에서 발생한 기타 오류 (e.g., throw Exception)
      BArtSnackBar.showErrorSnackBar(
          title: '오류 발생', message: e.toString().replaceAll('Exception: ', ''));
      Logger.error('AI Takeover Error (Generic)',
          error: e, stackTrace: stackTrace);
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
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

            // [Task 99] V3 현장 검증 체크리스트
            if (_checklistItems.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                StringTranslateExtension('marketplace.takeover.checklistTitle')
                    .tr(), // "현장 검증 체크리스트"
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              // 체크리스트 항목들을 순회하며 표시
              ..._checklistItems.map((item) => Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                          color: Theme.of(context).colorScheme.outlineVariant),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: Icon(Icons.fact_check_outlined,
                          color: Theme.of(context).colorScheme.primary),
                      title: Text(item.checkPoint,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(item.instruction),
                    ),
                  )),
            ],

            const Divider(height: 32),
            // 사진 촬영 섹션
            Text(
              StringTranslateExtension('marketplace.takeover.photoTitle').tr(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._newPhotoBytes.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final bytes = entry.value;
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      bytes,
                      key: ValueKey(idx),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  );
                }),
                GestureDetector(
                  onTap: _pickPhotos,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[400]!),
                    ),
                    child: const Icon(Icons.add_a_photo_outlined, size: 32),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
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
}
